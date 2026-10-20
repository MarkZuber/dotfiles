# Keep PATH free of duplicates. Marking `path` unique drops a repeat on sight and keeps the
# leftmost copy, retroactively as well as from here on. Two entries arrive twice without it:
# ~/.cargo/bin (~/.zshenv sources .cargo/env on an empty PATH, then the export below adds it
# again with no check) and the flutter bin (~/.zshenv and ~/.zshrc_work.zsh add the same
# folder, one spelled absolute and one spelled $HOME, so neither can see the other). Apple's
# path_helper in /etc/zprofile reorders PATH between those two steps, which is why the pairs
# end up far apart and are easy to miss. It also stops PATH growing on a re-source or in a
# nested shell, which inherits the parent PATH and then prepends to it again.
typeset -U path PATH

# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Add ~/.local/bin for distrobox-exported binaries (lsd, ghostty, etc.)
# Add ~/.cargo/bin for cargo-installed tools (lsd via cargo)
# Add the repo's scripts/claude for `wt`, which the wt() wrapper below calls as `command wt`.
export PATH="$HOME/.local/bin:$HOME/.cargo/bin:$HOME/dotfiles/scripts/claude:$PATH"

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# No oh-my-zsh theme: the prompt is starship, initialised after oh-my-zsh below.
ZSH_THEME=""

# AUTOCOMPLETION
# oh-my-zsh runs compinit itself (with a cached, host-scoped zcompdump) when
# oh-my-zsh.sh is sourced below, so no manual compinit here — it was a redundant,
# full-audit second run.

# atuin (initialised at the bottom) is the real history search; this file is the fallback and
# what atuin imports from.
HISTFILE=~/.zsh_history
HISTSIZE=100000
SAVEHIST=100000

setopt CORRECT
setopt EXTENDED_HISTORY                 # add timestamps to history
setopt SHARE_HISTORY                    # write incrementally and share across sessions
setopt HIST_IGNORE_ALL_DUPS             # don't record dupes in history
setopt HIST_REDUCE_BLANKS

zstyle ':fzf-tab:complete:cd:*' fzf-preview 'lsd -1 --color=always $realpath'

# always update but never prompt for it
zstyle ':omz:update' mode auto

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# ZSH_CUSTOM=/path/to/new-custom-folder
# Would you like to use another custom folder than $ZSH/custom?

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
# Order matters: fzf-tab must load after compinit but before anything that wraps widgets
# (autosuggestions), and zsh-syntax-highlighting has to be last.
plugins=(git fzf fzf-tab zsh-autosuggestions zsh-syntax-highlighting)

fpath+=${ZSH_CUSTOM:-${ZSH:-~/.oh-my-zsh}/custom}/plugins/zsh-completions/src
fpath+=$HOME/dotfiles/scripts/claude
# Docker CLI completions — add to fpath BEFORE oh-my-zsh's compinit runs (below),
# so they're picked up by that single compinit instead of a third redundant one.
fpath=(~/.docker/completions $fpath)

source $ZSH/oh-my-zsh.sh

# Alt+Enter runs the grey autosuggestion as-is. (Ctrl+E / → already accept it without running.)
bindkey '^[^M' autosuggest-execute

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

# nvm, only where mise isn't installed (the Linux setup scripts still install nvm). Lazy-loaded:
# sourcing nvm.sh eagerly cost ~300ms of startup.
if (( ! $+commands[mise] )) && [[ -s "$HOME/.nvm/nvm.sh" ]]; then
  export NVM_DIR="$HOME/.nvm"
  nvm() {
    unset -f nvm
    \. "$NVM_DIR/nvm.sh"
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
    nvm "$@"
  }
fi

alias vim="nvim"
alias sv="sudo nvim"

# User configuration
# --wait so callers (crontab -e, zle edit-command-line, ...) block until the tab is closed.
# Falls back to nvim where VS Code isn't installed, e.g. over ssh to a headless box.
if (( $+commands[code] )); then
  export EDITOR='code --wait'
else
  export EDITOR='nvim'
fi

alias cls='clear'
# Reload by replacing the shell: re-sourcing stacks hooks, keybindings and plugin state on top
# of the old ones, while exec starts clean (keeping the environment, cwd and history).
alias srcz="exec zsh"
alias viz="vim ~/.zshrc"

