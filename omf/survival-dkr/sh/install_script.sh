#!/usr/bin/env bash
# =====================================================================
# OMFS install_script.sh (RPi5 / Debian Bookworm)  [FIX: pack爆積み抑止版]
# - 変更点:
#   * world_behavior_packs.json を「OMF Chat Logger のみ」に強制固定
#   * update_addons.py は参照出力のみ（world_*_packs.json を書かない）
#   * enable_packs.py は上書きモードで安全リストのみを反映
#   * ScriptAPI は安定API中心（@minecraft/server のみ）。UI依存を排除
# - 構成: bds / contentlog-tail / monitor / web
# =====================================================================

set -euo pipefail

# ===== 変数・ディレクトリ =====
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

mkdir -p "${DOCKER_DIR}" "${DATA_DIR}" "${BKP_DIR}" "${WEB_SITE_DIR}" "${TOOLS_DIR}"
sudo chown -R "${USER_NAME}:${USER_NAME}" "${BASE}" || true

[[ -f "${KEY_FILE}" ]] || { echo "[ERR] key.conf が見つかりません: ${KEY_FILE}"; exit 1; }
# shellcheck disable=SC1090
source "${KEY_FILE}"

: "${SERVER_NAME:?SERVER_NAME を key.conf に設定してください}"
: "${API_TOKEN:?API_TOKEN を key.conf に設定してください}"
: "${GAS_URL:?GAS_URL を key.conf に設定してください}"

# ===== ポート / 環境 =====
TZ="${TZ:-Asia/Tokyo}"
BDS_PORT_PUBLIC_V4="${BDS_PORT_PUBLIC_V4:-13922}"   # クライアント接続
BDS_PORT_V6="${BDS_PORT_V6:-19132}"                 # LAN Discovery
MONITOR_BIND="${MONITOR_BIND:-0.0.0.0}"
MONITOR_PORT="${MONITOR_PORT:-13900}"
WEB_BIND="${WEB_BIND:-0.0.0.0}"
WEB_PORT="${WEB_PORT:-13901}"
BDS_URL="${BDS_URL:-}"                              # 固定BDS URL（空=自動）
ALL_CLEAN="${ALL_CLEAN:-false}"

echo "[INFO] OMFS start user=${USER_NAME} base=${BASE} ALL_CLEAN=${ALL_CLEAN}"

# ===== 停止・掃除 =====
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

# ===== 必要パッケージ =====
echo "[SETUP] apt..."
sudo apt-get update -y
sudo apt-get install -y --no-install-recommends \
  ca-certificates curl wget jq unzip git tzdata xz-utils build-essential rsync

# ===== .env =====
cat > "${DOCKER_DIR}/.env" <<EOF
TZ=${TZ}
SERVER_NAME=${SERVER_NAME}
API_TOKEN=${API_TOKEN}
GAS_URL=${GAS_URL}
BDS_URL=${BDS_URL}
BDS_PORT_PUBLIC_V4=${BDS_PORT_PUBLIC_V4}
BDS_PORT_V6=${BDS_PORT_V6}
MONITOR_BIND=${MONITOR_BIND}
MONITOR_PORT=${MONITOR_PORT}
WEB_BIND=${WEB_BIND}
WEB_PORT=${WEB_PORT}
EOF

# ===== compose.yml =====
cat > "${DOCKER_DIR}/compose.yml" <<'YAML'
services:
  # ---- Bedrock Dedicated Server (box64) ----
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

  # ---- contentlog-tail（OMFCHATログ→ chat.json / players.json） ----
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

  # ---- 監視 API ----
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

  # ---- Web（見出し「昨日までのマップデータ」固定） ----
  web:
    build: { context: ./web }
    image: local/bds-web:latest
    container_name: bds-web
    env_file: .env
    environment:
      TZ: ${TZ}
      MONITOR_INTERNAL: http://bds-monitor:13900
    volumes:
      - ./web/nginx.conf:/etc/nginx/conf.d/default.conf:ro   # file→file
      - ./web/site:/usr/share/nginx/html:ro
      - ../data/map:/data-map:ro
    ports:
      - "${WEB_BIND}:${WEB_PORT}:80"
    depends_on:
      monitor:
        condition: service_healthy
    restart: unless-stopped
