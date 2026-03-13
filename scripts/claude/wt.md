# wt — git worktree manager for parallel Claude agents

Manages git worktrees so multiple Claude Code agents can work on the same
repository in parallel, each on its own branch, without interfering with each
other or with your working tree.

## Installation

`wt` is in `~/dotfiles/scripts/claude/`, which is on PATH. No setup needed.

## Worktree layout

Worktrees are placed under `~/wt/<repo>/`:

```
~/wt/
  myrepo/
    feature-auth/  ← worktree for branch "feature-auth"
    fix-crash/     ← worktree for branch "fix-crash"
~/code/
  myrepo/          ← main repo (unchanged)
```

Override the root with `WT_ROOT=/some/path` (worktrees go to `$WT_ROOT/<repo>/<name>`),
or override the full parent for a specific repo with `WT_BASE=/some/path`.

## Commands

### `wt new <name> [base-branch]`

Create a new worktree and branch. Fetches `origin/<base>` first so the branch
starts from the latest upstream commit.

```bash
wt new feature-auth            # branch from main (or master)
wt new fix-crash develop       # branch from develop
wt new ui-work --claude        # create + open Claude in a new Ghostty window
wt new ui-work --tab           # create + open Claude in a new Ghostty tab
wt new ui-work --split         # create + open Claude in a Ghostty split (right)
wt new ui-work --split-down    # create + open Claude in a Ghostty split (down)
wt new ui-work -p "Refactor the login form to use shadcn components"
```

Flags:
- `--claude / -c` — launch Claude after creation (uses `WT_GHOSTTY_MODE` or `window`)
- `--prompt / -p <text>` — send an initial prompt to Claude on launch
- `--prompt-file / -f <file>` — read the initial prompt from a markdown file
- `--tab` — open in a new Ghostty tab (implies `--claude`)
- `--split` — open in a Ghostty split-right pane (implies `--claude`)
- `--split-down` — open in a Ghostty split-down pane (implies `--claude`)
- `--window` — open in a new Ghostty window (implies `--claude`, explicit default)

---

### `wt switch <name>` (alias: `wt sw`)

`cd` into a worktree in your current shell session. Implemented as a zsh
function in `.zshrc` (a script can't change your shell's directory directly).

```bash
wt switch feature-auth
wt sw fix-crash
```

---

### `wt list`

List all worktrees with their branch, base branch, dirty indicator (`*`), and path.

```bash
wt list
```

---

### `wt status`

Run `git status --short` inside every worktree at once.

```bash
wt status
```

---

### `wt agent <name> [prompt...]`

Launch Claude Code in the named worktree. Terminal target, in priority order:

1. **tmux** — new window named `wt:<name>` (mode flags ignored; tmux has its own model)
2. **Ghostty** — controlled via AppleScript; respects `--tab`, `--split`, `--split-down`, `--window`
3. **Terminal.app** — new window via AppleScript (fallback when not in Ghostty)
4. **Print** — prints the command to run manually

```bash
wt agent feature-auth                            # new window (default)
wt agent --tab feature-auth                      # new tab in current Ghostty window
wt agent --split feature-auth                    # split right in current Ghostty tab
wt agent --split-down feature-auth               # split down in current Ghostty tab
wt agent --tab feature-auth "Implement OAuth2 login"
wt agent --tab -f prompts/auth.md feature-auth   # load prompt from file
```

If a prompt is given, Claude receives it via `--print` and then drops into
interactive mode.

Set `WT_GHOSTTY_MODE=tab` (or `split`, `split-down`, `window`) in your shell
profile to make a mode the persistent default without typing a flag every time.

---

### `wt open <name>`

Alias for `wt agent`.

---

### `wt pr <name> [--draft] [--title <title>]`

Push the branch to `origin` and open a pull request.

- If [`gh`](https://cli.github.com) is installed: creates the PR directly.
- Otherwise: pushes and opens the GitHub compare URL in your browser.

```bash
wt pr feature-auth
wt pr feature-auth --draft
wt pr feature-auth --title "feat: OAuth2 login"
```

---

### `wt sync <name>`

Fetch `origin/<base>` and rebase the worktree's branch onto it.

```bash
wt sync feature-auth
```

---

### `wt rm <name>`

Remove the worktree directory and delete the local branch.

```bash
wt rm feature-auth             # remove worktree + delete branch
wt rm feature-auth --keep-branch   # remove worktree, keep branch
```

---

### `wt path <name>`

Print the filesystem path of a worktree. Useful with `cd`:

```bash
cd $(wt path feature-auth)
```

---

## Typical workflow

```bash
# 1. Start a new task
wt new feature-auth --claude

# 2. Or: create first, then launch agent with a task
wt new fix-crash develop
wt agent fix-crash "The app crashes on startup when config.json is missing. Find and fix the root cause."

# 3. Run more agents in parallel
wt new ui-redesign
wt agent ui-redesign "Redesign the dashboard layout using the design spec in docs/design.md"

# 4. Check what's happening across all worktrees
wt list
wt status

# 5. Keep a worktree current with main
wt sync feature-auth

# 6. Ship it
wt pr feature-auth --title "feat: OAuth2 login"

# 7. Clean up
wt rm feature-auth
```

## Environment variables

| Variable           | Default    | Description                                              |
|--------------------|------------|----------------------------------------------------------|
| `WT_ROOT`          | `~/wt`     | Root for all worktrees; repos get a subdir (`$WT_ROOT/<repo>/<name>`) |
| `WT_BASE`          | —          | Override the full parent dir for this repo (overrides `WT_ROOT`) |
| `WT_GHOSTTY_MODE`  | `window`   | Default Ghostty open mode: `window` `tab` `split` `split-down` |

```bash
export WT_ROOT=~/worktrees       # use ~/worktrees/<repo>/<name> instead
export WT_GHOSTTY_MODE=tab       # always open in a new tab
```

Per-call flags (`--tab`, `--split`, etc.) always override `WT_GHOSTTY_MODE`.
