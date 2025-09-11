#!/usr/bin/env bash
# =====================================================================
# OMFS installer.sh  (RPi5 / Debian Bookworm 想定)
# - LeviLamina 系は使わない
# - Script API ベースのチャット収集（互換対応：新旧APIどちらでも動作）
# - ログテイラーは bds_console.log を一次ソース（なければ ContentLog*）
# - uNmINeD (ARM64 glibc) 自動DL & Web 出力（見出しは「昨日までのマップデータ」）
# - compose: bds / contentlog-tail / monitor / web
# =====================================================================
set -euo pipefail

# ===== ユーザ設定ファイル =====
USER_NAME="${SUDO_USER:-$USER}"
HOME_DIR="$(getent passwd "$USER_NAME" | cut -d: -f6)"
BASE="${HOME_DIR}/omf/survival-dkr"
OBJ="${BASE}/obj"
DOCKER_DIR="${OBJ}/docker"
DATA_DIR="${OBJ}/data"
BKP_DIR="${DATA_DIR}/backups"
WEB_SITE_DIR="${DOCKER_DIR}/web/site"
TOOLS_DIR="${OBJ}/tools"
KEY_FILE="${BASE}/key/key.conf"

# ===== 事前チェック =====
mkdir -p "${DOCKER_DIR}" "${DATA_DIR}" "${BKP_DIR}" "${WEB_SITE_DIR}" "${TOOLS_DIR}"
sudo chown -R "${USER_NAME}:${USER_NAME}" "${BASE}" || true

[[ -f "${KEY_FILE}" ]] || { echo "[ERR] key.conf が見つかりません: ${KEY_FILE}"; exit 1; }
# shellcheck disable=SC1090
source "${KEY_FILE}"
: "${SERVER_NAME:?SERVER_NAME を key.conf に設定してください}"
: "${API_TOKEN:?API_TOKEN を key.conf に設定してください}"
: "${GAS_URL:?GAS_URL を key.conf に設定してください}"

# ===== ポートなど =====
BDS_PORT_PUBLIC_V4="${BDS_PORT_PUBLIC_V4:-13922}"   # 公開ポート（クライアント接続）
BDS_PORT_V6="${BDS_PORT_V6:-19132}"                 # LAN ディスカバリ
MONITOR_BIND="${MONITOR_BIND:-127.0.0.1}"
MONITOR_PORT="${MONITOR_PORT:-13900}"
WEB_BIND="${WEB_BIND:-0.0.0.0}"
WEB_PORT="${WEB_PORT:-13901}"
BDS_URL="${BDS_URL:-}"             # 固定BDS URL（空=自動）
ALL_CLEAN="${ALL_CLEAN:-false}"

echo "[INFO] OMFS start user=${USER_NAME} base=${BASE} ALL_CLEAN=${ALL_CLEAN}"

# ===== 既存停止・掃除 =====
echo "[CLEAN] stopping old stack..."
if [[ -f "${DOCKER_DIR}/compose.yml" ]]; then
  sudo docker compose -f "${DOCKER_DIR}/compose.yml" down --remove-orphans || true
fi
for c in bds contentlog-tail bds-monitor bds-web; do
  sudo docker rm -f "$c" >/dev/null 2>&1 || true
done
if [[ "${ALL_CLEAN}" == "true" ]]; then
  sudo docker system prune -a -f || true
  rm -rf "${OBJ}"
else
  sudo docker system prune -f || true
fi
mkdir -p "${DOCKER_DIR}" "${DATA_DIR}" "${BKP_DIR}" "${WEB_SITE_DIR}" "${TOOLS_DIR}"
sudo chown -R "${USER_NAME}:${USER_NAME}" "${OBJ}" || true

# ===== ホスト依存 =====
echo "[SETUP] apt..."
sudo apt-get update -y
sudo apt-get install -y --no-install-recommends \
  ca-certificates curl wget jq unzip git tzdata xz-utils build-essential rsync

# ===== .env =====
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
ENV

