# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

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
export PATH="$HOME/.local/bin:$HOME/.cargo/bin:$PATH"

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="powerlevel10k/powerlevel10k"

# AUTOCOMPLETION
# oh-my-zsh runs compinit itself (with a cached, host-scoped zcompdump) when
# oh-my-zsh.sh is sourced below, so no manual compinit here — it was a redundant,
# full-audit second run.

HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000

setopt CORRECT
setopt EXTENDED_HISTORY                 # add timestamps to history
setopt APPEND_HISTORY                   # adds history
setopt SHARE_HISTORY
setopt INC_APPEND_HISTORY SHARE_HISTORY # adds history incrementally and share it across sessions
setopt HIST_IGNORE_ALL_DUPS             # don't record dupes in history
setopt HIST_REDUCE_BLANKS

zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'


# autocompletion using arrow keys (based on history)
bindkey '\e[A' history-search-backward
bindkey '\e[B' history-search-forward

# always update but never prompt for it
export DISABLE_UPDATE_PROMPT=true

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
plugins=(git fzf zsh-syntax-highlighting zsh-autosuggestions fzf-tab z)

fpath+=${ZSH_CUSTOM:-${ZSH:-~/.oh-my-zsh}/custom}/plugins/zsh-completions/src
fpath+=$HOME/dotfiles/scripts/claude
# Docker CLI completions — add to fpath BEFORE oh-my-zsh's compinit runs (below),
# so they're picked up by that single compinit instead of a third redundant one.
fpath=(~/.docker/completions $fpath)
# TODO: this was the old way, make sure we're not breaking by removing
# plugins=(git fzf zsh-syntax-highlighting zsh-autosuggestions z)
# source $ZSH/custom/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh

