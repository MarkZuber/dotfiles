#Requires -Version 5.1
<#
.SYNOPSIS
    Windows Dev Setup Script

.DESCRIPTION
    Sets up a development environment on Windows.

    First:
        cd ~
        git clone https://github.com/markzuber/dotfiles
    Then run (as Administrator):
        ~\dotfiles\scripts\windows_config.ps1
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Write-Host "=== Windows Dev Setup ===" -ForegroundColor Cyan
Write-Host ""

$DOTFILES_DIR = "$HOME\dotfiles"

# -----------------------------------------------------------------------------
# Helper functions
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

function Scoop-Install($pkg) {
    if (scoop list $pkg 2>$null | Select-String $pkg) {
        Write-Step "$pkg (scoop) already installed"
    } else {
        Write-Step "Installing $pkg (scoop)..."
        scoop install $pkg
    }
}

function Install-PsModule($name) {
    if (Get-Module -ListAvailable -Name $name) {
        Write-Step "PowerShell module $name already installed"
    } else {
        Write-Step "Installing PowerShell module $name..."
        Install-Module -Name $name -Scope CurrentUser -Force -AllowClobber -SkipPublisherCheck
    }
}

# -----------------------------------------------------------------------------
# Admin check
# -----------------------------------------------------------------------------

$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(
    [Security.Principal.WindowsBuiltInRole]::Administrator
)
if (-not $isAdmin) {
    Write-Warning "This script must be run as Administrator for symlink creation and Windows feature installation."
    Write-Warning "Please re-run from an elevated PowerShell prompt."
    exit 1
}

# -----------------------------------------------------------------------------
# Execution policy
# -----------------------------------------------------------------------------

Write-Step "Setting PowerShell execution policy..."
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force

# -----------------------------------------------------------------------------
# Windows Features for Docker + Hyper-V
# -----------------------------------------------------------------------------

Write-Step "Enabling Windows features for Docker (Containers, Hyper-V, WSL2)..."

$features = @(
    'Microsoft-Hyper-V-All',
    'Containers',
    'Microsoft-Windows-Subsystem-Linux',
    'VirtualMachinePlatform'
)

$rebootNeeded = $false
foreach ($feature in $features) {
    $state = Get-WindowsOptionalFeature -Online -FeatureName $feature -ErrorAction SilentlyContinue
    if ($state -and $state.State -ne 'Enabled') {
        Write-Step "Enabling Windows feature: $feature"
        $result = Enable-WindowsOptionalFeature -Online -FeatureName $feature -NoRestart -All
        if ($result.RestartNeeded) { $rebootNeeded = $true }
    } else {
        Write-Step "Windows feature $feature already enabled"
    }
}

if ($rebootNeeded) {
    Write-Warning "Some Windows features require a reboot. Please reboot and re-run this script to continue."
    Write-Warning "Press Enter to continue without rebooting (some installs may fail), or Ctrl+C to stop."
    Read-Host
}

# -----------------------------------------------------------------------------
# winget
# -----------------------------------------------------------------------------

if (-not (Command-Exists 'winget')) {
    Write-Step "Installing winget (App Installer)..."
    # winget ships with Windows 11 and recent Windows 10. If missing, direct user to install it.
    Write-Warning "winget not found. Install 'App Installer' from the Microsoft Store, then re-run."
    exit 1
} else {
    Write-Step "winget already available: $(winget --version)"
    Write-Step "Updating winget sources..."
    winget source update --accept-source-agreements 2>$null
}

# -----------------------------------------------------------------------------
# Scoop (secondary package manager for tools not in winget)
# -----------------------------------------------------------------------------

Write-Step "Installing Scoop..."
if (-not (Command-Exists 'scoop')) {
    Invoke-RestMethod -Uri 'https://get.scoop.sh' | Invoke-Expression
    # Add extras bucket
    scoop bucket add extras
    scoop bucket add nerd-fonts
} else {
    Write-Step "Scoop already installed"
    scoop update
}

