# PowerShell Profile
# ==================
# Sourced by both PS7 and Windows PowerShell 5.1 (symlinked from dotfiles).
#
# Equivalent to zsh/.zshrc on macOS.
# Additional per-machine config: ~/Documents/PowerShell/profile.local.ps1

$DOTFILES_DIR = "$HOME\dotfiles"

# -----------------------------------------------------------------------------
# Oh My Posh (equivalent to Powerlevel10k)
# -----------------------------------------------------------------------------

if (Get-Command oh-my-posh -ErrorAction SilentlyContinue) {
    # Use powerlevel10k_rainbow theme — closest equivalent to the p10k setup on macOS.
    # To list available themes: oh-my-posh config export --output ~/omp-themes
    # To browse interactively:  Get-PoshThemes
    $ompTheme = "$env:POSH_THEMES_PATH\powerlevel10k_rainbow.omp.json"
    if (-not (Test-Path $ompTheme)) {
        $ompTheme = "$env:POSH_THEMES_PATH\agnoster.omp.json"
    }
    oh-my-posh init pwsh --config $ompTheme | Invoke-Expression
}

# -----------------------------------------------------------------------------
# posh-git (git status in prompt + git tab completion)
# -----------------------------------------------------------------------------

if (Get-Module -ListAvailable -Name posh-git) {
    Import-Module posh-git
    $GitPromptSettings.EnableStashStatus = $true
}

# -----------------------------------------------------------------------------
# Terminal-Icons (file/folder icons in directory listings, like lsd icons)
# -----------------------------------------------------------------------------

if (Get-Module -ListAvailable -Name Terminal-Icons) {
    Import-Module Terminal-Icons
}

# -----------------------------------------------------------------------------
# PSReadLine — history, autosuggestions, syntax coloring
# Equivalent to: zsh-autosuggestions + zsh-syntax-highlighting + history opts
# -----------------------------------------------------------------------------

if (Get-Module -ListAvailable -Name PSReadLine) {
    Import-Module PSReadLine

    # Prediction from both history and plugins (like zsh-autosuggestions)
    Set-PSReadLineOption -PredictionSource HistoryAndPlugin -ErrorAction SilentlyContinue
    Set-PSReadLineOption -PredictionSource History -ErrorAction SilentlyContinue

    # Show inline suggestion (like zsh-autosuggestions grey text)
    Set-PSReadLineOption -PredictionViewStyle InlineView -ErrorAction SilentlyContinue

    # Up/Down arrow = history prefix search (like zsh history-search-backward/forward)
    Set-PSReadLineKeyHandler -Key UpArrow   -Function HistorySearchBackward
    Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
    Set-PSReadLineOption -HistorySearchCursorMovesToEnd

    # History settings (equivalent to HISTFILE / HISTSIZE / setopt EXTENDED_HISTORY)
    Set-PSReadLineOption -MaximumHistoryCount 10000
    Set-PSReadLineOption -HistoryNoDuplicates          # equivalent to HIST_IGNORE_ALL_DUPS
    Set-PSReadLineOption -HistorySavePath "$HOME\.ps_history"

    # Syntax coloring (equivalent to zsh-syntax-highlighting)
    Set-PSReadLineOption -Colors @{
        Command            = 'Yellow'
        Parameter          = 'Green'
        String             = 'Cyan'
        Operator           = 'Magenta'
        Variable           = 'White'
        Comment            = 'DarkGray'
        Keyword            = 'Blue'
        Error              = 'Red'
        InlinePrediction   = 'DarkGray'
    }

    # Ctrl+r = reverse history search via fzf (if PSFzf available)
    # Ctrl+d to accept inline prediction
    Set-PSReadLineKeyHandler -Chord 'Ctrl+d' -Function AcceptNextSuggestionWord
    Set-PSReadLineKeyHandler -Chord 'Ctrl+e' -Function AcceptSuggestion
}

# -----------------------------------------------------------------------------
# PSFzf — fzf integration (Ctrl+r history, Ctrl+t file picker)
# Equivalent to fzf-tab and fzf plugin in zsh
# -----------------------------------------------------------------------------

if (Get-Module -ListAvailable -Name PSFzf) {
    Import-Module PSFzf
    Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+t'
    Set-PsFzfOption -PSReadlineChordReverseHistory 'Ctrl+r'
}

# -----------------------------------------------------------------------------
# z — directory jumping (equivalent to zoxide / z plugin in zsh)
# -----------------------------------------------------------------------------

if (Get-Module -ListAvailable -Name z) {
    Import-Module z
}

# -----------------------------------------------------------------------------
# zoxide (preferred over z if installed)
# -----------------------------------------------------------------------------

if (Get-Command zoxide -ErrorAction SilentlyContinue) {
    Invoke-Expression (& { (zoxide init powershell | Out-String) })
}

# -----------------------------------------------------------------------------
# Environment variables
# -----------------------------------------------------------------------------

$env:EDITOR = 'nvim'
$env:BAT_THEME = 'gruvbox-dark'
$env:GCM_CREDENTIAL_STORE = 'wincred'

# Add cargo bin to PATH
if (Test-Path "$HOME\.cargo\bin") {
    $env:Path = "$HOME\.cargo\bin;$env:Path"
}

# Add dotfiles scripts to PATH
if (Test-Path "$DOTFILES_DIR\scripts") {
    $env:Path = "$DOTFILES_DIR\scripts;$env:Path"
}

