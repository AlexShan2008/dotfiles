#!/bin/sh
# Bootstrap script for dotfiles
#
# Usage:
#   curl -fsLS https://raw.githubusercontent.com/AlexShan2008/dotfiles/main/install.sh | sh

set -e

GITHUB_USER="AlexShan2008"

log() {
  printf '[%s] %s\n' "$1" "$2"
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

  if command -v brew >/dev/null 2>&1; then
    brew install chezmoi
  else
    log "ERROR" "Homebrew is required but not found. Install it first: https://brew.sh"
    exit 1
  fi
}

# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

main() {
  log "INFO" "Bootstrapping dotfiles for ${GITHUB_USER}..."
  install_chezmoi

  log "INFO" "Running chezmoi init --apply..."
  chezmoi init --apply "${GITHUB_USER}"

  log "INFO" "Done! Restart your shell to pick up changes."
}

main "$@"
