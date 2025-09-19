#!/usr/bin/env bash
set -euo pipefail

# ====== 基本パスと環境 ======
: "${BASE:=/home/omino/omf/survival-dkr}"
USER_NAME="${SUDO_USER:-$(/usr/bin/id -un)}"

# ユーザーHOMEからBASEを再決定（複数ユーザー運用でも安定）
HOME_DIR="$(getent passwd "$USER_NAME" | cut -d: -f6)"
BASE="${HOME_DIR}/omf/survival-dkr"
OBJ="${BASE}/obj"
DATA="${OBJ}/data"
BKP_OUTER="${BASE}/backups"

# アドオン同梱切替（1=同梱 / 0=除外）
: "${BACKUP_WITH_ADDONS:=1}"

# メタ情報：サーバー名（なければ OMFS）
SERVER_NAME="${SERVER_NAME:-}"
if [ -z "$SERVER_NAME" ] && [ -f "$BASE/key/key.conf" ]; then
  # key.conf に SERVER_NAME=... があれば拾う
  SERVER_NAME="$(/usr/bin/grep -m1 '^SERVER_NAME=' "$BASE/key/key.conf" | /usr/bin/cut -d= -f2- || true)"
fi
SERVER_NAME="${SERVER_NAME:-OMFS}"

# ====== 準備 ======
cd "$BASE"
mkdir -p "$BKP_OUTER"

TS="$(date +%Y%m%d-%H%M%S)"
OUT="${BKP_OUTER}/backup-${TS}.tar.zst"   # 出力は .tar.zst に統一
WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

echo "[backup] staging to: $WORK/stage"
mkdir -p "${WORK}/stage"

# ---- data 一式（obj/data）をステージへ ----
# 稼働中でも rsync でスナップショット（厳密には /save hold 等も検討余地）
/usr/bin/rsync -a "${DATA}/" "${WORK}/stage/data/"

# ---- アドオン（resource/behavior）同梱オプション ----
if [ "$BACKUP_WITH_ADDONS" = "1" ]; then
  if [ -d "${BASE}/resource" ]; then /usr/bin/rsync -a "${BASE}/resource/" "${WORK}/stage/host_resource/"; fi
  if [ -d "${BASE}/behavior" ]; then /usr/bin/rsync -a "${BASE}/behavior/" "${WORK}/stage/host_behavior/"; fi
fi

# ---- メタデータ ----
# JSON 文字列エスケープ（簡易）
esc() { printf '%s' "$1" | sed 's/"/\\"/g'; }
cat > "${WORK}/stage/metadata.json" <<JSON
{
  "created_at": "$(date --iso-8601=seconds)",
  "server_name": "$(esc "$SERVER_NAME")",
  "includes_addons": $([ "$BACKUP_WITH_ADDONS" = "1" ] && echo true || echo false),
  "base": "$(esc "$BASE")",
  "data_dir": "data"
}
JSON

# ====== 圧縮 ======
echo "[backup] archiving -> ${OUT}"
# WORK/stage の中身をまるごと固める（設計一貫）
tar -I "zstd -19" -C "${WORK}/stage" -cf "${OUT}" .

echo "[backup] done."
echo "${OUT}"