YAML

# ===== bds/Dockerfile =====
mkdir -p "${DOCKER_DIR}/bds"
cat > "${DOCKER_DIR}/bds/Dockerfile" <<'DOCK'
FROM debian:bookworm-slim
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends \
  ca-certificates curl wget unzip jq xz-utils procps build-essential git cmake ninja-build python3 rsync \
  && rm -rf /var/lib/apt/lists/*
# box64
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

# ===== bds/get_bds.sh =====
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
chmod +x "${DOCKER_DIR}/bds/get_bds.sh"

# ===== bds/update_addons.py（参照出力のみ） =====
cat > "${DOCKER_DIR}/bds/update_addons.py" <<'PY'
import os, json, re
ROOT="/data"
BP=os.path.join(ROOT,"behavior_packs")
RP=os.path.join(ROOT,"resource_packs")
OUT=os.path.join(ROOT,"addons_scan.json")

def _load_lenient(p):
    s=open(p,"r",encoding="utf-8").read()
    s=re.sub(r'//.*','',s); s=re.sub(r'/\*.*?\*/','',s,flags=re.S)
    s=re.sub(r',\s*([}\]])',r'\1',s)
    return json.loads(s)

def scan(d,tp):
    out=[]
    if not os.path.isdir(d): return out
    for name in sorted(os.listdir(d)):
        p=os.path.join(d,name); mf=os.path.join(p,"manifest.json")
        if not os.path.isdir(p) or not os.path.isfile(mf): continue
        try:
            m=_load_lenient(mf)
            uuid=m["header"]["uuid"]; ver=m["header"]["version"]
            if not(isinstance(ver,list) and len(ver)==3): raise ValueError("bad version")
            out.append({"name":name,"pack_id":uuid,"version":ver,"type":tp})
        except Exception as e:
            out.append({"name":name,"error":str(e)})
    return out

if __name__=="__main__":
    info={"bp":scan(BP,"data"),"rp":scan(RP,"resources")}
    with open(OUT,"w",encoding="utf-8") as f:
        json.dump(info,f,ensure_ascii=False,indent=2)
    print(f"[addons] wrote {OUT}")
PY

# ===== bds/enable_packs.py（上書き・安全リストのみ） =====
cat > "${DOCKER_DIR}/bds/enable_packs.py" <<'PY'
import os, json
ROOT="/data"
WORLD=os.path.join(ROOT,"worlds","world")
WBP=os.path.join(WORLD,"world_behavior_packs.json")
WRP=os.path.join(WORLD,"world_resource_packs.json")

# 安全リスト: OMF Chat Logger のみ
SAFE_BEHAVIOR=[{"pack_id":"8f6e9a32-bb0b-47df-8f0e-12b7df0e3d77","version":[1,0,0],"type":"data"}]
SAFE_RESOURCE=[]

def save(p,obj):
    os.makedirs(os.path.dirname(p), exist_ok=True)
    with open(p,"w",encoding="utf-8") as f:
        json.dump(obj,f,ensure_ascii=False,indent=2)

if __name__=="__main__":
    save(WBP, SAFE_BEHAVIOR)
    save(WRP, SAFE_RESOURCE)
    print(f"[packs] wrote: {WBP} ({len(SAFE_BEHAVIOR)})")
    print(f"[packs] wrote: {WRP} ({len(SAFE_RESOURCE)})")
PY

# ===== bds/entry-bds.sh =====
cat > "${DOCKER_DIR}/bds/entry-bds.sh" <<'BASH'
#!/usr/bin/env bash
set -euo pipefail
export TZ="${TZ:-Asia/Tokyo}"
cd /data

# 1) BDS payload
/get_bds.sh

