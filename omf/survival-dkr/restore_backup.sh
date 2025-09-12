#!/usr/bin/env bash
# バックアップ復元（一覧から選択）※アドオンは復元対象外。起動時に現行ホストのアドオンを再適用します。
set -euo pipefail
BASE="$(cd "$(dirname "$0")" && pwd)"
OBJ="${BASE}/obj"
DATA="${OBJ}/data"
BKP="${BASE}/backups"
COMPOSE="${OBJ}/docker/compose.yml"

shopt -s nullglob
files=( "${BKP}"/backup-*.tar.gz )
if (( ${#files[@]} == 0 )); then
  echo "[ERR] backups not found in ${BKP}"
  exit 1
fi

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
if ! [[ "$sel" =~ ^[0-9]+$ ]] || (( sel < 1 || sel > ${#files[@]} )); then
  echo "[ERR] invalid selection"; exit 2
fi
target="${files[$((sel-1))]}"

echo "[WARN] サーバーを停止して復元します。続行しますか？ (yes/no)"
read -r ans
if [[ "${ans}" != "yes" ]]; then
  echo "中止しました"; exit 0
fi

echo "[INFO] stopping stack..."
if [[ -f "${COMPOSE}" ]]; then
  docker compose -f "${COMPOSE}" down || true
fi

echo "[INFO] restoring from: ${target}"
mkdir -p "${OBJ}"
cd "${OBJ}"

# 既存 world/db を削除してから展開（addon ディレクトリと world_*_packs.json は触らない）
rm -rf "${DATA}/worlds/world/db"
mkdir -p "${DATA}"
tar -xzf "${target}" -C "${OBJ}"

# 権限修正
chown -R "$(id -u)":"$(id -g)" "${OBJ}"

echo "[INFO] starting stack..."
if [[ -f "${COMPOSE}" ]]; then
  docker compose -f "${COMPOSE}" up -d
fi

echo "[OK] 復元完了（アドオンは現行ホストの内容を起動時に再適用）"
