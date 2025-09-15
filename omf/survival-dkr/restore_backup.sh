#!/usr/bin/env bash
# 対話式復元：バックアップ選択 → 「アドオンも復元するか」を選択
set -euo pipefail
USER_NAME="${SUDO_USER:-$USER}"
HOME_DIR="$(getent passwd "$USER_NAME" | cut -d: -f6)"
BASE="${HOME_DIR}/omf/survival-dkr"
OBJ="${BASE}/obj"
DATA="${OBJ}/data"
BKP_OUTER="${BASE}/backups"
DOCKER_DIR="${OBJ}/docker"

choose_backup() {
  echo "[restore] available backups:"
  mapfile -t BKPS < <(ls -1t "${BKP_OUTER}"/backup-*.tgz 2>/dev/null || true)
  if [ "${#BKPS[@]}" -eq 0 ]; then echo "no backups"; exit 1; fi
  local i=1
  for f in "${BKPS[@]}"; do
    # metadata.json の created_at を表示（あれば）
    local ts="$(tar -tzf "$f" 2>/dev/null | grep -m1 '^metadata\.json$' >/dev/null && tar -xOzf "$f" metadata.json | jq -r '.created_at' 2>/dev/null || echo -n '')"
    printf " %2d) %s %s\n" "$i" "$(basename "$f")" "${ts:+($ts)}"
    i=$((i+1))
  done
  echo -n "select number: "
  read -r num
  if ! [[ "$num" =~ ^[0-9]+$ ]] || [ "$num" -lt 1 ] || [ "$num" -gt "${#BKPS[@]}" ]; then
    echo "invalid selection"; exit 1
  fi
  echo -n "${BKPS[$((num-1))]}"
}

BKP_FILE="${1:-}"
if [ -z "${BKP_FILE}" ]; then
  BKP_FILE="$(choose_backup)"
fi
[ -f "${BKP_FILE}" ] || { echo "backup not found: ${BKP_FILE}"; exit 1; }

echo -n "Restore addons as well? (y/N): "
read -r RESTORE_ADDONS
RESTORE_ADDONS="$(echo "${RESTORE_ADDONS:-N}" | tr 'A-Z' 'a-z')"
INCLUDE_ADDONS=false
if [ "${RESTORE_ADDONS}" = "y" ] || [ "${RESTORE_ADDONS}" = "yes" ]; then INCLUDE_ADDONS=true; fi

echo "[restore] stopping stack (if any)..."
if [ -f "${DOCKER_DIR}/compose.yml" ]; then
  sudo docker compose -f "${DOCKER_DIR}/compose.yml" down --remove-orphans || true
fi
for c in bds bds-monitor bds-web; do sudo docker rm -f "$c" >/devnull 2>&1 || true; done || true

echo "[restore] extracting..."
WORK="$(mktemp -d)"; trap 'rm -rf "$WORK"' EXIT
tar -C "${WORK}" -xzf "${BKP_FILE}"

# data を展開
mkdir -p "${DATA}"
if $INCLUDE_ADDONS; then
  rsync -a "${WORK}/data/" "${DATA}/"
else
  # addons と world_* を除外して上書き
  rsync -a \
    --exclude "resource_packs" \
    --exclude "behavior_packs" \
    --exclude "world_resource_packs.json" \
    --exclude "world_behavior_packs.json" \
    "${WORK}/data/" "${DATA}/"
fi

# ホスト側の原本も、選択に応じて復元
if $INCLUDE_ADDONS; then
  if [ -d "${WORK}/host_resource" ]; then
    mkdir -p "${BASE}/resource"; rsync -a "${WORK}/host_resource/" "${BASE}/resource/"
  fi
  if [ -d "${WORK}/host_behavior" ]; then
    mkdir -p "${BASE}/behavior"; rsync -a "${WORK}/host_behavior/" "${BASE}/behavior/"
  fi
fi

echo "[restore] done."
echo "※ アドオン除外で復元した場合は、次回起動時にホスト由来のアドオンのみが world_* に反映されます。"
