#!/bin/sh
# Bootstrap script for dotfiles
#
# Usage:
#   curl -fsLS https://raw.githubusercontent.com/alxshan/dotfiles/main/install.sh | sh
#
# Installs chezmoi (the only prerequisite), then runs `chezmoi init --apply`.
# Everything else (Xcode CLT, Homebrew, packages, dev tools) is handled by the
# repo's chezmoi scripts, keeping a single source of truth for setup logic.
# Prerequisites: macOS, internet connection.

set -e

GITHUB_USER="alxshan"
CHEZMOI_BIN="${HOME}/.local/bin/chezmoi"

log() {
  printf '[%s] %s\n' "$1" "$2"
}

main() {
  log "INFO" "Bootstrapping dotfiles for ${GITHUB_USER}..."

  if command -v chezmoi >/dev/null 2>&1; then
    log "INFO" "chezmoi already installed, skipping"
  else
    log "INFO" "Installing chezmoi (official installer)..."
    mkdir -p "${HOME}/.local/bin"
    sh -c "$(curl -fsLS get.chezmoi.io)" -- -b "${HOME}/.local/bin"
  fi

  log "INFO" "Running chezmoi init --apply..."
  "${CHEZMOI_BIN}" init --apply "${GITHUB_USER}"

  log "INFO" "Done! Restart your shell to pick up changes."
}

main "$@"
