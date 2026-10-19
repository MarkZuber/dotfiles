#!/usr/bin/env bash
# Create a git worktree and open it as a herdr workspace, under the one agreed location:
#
#     <main-checkout>/.claude/worktrees/<branch>
#
# Same place `wt new` and Claude Code's EnterWorktree use. Bound to prefix+shift+g as a
# popup command; herdr's built-in new_worktree action is unbound because it creates under a
# single global [worktrees] directory that cannot be made repo-relative.
set -uo pipefail

fail() { echo "$1" >&2; sleep 2; exit 1; }

# A popup may not be a listed pane, so fall back to the directory it inherited ($PWD).
cwd=$(herdr pane current 2>/dev/null | jq -r '.result.pane.foreground_cwd // .result.pane.cwd // empty')
[[ -n "$cwd" && -d "$cwd" ]] || cwd="$PWD"
[[ -d "$cwd" ]] || fail "could not resolve a working directory"
cd "$cwd" || fail "could not enter $cwd"

# --git-common-dir resolves to the MAIN checkout even from inside a linked worktree, so
# running this from a worktree can't nest a worktree inside a worktree.
common=$(git rev-parse --path-format=absolute --git-common-dir 2>/dev/null) \
  || fail "$cwd is not inside a git repository"
main=$(dirname "$common")

base=$(git symbolic-ref --quiet --short refs/remotes/origin/HEAD 2>/dev/null || echo origin/main)

printf 'new worktree branch (from %s): ' "$base"
read -r branch
[[ -n "$branch" ]] || exit 0

herdr worktree create \
  --branch "$branch" \
  --base "$base" \
  --path "$main/.claude/worktrees/$branch" \
  --focus \
  || fail "worktree create failed"
