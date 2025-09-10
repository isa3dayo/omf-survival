#!/usr/bin/env bash
# uNmINeD Web マップ更新 (ARM64 glibc 専用)
# - https://unmined.net/downloads/ から Linux ARM64 (glibc) の最新URLを抽出
# - .tar.gz / .zip どちらでも展開OK
# - パッケージ内の templates/ をそのまま利用（Windows フォールバックなし）
set -euo pipefail

BASE_DIR="$(cd "$(dirname "$0")" && pwd)"
DATA="${BASE_DIR}/obj/data"
WORLD="${DATA}/worlds/world"
OUT="${DATA}/map"

TOOLS="${BASE_DIR}/obj/tools/unmined"
BIN="${TOOLS}/unmined-cli"
CFG_DIR="${TOOLS}/config"
TPL_DIR="${TOOLS}/templates"
TPL_ZIP="${TPL_DIR}/default.web.template.zip"

mkdir -p "${TOOLS}" "${OUT}"

log(){ echo "[update_map] $*" >&2; }

need_cmd(){ command -v "$1" >/dev/null 2>&1 || { log "ERROR: '$1' not found"; exit 2; }; }
need_cmd curl
need_cmd grep
need_cmd sed
need_cmd awk
command -v tar   >/dev/null 2>&1 || true
command -v unzip >/dev/null 2>&1 || true
command -v file  >/dev/null 2>&1 || true

pick_arm_url(){
  # downloads ページから ARM64 glibc のリンクを抽出
  local page tmp url
  page="https://unmined.net/downloads/"
  tmp="$(mktemp -d)"
  log "scanning downloads page..."
  curl -fsSL "$page" > "$tmp/page.html"
  url="$(grep -Eo 'https://unmined\.net/download/unmined-cli-linux-arm64-dev/\?tmstv=[0-9]+' "$tmp/page.html" | head -n1 || true)"
  rm -rf "$tmp"
  [ -n "$url" ] || return 1
  echo "$url"
}

install_from_archive(){
  # $1: URL
  local url="$1"
  local tmp ext ctype root

  tmp="$(mktemp -d)"
  log "downloading: ${url}"
  curl -fL --retry 3 --retry-delay 2 -D "$tmp/headers" -o "$tmp/pkg" "$url"

  # 判定（できるだけ file の結果を優先）
  if command -v file >/dev/null 2>&1; then
    if file "$tmp/pkg" | grep -qi 'Zip archive data'; then
      ext="zip"
    elif file "$tmp/pkg" | grep -qi 'gzip compressed data'; then
      ext="tgz"  # ほぼ tar.gz
    else
      # Content-Type を最後の手段で見る
      ctype="$(awk 'BEGIN{IGNORECASE=1}/^Content-Type:/{print $2}' "$tmp/headers" | tr -d '\r' || true)"
      case "${ctype:-}" in
        application/zip)  ext="zip" ;;
        application/gzip|application/x-gzip|application/x-tgz) ext="tgz" ;;
        *) ext="unknown" ;;
      esac
    fi
  else
    ctype="$(awk 'BEGIN{IGNORECASE=1}/^Content-Type:/{print $2}' "$tmp/headers" | tr -d '\r' || true)"
    case "${ctype:-}" in
      application/zip)  ext="zip" ;;
      application/gzip|application/x-gzip|application/x-tgz) ext="tgz" ;;
      *) ext="unknown" ;;
    esac
  fi

  mkdir -p "$tmp/x"
  case "$ext" in
    tgz)
      # 通常はこちら。階層に unmined-cli_xxx ディレクトリができる
      tar xzf "$tmp/pkg" -C "$tmp/x"
      ;;
    zip)
      unzip -qo "$tmp/pkg" -d "$tmp/x"
      ;;
    *)
      log "ERROR: unsupported archive format"; rm -rf "$tmp"; return 1
      ;;
  esac

  # 直下に解凍される場合と、unmined-cli_* ディレクトリ配下になる場合がある
  root="$(find "$tmp/x" -maxdepth 2 -type d -name 'unmined-cli*' | head -n1 || true)"
  [ -n "$root" ] || root="$tmp/x"

  # 必須ファイルチェック
  if [ ! -f "$root/unmined-cli" ]; then
    # さらに深い階層を探す（zipのパターン保険）
    root="$(dirname "$(find "$tmp/x" -type f -name 'unmined-cli' | head -n1 || true)")"
  fi
  [ -n "$root" ] && [ -f "$root/unmined-cli" ] || { log "ERROR: unmined-cli not found in archive"; rm -rf "$tmp"; return 1; }

  # まるごと TOOLS へ配置（config/templates/library などを温存）
  mkdir -p "${TOOLS}"
  rsync -a "$root"/ "${TOOLS}/" 2>/dev/null || cp -rf "$root"/ "${TOOLS}/"

  chmod +x "${BIN}"
  rm -rf "$tmp"

  # テンプレ在庫確認
  if [ ! -f "${TPL_ZIP}" ]; then
    if [ -d "${TPL_DIR}" ] && [ -f "${TPL_DIR}/default.web.template.zip" ]; then
      : # OK
    else
      log "ERROR: templates/default.web.template.zip missing in package"
      return 1
    fi
  fi

  return 0
}

render_map(){
  log "rendering web map from: ${WORLD}"
  mkdir -p "${OUT}"
  pushd "${TOOLS}" >/dev/null

  # パッケージの config を尊重。無い場合だけ極小プレースホルダを用意
  if [ ! -f "${CFG_DIR}/blocktags.js" ]; then
    mkdir -p "${CFG_DIR}"
    cat > "${CFG_DIR}/blocktags.js" <<'JS'
// minimal placeholder for uNmINeD web render
export default {};
JS
  fi

  "./unmined-cli" --version || true
  "./unmined-cli" web render --world "${WORLD}" --output "${OUT}" --chunkprocessors 4
  local rc=$?
  popd >/dev/null
  return $rc
}

main(){
  # 1) CLI が無ければ downloads から取得して展開
  if [ ! -x "${BIN}" ] || [ ! -f "${TPL_ZIP}" ]; then
    url="$(pick_arm_url || true)"
    [ -n "${url:-}" ] || { log "ERROR: could not discover ARM64 (glibc) URL"; exit 1; }
    log "URL picked: ${url}"
    install_from_archive "$url"
  else
    log "uNmINeD CLI already installed"
  fi

  # 2) レンダリング
  if render_map; then
    log "done -> ${OUT}"
  else
    log "ERROR: render failed"
    exit 1
  fi
}

main "$@"
