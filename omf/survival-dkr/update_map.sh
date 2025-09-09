#!/usr/bin/env bash
set -euo pipefail
BASE_DIR="$(cd "$(dirname "$0")" && pwd)"
DATA="${BASE_DIR}/obj/data"
WORLD="${DATA}/worlds/world"
OUT="${DATA}/map"

# uNmINeD CLI が無い場合は案内（エラーではなく情報）
if ! command -v unmined-cli >/dev/null 2>&1; then
  echo "[update_map] uNmINeD CLI が見つかりません。インストール例:"
  echo "  sudo apt-get install -y openjdk-17-jre-headless  # 例: Java が必要な版"
  echo "  # または公式の CLI バイナリを取得して PATH へ配置"
  echo "手動で OUT=${OUT} に index.html を出力してください。"
  exit 0
fi

mkdir -p "${OUT}"
echo "[update_map] rendering map from: ${WORLD}"
unmined-cli render \
  --world "${WORLD}" \
  --output "${OUT}" \
  --zoomlevels 1-4 || true

echo "[update_map] done -> ${OUT}"