# -----------------------------------------------------------------------------
# CLI tools via winget
# -----------------------------------------------------------------------------

Write-Step "Installing CLI tools..."

# Install PowerShell 7 first — it's the shell used everywhere (Ghostty, Windows Terminal,
# profile symlinks). The built-in Windows PowerShell 5.1 is only used to run this script.
Winget-Install 'Microsoft.PowerShell' 'PowerShell 7 (pwsh)'

# Refresh PATH so pwsh.exe is available for the rest of this session
$env:Path = [System.Environment]::GetEnvironmentVariable('Path', 'Machine') + ';' +
            [System.Environment]::GetEnvironmentVariable('Path', 'User')

$wingetPackages = @(
    @{ id = 'Git.Git';                     label = 'git' },
    @{ id = 'GitHub.GitLFS';               label = 'git-lfs' },
    @{ id = 'dandavison.delta';            label = 'git-delta' },
    @{ id = 'Neovim.Neovim';              label = 'neovim' },
    @{ id = 'junegunn.fzf';               label = 'fzf' },
    @{ id = 'BurntSushi.ripgrep.MSVC';    label = 'ripgrep' },
    @{ id = 'sharkdp.bat';                label = 'bat' },
    @{ id = 'lsd-rs.lsd';                 label = 'lsd' },
    @{ id = 'eza-community.eza';          label = 'eza' },
    @{ id = 'sharkdp.fd';                 label = 'fd' },
    @{ id = 'Fastfetch-cli.Fastfetch';    label = 'fastfetch' },
    @{ id = 'JernejSimoncic.Wget';        label = 'wget' },
    @{ id = 'Kitware.CMake';              label = 'cmake' },
    @{ id = 'OpenJS.NodeJS.LTS';          label = 'node' },
    @{ id = 'Python.Python.3.13';         label = 'python 3.13' },
    @{ id = 'JesseDuffield.lazygit';      label = 'lazygit' },
    @{ id = 'GitHub.cli';                 label = 'gh' },
    @{ id = 'jqlang.jq';                  label = 'jq' },
    @{ id = 'ajeetdsouza.zoxide';         label = 'zoxide' },
    @{ id = 'Rustlang.Rustup';            label = 'rustup/rust' },
    @{ id = 'astral-sh.uv';              label = 'uv' },
    @{ id = 'Amazon.AWSCLI';              label = 'aws cli' },
    @{ id = 'glab.glab';                  label = 'glab' }
)

foreach ($pkg in $wingetPackages) {
    Winget-Install $pkg.id $pkg.label
}

# Refresh PATH so new tools are available in this session
$env:Path = [System.Environment]::GetEnvironmentVariable('Path', 'Machine') + ';' +
            [System.Environment]::GetEnvironmentVariable('Path', 'User')

# tree-sitter-cli and television via npm/cargo (after node/rust are installed)
Write-Step "Installing tree-sitter-cli via npm..."
npm install -g tree-sitter-cli 2>$null

Write-Step "Installing television (tv) via cargo..."
if (-not (Command-Exists 'tv')) {
    cargo install television 2>$null
} else {
    Write-Step "television already installed"
}

# Fun terminal tools via Scoop
Write-Step "Installing terminal fun tools via Scoop..."
foreach ($pkg in @('figlet', 'cowsay', 'lolcat', 'fortune')) {
    Scoop-Install $pkg
}

# luarocks via Scoop (for Neovim plugins)
Scoop-Install 'luarocks'

# -----------------------------------------------------------------------------
# Apps via winget
# -----------------------------------------------------------------------------

Write-Step "Installing apps..."

