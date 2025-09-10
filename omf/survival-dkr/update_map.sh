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

# GitHub API から unmined の CLI jar を取得
download_cli() {
  # 候補1: 直リンクの .jar
  url=$(curl -fsSL https://api.github.com/repos/unminednet/unmined/releases/latest \
    | jq -r '.assets[]?.browser_download_url' \
    | grep -iE 'unmined-?cli.*\.jar$' | head -n1)
  if [ -z "$url" ]; then
    # 候補2: zip内 .jar
    zipurl=$(curl -fsSL https://api.github.com/repos/unminednet/unmined/releases/latest \
      | jq -r '.assets[]?.browser_download_url' \
      | grep -iE 'unmined-?cli.*\.zip$' | head -n1)
    [ -n "$zipurl" ] || return 1
    tmp=$(mktemp -d)
    curl -fsSL -o "$tmp/cli.zip" "$zipurl" || { rm -rf "$tmp"; return 1; }
    unzip -qo "$tmp/cli.zip" -d "$tmp/z" || { rm -rf "$tmp"; return 1; }
    found=$(find "$tmp/z" -type f -iname 'unmined*cli*.jar' | head -n1 || true)
    [ -n "$found" ] || { rm -rf "$tmp"; return 1; }
    cp -f "$found" "${CLI_JAR}"
    rm -rf "$tmp"
    return 0
  else
    curl -fsSL -o "${CLI_JAR}" "$url" || return 1
    return 0
  fi
}

if [[ ! -f "${CLI_JAR}" ]]; then
  echo "[update_map] downloading uNmINeD CLI via GitHub API ..."
  if ! download_cli; then
    echo "[update_map] 自動DLに失敗。手動で ${CLI_JAR} を配置してください。"
    exit 0
  fi
fi

echo "[update_map] rendering map from: ${WORLD}"
java -jar "${CLI_JAR}" render \
  --world "${WORLD}" \
  --output "${OUT}" \
  --zoomlevels 1-4 || true

echo "[update_map] done -> ${OUT}"
