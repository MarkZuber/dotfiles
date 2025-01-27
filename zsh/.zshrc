# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="powerlevel10k/powerlevel10k"

# AUTOCOMPLETION
# initialize autocompletion
autoload -U compinit && compinit

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

# setup nvm
export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm


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

if [[ -f ~/.zube-at-work ]]; then
  alias sshdev="ssh devvm30920.prn0.facebook.com"
  alias etdev="et devvm30920.prn0.facebook.com:8080"
  alias etdevmux="et -c 'tmux -CC new-session -As auto' -x devvm30920.prn0.facebook.com:8080"

  alias c="code-fb"
  alias ci="code-fb-insiders"

  alias chime="afplay /System/Library/Sounds/Glass.aiff -v 2"

  alias cdf="cd ~/fbsource/"

  ### BEGIN VSCODE ALIASES ###

  alias cdvs="cd ~/fbsource/xplat/vscode"
  alias cvs="code-fb ~/fbsource/xplat/vscode"

  alias ybrc="yarn build --ext remote-connections"
  alias yybrc="yarn && yarn build --ext remote-connections"

  source ~/fbsource/xplat/vscode/scripts/distro/aliases-laptop.sh

  ### END VSCODE ALIASES ###

  ### BEGIN ANDROID ALIASES ###
  alias cda="cd ~/fbsource/fbandroid/"
  alias cdaf="cd ~/fbsource/fbandroid/devEnv/focus/python/focus"

  alias bbp="buck2 build //fbandroid/java/com/facebook/tools/intellij:configured_active_plugins"
  alias afp="arc focus --targets configured_active_plugins --open"

  alias mpsetup="arc monoproject setup --extras ide-plugins"
  alias mprefresh="arc monoproject refresh"
  alias killasport="rm ~/Library/Caches/Google/AndroidStudio2024.1/plugins-sandbox/system/.port"

  alias jbgate="jetbrains-cli install-ide gateway"
  alias hgstable="hg pull && hg up remote/fbandroid/stable"
  alias ap="arc pull && chime"
  alias al="arc lint -a"
  alias pyr="~/fbsource/fbandroid/scripts/run_pyre_typecheck.py"
  alias afig="arc focus-android config"
  alias afc="arc focus-android config"
  alias afix="arc focus-android fix --open --restart-ide && chime"
  alias afip="arc focus install-plugins --targets"
  unrage() { arc focus-android unrage $1 --open }

  # Used to build/open AS for arc focus development
  alias af="arc focus-android --targets configured_active_plugins focus-android //fbandroid/java/com/facebook/tools/intellij/internauth:internauth //xplat/buck2/intellij_project/tools/project_writer:project_writer --pinned fbandroid/java/com/facebook/tools/intellij/... fbandroid/devEnv/focus/python/... --without-tests --restart-ide --open --fetch-from-remote-cache=false && arc focus-android sync --install-plugins-to-sandbox && chime"

  # Used to build/open AS for gateway development
  alias afgate="arc focus-android --open --targets gateway-connector"

  # run tests for arc focus python code
  alias test_af="buck2 test //fbandroid/devEnv/focus/python/focus/__tests__:tests"

  # run tests for java code
  alias test_fb4idea="buck2 test //fbandroid/javatests/com/facebook/tools/intellij/fbandroid4idea:integration --target-platforms //third-party/java/intellij:AI-223-platform"

  # build plugins for gateway
  bldgwplug() { buck2 build scriptus codecompose4idea gatekeeper ideabuck invoker navelgazer scubalogger theia --target-platforms //third-party/java/intellij:IC-$1-platform }
  alias hgrf="hg rebase -d fbandroid/stable"

  alias og="open /Applications/GW-223.8472.app"
  alias od="dev connect -t fbsource:android -e -i projector"
  alias odx="dev connect -t fbsource:android_devx -e -i projector"

  # added by setup_fb4a.sh
  export ANDROID_SDK=/opt/android_sdk
  export ANDROID_NDK_REPOSITORY=/opt/android_ndk
  export ANDROID_HOME=${ANDROID_SDK}
  export PATH=${PATH}:${ANDROID_SDK}/emulator:${ANDROID_SDK}/tools:${ANDROID_SDK}/tools/bin:${ANDROID_SDK}/platform-tools

  ### END ANDROID ALIASES ###

  # hg aliases
  alias jfs="jf submit -s"
  jedi_land() { jf sync && jf land --mode jedi --bypass-land-issues "$1" }

  # used to lint/typecheck python code and then amend the current commit
  alias hgas="al && pyr && hg amend && jf submit && chime"
  hgcs() { al && pyr && hg commit -m "$1" && jf submit && chime }

  alias clean_wd="hg revert --all && hg purge"
  clean_ssd() { rm -rf ~/.hgcache/* && cd ~/fbsource && buck clean }

else
  alias c="code"
  alias ci="code-insiders"
fi

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

# ------------------------------------------------------------------------------
# | Search and Find                                                            |
# ------------------------------------------------------------------------------

# super-grep ;)
alias sgrep='grep -R -n -H -C 5 --exclude-dir={.git,.svn,CVS} '

# search in files (with fallback)
if which ack-grep >/dev/null 2>&1; then
  alias ack=ack-grep

  alias afind="ack-grep -iH"
else
  alias afind="ack -iH"
fi

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

alias lt="lsd --tree"
# list all files colorized in long format
alias l="lsd -lhF $COLORFLAG"
# list all files with directories
alias ldir="l -R"
# Show hidden files
alias l.="lsd -dlhF .* $COLORFLAG"
alias ldot="l."
# use colors
alias ls="lsd -F $COLORFLAG"
# display only files & dir in a v-aling view
alias l1="lsd -1 $COLORFLAG"
# displays all files and directories in detail
alias la="lsd -laFh $COLORFLAG"
# displays all files and directories in detail (without "." and without "..")
# alias lA="exa -lAFh $COLORFLAG"
alias lsa="la"
# displays all files and directories in detail with newest-files at bottom
# alias lr="exa -laFhtr $COLORFLAG"
# show last 10 recently changed files
alias lt="lsd -altr | grep -v '^d' | tail -n 10"
# show files and directories (also in sub-dir) that was touched in the last hour
alias lf="find ./* -ctime -1 | xargs ls -ltr $COLORFLAG"
# displays files and directories in detail
alias ll="lsd -lFh --group-directories-first $COLORFLAG"
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
alias gcma="git checkout main"
alias gcmas="git checkout master"
alias gpfix="git a; git com 'fix'; git push"