# ===== compose =====
cat > "${DOCKER_DIR}/compose.yml" <<'YAML'
services:
  # ---- Bedrock Dedicated Server (box64実行) ----
  bds:
    build: { context: ./bds }
    image: local/bds-box64:latest
    container_name: bds
    env_file: .env
    environment:
      TZ: ${TZ}
      SERVER_NAME: ${SERVER_NAME}
      GAS_URL: ${GAS_URL}
      API_TOKEN: ${API_TOKEN}
      BDS_URL: ${BDS_URL}
      BDS_PORT_V4: ${BDS_PORT_PUBLIC_V4}
      BDS_PORT_V6: ${BDS_PORT_V6}
    volumes:
      - ../data:/data
    ports:
      - "${BDS_PORT_PUBLIC_V4}:${BDS_PORT_PUBLIC_V4}/udp"
      - "${BDS_PORT_V6}:${BDS_PORT_V6}/udp"
    restart: unless-stopped

  # ---- contentlog-tail（bds_console.log / ContentLog* -> chat.json / players.json） ----
  contentlog-tail:
    build: { context: ./contentlog }
    image: local/contentlog-tail:latest
    container_name: contentlog-tail
    env_file: .env
    environment:
      TZ: ${TZ}
    volumes:
      - ../data:/data
    depends_on:
      - bds
    restart: unless-stopped

  # ---- 監視 API（/players, /chat を /data/*.json から返す） ----
  monitor:
    build: { context: ./monitor }
    image: local/bds-monitor:latest
    container_name: bds-monitor
    env_file: .env
    environment:
      TZ: ${TZ}
      SERVER_NAME: ${SERVER_NAME}
      GAS_URL: ${GAS_URL}
      API_TOKEN: ${API_TOKEN}
    volumes:
      - ../data:/data
    ports:
      - "${MONITOR_BIND}:${MONITOR_PORT}:13900/tcp"
    depends_on:
      - contentlog-tail
    healthcheck:
      test: ["CMD", "curl", "-fsS", "http://127.0.0.1:13900/health"]
      interval: 10s
      timeout: 3s
      retries: 12
      start_period: 20s
    restart: unless-stopped

  # ---- Web（見出しは「昨日までのマップデータ」固定） ----
  web:
    build: { context: ./web }
    image: local/bds-web:latest
    container_name: bds-web
    env_file: .env
    environment:
      TZ: ${TZ}
      MONITOR_INTERNAL: http://bds-monitor:13900
    volumes:
      - ./web/nginx.conf:/etc/nginx/conf.d/default.conf:ro
      - ./web/site:/usr/share/nginx/html:ro
      - ../data/map:/data-map:ro
    ports:
      - "${WEB_BIND}:${WEB_PORT}:80"
    depends_on:
      monitor:
        condition: service_healthy
    restart: unless-stopped
YAML

# ===== bds イメージ =====
mkdir -p "${DOCKER_DIR}/bds"

cat > "${DOCKER_DIR}/bds/Dockerfile" <<'DOCK'
FROM debian:bookworm-slim
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates curl wget unzip jq xz-utils procps build-essential git cmake ninja-build python3 rsync \
 && rm -rf /var/lib/apt/lists/*

# box64（x64 ELF 実行用）
RUN git clone --depth=1 https://github.com/ptitSeb/box64 /tmp/box64 \
 && cmake -S /tmp/box64 -B /tmp/box64/build -G Ninja \
      -DARM_DYNAREC=ON -DDEFAULT_PAGESIZE=16384 -DCMAKE_BUILD_TYPE=RelWithDebInfo \
 && cmake --build /tmp/box64/build -j && cmake --install /tmp/box64/build \
 && rm -rf /tmp/box64

WORKDIR /usr/local/bin
COPY get_bds.sh update_addons.py enable_packs.py entry-bds.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/*.sh

WORKDIR /data
EXPOSE 13922/udp 19132/udp
CMD ["/usr/local/bin/entry-bds.sh"]
DOCK

# --- BDS 取得 ---
cat > "${DOCKER_DIR}/bds/get_bds.sh" <<'BASH'
#!/usr/bin/env bash
set -euo pipefail
mkdir -p /data
cd /data
log(){ echo "[get_bds] $*"; }

API="https://net-secondary.web.minecraft-services.net/api/v1.0/download/links"
get_url_api(){
  curl --http1.1 -fsSL -H 'Accept: application/json' --retry 3 --retry-delay 2 "$API" \
  | jq -r '.result.links[] | select(.downloadType=="serverBedrockLinux") | .downloadUrl' \
  | head -n1
}
URL="${BDS_URL:-}"
if [ -z "$URL" ]; then URL="$(get_url_api || true)"; fi
[ -n "$URL" ] || { log "ERROR: could not obtain BDS url"; exit 10; }

log "downloading: ${URL}"
if ! wget -q -O bedrock-server.zip "${URL}"; then
  curl --http1.1 -fL -o bedrock-server.zip "${URL}"
fi
unzip -qo bedrock-server.zip -x server.properties allowlist.json
rm -f bedrock-server.zip
log "updated BDS payload"
BASH

# --- アドオン一覧 JSON（参考出力） ---
cat > "${DOCKER_DIR}/bds/update_addons.py" <<'PY'
import os, json, re
ROOT="/data"
BP=os.path.join(ROOT,"behavior_packs")
RP=os.path.join(ROOT,"resource_packs")
WBP=os.path.join(ROOT,"world_behavior_packs.json")
WRP=os.path.join(ROOT,"world_resource_packs.json")
def _load_lenient(p):
  s=open(p,"r",encoding="utf-8").read()
  s=re.sub(r'//.*','',s); s=re.sub(r'/\*.*?\*/','',s,flags=re.S); s=re.sub(r',\s*([}\]])',r'\1',s)
  return json.loads(s)
