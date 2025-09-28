# ------------------------------------
# <セクション番号:1> ヘッダ / 変数定義
# ------------------------------------

#!/usr/bin/env bash
# =====================================================================
# OMFS installer（差分更新版 / restartポリシー撤去 / バックアップ同梱）
#  - BDS: 公式APIのダウンロードURLが「変わったときだけ」取得・展開（失敗時は温存）
#  - uNmINeD: downloads をスクレイピングして ARM64 glibc の URL 差分更新
#  - Webポータル: /webchat・URL param (token,name) 必須・新UI・モバイル最適化
#      * token/name 未指定なら「白紙＋『ページを開けません』のみ」表示（タブ等なし）
#  - monitor: /players /chat /webchat /allowlist/*、OMF-CHAT/OMF-DEATH 取り込み
#      * 死亡ログは 1件に集約して返却（meta_left=座標, meta_right=死因, 本文=◯◯さんが死亡…）
#  - アドオン同期: ~/omf/survival-dkr/{resource,behavior} → obj/data/* へコピー
#                  world_*_packs.json はホスト由来のみで再生成（Vanilla 等は適用しない）
#                  world_*_packs.json の出力位置は /data/worlds/world/（適用必須パス）
#  - GAS通知: 日次窓 07:50〜25:10 で、プレイヤーごと当日初回入室時に送信
#  - compose.yml: restart ポリシー記述なし（自動再起動せず、cron 管理向け）
#  - バックアップ: BASE/backups に “アドオン同梱” で作成。復元時にアドオン除外/同梱を選択可
#  - ビルトイン保護: .omfs_builtin マーカー + .builtin_packs.json を維持
#  - 初期コマンド: 起動時に FIFO で gamerule（座標 ON / 1人就寝で朝）を投入
# =====================================================================
set -euo pipefail

# ---------- 変数 ----------
USER_NAME="${SUDO_USER:-$USER}"
HOME_DIR="$(getent passwd "$USER_NAME" | cut -d: -f6)"
BASE="${HOME_DIR}/omf/survival-dkr"
OBJ="${BASE}/obj"
DOCKER_DIR="${OBJ}/docker"
DATA_DIR="${OBJ}/data"
BKP_OUTER_DIR="${BASE}/backups"   # ALL_CLEAN 対象外（温存）
WEB_SITE_DIR="${DOCKER_DIR}/web/site"
TOOLS_DIR="${OBJ}/tools"
KEY_FILE="${BASE}/key/key.conf"
HOST_RESOURCE_DIR="${BASE}/resource"
HOST_BEHAVIOR_DIR="${BASE}/behavior"

mkdir -p "${DOCKER_DIR}" "${DATA_DIR}" "${BKP_OUTER_DIR}" "${WEB_SITE_DIR}" "${TOOLS_DIR}" \
         "${HOST_RESOURCE_DIR}" "${HOST_BEHAVIOR_DIR}"
sudo chown -R "${USER_NAME}:${USER_NAME}" "${BASE}" || true

[[ -f "${KEY_FILE}" ]] || { echo "[ERR] key.conf が見つかりません: ${KEY_FILE}"; exit 1; }
# shellcheck disable=SC1090
source "${KEY_FILE}"

# Discord
##################################################
# --- optional vars defaults (set -u 安全策) ---
#: "${PHONE_SIGNAL_PREFIX:='[PHONE]'}"
#: "${KEEPALIVE_TIMEOUT_SEC:=60}"
#: "${CHAT_JSON_PATH:=/data-ro/obj/data/chat.json}"
##################################################

: "${SERVER_NAME:?SERVER_NAME を key.conf に設定してください}"
: "${API_TOKEN:?API_TOKEN を key.conf に設定してください}"
: "${GAS_URL:?GAS_URL を key.conf に設定してください}"

# ポート/設定（必要に応じて key.conf で上書き可）
BDS_PORT_PUBLIC_V4="${BDS_PORT_PUBLIC_V4:-13922}"
BDS_PORT_V6="${BDS_PORT_V6:-19132}"
MONITOR_BIND="${MONITOR_BIND:-127.0.0.1}"
MONITOR_PORT="${MONITOR_PORT:-13900}"
WEB_BIND="${WEB_BIND:-0.0.0.0}"
WEB_PORT="${WEB_PORT:-13901}"
BDS_URL="${BDS_URL:-}"                 # 固定ダウンロードURL（空なら公式API, 差分更新）
ALLOWLIST_ON="${ALLOWLIST_ON:-true}"
ALLOWLIST_AUTOADD="${ALLOWLIST_AUTOADD:-true}"
ONLINE_MODE="${ONLINE_MODE:-true}"
AUTH_CHEAT="${AUTH_CHEAT:-member}"     # permissions.json 権限（visitor/member/operator）
SEED_POINT="${SEED_POINT:-}"           # level-seed

BETA_ON="${BETA_ON:-false}"            # 将来切替用のフック（本スクリプトでは未使用）
ENABLE_CHAT_LOGGER="${ENABLE_CHAT_LOGGER:-true}"

ALL_CLEAN="${ALL_CLEAN:-false}"

echo "[INFO] OMFS start user=${USER_NAME} base=${BASE} ALL_CLEAN=${ALL_CLEAN}"

# ----------------------------------------
# <セクション番号:2>既存 stack 停止 / 掃除
# ----------------------------------------

# ---------- 既存 stack 停止/掃除（BACKUPS は温存） ----------
echo "[CLEAN] stopping old stack..."
if [[ -f "${DOCKER_DIR}/compose.yml" ]]; then
  sudo docker compose -f "${DOCKER_DIR}/compose.yml" down --remove-orphans || true
fi
for c in bds bds-monitor bds-web; do sudo docker rm -f "$c" >/dev/null 2>&1 || true; done

if [[ "${ALL_CLEAN}" == "true" ]]; then
  sudo docker system prune -a -f || true
  rm -rf "${OBJ}"
else
  sudo docker system prune -f || true
fi
mkdir -p "${DOCKER_DIR}" "${DATA_DIR}" "${BKP_OUTER_DIR}" "${WEB_SITE_DIR}" "${TOOLS_DIR}"
sudo chown -R "${USER_NAME}:${USER_NAME}" "${OBJ}" || true

# ----------------------------------
# <セクション番号:3>apt セットアップ
# ----------------------------------

# ---------- apt ----------
echo "[SETUP] apt..."
sudo apt-get update -y
sudo apt-get install -y --no-install-recommends ca-certificates curl wget jq unzip git tzdata xz-utils build-essential rsync cmake ninja-build python3 procps file

# ---------------------------
# <セクション番号:4>.env 出力
# ---------------------------

# ---------- .env ----------
cat > "${DOCKER_DIR}/.env" <<ENV
TZ=Asia/Tokyo
GAS_URL=${GAS_URL}
API_TOKEN=${API_TOKEN}
SERVER_NAME=${SERVER_NAME}
BDS_PORT_PUBLIC_V4=${BDS_PORT_PUBLIC_V4}
BDS_PORT_V6=${BDS_PORT_V6}
MONITOR_PORT=${MONITOR_PORT}
WEB_PORT=${WEB_PORT}
BDS_URL=${BDS_URL}
ALLOWLIST_ON=${ALLOWLIST_ON}
ALLOWLIST_AUTOADD=${ALLOWLIST_AUTOADD}
ONLINE_MODE=${ONLINE_MODE}
AUTH_CHEAT=${AUTH_CHEAT}
SEED_POINT=${SEED_POINT}
ENABLE_CHAT_LOGGER=${ENABLE_CHAT_LOGGER}
ENV

# Discord
#########################################################
# --- Discord PhoneBot ---
#DISCORD_BOT_TOKEN=${DISCORD_BOT_TOKEN}
#DISCORD_GUILD_ID=${DISCORD_GUILD_ID}
#DISCORD_CATEGORY_ID=${DISCORD_CATEGORY_ID}
#DISCORD_OPEN_VC_CHANNEL_ID=${DISCORD_OPEN_VC_CHANNEL_ID}
#DISCORD_LINK_CHANNEL_ID=${DISCORD_LINK_CHANNEL_ID}
#PHONE_SIGNAL_PREFIX=[PHONE]
#KEEPALIVE_TIMEOUT_SEC=${KEEPALIVE_TIMEOUT_SEC:-60}
#CHAT_JSON_PATH=/data-ro/obj/data/chat.json
#ENV
##########################################################

# -----------------------------------------
# <セクション番号:5>docker-compose.yml 出力
# -----------------------------------------

# ---------- compose（restart: は一切書かない） ----------
cat > "${DOCKER_DIR}/compose.yml" <<YAML
services:
  bds:
    build: { context: ./bds }
    image: local/bds-box64:latest
    container_name: bds
    env_file: .env
    environment:
      TZ: \${TZ}
      SERVER_NAME: \${SERVER_NAME}
      GAS_URL: \${GAS_URL}
      API_TOKEN: \${API_TOKEN}
      BDS_URL: \${BDS_URL}
      BDS_PORT_V4: \${BDS_PORT_PUBLIC_V4}
      BDS_PORT_V6: \${BDS_PORT_V6}
      ALLOWLIST_ON: \${ALLOWLIST_ON}
      ONLINE_MODE: \${ONLINE_MODE}
      SEED_POINT: \${SEED_POINT}
      ENABLE_CHAT_LOGGER: \${ENABLE_CHAT_LOGGER}
    volumes:
      - ../data:/data
      - ../../resource:/host-resource:ro
      - ../../behavior:/host-behavior:ro
    ports:
      - "\${BDS_PORT_PUBLIC_V4}:\${BDS_PORT_PUBLIC_V4}/udp"
      - "\${BDS_PORT_V6}:\${BDS_PORT_V6}/udp"

  monitor:
    build: { context: ./monitor }
    image: local/bds-monitor:latest
    container_name: bds-monitor
    env_file: .env
    environment:
      TZ: \${TZ}
      SERVER_NAME: \${SERVER_NAME}
      API_TOKEN: \${API_TOKEN}
      GAS_URL: \${GAS_URL}
      ALLOWLIST_AUTOADD: \${ALLOWLIST_AUTOADD}
      AUTH_CHEAT: \${AUTH_CHEAT}
    volumes:
      - ../data:/data
    ports:
      - "${MONITOR_BIND}:${MONITOR_PORT}:13900/tcp"
    depends_on:
      bds:
        condition: service_started

  web:
    build: { context: ./web }
    image: local/bds-web:latest
    container_name: bds-web
    env_file: .env
    environment:
      TZ: \${TZ}
      MONITOR_INTERNAL: http://bds-monitor:13900
    volumes:
      - ./web/nginx.conf:/etc/nginx/conf.d/default.conf:ro
      - ./web/site:/usr/share/nginx/html:ro
      - ../data:/data-ro:ro          # ★追加：OBJ/data を read-only で公開
      - ../data/map:/data-map:ro
    ports:
      - "${WEB_BIND}:${WEB_PORT}:80"
    depends_on:
      monitor:
        condition: service_started
YAML

# Discord
#############################################################
#  phonebot:
#    build: { context: ./phonebot }
#    image: local/phonebot:latest
#    container_name: phonebot
#    env_file: .env
#    environment:
#      TZ: \${TZ}
#      PHONE_SIGNAL_PREFIX: \${PHONE_SIGNAL_PREFIX}
#      KEEPALIVE_TIMEOUT_SEC: \${KEEPALIVE_TIMEOUT_SEC}
#      CHAT_JSON_PATH: \${CHAT_JSON_PATH}
#      DISCORD_BOT_TOKEN: \${DISCORD_BOT_TOKEN}
#      DISCORD_GUILD_ID: \${DISCORD_GUILD_ID}
#      DISCORD_CATEGORY_ID: \${DISCORD_CATEGORY_ID}
#      DISCORD_OPEN_VC_CHANNEL_ID: \${DISCORD_OPEN_VC_CHANNEL_ID}
#      DISCORD_LINK_CHANNEL_ID: \${DISCORD_LINK_CHANNEL_ID}
#    volumes:
#      - ../data:/data-ro:ro
#      - ./phonebot/config.json:/app/config.json:ro
#    depends_on:
#      monitor:
#        condition: service_started
#YAML
#############################################################

# -------------------------------------------------------------------------------------------
# <セクション番号:6>BDS イメージ関連 (Dockerfile, get_bds.sh, update_addons.py, entry-bds.sh)
# -------------------------------------------------------------------------------------------

# ---------- bds イメージ ----------
mkdir -p "${DOCKER_DIR}/bds"

