#!/usr/bin/env bash
# =====================================================================
# OMFS installer（差分更新版 / restartポリシー撤去 / バックアップ同梱）
#  - BDS: 公式APIのダウンロードURLが「変わったときだけ」取得・展開（失敗時は温存）
#  - uNmINeD: downloads をスクレイピングして ARM64 glibc の URL 差分更新
#  - Webポータル: /webchat・URL param (token,name) 必須・新UI・モバイル最適化
#  - monitor: /players /chat /webchat /allowlist/*、OMF-CHAT/OMF-DEATH 取り込み
#  - アドオン同期: ~/omf/survival-dkr/{resource,behavior} → obj/data/* へコピー
#                  world_*_packs.json はホスト由来のみで再生成（Vanilla/chemistry等は適用しない）
#  - GAS通知: 日次窓 07:50〜25:10 で、プレイヤーごと当日初回入室時に送信
#  - compose.yml: restart ポリシー記述なし（自動再起動せず、cron 管理向け）
#  - バックアップ: BASE/backups に “アドオン同梱” で作成。復元時にアドオン除外/同梱を選択可
#  - ★改修点: BDS同梱packを .omfs_builtin マーカー + .builtin_packs.json で保護
#            （/dataのpackは保持。world_* には含めない）/ URL差分なし時も復元
# =====================================================================
set -euo pipefail

# ---------- 変数 ----------
USER_NAME="${SUDO_USER:-$USER}"
HOME_DIR="$(getent passwd "$USER_NAME" | cut -d: -f6)"
BASE="${HOME_DIR}/omf/survival-dkr"
OBJ="${BASE}/obj"
DOCKER_DIR="${OBJ}/docker"
DATA_DIR="${OBJ}/data}"
DATA_DIR="${OBJ}/data"        # ← 上行のタイプミス保険
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

# ---------- apt ----------
echo "[SETUP] apt..."
sudo apt-get update -y
sudo apt-get install -y --no-install-recommends ca-certificates curl wget jq unzip git tzdata xz-utils build-essential rsync cmake ninja-build python3 procps file

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
      - ../data/map:/data-map:ro
    ports:
      - "${WEB_BIND}:${WEB_PORT}:80"
    depends_on:
      monitor:
        condition: service_started
YAML

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

# --- BDS 取得（差分更新方式 + ★ビルトインpack記録/マーカー設置 + スキップ時復元） ---
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
  # .omfs_builtin が付いているディレクトリから .builtin_packs.json を再生成
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
            import json
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
    # スキップ時も .builtin_packs.json が無ければマーカーから復元を試す
    [ -f "$BUILTIN" ] || make_builtin_from_markers || true
    exit 0
  else
    log "ERROR: could not obtain BDS url (no existing server)"
    exit 10
  fi
fi

if [ -f "$LAST" ] && [ "$(cat "$LAST" 2>/dev/null || true)" = "$URL" ] && [ -x ./bedrock_server ]; then
  log "URL unchanged; skip download"
  # スキップ時も .builtin_packs.json が無ければマーカーから復元を試す
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

# ★ZIP から pack ディレクトリ名一覧を抽出 → 展開後の pack に .omfs_builtin を付与 → UUID 取得 → JSON 保存
rp_list="$tmp/rp.list"; bp_list="$tmp/bp.list"
unzip -Z1 "$tmp/bds.zip" 2>/dev/null | grep -E '^resource_packs/[^/]+/manifest\.json$' \
 | sed 's#^resource_packs/\([^/]\+\)/manifest\.json$#\1#' | sort -u > "$rp_list" || true
unzip -Z1 "$tmp/bds.zip" 2>/dev/null | grep -E '^behavior_packs/[^/]+/manifest\.json$' \
 | sed 's#^behavior_packs/\([^/]\+\)/manifest\.json$#\1#' | sort -u > "$bp_list" || true

# マーカー作成
while read -r n; do
  [ -n "${n:-}" ] || continue
  [ -d "/data/resource_packs/$n" ] && touch "/data/resource_packs/$n/.omfs_builtin" || true
done < "$rp_list"
while read -r n; do
  [ -n "${n:-}" ] || continue
  [ -d "/data/behavior_packs/$n" ] && touch "/data/behavior_packs/$n/.omfs_builtin" || true
