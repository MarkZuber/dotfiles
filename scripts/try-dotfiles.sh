#!/usr/bin/env bash
# Open a herdr tab that runs THIS checkout's shell and editor config, without linking anything.
# For trying a branch or worktree before it becomes the live setup: the live ~/.zshrc,
# ~/.config/nvim etc. are never touched, and closing the tab ends the trial.
#
#   scripts/try-dotfiles.sh          # run from inside herdr, from any checkout (e.g. a worktree)
#
# What the tab uses from this checkout, and how:
#   zsh        ZDOTDIR points at a scratch dir whose .zshrc sources zsh/.zshrc
#   nvim       NVIM_APPNAME=nvim-try → ~/.config/nvim-try links to nvim/.config/nvim; plugins and
#              Mason tools go to ~/.local/share/nvim-try, separate from the real nvim
#   starship, atuin, mise, television, git   pointed at their files here by env var
# Not on trial: Ghostty (the tab lives in the running Ghostty; check its config with
# `ghostty +validate-config --config-file=ghostty/.config/ghostty/config`). Not isolated:
# atuin's history database, zoxide's directory list and the zsh-init cache are the real ones
# (they hold data, not config), and ssh/glow/gh-dash keep using the live config.
#
# (A separate Ghostty window via `open -na Ghostty --env …` was tried first: the environment
# never reached the shell, so the window ran the live config.)

set -euo pipefail

if [[ "${HERDR_ENV:-}" != 1 ]]; then
  echo "Run this from a herdr pane: it opens the trial as a herdr tab." >&2
  exit 1
fi

REPO="$(cd "$(dirname "$0")/.." && pwd)"
STATE="${TMPDIR:-/tmp}/try-dotfiles"

mkdir -p "$STATE/zdot" "$STATE/television"

printf '[[ -f "$HOME/.zshenv" ]] && source "$HOME/.zshenv"\n' > "$STATE/zdot/.zshenv"
printf 'source "%s/zsh/.zshrc"\n' "$REPO" > "$STATE/zdot/.zshrc"

# television keeps channels next to its config; fetch them into the scratch dir, not the repo.
ln -sfn "$REPO/television/.config/television/config.toml" "$STATE/television/config.toml"
if [[ ! -d "$STATE/television/cable" ]] && command -v tv >/dev/null; then
  TELEVISION_CONFIG="$STATE/television" tv update-channels >/dev/null 2>&1 || true
fi

ln -sfn "$REPO/nvim/.config/nvim" "$HOME/.config/nvim-try"

herdr tab create \
  --env "ZDOTDIR=$STATE/zdot" \
  --env "DOTFILES_TRY=$REPO" \
  --env "NVIM_APPNAME=nvim-try" \
  --env "STARSHIP_CONFIG=$REPO/starship/.config/starship.toml" \
  --env "ATUIN_CONFIG_DIR=$REPO/atuin/.config/atuin" \
  --env "MISE_GLOBAL_CONFIG_FILE=$REPO/mise/.config/mise/config.toml" \
  --env "TELEVISION_CONFIG=$STATE/television" \
  --env "GIT_CONFIG_GLOBAL=$REPO/git/.gitconfig" \
  --cwd "$REPO" --label "dotfiles trial" --focus >/dev/null

echo "Opened a herdr tab trying ${REPO/#$HOME/~}."
echo "In it: nvim uses NVIM_APPNAME=nvim-try (first launch installs plugins; let Mason finish)."
echo "Clean up afterwards: rm -rf ~/.config/nvim-try ~/.local/share/nvim-try ~/.local/state/nvim-try ~/.cache/nvim-try $STATE"
