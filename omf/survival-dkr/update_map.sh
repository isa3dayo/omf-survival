#!/usr/bin/env bash
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
if [[ ! -f "${CFG_DIR}/blocktags.js" ]]; then
  cat > "${CFG_DIR}/blocktags.js" <<'JS'
// minimal placeholder for uNmINeD web render
export default {};
JS
fi

arch="$(uname -m)"
libc="glibc"; (ldd --version 2>&1 | grep -qi musl) && libc="musl"
say(){ echo "[update_map] $*"; }

find_unmined_url() {
  local html url
  html="$(curl -fsSL -H 'User-Agent: omfs-installer' 'https://unmined.net/downloads/' || true)"
  url="$(printf "%s" "$html" | tr '\"'\'' '\n' | awk 'BEGIN{IGNORECASE=1}
    /https?:\/\/[^ ]*unmined.*linux.*arm64.*glibc.*\.(zip|tar\.gz|tar\.xz)$/ {print; exit}')"
  if [[ -z "$url" ]]; then
    url="$(printf "%s" "$html" | tr '\"'\'' '\n' | awk 'BEGIN{IGNORECASE=1}
      /https?:\/\/[^ ]*unmined.*linux.*arm64.*musl.*\.(zip|tar\.gz|tar\.xz)$/ {print; exit}')"
  fi
  if [[ -z "$url" ]]; then
    local page
    if [[ "$libc" == "musl" ]]; then
      page="https://unmined.net/download/unmined-cli-linux-musl-arm64-dev/"
    else
      page="https://unmined.net/download/unmined-cli-linux-arm64-dev/"
    fi
    say "fetching: ${page}"
    html="$(curl -fsSL -H 'User-Agent: omfs-installer' "$page" || true)"
    url="$(printf "%s" "$html" | tr '\"'\'' '\n' | awk 'BEGIN{IGNORECASE=1}
      /https?:\/\/[^ ]*\.(zip|tar\.gz|tar\.xz)$/ {print; exit}')"
  fi
  printf "%s" "$url"
}

download_and_unpack() {
  local url="$1"
  local tmp; tmp="$(mktemp -d)"
  say "downloading: ${url}"
  if ! curl -fL --retry 3 --retry-delay 2 -H 'User-Agent: omfs-installer' -o "${tmp}/pkg" "$url"; then
    rm -rf "$tmp"; return 1
  fi
  mkdir -p "${tmp}/x"
  if file "${tmp}/pkg" | grep -qi zip; then
    unzip -qo "${tmp}/pkg" -d "${tmp}/x" || { rm -rf "$tmp"; return 1; }
  else
    tar xf "${tmp}/pkg" -C "${tmp}/x" || { rm -rf "$tmp"; return 1; }
  fi
  rm -rf "${TOOLS:?}/"* || true
  cp -a "${tmp}/x/." "${TOOLS}/"
  local found; found="$(find "${TOOLS}" -maxdepth 2 -type f -iname 'unmined-cli*' | head -n1 || true)"
  if [[ -z "${found}" ]]; then
    say "ERROR: uNmINeD 実行ファイルが見つからない"; rm -rf "$tmp"; return 1
  fi
  mv -f "${found}" "${BIN}"
  chmod +x "${BIN}"
  rm -rf "$tmp"
}

say "downloading uNmINeD CLI (arch=${arch} libc=${libc})"
url="$(find_unmined_url || true)"
if [[ -n "$url" ]]; then download_and_unpack "$url" || true; fi

if [[ (! -x "${BIN}") || (! -d "${TOOLS}/templates") ]]; then
  if [[ "$libc" == "musl" ]]; then alt="glibc"; else alt="musl"; fi
  page="https://unmined.net/download/unmined-cli-linux-${alt}-arm64-dev/"
  say "fetching: ${page}"
  html2="$(curl -fsSL -H 'User-Agent: omfs-installer' "$page" || true)"
  url2="$(printf "%s" "$html2" | tr '\"'\'' '\n' | awk 'BEGIN{IGNORECASE=1}
    /https?:\/\/[^ ]*\.(zip|tar\.gz|tar\.xz)$/ {print; exit}')"
  if [[ -n "$url2" ]]; then download_and_unpack "$url2" || true; fi
fi

if [[ (! -x "${BIN}") || (! -d "${TOOLS}/templates") ]]; then
  say "自動DLに失敗。手動で ${TOOLS} に一式配置してください（templates/ を含む）"
  exit 0
fi

if [[ ! -d "${WORLD}" ]]; then
  say "world が見つかりません: ${WORLD}"
  exit 0
fi

say "rendering web map from: ${WORLD}"
pushd "${TOOLS}" >/dev/null
"./unmined-cli" web render --world "${WORLD}" --output "${OUT}" --chunkprocessors 4 || true
popd >/dev/null
say "done -> ${OUT}"
