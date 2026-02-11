#!/bin/sh
# Bootstrap script for dotfiles
#
# Usage:
#   curl -fsLS https://raw.githubusercontent.com/AlexShan2008/dotfiles/main/install.sh | sh
#
# Environment:
#   CHEZMOI_VERSION  Pin to a specific chezmoi version (e.g. "v2.52.0"). Default: latest.

set -e

CHEZMOI_BIN="${HOME}/.local/bin/chezmoi"
GITHUB_USER="AlexShan2008"
CHEZMOI_VERSION="${CHEZMOI_VERSION:-latest}"

_tmp_dir=""

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
  mkdir -p "${HOME}/.local/bin"

  if ! command -v curl >/dev/null 2>&1; then
    log "ERROR" "curl is required but not found"
    exit 1
  fi

  OS="$(uname -s | tr '[:upper:]' '[:lower:]')"
  ARCH="$(uname -m)"
  case "${ARCH}" in
    x86_64)        ARCH="amd64" ;;
    arm64|aarch64) ARCH="arm64" ;;
    *)
      log "ERROR" "Unsupported architecture: ${ARCH}"
      exit 1
      ;;
  esac

  if [ "${CHEZMOI_VERSION}" = "latest" ]; then
    log "INFO" "Resolving latest chezmoi version..."
    CHEZMOI_VERSION="$(curl -fsSL "https://api.github.com/repos/twpayne/chezmoi/releases/latest" \
      | sed -n 's/.*"tag_name":[[:space:]]*"\([^"]*\)".*/\1/p' | head -n 1)"
    if [ -z "${CHEZMOI_VERSION}" ]; then
      log "ERROR" "Failed to resolve latest chezmoi version"
      exit 1
    fi
  fi

  log "INFO" "Installing chezmoi ${CHEZMOI_VERSION} (${OS}/${ARCH})"

  TARBALL="chezmoi_${CHEZMOI_VERSION#v}_${OS}_${ARCH}.tar.gz"
  BASE_URL="https://github.com/twpayne/chezmoi/releases/download/${CHEZMOI_VERSION}"
  _tmp_dir="$(mktemp -d)"

  curl -fsSL "${BASE_URL}/${TARBALL}" -o "${_tmp_dir}/${TARBALL}"
  curl -fsSL "${BASE_URL}/checksums.txt" -o "${_tmp_dir}/checksums.txt"

  log "INFO" "Verifying checksum..."
  (cd "${_tmp_dir}" && grep " ${TARBALL}\$" checksums.txt | shasum -a 256 -c -)

  tar -xzf "${_tmp_dir}/${TARBALL}" -C "${_tmp_dir}"
  install -m 0755 "${_tmp_dir}/chezmoi" "${CHEZMOI_BIN}"
  log "INFO" "chezmoi installed to ${CHEZMOI_BIN}"
}

# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

main() {
  trap '[ -n "${_tmp_dir}" ] && rm -rf "${_tmp_dir}"' EXIT

  log "INFO" "Bootstrapping dotfiles for ${GITHUB_USER}..."
  install_chezmoi

  log "INFO" "Running chezmoi init --apply..."
  if [ -x "${CHEZMOI_BIN}" ]; then
    "${CHEZMOI_BIN}" init --apply "${GITHUB_USER}"
  else
    chezmoi init --apply "${GITHUB_USER}"
  fi

  log "INFO" "Done! Restart your shell to pick up changes."
}

main "$@"
