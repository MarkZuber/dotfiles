#!/usr/bin/env bash
# Set up this machine: detect the OS and run its script from scripts/setup/, which installs
# tools and then links the config into place with scripts/link-dotfiles.sh.
#
#   machine_setup.sh            detect the OS and run the matching setup script
#   machine_setup.sh <name>     run scripts/setup/<name>.sh instead, e.g. bazzite_distrobox_devmate
#
# Safe to rerun on macOS and CachyOS to pick up newly added tools: their scripts skip anything
# already installed.

set -euo pipefail

SETUP="$(cd "$(dirname "$0")" && pwd)/setup"

if [[ $# -gt 0 ]]; then
  script="$SETUP/$1.sh"
  [[ -f "$script" ]] || { echo "no such setup script: ${script#"$SETUP/"}" >&2; ls "$SETUP" >&2; exit 2; }
  exec bash "$script"
fi

case "$(uname -s)" in
  Darwin)
    exec bash "$SETUP/mac_config.sh"
    ;;
  Linux)
    id=""
    [[ -r /etc/os-release ]] && id="$(. /etc/os-release && echo "${ID:-}")"
    case "$id" in
      cachyos) exec bash "$SETUP/cachyos_config.sh" ;;
      bazzite) exec bash "$SETUP/bazzite_config_immutable.sh" ;;
      *)
        echo "no setup script for Linux distro '${id:-unknown}'; pass one by name:" >&2
        ls "$SETUP" >&2
        exit 2
        ;;
    esac
    ;;
  MINGW*|MSYS*|CYGWIN*)
    exec powershell.exe -NoProfile -ExecutionPolicy Bypass -File "$(cygpath -w "$SETUP/windows_config.ps1")"
    ;;
  *)
    echo "unsupported OS: $(uname -s)" >&2
    exit 2
    ;;
esac
