#!/bin/bash
set -euo pipefail
BASE_DIR="$(cd "$(dirname "$0")" && pwd)"
DATA="${BASE_DIR}/obj/data"
WORLD="${DATA}/worlds/world"
OUT="${DATA}/map"
TOOLS="${BASE_DIR}/obj/tools/unmined"
BIN="${TOOLS}/unmined-cli"
CFG_DIR="${TOOLS}/config"
mkdir -p "${TOOLS}" "${OUT}" "${CFG_DIR}"

# ダミーconfig（空でOK）
if [ ! -f "${CFG_DIR}/blocktags.js" ]; then
  cat > "${CFG_DIR}/blocktags.js" <<'JS'
// minimal placeholder for uNmINeD web render
export default {};
JS
fi

arch="$(uname -m)"
libc="glibc"
if ldd --version 2>&1 | grep -qi musl; then libc="musl"; fi
echo "[update_map] downloading uNmINeD CLI (arch=${arch} libc=${libc})"

# downloads 一覧ページ → ARM64 (glibc/musl) を抽出 → アーカイブ直URL
find_url_from_downloads_page() {
  curl -fsSL -H 'User-Agent: omfs-installer' 'https://unmined.net/downloads/' 2>/dev/null \
  | tr '"'\'' ' '\n' \
  | awk 'BEGIN{IGNORECASE=1}
      /https?:\/\/[^ ]*unmined.*linux.*arm64.*(glibc|gnu).*\.((zip)|(tar\.gz)|(tar\.xz))$/ {print; found=1; exit}
      END{ if(!found) exit 1 }'
}

find_url_from_downloads_page_musl() {
  curl -fsSL -H 'User-Agent: omfs-installer' 'https://unmined.net/downloads/' 2>/dev/null \
  | tr '"'\'' ' '\n' \
  | awk 'BEGIN{IGNORECASE=1}
      /https?:\/\/[^ ]*unmined.*linux.*arm64.*musl.*\.((zip)|(tar\.gz)|(tar\.xz))$/ {print; found=1; exit}
      END{ if(!found) exit 1 }'
}

fallback_page_fetch() {
  local page="$1"
  echo "[update_map] fetching: ${page}"
  curl -fsSL -H 'User-Agent: omfs-installer' "$page" 2>/dev/null \
  | tr '"'\'' ' '\n' \
  | awk 'BEGIN{IGNORECASE=1}
      /https?:\/\/[^ ]*\.(zip|tar\.gz|tar\.xz)$/ {print; exit}'
}

download_and_unpack() {
  local url="$1"; local tmp; tmp="$(mktemp -d)"
  echo "[update_map] downloading: ${url}"
  if ! curl -fL --retry 3 --retry-delay 2 -H 'User-Agent: omfs-installer' -o "${tmp}/pkg" "$url"; then
    echo "[update_map] ERROR: download failed"; rm -rf "$tmp"; return 1
  fi
  mkdir -p "${tmp}/x"
  if file "${tmp}/pkg" | grep -qi zip; then
    unzip -qo "${tmp}/pkg" -d "${tmp}/x" || { echo "[update_map] ERROR: unzip failed"; rm -rf "$tmp"; return 1; }
  else
    tar xf "${tmp}/pkg" -C "${tmp}/x" || { echo "[update_map] ERROR: tar extract failed"; rm -rf "$tmp"; return 1; }
  fi
  rm -rf "${TOOLS:?}/"* 2>/dev/null || true
  cp -a "${tmp}/x/." "${TOOLS}/"
  local found
  found="$(find "${TOOLS}" -maxdepth 2 -type f -iname 'unmined-cli*' | head -n1 || true)"
  if [ -z "${found}" ]; then echo "[update_map] ERROR: uNmINeD 実行ファイルが見つからない"; rm -rf "$tmp"; return 1; fi
  mv -f "${found}" "${BIN}"
  chmod +x "${BIN}"
  rm -rf "$tmp"
}

URL=""
if [ "$libc" = "musl" ]; then
  URL="$(find_url_from_downloads_page_musl || true)"
  if [ -z "$URL" ]; then URL="$(fallback_page_fetch 'https://unmined.net/download/unmined-cli-linux-musl-arm64-dev/' || true)"; fi
else
  URL="$(find_url_from_downloads_page || true)"
  if [ -z "$URL" ]; then URL="$(fallback_page_fetch 'https://unmined.net/download/unmined-cli-linux-arm64-dev/' || true)"; fi
fi

if [ -n "$URL" ]; then download_and_unpack "$URL" || true; fi

# 逆側（glibc <-> musl）も試す（templates 不足対策）
if [ ! -x "${BIN}" ] || [ ! -d "${TOOLS}/templates" ]; then
  if [ "$libc" = "musl" ]; then
    ALT="$(fallback_page_fetch 'https://unmined.net/download/unmined-cli-linux-arm64-dev/' || true)"
  else
    ALT="$(fallback_page_fetch 'https://unmined.net/download/unmined-cli-linux-musl-arm64-dev/' || true)"
  fi
  if [ -n "$ALT" ]; then download_and_unpack "$ALT" || true; fi
fi

if [ ! -x "${BIN}" ] || [ ! -d "${TOOLS}/templates" ]; then
  echo "[update_map] 自動DLに失敗。手動で ${TOOLS} に一式配置してください（templates/ を含む）"
  exit 0
fi

if [ ! -d "${WORLD}" ]; then
  echo "[update_map] world が見つかりません: ${WORLD}"
  exit 0
fi

echo "[update_map] rendering web map from: ${WORLD}"
cd "${TOOLS}"
"./unmined-cli" web render --world "${WORLD}" --output "${OUT}" --chunkprocessors 4 || true
echo "[update_map] done -> ${OUT}"
