#!/usr/bin/env bash
# Raise a macOS notification for an agent that wants attention, tagged with its MR number.
#
#   usage: notify.sh <state-label>        e.g. "finished", "needs input"
#
# Replaces herdr's built-in agent-state toast ([ui.toast] delivery = "off"), which cannot
# include an MR number — its text is baked into the binary, and herdr's own notification API
# is gated by that same delivery setting. herdr's [ui.sound] is independent and still plays,
# so this supplies the visual half only and stays silent to avoid a double chime.
#
# Called from the Claude Code Stop and Notification hooks.
set -uo pipefail

[[ "${HERDR_ENV:-}" == 1 && -n "${HERDR_PANE_ID:-}" ]] || exit 0
state="${1:-needs attention}"

panes=$(herdr pane list 2>/dev/null) || exit 0

# Don't notify about something already on screen. Panes sharing the focused tab are visible
# even when not focused themselves (splits), so the tab is the right granularity.
focused_tab=$(printf '%s' "$panes" | jq -r '.result.panes[] | select(.focused) | .tab_id')
[[ -n "$focused_tab" && "$focused_tab" == "${HERDR_TAB_ID:-}" ]] && exit 0

read -r mr topic <<<"$(printf '%s' "$panes" | jq -r --arg p "$HERDR_PANE_ID" '
  .result.panes[] | select(.pane_id == $p)
  | "\(.tokens.mr // "-") \(.terminal_title_stripped // "agent")"')"
[[ "$mr" == "-" ]] && mr=""

space=$(herdr workspace get "${HERDR_WORKSPACE_ID:-}" 2>/dev/null \
  | jq -r '.result.workspace.label // empty')

title="${mr:+$mr · }${topic}"
body="${state}${space:+ · $space}"

# argv form: the strings never reach an AppleScript parser as literals.
osascript -e 'on run argv
  display notification (item 1 of argv) with title (item 2 of argv)
end run' "$body" "$title" >/dev/null 2>&1
