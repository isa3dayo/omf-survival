#!/usr/bin/env bash
set -euo pipefail
BASE_DIR="$(cd "$(dirname "$0")" && pwd)"
DATA="${BASE_DIR}/obj/data"
WORLD="${DATA}/worlds/world"
OUT="${DATA}/map"
CLI_DIR="${BASE_DIR}/obj/tools/unmined"
CLI_JAR="${CLI_DIR}/unmined-cli.jar"

mkdir -p "${CLI_DIR}" "${OUT}"

# Java が無ければ導入
if ! command -v java >/dev/null 2>&1; then
  echo "[update_map] installing OpenJDK headless..."
  sudo apt-get update -y
  sudo apt-get install -y --no-install-recommends openjdk-17-jre-headless
fi

# CLI 未取得ならダウンロード（ベストエフォート：URL候補を順に試す）
if [[ ! -f "${CLI_JAR}" ]]; then
  echo "[update_map] downloading uNmINeD CLI ..."
  TMP="$(mktemp -d)"
  ok=""
  for u in \
    "https://unmined.net/download/unmined-cli-latest.zip" \
    "https://github.com/unminednet/unmined/releases/latest/download/unmined-cli.zip" \
  ; do
    if curl -fsSL -o "${TMP}/cli.zip" "$u"; then
      if unzip -qo "${TMP}/cli.zip" -d "${TMP}/cli"; then
        found="$(find "${TMP}/cli" -type f -name 'unmined-cli*.jar' | head -n1 || true)"
        if [[ -n "${found}" ]]; then
          cp -f "${found}" "${CLI_JAR}"
          ok="yes"; break
        fi
      fi
    fi
  done
  rm -rf "${TMP}"
  if [[ -z "${ok}" ]]; then
    echo "[update_map] 自動DLに失敗。手動で ${CLI_JAR} を配置してください。"; exit 0
  fi
fi

echo "[update_map] rendering map from: ${WORLD}"
java -jar "${CLI_JAR}" render \
  --world "${WORLD}" \
  --output "${OUT}" \
  --zoomlevels 1-4 || true

echo "[update_map] done -> ${OUT}"
