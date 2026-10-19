# dotfiles

Shell, editor, terminal, git, Claude Code and herdr config for macOS, Linux (CachyOS,
Bazzite) and Windows.

**This repo is public.** Don't put anything here that names an employer, an internal repo,
org or host, or holds a secret. Those go in the local-only files listed under
[Machine-local files](#machine-local-files).

## Layout

| Path | What it is |
| --- | --- |
| `scripts/machine_setup.sh` | set up a machine: detects the OS and runs its setup script |
| `scripts/sync-dotfiles.sh` | pull the latest and relink |
| `scripts/link-dotfiles.sh` | make every config link; the list of linked files is here |
| `scripts/setup/` | one install script per OS |
| `scripts/claude/`, `scripts/update_bazzite_wallpaper.sh` | standalone helpers |
| everything else | the config itself, one folder per tool, laid out like `$HOME` (e.g. `zsh/.zshrc`, `herdr/.config/herdr/…`) |

## Cheatsheet

Key bindings and commands for everything here (Ghostty, herdr, zsh/atuin/television, zoxide,
mise, git aliases, and Neovim by task and by language): **[CHEATSHEET.md](CHEATSHEET.md)**.

## Set up a new machine

Clone to `~/dotfiles`. `.zshrc` and `.gitconfig` refer to files by that path.

```sh
cd ~
git clone https://github.com/markzuber/dotfiles
```

Then run:

```sh
~/dotfiles/scripts/machine_setup.sh
```

It detects the OS and runs the matching script from `scripts/setup/`:

| Detected | Runs |
| --- | --- |
| macOS | `mac_config.sh` |
| CachyOS | `cachyos_config.sh` |
| Bazzite | `bazzite_config_immutable.sh` |
| Windows (Git Bash) | `windows_config.ps1`, through PowerShell |

To run a different one, pass its name: `machine_setup.sh bazzite_distrobox_devmate`. On
Windows without Git Bash, run `scripts\setup\windows_config.ps1` directly.

Each setup script installs packages and tools, then runs `scripts/link-dotfiles.sh --replace`
to link the config into place. Config that an installer has already written, such as the
default `~/.zshrc` from oh-my-zsh, is moved aside to `<file>.pre-dotfiles.<time>`, not
deleted.

Then create any [machine-local files](#machine-local-files) this machine needs. If you added
`~/.claude/settings.work.json`, rerun `scripts/link-dotfiles.sh`.

### Rerunning a setup script

The macOS and CachyOS scripts skip anything already installed, so rerunning
`machine_setup.sh` is how you pick up a newly added tool. A rerun also reapplies their system settings (Finder, Dock, key
repeat and so on) and reruns the Claude Code installer. The older `bazzite_config.sh` has no
such checks, so don't rerun it.

### Before running it on a machine that's already set up

On a machine that already has some of this config, or an older version of it, check these
first:

1. **Pull:** `cd ~/dotfiles && git pull`.
2. **See what will be moved aside:** `scripts/link-dotfiles.sh --check`. Every `drift` line
   is a file that the setup's `--replace` will move to `<file>.pre-dotfiles.<time>`. Before
   running, note what those files hold that the repo doesn't. Real hosts in `~/.ssh/config`
   belong in `~/.ssh/config.local`, extra git settings in `~/.gitconfig-local`, and
   machine-specific shell setup in `~/.zshrc_local.zsh`.
3. **Apps (macOS):** `brew list --cask` shows the apps Homebrew manages. An app in the
   script's list that you installed some other way is skipped, not reinstalled, and listed at
   the end of the run. To have Homebrew manage it, delete the app and rerun.
4. **Rust:** `which rustc rustup`. If `rustc` exists but `rustup` doesn't (Homebrew's
   `rust`), the setup skips rust-analyzer, clippy and rustfmt. Run `brew uninstall rust` first
   to have it install rustup instead.
5. **Neovim state from an older config:** to start LazyVim clean, move
   `~/.local/share/nvim`, `~/.local/state/nvim` and `~/.cache/nvim` aside before opening nvim.
6. **Stay at the keyboard:** the macOS script asks for your password (sudo) and asks whether
   to enable Touch ID for sudo.

Afterwards, find the moved-aside files and copy back anything you need:

```sh
find ~ -maxdepth 3 -path ~/Library -prune -o -name '*.pre-dotfiles.*' -print 2>/dev/null
ls ~/Library/Application\ Support/Code*/User/ | grep pre-dotfiles
```

## How config gets into place

Every live config file is a symlink back into this repo, and **`scripts/link-dotfiles.sh` makes
all of them** on macOS and Linux. The list is the `MAP` array at the top of the script:

- **Every machine:** `.zshrc`, `.tmux.conf`, `.editorconfig`, `.gitconfig`, `~/.ssh/config`,
  nvim, ghostty, starship, atuin, mise, television, lsd, glow, gh-dash, Claude Code
  (`~/.claude/…`), herdr (`~/.config/herdr/…`) and `~/.agents/…`. Real ssh hosts go in the
  untracked `~/.ssh/config.local`, which the tracked config includes.
- **macOS only:** VS Code and VS Code Insiders settings under `~/Library/Application Support`,
  plus iTerm2. iTerm2 isn't a link: the script points iTerm2's prefs folder at `iterm2/`.
- **Linux only:** VS Code settings under `~/.config`, and the Flatpak copies of ghostty and VS
  Code under `~/.var/app/<app id>`. A Flatpak copy is linked only if that app is installed.

Under `~/.claude`, `~/.config/herdr` and `~/.agents` the script links **individual files**,
never whole directories, because those directories also hold transcripts, logs, sockets and
plugin caches.

Windows can't run the script. `scripts/setup/windows_config.ps1` keeps its own `Make-Link` lines,
covering the Claude Code files too. Rerun it after a pull to pick up new links. On Windows,
`~/.claude/settings.json` is a plain link to the personal part. If
`~/.claude/settings.work.json` exists, the script merges the two into a file instead, so
rerun the script after changing either part.

The script has four modes:

```sh
scripts/link-dotfiles.sh             # create or repair links; refuses to overwrite a conflict
scripts/link-dotfiles.sh --check     # report only; exits non-zero if anything has drifted
scripts/link-dotfiles.sh --adopt     # on a conflict, take the live file's content into the repo
scripts/link-dotfiles.sh --replace   # on a conflict, move the live file aside and link over it
```

Tools sometimes replace a symlinked config with a plain file. Claude Code does this to
`~/.claude/settings.json`, for example. `--check` finds those files, and `--adopt` pulls the
live content back into the repo. `--replace` is for a fresh machine, where the live file is an
installer's default that you don't want.

### Generated files

`~/.claude/settings.json` is **generated**, not linked. Claude Code has no way to include one
settings file in another. The script builds the live file by deep-merging two parts with
`jq`:

- `claude/.claude/settings.json`: personal settings, tracked here.
- `~/.claude/settings.work.json`: work-only settings, such as private plugin marketplaces,
  plugins and `autoMode` environment notes. **Never tracked.** Leave it out on a personal
  machine.

In the merge, objects combine key by key. Any other value, including an array, is taken whole
from the work file.

The live file is a plain copy, so a change Claude Code makes to it (for example, toggling a
plugin) does not reach the repo. `--check` reports it as drift, and a rerun refuses to
overwrite it. To keep the change:

1. Copy it into the right part: the repo file if it's personal, the work file if it isn't.
2. `rm ~/.claude/settings.json`
3. `scripts/link-dotfiles.sh`

## Keep a machine up to date

```sh
~/dotfiles/scripts/sync-dotfiles.sh
```

This stashes local changes, runs `git pull --ff-only`, restores the stash, and then runs
`scripts/link-dotfiles.sh` to pick up any new links. If restoring the stash conflicts, it lists
the files and skips the link step. Fix the conflicts, then run `scripts/link-dotfiles.sh` yourself.

New links arrive with the sync. New tools don't, so after pulling a change that adds a tool,
[rerun the setup script](#rerunning-a-setup-script).

## Add or change a tracked file

Put the file in the repo at the path that matches where it lives under `$HOME`. For example,
`~/.claude/hooks/foo.sh` goes in `claude/.claude/hooks/foo.sh`. Then add a line to `MAP` in
`scripts/link-dotfiles.sh`. If the file only belongs on one OS, add it to that OS's block in the
`case "$(uname -s)"` below `MAP`.

```sh
"claude/.claude/hooks/foo.sh:$HOME/.claude/hooks/foo.sh"
```

If the file already exists on this machine, you can skip copying it. Add the `MAP` line and
run the script: it moves a live file that isn't in the repo yet into the repo and links it.
If the directory also holds state, add those state paths to `.gitignore` too. The herdr and
`claude/.claude/` blocks there show the pattern.

If the file should also be on Windows, add a `Make-Link` line to `scripts/setup/windows_config.ps1`.

**Stop tracking a file.** Remove its `MAP` line and add the path to
`.gitignore`. Then run `git rm --cached <path>`. Before that, replace the live symlink with a
real copy so the tool keeps working:
`cp "$(readlink <live>)" <live>.tmp && mv -f <live>.tmp <live>`.

**Paths.** Never write a home directory as `/Users/<name>` or `/home/<name>`. Use `~` or
`$HOME` in shell, `wezterm.home_dir` in wezterm, and so on, so the same file works under any
username.

## Machine-local files

These files are read if they exist and are never committed. Create them by hand on the
machines that need them.

| File | Read by | Holds |
| --- | --- | --- |
| `~/.gitconfig-local` | `[include]` right after `[user]` in `git/.gitconfig` | work email, URL rewrites, credential helper |
| `~/.claude/settings.work.json` | `scripts/link-dotfiles.sh`, or `windows_config.ps1` on Windows (merged into `~/.claude/settings.json`) | work-only Claude Code settings |
| `~/.zshrc_local.zsh` | end of `zsh/.zshrc` | shell setup for this machine only |
| `~/.zshrc_work.zsh` | end of `zsh/.zshrc` | work env vars and API keys |
| `~/.zube-at-work` (empty marker) | `zsh/.zshrc` | makes `.zshrc` source `zsh/work_setup.zsh` (git-ignored) |
| `$HOME\Documents\PowerShell\profile.work.ps1` | `powershell/Microsoft.PowerShell_profile.ps1` | work PowerShell setup |

`~/.gitconfig-local` is included after `[user]`, so a work email set there overrides the
personal one.
