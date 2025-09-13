#!/usr/bin/env bash
set -euo pipefail
BASE="$(cd "$(dirname "$0")" && pwd)"
OBJ="${BASE}/obj"
DATA="${OBJ}/data"
BKP="${BASE}/backups"
COMPOSE="${OBJ}/docker/compose.yml"

shopt -s nullglob
files=( "${BKP}"/backup-*.tar.gz )
if (( ${#files[@]} == 0 )); then echo "[ERR] backups not found in ${BKP}"; exit 1; fi
IFS=$'\n' files=( $(ls -1t "${BKP}"/backup-*.tar.gz) ); unset IFS

echo "== バックアップ一覧 =="
idx=1
for f in "${files[@]}"; do
  ts="$(basename "$f" | sed -E 's/^backup-([0-9]{8}-[0-9]{6}).*/\1/')"
  mt="$(date -r "$f" '+%Y-%m-%d %H:%M:%S')"
  size="$(du -h "$f" | cut -f1)"
  printf "%2d) %s  (mtime: %s, size: %s)\n" "$idx" "$ts" "$mt" "$size"
  idx=$((idx+1))
done

read -rp "番号を選んでください: " sel
if ! [[ "$sel" =~ ^[0-9]+$ ]] || (( sel < 1 || sel > ${#files[@]} )); then echo "[ERR] invalid selection"; exit 2; fi
target="${files[$((sel-1))]}"

echo "アドオン（resource_packs / behavior_packs / world_*_packs.json）も復元しますか？ (yes/no) [yes]: "
read -r ans
ans="${ans:-yes}"
RESTORE_ADDONS="yes"
if [[ "$ans" != "yes" ]]; then RESTORE_ADDONS="no"; fi

echo "[WARN] サーバーを停止して復元します。続行しますか？ (yes/no)"
read -r agree
if [[ "${agree}" != "yes" ]]; then echo "中止しました"; exit 0; fi

echo "[INFO] stopping stack..."
if [[ -f "${COMPOSE}" ]]; then docker compose -f "${COMPOSE}" down || true; fi

echo "[INFO] restoring from: ${target}"
mkdir -p "${OBJ}"
cd "${OBJ}"
rm -rf "${DATA}/worlds/world/db"
mkdir -p "${DATA}"

TMPD="$(mktemp -d)"
tar -xzf "${target}" -C "${TMPD}"

# 必須群を上書き展開
rsync -a "${TMPD}/data/server.properties" "${DATA}/" || true
rsync -a "${TMPD}/data/allowlist.json" "${DATA}/" || true
rsync -a "${TMPD}/data/permissions.json" "${DATA}/" || true
rsync -a "${TMPD}/data/chat.json" "${DATA}/" || true
rsync -a "${TMPD}/data/players.json" "${DATA}/" || true
rsync -a "${TMPD}/data/map" "${DATA}/" || true
mkdir -p "${DATA}/worlds/world"
rsync -a "${TMPD}/data/worlds/world/db" "${DATA}/worlds/world/" || true

if [[ "${RESTORE_ADDONS}" = "yes" ]]; then
  echo "[INFO] restoring addons..."
  rsync -a --delete "${TMPD}/data/resource_packs" "${DATA}/" || true
  rsync -a --delete "${TMPD}/data/behavior_packs" "${DATA}/" || true
  rsync -a "${TMPD}/data/worlds/world/world_resource_packs.json" "${DATA}/worlds/world/" || true
  rsync -a "${TMPD}/data/worlds/world/world_behavior_packs.json" "${DATA}/worlds/world/" || true
else
  echo "[INFO] skipping addons restore; will apply host-provided addons at next boot"
fi

rm -rf "${TMPD}"
chown -R "$(id -u)":"$(id -g)" "${OBJ}"

echo "[INFO] starting stack..."
if [[ -f "${COMPOSE}" ]]; then docker compose -f "${COMPOSE}" up -d; fi

echo "[OK] 復元完了（アドオン含め=${RESTORE_ADDONS}）"