def scan(d,tp):
  out=[]; 
  if not os.path.isdir(d): return out
  for name in sorted(os.listdir(d)):
    p=os.path.join(d,name); mf=os.path.join(p,"manifest.json")
    if not os.path.isdir(p) or not os.path.isfile(mf): continue
    try:
      m=_load_lenient(mf); uuid=m["header"]["uuid"]; ver=m["header"]["version"]
      if not(isinstance(ver,list) and len(ver)==3): raise ValueError("bad version")
      out.append({"pack_id":uuid,"version":ver,"type":tp}); print(f"[addons] {name} {uuid} {ver}")
    except Exception as e: print(f"[addons] invalid manifest in {name}: {e}")
  return out
def write(p,items): open(p,"w",encoding="utf-8").write(json.dumps(items,indent=2,ensure_ascii=False)); print(f"[addons] wrote {p} ({len(items)} packs)")
if __name__=="__main__":
  write(WBP,scan(BP,"data")); write(WRP,scan(RP,"resources"))
PY

# --- ワールドに指定パック（チャットロガー & プローブ）を有効化 ---
cat > "${DOCKER_DIR}/bds/enable_packs.py" <<'PY'
import os, json

ROOT="/data"
WORLD=os.path.join(ROOT,"worlds","world")
WBP=os.path.join(WORLD,"world_behavior_packs.json")
os.makedirs(WORLD, exist_ok=True)

# 必ず有効化したい pack
REQUIRED=[
  {"pack_id":"8f6e9a32-bb0b-47df-8f0e-12b7df0e3d77","version":[1,0,0],"type":"data"},  # omf_chatlogger
  {"pack_id":"11111111-2222-4333-8444-555555555555","version":[1,0,0],"type":"data"},  # omf_scriptprobe
]

def load_json(path):
  try:
    with open(path,"r",encoding="utf-8") as f: return json.load(f)
  except: return []

def save_json(path, obj):
  with open(path,"w",encoding="utf-8") as f: json.dump(obj,f,ensure_ascii=False,indent=2)

cur=load_json(WBP)
# 重複防止
exist=set((x.get("pack_id"), tuple(x.get("version",[]))) for x in cur if isinstance(x,dict))
for it in REQUIRED:
  key=(it["pack_id"], tuple(it["version"]))
  if key not in exist:
    cur.insert(0, it)
save_json(WBP, cur)
print(f"[packs] enabled: {WBP} ({len(cur)} entries)")
PY

# --- エントリ（BDS 単体起動） ---
cat > "${DOCKER_DIR}/bds/entry-bds.sh" <<'BASH'
#!/usr/bin/env bash
set -euo pipefail
export TZ="${TZ:-Asia/Tokyo}"
cd /data; mkdir -p /data

# 初回 server.properties
if [ ! -f server.properties ]; then
  cat > server.properties <<PROP
server-name=${SERVER_NAME:-OMF}
gamemode=survival
difficulty=normal
allow-cheats=false
max-players=5
online-mode=true
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
PROP
else
  sed -i "s/^server-port=.*/server-port=${BDS_PORT_V4:-13922}/" server.properties
  sed -i "s/^server-portv6=.*/server-portv6=${BDS_PORT_V6:-19132}/" server.properties
  sed -i "s/^content-log-file-enabled=.*/content-log-file-enabled=true/" server.properties
  if grep -q '^content-log-file-name=' server.properties; then
    sed -i "s/^content-log-file-name=.*/content-log-file-name=content.log/" server.properties
  else
    echo "content-log-file-name=content.log" >> server.properties
  fi
fi

# 必要ファイル
[ -f allowlist.json ] || echo "[]" > allowlist.json
[ -d worlds/world/db ] || mkdir -p worlds/world/db
touch bedrock_server.log bds_console.log

# BDS 配布物取得
/usr/local/bin/get_bds.sh

# 挙動確認用 & チャット収集用 Behavior Pack をホスト側から利用するのでここで有効化
python3 /usr/local/bin/update_addons.py || true
python3 /usr/local/bin/enable_packs.py || true

# 起動メッセージ（Web 表示用）
python3 - <<'PY' || true
import json,os,datetime
f="chat.json"; d=[]
try:
  if os.path.exists(f): d=json.load(open(f))
except: d=[]
if not isinstance(d,list): d=[]
d.append({"player":"SYSTEM","message":"サーバーが起動しました","timestamp":datetime.datetime.now().isoformat()})
d=d[-50:]; json.dump(d,open(f,"w"),ensure_ascii=False)
PY

