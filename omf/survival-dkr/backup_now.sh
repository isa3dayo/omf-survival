#!/usr/bin/env bash
# ワールド安全バックアップ（停止→rsync→再起動）
set -euo pipefail
BASE="$(cd "$(dirname "$0")" && pwd)"
OBJ="${BASE}/obj"
DATA="${OBJ}/data"
BKP="${BASE}/backups"
COMPOSE="${OBJ}/docker/compose.yml"

mkdir -p "${BKP}"
ts="$(date +%Y%m%d-%H%M%S)"
name="backup-${ts}.tar.gz"

echo "[INFO] stopping BDS..."
if [[ -f "${COMPOSE}" ]]; then
  docker compose -f "${COMPOSE}" stop bds || true
fi

echo "[INFO] packing world & map..."
cd "${OBJ}"
tar -czf "${BKP}/${name}" \
  --warning=no-file-changed \
  data/worlds/world \
  data/map \
  data/server.properties \
  data/allowlist.json \
  data/permissions.json \
  data/worlds/world/world_behavior_packs.json \
  data/worlds/world/world_resource_packs.json

echo "[INFO] starting BDS..."
if [[ -f "${COMPOSE}" ]]; then
  docker compose -f "${COMPOSE}" start bds || docker compose -f "${COMPOSE}" up -d bds
fi
echo "[OK] ${BKP}/${name}"
