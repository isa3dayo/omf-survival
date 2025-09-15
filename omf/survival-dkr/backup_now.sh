#!/usr/bin/env bash
# アドオン“同梱”バックアップを BASE/backups に作成
set -euo pipefail
USER_NAME="${SUDO_USER:-$USER}"
HOME_DIR="$(getent passwd "$USER_NAME" | cut -d: -f6)"
BASE="${HOME_DIR}/omf/survival-dkr"
OBJ="${BASE}/obj"
DATA="${OBJ}/data"
BKP_OUTER="${BASE}/backups"

mkdir -p "${BKP_OUTER}"
TS="$(date +%Y%m%d-%H%M%S)"
WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

echo "[backup] staging..."
mkdir -p "${WORK}/stage"
# data 全体（map含む）を含める。容量が大きい場合は適宜除外に変えてください。
rsync -a "${DATA}/" "${WORK}/stage/data/"

# ホストのアドオン原本も同梱（復元時に選択可能にするため）
if [ -d "${BASE}/resource" ]; then
  rsync -a "${BASE}/resource/" "${WORK}/stage/host_resource/"
fi
if [ -d "${BASE}/behavior" ]; then
  rsync -a "${BASE}/behavior/" "${WORK}/stage/host_behavior/"
fi

# メタ情報
cat > "${WORK}/stage/metadata.json" <<JSON
{"created_at":"$(date --iso-8601=seconds)","server_name":"$(jq -r . 2>/dev/null <<<"${SERVER_NAME:-OMF}" || echo OMFS)","includes_addons":true}
JSON

OUT="${BKP_OUTER}/backup-${TS}.tgz"
echo "[backup] archiving -> ${OUT}"
tar -C "${WORK}/stage" -czf "${OUT}" .
echo "[backup] done."
echo "${OUT}"
