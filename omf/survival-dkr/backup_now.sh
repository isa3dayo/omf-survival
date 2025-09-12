#!/usr/bin/env bash
# ワールド安全バックアップ（停止→打包→再起動）
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

echo "[INFO] packing world & configs (addons excluded)..."
cd "${OBJ}"
tar -czf "${BKP}/${name}" \
  --warning=no-file-changed \
  data/worlds/world/db \
  data/server.properties \
  data/allowlist.json \
  data/permissions.json \
  data/chat.json \
  data/players.json \
  data/map

echo "[INFO] starting BDS..."
if [[ -f "${COMPOSE}" ]]; then
  docker compose -f "${COMPOSE}" start bds || docker compose -f "${COMPOSE}" up -d bds
fi
echo "[OK] ${BKP}/${name}"
