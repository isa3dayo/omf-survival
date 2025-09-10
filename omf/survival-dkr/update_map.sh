#!/usr/bin/env bash
set -euo pipefail
BASE_DIR="$(cd "$(dirname "$0")" && pwd)"
DATA="${BASE_DIR}/obj/data"
WORLD="${DATA}/worlds/world"
OUT="${DATA}/map"
TOOLS="${BASE_DIR}/obj/tools/unmined"
BIN="${TOOLS}/unmined-cli"
mkdir -p "${TOOLS}" "${OUT}"

arch="$(uname -m)"
libc="glibc"
if ldd --version 2>&1 | grep -qi musl; then libc="musl"; fi

# RPi OS は glibc が通常。musl なら musl に切替
pick_url() {
  if [ "$arch" != "aarch64" ] && [ "$arch" != "arm64" ]; then
    echo "unsupported-arch"
    return
  fi
  if [ "$libc" = "musl" ]; then
    echo "https://unmined.net/download/unmined-cli-linux-musl-arm64-dev/"
  else
    echo "https://unmined.net/download/unmined-cli-linux-arm64-dev/"
  fi
}

download_and_extract() {
  local page="$1"
  local tmp; tmp="$(mktemp -d)"
  echo "[update_map] fetching: $page"
  # ランディング → リダイレクト先アセットを追跡
  # 最終URLは zip or tar.gz
  if ! wget -q --content-disposition -L -P "$tmp" "$page"; then
    echo "[update_map] initial fetch failed"
    rm -rf "$tmp"; return 1
  fi
  # 展開（zip or tar.gz）
  local file; file="$(ls -1 "$tmp" | head -n1 || true)"
  [ -n "$file" ] || { echo "[update_map] no file"; rm -rf "$tmp"; return 1; }
  file="$tmp/$file"
  if echo "$file" | grep -qiE '\.zip$'; then
    unzip -qo "$file" -d "$tmp/x" || { rm -rf "$tmp"; return 1; }
  else
    mkdir -p "$tmp/x"
    tar xf "$file" -C "$tmp/x" || { rm -rf "$tmp"; return 1; }
  fi
  # 実行ファイルを拾う
  local found; found="$(find "$tmp/x" -type f -iname 'unmined-cli*' | head -n1 || true)"
  [ -n "$found" ] || { echo "[update_map] binary not found in package"; rm -rf "$tmp"; return 1; }
  cp -f "$found" "$BIN"
  chmod +x "$BIN"
  rm -rf "$tmp"
  return 0
}

URL="$(pick_url)"
if [ "$URL" = "unsupported-arch" ]; then
  echo "[update_map] unsupported arch: $(uname -m)"
  exit 0
fi

if [[ ! -x "$BIN" ]]; then
  echo "[update_map] downloading uNmINeD CLI (arch=$(uname -m) libc=$libc)"
  if ! download_and_extract "$URL"; then
    # フォールバック（musl/glibc を逆に）
    if echo "$URL" | grep -q musl; then
      echo "[update_map] fallback to glibc"
      download_and_extract "https://unmined.net/download/unmined-cli-linux-arm64-dev/" || true
    else
      echo "[update_map] fallback to musl"
      download_and_extract "https://unmined.net/download/unmined-cli-linux-musl-arm64-dev/" || true
    fi
  fi
fi

if [[ ! -x "$BIN" ]]; then
  echo "[update_map] 自動DLに失敗。手動で ${BIN} を配置してください。"
  exit 0
fi

mkdir -p "${OUT}"
echo "[update_map] rendering map from: ${WORLD}"
"$BIN" render --world "${WORLD}" --output "${OUT}" --zoomlevels 1-4 || true
echo "[update_map] done -> ${OUT}"
