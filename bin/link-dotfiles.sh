#!/usr/bin/env bash
# Link tracked config files from this repo into their live locations.
#
#   link-dotfiles.sh            create/repair links; refuse on a content conflict
#   link-dotfiles.sh --adopt    on a conflict, take the LIVE file's content into the repo
#   link-dotfiles.sh --check    report only; exit non-zero if anything is not linked
#
# Links are absolute, and made per-FILE, never per-directory: ~/.claude and ~/.config/herdr
# hold transcripts, logs and sockets alongside the config, so a directory link would expose
# all of it, and per-file lets one command be tracked while another stays local.
#
# (This replaced a symlink farm manager. Don't reintroduce one: it would want to own whole
# package directories, and it can't produce the absolute links already in place here.)
#
# The --adopt path exists because tools rewrite their own config: Claude Code replaced
# ~/.claude/settings.json (a symlink) with a regular file during a doctor run, which silently
# froze the repo copy. `--check` catches that; `--adopt` recovers it.

set -uo pipefail

REPO="$(cd "$(dirname "$0")/.." && pwd)"

# repo-relative path : absolute live target
MAP=(
  "claude/.claude/CLAUDE.md:$HOME/.claude/CLAUDE.md"
  "claude/.claude/settings.json:$HOME/.claude/settings.json"
  "claude/.claude/statusline-command.sh:$HOME/.claude/statusline-command.sh"
  "claude/.claude/hooks/herdr-agent-state.sh:$HOME/.claude/hooks/herdr-agent-state.sh"
  "claude/.claude/hooks/worktree-on-plan-exit.sh:$HOME/.claude/hooks/worktree-on-plan-exit.sh"
  "claude/.claude/output-styles/eli5.md:$HOME/.claude/output-styles/eli5.md"
  "claude/.claude/skills/bro/SKILL.md:$HOME/.claude/skills/bro/SKILL.md"
  "herdr/.config/herdr/config.toml:$HOME/.config/herdr/config.toml"
  "herdr/.config/herdr/plugins.json:$HOME/.config/herdr/plugins.json"
  "herdr/.config/herdr/scripts/mr-token.sh:$HOME/.config/herdr/scripts/mr-token.sh"
  "herdr/.config/herdr/scripts/new-worktree.sh:$HOME/.config/herdr/scripts/new-worktree.sh"
  "herdr/.config/herdr/scripts/notify.sh:$HOME/.config/herdr/scripts/notify.sh"
  "agents/.agents/skills/find-skills:$HOME/.agents/skills/find-skills"
  "agents/.agents/skills/herdr:$HOME/.agents/skills/herdr"
)

# Intentionally NOT linked, so they never reach this public repo:
#   ~/.zshrc_work.zsh              work-machine only; holds API keys
#
# ~/.claude/CLAUDE.md used to be on that list for the same reason. The sections that named
# employer-internal repos moved into a shared team plugin, so what is left is generic and is
# now tracked — but it is a public repo, so keep it that way: a rule that only makes sense
# with an internal repo, org or hostname in it belongs in the plugin, not here.

mode=link
case "${1:-}" in
  --check) mode=check ;;
  --adopt) mode=adopt ;;
  "")      ;;
  *)       echo "usage: $(basename "$0") [--check|--adopt]" >&2; exit 2 ;;
esac

red()   { printf '\033[31m%s\033[0m' "$*"; }
green() { printf '\033[32m%s\033[0m' "$*"; }
amber() { printf '\033[33m%s\033[0m' "$*"; }

drift=0

for entry in "${MAP[@]}"; do
  rel="${entry%%:*}"
  target="${entry#*:}"
  src="$REPO/$rel"
  label="${target/$HOME/~}"

  # Already linked where it should be.
  if [[ -L "$target" && "$(readlink "$target")" == "$src" ]]; then
    printf '%s  %s\n' "$(green ok)" "$label"
    continue
  fi

  drift=1
  if [[ "$mode" == check ]]; then
    if [[ -L "$target" ]]; then
      reason="links elsewhere → $(readlink "$target")"
    elif [[ -e "$target" && ! -e "$src" ]]; then
      reason="live only, not in the repo yet"
    elif [[ -e "$target" ]] && [[ -f "$target" && -f "$src" ]] && cmp -s "$target" "$src"; then
      reason="not a link, but content matches the repo — a plain rerun fixes it"
    elif [[ -e "$target" ]]; then
      reason="not a link and content differs — a tool rewrote it; needs --adopt"
    else
      reason="missing"
    fi
    printf '%s %s  %s\n' "$(red drift)" "$label" "$reason"
    continue
  fi

  mkdir -p "$(dirname "$target")" "$(dirname "$src")"

  # A wrong link is safe to replace: the content lives in whatever it points at, not here.
  if [[ -L "$target" ]]; then
    old="$(readlink "$target")"
    ln -sfn "$src" "$target"
    printf '%s %s  re-pointed (was %s)\n' "$(amber relink)" "$label" "$old"
    continue
  fi

  if [[ -e "$target" ]]; then
    if [[ ! -e "$src" ]]; then
      # Nothing in the repo yet: moving the live copy in cannot lose anything.
      mv "$target" "$src"
      ln -s "$src" "$target"
      printf '%s %s  moved into the repo\n' "$(amber adopt)" "$label"
      continue
    fi
    if [[ -f "$target" && -f "$src" ]] && cmp -s "$target" "$src"; then
      rm "$target"
      ln -s "$src" "$target"
      printf '%s %s  identical, re-linked\n' "$(green ok)" "$label"
      continue
    fi
    if [[ "$mode" == adopt ]]; then
      rm -rf "$src"
      mv "$target" "$src"
      ln -s "$src" "$target"
      printf '%s %s  live content adopted over the repo copy\n' "$(amber adopt)" "$label"
      continue
    fi
    printf '%s %s  differs from %s — rerun with --adopt to take the live content\n' \
      "$(red conflict)" "$label" "$rel"
    continue
  fi

  if [[ ! -e "$src" ]]; then
    printf '%s %s  neither the repo copy nor the target exists; skipping\n' "$(red missing)" "$label"
    continue
  fi

  ln -s "$src" "$target"
  printf '%s %s  linked\n' "$(green new)" "$label"
done

[[ "$mode" == check ]] && exit "$drift"
exit 0