# 2) 最低限の server.properties
if [ ! -f server.properties ]; then
cat > server.properties <<PROP
server-name=${SERVER_NAME:-OMF}
server-port=${BDS_PORT_V4:-13922}
server-portv6=${BDS_PORT_V6:-19132}
white-list=false
online-mode=true
allow-cheats=false
max-players=10
view-distance=16
tick-distance=4
emit-server-telemetry=false
enable-lan-visibility=true
content-log-file-enabled=true
PROP
fi

# 3) OMF Chat Logger（安定API寄せ）
mkdir -p /data/behavior_packs/omf_chatlogger/scripts
cat > /data/behavior_packs/omf_chatlogger/manifest.json <<'JSON'
{
  "format_version": 2,
  "header": {
    "name": "OMF Chat Logger",
    "description": "Collect chat/join/leave/death via Script API (stable first)",
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
  ],
  "capabilities": [ "script_eval" ]
}
JSON

cat > /data/behavior_packs/omf_chatlogger/scripts/main.js <<'JS'
// OMF Chat Logger (stable-first)
import { world, system } from "@minecraft/server";
function out(obj){ try{ console.log(`[OMFCHAT] ${JSON.stringify(obj)}`) }catch{} }

// chat (stable paths)
try {
  world.beforeEvents.chatSend.subscribe(ev=>{
    try{ out({type:"chat", name: ev.sender?.name ?? "unknown", message: ev.message ?? ""}); }catch{}
  });
} catch {}
try {
  world.afterEvents.chatSend.subscribe(ev=>{
    try{ out({type:"chat", name: ev.sender?.name ?? "unknown", message: ev.message ?? ""}); }catch{}
  });
} catch {}

// join
try {
  world.afterEvents.playerSpawn.subscribe(ev=>{
    try{ if(ev.initialSpawn){ out({type:"join", name: ev.player?.name ?? "unknown"}) } }catch{}
  });
} catch {}

// leave (fallback: players pollで補完)
system.runInterval(()=>{
  try{
    const names = world.getPlayers().map(p=>p.name).filter(Boolean).sort();
    out({type:"players", list:names});
  }catch{}
}, 100);

// death
try {
  world.afterEvents.entityDie.subscribe(ev=>{
    try{
      const e=ev.deadEntity;
      if(e?.typeId==="minecraft:player"){
        const name=e.name ?? e.nameTag ?? "player";
        const cause=ev.damageSource?.cause ?? "";
        out({type:"death", name, message:String(cause)});
      }
    }catch{}
  });
} catch {}

// 起動表示
system.runTimeout(()=>{ out({type:"system", message:"chat hook ready(stable)"}) }, 60);
JS

# 4) ワールド packs は「安全リストに固定」
python3 /usr/local/bin/enable_packs.py

# 5) 参照用: 既存BP/RPをスキャン（world_*_packs.json は書かない）
python3 /usr/local/bin/update_addons.py || true

# 6) ログ案内（ContentLog or bds_console）
echo "=== OMF BDS ENTRY DONE ===" | tee -a /data/bds_console.log

# 7) 実行
exec /usr/local/bin/box64 ./bedrock_server
BASH
chmod +x "${DOCKER_DIR}/bds/entry-bds.sh"

# ===== contentlog-tail =====
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

def push_chat(player,message):
    j=safe_load(CHAT,[]); j.append({"player":player,"message":str(message),"timestamp":datetime.datetime.now().isoformat()})
    j=j[-MAX_CHAT:]; safe_dump(CHAT,j)

def set_players(names):
    safe_dump(PLAY, sorted(set([n for n in names if isinstance(n,str) and n.strip()])) )

