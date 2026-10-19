#!/usr/bin/env bash
# PostToolUse[ExitPlanMode] — nudge toward worktree isolation.
#
# Several agents often run against the same checkout at once, and two of them editing one
# working tree clobber each other. When a plan is approved while the session is still in
# the main checkout on the default branch, tell Claude to call EnterWorktree before it
# starts editing. Silent in every other case, so re-planning inside a worktree — or
# working deliberately on a feature branch — is never interrupted.

set -uo pipefail

emit() {
  jq -n --arg ctx "$1" \
    '{hookSpecificOutput: {hookEventName: "PostToolUse", additionalContext: $ctx}}'
  exit 0
}

input="$(cat)"
cwd="$(printf '%s' "$input" | jq -r '.cwd // empty' 2>/dev/null)"
[[ -n "$cwd" && -d "$cwd" ]] || exit 0

git -C "$cwd" rev-parse --is-inside-work-tree >/dev/null 2>&1 || exit 0

# A linked worktree's git dir is <common>/worktrees/<name>; in the main checkout the two
# paths are identical. Already in a worktree -> the session is isolated, say nothing.
gitdir="$(git -C "$cwd" rev-parse --absolute-git-dir 2>/dev/null)"
common="$(git -C "$cwd" rev-parse --path-format=absolute --git-common-dir 2>/dev/null)"
[[ -n "$gitdir" && "$gitdir" == "$common" ]] || exit 0

# Main checkout, but already on a feature branch -> the work is isolated by branch.
branch="$(git -C "$cwd" rev-parse --abbrev-ref HEAD 2>/dev/null)"
default="$(git -C "$cwd" symbolic-ref --short refs/remotes/origin/HEAD 2>/dev/null)"
default="${default#origin/}"
[[ -n "$default" ]] || default="main"
[[ "$branch" == "$default" ]] || exit 0

root="$(git -C "$cwd" rev-parse --show-toplevel)"
others="$(git -C "$cwd" worktree list | tail -n +2)"
dirty="$(git -C "$cwd" status --porcelain | wc -l | tr -d ' ')"

msg="Worktree isolation: this session is in the main checkout of ${root}, on \`${branch}\` — not a worktree.

If the approved plan edits files, call EnterWorktree before the first edit, with a short name derived from the task. Skip only if the plan changes no files, or the user asked to work in this checkout."

if [[ -n "$others" ]]; then
  msg+="

This repo already has worktrees. If the plan continues work that belongs in one of them, enter it with EnterWorktree's \`path\` rather than creating a second one:
${others}"
fi

if [[ "$dirty" -gt 0 ]]; then
  msg+="

Heads up: the main checkout has ${dirty} uncommitted change(s). A new worktree branches from \`origin/${default}\` and will NOT carry them over. If those changes matter to this task, say so and confirm with the user before entering a worktree."
fi

emit "$msg"