$appPackages = @(
    @{ id = 'Ghostty.Ghostty';                         label = 'Ghostty' },
    @{ id = 'Microsoft.WindowsTerminal';               label = 'Windows Terminal' },
    @{ id = 'Microsoft.VisualStudioCode';              label = 'Visual Studio Code' },
    @{ id = 'Google.Chrome';                           label = 'Google Chrome' },
    @{ id = 'Discord.Discord';                         label = 'Discord' },
    @{ id = 'GitHub.GitHubDesktop';                    label = 'GitHub Desktop' },
    @{ id = 'Notion.Notion';                           label = 'Notion' },
    @{ id = 'Zoom.Zoom';                               label = 'Zoom' },
    @{ id = 'OpenWhisperSystems.Signal';               label = 'Signal' },
    @{ id = 'Spotify.Spotify';                         label = 'Spotify' },
    @{ id = 'SlackTechnologies.Slack';                 label = 'Slack' },
    @{ id = 'Google.FlutterSDK';                       label = 'Flutter SDK' },
    @{ id = 'Docker.DockerDesktop';                    label = 'Docker Desktop' },
    @{ id = 'Microsoft.PowerToys';                     label = 'PowerToys' },
    @{ id = 'Microsoft.GitCredentialManager';          label = 'Git Credential Manager' },
    @{ id = 'LogitechG.LGHUB';                         label = 'Logitech G Hub' }
)

foreach ($pkg in $appPackages) {
    Winget-Install $pkg.id $pkg.label
}

# -----------------------------------------------------------------------------
# Visual Studio 2022 Community with C++ and base build tools
# -----------------------------------------------------------------------------

Write-Step "Installing Visual Studio 2022 Community with C++ workload..."

$vsInstalled = winget list --id 'Microsoft.VisualStudio.2022.Community' --exact 2>$null | Select-String 'VisualStudio'
if ($vsInstalled) {
    Write-Step "Visual Studio 2022 Community already installed"
} else {
    Write-Step "Installing Visual Studio 2022 Community (this will take a while)..."
    winget install --id 'Microsoft.VisualStudio.2022.Community' --exact --silent `
        --accept-package-agreements --accept-source-agreements `
        --override ('--wait --quiet --norestart --includeRecommended ' +
                    '--add Microsoft.VisualStudio.Workload.NativeDesktop ' +
                    '--add Microsoft.VisualStudio.Workload.NativeCrossPlat ' +
                    '--add Microsoft.VisualStudio.Workload.VCTools ' +
                    '--add Microsoft.VisualStudio.Component.VC.Tools.x86.x64 ' +
                    '--add Microsoft.VisualStudio.Component.Windows11SDK.22621')
}

# -----------------------------------------------------------------------------
# Claude CLI
# -----------------------------------------------------------------------------

Write-Step "Installing Claude CLI..."
if (-not (Command-Exists 'claude')) {
    $claudeInstall = (Invoke-RestMethod -Uri 'https://claude.ai/install.ps1' -ErrorAction SilentlyContinue)
    if ($claudeInstall) {
        Invoke-Expression $claudeInstall
    } else {
        # Fallback: install via npm
        npm install -g @anthropic-ai/claude-code 2>$null
    }
} else {
    Write-Step "Claude CLI already installed"
}

# -----------------------------------------------------------------------------
# nvm-windows and Node.js
# -----------------------------------------------------------------------------

Write-Step "Installing nvm-windows..."
Winget-Install 'CoreyButler.NVMforWindows' 'nvm-windows'

# Refresh PATH
$env:Path = [System.Environment]::GetEnvironmentVariable('Path', 'Machine') + ';' +
            [System.Environment]::GetEnvironmentVariable('Path', 'User')

if (Command-Exists 'nvm') {
    Write-Step "Installing Node.js LTS via nvm..."
    nvm install lts
    nvm use lts
}

Write-Step "Installing global npm packages..."
foreach ($pkg in @('typescript', 'ts-node', 'prettier', 'eslint')) {
    $installed = npm list -g $pkg 2>$null | Select-String $pkg
    if (-not $installed) {
        npm install -g $pkg
    } else {
        Write-Step "npm package $pkg already installed"
    }
}

# -----------------------------------------------------------------------------
# Rust
# -----------------------------------------------------------------------------

Write-Step "Configuring Rust..."
# Refresh PATH so rustup/cargo are visible
$env:Path = [System.Environment]::GetEnvironmentVariable('Path', 'Machine') + ';' +
            [System.Environment]::GetEnvironmentVariable('Path', 'User')

