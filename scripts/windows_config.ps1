#Requires -Version 5.1
<#
.SYNOPSIS
    Windows Dev Setup Script

.DESCRIPTION
    Configures a Windows machine to match the reference setup.
    Assumes Git, Windows Terminal, and VSCode are already installed.

    Run as Administrator from a new terminal after cloning dotfiles:

        git clone https://github.com/markzuber/dotfiles $HOME\dotfiles
        pwsh -File $HOME\dotfiles\scripts\windows_config.ps1

    Re-running is safe — all steps are idempotent.
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Write-Host "=== Windows Dev Setup ===" -ForegroundColor Cyan
Write-Host ""

$DOTFILES_DIR = "$HOME\dotfiles"

# -----------------------------------------------------------------------------
# Helpers
# -----------------------------------------------------------------------------

function Write-Step($msg) {
    Write-Host ">>> $msg" -ForegroundColor Green
}

function Command-Exists($cmd) {
    $null -ne (Get-Command $cmd -ErrorAction SilentlyContinue)
}

function Make-Link($target, $linkName) {
    $linkDir = Split-Path $linkName -Parent
    if ($linkDir -and -not (Test-Path $linkDir)) {
        New-Item -ItemType Directory -Path $linkDir -Force | Out-Null
    }
    if (Test-Path $linkName) {
        Remove-Item $linkName -Force -Recurse
    }
    New-Item -ItemType SymbolicLink -Path $linkName -Target $target -Force | Out-Null
}

function Winget-Install($id, $label) {
    $name = if ($label) { $label } else { $id }
    $installed = winget list --id $id --exact --accept-source-agreements 2>$null | Select-String $id
    if ($installed) {
        Write-Step "$name already installed"
    } else {
        Write-Step "Installing $name..."
        winget install --id $id --exact --silent --accept-package-agreements --accept-source-agreements
    }
}

function Install-PsModule($name) {
    if (Get-Module -ListAvailable -Name $name) {
        Write-Step "PS module $name already installed"
    } else {
        Write-Step "Installing PS module $name..."
        Install-Module -Name $name -Scope CurrentUser -Force -AllowClobber -SkipPublisherCheck
    }
}

function Install-FontFile($fontPath) {
    $fontName = [System.IO.Path]::GetFileName($fontPath)
    $dest = "C:\Windows\Fonts\$fontName"
    if (Test-Path $dest) {
        Write-Step "Font $fontName already installed"
        return
    }
    Write-Step "Installing font $fontName..."
    Copy-Item $fontPath $dest -Force
    $regPath = 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts'
    $regName = [System.IO.Path]::GetFileNameWithoutExtension($fontName) + " (TrueType)"
    Set-ItemProperty -Path $regPath -Name $regName -Value $fontName -Force
}

# -----------------------------------------------------------------------------
# Admin check
# -----------------------------------------------------------------------------

$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(
    [Security.Principal.WindowsBuiltInRole]::Administrator
)
if (-not $isAdmin) {
    Write-Warning "This script must be run as Administrator (symlinks, font install, PowerToys config)."
    Write-Warning "Right-click PowerShell → 'Run as administrator', then re-run."
    exit 1
}

# -----------------------------------------------------------------------------
# Execution policy
# -----------------------------------------------------------------------------

Write-Step "Setting execution policy..."
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force

# -----------------------------------------------------------------------------
# PowerShell 7
# -----------------------------------------------------------------------------

Winget-Install 'Microsoft.PowerShell' 'PowerShell 7'

# -----------------------------------------------------------------------------
# Shell tools via winget
# (small CLI utilities the profile depends on)
# -----------------------------------------------------------------------------

Winget-Install 'JanDeDobbeleer.OhMyPosh'  'Oh My Posh'
Winget-Install 'junegunn.fzf'              'fzf'
Winget-Install 'sharkdp.bat'               'bat'
Winget-Install 'lsd-rs.lsd'                'lsd'
Winget-Install 'BurntSushi.ripgrep.MSVC'   'ripgrep'
Winget-Install 'ajeetdsouza.zoxide'        'zoxide'

# Refresh PATH so the tools above are available later in this session
$env:Path = [System.Environment]::GetEnvironmentVariable('Path', 'Machine') + ';' +
            [System.Environment]::GetEnvironmentVariable('Path', 'User')

# -----------------------------------------------------------------------------
# Fonts — ComicShannsMono Nerd Font
# -----------------------------------------------------------------------------

Write-Step "Installing ComicShannsMono Nerd Font..."

# Seed the regular weight from dotfiles
$singleFont = "$DOTFILES_DIR\fonts\ComicShannsNerdFont-Regular.ttf"
if (Test-Path $singleFont) {
    Install-FontFile $singleFont
}

# Install the full family (Mono + Propo variants) via oh-my-posh
if (Command-Exists 'oh-my-posh') {
    oh-my-posh font install ComicShannsMono
} else {
    Write-Warning "oh-my-posh not in PATH yet. After setup, run: oh-my-posh font install ComicShannsMono"
}