echo "[entry-bds] exec: box64 ./bedrock_server"
box64 ./bedrock_server 2>&1 | tee -a /data/bds_console.log
BASH
chmod +x "${DOCKER_DIR}/bds/"*.sh

# ===== Script API アドオン（ホスト側に配置） =====
# omf_chatlogger（互換API対応 main.js）
mkdir -p "${DATA_DIR}/behavior_packs/omf_chatlogger/scripts"
cat > "${DATA_DIR}/behavior_packs/omf_chatlogger/manifest.json" <<'JSON'
{
  "format_version": 2,
  "header": {
    "name": "OMF Chat Logger",
    "description": "Collect chat/join/leave/death via Script API",
    "uuid": "8f6e9a32-bb0b-47df-8f0e-12b7df0e3d77",
    "version": [1,0,0],
    "min_engine_version": [1,21,0]
  },
  "modules": [
    {
      "type": "script",
      "language": "javascript",
      "uuid": "9c7d0a13-8e2f-4e62-9e09-0f9b6bd2daaa",
      "entry": "scripts/main.js",
      "version": [1,0,0]
    }
  ],
  "dependencies": [
    { "module_name": "@minecraft/server", "version": "1.12.0" }
  ]
}
JSON

cat > "${DATA_DIR}/behavior_packs/omf_chatlogger/scripts/main.js" <<'JS'
// OMF Chat Logger (API互換対応版)
import { world, system } from "@minecraft/server";
function log(obj){ try{ console.log(`[OMFCHAT] ${JSON.stringify(obj)}`); }catch{} }

// chat
try{
  if (world.beforeEvents?.chatSend?.subscribe){
    world.beforeEvents.chatSend.subscribe((ev)=>{
      try{ const name=ev.sender?.name??"unknown"; const msg=ev.message??""; log({type:"chat",name,message:msg}); }catch{}
    });
  } else if (world.events?.beforeChat?.subscribe){
    world.events.beforeChat.subscribe((ev)=>{
      try{ const name=ev.sender?.name??"unknown"; const msg=ev.message??""; log({type:"chat",name,message:msg}); }catch{}
    });
  } else {
    system.runTimeout(()=>log({type:"system",message:"chat hook not available"}),40);
  }
}catch{}

// join
try{
  if (world.afterEvents?.playerSpawn?.subscribe){
    world.afterEvents.playerSpawn.subscribe((ev)=>{ try{ if(!ev.initialSpawn) return; const name=ev.player?.name??"unknown"; log({type:"join",name}); }catch{} });
  }
}catch{}

// leave
try{
  if (world.afterEvents?.playerLeave?.subscribe){
    world.afterEvents.playerLeave.subscribe((ev)=>{ try{ const name=ev.playerName??"unknown"; log({type:"leave",name}); }catch{} });
  }
}catch{}

// death
try{
  if (world.afterEvents?.entityDie?.subscribe){
    world.afterEvents.entityDie.subscribe((ev)=>{ try{
      const e=ev.deadEntity; if(e?.typeId==="minecraft:player"){ const name=e.name??e.nameTag??"player"; const cause=ev.damageSource?.cause??""; log({type:"death",name,message:String(cause)}); }
    }catch{} });
  }
}catch{}

system.runTimeout(()=>{ log({type:"system",message:"chatlogger ready (compat)"}); },60);
JS

# omf_scriptprobe（生存確認ログ）
mkdir -p "${DATA_DIR}/behavior_packs/omf_scriptprobe/scripts"
cat > "${DATA_DIR}/behavior_packs/omf_scriptprobe/manifest.json" <<'JSON'
{
  "format_version": 2,
  "header": {
    "name": "OMF Script Probe",
    "description": "Simple probe to verify Script API runs",
    "uuid": "11111111-2222-4333-8444-555555555555",
    "version": [1,0,0],
    "min_engine_version": [1,21,0]
  },
  "modules": [
    {
      "type": "script",
      "language": "javascript",
      "uuid": "aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee",
      "entry": "scripts/main.js",
      "version": [1,0,0]
    }
  ],
  "dependencies": [
    { "module_name": "@minecraft/server", "version": "1.12.0" }
  ]
}
JSON

cat > "${DATA_DIR}/behavior_packs/omf_scriptprobe/scripts/main.js" <<'JS'
import { system } from "@minecraft/server";
system.runTimeout(()=>{ console.log("[OMFTEST] Script probe is alive."); }, 40);
JS

