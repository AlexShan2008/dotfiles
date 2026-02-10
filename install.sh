#!/bin/sh
# Bootstrap script for dotfiles
#
# Usage:
#   curl -fsLS https://raw.githubusercontent.com/AlexShan2008/dotfiles/main/install.sh | sh
#
# If GitHub is unreachable in CN, prefer proxy:
#   PROXY_URL=http://127.0.0.1:7890 ALL_PROXY=socks5://127.0.0.1:7891 \
#   curl -fsLS https://raw.githubusercontent.com/AlexShan2008/dotfiles/main/install.sh | sh
#
# Environment:
#   CHEZMOI_VERSION  Pin to a specific chezmoi version (e.g. "v2.52.0"). Default: latest.
#   PROXY_URL        HTTP/HTTPS proxy for curl (e.g. "http://127.0.0.1:7890")
#   ALL_PROXY        SOCKS proxy for curl (e.g. "socks5://127.0.0.1:7891")
#   GITHUB_PROXY     URL prefix for GitHub/Raw downloads (e.g. "https://ghproxy.com/")

set -e

CHEZMOI_BIN="${HOME}/.local/bin/chezmoi"
GITHUB_USER="AlexShan2008"
CHEZMOI_VERSION="${CHEZMOI_VERSION:-latest}"

_tmp_dir=""
_proxy_enabled=""

log() {
  printf '[%s] %s\n' "$1" "$2"
}

# ---------------------------------------------------------------------------
# Networking helpers
# ---------------------------------------------------------------------------

normalize_proxy_env() {
  if [ -n "${PROXY_URL:-}" ]; then
    [ -z "${HTTP_PROXY:-}" ] && export HTTP_PROXY="${PROXY_URL}"
    [ -z "${HTTPS_PROXY:-}" ] && export HTTPS_PROXY="${PROXY_URL}"
  fi
  if [ -n "${HTTP_PROXY:-}" ] && [ -z "${http_proxy:-}" ]; then
    export http_proxy="${HTTP_PROXY}"
  fi
  if [ -n "${HTTPS_PROXY:-}" ] && [ -z "${https_proxy:-}" ]; then
    export https_proxy="${HTTPS_PROXY}"
  fi
  if [ -n "${ALL_PROXY:-}" ] && [ -z "${all_proxy:-}" ]; then
    export all_proxy="${ALL_PROXY}"
  fi

  if [ -n "${HTTP_PROXY:-}" ] || [ -n "${HTTPS_PROXY:-}" ] || [ -n "${ALL_PROXY:-}" ] || \
     [ -n "${http_proxy:-}" ] || [ -n "${https_proxy:-}" ] || [ -n "${all_proxy:-}" ]; then
    _proxy_enabled=1
  fi
}

github_url() {
  if [ -n "${GITHUB_PROXY:-}" ]; then
    printf '%s%s' "${GITHUB_PROXY%/}/" "$1"
  else
    printf '%s' "$1"
  fi
}

curl_cmd() {
  curl -fsSL --retry 5 --retry-all-errors --connect-timeout 10 --max-time 60 "$@"
}

# ---------------------------------------------------------------------------
# GitHub connectivity — check only (no implicit /etc/hosts changes)
# ---------------------------------------------------------------------------

ensure_github_access() {
  if curl_cmd -o /dev/null "$(github_url "https://github.com")" 2>/dev/null; then
    return
  fi

  if [ -n "${_proxy_enabled}" ]; then
    log "ERROR" "GitHub is unreachable even with proxy settings. Check your proxy or try GITHUB_PROXY."
  else
    log "ERROR" "GitHub is unreachable. Set PROXY_URL/HTTP(S)_PROXY or ALL_PROXY, or try GITHUB_PROXY."
  fi
  exit 1
}

# ---------------------------------------------------------------------------
# chezmoi installer
# ---------------------------------------------------------------------------

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
      api_url="$(github_url "https://api.github.com/repos/twpayne/chezmoi/releases/latest")"
      version="$(curl_cmd "${api_url}" | sed -n 's/.*"tag_name":[[:space:]]*"\([^"]*\)".*/\1/p' | head -n 1)"
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
  BASE_URL="$(github_url "https://github.com/twpayne/chezmoi/releases/download/${RESOLVED_VERSION}")"
  CHECKSUMS="checksums.txt"
  _tmp_dir="$(mktemp -d)"

  curl_cmd "${BASE_URL}/${TARBALL}" -o "${_tmp_dir}/${TARBALL}"
  curl_cmd "${BASE_URL}/${CHECKSUMS}" -o "${_tmp_dir}/${CHECKSUMS}"

  (cd "${_tmp_dir}" && grep " ${TARBALL}\$" "${CHECKSUMS}" | shasum -a 256 -c -)

  tar -xzf "${_tmp_dir}/${TARBALL}" -C "${_tmp_dir}"
  install -m 0755 "${_tmp_dir}/chezmoi" "${CHEZMOI_BIN}"
}

# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

cleanup_all() {
  [ -n "${_tmp_dir}" ] && rm -rf "${_tmp_dir}"
}

main() {
  trap cleanup_all EXIT
  log "INFO" "Bootstrapping dotfiles for ${GITHUB_USER}..."
  normalize_proxy_env
  ensure_github_access
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