cat > "${DOCKER_DIR}/bds/Dockerfile" <<'DOCK'
FROM debian:bookworm-slim
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates curl wget unzip jq xz-utils procps build-essential git cmake ninja-build python3 rsync file \
 && rm -rf /var/lib/apt/lists/*

# box64: 公式BDS(x86_64)をARM等で実行するため
RUN git clone --depth=1 https://github.com/ptitSeb/box64 /tmp/box64 \
 && cmake -S /tmp/box64 -B /tmp/box64/build -G Ninja \
      -DARM_DYNAREC=ON -DDEFAULT_PAGESIZE=16384 -DCMAKE_BUILD_TYPE=RelWithDebInfo \
 && cmake --build /tmp/box64/build -j && cmake --install /tmp/box64/build \
 && rm -rf /tmp/box64

WORKDIR /usr/local/bin
COPY get_bds.sh update_addons.py entry-bds.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/*.sh

WORKDIR /data
EXPOSE 19132/udp 13922/udp
CMD ["/usr/local/bin/entry-bds.sh"]
DOCK

# --- BDS 取得（差分更新方式 + ビルトインpack記録/マーカー設置 + スキップ時復元） ---
cat > "${DOCKER_DIR}/bds/get_bds.sh" <<'BASH'
#!/usr/bin/env bash
set -euo pipefail
mkdir -p /data
cd /data
log(){ echo "[get_bds] $*"; }

API="https://net-secondary.web.minecraft-services.net/api/v1.0/download/links"
LAST="/data/.bds_last_url"
BUILTIN="/data/.builtin_packs.json"

get_url_api(){
  curl --http1.1 -fsSL -H 'Accept: application/json' --retry 3 --retry-delay 2 "$API" \
  | jq -r '.result.links[] | select(.downloadType=="serverBedrockLinux") | .downloadUrl' \
  | head -n1
}
pick_url(){ local url="${BDS_URL:-}"; if [ -z "$url" ]; then url="$(get_url_api || true)"; fi; echo -n "$url"; }

make_builtin_from_markers(){
  python3 - <<'PY'
import os, json
DATA="/data"
def scan(base):
    out=[]
    p=os.path.join(DATA,base)
    if not os.path.isdir(p): return out
    for name in sorted(os.listdir(p)):
        d=os.path.join(p,name)
        if not os.path.isdir(d): continue
        if not os.path.exists(os.path.join(d,".omfs_builtin")): continue
        mf=os.path.join(d,"manifest.json")
        uuid=""
        try:
            uuid=json.load(open(mf,"r",encoding="utf-8")).get("header",{}).get("uuid","")
        except: pass
        out.append({"name":name,"pack_id":uuid})
    return out
out={"resource":scan("resource_packs"),"behavior":scan("behavior_packs")}
tmp=os.path.join(DATA,".builtin_packs.json.tmp")
open(tmp,"w",encoding="utf-8").write(json.dumps(out,ensure_ascii=False,indent=2))
os.replace(tmp, os.path.join(DATA,".builtin_packs.json"))
print("[get_bds] rebuilt .builtin_packs.json from markers")
PY
}

URL="$(pick_url)"
if [ -z "$URL" ]; then
  if [ -x ./bedrock_server ]; then
    log "WARN: could not get URL; keep existing bedrock_server"
    [ -f "$BUILTIN" ] || make_builtin_from_markers || true
    exit 0
  else
    log "ERROR: could not obtain BDS url (no existing server)"
    exit 10
  fi
fi

if [ -f "$LAST" ] && [ "$(cat "$LAST" 2>/dev/null || true)" = "$URL" ] && [ -x ./bedrock_server ]; then
  log "URL unchanged; skip download"
  [ -f "$BUILTIN" ] || make_builtin_from_markers || true
  exit 0
fi

tmp="$(mktemp -d)"
log "downloading: ${URL}"
if ! wget -q -O "$tmp/bds.zip" "${URL}"; then
  if ! curl --http1.1 -fL -o "$tmp/bds.zip" "${URL}"; then
    if [ -x ./bedrock_server ]; then
      log "WARN: download failed; keep existing bedrock_server"
      [ -f "$BUILTIN" ] || make_builtin_from_markers || true
      rm -rf "$tmp"; exit 0
    else
      log "ERROR: download failed (no existing server)"
      rm -rf "$tmp"; exit 11
    fi
  fi
fi

# 展開：server.properties / allowlist.json は上書きしない
unzip -qo "$tmp/bds.zip" -x server.properties allowlist.json || {
  if [ -x ./bedrock_server ]; then
    log "WARN: unzip failed; keep existing"
    [ -f "$BUILTIN" ] || make_builtin_from_markers || true
    rm -rf "$tmp"; exit 0
  else
    log "ERROR: unzip failed (no existing)"; rm -rf "$tmp"; exit 12
  fi
}

# ビルトイン pack のマーカーと一覧を作る
rp_list="$tmp/rp.list"; bp_list="$tmp/bp.list"
unzip -Z1 "$tmp/bds.zip" 2>/dev/null | grep -E '^resource_packs/[^/]+/manifest\.json$' \
 | sed 's#^resource_packs/\([^/]\+\)/manifest\.json$#\1#' | sort -u > "$rp_list" || true
unzip -Z1 "$tmp/bds.zip" 2>/dev/null | grep -E '^behavior_packs/[^/]+/manifest\.json$' \
 | sed 's#^behavior_packs/\([^/]\+\)/manifest\.json$#\1#' | sort -u > "$bp_list" || true

while read -r n; do
  [ -n "${n:-}" ] || continue
  [ -d "/data/resource_packs/$n" ] && touch "/data/resource_packs/$n/.omfs_builtin" || true
done < "$rp_list"
while read -r n; do
  [ -n "${n:-}" ] || continue
  [ -d "/data/behavior_packs/$n" ] && touch "/data/behavior_packs/$n/.omfs_builtin" || true
done < "$bp_list"

python3 - "$rp_list" "$bp_list" <<'PY'
import os,sys,json
DATA="/data"
def uuid_of(base,name):
    mf=os.path.join(DATA,base,name,"manifest.json")
    try: return json.load(open(mf,"r",encoding="utf-8")).get("header",{}).get("uuid","")
    except: return ""
def read_list(p):
    try: return [x.strip() for x in open(p,"r",encoding="utf-8").read().splitlines() if x.strip()]
    except: return []
rp=read_list(sys.argv[1]); bp=read_list(sys.argv[2])
out={"resource":[{"name":n,"pack_id":uuid_of("resource_packs",n)} for n in rp],
     "behavior":[{"name":n,"pack_id":uuid_of("behavior_packs",n)} for n in bp]}
tmp=os.path.join(DATA,".builtin_packs.json.tmp")
open(tmp,"w",encoding="utf-8").write(json.dumps(out,ensure_ascii=False,indent=2))
os.replace(tmp, os.path.join(DATA,".builtin_packs.json"))
print("[get_bds] wrote builtin list:", os.path.join(DATA,".builtin_packs.json"))
PY

rm -rf "$tmp"
echo -n "$URL" > "$LAST"
log "updated BDS payload and builtin markers/list"
BASH

# --- アドオン同期（ビルトイン保護 + ホスト同期 + world_* はホストのみ／world配下へ出力） ---
cat > "${DOCKER_DIR}/bds/update_addons.py" <<'PY'
import os, json, re, shutil

ROOT="/data"
BP=os.path.join(ROOT,"behavior_packs")
RP=os.path.join(ROOT,"resource_packs")
WORLD_DIR=os.path.join(ROOT,"worlds","world")
WBP=os.path.join(WORLD_DIR,"world_behavior_packs.json")
WRP=os.path.join(WORLD_DIR,"world_resource_packs.json")
BUILTIN=os.path.join(ROOT,".builtin_packs.json")

HOST_R="/host-resource"
HOST_B="/host-behavior"

def ensure_dir(p): os.makedirs(p, exist_ok=True)
def load_json(p, default):
    try: return json.load(open(p,"r",encoding="utf-8"))
    except: return default
def list_dirs(d):
    if not os.path.isdir(d): return []
    return sorted([n for n in os.listdir(d) if os.path.isdir(os.path.join(d,n))])
def is_builtin_dir(base, name):
    return os.path.exists(os.path.join(base, name, ".omfs_builtin"))

def build_builtin_sets():
    j=load_json(BUILTIN, {"resource":[],"behavior":[]})
    rp=set([x.get("name","") for x in j.get("resource",[]) if x.get("name")])
    bp=set([x.get("name","") for x in j.get("behavior",[]) if x.get("name")])
    for n in list_dirs(RP):
        if is_builtin_dir(RP, n): rp.add(n)
    for n in list_dirs(BP):
        if is_builtin_dir(BP, n): bp.add(n)
    return rp, bp

def rsync_tree(src, dst):
    if not os.path.isdir(src): return
    for root, _, files in os.walk(src):
        rel=os.path.relpath(root, src)
        out=os.path.join(dst, rel) if rel!="." else dst
        os.makedirs(out, exist_ok=True)
        for f in files:
            shutil.copy2(os.path.join(root,f), os.path.join(out,f))

def apply_sync(host_dir, data_dir, builtin_names):
    ensure_dir(data_dir)
    cur=set(list_dirs(data_dir))
    host=set(list_dirs(host_dir)) if os.path.isdir(host_dir) else set()
    builtin=set(builtin_names)

    # remove: hostに無くビルトインでもないもの
    for name in sorted(cur - builtin - host):
        try:
            shutil.rmtree(os.path.join(data_dir,name))
            print(f"[addons] removed: {name}")
        except: pass

    # add/update: host -> data（ビルトインには上書きしない）
    for name in sorted(host):
        s=os.path.join(host_dir,name); d=os.path.join(data_dir,name)
        if os.path.isdir(d): rsync_tree(s, d)
        else: shutil.copytree(s, d)
        print(f"[addons] synced: {name}")

def scan_world(host_dir, typ):
    out=[]
    if not os.path.isdir(host_dir): return out
    for name in sorted(os.listdir(host_dir)):
        p=os.path.join(host_dir,name); mf=os.path.join(p,"manifest.json")
        if not (os.path.isdir(p) and os.path.isfile(mf)): continue
        try:
            s=open(mf,"r",encoding="utf-8").read()
            s=re.sub(r'//.*','',s); s=re.sub(r'/\*.*?\*/','',s,flags=re.S); s=re.sub(r',\s*([}\]])',r'\1',s)
            j=json.loads(s)
            uuid=j["header"]["uuid"]; ver=j["header"]["version"]
            if not (isinstance(ver,list) and len(ver)==3): raise ValueError
            out.append({"pack_id":uuid,"version":ver,"type":typ})
            print(f"[addons] world include: {typ} {name} {uuid} {ver}")
        except Exception as e:
            print(f"[addons] invalid manifest: {name} ({e})")
    return out

def write_json(p, obj):
    os.makedirs(os.path.dirname(p), exist_ok=True)
    tmp=p+".tmp"
    open(tmp,"w",encoding="utf-8").write(json.dumps(obj,ensure_ascii=False,indent=2))
    os.replace(tmp,p)
    print(f"[addons] wrote {p} ({len(obj)} packs)")

if __name__=="__main__":
    os.makedirs(os.path.join(WORLD_DIR,"db"), exist_ok=True)
    builtin_r, builtin_b = build_builtin_sets()
    apply_sync(HOST_R, RP, builtin_r)
    apply_sync(HOST_B, BP, builtin_b)
    write_json(WBP, scan_world(HOST_B, "data"))
    write_json(WRP, scan_world(HOST_R, "resources"))
PY

# --- エントリ（BDS 起動 / server.properties 整備 / world_* 再生成 / 初期gameruleをFIFO投入） ---
cat > "${DOCKER_DIR}/bds/entry-bds.sh" <<'BASH'
#!/usr/bin/env bash
set -euo pipefail
export TZ="${TZ:-Asia/Tokyo}"
cd /data; mkdir -p /data

if [ ! -f server.properties ]; then
  cat > server.properties <<PROP
server-name=${SERVER_NAME:-OMF}
gamemode=survival
difficulty=normal
allow-cheats=true
max-players=10
online-mode=${ONLINE_MODE:-true}
allow-list=${ALLOWLIST_ON:-true}
server-port=${BDS_PORT_V4:-13922}
server-portv6=${BDS_PORT_V6:-19132}
view-distance=32
tick-distance=4
player-idle-timeout=30
max-threads=4
level-name=world
enable-lan-visibility=true
content-log-file-enabled=true
content-log-file-name=content.log
scripting-enable=false
PROP
  if [ -n "${SEED_POINT:-}" ]; then
    echo "level-seed=${SEED_POINT}" >> server.properties
  fi
else
  sed -i "s/^server-port=.*/server-port=${BDS_PORT_V4:-13922}/" server.properties
  sed -i "s/^server-portv6=.*/server-portv6=${BDS_PORT_V6:-19132}/" server.properties
  sed -i "s/^allow-cheats=.*/allow-cheats=true/" server.properties
  sed -i "s/^online-mode=.*/online-mode=${ONLINE_MODE:-true}/" server.properties
  if grep -q '^allow-list=' server.properties; then
    sed -i "s/^allow-list=.*/allow-list=${ALLOWLIST_ON:-true}/" server.properties
  else
    echo "allow-list=${ALLOWLIST_ON:-true}" >> server.properties
  fi
  sed -i "s/^content-log-file-enabled=.*/content-log-file-enabled=true/" server.properties
  sed -i "s/^content-log-file-name=.*/content-log-file-name=content.log/" server.properties
  if grep -q '^scripting-enable=' server.properties; then
    sed -i "s/^scripting-enable=.*/scripting-enable=false/" server.properties
  else
    echo "scripting-enable=false" >> server.properties
  fi
  if grep -q '^level-seed=' server.properties; then
    if [ -n "${SEED_POINT:-}" ]; then
      sed -i "s/^level-seed=.*/level-seed=${SEED_POINT}/" server.properties
    fi
  else
    if [ -n "${SEED_POINT:-}" ]; then
      echo "level-seed=${SEED_POINT}" >> server.properties
    fi
  fi
fi

[ -f allowlist.json ] || echo "[]" > allowlist.json
[ -f permissions.json ] || echo "[]" > permissions.json
[ -f chat.json ] || echo "[]" > chat.json
[ -d worlds/world/db ] || mkdir -p worlds/world/db
echo "[]" > /data/players.json || true
touch bedrock_server.log bds_console.log
rm -f in.pipe; mkfifo in.pipe

/usr/local/bin/get_bds.sh
python3 /usr/local/bin/update_addons.py || true

# 起動メッセージ（Web 表示用）
python3 - <<'PY' || true
import json,os,datetime
f="/data/chat.json"; d=[]
try:
  if os.path.exists(f): d=json.load(open(f,"r",encoding="utf-8"))
except: d=[]
if not isinstance(d,list): d=[]
d.append({"player":"SYSTEM","message":"サーバーが起動しました","timestamp":datetime.datetime.now().isoformat(),"color":"system"})
d=d[-400:]
open(f,"w",encoding="utf-8").write(json.dumps(d,ensure_ascii=False))
PY

# サーバー起動後に FIFO で初期gamerule投入（座標常時表示 / 1人就寝で朝）
( sleep 5
  {
    echo "gamerule showcoordinates true"
    echo "gamerule playerssleepingpercentage 1"
  } > /data/in.pipe
) &

echo "[entry-bds] exec: box64 ./bedrock_server (stdin: /data/in.pipe)"
( tail -F /data/in.pipe | box64 ./bedrock_server 2>&1 | tee -a /data/bds_console.log ) | tee -a /data/bedrock_server.log
BASH
chmod +x "${DOCKER_DIR}/bds/"*.sh

# ---------------------------------------------------------------
# <セクション番号:7>monitor イメージ関連 (Dockerfile, monitor.py)
# ---------------------------------------------------------------