done < "$bp_list"

# JSON 生成
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

# --- アドオン同期（ビルトイン保護 + ホスト同期 + world_* はホストのみ） ---
cat > "${DOCKER_DIR}/bds/update_addons.py" <<'PY'
import os, json, re, shutil

ROOT="/data"
BP=os.path.join(ROOT,"behavior_packs")
RP=os.path.join(ROOT,"resource_packs")
WBP=os.path.join(ROOT,"world_behavior_packs.json")
WRP=os.path.join(ROOT,"world_resource_packs.json")
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
    marker=os.path.join(base, name, ".omfs_builtin")
    return os.path.exists(marker)

def build_builtin_sets():
    j=load_json(BUILTIN, {"resource":[],"behavior":[]})
    rp=set([x.get("name","") for x in j.get("resource",[]) if x.get("name")])
    bp=set([x.get("name","") for x in j.get("behavior",[]) if x.get("name")])
    # マーカー優先（JSONが古い/欠損でも守る）
    for n in list_dirs(RP):
        if is_builtin_dir(RP, n): rp.add(n)
    for n in list_dirs(BP):
        if is_builtin_dir(BP, n): bp.add(n)
    return rp, bp

def rsync_tree(src, dst):
    if not os.path.isdir(src): return
    for root, dirs, files in os.walk(src):
        rel=os.path.relpath(root, src)
        out=os.path.join(dst, rel) if rel!="." else dst
        os.makedirs(out, exist_ok=True)
        for f in files:
            s=os.path.join(root,f); t=os.path.join(out,f)
            shutil.copy2(s,t)

def apply_sync(host_dir, data_dir, builtin_names):
    ensure_dir(data_dir)
    cur=set(list_dirs(data_dir))
    host=set(list_dirs(host_dir)) if os.path.isdir(host_dir) else set()
    builtin=set(builtin_names)

    # 1) 削除: ホストになく、かつビルトインでもないもの
    for name in sorted(cur - builtin - host):
        try:
            shutil.rmtree(os.path.join(data_dir,name))
            print(f"[addons] removed: {name}")
        except: pass

    # 2) 追加/更新: ホスト → data（ビルトインに上書きはしない想定；名前被りは別名で管理してください）
    for name in sorted(host):
        s=os.path.join(host_dir,name)
        d=os.path.join(data_dir,name)
        if os.path.isdir(d):
            rsync_tree(s, d)
        else:
            shutil.copytree(s, d)
        # ホスト由来にはビルトインマーカーは付けない
        print(f"[addons] synced: {name}")

def scan_world(host_dir, typ):
    out=[]
    if not os.path.isdir(host_dir): return out
    for name in sorted(os.listdir(host_dir)):
        p=os.path.join(host_dir,name)
        mf=os.path.join(p,"manifest.json")
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
    tmp=p+".tmp"
    open(tmp,"w",encoding="utf-8").write(json.dumps(obj,ensure_ascii=False,indent=2))
    os.replace(tmp,p)
    print(f"[addons] wrote {p} ({len(obj)} packs)")

if __name__=="__main__":
    builtin_r, builtin_b = build_builtin_sets()
    apply_sync(HOST_R, RP, builtin_r)
    apply_sync(HOST_B, BP, builtin_b)
    write_json(WBP, scan_world(HOST_B, "data"))
    write_json(WRP, scan_world(HOST_R, "resources"))
PY

# --- エントリ（BDS 起動 / server.properties 整備 / world_* 再生成） ---
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

echo "[entry-bds] exec: box64 ./bedrock_server (stdin: /data/in.pipe)"
( tail -F /data/in.pipe | box64 ./bedrock_server 2>&1 | tee -a /data/bds_console.log ) | tee -a /data/bedrock_server.log
BASH
chmod +x "${DOCKER_DIR}/bds/"*.sh

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

def push_chat(player, message, color="normal"):
    with lock:
        j = jload(CHAT, [])
        j.append({"player": str(player), "message": str(message),
                  "timestamp": datetime.datetime.now().isoformat(), "color": color})
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
                player = f"死因:{killer}"
                push_chat(player, f"{obj.get('player','誰か')}さんが死亡しました。", "death")
                pos = obj.get("position",{})
                xyz = f"({pos.get('x','?')}, {pos.get('y','?')}, {pos.get('z','?')})"
                push_chat(player, f"座標: {xyz}", "death")
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