if (Command-Exists 'rustup') {
    Write-Step "Rust already installed: $(rustc --version 2>$null)"
    rustup update
} else {
    Write-Step "Run rustup-init.exe from the installed rustup to complete Rust setup."
}

# -----------------------------------------------------------------------------
# Fonts (install to Windows Fonts directory)
# -----------------------------------------------------------------------------

Write-Step "Installing fonts..."
$fontsDir = "$env:LOCALAPPDATA\Microsoft\Windows\Fonts"
$systemFontsDir = "$env:SystemRoot\Fonts"
$userFontsRegPath = 'HKCU:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts'

function Install-Font($zipPath, $label) {
    if (-not (Test-Path $zipPath)) {
        Write-Step "$label font zip not found, skipping"
        return
    }
    Write-Step "Installing $label font..."
    $tempDir = Join-Path $env:TEMP "fonts_$label"
    Expand-Archive -Path $zipPath -DestinationPath $tempDir -Force
    Get-ChildItem $tempDir -Recurse -Include '*.ttf', '*.otf' | ForEach-Object {
        $dest = Join-Path $fontsDir $_.Name
        Copy-Item $_.FullName $dest -Force
        $fontName = $_.BaseName
        if (-not (Get-ItemProperty $userFontsRegPath -Name "$fontName (TrueType)" -ErrorAction SilentlyContinue)) {
            New-ItemProperty -Path $userFontsRegPath -Name "$fontName (TrueType)" -Value $dest -PropertyType String -Force | Out-Null
        }
    }
    Remove-Item $tempDir -Recurse -Force
}

New-Item -ItemType Directory -Path $fontsDir -Force | Out-Null
Install-Font "$DOTFILES_DIR\fonts\FiraCode.zip"         "FiraCode"
Install-Font "$DOTFILES_DIR\fonts\CascadiaCode.zip"     "CascadiaCode"
Install-Font "$DOTFILES_DIR\fonts\comic-shanns-mono-v1.3.0.zip" "ComicShanns"

# Also install ComicShanns TTF if present
$comicShannsttf = "$DOTFILES_DIR\fonts\ComicShannsNerdFont-Regular.ttf"
if (Test-Path $comicShannsttf) {
    $dest = Join-Path $fontsDir "ComicShannsNerdFont-Regular.ttf"
    Copy-Item $comicShannsttf $dest -Force
    New-ItemProperty -Path $userFontsRegPath -Name "ComicShanns Nerd Font Regular (TrueType)" -Value $dest -PropertyType String -Force | Out-Null
}

# Install Nerd Font via Scoop for reliable access
Write-Step "Installing CascadiaCode Nerd Font via Scoop..."
scoop install nerd-fonts/CascadiaCode 2>$null

# -----------------------------------------------------------------------------
# PowerShell modules
# -----------------------------------------------------------------------------

Write-Step "Installing PowerShell modules..."

# Update PowerShellGet first
Install-Module -Name PowerShellGet -Scope CurrentUser -Force -AllowClobber -ErrorAction SilentlyContinue

$psModules = @(
    'posh-git',
    'Terminal-Icons',
    'PSFzf',
    'z',
    'PSReadLine'
)

foreach ($mod in $psModules) {
    Install-PsModule $mod
}

# oh-my-posh via winget (official distribution)
Winget-Install 'JanDeDobbeleer.OhMyPosh' 'oh-my-posh'

# -----------------------------------------------------------------------------
# PowerShell profile
# -----------------------------------------------------------------------------

Write-Step "Linking PowerShell profile..."

# PS7 profile location
$ps7ProfileDir = "$HOME\Documents\PowerShell"
$ps7ProfilePath = "$ps7ProfileDir\Microsoft.PowerShell_profile.ps1"

# Windows PowerShell 5.1 profile
$ps5ProfileDir = "$HOME\Documents\WindowsPowerShell"
$ps5ProfilePath = "$ps5ProfileDir\Microsoft.PowerShell_profile.ps1"

