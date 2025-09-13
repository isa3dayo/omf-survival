#!/usr/bin/env bash
set -euo pipefail
BASE_DIR="$(cd "$(dirname "$0")" && pwd)"
DATA="${BASE_DIR}/obj/data"
DEST="${BASE_DIR}/backups"
TS="$(date +%Y%m%d-%H%M%S)"

INCLUDE_ADDONS="${INCLUDE_ADDONS:-true}"  # true=アドオン含む / false=除外

mkdir -p "$DEST"
OUT="${DEST}/backup-${TS}.tar.zst"

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

# 収集対象
rsync -a --exclude 'map/*' --exclude 'content.log*' "$DATA/" "$tmp/data/"

if [ "${INCLUDE_ADDONS}" != "true" ]; then
  rm -rf "$tmp/data/behavior_packs" "$tmp/data/resource_packs"
  rm -f "$tmp/data/worlds/world/world_behavior_packs.json" "$tmp/data/worlds/world/world_resource_packs.json"
fi

tar -I 'zstd -19 -T0' -cf "$OUT" -C "$tmp" data
echo "[backup] created: $OUT"
