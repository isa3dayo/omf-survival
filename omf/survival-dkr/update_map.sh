#!/usr/bin/env bash
# uNmINeD 自動DL改良版：downloadsページをパース→実ファイルURL取得→全展開（templates含む）
set -euo pipefail

BASE_DIR="$(cd "$(dirname "$0")" && pwd)"
DATA="${BASE_DIR}/obj/data"
WORLD="${DATA}/worlds/world"
OUT="${DATA}/map"
TOOLS="${BASE_DIR}/obj/tools/unmined"
BIN="${TOOLS}/unmined-cli"
CFG_DIR="${TOOLS}/config"

mkdir -p "${TOOLS}" "${OUT}" "${CFG_DIR}"

# プレースホルダ（空でOK）
if [[ ! -f "${CFG_DIR}/blocktags.js" ]]; then
  cat > "${CFG_DIR}/blocktags.js" <<'JS'
// minimal placeholder for uNmINeD web render
export default {};
JS
fi

arch="$(uname -m)"
libc="glibc"; (ldd --version 2>&1 | grep -qi musl) && libc="musl"

say(){ echo "[update_map] $*"; }

# --- downloads ページから arm64 用の実ファイルURLを抜く ---
find_unmined_url() {
  # 1) downloads 一覧から “arm64 & linux” を優先
  local page html url
  page="https://unmined.net/downloads/"
  say "query: ${page}"
  html="$(curl -fsSL -H 'User-Agent: omfs-installer' "$page" || true)"

  # a) glibc を優先、次に musl。ZIP を第一候補、次に tar.*
  url="$(printf "%s" "$html" | tr '"' '\n' | tr "'" '\n' | \
        awk 'BEGIN{IGNORECASE=1}
             /https?:\/\/[^ ]*unmined.*linux.*arm64.*(glibc).*\.(zip|tar\.gz|tar\.xz)/ {print; exit}' )"
  if [[ -z "${url}" ]]; then
    url="$(printf "%s" "$html" | tr '"' '\n' | tr "'" '\n' | \
          awk 'BEGIN{IGNORECASE=1}
               /https?:\/\/[^ ]*unmined.*linux.*arm64.*(musl).*\.(zip|tar\.gz|tar\.xz)/ {print; exit}' )"
  fi
  # b) 直リンクが取れない場合は “/download/unmined-cli-linux-*-arm64-dev/” ページを辿る
  if [[ -z "${url}" ]]; then
    local page2
    if [[ "${libc}" == "musl" ]]; then
      page2="https://unmined.net/download/unmined-cli-linux-musl-arm64-dev/"
    else
      page2="https://unmined.net/download/unmined-cli-linux-arm64-dev/"
    fi
    say "fallback page: ${page2}"
    html="$(curl -fsSL -H 'User-Agent: omfs-installer' "$page2" || true)"
    url="$(printf "%s" "$html" | tr '"' '\n' | tr "'" '\n' | \
          awk 'BEGIN{IGNORECASE=1}
               /https?:\/\/[^ ]*\.(zip|tar\.gz|tar\.xz)$/ {print; exit}')"
  fi
  printf "%s" "${url}"
}

download_and_unpack() {
  local url="$1"
  local tmp; tmp="$(mktemp -d)"
  say "downloading: ${url}"
  if ! curl -fL --retry 3 --retry-delay 2 -o "${tmp}/pkg" -H 'User-Agent: omfs-installer' "$url"; then
    rm -rf "$tmp"; return 1
  fi
  mkdir -p "${tmp}/x"
  if file "${tmp}/pkg" | grep -qi zip; then
    unzip -qo "${tmp}/pkg" -d "${tmp}/x"
  else
    # tar(.gz/.xz)
    tar xf "${tmp}/pkg" -C "${tmp}/x"
  fi
  # パッケージ全体を配置（templates/ を残すため）
  rm -rf "${TOOLS:?}/"* || true
  cp -a "${tmp}/x/." "${TOOLS}/"

  # 実行ファイル名の揺れに対応（unmined-cli* を拾う）
  local found
  found="$(find "${TOOLS}" -maxdepth 2 -type f -iname 'unmined-cli*' | head -n1 || true)"
  if [[ -z "${found}" ]]; then
    say "ERROR: uNmINeD 実行ファイルが見つからない"; rm -rf "$tmp"; return 1
  fi
  mv -f "${found}" "${BIN}"
  chmod +x "${BIN}"
  rm -rf "$tmp"
}

say "downloading uNmINeD CLI (arch=${arch} libc=${libc})"

url="$(find_unmined_url || true)"

if [[ -n "${url}" ]]; then
  download_and_unpack "${url}" || true
fi

# 片方しか見つからなかった／失敗した時の入れ替えトライ
if [[ ! -x "${BIN}" ]] || [[ ! -d "${TOOLS}/templates" ]]; then
  # libc を切り替えて再探索
  if [[ "${libc}" == "musl" ]]; then alt="glibc"; else alt="musl"; fi
  page_alt="https://unmined.net/download/unmined-cli-linux-${alt}-arm64-dev/"
  say "fallback: ${page_alt}"
  html2="$(curl -fsSL -H 'User-Agent: omfs-installer' "$page_alt" || true)"
  url2="$(printf "%s" "$html2" | tr '"' '\n' | tr "'" '\n' | \
        awk 'BEGIN{IGNORECASE=1}
             /https?:\/\/[^ ]*\.(zip|tar\.gz|tar\.xz)$/ {print; exit}')"
  if [[ -n "${url2}" ]]; then
    download_and_unpack "${url2}" || true
  fi
fi

if [[ ! -x "${BIN}" ]] || [[ ! -d "${TOOLS}/templates" ]]; then
  say "自動DLに失敗。手動で ${TOOLS} に一式配置してください（templates/ を含む）"
  exit 0
fi

# --- 描画 ---
if [[ ! -d "${WORLD}" ]]; then
  say "world が見つかりません: ${WORLD}"
  exit 0
fi

say "rendering web map from: ${WORLD}"
# templates を見つけやすいように CWD=TOOLS で実行
pushd "${TOOLS}" >/dev/null
"./unmined-cli" web render \
  --world "${WORLD}" \
  --output "${OUT}" \
  --chunkprocessors 4 || true
popd >/dev/null
say "done -> ${OUT}"

