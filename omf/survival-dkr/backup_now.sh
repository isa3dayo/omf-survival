#!/usr/bin/env bash
set -euo pipefail
BASE_DIR="$(cd "$(dirname "$0")" && pwd)"
DATA="${BASE_DIR}/obj/data"
BACKUP_DIR="${DATA}/backups"
KEEP_DAYS="${KEEP_DAYS:-7}"
ts="$(date +%Y%m%d_%H%M%S)"
mkdir -p "${BACKUP_DIR}"
cd "${DATA}"
tar czf "${BACKUP_DIR}/world_backup_${ts}.tgz" worlds || true
find "${BACKUP_DIR}" -type f -name 'world_backup_*.tgz' -mtime +${KEEP_DAYS} -print -delete || true
echo "[backup] done: ${BACKUP_DIR}/world_backup_${ts}.tgz (keep ${KEEP_DAYS}d)"
