#!/bin/sh
# Bootstrap script for dotfiles
# Usage: curl -fsLS https://raw.githubusercontent.com/AlexShan2008/dotfiles/main/install.sh | sh

set -e

CHEZMOI_BIN="${HOME}/.local/bin/chezmoi"
GITHUB_USER="AlexShan2008"
# Set CHEZMOI_VERSION to a specific release (e.g. "v2.52.0") for reproducible installs.
# Default: resolve the latest release tag from GitHub.
CHEZMOI_VERSION="${CHEZMOI_VERSION:-latest}"

log() {
  printf '[%s] %s\n' "$1" "$2"
}

install_chezmoi() {
  if command -v chezmoi >/dev/null 2>&1; then
    log "INFO" "chezmoi is already installed"
    return
  fi

  log "INFO" "Installing chezmoi..."
  mkdir -p "${HOME}/.local/bin"

  if ! command -v curl >/dev/null 2>&1; then
    log "ERROR" "curl not found. Please install curl first."
    exit 1
  fi

  if ! command -v shasum >/dev/null 2>&1; then
    log "ERROR" "shasum not found. Please install it or ensure Xcode CLT is installed."
    exit 1
  fi

  OS="$(uname -s | tr '[:upper:]' '[:lower:]')"
  if [ "${OS}" != "darwin" ]; then
    log "ERROR" "This installer only supports macOS."
    exit 1
  fi

  ARCH="$(uname -m)"
  case "${ARCH}" in
    x86_64) ARCH="amd64" ;;
    arm64|aarch64) ARCH="arm64" ;;
    *)
      log "ERROR" "Unsupported architecture: ${ARCH}"
      exit 1
      ;;
  esac

  resolve_chezmoi_version() {
    if [ "${CHEZMOI_VERSION}" = "latest" ]; then
      api_url="https://api.github.com/repos/twpayne/chezmoi/releases/latest"
      version="$(curl -fsSL "${api_url}" | sed -n 's/.*"tag_name":[[:space:]]*"\([^"]*\)".*/\1/p' | head -n 1)"
      if [ -z "${version}" ]; then
        log "ERROR" "Failed to resolve latest chezmoi version from GitHub."
        exit 1
      fi
      echo "${version}"
    else
      echo "${CHEZMOI_VERSION}"
    fi
  }

  RESOLVED_VERSION="$(resolve_chezmoi_version)"
  TARBALL="chezmoi_${RESOLVED_VERSION#v}_${OS}_${ARCH}.tar.gz"
  BASE_URL="https://github.com/twpayne/chezmoi/releases/download/${RESOLVED_VERSION}"
  CHECKSUMS="checksums.txt"
  TMP_DIR="$(mktemp -d)"

  cleanup() {
    rm -rf "${TMP_DIR}"
  }
  trap cleanup EXIT

  curl -fsSL "${BASE_URL}/${TARBALL}" -o "${TMP_DIR}/${TARBALL}"
  curl -fsSL "${BASE_URL}/${CHECKSUMS}" -o "${TMP_DIR}/${CHECKSUMS}"

  (cd "${TMP_DIR}" && grep " ${TARBALL}\$" "${CHECKSUMS}" | shasum -a 256 -c -)

  tar -xzf "${TMP_DIR}/${TARBALL}" -C "${TMP_DIR}"
  install -m 0755 "${TMP_DIR}/chezmoi" "${CHEZMOI_BIN}"
}

main() {
  log "INFO" "Bootstrapping dotfiles for ${GITHUB_USER}..."
  install_chezmoi

  # Use the installed binary or the one in PATH
  if [ -x "${CHEZMOI_BIN}" ]; then
    "${CHEZMOI_BIN}" init --apply "${GITHUB_USER}"
  else
    chezmoi init --apply "${GITHUB_USER}"
  fi

  log "INFO" "Dotfiles applied successfully!"
}

main "$@"