# Flutter
if (Test-Path "$HOME\flutter\bin") {
    $env:Path = "$HOME\flutter\bin;$env:Path"
}

# -----------------------------------------------------------------------------
# Aliases — equivalent to .zshrc aliases
# -----------------------------------------------------------------------------

# Editor
Set-Alias vim nvim
Set-Alias vi nvim

function svim { & sudo nvim @args }

# Navigation
function .. { Set-Location .. }
function ... { Set-Location ..\.. }
function .... { Set-Location ..\..\.. }
function ..... { Set-Location ..\..\..\.. }

# Shell conveniences
function srcz { . $PROFILE }
function viz { nvim $PROFILE }
function repos { Set-Location "$HOME\repos" }
function cdh { Set-Location $HOME }
function cdhome { Set-Location $HOME }

# Clear
Set-Alias cls Clear-Host

# Code
function c { code @args }
function ci { code-insiders @args }

# Git shortcuts (posh-git handles tab completion, these mirror .zshrc aliases)
function glog {
    git log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --branches
}
function gpusho { git push --set-upstream origin (git rev-parse --abbrev-ref HEAD) }
function gcma { git checkout main }
function gcmas { git checkout master }
function gpfix { git add -A; git commit -m 'fix'; git push }
function gdc { git diff --cached }
function gmom { git fetch; git merge origin/main }
function gdm { git diff "main...$(git rev-parse --abbrev-ref HEAD)" }

# ls / lsd aliases
if (Get-Command lsd -ErrorAction SilentlyContinue) {
    function ls { lsd @args }
    function ll { lsd -lhF --group-directories-first @args }
    function la { lsd -laFh @args }
    function l { lsd -lhF @args }
    function l1 { lsd -1 @args }
    function lt { lsd --tree @args }
    function l. { lsd -dlhF .* @args }
    function ldot { lsd -dlhF .* @args }
    function lsa { lsd -laFh @args }
    function llt { lsd -altr @args | Select-Object -Last 10 }
} else {
    function ll { Get-ChildItem -Force @args }
    function la { Get-ChildItem -Force @args }
}

# cat → bat
if (Get-Command bat -ErrorAction SilentlyContinue) {
    function cat { bat --paging=never @args }
    function catp { bat --paging=never --style=plain @args }
}

# ripgrep: hidden files, exclude .git
if (Get-Command rg -ErrorAction SilentlyContinue) {
    function rg { & rg.exe --hidden --glob '!.git' @args }
}

# mkdir always creates parent dirs (like macOS alias mkdir="mkdir -p")
function md { New-Item -ItemType Directory -Path @args -Force }
function rd { Remove-Item -Recurse @args }

# mkdir alias that ensures -p behaviour
function mkdir { New-Item -ItemType Directory -Path @args -Force }

# Which / where
function which { Get-Command @args | Select-Object -ExpandProperty Source }

# Path display
function path { $env:Path -split ';' | Where-Object { $_ } }

# Network
function myip { (Invoke-RestMethod -Uri 'http://ipecho.net/plain') + "`n" }

# Disk/process info
function usage { Get-ChildItem @args | Sort-Object Length -Descending }
function psmem { Get-Process | Sort-Object WorkingSet64 -Descending | Select-Object -First 20 Name, Id, @{N='MemMB';E={[math]::Round($_.WorkingSet64/1MB,1)}} }
function pscpu { Get-Process | Sort-Object CPU -Descending | Select-Object -First 20 Name, Id, CPU }

# Date helpers
function date_iso_8601 { Get-Date -Format 'yyyyMMddTHHmmss' }
function date_clean { Get-Date -Format 'yyyy-MM-dd' }
function date_year { Get-Date -Format 'yyyy' }
function date_time { Get-Date -Format 'HH:mm:ss' }

# Grep equivalent
function sgrep { Select-String -Recurse -Context 5 @args }

# Tree (Windows built-in, or use lsd --tree)
function ltree { lsd --tree @args | less }

# -----------------------------------------------------------------------------
# Docker: switch engine helpers
# -----------------------------------------------------------------------------

function docker-windows {
    & 'C:\Program Files\Docker\Docker\DockerCli.exe' -SwitchWindowsEngine
    Write-Host "Switched to Windows containers" -ForegroundColor Green
}

function docker-linux {
    & 'C:\Program Files\Docker\Docker\DockerCli.exe' -SwitchLinuxEngine
    Write-Host "Switched to Linux containers" -ForegroundColor Green
}

# -----------------------------------------------------------------------------
# Source additional profile scripts
# (drop .ps1 files into ~/dotfiles/powershell/profile.d/ to auto-load them)
# Machine-local overrides go in ~/Documents/PowerShell/profile.local.ps1
# -----------------------------------------------------------------------------

$profileD = "$DOTFILES_DIR\powershell\profile.d"
if (Test-Path $profileD) {
    Get-ChildItem "$profileD\*.ps1" | ForEach-Object { . $_.FullName }
}

$localProfile = "$HOME\Documents\PowerShell\profile.local.ps1"
if (Test-Path $localProfile) {
    . $localProfile
}

$workProfile = "$HOME\Documents\PowerShell\profile.work.ps1"
if (Test-Path $workProfile) {
    . $workProfile
}
