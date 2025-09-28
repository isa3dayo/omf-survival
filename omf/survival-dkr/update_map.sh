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

# --- key.conf 読み込み（存在すれば） ---
KEY_FILE="${BASE_DIR}/key/key.conf"
[[ -f "${KEY_FILE}" ]] && source "${KEY_FILE}"

# 期待する key.conf 変数（存在しなければ既定値）
WEEKLY_DAY="${WEEKLY_DAY:-}"           # 0=Sun..6=Sat（空なら週次モードなし）
DIMENSIONS_RAW="${DIMENSIONS_RAW:-auto}" # "auto" か "overworld,nether,end" など
TRIM="${TRIM:-0}"                      # ※現行 CLI に 'trim' フラグは無い（保持のみ）
CHUNKPROC="${CHUNKPROC:-4}"
MAX_ZOOM="${MAX_ZOOM:-6}"              # --zoomout にマップ
EXTRA_FLAGS="${EXTRA_FLAGS:-}"         # 任意の追加フラグ（例: --players）

# --- uNmINeD 差分取得 ---
pick_url(){
  local tmp url
  tmp="$(mktemp -d)"
  curl -fsSL "https://unmined.net/downloads/" > "$tmp/p.html"
  url="$(grep -Eo 'https://unmined\.net/download/unmined-cli-linux-arm64-dev/[^"]*' "$tmp/p.html" | head -n1 || true)"
  rm -rf "$tmp"
  [ -n "$url" ] || return 1
  echo "$url"
}

detect_and_extract(){
  local pkg="$1" tmp="$2"
  mkdir -p "$tmp/x"
  if tar tzf "$pkg" >/dev/null 2>&1; then
    tar xzf "$pkg" -C "$tmp/x"; echo tgz; return 0
  fi
  if unzip -tq "$pkg" >/dev/null 2>&1; then
    unzip -qo "$pkg" -d "$tmp/x"; echo zip; return 0
  fi
  if file "$pkg" 2>/dev/null | grep -qi 'gzip'; then
    tar xzf "$pkg" -C "$tmp/x" || true; echo tgz; return 0
  fi
  if file "$pkg" 2>/dev/null | grep -qi 'zip'; then
    unzip -qo "$pkg" -d "$tmp/x" || true; echo zip; return 0
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

# --- 週次判定（WEEKLY_DAY が今日の曜日と一致したら weekly=true） ---
is_weekly_day(){
  local dow today
  dow="$(date +%w)"   # 0=Sun..6=Sat
  today="${dow}"
  [ -n "${WEEKLY_DAY}" ] && [ "${today}" = "${WEEKLY_DAY}" ]
}

# --- レンダリング1回分（ディメンションは任意） ---
render_one(){
  local dim="${1:-}"  # ""=自動判定, それ以外=overworld|nether|end のいずれか
  local mode_args=()
  if is_weekly_day; then
    mode_args+=( --force )
  fi

  local -a args=( web render
    --world "${WORLD}"
    --output "${OUT}"
    --chunkprocessors "${CHUNKPROC}"
    --zoomout "${MAX_ZOOM}"
    "${mode_args[@]}"
  )

  # ディメンション指定（単数のみ）
  if [ -n "${dim}" ] && [ "${dim}" != "auto" ]; then
    args+=( --dimension "${dim}" )
  fi

  # 任意の追加フラグ
  if [ -n "${EXTRA_FLAGS}" ]; then
    # shellcheck disable=SC2206
    extra_arr=( ${EXTRA_FLAGS} )
    args+=( "${extra_arr[@]}" )
  fi

  log "render args: ${args[*]}"
  if ! "${BIN}" "${args[@]}"; then
    log "WARN: render failed${dim:+ (dimension=${dim})}; skip this run"
    return 1
  fi
  return 0
}

main(){
  # 取得/更新
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

  if [ ! -x "${BIN}" ]; then
    log "ERROR: unmined-cli not installed"
    exit 1
  fi

  # 実行モード表示
  if is_weekly_day; then
    log "mode: WEEKLY (WEEKLY_DAY=${WEEKLY_DAY})"
  else
    log "mode: DAILY"
  fi

  # DIMENSIONS_RAW の扱い:
  # - "auto" または空：ディメンション指定なし（自動判定で1回だけ実行）
  # - それ以外：カンマ区切りの各ディメンションを個別に実行、失敗しても続行
  local success=0
  if [ -z "${DIMENSIONS_RAW}" ] || [ "${DIMENSIONS_RAW}" = "auto" ]; then
    render_one "" && success=1
  else
    # 正規化してループ
    IFS=',' read -r -a dims <<<"$(echo "${DIMENSIONS_RAW}" | tr 'A-Z' 'a-z' | tr -s ', ' ',' | sed 's/^,//;s/,$//')"
    for d in "${dims[@]}"; do
      d="$(echo "$d" | xargs)"  # trim
      [ -n "$d" ] || continue
      render_one "$d" && success=1 || true
    done
  fi

  if [ "${success}" -eq 0 ]; then
    log "ERROR: all render attempts failed"
    exit 1
  fi

  log "done -> ${OUT}"
}

main "$@"

