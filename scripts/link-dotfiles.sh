#!/usr/bin/env bash
# Link tracked config files from this repo into their live locations. This is the ONLY place
# links are made, on macOS and Linux; the scripts/setup/ scripts install tools and
# then call this. (Windows can't run it: scripts/setup/windows_config.ps1 keeps its own links.)
#
#   link-dotfiles.sh            create/repair links; refuse on a content conflict
#   link-dotfiles.sh --adopt    on a conflict, take the LIVE file's content into the repo
#   link-dotfiles.sh --replace  on a conflict, move the live file aside (*.pre-dotfiles.<time>)
#                               and link over it; for a fresh machine, where installers have
#                               already written default config
#   link-dotfiles.sh --check    report only; exit non-zero if anything is not linked
#
# Links are absolute. Under ~/.claude, ~/.config/herdr and ~/.agents they are made per-FILE,
# never per-directory: those directories hold transcripts, logs and sockets alongside the
# config, so a directory link would expose all of it. A whole directory is linked only where
# it is pure config (nvim, single skills).
#
# (This replaced a symlink farm manager. Don't reintroduce one: it would want to own whole
# package directories, and it can't produce the absolute links already in place here.)
#
# The --adopt path exists because tools rewrite their own config: Claude Code replaced
# ~/.claude/settings.json (a symlink) with a regular file during a doctor run, which silently
# froze the repo copy. `--check` catches that; `--adopt` recovers it.
#
# ~/.claude/settings.json is the one exception: it is GENERATED, not linked (see GENERATED
# below), because it mixes personal settings with work-only ones that must not reach this public
# repo, and Claude Code has no include. The work half lives in ~/.claude/settings.work.json,
# which is never tracked.

set -uo pipefail

REPO="$(cd "$(dirname "$0")/.." && pwd)"

# repo-relative path : absolute live target
MAP=(
  "zsh/.zshrc:$HOME/.zshrc"
  "starship/.config/starship.toml:$HOME/.config/starship.toml"
  "atuin/.config/atuin/config.toml:$HOME/.config/atuin/config.toml"
  "mise/.config/mise/config.toml:$HOME/.config/mise/config.toml"
  "television/.config/television/config.toml:$HOME/.config/television/config.toml"
  "lsd/.config/lsd/config.yaml:$HOME/.config/lsd/config.yaml"
  "glow/.config/glow/glow.yml:$HOME/.config/glow/glow.yml"
  "gh-dash/.config/gh-dash/config.yml:$HOME/.config/gh-dash/config.yml"
  "ssh/.ssh/config:$HOME/.ssh/config"
  "tmux/.tmux.conf:$HOME/.tmux.conf"
  "editorconfig/.editorconfig:$HOME/.editorconfig"
  "git/.gitconfig:$HOME/.gitconfig"
  "nvim/.config/nvim:$HOME/.config/nvim"
  "ghostty/.config/ghostty/config:$HOME/.config/ghostty/config"
  "claude/.claude/CLAUDE.md:$HOME/.claude/CLAUDE.md"
  "claude/.claude/statusline-command.sh:$HOME/.claude/statusline-command.sh"
  "claude/.claude/hooks/herdr-agent-state.sh:$HOME/.claude/hooks/herdr-agent-state.sh"
  "claude/.claude/hooks/worktree-on-plan-exit.sh:$HOME/.claude/hooks/worktree-on-plan-exit.sh"
  "claude/.claude/output-styles/eli5.md:$HOME/.claude/output-styles/eli5.md"
  "claude/.claude/skills/bro/SKILL.md:$HOME/.claude/skills/bro/SKILL.md"
  "herdr/.config/herdr/config.toml:$HOME/.config/herdr/config.toml"
  "herdr/.config/herdr/scripts/mr-token.sh:$HOME/.config/herdr/scripts/mr-token.sh"
  "herdr/.config/herdr/scripts/new-worktree.sh:$HOME/.config/herdr/scripts/new-worktree.sh"
  "herdr/.config/herdr/scripts/notify.sh:$HOME/.config/herdr/scripts/notify.sh"
  "agents/.agents/herdr-spawn.zsh:$HOME/.agents/herdr-spawn.zsh"
  "agents/.agents/skills/find-skills:$HOME/.agents/skills/find-skills"
  "agents/.agents/skills/herdr:$HOME/.agents/skills/herdr"
)

# Flatpak apps keep their config under ~/.var/app/<app id>/config; link only where installed.
flatpak_link() {
  [[ -d "$HOME/.var/app/$2" ]] && MAP+=("$1:$HOME/.var/app/$2/config/$3")
}

case "$(uname -s)" in
  Darwin)
    MAP+=(
      "vscode/settings.json:$HOME/Library/Application Support/Code/User/settings.json"
      "vscode/settings.json:$HOME/Library/Application Support/Code - Insiders/User/settings.json"
    )
    ;;
  Linux)
    MAP+=(
      "vscode/settings.json:$HOME/.config/Code/User/settings.json"
      "vscode/settings.json:$HOME/.config/Code - Insiders/User/settings.json"
    )
    flatpak_link ghostty/.config/ghostty/config com.mitchellh.ghostty ghostty/config
    flatpak_link vscode/settings.json com.visualstudio.code Code/User/settings.json
    flatpak_link vscode/settings.json com.visualstudio.code-insiders "Code - Insiders/User/settings.json"
    ;;
esac

