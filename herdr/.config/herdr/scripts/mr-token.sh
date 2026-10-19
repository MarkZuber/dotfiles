#!/usr/bin/env bash
# Push this agent's open GitLab MR number into its herdr sidebar row as $mr.
#
# Reported against the PANE, not the workspace: a workspace often holds several agents on
# different branches, and a workspace-level token would be last-writer-wins. Rendered by
# [ui.sidebar.agents.rows_by_agent] in config.toml. Reporting is push-based, so herdr never
# blocks on the network to draw a row.
#
# Called from the Claude Code SessionStart and Stop hooks; pass --force to bypass the rate
# limit (e.g. from a keybinding, or right after opening an MR).
set -uo pipefail

[[ "${HERDR_ENV:-}" == 1 && -n "${HERDR_PANE_ID:-}" ]] || exit 0
command -v glab >/dev/null 2>&1 || exit 0

report() {
  herdr pane report-metadata "$HERDR_PANE_ID" --source mr-token "$@" >/dev/null 2>&1
}

# Hooks pipe their payload as JSON, whose .cwd is the session's working directory. That is
# the authoritative one: after EnterWorktree the session moves but the pane's shell does
# not, so $PWD would still name the main checkout and resolve the wrong branch.
if [[ ! -t 0 ]]; then
  cwd=$(cat | jq -r '.cwd // empty' 2>/dev/null)
  [[ -n "$cwd" && -d "$cwd" ]] && cd "$cwd"
fi

branch=$(git symbolic-ref --quiet --short HEAD 2>/dev/null)
[[ -n "$branch" ]] || { report --clear-token mr; exit 0; }   # detached HEAD, or not a repo

# The Stop hook fires every turn, so look up at most once per 90s. Keying the stamp on the
# branch means switching branches refreshes immediately instead of showing a stale number.
stamp="${TMPDIR:-/tmp}/herdr-mr-${HERDR_PANE_ID//:/_}-${branch//\//_}"
if [[ "${1:-}" != --force && -f "$stamp" ]] \
   && (( $(date +%s) - $(stat -f %m "$stamp") < 90 )); then
  exit 0
fi
: > "$stamp"

iid=$(glab mr list --source-branch "$branch" -F json 2>/dev/null | jq -r '.[0].iid // empty')
if [[ -n "$iid" ]]; then
  report --token "mr=!$iid"
else
  report --clear-token mr
fi