New-Item -ItemType Directory -Path $ps7ProfileDir -Force | Out-Null
New-Item -ItemType Directory -Path $ps5ProfileDir -Force | Out-Null

Make-Link "$DOTFILES_DIR\powershell\Microsoft.PowerShell_profile.ps1" $ps7ProfilePath
Make-Link "$DOTFILES_DIR\powershell\Microsoft.PowerShell_profile.ps1" $ps5ProfilePath

# -----------------------------------------------------------------------------
# Symlink dotfiles
# -----------------------------------------------------------------------------

Write-Step "Linking dotfiles..."

# git config
Make-Link "$DOTFILES_DIR\git\.gitconfig" "$HOME\.gitconfig"

# editorconfig
Make-Link "$DOTFILES_DIR\editorconfig\.editorconfig" "$HOME\.editorconfig"

# nvim
Make-Link "$DOTFILES_DIR\nvim\.config\nvim" "$env:LOCALAPPDATA\nvim"

# ghostty config (Windows path: %APPDATA%\ghostty\config)
# Use config_windows, which includes the shared base config and overrides shell settings for Windows.
Make-Link "$DOTFILES_DIR\ghostty\.config\ghostty\config_windows" "$env:APPDATA\ghostty\config"

# claude settings
Make-Link "$DOTFILES_DIR\claude\settings.json" "$HOME\.claude\settings.json"

# VSCode settings
$vscodeSettingsSrc = "$DOTFILES_DIR\vscode\settings.json"
Make-Link $vscodeSettingsSrc "$env:APPDATA\Code\User\settings.json"
Make-Link $vscodeSettingsSrc "$env:APPDATA\Code - Insiders\User\settings.json"

# Windows Terminal settings
$wtSettingsDir = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState"
if (Test-Path $wtSettingsDir) {
    Make-Link "$DOTFILES_DIR\windows-terminal\settings.json" "$wtSettingsDir\settings.json"
} else {
    Write-Step "Windows Terminal package dir not found; copy $DOTFILES_DIR\windows-terminal\settings.json manually if needed"
}

# -----------------------------------------------------------------------------
# Git configuration
# -----------------------------------------------------------------------------

Write-Step "Configuring git credentials (wincred)..."
git config --file "$HOME\.gitconfig-local" credential.helper manager

# -----------------------------------------------------------------------------
# VSCode extensions
# -----------------------------------------------------------------------------

Write-Step "Installing VSCode extensions..."
$vscodeExtensions = @(
    'rust-lang.rust-analyzer',
    'PKief.material-icon-theme',
    'PKief.material-product-icons'
)
foreach ($ext in $vscodeExtensions) {
    $installed = code --list-extensions 2>$null | Where-Object { $_ -eq $ext }
    if (-not $installed) {
        code --install-extension $ext 2>$null
    } else {
        Write-Step "VSCode extension $ext already installed"
    }
}

# -----------------------------------------------------------------------------
# Docker: configure for Windows containers
# -----------------------------------------------------------------------------

Write-Step "Configuring Docker for Windows containers..."

$dockerDaemonConfig = "$env:ProgramData\Docker\config\daemon.json"
$dockerDaemonDir = Split-Path $dockerDaemonConfig -Parent

if (-not (Test-Path $dockerDaemonDir)) {
    New-Item -ItemType Directory -Path $dockerDaemonDir -Force | Out-Null
}

# Write daemon.json enabling both Linux and Windows container support
# To switch to Windows containers: right-click Docker tray → Switch to Windows containers
# Or run: & "C:\Program Files\Docker\Docker\DockerCli.exe" -SwitchWindowsEngine
if (-not (Test-Path $dockerDaemonConfig)) {
    @{
        'experimental' = $true
        'features'     = @{ 'buildkit' = $true }
    } | ConvertTo-Json | Set-Content -Path $dockerDaemonConfig -Encoding UTF8
    Write-Step "Docker daemon.json created with buildkit enabled"
} else {
    Write-Step "Docker daemon.json already exists"
}