# ---------- web（/api プロキシ + 新UI + 外部本文 + パラメータ必須） ----------
mkdir -p "${DOCKER_DIR}/web"
cat > "${DOCKER_DIR}/web/Dockerfile" <<'DOCK'
FROM nginx:alpine
DOCK

cat > "${DOCKER_DIR}/web/nginx.conf" <<'NGX'
server {
  listen 80 default_server;
  server_name _;

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
<link rel="stylesheet" href="styles.css">
<script defer src="main.js"></script>
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

cat > "${WEB_SITE_DIR}/styles.css" <<'CSS'
*{box-sizing:border-box}html,body{height:100%}
:root{
  --bg:#0b0d10; --fg:#e8eef5; --soft:#c6d4e3;
  --card:#141821; --muted:#9fb2c6;
  --accent:#7aa2ff; --ok:#55FF55; --warn:#FFAA55; --err:#FF5555; --sys:#AAAAAA;
}
body{margin:0;background:var(--bg);color:var(--fg);font:16px system-ui,Segoe UI,Roboto,Helvetica,Arial}
header{position:sticky;top:0;background:#0a0e14;border-bottom:1px solid #1e2633;z-index:10}
.tabs{display:flex;gap:.25rem;padding:.5rem;max-width:980px;margin:0 auto}
.tab{flex:1;padding:.7rem 0;border:0;background:#161c26;color:#cfe0f5;cursor:pointer;border-radius:.5rem}
.tab.active{background:linear-gradient(180deg,#1f2a3a,#152033);color:#fff;font-weight:600}
main{max-width:980px;margin:0 auto;padding:1rem}
.panel{display:none}.panel.show{display:block}
.server-info{padding:1rem;background:var(--card);border:1px solid #1f2a3a;border-radius:.6rem}

.status-row{display:flex;gap:.5rem;align-items:center;margin-bottom:.5rem;color:var(--muted)}
.pill-row{display:flex;gap:.5rem;overflow-x:auto;padding:.25rem .5rem;border:1px solid #283449;border-radius:.5rem;min-height:2.2rem;background:#0f131b}
.pill{padding:.25rem .6rem;border-radius:999px;background:#162031;border:1px solid #293850;color:var(--soft)}

.param-error{padding:.6rem 1rem;background:#302025;border:1px solid #4c2a30;color:#f3c6cb;border-radius:.5rem}
.hidden{display:none}

.chat-list{border:1px solid #1f2a3a;border-radius:.6rem;height:56vh;overflow:auto;padding:.6rem;background:#0f131b}
.chat-item{margin:.4rem 0;padding:.5rem .6rem;border-radius:.5rem;background:#121926;border:1px solid #1b2738}
.chat-meta{display:flex;justify-content:space-between;font-size:.8rem;margin-bottom:.25rem;opacity:.9}
.chat-body{font-size:1rem;line-height:1.45}
.meta-normal{color:var(--ok)} .body-normal{color:#fff}
.meta-system{color:var(--sys)} .body-system{color:var(--sys)}
.meta-death{color:var(--err)} .body-death{color:var(--err)}

.chat-form{display:flex;gap:.6rem;margin-top:.6rem}
#chat-input{flex:1;padding:.7rem .8rem;border:1px solid #2a3548;border-radius:.5rem;background:#0e141f;color:#e8eef5}
#send-btn{padding:.7rem 1.2rem;border:0;background:linear-gradient(180deg,#3b6ff0,#274dd1);color:#fff;border-radius:.5rem;cursor:pointer;white-space:nowrap}

.map-header{margin:.5rem 0;font-weight:600;color:var(--soft)}
.map-frame{height:70vh;border:1px solid #1f2a3a;border-radius:.6rem;overflow:hidden;background:#0f131b}
.map-frame iframe{width:100%;height:100%;border:0}
CSS

cat > "${WEB_SITE_DIR}/main.js" <<'JS'
const API="/api";
function qs(k,def=""){try{const u=new URL(location.href);return u.searchParams.get(k)||def;}catch(_){return def}}
const TOKEN=qs("token",""); const NAME=qs("name","");
const SV  = localStorage.getItem("server_name") || "OMF";

document.addEventListener("DOMContentLoaded", ()=>{
  document.querySelectorAll(".tab").forEach(b=>{
    b.addEventListener("click", ()=>{
      document.querySelectorAll(".tab").forEach(x=>x.classList.remove("active"));
      document.querySelectorAll(".panel").forEach(x=>x.classList.remove("show"));
      b.classList.add("active"); document.getElementById(b.dataset.target).classList.add("show");
    });
  });

  fetchServerInfo();

  const okParams = Boolean(TOKEN) && Boolean(NAME);
  document.getElementById("param-error").classList.toggle("hidden", okParams);
  document.getElementById("chat-form").style.display = okParams ? "flex" : "none";

  refreshPlayers(); refreshChat();
  setInterval(refreshPlayers,15000); setInterval(refreshChat,12000);

  document.getElementById("chat-form").addEventListener("submit", async(e)=>{
    e.preventDefault();
    const v=document.getElementById("chat-input").value.trim(); if(!v) return;
    if(!okParams) return;
    try{
      const r=await fetch(API+"/webchat",{method:"POST",headers:{"Content-Type":"application/json","x-api-key":TOKEN},body:JSON.stringify({message:v,name:NAME})});
      if(!r.ok) throw 0; document.getElementById("chat-input").value=""; refreshChat();
    }catch(_){ alert("送信失敗"); }
  });
});

async function fetchServerInfo(){
  const box=document.getElementById("server-info");
  const cands=["/html_server.html","/html_server.txt","/html_server"];
  for(const c of cands){
    try{ const r=await fetch(c); if(!r.ok) continue; const t=await r.text(); box.innerHTML=t; return; }catch(_){}
  }
  box.innerHTML=`<p>ようこそ！<strong>${SV}</strong></p><p>掲示は Web または外部 API (<code>/api/webchat</code>) から送れます。</p>`;
}

async function refreshPlayers(){
  try{
    const r=await fetch(API+"/players",{headers:{"x-api-key":TOKEN}}); if(!r.ok) return;
    const d=await r.json(); const row=document.getElementById("players"); row.innerHTML="";
    (d.players||[]).forEach(n=>{ const el=document.createElement("div"); el.className="pill"; el.textContent=n; row.appendChild(el); });
  }catch(_){}
}
function fmt(ts){ try{const d=new Date(ts); return `${String(d.getHours()).padStart(2,'0')}:${String(d.getMinutes()).padStart(2,'0')}`;}catch(_){return ts} }
async function refreshChat(){
  try{
    const r=await fetch(API+"/chat",{headers:{"x-api-key":TOKEN}}); if(!r.ok) return;
    const d=await r.json(); const list=document.getElementById("chat-list"); list.innerHTML="";
    (d.latest||[]).forEach(m=>{
      const item=document.createElement("div"); item.className="chat-item";
      const meta=document.createElement("div"); meta.className=`chat-meta meta-${m.color||'normal'}`;
      const left=document.createElement("div"); left.textContent=`[${fmt(m.timestamp||'')}]`;
      const right=document.createElement("div"); right.textContent=(m.player||'名無し'); meta.appendChild(left); meta.appendChild(right);
      const text=document.createElement("div"); text.className=`chat-body body-${m.color||'normal'}`; text.textContent=(m.message||'');
      item.appendChild(meta); item.appendChild(text); list.appendChild(item);
    });
    list.scrollTop=list.scrollHeight;
  }catch(_){}
}
JS

# サーバー情報本文（外部HTML。編集して使う）
mkdir -p "${DATA_DIR}"
if [[ ! -f "${DATA_DIR}/html_server.html" ]]; then
  cat > "${DATA_DIR}/html_server.html" <<'HTML'
<p>ようこそ！<strong id="sv-name">OMF</strong></p>
<p>掲示は Web または外部 API (<code>/api/webchat</code>) から送れます。</p>
HTML
fi

# map 出力先プレースホルダ
mkdir -p "${DATA_DIR}/map"
if [[ ! -f "${DATA_DIR}/map/index.html" ]]; then
  echo '<!doctype html><meta charset="utf-8"><p>uNmINeD の Web 出力がここに作成されます。</p>' > "${DATA_DIR}/map/index.html"
fi

# ---------- uNmINeD: ARM64 glibc の差分取得 + レンダ ----------
cat > "${BASE}/update_map.sh" <<'BASH'
#!/usr/bin/env bash
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
need curl; need grep; need sed; command -v tar >/dev/null 2>&1 || true; command -v unzip >/dev/null 2>&1 || true

pick_url(){
  local page tmp url
  tmp="$(mktemp -d)"
  curl -fsSL "https://unmined.net/downloads/" > "$tmp/p.html"
  url="$(grep -Eo 'https://unmined\.net/download/unmined-cli-linux-arm64-dev/\?tmstv=[0-9]+' "$tmp/p.html" | head -n1 || true)"
  rm -rf "$tmp"
  [ -n "$url" ] || return 1
  echo "$url"
}

install_from_url(){
  local url="$1" tmp ext
  tmp="$(mktemp -d)"
  log "downloading: $url"
  curl -fL --retry 3 --retry-delay 2 -o "$tmp/pkg" "$url" || { rm -rf "$tmp"; return 1; }
  if file "$tmp/pkg" 2>/dev/null | grep -qi 'Zip'; then ext=zip; else ext=tgz; fi
  mkdir -p "$tmp/x"
  if [ "$ext" = "zip" ]; then unzip -qo "$tmp/pkg" -d "$tmp/x"; else tar xzf "$tmp/pkg" -C "$tmp/x"; fi
  local root; root="$(find "$tmp/x" -maxdepth 2 -type f -name 'unmined-cli' -printf '%h\n' | head -n1 || true)"
  [ -n "$root" ] || { rm -rf "$tmp"; return 1; }
  rsync -a "$root"/ "${TOOLS}/" 2>/dev/null || cp -rf "$root"/ "${TOOLS}/"
  chmod +x "${BIN}" || true
  echo -n "$url" > "${LAST}"
  rm -rf "$tmp"
}

main(){
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

  if [ -x "${BIN}" ]; then
    log "rendering..."
    "${BIN}" web render --world "${WORLD}" --output "${OUT}" --chunkprocessors 4 || { log "ERROR: render failed"; exit 1; }
    log "done -> ${OUT}"
  else
    log "ERROR: unmined-cli not installed"
    exit 1
  fi
}
main "$@"
BASH
chmod +x "${BASE}/update_map.sh"

# ---------- バックアップ（アドオン同梱） ----------
cat > "${BASE}/backup_now.sh" <<'BASH'
#!/usr/bin/env bash
set -euo pipefail
USER_NAME="${SUDO_USER:-$USER}"
HOME_DIR="$(getent passwd "$USER_NAME" | cut -d: -f6)"
BASE="${HOME_DIR}/omf/survival-dkr"
OBJ="${BASE}/obj"
DATA="${OBJ}/data"
BKP_OUTER="${BASE}/backups"

mkdir -p "${BKP_OUTER}"
TS="$(date +%Y%m%d-%H%M%S)"
WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

echo "[backup] staging..."
mkdir -p "${WORK}/stage"
rsync -a "${DATA}/" "${WORK}/stage/data/"
if [ -d "${BASE}/resource" ]; then rsync -a "${BASE}/resource/" "${WORK}/stage/host_resource/"; fi
if [ -d "${BASE}/behavior" ]; then rsync -a "${BASE}/behavior/" "${WORK}/stage/host_behavior/"; fi

cat > "${WORK}/stage/metadata.json" <<JSON
{"created_at":"$(date --iso-8601=seconds)","server_name":"$(jq -r . 2>/dev/null <<<"${SERVER_NAME:-OMF}" || echo OMFS)","includes_addons":true}
JSON

OUT="${BKP_OUTER}/backup-${TS}.tgz"
echo "[backup] archiving -> ${OUT}"
tar -C "${WORK}/stage" -czf "${OUT}" .
echo "[backup] done."
echo "${OUT}"
BASH
chmod +x "${BASE}/backup_now.sh"

# ---------- 復元（アドオン除外/同梱の選択） ----------
cat > "${BASE}/restore_backup.sh" <<'BASH'
#!/usr/bin/env bash
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
    local ts="$(tar -tzf "$f" 2>/dev/null | grep -m1 '^metadata\.json$' >/dev/null && tar -xOzf "$f" metadata.json | jq -r '.created_at' 2>/dev/null || echo -n '')"
    printf " %2d) %s %s\n" "$i" "$(basename "$f")" "${ts:+($ts)}"
    i=$((i+1))
  done
  echo -n "select number: "; read -r num
  if ! [[ "$num" =~ ^[0-9]+$ ]] || [ "$num" -lt 1 ] || [ "$num" -gt "${#BKPS[@]}" ]; then
    echo "invalid selection"; exit 1
  fi
  echo -n "${BKPS[$((num-1))]}"
}

BKP_FILE="${1:-}"
if [ -z "${BKP_FILE}" ]; then BKP_FILE="$(choose_backup)"; fi
[ -f "${BKP_FILE}" ] || { echo "backup not found: ${BKP_FILE}"; exit 1; }

echo -n "Restore addons as well? (y/N): "; read -r RESTORE_ADDONS
RESTORE_ADDONS="$(echo "${RESTORE_ADDONS:-N}" | tr 'A-Z' 'a-z')"
INCLUDE_ADDONS=false
if [ "${RESTORE_ADDONS}" = "y" ] || [ "${RESTORE_ADDONS}" = "yes" ]; then INCLUDE_ADDONS=true; fi

echo "[restore] stopping stack (if any)..."
if [ -f "${DOCKER_DIR}/compose.yml" ]; then
  sudo docker compose -f "${DOCKER_DIR}/compose.yml" down --remove-orphans || true
fi
for c in bds bds-monitor bds-web; do sudo docker rm -f "$c" >/dev/null 2>&1 || true; done

echo "[restore] extracting..."
WORK="$(mktemp -d)"; trap 'rm -rf "$WORK"' EXIT
tar -C "${WORK}" -xzf "${BKP_FILE}"

mkdir -p "${DATA}"
if $INCLUDE_ADDONS; then
  rsync -a "${WORK}/data/" "${DATA}/"
else
  rsync -a \
    --exclude "resource_packs" \
    --exclude "behavior_packs" \
    --exclude "world_resource_packs.json" \
    --exclude "world_behavior_packs.json" \
    "${WORK}/data/" "${DATA}/"
fi

if $INCLUDE_ADDONS; then
  if [ -d "${WORK}/host_resource" ]; then mkdir -p "${BASE}/resource"; rsync -a "${WORK}/host_resource/" "${BASE}/resource/"; fi
  if [ -d "${WORK}/host_behavior" ]; then mkdir -p "${BASE}/behavior"; rsync -a "${WORK}/host_behavior/" "${BASE}/behavior/"; fi
fi

echo "[restore] done."
echo "※ アドオン除外で復元した場合は、次回起動時にホスト由来のアドオンのみが world_* に反映されます。"
BASH
chmod +x "${BASE}/restore_backup.sh"

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
cat <<MSG

== 確認 ==
curl -s -S "http://${MONITOR_BIND}:${MONITOR_PORT}/health" | jq .
curl -s -S -H "x-api-key: ${API_TOKEN}" "http://${MONITOR_BIND}:${MONITOR_PORT}/players" | jq .
curl -s -S -H "x-api-key: ${API_TOKEN}" "http://${MONITOR_BIND}:${MONITOR_PORT}/chat"    | jq .

== Web ==
例）http://${WEB_BIND}:${WEB_PORT}/?token=${API_TOKEN}&name=名無し

== バックアップ ==
作成: ${BASE}/backup_now.sh
復元: ${BASE}/restore_backup.sh

== メモ ==
- compose.yml は restart ポリシー未指定（ブート時自動起動しません）→ cron で up/down 管理
- BDS は URL 差分があるときのみ更新。失敗時は既存温存
- uNmINeD も URL 差分で更新
- Web サーバー情報本文は ${DATA_DIR}/html_server.html を編集
- ★ビルトイン packs は .omfs_builtin マーカー & .builtin_packs.json で保護（world_* には含めない）
- ★URL差分なしで get_bds.sh がスキップしても、.builtin_packs.json がなければマーカーから自動復元
- ★ホスト resource/behavior の変更は、起動時に /data へ同期 & world_* をホスト由来だけで再生成
MSG