alias python="python3"

alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias .....="cd ../../../.."

# fallback by typo
alias cd..='cd ..'
alias cd...='cd ../..'
alias cd....='cd ../../..'
alias cd.....='cd ../../../..'

alias c="code"
alias ci="code-insiders"

alias cdh="cd ~/"
alias cdhome="cdh"
alias cdr="cd /"
alias cdroot="cdr"

alias zshrc="c ~/.zshrc"

alias mkdir="mkdir -p"
alias md="mkdir"
alias rd="rmdir"

alias d='dirs -v | head -10'

# Print each PATH entry on a separate line
alias path='print -l $path'

alias repos="cd ~/repos"

alias myip="curl http://ipecho.net/plain; echo"
alias myip_dns="dig +short myip.opendns.com @resolver1.opendns.com"

alias usage="du -h -d1"
alias runp="lsof -i "
# ten most-used commands
alias topten="history 1 | awk '{print \$2}' | sort | uniq -c | sort -rn | head"
alias listening="lsof -i -P | grep LISTEN "

alias glog="git log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --branches"
alias gpusho='git push --set-upstream origin $(git rev-parse --abbrev-ref HEAD)'

# convert every .flac in the current directory to a 320k mp3
flacconv() {
  local f
  for f in *.flac; do
    ffmpeg -i "$f" -ab 320k -map_metadata 0 -id3v2_version 3 "${f%.flac}.mp3"
  done
}

# tree (with fallback)
if (( $+commands[tree] )); then
  alias tree="tree -Csu"
else
  alias tree="find . -print | sed -e 's;[^/]*/;|____;g;s;____|; |;g'"
fi

# from 'brew install bat' a replacement for cat
# with color highlightint
export BAT_THEME='gruvbox-dark'
alias cat='bat --paging=never'
alias catp='bat --paging=never --style=plain'

# colorize help commands
# for the :B part, see https://github.com/ohmyzsh/ohmyzsh/issues/12457
alias -g :B='-h 2>&1 | bat --language=help --style=plain'
alias -g :C='--help 2>&1 | bat --language=help --style=plain'

# ------------------------------------------------------------------------------
# | Search and Find                                                            |
# ------------------------------------------------------------------------------

alias grep="rg --color=auto -g '!**/.git/**/*' -g '!**/.fingerprint/**/*' -g '!uv.lock' -g '!**/.cargo/**/*' -g '!**/target/release/**/*'"

# ------------------------------------------------------------------------------
# | Network                                                                    |
# ------------------------------------------------------------------------------

# speedtest: get a 100MB file via wget
alias speedtest="wget -O /dev/null http://speedtest.wdc01.softlayer.com/downloads/test100.zip"
# displays the ports that use the applications
alias lsport='sudo lsof -i -T -n'
# show only active network listeners
alias netlisteners='sudo lsof -i -P | grep LISTEN'

# ------------------------------------------------------------------------------
# | Date & Time                                                                |
# ------------------------------------------------------------------------------

# date
alias date_iso_8601='date "+%Y%m%dT%H%M%S"'
alias date_clean='date "+%Y-%m-%d"'
alias date_year='date "+%Y"'
alias date_month='date "+%m"'
alias date_week='date "+%V"'
alias date_day='date "+%d"'
alias date_hour='date "+%H"'
alias date_minute='date "+%M"'
alias date_second='date "+%S"'
alias date_time='date "+%H:%M:%S"'

# stopwatch
alias timer='echo "Timer started. Stop with Ctrl-D." && date && time cat && date'

# ------------------------------------------------------------------------------
# | List Directory Contents (ls)                                               |
# ------------------------------------------------------------------------------

# lsd is the one ls replacement installed (eza is the alternative; exa, its predecessor, is
# unmaintained). Its settings are in lsd/.config/lsd/config.yaml.

alias ic="wezterm imgcat"

# Core replacements
alias ls="lsd -F"
alias ll="lsd -lF --group-directories-first"
alias la="lsd -laF" # Removed 'h' to respect bytes layout
alias lsa="la"

