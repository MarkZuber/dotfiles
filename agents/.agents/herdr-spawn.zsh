# herdr-spawn.zsh — spawn agents and commands into sibling herdr panes.
# Source from ~/.zshrc:  source ~/.agents/herdr-spawn.zsh

# _hsplit <direction> — split the current pane, print the new pane id.
_hsplit() {
  herdr pane split --current --direction "${1:-right}" --no-focus \
    | jq -r .result.pane.pane_id
}

# hrun <command...> — run a shell command in a new pane to the right.
#   hrun cargo test -p mycrate
hrun() {
  local p; p=$(_hsplit right)
  herdr pane run "$p" "$*"
  print -r -- "$p"
}

# hrund <command...> — same, split downward.
hrund() {
  local p; p=$(_hsplit down)
  herdr pane run "$p" "$*"
  print -r -- "$p"
}

# hpi <task...> — spawn a pi agent in a new pane with an initial task.
#   hpi "fix all clippy warnings in the parser crate"
hpi() {
  local p; p=$(_hsplit right)
  herdr pane run "$p" "pi ${(q)*}"
  print -r -- "$p"
}

# hclaude <task...> — same, but Claude CLI.
hclaude() {
  local p; p=$(_hsplit right)
  herdr pane run "$p" "claude ${(q)*}"
  print -r -- "$p"
}

# hwatch <pane> [lines] — read a pane's recent output.
hwatch() { herdr pane read "$1" --source recent --lines "${2:-40}"; }

# hjoin <pane> [timeout_ms] — block until that agent settles, then show its output.
# Settled means done, idle, or blocked on a question. Waiting only for `done` hangs
# forever when the agent stops to ask you something, or when you focus its tab (a seen
# tab reports `idle`, never `done`).
hjoin() {
  herdr agent wait "$1" --timeout "${2:-300000}" >/dev/null \
    && herdr agent read "$1" --source recent-unwrapped --lines 80
}

# hme — print YOUR OWN pane id.
# Not `select(.focused)`: that is the UI-focused pane, which belongs to whichever client
# the user is looking at — often a different session entirely. Herdr injects the caller's
# own id into every managed pane, so read that.
hme() {
  print -r -- "${HERDR_PANE_ID:-$(herdr pane current --current | jq -r .result.pane.pane_id)}"
}

# hls — compact table of panes: id, agent, status, title. `*` marks YOUR pane.
hls() {
  herdr pane list | jq -r --arg me "$HERDR_PANE_ID" '
    .result.panes[]
    | [(if .pane_id == $me then "*" else " " end), .pane_id, (.agent // "shell"),
       (.agent_status // "-"), (.terminal_title_stripped // "")]
    | @tsv' | column -t -s$'\t'
}
