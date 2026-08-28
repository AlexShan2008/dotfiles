#!/bin/sh
# Bootstrap script for dotfiles
#
# Usage:
#   curl -fsLS https://raw.githubusercontent.com/alexshanx/dotfiles/main/install.sh | sh
#
# Installs chezmoi (the only prerequisite), then runs `chezmoi init --apply`.
# Everything else (Xcode CLT, Homebrew, packages, dev tools) is handled by the
# repo's chezmoi scripts, keeping a single source of truth for setup logic.
# Prerequisites: macOS, internet connection.

set -e

GITHUB_USER="alexshanx"

log() {
  printf '[%s] %s\n' "$1" "$2"
}

main() {
  log "INFO" "Bootstrapping dotfiles for ${GITHUB_USER}..."

  if command -v chezmoi >/dev/null 2>&1; then
    CHEZMOI_BIN="$(command -v chezmoi)"
    log "INFO" "chezmoi already installed, skipping"
  else
    CHEZMOI_BIN="${HOME}/.local/bin/chezmoi"
    log "INFO" "Installing chezmoi (official installer)..."
    mkdir -p "${HOME}/.local/bin"
    sh -c "$(curl -fsLS get.chezmoi.io)" -- -b "${HOME}/.local/bin"
  fi

  log "INFO" "Running chezmoi init --apply..."
  # Force chezmoi's builtin git (go-git) for the initial clone: on a fresh
  # Mac, /usr/bin/git is only a stub that pops the Xcode CLT install dialog
  # and exits non-zero immediately (it does not wait for the dialog), which
  # makes chezmoi's autodetected system git fail before the repo is even
  # cloned. The run_once_before script installs real CLT/git afterward.
  "${CHEZMOI_BIN}" init --apply --use-builtin-git=true "${GITHUB_USER}"

  log "INFO" "Done! Restart your shell to pick up changes."
}

main "$@"
