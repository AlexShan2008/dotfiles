#!/bin/sh
# Bootstrap script for dotfiles
#
# Usage:
#   curl -fsLS https://raw.githubusercontent.com/AlexShan2008/dotfiles/main/install.sh | sh
#
# One-shot setup: installs Xcode CLT (macOS), Homebrew, chezmoi, then runs full dotfiles config.
# Prerequisites: macOS, internet connection.

set -e

GITHUB_USER="AlexShan2008"

log() {
  printf '[%s] %s\n' "$1" "$2"
}

# ---------------------------------------------------------------------------
# Xcode Command Line Tools (macOS only, required by Homebrew)
# ---------------------------------------------------------------------------

install_xcode_clt() {
  [ "$(uname -s)" = "Darwin" ] || return 0

  if xcode-select -p >/dev/null 2>&1; then
    log "INFO" "Xcode Command Line Tools already installed, skipping"
    return
  fi

  log "INFO" "Installing Xcode Command Line Tools (required by Homebrew)..."
  log "INFO" "A dialog will appear - click 'Install' and wait for it to complete."
  xcode-select --install

  # Poll until installation completes (timeout 15 minutes)
  max_wait=900
  waited=0
  until xcode-select -p >/dev/null 2>&1; do
    if [ "$waited" -ge "$max_wait" ]; then
      log "ERROR" "Timed out waiting for Xcode CLT. Complete the installation and re-run this script."
      exit 1
    fi
    sleep 5
    waited=$((waited + 5))
  done
  log "INFO" "Xcode Command Line Tools installed"
}

# ---------------------------------------------------------------------------
# Homebrew installer (official method: https://brew.sh)
# ---------------------------------------------------------------------------

ensure_brew_in_path() {
  if command -v brew >/dev/null 2>&1; then
    return
  fi
  # Apple Silicon: /opt/homebrew, Intel: /usr/local
  if [ -f /opt/homebrew/bin/brew ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [ -f /usr/local/bin/brew ]; then
    eval "$(/usr/local/bin/brew shellenv)"
  fi
}

install_homebrew() {
  ensure_brew_in_path
  if command -v brew >/dev/null 2>&1; then
    log "INFO" "Homebrew already installed, skipping"
    return
  fi

  [ "$(uname -s)" != "Darwin" ] && return 0

  # Xcode CLT is installed by install_xcode_clt() in main()
  log "INFO" "Installing Homebrew (official installer)..."
  
  # Pre-authenticate sudo to avoid NONINTERACTIVE=1 blocking password prompt
  # This caches credentials for ~5 minutes
  log "INFO" "Administrator access required. Please enter your password:"
  if ! sudo -v </dev/tty; then
    log "ERROR" "Failed to authenticate. You must be an Administrator to install Homebrew."
    log "INFO" "Alternative: Ask an admin to run: sudo dseditgroup -o edit -a ${USER} -t user admin"
    exit 1
  fi
  
  # Now run installer with NONINTERACTIVE=1 (sudo credentials are cached)
  NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  ensure_brew_in_path
  if ! command -v brew >/dev/null 2>&1; then
    log "ERROR" "Homebrew install may have completed but brew not in PATH. Restart terminal and retry."
    exit 1
  fi
  log "INFO" "Homebrew installed successfully"
}

# ---------------------------------------------------------------------------
# chezmoi installer
# ---------------------------------------------------------------------------

install_chezmoi() {
  if command -v chezmoi >/dev/null 2>&1; then
    log "INFO" "chezmoi already installed, skipping"
    return
  fi

  log "INFO" "Installing chezmoi..."

  ensure_brew_in_path
  if ! command -v brew >/dev/null 2>&1; then
    install_homebrew
  fi
  brew install chezmoi
}

# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

main() {
  log "INFO" "Bootstrapping dotfiles for ${GITHUB_USER}..."
  install_xcode_clt
  install_chezmoi

  log "INFO" "Running chezmoi init --apply..."
  chezmoi init --apply "${GITHUB_USER}"

  log "INFO" "Done! Restart your shell to pick up changes."
}

main "$@"
