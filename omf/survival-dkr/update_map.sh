#!/usr/bin/env bash
set -euo pipefail
BASE_DIR="$(cd "$(dirname "$0")" && pwd)"
DATA="${BASE_DIR}/obj/data"
WORLD="${DATA}/worlds/world"
OUT="${DATA}/map"
TOOLS="${BASE_DIR}/obj/tools/unmined"
BIN="${TOOLS}/unmined-cli"
log(){ echo "[update_map] $*" >&2; }
need(){ command -v "$1" >/dev/null 2>&1 || { log "need '$1'"; exit 2; }; }
need curl; need grep; need sed; need awk
command -v tar >/dev/null 2>&1 || true
command -v unzip >/dev/null 2>&1 || true
command -v file >/dev/null 2>&1 || true
pick_arm_url(){
  local tmp url
  tmp="$(mktemp -d)"
  curl -fsSL "https://unmined.net/downloads/" > "$tmp/p.html"
  url="$(grep -Eo 'https://unmined\.net/download/unmined-cli-linux-arm64-dev/\?tmstv=[0-9]+' "$tmp/p.html" | head -n1 || true)"
  rm -rf "$tmp"; [ -n "$url" ] || return 1; echo "$url"
}
install_from_url(){
  local url="$1" tmp ext ctype root
  tmp="$(mktemp -d)"; curl -fL --retry 3 --retry-delay 2 -D "$tmp/h" -o "$tmp/p" "$url" || { rm -rf "$tmp"; return 1; }
  if command -v file >/dev/null 2>&1 && file "$tmp/p" | grep -qi 'Zip archive data'; then ext="zip"
  elif command -v file >/dev/null 2>&1 && file "$tmp/p" | grep -qi 'gzip compressed data'; then ext="tgz"
  else ctype="$(awk 'BEGIN{IGNORECASE=1}/^Content-Type:/{print $2}' "$tmp/h" | tr -d '\r' || true)"
       case "${ctype:-}" in application/zip) ext="zip";; application/gzip|application/x-gzip|application/x-tgz) ext="tgz";; *) ext="unknown";; esac
  fi
  mkdir -p "$tmp/x"
  case "$ext$" in tgz$) tar xzf "$tmp/p" -C "$tmp/x";; zip$) unzip -qo "$tmp/p" -d "$tmp/x";; *) rm -rf "$tmp"; return 1;; esac
  root="$(find "$tmp/x" -maxdepth 2 -type d -name 'unmined-cli*' | head -n1 || true)"; [ -n "$root" ] || root="$tmp/x"
  [ -f "$root/unmined-cli" ] || root="$(dirname "$(find "$tmp/x" -type f -name 'unmined-cli' | head -n1 || true)")"
  [ -n "$root" ] && [ -f "$root/unmined-cli" ] || { rm -rf "$tmp"; return 1; }
  mkdir -p "${TOOLS}"; rsync -a "$root"/ "${TOOLS}/" 2>/dev/null || cp -rf "$root"/ "${TOOLS}/"
  chmod +x "${BIN}" || true; rm -rf "$tmp"
}
ensure_cli(){
  mkdir -p "${TOOLS}" "${OUT}"
  if [ -x "${BIN}" ]; then return 0; fi
  local url; url="$(pick_arm_url || true)"; [ -n "${url:-}" ] || return 1; install_from_url "$url"
}
render(){ "${BIN}" --version || true; "${BIN}" web render --world "${WORLD}" --output "${OUT}" --chunkprocessors 4; }
main(){ ensure_cli && render || { echo "[update_map] skipped/failed"; exit 0; } }
main "$@"