def handle(obj):
    t=obj.get("type")
    if t=="chat":
        n=(obj.get("name") or "").strip(); m=(obj.get("message") or "").strip()
        if n and m: push_chat(n,m)
    elif t=="join":
        n=(obj.get("name") or "").strip()
        if n:
            ps=set(safe_load(PLAY,[])); ps.add(n); safe_dump(PLAY,sorted(ps)); push_chat("SYSTEM",f"{n} が参加")
    elif t=="leave":
        n=(obj.get("name") or "").strip()
        if n:
            ps=set(safe_load(PLAY,[])); ps.discard(n); safe_dump(PLAY,sorted(ps)); push_chat("SYSTEM",f"{n} が退出")
    elif t=="death":
        n=(obj.get("name") or "").strip(); m=(obj.get("message") or "").strip()
        if n: push_chat("DEATH",f"{n}: {m or '死亡'}")
    elif t=="system":
        m=(obj.get("message") or "").strip()
        if m: push_chat("SYSTEM",m)
    elif t=="players":
        lst=obj.get("list")
        if isinstance(lst,list): set_players(lst)

def follow():
    ensure_files()
    pos=0
    while True:
        try:
            with open(BDS_CON,"r",encoding="utf-8",errors="ignore") as f:
                f.seek(pos)
                for line in f:
                    pos=f.tell()
                    m=PAT.search(line)
                    if not m: continue
                    try:
                        obj=json.loads(m.group(1)); handle(obj)
                    except: pass
        except FileNotFoundError:
            time.sleep(0.3)
        time.sleep(0.2)

if __name__=="__main__":
    follow()
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
import os, json, datetime, threading, time, re
from fastapi import FastAPI, Header, HTTPException
from pydantic import BaseModel
import uvicorn

DATA="/data"
API_TOKEN=os.getenv("API_TOKEN","")
SERVER_NAME=os.getenv("SERVER_NAME","OMF")
PLAYERS_FILE=os.path.join(DATA,"players.json")
CHAT_FILE=os.path.join(DATA,"chat.json")
BDS_LOG=os.path.join(DATA,"bedrock_server.log")
MAX_CHAT=50
RE_SAY1 = re.compile(r'\[Server\]\s*(.+)$')
RE_SAY2 = re.compile(r'\bServer:\s*(.+)$')

app=FastAPI()
lock=threading.Lock()

def read_json(p,defv):
    try:
        with open(p,"r",encoding="utf-8") as f: return json.load(f)
    except: return defv

def write_json(p,obj):
    tmp=p+".tmp"
    with open(tmp,"w",encoding="utf-8") as f: json.dump(obj,f,ensure_ascii=False)
    os.replace(tmp,p)

def push_chat(player,msg):
    with lock:
        j=read_json(CHAT_FILE,[])
        j.append({"player":player,"message":msg,"timestamp":datetime.datetime.now().isoformat()})
        j=j[-MAX_CHAT:]
        write_json(CHAT_FILE,j)

def tail_bds_log():
    pos=0
    while True:
        try:
            with open(BDS_LOG,"r",encoding="utf-8",errors="ignore") as f:
                f.seek(pos, os.SEEK_SET)
                while True:
                    line=f.readline()
                    if not line:
                        pos=f.tell(); time.sleep(0.2); break
                    line=line.rstrip("\r\n")
                    m=RE_SAY1.search(line) or RE_SAY2.search(line)
                    if m:
                        msg=m.group(1).strip()
                        if msg: push_chat("SERVER", msg)
        except FileNotFoundError:
            time.sleep(0.5)

class ChatIn(BaseModel):
    message:str

@app.on_event("startup")
def _startup():
    if not os.path.exists(CHAT_FILE): write_json(CHAT_FILE,[])
    if not os.path.exists(PLAYERS_FILE): write_json(PLAYERS_FILE,[])
    threading.Thread(target=tail_bds_log,daemon=True).start()

@app.get("/health")
def health():
    return {"ok":True,"chat_file":os.path.exists(CHAT_FILE),"players_file":os.path.exists(PLAYERS_FILE),
            "ts":datetime.datetime.now().isoformat()}

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
    msg=(body.message or "").strip()
    if not msg: raise HTTPException(status_code=400, detail="Empty")
    push_chat("API", msg)
    return {"status":"ok"}

if __name__=="__main__":
    uvicorn.run(app, host="0.0.0.0", port=13900, log_level="info")
PY

