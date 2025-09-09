#!/usr/bin/env bash
set -euo pipefail
BASE_DIR="$(cd "$(dirname "$0")" && pwd)"
DATA="${BASE_DIR}/obj/data"
WORLD="${DATA}/worlds/world"
OUT="${DATA}/map"
if ! command -v unmined-cli >/dev/null 2>&1; then
  echo "[update_map] uNmINeD CLI が見つかりません。例: sudo apt-get install -y openjdk-17-jre-headless"
  echo "手動で OUT=${OUT} に index.html を出力してください。"; exit 0
fi
mkdir -p "${OUT}"
echo "[update_map] rendering map from: ${WORLD}"
unmined-cli render --world "${WORLD}" --output "${OUT}" --zoomlevels 1-4 || true
echo "[update_map] done -> ${OUT}"
