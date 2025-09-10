#!/usr/bin/env bash
set -euo pipefail
BASE_DIR="$(cd "$(dirname "$0")" && pwd)"
DATA="${BASE_DIR}/obj/data"
WORLD="${DATA}/worlds/world"
OUT="${DATA}/map"
TOOLS="${BASE_DIR}/obj/tools/unmined"
BIN="${TOOLS}/unmined-cli"
CFG_DIR="${TOOLS}/config"
TPL_DIR="${TOOLS}/templates"
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

fetch_pkg(){
  local page="$1" tmp; tmp="$(mktemp -d)"
  echo "[update_map] fetching: $page"
  if ! wget -q --content-disposition -L -P "$tmp" "$page"; then rm -rf "$tmp"; return 1; fi
  local f; f="$(ls -1 "$tmp" | head -n1 || true)"; [ -n "$f" ] || { rm -rf "$tmp"; return 1; }
  f="$tmp/$f"; mkdir -p "$tmp/x"
  if echo "$f" | grep -qiE '\.zip$'; then unzip -qo "$f" -d "$tmp/x" || { rm -rf "$tmp"; return 1; }
  else tar xf "$f" -C "$tmp/x" || { rm -rf "$tmp"; return 1; }
  fi
  # パッケージ全体を TOOLS にコピー（templates 等を保持）
  rm -rf "${TOOLS:?}/"* || true
  cp -rf "$tmp/x"/. "${TOOLS}/"
  # 代表バイナリ検出
  local found; found="$(find "${TOOLS}" -maxdepth 2 -type f -iname 'unmined-cli*' | head -n1 || true)"
  [ -n "$found" ] || { rm -rf "$tmp"; return 1; }
  mv -f "$found" "${BIN}"
  chmod +x "${BIN}"
  rm -rf "$tmp"
  return 0
}

URL="$(pick_url)"
if [ "$URL" = "unsupported" ]; then echo "[update_map] unsupported arch $(uname -m)"; exit 0; fi

if [[ ! -x "$BIN" ]] || [[ ! -d "$TPL_DIR" ]]; then
  echo "[update_map] downloading uNmINeD CLI (arch=$(uname -m) libc=$libc)"
  fetch_pkg "$URL" || true
  if [[ ! -x "$BIN" ]] || [[ ! -d "$TPL_DIR" ]]; then
    if echo "$URL" | grep -q musl; then fetch_pkg "https://unmined.net/download/unmined-cli-linux-arm64-dev/" || true
    else fetch_pkg "https://unmined.net/download/unmined-cli-linux-musl-arm64-dev/" || true
    fi
  fi
fi
if [[ ! -x "$BIN" ]] || [[ ! -d "$TPL_DIR" ]]; then
  echo "[update_map] 自動DLに失敗。手動で ${TOOLS} に一式配置してください（templates/ を含む）"
  exit 0
fi

echo "[update_map] rendering web map from: ${WORLD}"
pushd "${TOOLS}" >/dev/null
"./unmined-cli" web render --world "${WORLD}" --output "${OUT}" --chunkprocessors 4 || true
popd >/dev/null
echo "[update_map] done -> ${OUT}"