# ===== web（Nginx + タブUI、見出し固定） =====
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
  location /map/ { alias /data-map/; autoindex on; }
  location /     { root /usr/share/nginx/html; index index.html; try_files $uri $uri/ =404; }
}
NGX

mkdir -p "${WEB_SITE_DIR}"
cat > "${WEB_SITE_DIR}/index.html" <<'HTML'
<!doctype html><meta charset="utf-8"/>
<title>OMF Portal</title>
<link rel="stylesheet" href="styles.css">
<header><div class="tabs">
  <button class="tab active" data-target="p1">サーバー情報</button>
  <button class="tab" data-target="p2">チャット</button>
  <button class="tab" data-target="p3">マップ</button>
</div></header>
<main>
  <section id="p1" class="panel show">
    <h1 id="sv-name">OMF</h1>
    <div class="status-row"><div>現在接続中:</div><div id="players" class="pill-row"></div></div>
  </section>
  <section id="p2" class="panel">
    <div id="chat-list" class="chat-list"></div>
    <form id="chat-form" class="chat-form">
      <input id="chat-input" placeholder="メッセージを送信"/>
      <button type="submit">送信</button>
    </form>
  </section>
  <section id="p3" class="panel">
    <div class="map-header">昨日までのマップデータ</div>
    <div class="map-frame"><iframe src="/map/"></iframe></div>
  </section>
</main>
<script src="main.js"></script>
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
.map-header{margin:.5rem 0;font-weight:600}.map-frame{height:70vh;border:1px solid #ddd;border-radius:.5rem;overflow:hidden}
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
      b.classList.add("active");
      document.getElementById(b.dataset.target).classList.add("show");
    });
  });
  refreshPlayers(); refreshChat();
  setInterval(refreshPlayers,15000);
  setInterval(refreshChat,15000);
  document.getElementById("chat-form").addEventListener("submit", async(e)=>{
    e.preventDefault();
    const v=document.getElementById("chat-input").value.trim();
    if(!v) return;
    try{
      const r=await fetch(API+"/chat",{method:"POST",headers:{"Content-Type":"application/json","x-api-key":TOKEN},body:JSON.stringify({message:v})});
      if(!r.ok) throw 0;
      document.getElementById("chat-input").value="";
      refreshChat();
    }catch(_){ alert("送信失敗"); }
  });
});

async function refreshPlayers(){
  try{
    const r=await fetch(API+"/players",{headers:{"x-api-key":TOKEN}});
    if(!r.ok) return;
    const d=await r.json();
    const row=document.getElementById("players");
    row.innerHTML="";
    (d.players||[]).forEach(n=>{
      const el=document.createElement("div"); el.className="pill"; el.textContent=n; row.appendChild(el);
    });
  }catch(_){}
}
async function refreshChat(){
  try{
    const r=await fetch(API+"/chat",{headers:{"x-api-key":TOKEN}});
    if(!r.ok) return;
    const d=await r.json();
    const list=document.getElementById("chat-list");
    list.innerHTML="";
    (d.latest||[]).forEach(m=>{
      const el=document.createElement("div");
      el.className="chat-item";
      el.textContent=`[${(m.timestamp||'').replace('T',' ').slice(0,19)}] ${m.player}: ${m.message}`;
      list.appendChild(el);
    });
    list.scrollTop=list.scrollHeight;
  }catch(_){}
}
JS

# ===== map プレースホルダ =====
mkdir -p "${DATA_DIR}/map"
if [[ ! -f "${DATA_DIR}/map/index.html" ]]; then
  echo '<!doctype html><meta charset="utf-8"/><title>map</title><p>uNmINeD の Web 出力がここに作成されます。</p>' > "${DATA_DIR}/map/index.html"
fi

# ===== ビルド & 起動 =====
echo "[BUILD] docker images..."
sudo docker compose -f "${DOCKER_DIR}/compose.yml" build --no-cache
echo "[UP] compose up -d ..."
sudo docker compose -f "${DOCKER_DIR}/compose.yml" up -d

echo "[DONE] OMFS ready."