Write-Step "NOTE: To build Windows containers, right-click the Docker tray icon and select 'Switch to Windows containers'"

# -----------------------------------------------------------------------------
# PowerToys: CapsLock → Ctrl via Keyboard Manager
# -----------------------------------------------------------------------------

Write-Step "Configuring PowerToys Keyboard Manager (CapsLock → Ctrl)..."

$powerToysKbDir = "$env:LOCALAPPDATA\Microsoft\PowerToys\Keyboard Manager"
$powerToysKbConfig = "$powerToysKbDir\default.json"

New-Item -ItemType Directory -Path $powerToysKbDir -Force | Out-Null

# VK_CAPITAL = 0x14 (20), VK_LCONTROL = 0xA2 (162) / VK_CONTROL = 0x11 (17)
# PowerToys Keyboard Manager JSON format (v0.70+)
$kbConfig = @{
    remapKeys = @{
        inProcess = @(
            @{
                originalAttributes      = 0
                originalVirtualKeyCode  = 20    # VK_CAPITAL (CapsLock)
                newAttributes           = 0
                newVirtualKeyCode       = 17    # VK_CONTROL (Ctrl)
                targetApp               = ""
            }
        )
    }
    remapShortcuts = @{
        global      = @()
        appSpecific = @()
    }
}

$kbConfig | ConvertTo-Json -Depth 10 | Set-Content -Path $powerToysKbConfig -Encoding UTF8
Write-Step "PowerToys Keyboard Manager configured: CapsLock → Ctrl"
Write-Step "NOTE: PowerToys must be running for the remapping to take effect. Enable Keyboard Manager in PowerToys settings."

# -----------------------------------------------------------------------------
# Repos directory
# -----------------------------------------------------------------------------

Write-Step "Setting up repos directory..."
New-Item -ItemType Directory -Path "$HOME\repos" -Force | Out-Null

# -----------------------------------------------------------------------------
# Final notes
# -----------------------------------------------------------------------------

Write-Host ""
Write-Host "=== Setup Complete ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "Installed tools:"
Write-Host "  - CLI: git, neovim, fzf, ripgrep, bat, lsd, eza, lazygit, gh, zoxide"
Write-Host "  - Languages: Node.js (LTS), Rust (via rustup), Python 3.13"
Write-Host "  - PS modules: oh-my-posh, posh-git, PSReadLine, Terminal-Icons, PSFzf, z"
Write-Host "  - Apps: Ghostty, Windows Terminal, VSCode, Chrome, Discord, GitHub Desktop,"
Write-Host "          Notion, Zoom, Signal, Spotify, Slack, Flutter SDK,"
Write-Host "          Docker Desktop, PowerToys"
Write-Host "  - VS 2022 Community with C++ (NativeDesktop + VCTools workloads)"
Write-Host ""
Write-Host "Post-setup tasks:"
Write-Host "  1. PowerShell 7 (pwsh.exe) is now installed — open a new pwsh window or Ghostty."
Write-Host "     Windows PowerShell 5.1 (powershell.exe) is still the Windows default but is"
Write-Host "     only used for legacy compatibility. Both share the same profile from dotfiles."
Write-Host "  2. Run 'oh-my-posh font install' if fonts need additional setup"
Write-Host "  3. CapsLock → Ctrl: ensure PowerToys is running and Keyboard Manager is enabled"
Write-Host "     PowerToys → Keyboard Manager → Enable → verify the CapsLock mapping"
Write-Host "  4. Docker Windows containers:"
Write-Host "     Right-click Docker tray icon → Switch to Windows containers"
Write-Host "  5. Flutter: run 'flutter doctor' to complete SDK setup"
Write-Host "  6. VSCode font settings already linked from dotfiles"
Write-Host "  7. Ghostty config linked (config_windows includes base config + Windows shell overrides)"
Write-Host "  8. Git credentials use Windows Credential Manager (already configured)"
Write-Host ""

if (Command-Exists 'fastfetch') {
    fastfetch
}
