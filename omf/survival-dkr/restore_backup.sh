#!/usr/bin/env bash
set -euo pipefail
BASE_DIR="$(cd "$(dirname "$0")" && pwd)"
DATA="${BASE_DIR}/obj/data"
SRC="${BASE_DIR}/backups"
echo "== バックアップ一覧 =="
select f in $(ls -1 ${SRC}/backup-*.tar.zst 2>/dev/null | sort); do
  [ -n "$f" ] || { echo "選択なし"; exit 1; }
  echo "選択: $f"; break
done
read -rp "アドオンも復元しますか？ [y/N]: " yn
WITH_ADDONS=false; [[ "$yn" =~ ^[Yy]$ ]] && WITH_ADDONS=true
tmp="$(mktemp -d)"; trap 'rm -rf "$tmp"' EXIT
tar -I zstd -xf "$f" -C "$tmp"
mkdir -p "$DATA"; rsync -a --delete "$tmp/data/" "$DATA/"
if [ "$WITH_ADDONS" != "true" ]; then
  rm -rf "$DATA/behavior_packs" "$DATA/resource_packs"
  rm -f "$DATA/worlds/world/world_behavior_packs.json" "$DATA/worlds/world/world_resource_packs.json"
fi
echo "[restore] done."