# Detailed long format view shortcuts
alias l="lsd -lF"   # Removed 'h' to respect bytes layout
alias l1="lsd -1"
alias ldir="l -R"

# Hidden file searches
alias l.="lsd -dlF .*" # Removed 'h' to respect bytes layout
alias ldot="l."

# Interactive Tree View
alias ltree="lsd --tree"

# Files changed in the last day, newest last
alias lf="find ./* -ctime -1 | xargs lsd -ltr"

# ------------------------------------------------------------------------------
# | Hard- & Software Infos                                                     |
# ------------------------------------------------------------------------------

# get top process eating memory
alias psmem="ps -o time,ppid,pid,nice,pcpu,pmem,user,comm -A | sort -n -k 6"
alias psmem5="psmem | tail -5"
alias psmem10="psmem | tail -10"

# get top process eating cpu
alias pscpu="ps -o time,ppid,pid,nice,pcpu,pmem,user,comm -A | sort -n -k 5"
alias pscpu5="pscpu | tail -5"
alias pscpu10="pscpu | tail -10"

# shows the corresponding process to ...
alias psx="ps auxwf | grep "

# shows the process structure to clearly
alias pst="pstree -Alpha"

# shows all your processes
alias psmy="ps -ef | grep $USER"

if [[ "$(uname)" == Linux ]]; then
  alias meminfo="free -m -l -t"
  alias loadavg="cat /proc/loadavg"
  alias partitions="cat /proc/partitions"
  # shows more about the ports on which the applications use
  alias llport='netstat -nape --inet --inet6'
else
  alias meminfo="top -l 1 -s 0 | grep PhysMem"
  alias loadavg="sysctl -n vm.loadavg"
  alias partitions="diskutil list"
fi

# shows the disk usage of a directory legibly
alias du='du -kh'

# show the biggest files in a folder first
alias du_overview='du -h | grep "^[0-9,]*[MG]" | sort -hr | less'

# shows the complete disk usage to legibly
alias df='df -kTh'

# ------------------------------------------------------------------------------
# | Other                                                                      |
# ------------------------------------------------------------------------------

# TERM is left as Ghostty sets it (xterm-ghostty). Remote hosts that lack that terminfo are
# handled by Ghostty's ssh-terminfo/ssh-env shell-integration features (see the ghostty config),
# which is the fix for https://github.com/ghostty-org/ghostty/issues/3335.

# decimal to hexadecimal value
dec2hex() { printf "%x\n" "$1"; }

# Canonical hex dump; some systems have this symlinked
command -v hd >/dev/null || alias hd="hexdump -C"

# OS X has no `md5sum`, so use `md5` as a fallback
command -v md5sum >/dev/null || alias md5sum="md5"

# OS X has no `sha1sum`, so use `shasum` as a fallback
command -v sha1sum >/dev/null || alias sha1sum="shasum"

# intuitive map function
#
# For example, to list all directories that contain a certain file:
# find . -name .gitattributes | map dirname
alias map="xargs -n1"

# figlet -f mini Zube Mac | lolcat
# fortune -s | cowsay | lolcat

alias sshpi="ssh pi@192.168.2.203"
alias sshdev="ssh 192.168.2.197"
alias gcma="git checkout main"
alias gcmas="git checkout master"
alias gpfix="git a; git com 'fix'; git push"
alias gdc="git diff --cached"
alias gmom="git fetch; git merge origin/main"

alias rg="rg --hidden --glob '!.git'"

# wt switch <name> — cd into a worktree (must be a shell function to affect current session)
wt() {
  if [[ "$1" == "switch" || "$1" == "sw" ]]; then
    if [[ -n "${2:-}" ]]; then
      cd "$(command wt path "$2")"
    else
      cd "$(git worktree list --porcelain | awk '/^worktree / { print $2; exit }')"
    fi
  else
    command wt "$@"
  fi
}

# source script from the same directory as this file
if [[ -f ~/.zube-at-work ]]; then
    source ~/dotfiles/zsh/work_setup.zsh
fi