# -----------------------------------------------------------------------------
# PowerShell modules
# -----------------------------------------------------------------------------

Write-Step "Installing PowerShell modules..."
Install-Module -Name PowerShellGet -Scope CurrentUser -Force -AllowClobber -ErrorAction SilentlyContinue

foreach ($mod in @('PSReadLine', 'posh-git', 'Terminal-Icons', 'PSFzf', 'z')) {
    Install-PsModule $mod
}

# -----------------------------------------------------------------------------
# PowerShell profile symlinks (PS7 + PS5)
# -----------------------------------------------------------------------------

Write-Step "Linking PowerShell profile..."

$ps7Dir = "$HOME\Documents\PowerShell"
$ps5Dir = "$HOME\Documents\WindowsPowerShell"
New-Item -ItemType Directory -Path $ps7Dir -Force | Out-Null
New-Item -ItemType Directory -Path $ps5Dir -Force | Out-Null
Make-Link "$DOTFILES_DIR\powershell\Microsoft.PowerShell_profile.ps1" "$ps7Dir\Microsoft.PowerShell_profile.ps1"
Make-Link "$DOTFILES_DIR\powershell\Microsoft.PowerShell_profile.ps1" "$ps5Dir\Microsoft.PowerShell_profile.ps1"

# -----------------------------------------------------------------------------
# Dotfile symlinks
# -----------------------------------------------------------------------------

Write-Step "Linking dotfiles..."

Make-Link "$DOTFILES_DIR\git\.gitconfig"           "$HOME\.gitconfig"
Make-Link "$DOTFILES_DIR\editorconfig\.editorconfig" "$HOME\.editorconfig"
Make-Link "$DOTFILES_DIR\nvim\.config\nvim"        "$env:LOCALAPPDATA\nvim"
Make-Link "$DOTFILES_DIR\ghostty\.config\ghostty\config_windows" "$env:APPDATA\ghostty\config"
Make-Link "$DOTFILES_DIR\claude\settings.json"     "$HOME\.claude\settings.json"

# VSCode settings
$vsSrc = "$DOTFILES_DIR\vscode\settings.json"
Make-Link $vsSrc "$env:APPDATA\Code\User\settings.json"
Make-Link $vsSrc "$env:APPDATA\Code - Insiders\User\settings.json"

# Windows Terminal settings
$wtDir = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState"
if (Test-Path $wtDir) {
    Make-Link "$DOTFILES_DIR\windows-terminal\settings.json" "$wtDir\settings.json"
} else {
    Write-Warning "Windows Terminal settings dir not found — open Windows Terminal once, then re-run this script."
}


# -----------------------------------------------------------------------------
# VSCode extensions
# -----------------------------------------------------------------------------

Write-Step "Installing VSCode extensions..."
foreach ($ext in @('rust-lang.rust-analyzer', 'PKief.material-icon-theme', 'PKief.material-product-icons')) {
    $already = code --list-extensions 2>$null | Where-Object { $_ -eq $ext }
    if ($already) {
        Write-Step "  $ext already installed"
    } else {
        Write-Step "  Installing $ext..."
        code --install-extension $ext 2>$null
    }
}

# -----------------------------------------------------------------------------
# PowerToys: CapsLock → Ctrl
# -----------------------------------------------------------------------------

Write-Step "Configuring PowerToys Keyboard Manager (CapsLock → Ctrl)..."

$kbDir = "$env:LOCALAPPDATA\Microsoft\PowerToys\Keyboard Manager"
New-Item -ItemType Directory -Path $kbDir -Force | Out-Null

# VK_CAPITAL = 20, VK_CONTROL = 17
@{
    remapKeys = @{
        inProcess = @(@{
            originalAttributes     = 0
            originalVirtualKeyCode = 20
            newAttributes          = 0
            newVirtualKeyCode      = 17
            targetApp              = ""
        })
    }
    remapShortcuts = @{ global = @(); appSpecific = @() }
} | ConvertTo-Json -Depth 10 | Set-Content -Path "$kbDir\default.json" -Encoding UTF8

Write-Step "CapsLock→Ctrl config written. Enable Keyboard Manager inside the PowerToys app."

# -----------------------------------------------------------------------------
# Misc
# -----------------------------------------------------------------------------

New-Item -ItemType Directory -Path "$HOME\repos" -Force | Out-Null

# -----------------------------------------------------------------------------
# Done
# -----------------------------------------------------------------------------

Write-Host ""
Write-Host "=== Done! ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "  1. Open a new terminal — PowerShell 7 should load with Oh My Posh." -ForegroundColor White
Write-Host "  2. Open PowerToys → Keyboard Manager → enable it (CapsLock→Ctrl)." -ForegroundColor White
Write-Host "  3. If the font picker appeared, select ComicShannsMono and confirm." -ForegroundColor White
Write-Host "     Otherwise run: oh-my-posh font install ComicShannsMono" -ForegroundColor Gray
Write-Host ""
