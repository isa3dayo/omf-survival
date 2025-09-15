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
need curl; need grep; need sed; command -v tar >/dev/null 2>/dev/null || true; command -v unzip >/dev/null 2>/dev/null || true

pick_url(){
  local page tmp url
  tmp="$(mktemp -d)"
  curl -fsSL "https://unmined.net/downloads/" > "$tmp/p.html"
  url="$(grep -Eo 'https://unmined\.net/download/unmined-cli-linux-arm64-dev/\?tmstv=[0-9]+' "$tmp/p.html" | head -n1 || true)"
  rm -rf "$tmp"
  [ -n "$url" ] || return 1
  echo "$url"
}

install_from_url(){
  local url="$1" tmp ext
  tmp="$(mktemp -d)"
  log "downloading: $url"
  curl -fL --retry 3 --retry-delay 2 -o "$tmp/pkg" "$url" || { rm -rf "$tmp"; return 1; }
  if file "$tmp/pkg" 2>/dev/null | grep -qi 'Zip'; then ext=zip; else ext=tgz; fi
  mkdir -p "$tmp/x"
  if [ "$ext" = "zip" ]; then unzip -qo "$tmp/pkg" -d "$tmp/x"; else tar xzf "$tmp/pkg" -C "$tmp/x"; fi
  local root; root="$(find "$tmp/x" -maxdepth 2 -type f -name 'unmined-cli' -printf '%h\n' | head -n1 || true)"
  [ -n "$root" ] || { rm -rf "$tmp"; return 1; }
  rsync -a "$root"/ "${TOOLS}/" 2>/dev/null || cp -rf "$root"/ "${TOOLS}/"
  chmod +x "${BIN}" || true
  echo -n "$url" > "${LAST}"
  rm -rf "$tmp"
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
