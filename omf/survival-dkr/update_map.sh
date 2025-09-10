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

# 必要最低限の blocktags.js（空で良い）
if [[ ! -f "${CFG_DIR}/blocktags.js" ]]; then
  cat > "${CFG_DIR}/blocktags.js" <<'JS'
// minimal placeholder for uNmINeD web render
export default {};
JS
fi

arch="$(uname -m)"
libc="glibc"; (ldd --version 2>&1 | grep -qi musl) && libc="musl"

pick_url(){ 
  if [ "$arch" = "aarch64" ] || [ "$arch" = "arm64" ]; then
    if [ "$libc" = "musl" ]; then echo "https://unmined.net/download/unmined-cli-linux-musl-arm64-dev/"; else echo "https://unmined.net/download/unmined-cli-linux-arm64-dev/"; fi
  else
    echo "unsupported"
  fi
}
fetch_bin(){
  local page="$1" tmp; tmp="$(mktemp -d)"
  echo "[update_map] fetching: $page"
  # コンテント・ディスポジションで実体を取る
  if ! wget -q --content-disposition -L -P "$tmp" "$page"; then rm -rf "$tmp"; return 1; fi
  local f; f="$(ls -1 "$tmp" | head -n1 || true)"; [ -n "$f" ] || { rm -rf "$tmp"; return 1; }
  f="$tmp/$f"; mkdir -p "$tmp/x"
  if echo "$f" | grep -qiE '\.zip$'; then unzip -qo "$f" -d "$tmp/x" || { rm -rf "$tmp"; return 1; }
  else tar xf "$f" -C "$tmp/x" || { rm -rf "$tmp"; return 1; }
  fi
  local found; found="$(find "$tmp/x" -type f -iname 'unmined-cli*' | head -n1 || true)"; [ -n "$found" ] || { rm -rf "$tmp"; return 1; }
  cp -f "$found" "$BIN"; chmod +x "$BIN"; rm -rf "$tmp"; return 0
}
URL="$(pick_url)"
if [ "$URL" = "unsupported" ]; then echo "[update_map] unsupported arch $(uname -m)"; exit 0; fi
if [[ ! -x "$BIN" ]]; then
  echo "[update_map] downloading uNmINeD CLI (arch=$(uname -m) libc=$libc)"
  fetch_bin "$URL" || true
  if [[ ! -x "$BIN" ]]; then
    # 相互フォールバック
    if echo "$URL" | grep -q musl; then fetch_bin "https://unmined.net/download/unmined-cli-linux-arm64-dev/" || true
    else fetch_bin "https://unmined.net/download/unmined-cli-linux-musl-arm64-dev/" || true
    fi
  fi
fi
if [[ ! -x "$BIN" ]]; then echo "[update_map] 自動DLに失敗。手動で ${BIN} を配置してください。"; exit 0; fi

echo "[update_map] rendering web map from: ${WORLD}"
# uNmINeD が CFG_DIR を見つけられるようカレントを TOOLS にする
pushd "${TOOLS}" >/dev/null
"./unmined-cli" web render --world "${WORLD}" --output "${OUT}" --chunkprocessors 4 || true
popd >/dev/null
echo "[update_map] done -> ${OUT}"
