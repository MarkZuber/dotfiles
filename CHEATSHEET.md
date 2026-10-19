# Cheatsheet

Keys and commands for the tools this repo sets up. In key columns, `Ctrl+x` / `Alt+x` are
chords; in Neovim, `<leader>` is Space and `<C-x>` / `<M-x>` are Ctrl / Alt. Option is Alt in
Ghostty (`macos-option-as-alt`), so every Alt binding below works on a Mac keyboard.

- [Ghostty](#ghostty)
- [herdr](#herdr)
- [zsh: editing, history, completion](#zsh-editing-history-completion)
- [Getting around](#getting-around)
- [Everyday commands](#everyday-commands)
- [Environments and toolchains](#environments-and-toolchains)
- [Keeping the dotfiles in sync](#keeping-the-dotfiles-in-sync)
- [Neovim](#neovim)

## Ghostty

| Key | Action |
| --- | --- |
| `Ctrl+Shift+←/→/↑/↓` | move between splits |
| `Shift+Cmd+`` ` `` | quick terminal (drops down from the top, from any app) |
| `Cmd+Shift+PageUp/PageDown` | scroll a page |
| `Shift+→` | extend a selection right |
| select text | copied to the clipboard (`copy-on-select`) |

Pane tints: `tint-navy`, `tint-teal`, `tint-forest`, `tint-plum`, `tint-maroon`, `tint-mocha`,
`tint-slate`, `tint-olive`, `tint-carbon`, `tint-off` set this pane's background. `ssh` turns the
pane maroon while connected.

## herdr

Prefix is `Ctrl+F` or `Ctrl+Space`.

| Key | Action |
| --- | --- |
| `prefix f` | file viewer in a split |
| `prefix Shift+f` | file viewer in its own tab |
| `prefix Shift+g` | new worktree (popup) under `<main-checkout>/.claude/worktrees/` |
| `prefix Ctrl+g` | lazygit in an 80% popup |

Shell helpers from `agents/.agents/herdr-spawn.zsh` (work inside herdr only):

| Command | Does |
| --- | --- |
| `hrun <cmd…>` / `hrund <cmd…>` | run a command in a new pane to the right / below |
| `hclaude <task…>` / `hpi <task…>` | start a Claude / pi agent in a new pane with a task |
| `hwatch <pane> [lines]` | print a pane's recent output |
| `hjoin <pane> [timeout_ms]` | wait until that agent is done, idle or asking, then show its output |
| `hls` | table of panes (`*` is yours) |
| `hme` | your own pane id |

## zsh: editing, history, completion

| Key | Action |
| --- | --- |
| `Ctrl+R` | atuin: fuzzy search all history. `Enter` runs it, `Tab` puts it on the line to edit, `Ctrl+R` again cycles the filter (all → host → session → directory), `Esc` closes |
| `↑` / `↓` | previous / next command starting with what's already typed (`git` then `↑` steps through `git …` commands) |
| `Ctrl+T` | television, picked by what you've typed: `cd`/`z ` → dirs, `git checkout ` → branches, `git log ` → commits, `git add ` → changed files, `nvim ` → files, `export ` → env vars |
| `→` or `Ctrl+E` | accept the grey autosuggestion |
| `Alt+Enter` | accept the autosuggestion and run it |
| `Tab` | completion menu through fzf-tab; type to filter, `Enter` to pick |
| `cmd :C` / `cmd :B` | page `cmd --help` / `cmd -h` through bat with syntax colours (`git :C`) |

Inside television: `Ctrl+J/K` move, `Ctrl+R` switch channel, `Ctrl+X` actions on the
selection, `Ctrl+S` cycle sources (e.g. hidden files), `Ctrl+O` toggle preview, `Ctrl+Y` copy,
`Ctrl+G` help.

## Getting around

| Command | Does |
| --- | --- |
| `z <words>` | jump to the most used dir matching the words, in order (`z dot`, `z sanas app`) |
| `zi [words]` | same, picking from a list |
| `..` `...` `....` | up 1/2/3 levels |
| `repos` | `cd ~/repos` |
| `tv` | file picker; `tv <channel>` for others, `tv list-channels` to see them all |
| `tv git-branch`, `tv git-log`, `tv git-stash`, `tv git-worktrees`, `tv git-reflog` | git pickers, each with actions (`Ctrl+X`) |
| `tv docker-containers`, `tv docker-images`, `tv procs`, `tv make-targets`, `tv text`, `tv todo-comments` | other channels |

Worktrees (`wt`, full docs in [scripts/claude/wt.md](scripts/claude/wt.md)):

| Command | Does |
| --- | --- |
| `wt new <name> [base]` | new branch + worktree from the latest `origin/<base>`; `--tab`/`--split`/`--claude` also opens Claude |
| `wt switch <name>` / `wt sw` | `cd` into it (bare `wt sw` returns to the main checkout) |
| `wt list` / `wt status` | all worktrees (branch, base, `*` if dirty) / `git status --short` in each |
| `wt agent <name> [prompt]` | open Claude in that worktree |
| `wt pr <name> [--draft]` | push and open a PR |
| `wt sync <name>` | fetch and rebase it onto `origin/<base>` |
| `wt rm <name> [--keep-branch]` | remove the worktree (and its branch unless told not to) |

## Everyday commands

| Command | Does |
| --- | --- |
| `ls`, `ll`, `la`, `l`, `l1`, `l.` | lsd: plain, long + dirs first, all, long, one per line, dotfiles |
| `ltree` | lsd tree view |
| `lf` | files changed in the last day |
| `cat` / `catp` | bat with / without line numbers and decorations |
| `grep`, `rg` | ripgrep, skipping `.git`, build output and lockfiles |
| `mdv <file>` / `glow` | render markdown in the terminal / browse markdown files here |
| `http GET example.com/api` | xh, a fast HTTPie (`http POST url key=value`) |
| `sshs` | pick an ssh host from `~/.ssh/config` |
| `ghd` | gh-dash: your PRs, review requests and issues on GitHub (`?` lists its keys) |
| `myip`, `lsport`, `listening` | public IP, open ports (sudo), listening sockets |
| `psmem10`, `pscpu10`, `psx <name>`, `pst` | top memory / CPU, find a process, process tree |
| `meminfo`, `loadavg`, `partitions`, `du_overview` | memory, load, disks, biggest dirs |
| `srcz` | reload the shell (`exec zsh`) after changing `.zshrc` |
| `path` | PATH, one entry per line |
| `topten` | your ten most-used commands |
| `rmc` | ask Claude to resolve merge conflicts |

Git aliases (in `git/.gitconfig` unless marked *zsh*):

| Alias | Does |
| --- | --- |
| `git lg` / `git lga` | coloured graph log / of all branches |
| `git s`, `git a`, `git com "msg"`, `git amend` | status, add everything, commit, amend |
| `git cb <name>`, `git c <branch>` | new branch, checkout |
| `git pr`, `git rc`, `git ra` | pull --rebase, rebase continue / abort |
| `git undo`, `git unstage` | drop the last commit (keep changes), unstage |
| `git default-branch`, `git up`, `git pub`, `git sync` | origin's default branch; rebase on it; push to it; merge upstream into it |
| `gdm` *zsh* | diff this branch against `main` |
| `gmom` *zsh* | fetch and merge `origin/main` |
| `gpusho` *zsh* | push and set upstream |

## Environments and toolchains

| Command | Does |
| --- | --- |
| `mise use node@22` | pin a version for this project (writes `mise.toml`) |
| `mise use -g python@3.13` | change the global default (in `~/.config/mise/config.toml`) |
| `mise ls`, `mise outdated`, `mise upgrade` | what's installed / behind / upgrade it |
| `mise doctor` | check the setup |
| `echo 'export FOO=1' > .envrc && direnv allow` | per-directory env vars, loaded on `cd`, unloaded on leaving |
| `atuin stats` | most-used commands |
| `atuin import zsh` | pull `~/.zsh_history` into atuin (setup does this once) |
| `atuin register` / `atuin login` | opt in to syncing history between machines |
| `rm -rf ~/.cache/zsh-init` | regenerate cached tool init scripts (after changing a tool's shell setup) |

## Keeping the dotfiles in sync

| Command | Does |
| --- | --- |
| `scripts/try-dotfiles.sh` | (inside herdr) open a tab running that checkout's shell and nvim config (a branch or worktree), with nothing linked |
| `scripts/sync-dotfiles.sh` | pull and relink |
| `scripts/link-dotfiles.sh --check` | report anything not linked (exit 1 if so) |
| `scripts/link-dotfiles.sh` | make missing links |
| `scripts/link-dotfiles.sh --adopt` | a tool rewrote a linked file: take the live version into the repo |
| `scripts/link-dotfiles.sh --replace` | set conflicting live files aside and link over them (new machine) |

## Neovim

LazyVim. `<leader>` (Space) and wait shows every key in which-key; `<leader>sk` searches all
keymaps; `<leader>?` lists this buffer's. Setup details are in [nvim/.config/nvim/SETUP.md](nvim/.config/nvim/SETUP.md).

### General

| Key | Action |
| --- | --- |
| `jk` / `jj` | leave insert mode |
| `<C-s>` | save |
| `<leader>qq` | quit all |
| `<C-h/j/k/l>` | move between windows |
| `<leader>-` / `<leader>\|` | split below / right |
| `<leader>wd`, `<leader>wm` | close window, zoom it |
| `<S-h>` / `<S-l>` | previous / next buffer |
| `<leader>bd`, `<leader>bo` | close buffer, close all others |
| `<C-/>` or `<leader>ft` | floating terminal |
| `<leader>.` | scratch buffer |
| `<leader>l`, `<leader>cm` | Lazy (plugins), Mason (language tools) |
| `:LazyExtras` | turn language and feature extras on or off |
| `<leader>qs` / `<leader>ql` | restore session for this dir / last session |

### Find and search

| Key | Action |
| --- | --- |
| `<leader><leader>` or `<leader>ff` | find files (project root) |
| `<leader>fF` | find files (cwd) |
| `<leader>fr` | recent files |
| `<leader>,` / `<leader>fb` | switch buffer |
| `<leader>/` or `<leader>sg` | grep the project |
| `<leader>ss` / `<leader>sS` | symbols in file / workspace |
| `<leader>sk`, `<leader>sh` | keymaps, help pages |
| `<leader>sR` | resume the last picker |
| `<leader>sr` | search and replace across files (grug-far) |
| `<leader>fc` | find a config file |
| `<leader>e` / `<leader>E` | file explorer at project root / cwd |
| `<leader>H` | add file to harpoon |
| `<leader>h` | harpoon menu |
| `<leader>1` … `<leader>5` | jump to harpoon file 1–5 |

### Moving and editing

| Key | Action |
| --- | --- |
| `s` + 2 chars | flash: jump to any visible match |
| `S` | flash treesitter: select a node |
| `af`/`if`, `ac`/`ic`, `aa`/`ia` | function, class, argument text objects (`vaf`, `cia`) |
| `ys{motion}{char}`, `yss{char}` | surround a motion / the line (`ysiw"`) |
| `ds{char}`, `cs{old}{new}` | delete / change a surrounding pair |
| `gcc`, `gc{motion}`, `gco` | comment line, comment motion, add a comment below |
| `<M-j>` / `<M-k>` | move line or selection down / up |
| `<leader>p` (visual) | paste over a selection without losing the yank |
| `]]` / `[[` | next / previous reference to the word under the cursor |

### Code (LSP)

| Key | Action |
| --- | --- |
| `gd` | go to definition |
| `gr` | references |
| `gI` | implementation |
| `gy` | type definition |
| `gD` | declaration (source definition in TS) |
| `K` | hover docs |
| `<leader>ca` | code action |
| `<leader>cr` (or `<leader>rn`) | rename with live preview |
| `<leader>cR` | rename the file (and update imports) |
| `<leader>cf` (or `<leader>lf`) | format |
| `<leader>cd` | line diagnostics |
| `]d` / `[d` | next / previous diagnostic |
| `<leader>cs` | outline (symbols sidebar) |
| `<leader>cl` | LSP info |
| `<leader>uh` | toggle inlay hints |

### Diagnostics, todos, quickfix

| Key | Action |
| --- | --- |
| `<leader>xx` / `<leader>xX` | all diagnostics / this buffer's (Trouble) |
| `<leader>xt` | TODO/FIXME list |
| `]t` / `[t` | next / previous TODO comment |
| `<leader>xL`, `<leader>xQ` | location list, quickfix list |
| `]q` / `[q` | next / previous quickfix item |

### Debugging

Set a breakpoint, then `<leader>dc` picks a launch configuration for the language
(debugpy, delve, codelldb for Rust/C++, js-debug for Node).

| Key | Action |
| --- | --- |
| `<leader>db` / `<leader>dB` | toggle breakpoint / conditional breakpoint |
| `<leader>dc` | start / continue |
| `<leader>da` | start with arguments |
| `<leader>dO` / `<leader>di` / `<leader>do` | step over / into / out |
| `<leader>dC` | run to cursor |
| `<leader>du` | toggle the debugger UI |
| `<leader>de` | evaluate expression (or selection) |
| `<leader>dr` | REPL (in Rust buffers: pick a debuggable target) |
| `<leader>dt` | terminate |

### Tests

| Key | Action |
| --- | --- |
| `<leader>tr` | run the nearest test |
| `<leader>tt` / `<leader>tT` | run this file / all test files |
| `<leader>tl` | rerun the last test |
| `<leader>td` | debug the nearest test |
| `<leader>ts` | test summary tree |
| `<leader>to` / `<leader>tO` | output of this test / output panel |
| `<leader>tw` | watch this file and rerun on save |
| `<leader>tS` | stop |

### Git

| Key | Action |
| --- | --- |
| `<leader>gg` | lazygit |
| `]h` / `[h` | next / previous hunk |
| `<leader>ghs` / `<leader>ghr` | stage / reset hunk (or selection) |
| `<leader>ghp` | preview hunk inline |
| `<leader>ghb` / `<leader>gb` | blame line (full / short) |
| `ih` | hunk text object (`vih`, `dih`) |
| `<leader>gv` / `<leader>gV` | diffview of all changes / this file's history |
| `<leader>gs`, `<leader>gl`, `<leader>gf` | git status, log, this file's log (pickers) |
| `<leader>gB` | open the line on GitHub/GitLab |

### AI

| Key | Action |
| --- | --- |
| `<leader>ac` | toggle Claude Code in a split (it sees your open buffers and selection) |
| `<leader>af` | focus the Claude split |
| `<leader>ar` / `<leader>aC` | resume / continue a previous Claude session |
| `<leader>ab` | add this buffer to Claude's context |
| `<leader>as` (visual) | send the selection to Claude |
| `<leader>aa` / `<leader>ad` | accept / deny the diff Claude proposes |
| `<leader>Aa` | avante: ask about the code (needs `ANTHROPIC_API_KEY`) |
| `<leader>Ae` (visual) | avante: edit the selection |
| `<leader>At`, `<leader>Am` | avante: toggle sidebar, pick model |

### Per language

| Language | Key / command | Action |
| --- | --- | --- |
| TypeScript | `<leader>co` | organize imports |
| | `<leader>cM` | add missing imports |
| | `gD` | go to source definition (skips `.d.ts`) |
| Python | `<leader>cv` | pick the virtualenv |
| Rust | `<leader>cR` | rust-analyzer code actions (grouped) |
| | `<leader>dr` | pick a binary/test to debug |
| | `:RustLsp runnables`, `:RustLsp expandMacro`, `:RustLsp openCargo` | run targets, expand a macro, jump to Cargo.toml |
| | in `Cargo.toml`, `K` | crate versions and features (crates.nvim) |
| C / C++ | `<leader>ch` | switch between source and header |
| | — | needs `compile_commands.json` at the project root (see SETUP.md) |
| | `:ConfigureGtest` | point the GoogleTest adapter at your test binaries (once per project) |
| Go | `<leader>tr` / `<leader>td` | run / debug the test under the cursor (neotest-golang, delve) |
| | `<leader>ca` on a struct | fill struct, generate, add tags (gopls) |

### UI toggles

| Key | Action |
| --- | --- |
| `<leader>uf` | format-on-save on/off |
| `<leader>uw`, `<leader>ul` | wrap, line numbers |
| `<leader>ud` | diagnostics on/off |
| `<leader>uz` / `<leader>uZ` | zen mode / zoom the window |
| `<leader>uC` | pick a colorscheme with preview |
| `<leader>ur` | redraw, clear search highlight |
| `<leader>n` | notification history |