source $ZSH/oh-my-zsh.sh

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

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# setup nvm — lazy-loaded (node/npm come from Homebrew; nvm has no installed versions,
# so eager-sourcing nvm.sh + nvm_auto was ~300ms of pure startup cost for nothing).
export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
nvm() {
  unset -f nvm
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
  [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
  nvm "$@"
}

alias vim="nvim"
alias sv="sudo nvim"

# User configuration
export EDITOR='nvim'

alias cls='clear'
alias srcz="source ~/.zshrc"
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

. "$HOME/.cargo/env"

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
alias path="echo -e ${PATH//:/\\n}"

alias repos="cd ~/repos"

alias myip="curl http://ipecho.net/plain; echo"
alias myip_dns="dig +short myip.opendns.com @resolver1.opendns.com"

alias usage="du -h -d1"
alias runp="lsof -i "
alias topten="history | commands | sort -rn | head"
alias listening="lsof -i -P | grep LISTEN "

alias glog="git log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --branches"
alias gpusho='git push --set-upstream origin $(git rev-parse --abbrev-ref HEAD)'

alias flacconv="for f in *.flac; do ffmpeg -i "$f" -ab 320k -map_metadata 0 -id3v2_version 3 "${f%.flac}.mp3"; done"

# tree (with fallback)
if which tree >/dev/null 2>&1; then
  # displays a directory tree
  alias tree="tree -Csu"
  # displays a directory tree - paginated
  alias ltree="tree -Csu | less -R"
else
  alias tree="find . -print | sed -e 's;[^/]*/;|____;g;s;____|; |;g'"
  alias ltree="tree | less -R"
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
# shows more about the ports on which the applications use
alias llport='netstat -nape --inet --inet6'
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

# eza is the other option, but lsd is fantastic
# 'brew install lsd'

alias ic="wezterm imgcat"

alias ls="lsd "

# I don't really like zoxide.  Maybe I need to learn it more, but I like what i have.
# eval "$(zoxide init zsh)"
# alias cd="z"

# Passing an empty string env variable clears the constraint for the execution lifecyle
# alias lsd="env LS_COLORS= lsd"
# alias ll="env LS_COLORS= lsd -lF --header --group-directories-first $COLORFLAG"
# alias la="env LS_COLORS= lsd -laF --header $COLORFLAG"

# Core replacements
alias ls="lsd -F $COLORFLAG" 
alias ll="lsd -lF --group-directories-first $COLORFLAG"
alias la="lsd -laF $COLORFLAG" # Removed 'h' to respect bytes layout
alias lsa="la"

# Detailed long format view shortcuts
alias l="lsd -lF $COLORFLAG"   # Removed 'h' to respect bytes layout
alias l1="lsd -1 $COLORFLAG"
alias ldir="l -R"

# Hidden file searches
alias l.="lsd -dlF .* $COLORFLAG" # Removed 'h' to respect bytes layout
alias ldot="l."

# Interactive Tree View
alias ltree="lsd --tree" 

# File search helper tracking
alias lf="find ./* -ctime -1 | xargs lsd -ltr $COLORFLAG" 

# alias lt="lsd --tree"
# # list all files colorized in long format
# alias l="lsd -lhF $COLORFLAG"
# # list all files with directories
# alias ldir="l -R"
# # Show hidden files
# alias l.="lsd -dlhF .* $COLORFLAG"
# alias ldot="l."
# # use colors
# alias ls="lsd -F $COLORFLAG"
# # display only files & dir in a v-aling view
# alias l1="lsd -1 $COLORFLAG"
# # displays all files and directories in detail
# alias la="lsd -laFh $COLORFLAG"
# # displays all files and directories in detail (without "." and without "..")
# # alias lA="exa -lAFh $COLORFLAG"
# alias lsa="la"
# # displays all files and directories in detail with newest-files at bottom
# # alias lr="exa -laFhtr $COLORFLAG"
# # show last 10 recently changed files
# alias lt="lsd -altr | grep -v '^d' | tail -n 10"
# # show files and directories (also in sub-dir) that was touched in the last hour
# alias lf="find ./* -ctime -1 | xargs ls -ltr $COLORFLAG"
# # displays files and directories in detail
# alias ll="lsd -lFh --group-directories-first $COLORFLAG"
# shows the most recently modified files at the bottom of
# alias llr="exa -lartFh --group-directories-first $COLORFLAG"
# list only directories
# alias lsd="eza -lFh $COLORFLAG | grep --color=never '^d'"
# sort by file-size
# alias lS="exa -1FSshr $COLORFLAG"
# displays files and directories
# alias dir="exa --format=vertical $COLORFLAG"
# displays more information about files and directories
# alias vdir="exa --format=long $COLORFLAG"

# ------------------------------------------------------------------------------
# | Hard- & Software Infos                                                     |
# ------------------------------------------------------------------------------

# pass options to free
alias meminfo="free -m -l -t"

# get top process eating memory
alias psmem="ps -o time,ppid,pid,nice,pcpu,pmem,user,comm -A | sort -n -k 6"
alias psmem5="psmem | tail -5"
alias psmem10="psmem | tail -10"

# get top process eating cpu
alias pscpu="ps -o time,ppid,pid,nice,pcpu,pmem,user,comm -A | sort -n -k 5"
alias pscpu5="pscpu5 | tail -5"
alias pscpu10="pscpu | tail -10"

# shows the corresponding process to ...
alias psx="ps auxwf | grep "

# shows the process structure to clearly
alias pst="pstree -Alpha"

# shows all your processes
alias psmy="ps -ef | grep $USER"

# the load-avg
alias loadavg="cat /proc/loadavg"

# show all partitions
alias partitions="cat /proc/partitions"

# shows the disk usage of a directory legibly
alias du='du -kh'

# show the biggest files in a folder first
alias du_overview='du -h | grep "^[0-9,]*[MG]" | sort -hr | less'

# shows the complete disk usage to legibly
alias df='df -kTh'

# ------------------------------------------------------------------------------
# | Other                                                                      |
# ------------------------------------------------------------------------------

# Put this in here for ghostty
# See https://github.com/ghostty-org/ghostty/issues/3335
export TERM=xterm-256color

# decimal to hexadecimal value
alias dec2hex='printf "%x\n" $1'

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
else
  alias c="code"
  alias ci="code-insiders"
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
trap clean_pane_tint_on_exit EXIT INT TERM

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

# herdr pane/agent helpers: hls, hrun, hwatch, hjoin, hme (see the file for the full list).
# Only useful inside herdr; harmless elsewhere, since every function just shells out.
[[ ! -f ~/.agents/herdr-spawn.zsh ]] || source ~/.agents/herdr-spawn.zsh

# source local file that won't get checked in to my dotfiles
[[ ! -f ~/.zshrc_local.zsh ]] || source ~/.zshrc_local.zsh
[[ ! -f ~/.zshrc_work.zsh ]] || source ~/.zshrc_work.zsh