### Ghostty Window Pane Tinting
# Goal being to be able to manually select a background tint (the tint-aliases)
# and also to be able to have any new pane randomly pick a color value.
# The fancy part is that it also makes sure not to duplicate colors when launching.
# So we shouldn't get two forest colored panes.  Unless we open too many panes.
# The pane color limit is per-window, not across all windows.  Each window
# gets its own color selection list so we won't run out.
# It does mean however that two windows could (likely) have a pane with the same color.

# 1. Manual Tint Aliases
alias tint-off="printf '\e]111\a'"            # System / Native Theme
alias tint-slate="printf '\e]11;#161b22\a'"   # GitHub Dark-style
alias tint-navy="printf '\e]11;#0d1b2a\a'"    # Deep Oceanic Blue
alias tint-teal="printf '\e]11;#072227\a'"    # Matrix-adjacent Dark Teal
alias tint-forest="printf '\e]11;#132219\a'"  # Clean Dark Green
alias tint-olive="printf '\e]11;#1c1d11\a'"   # Earthy Camo Tone
alias tint-plum="printf '\e]11;#1e122b\a'"    # Dracula Purple
alias tint-maroon="printf '\e]11;#281313\a'"  # Production Red
alias tint-mocha="printf '\e]11;#1e1713\a'"   # Warm Espresso Brown
alias tint-carbon="printf '\e]11;#171717\a'"  # Pure Minimalist Charcoal

# Helper to get the state file unique to THIS Ghostty window
_get_ghostty_state_file() {
  # Fallback to "default" if GHOSTTY_WINDOW_ID isn't set yet
  local win_id="${GHOSTTY_WINDOW_ID:-default}"
  echo "${TMPDIR:-/tmp}/ghostty_colors_${USER}_win_${win_id}"
}