# ===== contentlog-tail（bds_console.log -> chat.json / players.json） =====
mkdir -p "${DOCKER_DIR}/contentlog"
cat > "${DOCKER_DIR}/contentlog/Dockerfile" <<'DOCK'
FROM python:3.11-slim
RUN apt-get update && apt-get install -y --no-install-recommends ca-certificates && rm -rf /var/lib/apt/lists/*
WORKDIR /app
COPY tailer.py /app/tailer.py
CMD ["python","/app/tailer.py"]
DOCK

cat > "${DOCKER_DIR}/contentlog/tailer.py" <<'PY'
import os, time, json, re, glob, datetime
DATA="/data"
CHAT=os.path.join(DATA,"chat.json")
PLAY=os.path.join(DATA,"players.json")
BDS_CON=os.path.join(DATA,"bds_console.log")
MAX_CHAT=50
PAT=re.compile(r'\[OMFCHAT\]\s*(\{.*\})\s*$')
def safe_load(path,defv):
    try:
        if not os.path.exists(path): return defv
        with open(path,"r",encoding="utf-8") as f: return json.load(f)
    except: return defv
def safe_dump(path,obj):
    tmp=path+".tmp"
    with open(tmp,"w",encoding="utf-8") as f: json.dump(obj,f,ensure_ascii=False)
    os.replace(tmp,path)
def ensure_files():
    if not os.path.exists(CHAT): safe_dump(CHAT,[])
    if not os.path.exists(PLAY): safe_dump(PLAY,[])
def latest_contentlog():
    files=sorted(glob.glob(os.path.join(DATA,"ContentLog*")))
    return files[-1] if files else None
def choose_source(cur_src):
    if os.path.exists(BDS_CON):
        if cur_src!=BDS_CON: return (BDS_CON,0)
        return (BDS_CON,None)
    latest=latest_contentlog()
    if latest and latest!=cur_src: return (latest,0)
    return (cur_src,None)
def push_chat(player,message):
    j=safe_load(CHAT,[]); j.append({"player":player,"message":str(message),"timestamp":datetime.datetime.now().isoformat()})
    j=j[-MAX_CHAT:]; safe_dump(CHAT,j)
def add_player(name):
    s=set(safe_load(PLAY,[])); s.add(name); safe_dump(PLAY,sorted(s))
def remove_player(name):
    s=set(safe_load(PLAY,[])); s.discard(name); safe_dump(PLAY,sorted(s))
def handle(obj):
    t=obj.get("type"); n=(obj.get("name") or "").strip(); m=(obj.get("message") or "").strip()
    if t=="chat" and n and m: push_chat(n,m)
    elif t=="join" and n: add_player(n); push_chat("SYSTEM",f"{n} が参加")
    elif t=="leave" and n: remove_player(n); push_chat("SYSTEM",f"{n} が退出")
    elif t=="death" and n: push_chat("DEATH",f"{n}: {m or '死亡'}")
    elif t=="system" and m: push_chat("SYSTEM",m)
def follow():
    cur=None; pos=0
    while True:
        cur,reset=choose_source(cur)
        if cur is None: time.sleep(0.5); continue
        if reset is not None:
            pos=reset
            try: push_chat("SYSTEM",f"Log attach: {os.path.basename(cur)}")
            except: pass
        try:
            with open(cur,"r",encoding="utf-8",errors="ignore") as f:
                f.seek(pos)
                for line in f:
                    pos=f.tell()
                    m=PAT.search(line)
                    if not m: continue
                    try: obj=json.loads(m.group(1)); handle(obj)
                    except: pass
        except FileNotFoundError:
            time.sleep(0.3)
        time.sleep(0.2)
def main():
    ensure_files(); follow()
if __name__=="__main__": main()
PY

# ===== monitor =====
mkdir -p "${DOCKER_DIR}/monitor"
cat > "${DOCKER_DIR}/monitor/Dockerfile" <<'DOCK'
FROM python:3.11-slim
RUN apt-get update && apt-get install -y --no-install-recommends ca-certificates curl jq procps \
 && rm -rf /var/lib/apt/lists/*
WORKDIR /app
RUN pip install --no-cache-dir fastapi uvicorn requests pydantic
COPY monitor_players.py /app/monitor_players.py
EXPOSE 13900/tcp
CMD ["python","/app/monitor_players.py"]
DOCK

cat > "${DOCKER_DIR}/monitor/monitor_players.py" <<'PY'
import os, json, datetime
from fastapi import FastAPI, Header, HTTPException
from pydantic import BaseModel
import uvicorn

DATA="/data"
CFG_GAS=os.getenv("GAS_URL","")
API_TOKEN=os.getenv("API_TOKEN","")
SERVER_NAME=os.getenv("SERVER_NAME","OMF")

PLAYERS_FILE=os.path.join(DATA,"players.json")
CHAT_FILE=os.path.join(DATA,"chat.json")
MAX_CHAT=50

app=FastAPI()

def read_json(p,defv):
  try:
    with open(p,"r",encoding="utf-8") as f: return json.load(f)
  except: return defv

@app.get("/health")
def health():
  ok_chat=os.path.exists(CHAT_FILE); ok_players=os.path.exists(PLAYERS_FILE)
  return {"ok":True,"chat_file":ok_chat,"players_file":ok_players,"ts":datetime.datetime.now().isoformat()}

class ChatIn(BaseModel): message:str

@app.get("/players")
def players(x_api_key: str = Header(None)):
  if x_api_key != API_TOKEN: raise HTTPException(status_code=403, detail="Forbidden")
  return {"server":SERVER_NAME,"players":read_json(PLAYERS_FILE,[]),"timestamp":datetime.datetime.now().isoformat()}

@app.get("/chat")
def chat(x_api_key: str = Header(None)):
  if x_api_key != API_TOKEN: raise HTTPException(status_code=403, detail="Forbidden")
  j=read_json(CHAT_FILE,[])
  return {"server":SERVER_NAME,"latest":j[-MAX_CHAT:],"count":len(j),"timestamp":datetime.datetime.now().isoformat()}

@app.post("/chat")
def post_chat(body: ChatIn, x_api_key: str = Header(None)):
  if x_api_key != API_TOKEN: raise HTTPException(status_code=403, detail="Forbidden")
  msg=body.message.strip()
  if not msg: raise HTTPException(status_code=400, detail="Empty")
  j=read_json(CHAT_FILE,[]); j.append({"player":"API","message":msg,"timestamp":datetime.datetime.now().isoformat()}); j=j[-MAX_CHAT:]
  try:
    with open(CHAT_FILE,"w",encoding="utf-8") as f: json.dump(j,f,ensure_ascii=False)
  except: pass
  return {"status":"ok"}

if __name__=="__main__":
  uvicorn.run(app, host="0.0.0.0", port=13900, log_level="info")
PY

# ===== web（見出し修正済み） =====
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
<!doctype html><html lang="ja"><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>OMF Portal</title>
<link rel="stylesheet" href="styles.css"><script defer src="main.js"></script>
<body>
<header><nav class="tabs"><button class="tab active" data-target="info">サーバー情報</button><button class="tab" data-target="chat">チャット</button><button class="tab" data-target="map">マップ</button></nav></header>
<main>
<section id="info" class="panel show"><h1>サーバー情報</h1><p>ようこそ！<strong id="sv-name"></strong></p></section>
<section id="chat" class="panel">
  <div class="status-row"><span>現在接続中:</span><div id="players" class="pill-row"></div></div>
  <div class="chat-list" id="chat-list"></div>
  <form id="chat-form" class="chat-form"><input id="chat-input" type="text" placeholder="メッセージ..." maxlength="200"/><button type="submit">送信</button></form>
</section>
<section id="map" class="panel"><div class="map-header">昨日までのマップデータ</div><div class="map-frame"><iframe id="map-iframe" src="/map/index.html"></iframe></div></section>
</main>
</body></html>
HTML

cat > "${WEB_SITE_DIR}/styles.css" <<'CSS'
*{box-sizing:border-box}body{margin:0;font-family:system-ui,Segoe UI,Roboto,Helvetica,Arial}
header{position:sticky;top:0;background:#111;color:#fff}
.tabs{display:flex;gap:.25rem;padding:.5rem}
.tab{flex:1;padding:.6rem 0;border:0;background:#222;color:#eee;cursor:pointer}
.tab.active{background:#0a84ff;color:#fff;font-weight:600}
.panel{display:none;padding:1rem}.panel.show{display:block}
.status-row{display:flex;gap:.5rem;align-items:center;margin-bottom:.5rem}
.pill-row{display:flex;gap:.5rem;overflow-x:auto;padding:.25rem .5rem;border:1px solid #ddd;border-radius:.5rem;min-height:2.2rem}
.pill{padding:.25rem .6rem;border-radius:999px;background:#f1f1f1;border:1px solid #ddd}
.chat-list{border:1px solid #ddd;border-radius:.5rem;height:50vh;overflow:auto;padding:.5rem;background:#fafafa}
.chat-item{margin:.25rem 0;padding:.35rem .5rem;border-radius:.25rem;background:#fff;border:1px solid #eee}
.chat-form{display:flex;gap:.5rem;margin-top:.5rem}
.chat-form input{flex:1;padding:.6rem;border:1px solid #ccc;border-radius:.4rem}
.chat-form button{padding:.6rem 1rem;border:0;background:#0a84ff;color:#fff;border-radius:.4rem;cursor:pointer}
.map-header{margin:.5rem 0;font-weight:600}
.map-frame{height:70vh;border:1px solid #ddd;border-radius:.5rem;overflow:hidden}
.map-frame iframe{width:100%;height:100%;border:0}
CSS

cat > "${WEB_SITE_DIR}/main.js" <<'JS'
const API = "/api";
const TOKEN = localStorage.getItem("x_api_key") || "";
const SV = localStorage.getItem("server_name") || "OMF";
document.addEventListener("DOMContentLoaded", ()=>{
  document.getElementById("sv-name").textContent = SV;
  document.querySelectorAll(".tab").forEach(b=>{
    b.addEventListener("click", ()=>{
      document.querySelectorAll(".tab").forEach(x=>x.classList.remove("active"));
      document.querySelectorAll(".panel").forEach(x=>x.classList.remove("show"));
      b.classList.add("active"); document.getElementById(b.dataset.target).classList.add("show");
    });
  });
  refreshPlayers(); refreshChat();
  setInterval(refreshPlayers,15000); setInterval(refreshChat,15000);
  document.getElementById("chat-form").addEventListener("submit", async(e)=>{
    e.preventDefault();
    const v=document.getElementById("chat-input").value.trim(); if(!v) return;
    try{
      const r=await fetch(API+"/chat",{method:"POST",headers:{"Content-Type":"application/json","x-api-key":TOKEN},body:JSON.stringify({message:v})});
      if(!r.ok) throw 0; document.getElementById("chat-input").value=""; refreshChat();
    }catch(_){ alert("送信失敗"); }
  });
});
async function refreshPlayers(){
  try{
    const r=await fetch(API+"/players",{headers:{"x-api-key":TOKEN}}); if(!r.ok) return;
    const d=await r.json(); const row=document.getElementById("players"); row.innerHTML="";
    (d.players||[]).forEach(n=>{ const el=document.createElement("div"); el.className="pill"; el.textContent=n; row.appendChild(el); });
  }catch(_){}
}
async function refreshChat(){
  try{
    const r=await fetch(API+"/chat",{headers:{"x-api-key":TOKEN}}); if(!r.ok) return;
    const d=await r.json(); const list=document.getElementById("chat-list"); list.innerHTML="";
    (d.latest||[]).forEach(m=>{ const el=document.createElement("div"); el.className="chat-item"; el.textContent=`[${(m.timestamp||'').replace('T',' ').slice(0,19)}] ${m.player}: ${m.message}`; list.appendChild(el); });
    list.scrollTop=list.scrollHeight;
  }catch(_){}
}
JS

# ===== map 出力先プレースホルダ =====
mkdir -p "${DATA_DIR}/map"
if [[ ! -f "${DATA_DIR}/map/index.html" ]]; then
  echo '<!doctype html><meta charset="utf-8"><p>uNmINeD の Web 出力がここに作成されます。</p>' > "${DATA_DIR}/map/index.html"
fi

# ===== uNmINeD 自動DL & Web Render（ARM64 glibc 限定） =====
cat > "${BASE}/update_map.sh" <<'BASH'
#!/usr/bin/env bash
# uNmINeD Web マップ更新 (ARM64 glibc 専用)
set -euo pipefail
BASE_DIR="$(cd "$(dirname "$0")" && pwd)"
DATA="${BASE_DIR}/obj/data"
WORLD="${DATA}/worlds/world"
OUT="${DATA}/map"
TOOLS="${BASE_DIR}/obj/tools/unmined"
BIN="${TOOLS}/unmined-cli"
CFG_DIR="${TOOLS}/config"
TPL_DIR="${TOOLS}/templates"
TPL_ZIP="${TPL_DIR}/default.web.template.zip"
mkdir -p "${TOOLS}" "${OUT}"
log(){ echo "[update_map] $*" >&2; }
need_cmd(){ command -v "$1" >/dev/null 2>&1 || { log "ERROR: '$1' not found"; exit 2; }; }
need_cmd curl; need_cmd grep; need_cmd awk; command -v tar >/dev/null 2>&1 || true; command -v unzip >/dev/null 2>&1 || true; command -v file >/dev/null 2>&1 || true
pick_arm_url(){
  local page tmp url; page="https://unmined.net/downloads/"; tmp="$(mktemp -d)"
  log "scanning downloads page..."; curl -fsSL "$page" > "$tmp/page.html"
  url="$(grep -Eo 'https://unmined\.net/download/unmined-cli-linux-arm64-dev/\?tmstv=[0-9]+' "$tmp/page.html" | head -n1 || true)"
  rm -rf "$tmp"; [ -n "$url" ] || return 1; echo "$url"
}
install_from_archive(){
  local url="$1" tmp ext ctype root; tmp="$(mktemp -d)"
  log "downloading: ${url}"; curl -fL --retry 3 --retry-delay 2 -D "$tmp/headers" -o "$tmp/pkg" "$url"
  if command -v file >/dev/null 2>&1; then
    if   file "$tmp/pkg" | grep -qi 'Zip archive data'; then ext="zip"
    elif file "$tmp/pkg" | grep -qi 'gzip compressed data'; then ext="tgz"
    else ctype="$(awk 'BEGIN{IGNORECASE=1}/^Content-Type:/{print $2}' "$tmp/headers" | tr -d '\r' || true)"
         case "${ctype:-}" in application/zip) ext="zip";; application/gzip|application/x-gzip|application/x-tgz) ext="tgz";; *) ext="unknown";; esac
    fi
  else
    ctype="$(awk 'BEGIN{IGNORECASE=1}/^Content-Type:/{print $2}' "$tmp/headers" | tr -d '\r' || true)"
    case "${ctype:-}" in application/zip) ext="zip";; application/gzip|application/x-gzip|application/x-tgz) ext="tgz";; *) ext="unknown";; esac
  fi
  mkdir -p "$tmp/x"
  case "$ext" in tgz) tar xzf "$tmp/pkg" -C "$tmp/x" ;; zip) unzip -qo "$tmp/pkg" -d "$tmp/x" ;; *) log "ERROR: unsupported archive format"; rm -rf "$tmp"; return 1;; esac
  root="$(find "$tmp/x" -maxdepth 2 -type d -name 'unmined-cli*' | head -n1 || true)"; [ -n "$root" ] || root="$tmp/x"
  if [ ! -f "$root/unmined-cli" ]; then root="$(dirname "$(find "$tmp/x" -type f -name 'unmined-cli' | head -n1 || true)")"; fi
  [ -n "$root" ] && [ -f "$root/unmined-cli" ] || { log "ERROR: unmined-cli not found in archive"; rm -rf "$tmp"; return 1; }
  mkdir -p "${TOOLS}"; rsync -a "$root"/ "${TOOLS}/" 2>/dev/null || cp -rf "$root"/ "${TOOLS}/"; chmod +x "${BIN}"; rm -rf "$tmp"
  if [ ! -f "${TPL_ZIP}" ]; then if [ -d "${TPL_DIR}" ] && [ -f "${TPL_DIR}/default.web.template.zip" ]; then :; else log "ERROR: templates/default.web.template.zip missing in package"; return 1; fi; fi
}
render_map(){
  log "rendering web map from: ${WORLD}"
  mkdir -p "${OUT}"; pushd "${TOOLS}" >/dev/null
  if [ ! -f "${CFG_DIR}/blocktags.js" ]; then mkdir -p "${CFG_DIR}"; cat > "${CFG_DIR}/blocktags.js" <<'JS'
export default {};
JS
  fi
  "./unmined-cli" --version || true
  "./unmined-cli" web render --world "${WORLD}" --output "${OUT}" --chunkprocessors 4
  local rc=$?; popd >/dev/null; return $rc
}
main(){
  if [ ! -x "${BIN}" ] || [ ! -f "${TPL_ZIP}" ]; then
    url="$(pick_arm_url || true)"; [ -n "${url:-}" ] || { log "ERROR: could not discover ARM64 (glibc) URL"; exit 1; }
    log "URL picked: ${url}"; install_from_archive "$url"
  else log "uNmINeD CLI already installed"; fi
  if render_map; then log "done -> ${OUT}"; else log "ERROR: render failed"; exit 1; fi
}
main "$@"
BASH
chmod +x "${BASE}/update_map.sh"

# ===== ビルド & 起動 =====
echo "[BUILD] images..."
sudo docker compose -f "${DOCKER_DIR}/compose.yml" build --no-cache

echo "[PREFETCH] BDS payload ..."
sudo docker run --rm -e TZ=Asia/Tokyo --entrypoint /usr/local/bin/get_bds.sh -v "${DATA_DIR}:/data" local/bds-box64:latest

echo "[UP] compose up -d ..."
sudo docker compose -f "${DOCKER_DIR}/compose.yml" up -d

sleep 3
cat <<MSG

== 確認 ==
curl -s -S "http://${MONITOR_BIND}:${MONITOR_PORT}/health" | jq .
curl -s -S -H "x-api-key: ${API_TOKEN}" "http://${MONITOR_BIND}:${MONITOR_PORT}/players" | jq .
curl -s -S -H "x-api-key: ${API_TOKEN}" "http://${MONITOR_BIND}:${MONITOR_PORT}/chat"    | jq .

# マップ更新
${BASE}/update_map.sh

# BDS 接続
- クライアントは 「公開ポート ${BDS_PORT_PUBLIC_V4}/udp」に接続
- bds_console.log に [OMFCHAT] 行が出れば Script API ロガーが稼働
- chat.json / players.json に反映され、/api/chat / /api/players で取得可
MSG

