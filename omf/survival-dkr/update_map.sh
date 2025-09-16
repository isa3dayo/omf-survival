#!/usr/bin/env bash
set -euo pipefail
BASE_DIR="$(cd "$(dirname "$0")" && pwd)"
DATA="${BASE_DIR}/obj/data"
WORLD="${DATA}/worlds/world"
OUT="${DATA}/map"
TOOLS="${BASE_DIR}/obj/tools/unmined"
BIN="${TOOLS}/unmined-cli"
LAST="${TOOLS}/.last_url"

mkdir -p "${TOOLS}" "${OUT}"

log(){ echo "[update_map] $*" >&2; }
need(){ command -v "$1" >/dev/null 2>&1 || { log "need $1"; exit 2; }; }
need curl; command -v grep >/dev/null 2>&1 || true; command -v sed >/dev/null 2>&1 || true

pick_url(){
  local tmp url
  tmp="$(mktemp -d)"
  curl -fsSL "https://unmined.net/downloads/" > "$tmp/p.html"
  url="$(grep -Eo 'https://unmined\.net/download/unmined-cli-linux-arm64-dev/[^"]*' "$tmp/p.html" | head -n1 || true)"
  rm -rf "$tmp"
  [ -n "$url" ] || return 1
  echo "$url"
}

# 判別：先に tar と zip の “テスト”を試し、どちらも不可なら file で推定
detect_and_extract(){
  local pkg="$1" tmp="$2"
  mkdir -p "$tmp/x"
  if tar tzf "$pkg" >/dev/null 2>&1; then
    tar xzf "$pkg" -C "$tmp/x"
    echo tgz; return 0
  fi
  if unzip -tq "$pkg" >/dev/null 2>&1; then
    unzip -qo "$pkg" -d "$tmp/x"
    echo zip; return 0
  fi
  if file "$pkg" 2>/dev/null | grep -qi 'gzip'; then
    tar xzf "$pkg" -C "$tmp/x" || true
    echo tgz; return 0
  fi
  if file "$pkg" 2>/dev/null | grep -qi 'zip'; then
    unzip -qo "$pkg" -d "$tmp/x" || true
    echo zip; return 0
  fi
  return 1
}

install_from_url(){
  local url="$1" tmp ext
  tmp="$(mktemp -d)"
  log "downloading: $url"
  if ! curl -fL --retry 3 --retry-delay 2 -o "$tmp/pkg" "$url"; then
    rm -rf "$tmp"; return 1
  fi
  if ! ext="$(detect_and_extract "$tmp/pkg" "$tmp")"; then
    log "WARN: install failed; keep existing"
    rm -rf "$tmp"; return 1
  fi
  local root; root="$(find "$tmp/x" -maxdepth 3 -type f -name 'unmined-cli' -printf '%h\n' | head -n1 || true)"
  [ -n "$root" ] || { rm -rf "$tmp"; return 1; }
  rsync -a "$root"/ "${TOOLS}/" 2>/dev/null || cp -rf "$root"/ "${TOOLS}/"
  chmod +x "${BIN}" || true
  echo -n "$url" > "${LAST}"
  rm -rf "$tmp"; return 0
}

main(){
  local url; url="$(pick_url || true)"
  if [ -n "$url" ]; then
    if [ ! -f "${LAST}" ] || [ "$(cat "${LAST}")" != "$url" ] || [ ! -x "${BIN}" ]; then
      install_from_url "$url" || log "WARN: install failed; keep existing"
    else
      log "URL unchanged; skip update"
    fi
  else
    log "WARN: could not discover URL; keep existing"
  fi

  if [ -x "${BIN}" ]; then
    log "rendering..."
    "${BIN}" web render --world "${WORLD}" --output "${OUT}" --chunkprocessors 4 || { log "ERROR: render failed"; exit 1; }
    log "done -> ${OUT}"
  else
    log "ERROR: unmined-cli not installed"
    exit 1
  fi
}
main "$@"