# repo-relative base : optional local overlay : absolute live target
# The live file is the base deep-merged with the overlay (jq `*`: objects merge key by key,
# anything else — arrays included — is taken whole from the overlay). It is a plain file, so an
# edit Claude Code makes to it does not reach the repo: --check reports it, and a rerun refuses to
# overwrite it until you have moved the change into the base or the overlay and deleted the file.
GENERATED=(
  "claude/.claude/settings.json:$HOME/.claude/settings.work.json:$HOME/.claude/settings.json"
)

# Intentionally NOT linked, so they never reach this public repo:
#   ~/.zshrc_work.zsh              work-machine only; holds API keys
#   ~/.claude/settings.work.json   work-only Claude settings, merged in via GENERATED above
#
# ~/.claude/CLAUDE.md used to be on that list for the same reason. The sections that named
# employer-internal repos moved into a shared team plugin, so what is left is generic and is
# now tracked — but it is a public repo, so keep it that way: a rule that only makes sense
# with an internal repo, org or hostname in it belongs in the plugin, not here.

mode=link
case "${1:-}" in
  --check) mode=check ;;
  --adopt) mode=adopt ;;
  --replace) mode=replace ;;
  "")      ;;
  *)       echo "usage: $(basename "$0") [--check|--adopt|--replace]" >&2; exit 2 ;;
esac

red()   { printf '\033[31m%s\033[0m' "$*"; }
green() { printf '\033[32m%s\033[0m' "$*"; }
amber() { printf '\033[33m%s\033[0m' "$*"; }

# --replace: move a conflicting live file out of the way, keeping it, and echo where it went.
set_aside() {
  local backup="$1.pre-dotfiles.$(date +%Y%m%d-%H%M%S)"
  mv "$1" "$backup"
  echo "${backup/$HOME/~}"
}

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
    if [[ "$mode" == replace ]]; then
      backup="$(set_aside "$target")"
      ln -s "$src" "$target"
      printf '%s %s  linked; the old copy is at %s\n' "$(amber replace)" "$label" "$backup"
      continue
    fi
    printf '%s %s  differs from %s — rerun with --adopt to take the live content, or --replace to set it aside\n' \
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

for entry in "${GENERATED[@]}"; do
  IFS=: read -r rel overlay target <<< "$entry"
  src="$REPO/$rel"
  label="${target/$HOME/~}"

  parts=("$src")
  [[ -f "$overlay" ]] && parts+=("$overlay")
  if ! want="$(jq -s 'reduce .[] as $p ({}; . * $p)' "${parts[@]}")"; then
    drift=1
    printf '%s %s  could not merge %s\n' "$(red error)" "$label" "${parts[*]/$HOME/~}"
    continue
  fi

  if [[ -f "$target" && ! -L "$target" ]] && [[ "$(cat "$target")" == "$want" ]]; then
    printf '%s  %s\n' "$(green ok)" "$label"
    continue
  fi

  drift=1
  if [[ "$mode" == check ]]; then
    if [[ -L "$target" ]]; then
      reason="a link, should be generated — a plain rerun fixes it"
    elif [[ -e "$target" ]]; then
      reason="differs from the merge — a tool or you edited it; move the change into $rel or ${overlay/$HOME/~}"
    else
      reason="missing"
    fi
    printf '%s %s  %s\n' "$(red drift)" "$label" "$reason"
    continue
  fi

  # A link holds no content of its own, so replacing it loses nothing. A plain file that
  # differs may hold an edit that exists nowhere else, so never overwrite it (--replace keeps
  # a copy first).
  backup=""
  if [[ -e "$target" && ! -L "$target" ]]; then
    if [[ "$mode" != replace ]]; then
      printf '%s %s  differs from the merge — move the change into %s or %s, delete it, rerun\n' \
        "$(red conflict)" "$label" "$rel" "${overlay/$HOME/~}"
      continue
    fi
    backup="$(set_aside "$target")"
  fi

  mkdir -p "$(dirname "$target")"
  rm -f "$target"
  printf '%s\n' "$want" > "$target"
  printf '%s %s  generated from %s%s\n' "$(green new)" "$label" "${parts[*]/$HOME/~}" \
    "${backup:+; the old copy is at $backup}"
done

# iTerm2 isn't linked: it is told to read its prefs from iterm2/ in this repo.
if [[ "$(uname -s)" == Darwin ]]; then
  label="iTerm2 prefs folder"
  folder="$(defaults read com.googlecode.iterm2 PrefsCustomFolder 2>/dev/null)"
  load="$(defaults read com.googlecode.iterm2 LoadPrefsFromCustomFolder 2>/dev/null)"
  if [[ ( "$folder" == "$REPO/iterm2" || "$folder" == "${REPO/#$HOME/~}/iterm2" ) && "$load" == 1 ]]; then
    printf '%s  %s\n' "$(green ok)" "$label"
  else
    drift=1
    if [[ "$mode" == check ]]; then
      printf '%s %s  not reading from %s/iterm2\n' "$(red drift)" "$label" "${REPO/#$HOME/~}"
    else
      defaults write com.googlecode.iterm2 PrefsCustomFolder -string "$REPO/iterm2"
      defaults write com.googlecode.iterm2 LoadPrefsFromCustomFolder -bool true
      printf '%s %s  set to %s/iterm2\n' "$(green new)" "$label" "${REPO/#$HOME/~}"
    fi
  fi
fi

[[ "$mode" == check ]] && exit "$drift"
exit 0