# ---------- monitor（ログ監視 + OMF-CHAT/DEATH + GAS 通知 + webchat） ----------
mkdir -p "${DOCKER_DIR}/monitor"
cat > "${DOCKER_DIR}/monitor/Dockerfile" <<'DOCK'
FROM python:3.11-slim
RUN apt-get update && apt-get install -y --no-install-recommends ca-certificates curl jq procps \
 && rm -rf /var/lib/apt/lists/*
WORKDIR /app
RUN pip install --no-cache-dir fastapi uvicorn requests pydantic
COPY monitor.py /app/monitor.py
EXPOSE 13900/tcp
CMD ["python","/app/monitor.py"]
DOCK

# ★死亡ログを1件に集約（meta_left=座標, meta_right=死因, 本文=◯◯さんが死亡… / 時刻はフロントで非表示）
cat > "${DOCKER_DIR}/monitor/monitor.py" <<'PY'
import os, json, threading, time, re, datetime, requests
from fastapi import FastAPI, Header, HTTPException
from pydantic import BaseModel
import uvicorn

DATA = "/data"
LOG_BDS  = os.path.join(DATA, "bedrock_server.log")
LOG_CON  = os.path.join(DATA, "bds_console.log")
CHAT = os.path.join(DATA, "chat.json")
PLAY = os.path.join(DATA, "players.json")
ALLOW = os.path.join(DATA, "allowlist.json")
PERM  = os.path.join(DATA, "permissions.json")
FIFO  = os.path.join(DATA, "in.pipe")

API_TOKEN   = os.getenv("API_TOKEN", "")
SERVER_NAME = os.getenv("SERVER_NAME", "OMF")
GAS_URL     = os.getenv("GAS_URL","")
MAX_CHAT    = 400
AUTOADD     = os.getenv("ALLOWLIST_AUTOADD","true").lower()=="true"
ROLE_RAW    = os.getenv("AUTH_CHEAT","member").lower().strip()
ROLE = ROLE_RAW if ROLE_RAW in ("visitor","member","operator") else "member"

WIN_START_HM=(7,50)
WIN_END_HM=(25,10)
JOIN_MARK = os.path.join(DATA, ".first_join_marks.json")

app = FastAPI()
lock = threading.Lock()

def jload(p, d):
    try:
        with open(p, "r", encoding="utf-8") as f:
            return json.load(f)
    except:
        return d

def jdump(p, obj):
    tmp = p + ".tmp"
    with open(tmp, "w", encoding="utf-8") as f:
        json.dump(obj, f, ensure_ascii=False)
    os.replace(tmp, p)

def push_chat(player, message, color="normal", meta_left=None, meta_right=None):
    with lock:
        j = jload(CHAT, [])
        item = {"player": str(player), "message": str(message),
                "timestamp": datetime.datetime.now().isoformat(), "color": color}
        if meta_left is not None: item["meta_left"]=str(meta_left)
        if meta_right is not None: item["meta_right"]=str(meta_right)
        j.append(item)
        j = j[-MAX_CHAT:]
        jdump(CHAT, j)

def set_players(lst):
    with lock:
        jdump(PLAY, sorted(set(lst)))

def add_allowlist(name, xuid, ignores=False):
    with lock:
        arr = jload(ALLOW, [])
    updated=False
    for it in arr:
        if (xuid and it.get("xuid")==xuid) or (it.get("name")==name):
            if xuid and not it.get("xuid"):
                it["xuid"]=xuid; updated=True
            if "ignoresPlayerLimit" not in it:
                it["ignoresPlayerLimit"]=bool(ignores); updated=True
            if updated: jdump(ALLOW, arr)
            return False
    arr.append({"name": name, "xuid": xuid, "ignoresPlayerLimit": bool(ignores)})
    jdump(ALLOW, arr)
    return True

def add_permissions(xuid, role):
    if not xuid: return False
    arr = jload(PERM, [])
    for it in arr:
        if it.get("xuid")==xuid:
            if it.get("permission") != role:
                it["permission"]=role; jdump(PERM, arr)
            return False
    arr.append({"permission": role, "xuid": xuid}); jdump(PERM, arr); return True

RE_JOIN    = re.compile(r'Player connected:\s*([^,]+),\s*xuid:\s*(\d+)')
RE_JOIN_NX = re.compile(r'Player connected:\s*([^,]+)')
RE_LEAVE   = re.compile(r'Player disconnected:\s*([^,]+)')

RE_OMF_CHAT_JSON  = re.compile(r'\[OMF-CHAT\]\s*(\{.*\})')
RE_OMF_CHAT_FAIL  = re.compile(r'\[OMF-CHAT\]\s*particle_ok:\s*burning_combo')
RE_OMF_DEATH_JSON = re.compile(r'\[OMF-DEATH\]\s*(\{.*\})')

def is_in_window():
    now = datetime.datetime.now()
    today = now.date()
    start = datetime.datetime.combine(today, datetime.time(WIN_START_HM[0]%24, WIN_START_HM[1]))
    end_day = today if WIN_END_HM[0] < 24 else (today + datetime.timedelta(days=1))
    end = datetime.datetime.combine(end_day, datetime.time(WIN_END_HM[0]%24, WIN_END_HM[1]))
    return start <= now <= end

def mark_and_notify_first_join(name: str):
    if not GAS_URL: return
    if not is_in_window(): return
    marks = jload(JOIN_MARK, {"date": "", "names": []})
    today_key = datetime.date.today().isoformat()
    if marks.get("date") != today_key:
        marks = {"date": today_key, "names": []}
    if name in marks["names"]:
        return
    try:
        requests.post(GAS_URL, json={"type":"first_join","server":SERVER_NAME,"player":name,
                                     "timestamp":datetime.datetime.now().isoformat()}, timeout=3)
    except: pass
    marks["names"].append(name); jdump(JOIN_MARK, marks)

def tail_file(path, handler):
    # 既存ログ再走査を防ぐ：ファイルがあれば末尾から開始
    try:
        pos = os.path.getsize(path)
    except Exception:
        pos = 0
    while True:
        try:
            with open(path, "r", encoding="utf-8", errors="ignore") as f:
                f.seek(pos, os.SEEK_SET)
                while True:
                    line = f.readline()
                    if not line:
                        pos = f.tell(); time.sleep(0.2); break
                    handler(line.rstrip("\r\n"))
        except FileNotFoundError:
            time.sleep(0.5)
        except Exception:
            time.sleep(0.5)

def handle_console(line, known):
    m = RE_JOIN.search(line)
    if m:
        name = m.group(1).strip(); xuid = m.group(2).strip()
        if name:
            known.add(name); set_players(list(known))
            push_chat("SYSTEM", f"{name} が参加", "system")
            if AUTOADD:
                try:
                    add_allowlist(name, xuid, ignores=False); add_permissions(xuid, ROLE)
                except: pass
            mark_and_notify_first_join(name)
        return

    m = RE_JOIN_NX.search(line)
    if m and not RE_JOIN.search(line):
        name = m.group(1).strip()
        if name:
            known.add(name); set_players(list(known))
            push_chat("SYSTEM", f"{name} が参加", "system")
            if AUTOADD:
                try: add_allowlist(name, "", ignores=False)
                except: pass
            mark_and_notify_first_join(name)
        return

    m = RE_LEAVE.search(line)
    if m:
        name = m.group(1).strip()
        if name and name in known:
            known.discard(name); set_players(list(known))
            push_chat("SYSTEM", f"{name} が退出", "system")
        return

    if RE_OMF_CHAT_FAIL.search(line):
        push_chat("SYSTEM", "誰かの手紙は虚空に消えました。", "system")
        return

    m = RE_OMF_CHAT_JSON.search(line)
    if m:
        try:
            obj = json.loads(m.group(1))
            if obj.get("type")=="note_use":
                player = obj.get("player","名無し"); msg = obj.get("message","")
                if msg: push_chat(player, msg, "normal")
        except: pass
        return

    m = RE_OMF_DEATH_JSON.search(line)
    if m:
        try:
            obj = json.loads(m.group(1))
            if obj.get("type")=="death":
                kt = obj.get("killerType","") or ""
                if kt.startswith("minecraft:"): kt = kt.split("minecraft:")[-1]
                killer = ("不明" if not kt else kt)
                pos = obj.get("position",{})
                xyz = f"({pos.get('x','?')}, {pos.get('y','?')}, {pos.get('z','?')})"
                # 1件に集約：上段=「座標(x,y,z)    死因:killer」／下段=「◯◯さんが死亡しました。」
                push_chat(player="", message=f"{obj.get('player','誰か')}さんが死亡しました。", color="death",
                          meta_left=f"座標{xyz}", meta_right=f"死因:{killer}")
        except: pass
        return

def handle_bedrock(line):
    if "Server:" in line or "[Server]" in line:
        for key in ("Server:","[Server]"):
            if key in line:
                msg = line.split(key,1)[-1].strip()
                if msg: push_chat("SERVER", msg, "system")
                break

def tail_workers():
    known = set(jload(PLAY, []))
    t1 = threading.Thread(target=tail_file, args=(LOG_CON, lambda ln: handle_console(ln, known)), daemon=True)
    t2 = threading.Thread(target=tail_file, args=(LOG_BDS, handle_bedrock), daemon=True)
    t1.start(); t2.start()

class ChatIn(BaseModel): message: str
class WebChatIn(BaseModel):
    message: str
    name: str | None = None

@app.on_event("startup")
def _startup():
    for p,init in [(CHAT,[]),(PLAY,[]),(ALLOW,[]),(PERM,[])]:
        if not os.path.exists(p): jdump(p, init)
    tail_workers()

@app.get("/health")
def health():
    return {"ok": True, "console": os.path.exists(LOG_CON), "bds": os.path.exists(LOG_BDS),
            "role": ROLE, "autoadd": AUTOADD,
            "ts": datetime.datetime.now().isoformat()}

@app.get("/players")
def players(x_api_key: str = Header(None)):
    if x_api_key != API_TOKEN: raise HTTPException(status_code=403, detail="Forbidden")
    return {"server": SERVER_NAME, "players": jload(PLAY, []), "timestamp": datetime.datetime.now().isoformat()}

@app.get("/chat")
def chat(x_api_key: str = Header(None)):
    if x_api_key != API_TOKEN: raise HTTPException(status_code=403, detail="Forbidden")
    j = jload(CHAT, [])
    return {"server": SERVER_NAME, "latest": j[-MAX_CHAT:], "count": len(j),
            "timestamp": datetime.datetime.now().isoformat()}

@app.post("/chat")
def post_chat(body: ChatIn, x_api_key: str = Header(None)):
    if x_api_key != API_TOKEN: raise HTTPException(status_code=403, detail="Forbidden")
    msg = (body.message or "").strip()
    if not msg: raise HTTPException(status_code=400, detail="Empty")
    try:
        with open(FIFO,"w",encoding="utf-8") as f: f.write("say "+msg+"\n")
    except Exception: pass
    push_chat("API", msg, "normal")
    return {"status":"ok"}

@app.post("/webchat")
def post_webchat(body: WebChatIn, x_api_key: str = Header(None)):
    if x_api_key != API_TOKEN: raise HTTPException(status_code=403, detail="Forbidden")
    msg = (body.message or "").strip()
    name = (body.name or "").strip() or "名無し"
    if not msg: raise HTTPException(status_code=400, detail="Empty")
    push_chat(name, msg, "normal")
    return {"status":"ok"}

@app.get("/allowlist/list")
def allow_list(x_api_key: str = Header(None)):
    if x_api_key != API_TOKEN: raise HTTPException(status_code=403, detail="Forbidden")
    return {"allowlist": jload(ALLOW, []), "permissions": jload(PERM, [])}

@app.post("/allowlist/add")
def allow_add(body: dict, x_api_key: str = Header(None)):
    if x_api_key != API_TOKEN: raise HTTPException(status_code=403, detail="Forbidden")
    name = (body.get("name") or "").strip()
    xuid = (body.get("xuid") or "").strip()
    ignores = bool(body.get("ignoresPlayerLimit", False))
    if not name: raise HTTPException(status_code=400, detail="name required")
    added = add_allowlist(name, xuid, ignores)
    if xuid: add_permissions(xuid, ROLE)
    return {"ok": True, "added": added, "count": len(jload(ALLOW, [])), "role": ROLE}

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=13900, log_level="info")
PY

# --------------------------------------------------------------------------------------------
# <セクション番号:8>web イメージ関連 (Dockerfile, nginx.conf, index.html, styles.css, main.js)
# --------------------------------------------------------------------------------------------

# ---------- web（/api プロキシ + 新UI + 外部本文 + パラメータ必須：未指定なら白紙表示のみ） ----------
mkdir -p "${DOCKER_DIR}/web"
cat > "${DOCKER_DIR}/web/Dockerfile" <<'DOCK'
FROM nginx:alpine
DOCK

cat > "${DOCKER_DIR}/web/nginx.conf" <<'NGX'
server {
  listen 80 default_server;
  server_name _;

  # ------------ 内部ファイル参照用のエイリアス（超重要） ------------
  # /_fs/xxx → 実ファイルシステムの /xxx を返せる “内部” ロケーション
  location /_fs/ {
    internal;
    alias /;
    # 例: try_files /_fs/data-ro/worlds/world/html_server.html; で
    #      実ファイル /data-ro/worlds/world/html_server.html を返せる
  }

  # ------------ 既存プロキシ/マップ ------------
  location /api/ {
    proxy_pass http://bds-monitor:13900/;
    proxy_set_header Host $host;
    proxy_set_header X-Forwarded-Proto $scheme;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
  }

  location /map/ {
    alias /data-map/;
    autoindex on;
  }


  # ------------ サーバー情報本文（最優先: world 直下 → data 直下 → site） ------------
  # ここが 404 の原因だったので、/_fs/ 経由の “URI” を try_files に渡す形に修正
  # /html_server.html
location = /html_server.html {
  root /;
  add_header Cache-Control "no-store, no-cache, must-revalidate, max-age=0";
  try_files
    /data-ro/worlds/world/html_server.html
    /data-ro/html_server.html
    /usr/share/nginx/html/html_server.html
    =404;
}

# /html_server.txt
location = /html_server.txt {
  root /;
  add_header Cache-Control "no-store, no-cache, must-revalidate, max-age=0";
  try_files
    /data-ro/worlds/world/html_server.txt
    /data-ro/html_server.txt
    /usr/share/nginx/html/html_server.txt
    =404;
}

# 拡張子なしフォールバック
location = /html_server {
  root /;
  add_header Cache-Control "no-store, no-cache, must-revalidate, max-age=0";
  try_files
    /data-ro/worlds/world/html_server.html
    /data-ro/html_server.html
    /usr/share/nginx/html/html_server.html
    =404;
}

  # ------------ 既定の静的サイト ------------
  location / {
    root /usr/share/nginx/html;
    index index.html;
    try_files $uri $uri/ =404;
  }
}
NGX

mkdir -p "${WEB_SITE_DIR}"
cat > "${WEB_SITE_DIR}/index.html" <<'HTML'
<!doctype html>
<html lang="ja">
<meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1,maximum-scale=1,user-scalable=no">
<title>OMF Portal</title>
<link rel="stylesheet" href="styles.css?v=4">
<script defer src="main.js?v=6"></script>
<body>
<header>
  <nav class="tabs">
    <button class="tab active" data-target="info">サーバー情報</button>
    <button class="tab" data-target="chat">チャット</button>
    <button class="tab" data-target="map">マップ</button>
  </nav>
</header>
<main>
  <section id="info" class="panel show">
    <h1>サーバー情報</h1>
    <div id="server-info" class="server-info"></div>
  </section>

  <section id="chat" class="panel">
    <div class="chat-top">
      <div class="status-row"><span>現在接続中:</span><div id="players" class="pill-row"></div></div>
      <div id="param-error" class="param-error hidden">ページを開けません</div>
    </div>
    <div class="chat-list" id="chat-list"></div>
    <form id="chat-form" class="chat-form">
      <input id="chat-input" type="text" placeholder="メッセージ本文" maxlength="200" autocomplete="off"/>
      <button type="submit" id="send-btn">送信</button>
    </form>
  </section>

  <section id="map" class="panel">
    <div class="map-header">昨日までのマップデータ</div>
    <div class="map-frame"><iframe id="map-iframe" src="/map/index.html"></iframe></div>
  </section>
</main>
</body>
</html>
HTML

# ★余白の最小化（チャット・マップの下端の隙間を詰める）
cat > "${WEB_SITE_DIR}/styles.css" <<'CSS'
*{box-sizing:border-box}
html,body{height:100%}
:root{
  --bg:#0b0d10; --fg:#e8eef5; --soft:#c6d4e3;
  --card:#141821; --muted:#9fb2c6;
  --accent:#7aa2ff; --ok:#55FF55; --warn:#FFAA55; --err:#FF5555; --sys:#AAAAAA;
}

/* ===== ベース ===== */
body{ margin:0; background:var(--bg); color:var(--fg); font:16px system-ui,Segoe UI,Roboto,Helvetica,Arial; display:flex; flex-direction:column; min-height:100% }
header{ position:sticky; top:0; background:#0a0e14; border-bottom:1px solid #1e2633; z-index:10 }
.tabs{ display:flex; gap:.25rem; padding:.5rem; max-width:980px; margin:0 auto }
.tab{ flex:1; padding:.6rem 0; border:0; cursor:pointer; background:#161c26; color:#cfe0f5; border-radius:.5rem }
.tab.active{ background:linear-gradient(180deg,#1f2a3a,#152033); color:#fff; font-weight:600 }

main{
  flex:1; display:block;
  max-width:980px;   /* デスクトップは中央 980px */
  width:100%;        /* モバイルは横いっぱい */
  margin:0 auto;
  padding:0.5rem 0.75rem;   /* ←左右の余白を縮小 */
}
.panel{display:none}
.panel.show{display:block}

/* サーバー情報カード */
.server-info{ padding:0.7rem; background:var(--card); border:1px solid #1f2a3a; border-radius:.6rem }

/* ===== チャット ===== */
#chat.panel{ display:none; }
#chat.panel.show{ display:flex; flex-direction:column; height:calc(100vh - 150px) }
.status-row{ display:flex; gap:.5rem; align-items:center; margin-bottom:.5rem; color:var(--muted) }
.pill-row{ display:flex; gap:.5rem; overflow-x:auto; padding:.25rem .5rem; border:1px solid #283449; border-radius:.5rem; min-height:2.0rem; background:#0f131b }
.pill{ padding:.2rem .6rem; border-radius:999px; background:#162031; border:1px solid #293850; color:var(--soft) }
.param-error{ padding:.6rem 1rem; background:#302025; border:1px solid #4c2a30; color:#f3c6cb; border-radius:.5rem }
.hidden{display:none}

.chat-list{
  flex:1; min-height:0;               /* ←下の隙間を消すキモ */
  overflow:auto; padding:0.35rem;     /* ←左右の内側余白を縮小 */
  border:1px solid #1f2a3a; border-radius:.6rem; background:#0f131b
}
.chat-item{
  width:100%;                         /* ←横いっぱい */
  margin:0.25rem 0;                   /* ←行間を少し詰める */
  padding:.45rem .55rem; border-radius:.5rem; background:#121926; border:1px solid #1b2738
}
.chat-meta{ display:flex; justify-content:space-between; font-size:.85rem; margin-bottom:.2rem; opacity:.95 }
.chat-body{ font-size:1rem; line-height:1.45 }
.meta-normal{ color:var(--ok) } .body-normal{ color:#fff }
.meta-system{ color:var(--sys) } .body-system{ color:var(--sys) }
.meta-death{ color:var(--err) } .body-death{ color:var(--err) }

.chat-form{ display:flex; gap:.5rem; margin-top:.5rem }
#chat-input{ flex:1; padding:.6rem .8rem; border:1px solid #2a3548; border-radius:.5rem; background:#0e141f; color:#e8eef5 }
#send-btn{ padding:.6rem 1.0rem; border:0; background:linear-gradient(180deg,#3b6ff0,#274dd1); color:#fff; border-radius:.5rem; cursor:pointer; white-space:nowrap }

/* ===== マップ ===== */
.map-header{ margin:.35rem 0 .45rem; font-weight:600; color:var(--soft) }
.map-frame{ width:100%; height:calc(100vh - 180px); border:1px solid #1f2a3a; border-radius:.6rem; overflow:hidden; background:#0f131b }
.map-frame iframe{ width:100%; height:100%; border:0 }

@media (max-width:640px){
  main{ padding:0.25rem 0.4rem }      /* ←さらに左右を詰める */
  #chat.panel{ height:calc(100vh - 160px) }
  .chat-list{ padding:0.3rem }
  .chat-item{ margin:0.22rem 0 }
}
CSS

# ★死亡ログの見た目：左に座標・右に死因（時刻は描画しない）。パラメータ未指定は白紙のみ。
cat > "${WEB_SITE_DIR}/main.js" <<'JS'
// === OMF Portal main.js (full) ============================================
// 要件:
// - URL に token と name が無い場合は白紙(タブ無し) + 「ページを開けません」だけ表示して終了
// - token/name がある場合のみ UI を表示
// - チャット: SYSTEM/通常は [MM/DD HH:MM] を左に表示（年は出さない）
// - チャット: 死亡ログは「時間を出さず」、上段に「座標(x,y,z)    死因:xxx」,
//              下段に「〇〇さんが死亡しました」を表示（= 2行構成）
//   ※ monitor は death を2行流す (本文 / 座標)。ここでペアリングして1つのカードにまとめる
// - チャットタブを開いた時・更新時は常に最新が見えるよう自動スクロール(下端)
// =========================================================================

const API = "/api";
function qs(k, def = "") {
  try { return new URL(location.href).searchParams.get(k) || def; }
  catch (_) { return def; }
}
const TOKEN = qs("token", "");
const NAME  = qs("name", "");

// --- 1) token/name が無い時はタブを出さず即終了 --------------------------------
(function gatekeep() {
  const ok = Boolean(TOKEN) && Boolean(NAME);
  if (!ok) {
    document.addEventListener("DOMContentLoaded", () => {
      document.body.innerHTML = `
        <!doctype html><meta charset="utf-8">
        <style>
          html,body{height:100%;margin:0;background:#0b0d10;color:#e8eef5;font:16px system-ui,Segoe UI,Roboto,Helvetica,Arial}
          .box{height:100%;display:flex;align-items:center;justify-content:center}
          .msg{padding:1rem 1.25rem;border:1px solid #2a3548;background:#10161f;border-radius:.6rem}
        </style>
        <div class="box"><div class="msg">ページを開けません</div></div>`;
    });
    // UI 初期化は行わない
    throw new Error("no token/name");
  }
})();

// --- 2) token/name があるときだけ通常の UI を動かす ------------------------------
document.addEventListener("DOMContentLoaded", () => {
  // タブ切替
  document.querySelectorAll(".tab").forEach((b) => {
    b.addEventListener("click", () => {
      document.querySelectorAll(".tab").forEach((x) => x.classList.remove("active"));
      document.querySelectorAll(".panel").forEach((x) => x.classList.remove("show"));
      b.classList.add("active");
      document.getElementById(b.dataset.target).classList.add("show");

      // チャットタブを開いた瞬間にも最下端へ
      if (b.dataset.target === "chat") scrollChatToBottom();
    });
  });

  fetchServerInfo();

  // 初回ロード & ポーリング
  refreshPlayers();
  refreshChat();
  setInterval(refreshPlayers, 15000);
  setInterval(refreshChat, 12000);

  // 送信フォーム
  const form = document.getElementById("chat-form");
  form.style.display = "flex"; // token/nameがあるので表示
  form.addEventListener("submit", async (e) => {
    e.preventDefault();
    const v = document.getElementById("chat-input").value.trim();
    if (!v) return;
    try {
      const r = await fetch(API + "/webchat", {
        method: "POST",
        headers: { "Content-Type": "application/json", "x-api-key": TOKEN },
        body: JSON.stringify({ message: v, name: NAME }),
      });
      if (!r.ok) throw 0;
      document.getElementById("chat-input").value = "";
      await refreshChat(true); // 送信直後は再取得 + 下端へ
    } catch (_) {
      alert("送信失敗");
    }
  });
});

// --- サーバー情報（外部本文） ---------------------------------------------------
async function fetchServerInfo(){
  const box=document.getElementById("server-info");
  const SV  = localStorage.getItem("server_name") || "OMF";
  const t   = Date.now();                       // ← 追加
  const cands=[`/html_server.html?t=${t}`,      // ← 追加
               `/html_server.txt?t=${t}`,
               `/html_server?t=${t}`];
  for(const c of cands){
    try{
      const r=await fetch(c, {cache:"no-store"});  // ← 追加
      if(!r.ok) continue;
      const text=await r.text();
      box.innerHTML=text;
      return;
    }catch(_){}
  }
  box.innerHTML = `<p>ようこそ！<strong>${SV}</strong></p>
  <p>掲示は Web または外部 API (<code>/api/webchat</code>) から送れます。</p>`;
}


// --- 日付+時刻（年なし）[MM/DD HH:MM] -----------------------------------------
function fmtMDHM(ts) {
  try {
    const d = new Date(ts);
    const m  = String(d.getMonth() + 1).padStart(2, "0");
    const da = String(d.getDate()).padStart(2, "0");
    const hh = String(d.getHours()).padStart(2, "0");
    const mm = String(d.getMinutes()).padStart(2, "0");
    return `${m}/${da} ${hh}:${mm}`;
  } catch (_) { return ""; }
}

// --- プレイヤー一覧 -------------------------------------------------------------
async function refreshPlayers() {
  try {
    const r = await fetch(API + "/players", { headers: { "x-api-key": TOKEN } });
    if (!r.ok) return;
    const d = await r.json();
    const row = document.getElementById("players");
    row.innerHTML = "";
    (d.players || []).forEach((n) => {
      const el = document.createElement("div");
      el.className = "pill";
      el.textContent = n;
      row.appendChild(el);
    });
  } catch (_) {}
}

// --- チャット描画 ---------------------------------------------------------------
// death 2行を 1カードにまとめる: 
//   例) m1: color="death", player="死因:zombie", message="〇〇さんが死亡しました。"
//       m2: color="death", message="座標: (x, y, z)"
//   → カード: 上段: "座標(x, y, z)    死因:zombie"（時間は出さない）
//             下段: "〇〇さんが死亡しました。"
function buildChatBlocks(list) {
  const out = [];
  for (let i = 0; i < list.length; i++) {
    const m = list[i] || {};
    const color = (m.color || "normal").toLowerCase();

    if (color === "death") {
      const text = String(m.message || "");
      const cause = String(m.player || "死因:不明");
      // 次行が座標なら拾う
      let coords = "";
      if (i + 1 < list.length) {
        const n = list[i + 1] || {};
        if ((n.color || "").toLowerCase() === "death" && String(n.message || "").startsWith("座標:")) {
          const t = String(n.message);
          // "座標: (x, y, z)" → "(x, y, z)"
          const idx = t.indexOf(":");
          coords = idx >= 0 ? t.slice(idx + 1).trim() : t.trim();
          i += 1; // 1行先取り消費
        }
      }
      out.push({ kind: "death", cause, coords, body: text });
      continue;
    }

    // SYSTEM / normal
    out.push({
      kind: (color === "system" ? "system" : "normal"),
      when: fmtMDHM(m.timestamp || ""),
      who: String(m.player || "名無し"),
      body: String(m.message || ""),
    });
  }
  return out;
}

async function refreshChat(scrollToBottom = false) {
  try {
    const r = await fetch(API + "/chat", { headers: { "x-api-key": TOKEN } });
    if (!r.ok) return;
    const d = await r.json();
    renderChat(d.latest || []);
    if (scrollToBottom) scrollChatToBottom();
  } catch (_) {}
}

function renderChat(arr) {
  const list = document.getElementById("chat-list");
  list.innerHTML = "";

  const blocks = buildChatBlocks(arr);
  blocks.forEach((b) => {
    const item = document.createElement("div");
    item.className = "chat-item";

    const meta = document.createElement("div");
    const text = document.createElement("div");

    if (b.kind === "death") {
      meta.className = "chat-meta meta-death";
      text.className = "chat-body body-death";
      // 時刻は出さない。上段に「座標(...)    死因:xxx」
      const left = document.createElement("div");
      const right = document.createElement("div");
      left.textContent = b.coords ? `座標${b.coords}` : "座標(不明)";
      right.textContent = b.cause || "死因:不明";
      meta.appendChild(left);
      meta.appendChild(right);

      text.textContent = b.body || "";
    } else {
      // SYSTEM/通常: [MM/DD HH:MM] を左、名前を右
      const isSys = b.kind === "system";
      meta.className = `chat-meta ${isSys ? "meta-system" : "meta-normal"}`;
      text.className = `chat-body ${isSys ? "body-system" : "body-normal"}`;

      const left = document.createElement("div");
      left.textContent = b.when || "";
      const right = document.createElement("div");
      right.textContent = b.who || "";
      meta.appendChild(left);
      meta.appendChild(right);

      text.textContent = b.body || "";
    }

    item.appendChild(meta);
    item.appendChild(text);
    list.appendChild(item);
  });

  // 常に最新が見えるように最下端へ
  scrollChatToBottom();
}

function scrollChatToBottom() {
  const list = document.getElementById("chat-list");
  list.scrollTop = list.scrollHeight;
}
JS

# ------------------------------------------------------------------------------------------
# <セクション番号:8A>phonebot イメージ関連 (Dockerfile, index.js, package.json, config.json)
# ------------------------------------------------------------------------------------------

<< 'COMMENT'
# ---------- phonebot ビルドコンテキスト ----------
mkdir -p "${DOCKER_DIR}/phonebot"

# Dockerfile
cat > "${DOCKER_DIR}/phonebot/Dockerfile" <<'DOCK'
FROM node:20-bookworm-slim
ENV NODE_ENV=production
WORKDIR /app
# lockfile を前提にしない
COPY package.json ./
# npm ci ではなく npm install を使用（lockfile不要）
RUN npm install --omit=dev
COPY index.js ./index.js
# config.json はホストマウント
CMD ["node", "index.js"]
DOCK

# package.json
cat > "${DOCKER_DIR}/phonebot/package.json" <<'PKG'
{
  "name": "omf-phonebot",
  "version": "1.1.0",
  "private": true,
  "type": "module",
  "dependencies": {
    "discord.js": "^14.15.3",
    "tail-file": "^2.0.0"
  }
}
PKG

# index.js（発信→受話→ルーティング。30秒タイムアウト／トークンロック／キャンセル対応）
cat > "${DOCKER_DIR}/phonebot/index.js" <<'NODE'
import fs from "node:fs";
import { TailFile } from "tail-file";
import { Client, GatewayIntentBits, ChannelType, PermissionFlagsBits } from "discord.js";

const env = (k, d="") => process.env[k] ?? d;

// ---- 設定（env と config.json を併用）----
const CFG_PATH = "/app/config.json";
let cfg = { playerMap: {}, voicePool: [], keepaliveTimeoutSec: 60 };
if (fs.existsSync(CFG_PATH)) {
  try { cfg = Object.assign(cfg, JSON.parse(fs.readFileSync(CFG_PATH, "utf8"))); } catch {}
}
const TOKEN       = env("DISCORD_BOT_TOKEN", cfg.token || "");
const GUILD_ID    = env("DISCORD_GUILD_ID", cfg.guildId || "");
const CATEGORY_ID = env("DISCORD_CATEGORY_ID", cfg.categoryId || "");
const OPEN_VC_ID  = env("DISCORD_OPEN_VC_CHANNEL_ID", cfg.openVcChannelId || "");
const LINK_CH_ID  = env("DISCORD_LINK_CHANNEL_ID", cfg.linkChannelId || "");
const KEEPALIVE_SEC = Number(env("KEEPALIVE_TIMEOUT_SEC", cfg.keepaliveTimeoutSec ?? 60));
const SIGNAL        = env("PHONE_SIGNAL_PREFIX", "[PHONE]");
const CHAT_JSON_PATH= env("CHAT_JSON_PATH", "/data-ro/obj/data/chat.json");
const ROUTING_MODE  = env("ROUTING_MODE", "move"); // move | invite
const VOICE_POOL    = (env("VOICE_POOL", (cfg.voicePool || []).join(",")) || "")
  .split(",").map(s => s.trim()).filter(Boolean);
const RING_TIMEOUT_SEC = Number(env("RING_TIMEOUT_SEC", cfg.ringTimeoutSec ?? 30)); // 応答待ち

const PLAYER_MAP = new Map(Object.entries(cfg.playerMap || {}));
const client = new Client({
  intents: [
    GatewayIntentBits.Guilds,
    GatewayIntentBits.GuildVoiceStates,
    GatewayIntentBits.GuildMembers,
    GatewayIntentBits.DirectMessages,
    GatewayIntentBits.GuildMessages
  ]
});

// ---- 状態管理 ----
// pending: token -> { from, to, createdAt, timeout }
// sessions: token -> { users:[from,to], channelId, startedAt }
const pending  = new Map();
const sessions = new Map();

// ユーザーが他コールでビジーか？（pending or session に参加している）
function isUserBusy(mcName) {
  for (const p of pending.values()) if (p.from===mcName || p.to===mcName) return true;
  for (const s of sessions.values()) if (s.users.includes(mcName)) return true;
  return false;
}

function mcToDiscordId(name) { return PLAYER_MAP.get(name); }

async function dmInvite(discordId, channel) {
  try {
    const user = await client.users.fetch(discordId);
    const invite = await channel.createInvite({ maxAge: 600, maxUses: 1 }).catch(()=>null);
    if (invite) await user.send(`📞 参加はこちら: ${invite.url}`);
  } catch (e) {
    console.error("[phonebot] DM invite failed", e?.message);
  }
}

async function firstFreePoolChannel(guild) {
  for (const id of VOICE_POOL) {
    const ch = await guild.channels.fetch(id).catch(()=>null);
    if (!ch || ch.type !== ChannelType.GuildVoice) continue;
    const members = [...(ch.members?.values() ?? [])];
    if (members.length === 0) return ch;
  }
  return null;
}

async function moveIfConnected(guild, discordId, destChannel) {
  try {
    const m = await guild.members.fetch(discordId);
    if (m?.voice?.channelId && m.voice.channelId !== destChannel.id) {
      await m.voice.setChannel(destChannel, "phone auto-routing");
      return true;
    }
  } catch {}
  return false;
}

async function allocateChannel(guild, from, to) {
  let dest = await firstFreePoolChannel(guild);
  if (!dest && CATEGORY_ID) {
    dest = await guild.channels.create({
      name: `📞 ${from}-${to}`,
      type: ChannelType.GuildVoice,
      parent: CATEGORY_ID
    });
  }
  return dest;
}

function clearPending(token, reason="") {
  const p = pending.get(token);
  if (!p) return;
  if (p.timeout) clearTimeout(p.timeout);
  pending.delete(token);
  console.log(`[phonebot] cleared pending token=${token} (${reason})`);
}

function endSessionByToken(guild, token) {
  const s = sessions.get(token);
  if (!s) return;
  sessions.delete(token);
  // プールの固定VCは削除しない。一時作成VCは削除してもよい。
  // ここでは安全のため、親カテゴリ一致かつ名前が📞で始まる場合のみ削除。
  (async () => {
    try {
      const ch = await guild.channels.fetch(s.channelId).catch(()=>null);
      if (ch && ch.parentId === CATEGORY_ID && ch.name.startsWith("📞 ")) {
        await ch.delete("phone session end (temp channel)");
      }
    } catch {}
  })();
}

function endSessionByUser(guild, mcName) {
  for (const [tok, s] of sessions.entries()) {
    if (s.users.includes(mcName)) {
      endSessionByToken(guild, tok);
    }
  }
}

client.once("ready", () => {
  console.log(`[phonebot] logged in as ${client.user.tag}`);
  setInterval(async () => {
    try {
      const g = await client.guilds.fetch(GUILD_ID);
      // KEEPALIVE型の自動切断（現行は使っても使わなくてもOK）
      const now = Date.now();
      for (const [tok, s] of sessions.entries()) {
        // KEEPALIVEは使わない前提なのでここでは何もしない（必要なら拡張）
      }
    } catch {}
  }, 15000);
});

client.login(TOKEN);

// ---- chat.json tail & signal handling ----
(async () => {
  const tf = new TailFile(CHAT_JSON_PATH, { startPos: 0, pollFileIntervalMs: 1000 });
  tf.on("line", async (line) => {
    if (!line.includes(SIGNAL)) return;
    const guild = await client.guilds.fetch(GUILD_ID).catch(()=>null);
    if (!guild) return;

    // 例:
    // [PHONE] CALL from=Steve to=Alex token=abc
    // [PHONE] ACCEPT from=Steve to=Alex token=abc
    // [PHONE] DECLINE from=Steve to=Alex token=abc
    // [PHONE] CANCEL from=Steve token=abc
    // [PHONE] HANGUP user=Steve token=abc
    const parts = Object.fromEntries(
      line.split(" ").slice(1).map(p => {
        const [k,v] = p.split("="); return [k, v ?? ""];
      })
    );

    try {
      if (line.includes("CALL")) {
        const from = parts["from"], to = parts["to"], token = parts["token"];
        // すでにこのtokenが存在→二重発行防止
        if (pending.has(token) || sessions.has(token)) return;
        // 当事者がビジーなら受け付けない（同時複数発信の衝突防止）
        if (isUserBusy(from) || isUserBusy(to)) {
          console.log(`[phonebot] busy: from=${from} to=${to}`);
          return;
        }
        // pending 登録 & 30秒タイムアウト
        const timer = setTimeout(() => {
          clearPending(token, "ring-timeout");
        }, RING_TIMEOUT_SEC * 1000);
        pending.set(token, { from, to, createdAt: Date.now(), timeout: timer });
        console.log(`[phonebot] pending start token=${token} ${from}->${to}`);

      } else if (line.includes("ACCEPT")) {
        const from = parts["from"], to = parts["to"], token = parts["token"];
        const p = pending.get(token);
        if (!p || p.from !== from || p.to !== to) {
          console.log(`[phonebot] ACCEPT invalid or expired token=${token}`);
          return;
        }
        clearPending(token, "accepted");
        const dest = await allocateChannel(guild, from, to);
        if (!dest) return;

        const fromId = mcToDiscordId(from);
        const toId   = mcToDiscordId(to);

        if (ROUTING_MODE === "move") {
          if (fromId) (await moveIfConnected(guild, fromId, dest)) || await dmInvite(fromId, dest);
          if (toId)   (await moveIfConnected(guild, toId, dest))   || await dmInvite(toId, dest);
        } else {
          if (fromId) await dmInvite(fromId, dest);
          if (toId)   await dmInvite(toId, dest);
        }

        sessions.set(token, { users:[from,to], channelId: dest.id, startedAt: Date.now() });
        console.log(`[phonebot] session started token=${token} ch=${dest.id}`);

      } else if (line.includes("DECLINE")) {
        const from = parts["from"], to = parts["to"], token = parts["token"];
        const p = pending.get(token);
        if (!p || p.from !== from || p.to !== to) return;
        clearPending(token, "declined");

      } else if (line.includes("CANCEL")) {
        // 発信者が着信待ちをキャンセル、または通話中キャンセルもサポート
        const from = parts["from"], token = parts["token"];
        if (pending.has(token)) {
          const p = pending.get(token);
          if (p.from === from) clearPending(token, "caller-cancel");
        }
        // 通話中キャンセル（発信/受信どちらでも）
        if (sessions.has(token)) {
          endSessionByToken(guild, token);
        } else {
          // tokenが分からない場合でも、ユーザー単位で終了
          endSessionByUser(guild, from);
        }

      } else if (line.includes("HANGUP")) {
        // ユーザーが通話終了を要求
        const user = parts["user"];
        endSessionByUser(guild, user);

      } else if (line.includes("KEEPALIVE")) {
        // 現仕様では必須ではない。必要なら sessions の更新に利用。
      }
    } catch (e) {
      console.error("[phonebot] error", e?.message);
    }
  });

  tf.on("error", (e)=>console.error("[tail]", e));
  await tf.start();
})();
NODE

# config.json（雛形：playerMap と voicePool を追記可能）
cat > "${DOCKER_DIR}/phonebot/config.json" <<'JSON'
{
  "token": "",
  "guildId": "",
  "categoryId": "",
  "openVcChannelId": "",
  "linkChannelId": "",
  "keepaliveTimeoutSec": 60,
  "ringTimeoutSec": 30,
  "voicePool": [
    "123456789012345670",
    "123456789012345671",
    "123456789012345672"
  ],
  "playerMap": {
    "Steve": "123456789012345678",
    "Alex": "234567890123456789"
  }
}
JSON

COMMENT

# ----------------------------------------------------
# <セクション番号:9>サーバー情報本文の初期ファイル生成
# ----------------------------------------------------

# サーバー情報本文（初期ファイル）
mkdir -p "${DATA_DIR}"
if [[ ! -f "${DATA_DIR}/html_server.html" ]]; then
  cat > "${DATA_DIR}/html_server.html" <<'HTML'
<p>ようこそ！<strong id="sv-name">OMF</strong></p>
<p>掲示は Web または外部 API (<code>/api/webchat</code>) から送れます。</p>
HTML
fi
# site 側のフォールバックも用意（上と同一でOK）
if [[ ! -f "${WEB_SITE_DIR}/html_server.html" ]]; then
  cp "${DATA_DIR}/html_server.html" "${WEB_SITE_DIR}/html_server.html"
fi

# ▼▼▼ ここから追記：Nginx から world 直下の本文を読めるように最低限の権限を付与 ▼▼▼
#   Nginx(nginxユーザー)は “ディレクトリの実行権(x)” が無いとパスを辿れません。
#   data → worlds → world を o+rx、本文があれば o+r を付けます（存在しないときは無視）。
chmod o+rx "${DATA_DIR}" || true
[[ -d "${DATA_DIR}/worlds" ]] && chmod o+rx "${DATA_DIR}/worlds" || true
[[ -d "${DATA_DIR}/worlds/world" ]] && chmod o+rx "${DATA_DIR}/worlds/world" || true
[[ -f "${DATA_DIR}/worlds/world/html_server.html" ]] && chmod o+r "${DATA_DIR}/worlds/world/html_server.html" || true
# ▲▲▲ 追記ここまで ▲▲▲

# map 出力先プレースホルダ
mkdir -p "${DATA_DIR}/map"
if [[ ! -f "${DATA_DIR}/map/index.html" ]]; then
  echo '<!doctype html><meta charset="utf-8"><p>uNmINeD の Web 出力がここに作成されます。</p>' > "${DATA_DIR}/map/index.html"
fi

# ------------------------------------------
# <セクション番号:10>uNmINeD (update_map.sh)
# ------------------------------------------

# ---------- uNmINeD: ARM64 glibc の差分取得 + レンダ ----------
# ★取得物の判別を強化（zip/tar.gz を自動判定して展開。どちらも失敗なら WARN で既存を継続）
cat > "${BASE}/update_map.sh" <<'BASH'
omino@omino:~/omf/survival-dkr $ cat update_map.sh
#!/usr/bin/env bash
# =============================================================================
# update_map.sh  —  uNmINeD マップ自動更新（週1フル + 日次差分 + --trim + 多次元対応）
#
# 概要:
#   - 日次: 既存出力を活かした増分生成（実質差分） + --trim で肥大化防止
#   - 週次: 全ディメンションをフル再生成（ズーム/オプションは共通）
#   - ディメンション: overworld, nether, end を環境変数で切替
#
# 主な環境変数:
#   WEEKLY_DAY   : 週次フル実行する曜日 (0=Sun..6=Sat)          [default: 0]
#   DIMENSIONS   : 対象ディメンション (csv)                       [default: "overworld,nether,end"]
#   TRIM         : 1=--trim 有効 / 0=無効                         [default: 1]
#   CHUNKPROC    : --chunkprocessors の並列数                      [default: 4]
#   MAX_ZOOM     : 追加の最大ズーム段 (空なら既定)                 [default: ""]
#   EXTRA_FLAGS  : その他 uNmINeD に渡す任意フラグ                 [default: ""]
#
# 備考:
#   - Bedrock(LevelDB)の「真の差分矩形自動算出」は困難なため、uNmINeD の既存出力再利用に依存します。
#     これにより日次は“増分”として動作し、実運用ではフルの 1/5〜1/20 程度まで短縮できます。
# =============================================================================

set -euo pipefail
BASE_DIR="$(cd "$(dirname "$0")" && pwd)"
DATA="${BASE_DIR}/obj/data"
WORLD="${DATA}/worlds/world"
OUT="${DATA}/map"
TOOLS="${BASE_DIR}/obj/tools/unmined"
BIN="${TOOLS}/unmined-cli"
LAST="${TOOLS}/.last_url"

mkdir -p "${TOOLS}" "${OUT}"

log(){ echo "[update_map] $*" >&2; }
need(){ command -v "$1" >/dev/null 2>&1 || { log "need $1"; exit 2; }; }
need curl; command -v grep >/dev/null 2>&1 || true; command -v sed >/dev/null 2>&1 || true

# --- key.conf 読み込み（存在すれば） ---
KEY_FILE="${BASE_DIR}/key/key.conf"
[[ -f "${KEY_FILE}" ]] && source "${KEY_FILE}"

# 期待する key.conf 変数（存在しなければ既定値）
WEEKLY_DAY="${WEEKLY_DAY:-}"           # 0=Sun..6=Sat（空なら週次モードなし）
DIMENSIONS_RAW="${DIMENSIONS_RAW:-auto}" # "auto" か "overworld,nether,end" など
TRIM="${TRIM:-0}"                      # ※現行 CLI に 'trim' フラグは無い（保持のみ）
CHUNKPROC="${CHUNKPROC:-4}"
MAX_ZOOM="${MAX_ZOOM:-6}"              # --zoomout にマップ
EXTRA_FLAGS="${EXTRA_FLAGS:-}"         # 任意の追加フラグ（例: --players）

# --- uNmINeD 差分取得 ---
pick_url(){
  local tmp url
  tmp="$(mktemp -d)"
  curl -fsSL "https://unmined.net/downloads/" > "$tmp/p.html"
  url="$(grep -Eo 'https://unmined\.net/download/unmined-cli-linux-arm64-dev/[^"]*' "$tmp/p.html" | head -n1 || true)"
  rm -rf "$tmp"
  [ -n "$url" ] || return 1
  echo "$url"
}

detect_and_extract(){
  local pkg="$1" tmp="$2"
  mkdir -p "$tmp/x"
  if tar tzf "$pkg" >/dev/null 2>&1; then
    tar xzf "$pkg" -C "$tmp/x"; echo tgz; return 0
  fi
  if unzip -tq "$pkg" >/dev/null 2>&1; then
    unzip -qo "$pkg" -d "$tmp/x"; echo zip; return 0
  fi
  if file "$pkg" 2>/dev/null | grep -qi 'gzip'; then
    tar xzf "$pkg" -C "$tmp/x" || true; echo tgz; return 0
  fi
  if file "$pkg" 2>/dev/null | grep -qi 'zip'; then
    unzip -qo "$pkg" -d "$tmp/x" || true; echo zip; return 0
  fi
  return 1
}

install_from_url(){
  local url="$1" tmp ext
  tmp="$(mktemp -d)"
  log "downloading: $url"
  if ! curl -fL --retry 3 --retry-delay 2 -o "$tmp/pkg" "$url"; then
    rm -rf "$tmp"; return 1
  fi
  if ! ext="$(detect_and_extract "$tmp/pkg" "$tmp")"; then
    log "WARN: install failed; keep existing"
    rm -rf "$tmp"; return 1
  fi
  local root; root="$(find "$tmp/x" -maxdepth 3 -type f -name 'unmined-cli' -printf '%h\n' | head -n1 || true)"
  [ -n "$root" ] || { rm -rf "$tmp"; return 1; }
  rsync -a "$root"/ "${TOOLS}/" 2>/dev/null || cp -rf "$root"/ "${TOOLS}/"
  chmod +x "${BIN}" || true
  echo -n "$url" > "${LAST}"
  rm -rf "$tmp"; return 0
}

# --- 週次判定（WEEKLY_DAY が今日の曜日と一致したら weekly=true） ---
is_weekly_day(){
  local dow today
  dow="$(date +%w)"   # 0=Sun..6=Sat
  today="${dow}"
  [ -n "${WEEKLY_DAY}" ] && [ "${today}" = "${WEEKLY_DAY}" ]
}

# --- レンダリング1回分（ディメンションは任意） ---
render_one(){
  local dim="${1:-}"  # ""=自動判定, それ以外=overworld|nether|end のいずれか
  local mode_args=()
  if is_weekly_day; then
    mode_args+=( --force )
  fi

  local -a args=( web render
    --world "${WORLD}"
    --output "${OUT}"
    --chunkprocessors "${CHUNKPROC}"
    --zoomout "${MAX_ZOOM}"
    "${mode_args[@]}"
  )

  # ディメンション指定（単数のみ）
  if [ -n "${dim}" ] && [ "${dim}" != "auto" ]; then
    args+=( --dimension "${dim}" )
  fi

  # 任意の追加フラグ
  if [ -n "${EXTRA_FLAGS}" ]; then
    # shellcheck disable=SC2206
    extra_arr=( ${EXTRA_FLAGS} )
    args+=( "${extra_arr[@]}" )
  fi

  log "render args: ${args[*]}"
  if ! "${BIN}" "${args[@]}"; then
    log "WARN: render failed${dim:+ (dimension=${dim})}; skip this run"
    return 1
  fi
  return 0
}

main(){
  # 取得/更新
  local url; url="$(pick_url || true)"
  if [ -n "$url" ]; then
    if [ ! -f "${LAST}" ] || [ "$(cat "${LAST}")" != "$url" ] || [ ! -x "${BIN}" ]; then
      install_from_url "$url" || log "WARN: install failed; keep existing"
    else
      log "URL unchanged; skip update"
    fi
  else
    log "WARN: could not discover URL; keep existing"
  fi

  if [ ! -x "${BIN}" ]; then
    log "ERROR: unmined-cli not installed"
    exit 1
  fi

  # 実行モード表示
  if is_weekly_day; then
    log "mode: WEEKLY (WEEKLY_DAY=${WEEKLY_DAY})"
  else
    log "mode: DAILY"
  fi

  # DIMENSIONS_RAW の扱い:
  # - "auto" または空：ディメンション指定なし（自動判定で1回だけ実行）
  # - それ以外：カンマ区切りの各ディメンションを個別に実行、失敗しても続行
  local success=0
  if [ -z "${DIMENSIONS_RAW}" ] || [ "${DIMENSIONS_RAW}" = "auto" ]; then
    render_one "" && success=1
  else
    # 正規化してループ
    IFS=',' read -r -a dims <<<"$(echo "${DIMENSIONS_RAW}" | tr 'A-Z' 'a-z' | tr -s ', ' ',' | sed 's/^,//;s/,$//')"
    for d in "${dims[@]}"; do
      d="$(echo "$d" | xargs)"  # trim
      [ -n "$d" ] || continue
      render_one "$d" && success=1 || true
    done
  fi

  if [ "${success}" -eq 0 ]; then
    log "ERROR: all render attempts failed"
    exit 1
  fi

  log "done -> ${OUT}"
}

main "$@"
BASH
chmod +x "${BASE}/update_map.sh"

# ---------------------------------------------------
# <セクション番号:11>バックアップ処理 (backup_now.sh)
# ---------------------------------------------------
# 削除済み
# -----------------------------------------------
# <セクション番号:12>復元処理 (restore_backup.sh)
# -----------------------------------------------
# 削除済み
# --------------------------------
# <セクション番号:13>ビルド & 起動
# --------------------------------

# ---------- ビルド & 起動 ----------
echo "[BUILD] images..."
sudo docker compose -f "${DOCKER_DIR}/compose.yml" build --no-cache

echo "[PREFETCH] BDS payload (diff-mode) ..."
sudo docker run --rm -e TZ=Asia/Tokyo --entrypoint /usr/local/bin/get_bds.sh \
  -v "${DATA_DIR}:/data" -v "${BASE}/resource:/host-resource:ro" -v "${BASE}/behavior:/host-behavior:ro" \
  local/bds-box64:latest

echo "[UP] compose up -d ..."
sudo docker compose -f "${DOCKER_DIR}/compose.yml" up -d

sleep 2

# ------------------------------------------------------
# <セクション番号:14B>安全停止スクリプト（graceful stop）
# ------------------------------------------------------

# =====================================================================
# [14B] 安全停止スクリプト（graceful stop）＋ systemd ユニット
# =====================================================================
TOOLS_DIR="${OBJ}/tools"
mkdir -p "${TOOLS_DIR}"

cat > "${TOOLS_DIR}/safe_stop.sh" <<'BASH'
#!/usr/bin/env bash
set -euo pipefail

BASE="${HOME}/omf/survival-dkr"
KEY_FILE="${BASE}/key/key.conf"
[[ -f "${KEY_FILE}" ]] && source "${KEY_FILE}"

SLACK_WEBHOOK_URL="${SLACK_WEBHOOK_URL:-}"
export BORG_PASSPHRASE="${BORG_PASSPHRASE:-}"

ts(){ date +"%Y-%m-%d %H:%M:%S"; }
say(){ echo "[safe_stop] $(ts) $*"; }
slack(){
  local text="${1:-}"; local color="${2:-#4b9e3a}"
  [ -n "${SLACK_WEBHOOK_URL}" ] || { say "slack: webhook 未設定"; return 0; }
  curl -fsS -X POST -H 'Content-type: application/json' \
    --data "{\"attachments\":[{\"color\":\"${color}\",\"text\":\"${text}\"}]}" \
    "${SLACK_WEBHOOK_URL}" >/dev/null 2>&1 || true
}

is_running(){ docker ps --format '{{.Names}}' | grep -qx 'bds'; }
wait_exit(){
  local timeout="${1:-60}" i=0
  while [ $i -lt "$timeout" ]; do
    if ! is_running; then return 0; fi
    sleep 1; i=$((i+1))
  done
  return 1
}
fifo_cmd(){ docker exec bds sh -lc "printf '%s\n' \"$1\" > /data/in.pipe" >/dev/null 2>&1 || true; }

write_clean_marker(){
  # 停止に成功したら「昨日日付」を保存（“前夜25:10の正常停止”を翌朝に確認するため）
  local yday; yday="$(date -d "yesterday" +%Y-%m-%d 2>/dev/null || date -v-1d +%Y-%m-%d)"
  echo "${yday}" | tee /tmp/.last_stop_clean >/dev/null
  docker run --rm -v "${BASE}/obj/data:/data" alpine:3.20 \
    sh -c 'mkdir -p /data && cp /tmp/.last_stop_clean /data/.last_stop_clean 2>/dev/null || true' || true
}

main(){
  if ! is_running; then
    say "bds は起動していません（何もしません）"
    slack ":white_check_mark: BDS は既に停止しています" "#aaaaaa"
    write_clean_marker
    exit 0
  fi

  say "優雅停止を開始します..."
  slack ":octagonal_sign: サーバー停止を開始（優雅停止）" "#ffcc00" || true

  fifo_cmd "say [OMFS] サーバーを停止します。数十秒後に終了します。"
  sleep 1

  fifo_cmd "save hold";  sleep 3
  for _ in 1 2 3; do fifo_cmd "save query"; sleep 2; done
  fifo_cmd "save resume"; sleep 1
  fifo_cmd "stop"

  if wait_exit 60; then
    say "優雅停止に成功しました。"
    slack ":white_check_mark: 優雅停止に成功しました" "#36a64f" || true
    write_clean_marker
    exit 0
  fi

  say "タイムアウト：SIGTERM を送ります"
  slack ":warning: 停止が遅延中 → SIGTERM 送信" "#ff9933" || true
  docker stop --time 15 bds >/dev/null 2>&1 || true
  if wait_exit 20; then
    say "SIGTERM 後に停止しました。"
    slack ":white_check_mark: SIGTERM 後に停止完了" "#36a64f" || true
    write_clean_marker
    exit 0
  fi

  say "依然として停止しないため、SIGKILL します"
  slack ":x: SIGKILL を送信（強制停止）" "#e01e5a" || true
  docker kill bds >/dev/null 2>&1 || true
  wait_exit 5 || true

  # 強制停止はクリーン扱いにしない（マーカーは書かない）
  LOG_DIR="${BASE}/obj/diagnose/$(date +%Y%m%d-%H%M%S)"
  mkdir -p "${LOG_DIR}"
  docker logs --since 30m bds           > "${LOG_DIR}/bds.stdout.log" 2>&1 || true
  docker logs --since 30m bds-monitor   > "${LOG_DIR}/monitor.stdout.log" 2>&1 || true
  docker inspect bds > "${LOG_DIR}/bds.inspect.json" 2>/dev/null || true
  slack ":fire: 強制停止（SIGKILL）。調査ログ: ${LOG_DIR}" "#e01e5a" || true
  say "強制停止しました（診断: ${LOG_DIR}）"
  exit 2
}
main "$@"
BASH
chmod +x "${TOOLS_DIR}/safe_stop.sh"

# systemd ユニット/テンプレート
sudo tee /etc/systemd/system/omfs-safe-stop@.service >/dev/null <<'UNIT'
[Unit]
Description=OMFS graceful stop (safe_stop.sh)
Wants=docker.service
After=docker.service

[Service]
Type=oneshot
User=%i
Group=%i
SupplementaryGroups=docker
Environment="HOME=/home/%i"
WorkingDirectory=/home/%i/omf/survival-dkr
ExecStart=/bin/bash -lc '/home/%i/omf/survival-dkr/obj/tools/safe_stop.sh'
TimeoutStartSec=0
KillMode=process
Nice=10
UNIT

sudo systemctl daemon-reload

# ----------------------------------------------------------
# <セクション番号:14C>Borg ラッパー（確認→復元→バックアップ）
# ----------------------------------------------------------

# =====================================================================
# [14C] Borg ラッパー：7:40 に「昨夜の停止確認 → 必要なら復元 → borg backup（SSD/SD）」
#   - key.conf:
#       SLACK_WEBHOOK_URL
#       BORG_PASSPHRASE
#       BORG_SSD_REPO   (例: /mnt/ssd256/borg/omfs)
#       BORG_SD_REPO    (例: /mnt/sdcard/borg/omfs)  # 空ならスキップ
#       PRUNE_SSD       (例: --keep-daily=7)
#       PRUNE_SD        (例: --keep-daily=10)
# =====================================================================
TOOLS_DIR="${OBJ}/tools"
mkdir -p "${TOOLS_DIR}"

cat > "${TOOLS_DIR}/borg_daily.sh" <<'BASH'
#!/usr/bin/env bash
set -euo pipefail

BASE="${HOME}/omf/survival-dkr"
DATA="${BASE}/obj/data"
KEY_FILE="${BASE}/key/key.conf"
[[ -f "${KEY_FILE}" ]] && source "${KEY_FILE}"

export BORG_PASSPHRASE="${BORG_PASSPHRASE:-}"
SSD_REPO="${BORG_SSD_REPO:-}"
SD_REPO="${BORG_SD_REPO:-}"
PRUNE_SSD="${PRUNE_SSD:---keep-daily=7}"
PRUNE_SD="${PRUNE_SD:---keep-daily=10}"
SLACK_WEBHOOK_URL="${SLACK_WEBHOOK_URL:-}"

ts(){ date +"%Y-%m-%d %H:%M:%S"; }
say(){ echo "[borg_daily] $(ts) $*"; }
slack(){
  local text="${1:-}"; local color="${2:-#4b9e3a}"
  [ -n "${SLACK_WEBHOOK_URL}" ] || { say "slack: webhook 未設定"; return 0; }
  curl -fsS -X POST -H 'Content-type: application/json' \
    --data "{\"attachments\":[{\"color\":\"${color}\",\"text\":\"${text}\"}]}" \
    "${SLACK_WEBHOOK_URL}" >/dev/null 2>&1 || true
}

need(){ command -v "$1" >/dev/null 2>&1 || { say "need $1"; slack ":x: $1 が見つかりません（borg 未インストール）" "#e01e5a"; exit 1; }; }
need borg

clean_stop_ok(){
  local mark="${DATA}/.last_stop_clean"
  [ -r "${mark}" ] || return 1
  local yday
  yday="$(date -d "yesterday" +%Y-%m-%d 2>/dev/null || date -v-1d +%Y-%m-%d)"
  grep -qx "${yday}" "${mark}"
}

repo_is_borg(){
  local repo="$1"
  BORG_UNKNOWN_UNENCRYPTED_REPO_ACCESS_IS_OK=yes \
  borg info "${repo}" >/dev/null 2>&1
}

ensure_repo(){
  local repo="$1"
  [ -n "${repo}" ] || return 1
  mkdir -p "${repo}" || true

  if repo_is_borg "${repo}"; then
    say "repo ok: ${repo}"
    return 0
  fi

  # 未初期化 → init（repokey）。パスフレーズは key.conf の BORG_PASSPHRASE を使用
  say "repo not initialized, init now: ${repo}"
  if ! borg init --encryption repokey "${repo}" >/dev/null 2>&1; then
    slack ":x: borg init 失敗: ${repo}" "#e01e5a"
    return 1
  fi
  say "repo initialized: ${repo}"
  return 0
}

restore_latest(){
  local repo=""
  if [ -n "${SSD_REPO}" ] && [ -d "${SSD_REPO}" ]; then repo="${SSD_REPO}"; fi
  if [ -z "${repo}" ] && [ -n "${SD_REPO}" ] && [ -d "${SD_REPO}" ]; then repo="${SD_REPO}"; fi
  [ -n "${repo}" ] || { slack ":x: 復元失敗（リポジトリ不在）" "#e01e5a"; return 1; }

  if ! ensure_repo "${repo}"; then
    slack ":x: 復元失敗（repo 準備不可）" "#e01e5a"
    return 1
  fi

  local latest
  latest="$(borg list --last 1 --short "${repo}" 2>/dev/null | tail -n1 || true)"
  [ -n "${latest}" ] || { slack ":x: 復元失敗（アーカイブ不在）" "#e01e5a"; return 1; }

  slack ":warning: 前夜が不正停止。最新スナップから復元 (${latest})" "#ffcc00"
  mkdir -p "${BASE}/obj/recovery"
  tar -C "${DATA}" -czf "${BASE}/obj/recovery/world-$(date +%Y%m%d-%H%M%S).tgz" worlds/world 2>/dev/null || true

  borg extract -v --numeric-owner "${repo}::${latest}" "obj/data/worlds/world" || {
    slack ":x: 復元失敗 (${latest})" "#e01e5a"; return 1; }

  # 読み取り権限を補正（nginx/borg が読めるように世界公開読み）
  chmod -R o+rx "${DATA}/worlds/world" || true

  slack ":white_check_mark: 復元完了 (${latest})" "#36a64f"
  return 0
}

do_borg(){
  local repo="$1" prune_opt="$2"
  [ -n "${repo}" ] || return 0

  # リポジトリ初期化（必要なら）
  if ! ensure_repo "${repo}"; then
    say "skip backup: repo prepare failed: ${repo}"
    return 1
  fi

  local tag; tag="$(hostname)-$(date +%Y%m%d-%H%M%S)"

  borg create --stats --compression lz4 \
    "${repo}::${tag}" \
    "${BASE}/obj/data/worlds/world" \
    "${BASE}/obj/data/allowlist.json" \
    "${BASE}/obj/data/permissions.json" \
    "${BASE}/obj/data/server.properties" \
    "${BASE}/obj/data/chat.json" \
    2>&1 | tee -a "${BASE}/obj/borg.log" || { slack ":x: borg create 失敗 (${repo})" "#e01e5a"; return 1; }

  borg prune -v --list ${prune_opt} "${repo}" 2>&1 | tee -a "${BASE}/obj/borg.log" || { slack ":x: borg prune 失敗 (${repo})" "#e01e5a"; return 1; }

  # 読み取り権限の補正（万が一変わっていても戻しておく）
  chmod -R o+rx "${DATA}/worlds/world" || true

  # 空き容量しきい値通知（10%未満なら警告）
  local avail total pct
  read avail total <<<"$(df -Pk "${repo}" | awk 'NR==2{print $4,$2}')"
  if [ -n "${avail:-}" ] && [ -n "${total:-}" ] && [ "${total}" -gt 0 ]; then
    pct=$((100 * avail / total))
    if [ "${pct}" -lt 10 ]; then
      slack ":warning: ${repo} の空きが少なくなっています（${pct}%）" "#ffcc00"
    fi
  fi
}

main(){
  # 稼働中は中止（hold/resume 等の整合を避ける）
  if docker ps --format '{{.Names}}' | grep -qx 'bds'; then
    slack ":x: 7:40 bds 稼働中 → バックアップ中止" "#e01e5a"
    exit 2
  fi

  # 昨日クリーンでなければ復元（SSD→SD の優先で選択）
  if ! clean_stop_ok; then
    restore_latest || true
  fi

  # SSD バックアップ
  if [ -n "${SSD_REPO}" ]; then
    say "backup SSD -> ${SSD_REPO}"
    do_borg "${SSD_REPO}" "${PRUNE_SSD}" || true
  else
    say "SSD_REPO 未指定のためスキップ"
  fi

  # SD バックアップ（変数が空 or ディスク未接続ならスキップ）
  if [ -n "${SD_REPO}" ]; then
    say "backup SD -> ${SD_REPO}"
    do_borg "${SD_REPO}" "${PRUNE_SD}" || true
  else
    say "SD_REPO 未指定のためスキップ"
  fi

  # 水曜のみ docker の掃除
  if [ "$(date +%u)" = "3" ]; then docker system prune -af || true; fi

  slack ":white_check_mark: 7:40 バックアップ完了" "#36a64f"
}
main "$@"
BASH
chmod +x "${TOOLS_DIR}/borg_daily.sh"


# ----------------------------------------------------------
# <セクション番号:14D>systemd ユニット/タイマー（cron 不使用）
# ----------------------------------------------------------

# =====================================================================
# [14D] systemd services/timers（JST 前提）
#   06:40  update_map
#   07:40  確認→復元→borg
#   08:50  compose up
#   09:00  起動ヘルスチェック（失敗ならSlack）
#   25:00  優雅停止（14B）
#   25:10  停止確認＋最終スナップ
#   25:20  シャットダウン
# =====================================================================

THIS_USER="${SUDO_USER:-$USER}"
HOME_DIR="$(getent passwd "$THIS_USER" | cut -d: -f6)"
BASE="${HOME_DIR}/omf/survival-dkr"

# --- 06:40 update_map ---
sudo tee /etc/systemd/system/omfs-update-map@.service >/dev/null <<'UNIT'
[Unit]
Description=OMFS update_map.sh
Wants=docker.service
After=docker.service

[Service]
Type=oneshot
User=%i
Environment="HOME=/home/%i"
WorkingDirectory=/home/%i/omf/survival-dkr
ExecStart=/bin/bash -lc '/home/%i/omf/survival-dkr/update_map.sh'
Nice=10
UNIT

sudo tee /etc/systemd/system/omfs-update-map@.timer >/dev/null <<'UNIT'
[Unit]
Description=Timer: OMFS update map (06:40)

[Timer]
OnCalendar=*-*-* 06:40:00
Persistent=true
Unit=omfs-update-map@%i.service

[Install]
WantedBy=timers.target
UNIT

# --- 07:40 確認→復元→borg ---
sudo tee /etc/systemd/system/omfs-borg-daily@.service >/dev/null <<'UNIT'
[Unit]
Description=OMFS borg daily (07:40): check-stop -> restore-if-needed -> backup
Wants=docker.service
After=docker.service

[Service]
Type=oneshot
User=%i
Environment="HOME=/home/%i"
WorkingDirectory=/home/%i/omf/survival-dkr
ExecStart=/bin/bash -lc '/home/%i/omf/survival-dkr/obj/tools/borg_daily.sh'
Nice=10
UNIT

sudo tee /etc/systemd/system/omfs-borg-daily@.timer >/dev/null <<'UNIT'
[Unit]
Description=Timer: OMFS borg daily (07:40)

[Timer]
OnCalendar=*-*-* 07:40:00
Persistent=true
Unit=omfs-borg-daily@%i.service

[Install]
WantedBy=timers.target
UNIT

# --- 08:50 起動（compose up）---
sudo tee /etc/systemd/system/omfs-up@.service >/dev/null <<'UNIT'
[Unit]
Description=OMFS compose up
Wants=docker.service
After=docker.service

[Service]
Type=oneshot
User=%i
Environment="HOME=/home/%i"
WorkingDirectory=/home/%i/omf/survival-dkr/obj/docker
ExecStart=/bin/bash -lc 'docker compose up -d'
Nice=5
UNIT

sudo tee /etc/systemd/system/omfs-up@.timer >/dev/null <<'UNIT'
[Unit]
Description=Timer: OMFS up (08:50)

[Timer]
OnCalendar=*-*-* 08:50:00
Persistent=true
Unit=omfs-up@%i.service

[Install]
WantedBy=timers.target
UNIT

# --- 09:00 起動チェック ---
sudo tee /etc/systemd/system/omfs-healthcheck@.service >/dev/null <<'UNIT'
[Unit]
Description=OMFS health check (09:00) and Slack notify if down
Wants=docker.service
After=docker.service

[Service]
Type=oneshot
User=%i
Environment="HOME=/home/%i"
WorkingDirectory=/home/%i/omf/survival-dkr
ExecStart=/bin/bash -lc '
  source /home/%i/omf/survival-dkr/key/key.conf;
  if curl -fsS "http://127.0.0.1:${MONITOR_PORT}/health" | jq -e ".ok==true" >/dev/null 2>&1; then
    exit 0;
  else
    if [ -n "${SLACK_WEBHOOK_URL:-}" ]; then
      curl -fsS -X POST -H "Content-type: application/json" \
        --data "{\"text\":\":x: 09:00 起動確認に失敗（monitor未応答）\"}" "${SLACK_WEBHOOK_URL}";
    fi;
    exit 1;
  fi
'
Nice=10
UNIT

sudo tee /etc/systemd/system/omfs-healthcheck@.timer >/dev/null <<'UNIT'
[Unit]
Description=Timer: OMFS healthcheck (09:00)

[Timer]
OnCalendar=*-*-* 09:00:00
Persistent=true
Unit=omfs-healthcheck@%i.service

[Install]
WantedBy=timers.target
UNIT

# --- 25:00 優雅停止（14B）---
sudo tee /etc/systemd/system/omfs-safe-stop@.timer >/dev/null <<'UNIT'
[Unit]
Description=Timer: OMFS graceful stop (25:00)

[Timer]
OnCalendar=*-*-* 01:00:00
Persistent=true
Unit=omfs-safe-stop@%i.service

[Install]
WantedBy=timers.target
UNIT

# --- 25:10 停止確認＋最終スナップ ---
sudo tee /etc/systemd/system/omfs-final-snap@.service >/dev/null <<'UNIT'
[Unit]
Description=OMFS final snapshot after stop (25:10)
Wants=docker.service
After=docker.service

[Service]
Type=oneshot
User=%i
Environment="HOME=/home/%i"
WorkingDirectory=/home/%i/omf/survival-dkr
ExecStart=/bin/bash -lc '
  source /home/%i/omf/survival-dkr/key/key.conf;
  SLACK_WEBHOOK_URL="${SLACK_WEBHOOK_URL:-}";
  # 停止確認
  if docker ps --format "{{.Names}}" | grep -qx bds; then
    [ -n "$SLACK_WEBHOOK_URL" ] && curl -fsS -X POST -H "Content-type: application/json" \
      --data "{\"text\":\":warning: 25:10 時点で bds がまだ稼働中です（停止失敗）\"}" "$SLACK_WEBHOOK_URL";
    exit 1;
  fi
  # クリーンマーカー（本日分）は safe_stop 側が「昨日」を書くため、ここでは“今日”も追記し保険
  date +%Y-%m-%d > /home/%i/omf/survival-dkr/obj/data/.last_stop_clean || true
  # 最終差分スナップ（SSD→SD）
  export BORG_PASSPHRASE="${BORG_PASSPHRASE:-}";
  [ -n "${BORG_SSD_REPO:-}" ] && borg create --stats --compression lz4 "${BORG_SSD_REPO}::$(hostname)-final-$(date +%Y%m%d-%H%M%S)" "/home/%i/omf/survival-dkr/obj/data/worlds/world";
  [ -n "${BORG_SD_REPO:-}"  ] && borg create --stats --compression lz4 "${BORG_SD_REPO}::$(hostname)-final-$(date +%Y%m%d-%H%M%S)"  "/home/%i/omf/survival-dkr/obj/data/worlds/world";
  [ -n "$SLACK_WEBHOOK_URL" ] && curl -fsS -X POST -H "Content-type: application/json" \
      --data "{\"text\":\":white_check_mark: 25:10 最終スナップ完了\"}" "$SLACK_WEBHOOK_URL";
'
Nice=10
UNIT

sudo tee /etc/systemd/system/omfs-final-snap@.timer >/dev/null <<'UNIT'
[Unit]
Description=Timer: OMFS final snap (25:10)

[Timer]
OnCalendar=*-*-* 01:10:00
Persistent=true
Unit=omfs-final-snap@%i.service

[Install]
WantedBy=timers.target
UNIT

# --- 25:20 シャットダウン ---
sudo tee /etc/systemd/system/omfs-poweroff.service >/dev/null <<'UNIT'
[Unit]
Description=OMFS poweroff (25:20)

[Service]
Type=oneshot
User=root
ExecStart=/sbin/poweroff
UNIT

sudo tee /etc/systemd/system/omfs-poweroff.timer >/dev/null <<'UNIT'
[Unit]
Description=Timer: OMFS poweroff (25:20)

[Timer]
OnCalendar=*-*-* 01:20:00
Persistent=true
Unit=omfs-poweroff.service

[Install]
WantedBy=timers.target
UNIT

# --- 手動復元サービス（対話型ラッパ） ---
# 端末直付けや systemd-run --pty で実行する場合の対話用。
# 中で tools/restore_manual.sh を起動し、SSD/SD の選択→アーカイブ選択→復元まで行う。
sudo tee /etc/systemd/system/omfs-restore@.service >/dev/null <<'UNIT'
[Unit]
Description=OMFS manual restore (interactive, choose repo and archive)

[Service]
Type=simple
User=%i
Environment="HOME=/home/%i"
WorkingDirectory=/home/%i/omf/survival-dkr
ExecStart=/bin/bash -lc '/home/%i/omf/survival-dkr/obj/tools/restore_manual.sh'
TTYPath=/dev/tty1
StandardInput=tty
StandardOutput=journal
UNIT

# 有効化
echo "[14D] systemd reload/enable/start (non-fatal handling enabled)..."

# 念のためリロード（sudo必須、失敗しても致命扱いにしない）
set +e
sudo systemctl daemon-reload >/dev/null 2>&1 || echo "[14D][WARN] daemon-reload failed (will continue)"

# タイマー/サービス起動を“非致命”で行うヘルパ
safe_enable_timer() {
  local unit="$1"
  sudo systemctl enable "$unit" --quiet 2>/dev/null
  sudo systemctl start  "$unit" 2>/dev/null
  rc=$?
  if [ $rc -ne 0 ]; then
    echo "[14D][WARN] start $unit rc=$rc (already running / elapsed / past time is OK)"
  fi
}

#sudo systemctl daemon-reload
#sudo systemctl enable omfs-update-map@"${THIS_USER}".timer
#sudo systemctl enable omfs-borg-daily@"${THIS_USER}".timer
#sudo systemctl enable omfs-up@"${THIS_USER}".timer
#sudo systemctl enable omfs-healthcheck@"${THIS_USER}".timer
#sudo systemctl enable omfs-safe-stop@"${THIS_USER}".timer
#sudo systemctl enable omfs-final-snap@"${THIS_USER}".timer
#sudo systemctl enable omfs-poweroff.timer
# 直ちに起動（次回からは自動）
#sudo systemctl start  omfs-update-map@"${THIS_USER}".timer
#sudo systemctl start  omfs-borg-daily@"${THIS_USER}".timer
#sudo systemctl start  omfs-up@"${THIS_USER}".timer
#sudo systemctl start  omfs-healthcheck@"${THIS_USER}".timer
#sudo systemctl start  omfs-safe-stop@"${THIS_USER}".timer
#sudo systemctl start  omfs-final-snap@"${THIS_USER}".timer
#sudo systemctl start  omfs-poweroff.timer

# ★ここは従来どおりの“スケジュール内容”を維持
safe_enable_timer "omfs-update-map@${USER_NAME}.timer"     # 06:40 update_map
safe_enable_timer "omfs-borg-daily@${USER_NAME}.timer"     # 07:40 停止確認→復元→borg
safe_enable_timer "omfs-up@${USER_NAME}.timer"             # 08:50 compose up
safe_enable_timer "omfs-healthcheck@${USER_NAME}.timer"    # 09:00 起動ヘルスチェック
safe_enable_timer "omfs-safe-stop@${USER_NAME}.timer"      # 25:00 優雅停止（14B）
safe_enable_timer "omfs-final-snap@${USER_NAME}.timer"     # 25:10 停止確認＋最終スナップ
safe_enable_timer "omfs-poweroff.timer"                    # 25:20 シャットダウン（= 01:20 JST）

# 以降は致命扱いに戻す
set -e

# -------------------------------------------------------------------------
# <セクション番号:14E>対話型 復元スクリプト（SSD/SD 選択・日付/番号選択対応）
# -------------------------------------------------------------------------

# ----------------------------------------------------------
# <セクション番号:14E>対話型 復元スクリプト（SSD/SD 選択 & 日付/番号選択）
#   - 使い方:
#       $ bash ~/omf/survival-dkr/obj/tools/restore_manual.sh
#     （または 14D の service / systemd-run --pty から実行）
# ----------------------------------------------------------
TOOLS_DIR="${OBJ}/tools"
mkdir -p "${TOOLS_DIR}"

cat > "${TOOLS_DIR}/restore_manual.sh" <<'BASH'
#!/usr/bin/env bash
set -euo pipefail

USER_NAME="${SUDO_USER:-$USER}"
HOME_DIR="$(getent passwd "$USER_NAME" | cut -d: -f6)"
BASE="${HOME_DIR}/omf/survival-dkr"
DATA="${BASE}/obj/data"
KEY_FILE="${BASE}/key/key.conf"

[[ -f "${KEY_FILE}" ]] && source "${KEY_FILE}"

export BORG_PASSPHRASE="${BORG_PASSPHRASE:-}"
SSD_REPO="${BORG_SSD_REPO:-}"
SD_REPO="${BORG_SD_REPO:-}"

ts(){ date +"%Y-%m-%d %H:%M:%S"; }
say(){ echo "[restore_manual] $(ts) $*"; }
err(){ echo "[restore_manual][ERR] $*" >&2; }

need(){ command -v "$1" >/dev/null 2>&1 || { err "command not found: $1"; exit 1; }; }
need borg

# --- 動作前チェック ---
if docker ps --format '{{.Names}}' | grep -qx 'bds'; then
  err "bds が起動中です。先に安全停止してください（omfs-stop など）。"
  exit 1
fi

# --- リポジトリ選択 ---
declare -a LABELS=()
declare -a PATHS=()

if [[ -n "${SSD_REPO}" && -d "${SSD_REPO}" ]]; then
  LABELS+=("SSD")
  PATHS+=("${SSD_REPO}")
fi
if [[ -n "${SD_REPO}" && -d "${SD_REPO}" ]]; then
  LABELS+=("SD")
  PATHS+=("${SD_REPO}")
fi

if [[ ${#PATHS[@]} -eq 0 ]]; then
  err "利用可能な Borg リポジトリが見つかりません（key.conf の BORG_SSD_REPO / BORG_SD_REPO を確認）"
  exit 1
fi

echo "=== 復元先リポジトリを選択してください ==="
for i in "${!LABELS[@]}"; do
  echo "  $((i+1))) ${LABELS[$i]}  (${PATHS[$i]})"
done
printf "番号を入力: "
read -r sel
if ! [[ "${sel}" =~ ^[0-9]+$ ]] || (( sel < 1 || sel > ${#PATHS[@]} )); then
  err "不正な選択です"; exit 1
fi
REPO="${PATHS[$((sel-1))]}"
say "選択: ${LABELS[$((sel-1))]} -> ${REPO}"

# --- アーカイブ一覧の取得 ---
# 期待フォーマット例: hostname-YYYYmmdd-HHMMSS
mapfile -t ARCHES < <(borg list --short "${REPO}")
if [[ ${#ARCHES[@]} -eq 0 ]]; then
  err "アーカイブがありません: ${REPO}"
  exit 1
fi

# 表示用に番号と日付を整形
echo "=== 復元するスナップショットを選んでください ==="
i=1
for a in "${ARCHES[@]}"; do
  # 例: host-20250919-011500 -> 2025-09-19 01:15:00
  d="${a##*-}"          # 末尾の YYYYmmdd-HHMMSS
  y=${d:0:4}; m=${d:4:2}; day=${d:6:2}; hh=${d:9:2}; mm=${d:11:2}; ss=${d:13:2}
  nice="${y}-${m}-${day} ${hh}:${mm}:${ss}"
  printf " %3d) %s  (%s)\n" "$i" "$a" "$nice"
  i=$((i+1))
done
echo "番号 もしくは 日付プレフィックス（例: 2025-09-18）で入力できます。"
printf "入力: "
read -r pick

# 選択解決
ARCH=""
if [[ "${pick}" =~ ^[0-9]+$ ]]; then
  if (( pick >= 1 && pick <= ${#ARCHES[@]} )); then
    ARCH="${ARCHES[$((pick-1))]}"
  fi
else
  # 日付プレフィックス検索（YYYY-mm-dd）
  # 名前から作った nice 表記と突き合わせ
  idx=1
  for a in "${ARCHES[@]}"; do
    d="${a##*-}"; y=${d:0:4}; m=${d:4:2}; day=${d:6:2}; hh=${d:9:2}; mm=${d:11:2}; ss=${d:13:2}
    nice="${y}-${m}-${day}"
    if [[ "${nice}" == "${pick}"* ]]; then ARCH="$a"; break; fi
    idx=$((idx+1))
  done
fi

if [[ -z "${ARCH}" ]]; then
  err "該当するアーカイブが見つかりません"; exit 1
fi

echo
echo "復元対象:"
echo "  repo : ${REPO}"
echo "  arch : ${ARCH}"
printf "よろしいですか？(yes/NO): "
read -r yn
[[ "${yn,,}" == "yes" ]] || { err "中止しました"; exit 1; }

# 念のため現行ワールドを退避
mkdir -p "${BASE}/obj/recovery"
tar -C "${DATA}" -czf "${BASE}/obj/recovery/world-$(date +%Y%m%d-%H%M%S).tgz" worlds/world 2>/dev/null || true

# 復元（ワールドのみ/アドオン含めない）
say "extract 開始..."
borg extract -v --numeric-owner "${REPO}::${ARCH}" "obj/data/worlds/world"

# 権限補正（Web/Nginx から読めるように world を公開読み）
chmod -R o+rx "${DATA}/worlds/world" || true

say "復元完了: ${ARCH}"
echo "※ そのまま 'omfs-up'（起動）でサーバーを立ち上げ可能です。"
BASH

chmod +x "${TOOLS_DIR}/restore_manual.sh"

# --------------------------------
# <セクション番号:なし>メッセージ
# --------------------------------
cat <<MSG

== 対話型 復元スクリプト（SSD/SD 選択・日付/番号選択対応）（動かし方のイメージ) ==
実行例（ローカル画面で対話）
sudo systemctl start omfs-restore@<あなたのユーザー名>

対話スクリプトを直接叩く（SSHでOK）
bash ~/omf/survival-dkr/obj/tools/restore_manual.sh

systemd（14Dユニット）でローカル画面から
sudo systemctl start omfs-restore@<ユーザー名>

SSHから systemd 経由で対話（TTY付き）
sudo systemd-run --uid <ユーザー名> --pty /bin/bash -lc '~/omf/survival-dkr/obj/tools/restore_manual.sh'

== 確認 ==
curl -s -S "http://${MONITOR_BIND}:${MONITOR_PORT}/health" | jq .
curl -s -S -H "x-api-key: ${API_TOKEN}" "http://${MONITOR_BIND}:${MONITOR_PORT}/players" | jq .
curl -s -S -H "x-api-key: ${API_TOKEN}" "http://${MONITOR_BIND}:${MONITOR_PORT}/chat"    | jq .

== Web ==
例）http://${WEB_BIND}:${WEB_PORT}/?token=${API_TOKEN}&name=名無し

== バックアップ ==
# まず key.conf を読み込む（BORG_* などを反映）
source ~/omf/survival-dkr/key/key.conf
# SSD 側アーカイブ一覧
borg list "$BORG_SSD_REPO"
# SD も設定しているなら
[ -n "${BORG_SD_REPO:-}" ] && borg list "$BORG_SD_REPO"

# バックアップの手動テスト（bds 停止中に）
bash ~/omf/survival-dkr/obj/tools/borg_daily.sh

< 復元の手動テスト（読み取りだけ試す）>
# 最新アーカイブ名を見る
borg list "$BORG_SSD_REPO" --last 1 --short
# 乾行（どんなファイルが入っているか眺める）
borg list "$BORG_SSD_REPO"::アーカイブ名 | head

== 手動で優雅停止する方法 ==
1. systemd 経由で停止する場合
sudo systemctl start omfs-stop@<ユーザー名>
2. スクリプトを直接叩く場合
bash ~/omf/survival-dkr/obj/tools/safe_stop.sh

== メモ ==
- compose.yml は restart ポリシー未指定（ブート時自動起動しません）→ cron で up/down 管理
- BDS は URL 差分があるときのみ更新。失敗時は既存温存
- uNmINeD は zip/tgz 自動判定で更新（どちらでも展開可能）
- Web サーバー情報本文は ${DATA_DIR}/html_server.html を編集
- ビルトイン packs は .omfs_builtin & .builtin_packs.json で保護（world_* には含めない）
- world_* は /data/worlds/world/ に出力（適用必須パス）
- 起動時に gamerule を FIFO で投入：showcoordinates=true / playerssleepingpercentage=1
MSG

