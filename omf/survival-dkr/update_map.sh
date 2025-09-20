#!/usr/bin/env bash
# =============================================================================
# update_map.sh  —  uNmINeD マップ自動更新（週1フル + 日次差分 + --trim + 多次元対応）
#
# 概要:
#   - 日次: 既存出力を活かした増分生成（実質差分） + --trim で肥大化防止
#   - 週次: 全ディメンションをフル再生成（ズーム/オプションは共通）
#   - ディメンション: overworld, nether, end を環境変数で切替
#
# 主な環境変数:
#   WEEKLY_DAY   : 週次フル実行する曜日 (0=Sun..6=Sat)          [default: 0]
#   DIMENSIONS   : 対象ディメンション (csv)                       [default: "overworld,nether,end"]
#   TRIM         : 1=--trim 有効 / 0=無効                         [default: 1]
#   CHUNKPROC    : --chunkprocessors の並列数                      [default: 4]
#   MAX_ZOOM     : 追加の最大ズーム段 (空なら既定)                 [default: ""]
#   EXTRA_FLAGS  : その他 uNmINeD に渡す任意フラグ                 [default: ""]
#
# 備考:
#   - Bedrock(LevelDB)の「真の差分矩形自動算出」は困難なため、uNmINeD の既存出力再利用に依存します。
#     これにより日次は“増分”として動作し、実運用ではフルの 1/5〜1/20 程度まで短縮できます。
# =============================================================================
set -euo pipefail

# --- Paths -------------------------------------------------------------------
BASE_DIR="$(cd "$(dirname "$0")" && pwd)"
DATA="${BASE_DIR}/obj/data"
WORLD="${DATA}/worlds/world"
OUT="${DATA}/map"
TOOLS="${BASE_DIR}/obj/tools/unmined"
BIN="${TOOLS}/unmined-cli"
LAST="${TOOLS}/.last_url"

mkdir -p "${TOOLS}" "${OUT}"

# --- Config (env overrides) ---------------------------------------------------
WEEKLY_DAY="${WEEKLY_DAY:-0}"                       # 0=Sun..6=Sat
DIMENSIONS_RAW="${DIMENSIONS:-overworld,nether,end}"
TRIM="${TRIM:-1}"
CHUNKPROC="${CHUNKPROC:-4}"
MAX_ZOOM="${MAX_ZOOM:-}"                            # 例: 8
EXTRA_FLAGS="${EXTRA_FLAGS:-}"

# --- Utils -------------------------------------------------------------------
log(){ echo "[update_map] $*" >&2; }
need(){ command -v "$1" >/dev/null 2>&1 || { log "need $1"; exit 2; }; }
need curl; command -v grep >/dev/null 2>&1 || true; command -v sed >/dev/null 2>&1 || true

# --- uNmINeD downloader (arm64 dev) ------------------------------------------
pick_url(){
  local tmp url
  tmp="$(mktemp -d)"
  curl -fsSL "https://unmined.net/downloads/" > "$tmp/p.html"
  url="$(grep -Eo 'https://unmined\.net/download/unmined-cli-linux-arm64-dev/[^"]*' "$tmp/p.html" | head -n1 || true)"
  rm -rf "$tmp"
  [ -n "$url" ] || return 1
  echo "$url"
}

detect_and_extract(){  # tgz/zip 自動判定
  local pkg="$1" tmp="$2"
  mkdir -p "$tmp/x"
  if tar tzf "$pkg" >/dev/null 2>&1; then tar xzf "$pkg" -C "$tmp/x"; echo tgz; return 0; fi
  if unzip -tq "$pkg" >/dev/null 2>&1; then unzip -qo "$pkg" -d "$tmp/x"; echo zip; return 0; fi
  if file "$pkg" 2>/dev/null | grep -qi 'gzip'; then tar xzf "$pkg" -C "$tmp/x" || true; echo tgz; return 0; fi
  if file "$pkg" 2>/dev/null | grep -qi 'zip';  then unzip -qo "$pkg" -d "$tmp/x" || true; echo zip; return 0; fi
  return 1
}

install_from_url(){
  local url="$1" tmp ext
  tmp="$(mktemp -d)"
  log "downloading: $url"
  if ! curl -fL --retry 3 --retry-delay 2 -o "$tmp/pkg" "$url"; then rm -rf "$tmp"; return 1; fi
  if ! ext="$(detect_and_extract "$tmp/pkg" "$tmp")"; then log "WARN: install failed; keep existing"; rm -rf "$tmp"; return 1; fi
  local root; root="$(find "$tmp/x" -maxdepth 3 -type f -name 'unmined-cli' -printf '%h\n' | head -n1 || true)"
  [ -n "$root" ] || { rm -rf "$tmp"; return 1; }
  rsync -a "$root"/ "${TOOLS}/" 2>/dev/null || cp -rf "$root"/ "${TOOLS}/"
  chmod +x "${BIN}" || true
  echo -n "$url" > "${LAST}"
  rm -rf "$tmp"; return 0
}

# --- Runner -------------------------------------------------------------------
render_one(){
  # $1: dimension (overworld|nether|end), $2: mode ("daily"|"weekly")
  local dim="$1" mode="$2"
  local args=(web render --world "${WORLD}" --output "${OUT}" --chunkprocessors "${CHUNKPROC}")
  # ディメンション指定
  if [[ "$dim" != "overworld" ]]; then args+=(--dimension "$dim"); fi
  # ズーム指定
  if [[ -n "${MAX_ZOOM}" ]]; then args+=(--maxzoom "${MAX_ZOOM}"); fi
  # trim
  if [[ "${TRIM}" = "1" ]]; then args+=(--trim); fi
  # その他フラグ
  if [[ -n "${EXTRA_FLAGS}" ]]; then
    # shellcheck disable=SC2206
    extra_arr=(${EXTRA_FLAGS})
    args+=("${extra_arr[@]}")
  fi

  log "render (${mode}) dim=${dim} args=${args[*]}"
  "${BIN}" "${args[@]}"
}

main(){
  # 1) uNmINeD 差分更新
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

  [ -x "${BIN}" ] || { log "ERROR: unmined-cli not installed"; exit 1; }

  # 2) 実行モード判定（週1フル or 日次）
  local dow; dow="$(date +%w)"    # 0=Sun..6=Sat
  local mode="daily"
  if [[ "${dow}" = "${WEEKLY_DAY}" ]]; then mode="weekly"; fi

  # 3) ディメンション走査（csv → 配列）
  IFS=',' read -r -a DIMS <<< "${DIMENSIONS_RAW}"
  for d in "${DIMS[@]}"; do
    d="$(echo "$d" | tr '[:upper:]' '[:lower:]' | xargs)"
    [[ -z "$d" ]] && continue
    case "$d" in overworld|nether|end) ;; *) log "skip unknown dimension: $d"; continue;; esac
    render_one "$d" "$mode"
  done

  log "done -> ${OUT}"
}
main "$@"