# 2. Automated Smart Deduplication Switcher (Per-Window Isolated)
assign_curated_pane_tint() {
  local state_file=$(_get_ghostty_state_file)
  touch "$state_file"

  local all_colors=(
    '\e]111\a'        # system theme / tint-off
    '\e]11;#161b22\a' # slate
    '\e]11;#0d1b2a\a' # navy
    '\e]11;#072227\a' # teal
    '\e]11;#132219\a' # forest
    '\e]11;#1c1d11\a' # olive
    '\e]11;#1e122b\a' # plum
    '\e]11;#281313\a' # maroon
    '\e]11;#1e1713\a' # mocha
    '\e]11;#171717\a' # carbon
  )

  # Purge stale dead PIDs from this window's tracking file
  local running_pids=()
  if [[ -s "$state_file" ]]; then
    while read -r recorded_pid recorded_color; do
      if kill -0 "$recorded_pid" 2>/dev/null; then
        running_pids+=("$recorded_pid $recorded_color")
      fi
    done < "$state_file"
  fi

  # Rewrite active tracking file with only live panes for this window
  printf "%s\n" "${running_pids[@]}" > "$state_file"

  # Gather currently occupied colors in this window
  local used_colors=()
  if [[ -s "$state_file" ]]; then
    used_colors=($(awk '{print $2}' "$state_file"))
  fi

  # Determine which colors are completely unassigned in this window
  local available_colors=()
  for col in "${all_colors[@]}"; do
    if [[ ! " ${used_colors[@]} " =~ " ${col} " ]]; then
      available_colors+=("$col")
    fi
  done

  # Fallback to the full pool if layout density exceeds your 10 palette choices
  if [[ ${#available_colors[@]} -eq 0 ]]; then
    available_colors=("${all_colors[@]}")
  fi

  # Pick a random selection from only the unused colors
  local random_index=$(( RANDOM % ${#available_colors[@]} + 1 ))
  local final_selection="${available_colors[$random_index]}"

  # Lock selection in the file matching this shell's Process ID ($$)
  echo "$$ $final_selection" >> "$state_file"

  # Push choice out to the Ghostty layout renderer
  printf "$final_selection"
}

# 3. Dynamic Cleanup Hook on Window Close
clean_pane_tint_on_exit() {
  local state_file=$(_get_ghostty_state_file)
  if [[ -f "$state_file" ]]; then
    local temp_file=$(mktemp)
    grep -v "^$$ " "$state_file" > "$temp_file" 2>/dev/null
    mv "$temp_file" "$state_file"
    
    # If the file is now empty, delete it entirely
    [[ ! -s "$state_file" ]] && rm -f "$state_file"
  fi
}
# zshexit runs once when the shell exits; a trap on INT also fired on every Ctrl-C at the prompt.
autoload -Uz add-zsh-hook
add-zsh-hook zshexit clean_pane_tint_on_exit

# Run the smart assignment immediately when shell spawns
# assign_curated_pane_tint

# 4. SSH Safety Wrapper Integration
ssh() {
  tint-maroon
  command ssh "$@"
  assign_curated_pane_tint  # Restores a clean, window-appropriate unused color upon exit
}

### END Window colorization


OS=$(uname)
case "$OS" in
    'Linux')
        export GCM_CREDENTIAL_STORE=plaintext
        ;;
    'Darwin')
        export GCM_CREDENTIAL_STORE=keychain
        ;;
    *)
        export GCM_CREDENTIAL_STORE=plaintext
        ;;
esac

alias gdm='git diff main...$(git rev-parse --abbrev-ref HEAD)'
rmc() { claude "resolve merge conflicts"; }

alias http="xh"
alias ghd="gh dash"
alias mdv="glow -p"

# ------------------------------------------------------------------------------
# | Prompt, history, environments, navigation                                  |
# ------------------------------------------------------------------------------
# Each tool prints its own init script; running all six on every shell start cost ~220ms, so
# each script is cached under ~/.cache/zsh-init and regenerated when that tool's binary is
# newer (i.e. after an upgrade) or the init command below changes. A tool that isn't installed
# (the Linux setups) is skipped.
# To force a refresh after changing a tool's own config: rm -rf ~/.cache/zsh-init
_cached_init() {
  local tool=$1; shift
  local bin=${commands[$tool]}
  [[ -n $bin ]] || return 0
  local cache=${XDG_CACHE_HOME:-$HOME/.cache}/zsh-init/$tool.zsh
  local first=""
  [[ -s $cache ]] && read -r first < $cache
  if [[ $first != "# $*" || $bin -nt $cache ]]; then
    mkdir -p ${cache:h}
    { print -r -- "# $*"; "$@" } >| $cache
  fi
  source $cache
}

# mise: node/python/go versions (global defaults in ~/.config/mise/config.toml, per-project
# in mise.toml or .tool-versions). Activated first so the tools below see its PATH.
_cached_init mise mise activate zsh

# direnv: loads/unloads a directory's .envrc on cd (`direnv allow` to trust one).
_cached_init direnv direnv hook zsh

# zoxide: `z <words>` jumps to the best match, `zi` picks with fzf. cd itself is untouched.
_cached_init zoxide zoxide init zsh

# television: context-aware Ctrl+T (cd → dirs, git checkout → branches, nvim → files).
# Initialised before atuin so atuin's Ctrl+R binding wins.
_cached_init tv tv init zsh

# atuin: Ctrl+R searches a full, timestamped history database (sync is opt-in). ↑ is left out
# of it on purpose: ↑/↓ step through earlier commands starting with what's already typed.
_cached_init atuin atuin init zsh --disable-up-arrow
bindkey '\e[A' history-search-backward
bindkey '\e[B' history-search-forward

_cached_init starship starship init zsh

# Redraw the prompt as Enter is pressed, so the clock on each prompt left in scrollback says
# when that command started rather than when the prompt first appeared.
if (( $+commands[starship] )); then
  autoload -Uz add-zle-hook-widget
  _prompt_stamp_on_enter() { zle reset-prompt }
  zle -N _prompt_stamp_on_enter
  add-zle-hook-widget line-finish _prompt_stamp_on_enter
fi

# herdr pane/agent helpers: hls, hrun, hwatch, hjoin, hme (see the file for the full list).
# Only useful inside herdr; harmless elsewhere, since every function just shells out.
[[ ! -f ~/.agents/herdr-spawn.zsh ]] || source ~/.agents/herdr-spawn.zsh

# source local file that won't get checked in to my dotfiles
[[ ! -f ~/.zshrc_local.zsh ]] || source ~/.zshrc_local.zsh
[[ ! -f ~/.zshrc_work.zsh ]] || source ~/.zshrc_work.zsh
