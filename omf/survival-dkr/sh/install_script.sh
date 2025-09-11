#!/usr/bin/env bash
# =====================================================================
# OMFS install_script.sh
#  - Script API(安定)で通常チャットを /me "<name>: <msg>" に変換
#  - bedrock_server.log を tail して /chat,/players を提供（入退室も拾う）
#  - LeviLamina/UDPプロキシ/βAPI/手紙アドオン 不要
#  - world_behavior_packs.json / world_resource_packs.json を
#    /data と /data/worlds/world/ の両方に配置し Pack Stack を確実化
#  - uNmINeD: ARM64 glibc 自動DL + web render（従来通り）
# =====================================================================
set -euo pipefail

# ---- 変数/ディレクトリ -------------------------------------------------------
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

# ---- ポート/設定 --------------------------------------------------------------
BDS_PORT_V4="${BDS_PORT_V4:-13922}"     # ゲームUDP
BDS_PORT_V6="${BDS_PORT_V6:-19132}"     # LAN
MONITOR_BIND="${MONITOR_BIND:-127.0.0.1}"
MONITOR_PORT="${MONITOR_PORT:-13900}"
WEB_BIND="${WEB_BIND:-0.0.0.0}"
WEB_PORT="${WEB_PORT:-13901}"
BDS_URL="${BDS_URL:-}"                  # BDS固定URL（空=自動）

echo "[INFO] OMFS start user=${USER_NAME} base=${BASE}"

# ---- 既存停止/掃除 -----------------------------------------------------------
echo "[CLEAN] stopping old stack..."
if [[ -f "${DOCKER_DIR}/compose.yml" ]]; then
  sudo docker compose -f "${DOCKER_DIR}/compose.yml" down --remove-orphans || true
fi
for c in bds bds-monitor bds-web logtail; do sudo docker rm -f "$c" >/dev/null 2>&1 || true; done
sudo docker system prune -f || true
mkdir -p "${DOCKER_DIR}" "${DATA_DIR}" "${BKP_DIR}" "${WEB_SITE_DIR}" "${TOOLS_DIR}"
sudo chown -R "${USER_NAME}:${USER_NAME}" "${OBJ}" || true

# ---- ホスト依存 --------------------------------------------------------------
echo "[SETUP] apt..."
sudo apt-get update -y
sudo apt-get install -y --no-install-recommends ca-certificates curl wget jq unzip git tzdata xz-utils build-essential rsync

# ---- .env --------------------------------------------------------------------
cat > "${DOCKER_DIR}/.env" <<ENV
TZ=Asia/Tokyo
GAS_URL=${GAS_URL}
API_TOKEN=${API_TOKEN}
SERVER_NAME=${SERVER_NAME}
BDS_PORT_V4=${BDS_PORT_V4}
BDS_PORT_V6=${BDS_PORT_V6}
MONITOR_PORT=${MONITOR_PORT}
WEB_PORT=${WEB_PORT}
BDS_URL=${BDS_URL}
ENV

# ---- compose -----------------------------------------------------------------
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
      BDS_PORT_V4: \${BDS_PORT_V4}
      BDS_PORT_V6: \${BDS_PORT_V6}
    volumes:
      - ../data:/data
    ports:
      - "\${BDS_PORT_V4}:\${BDS_PORT_V4}/udp"
      - "\${BDS_PORT_V6}:\${BDS_PORT_V6}/udp"
    restart: unless-stopped

  logtail:
    build: { context: ./logtail }
    image: local/logtail:latest
    container_name: logtail
    env_file: .env
    environment:
      TZ: \${TZ}
      ALLOWLIST_ENROLL: "true"   # 入室検知で allowlist に自動登録するなら true
    volumes:
      - ../data:/data
    depends_on:
      - bds
    restart: unless-stopped

  monitor:
    build: { context: ./monitor }
    image: local/bds-monitor:latest
    container_name: bds-monitor
    env_file: .env
    environment:
      TZ: \${TZ}
      SERVER_NAME: \${SERVER_NAME}
      GAS_URL: \${GAS_URL}
      API_TOKEN: \${API_TOKEN}
    volumes:
      - ../data:/data
    ports:
      - "${MONITOR_BIND}:${MONITOR_PORT}:13900/tcp"
    depends_on:
      bds:
        condition: service_started
    healthcheck:
      test: ["CMD", "curl", "-fsS", "http://127.0.0.1:13900/health"]
      interval: 10s
      timeout: 3s
      retries: 12
      start_period: 20s
    restart: unless-stopped

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
        condition: service_healthy
    restart: unless-stopped
YAML

# ---- bds image ---------------------------------------------------------------
mkdir -p "${DOCKER_DIR}/bds"

cat > "${DOCKER_DIR}/bds/Dockerfile" <<'DOCK'
FROM debian:bookworm-slim
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates curl wget unzip jq xz-utils procps build-essential git cmake ninja-build python3 rsync \
 && rm -rf /var/lib/apt/lists/*

# box64（x64 ELF 実行）
RUN git clone --depth=1 https://github.com/ptitSeb/box64 /tmp/box64 \
 && cmake -S /tmp/box64 -B /tmp/box64/build -G Ninja \
      -DARM_DYNAREC=ON -DDEFAULT_PAGESIZE=16384 -DCMAKE_BUILD_TYPE=RelWithDebInfo \
 && cmake --build /tmp/box64/build -j && cmake --install /tmp/box64/build \
 && rm -rf /tmp/box64

WORKDIR /usr/local/bin
COPY get_bds.sh update_addons.py entry-bds.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/*.sh

WORKDIR /data
EXPOSE 13922/udp 19132/udp
CMD ["/usr/local/bin/entry-bds.sh"]
DOCK

# ---- get_bds.sh --------------------------------------------------------------
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

# ---- update_addons.py（/data と /worlds/world に反映） ------------------------
cat > "${DOCKER_DIR}/bds/update_addons.py" <<'PY'
import os, json, re, shutil, sys
ROOT="/data"
BP=os.path.join(ROOT,"behavior_packs")
RP=os.path.join(ROOT,"resource_packs")
WBP=os.path.join(ROOT,"world_behavior_packs.json")
WRP=os.path.join(ROOT,"world_resource_packs.json")
WORLD=os.path.join(ROOT,"worlds","world")
WWBP=os.path.join(WORLD,"world_behavior_packs.json")
WWRP=os.path.join(WORLD,"world_resource_packs.json")

def _load_lenient(p):
  s=open(p,"r",encoding="utf-8").read()
  s=re.sub(r'//.*','',s); s=re.sub(r'/\*.*?\*/','',s,flags=re.S); s=re.sub(r',\s*([}\]])',r'\1',s)
  return json.loads(s)

def scan(d,tp):
  out=[]
  if not os.path.isdir(d): return out
  for name in sorted(os.listdir(d)):
    p=os.path.join(d,name); mf=os.path.join(p,"manifest.json")
    if not os.path.isdir(p) or not os.path.isfile(mf): continue
    try:
      m=_load_lenient(mf); uuid=m["header"]["uuid"]; ver=m["header"]["version"]
      if not(isinstance(ver,list) and len(ver)==3): raise ValueError("bad version")
      out.append({"pack_id":uuid,"version":ver,"type":tp})
      print(f"[addons] {name} {uuid} {ver}")
    except Exception as e: print(f"[addons] invalid manifest in {name}: {e}")
  return out

def write(p,items):
  os.makedirs(os.path.dirname(p), exist_ok=True)
  open(p,"w",encoding="utf-8").write(json.dumps(items,indent=2,ensure_ascii=False))
  print(f"[addons] wrote {p} ({len(items)} packs)")

if __name__=="__main__":
  b=scan(BP,"data"); r=scan(RP,"resources")
  write(WBP,b); write(WRP,r)
  # ワールド直下にも必ず反映（Pack Stack - None 回避）
  if os.path.isdir(WORLD):
    write(WWBP,b); write(WWRP,r)
  else:
    print("[addons] WARN: world dir not found, skip copy")
PY

# ---- entry-bds.sh ------------------------------------------------------------
cat > "${DOCKER_DIR}/bds/entry-bds.sh" <<'BASH'
#!/usr/bin/env bash
set -euo pipefail
export TZ="${TZ:-Asia/Tokyo}"
cd /data; mkdir -p /data

# server.properties（ログ出力/許可リストを有効）
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
allow-list=true
PROP
else
  sed -i "s/^server-port=.*/server-port=${BDS_PORT_V4:-13922}/" server.properties
  sed -i "s/^server-portv6=.*/server-portv6=${BDS_PORT_V6:-19132}/" server.properties
  sed -i "s/^content-log-file-enabled=.*/content-log-file-enabled=true/" server.properties
  sed -i "s/^content-log-file-name=.*/content-log-file-name=content.log/" server.properties
  sed -i "s/^allow-list=.*/allow-list=true/" server.properties
fi

[ -f allowlist.json ]   || echo "[]" > allowlist.json
[ -f permissions.json ] || echo "[]" > permissions.json
[ -f chat.json ]        || echo "[]" > chat.json
[ -d worlds/world/db ]  || mkdir -p worlds/world/db
echo "[]" > /data/players.json || true
touch bedrock_server.log bds_console.log

/usr/local/bin/get_bds.sh

# ---- チャット→/me 変換アドオン（安定APIのみ使用・β不要） --------------------
mkdir -p /data/behavior_packs/omf_mechat/scripts /data/behavior_packs/omf_mechat/texts
cat > /data/behavior_packs/omf_mechat/manifest.json <<'JSON'
{
  "format_version": 2,
  "header": {
    "name": "OMF MeChat",
    "description": "Convert normal chat to /me for logging",
    "uuid": "a1a1f2f2-1b1b-4c4c-9d9d-1010101010aa",
    "version": [1,0,0],
    "min_engine_version": [1,21,0]
  },
  "modules": [
    {
      "type": "script",
      "language": "javascript",
      "entry": "scripts/main.js",
      "uuid": "b2b2c3c3-2d2d-4e4e-9f9f-2020202020bb",
      "version": [1,0,0]
    }
  ],
  "dependencies": [
    { "module_name": "@minecraft/server", "version": "1.11.0" }
  ]
}
JSON

cat > /data/behavior_packs/omf_mechat/scripts/main.js <<'JS'
import { world, system } from "@minecraft/server";
// 通常チャットをキャンセルし、/me "<name>: <message>" に変換して発行。
// /me はOP不要で BDS のログに確実に出るため、logtail で回収できる。
function sanitize(s){ try{ return String(s??"").replace(/\s+/g," ").trim().slice(0,200);}catch{ return ""; } }
function runAsMe(player, text){
  const name = sanitize(player?.name ?? "Player");
  const body = sanitize(text);
  if(!body) return;
  system.run(()=>{ try { player.runCommandAsync(`me ${name}: ${body}`); } catch {} });
}
try{
  const be = world.beforeEvents;
  if (be && be.chatSend) {
    be.chatSend.subscribe(ev=>{
      const msg = String(ev.message||"");
      if (!msg.startsWith("/")) {  // コマンドは素通し
        runAsMe(ev.sender, msg);
        ev.cancel = true;
      }
    });
  } else {
    console.warn("[OMF-MECHAT] chat hook not available");
  }
}catch(e){ console.warn("[OMF-MECHAT] error: "+(e?.stack||e)); }
JS

# アドオン一覧を /data と /worlds/world に反映
python3 /usr/local/bin/update_addons.py || true

# 起動メッセージ（Web表示用）
python3 - <<'PY' || true
import json,os,datetime
f="chat.json"; d=[]
try:
  if os.path.exists(f): d=json.load(open(f))
except: d=[]
if not isinstance(d,list): d=[]
d.append({"player":"SYSTEM","message":"サーバーが起動しました","timestamp":datetime.datetime.now().isoformat()})
d=d[-200:]; json.dump(d,open(f,"w"),ensure_ascii=False)
PY

echo "[entry-bds] exec: box64 ./bedrock_server"
box64 ./bedrock_server 2>&1 | tee -a /data/bds_console.log
BASH
chmod +x "${DOCKER_DIR}/bds/"*.sh

# ---- logtail（ログ→ chat.json / players.json） -------------------------------
mkdir -p "${DOCKER_DIR}/logtail"
cat > "${DOCKER_DIR}/logtail/Dockerfile" <<'DOCK'
FROM python:3.11-slim
RUN apt-get update && apt-get install -y --no-install-recommends ca-certificates && rm -rf /var/lib/apt/lists/*
WORKDIR /app
COPY logtail.py /app/logtail.py
CMD ["python","/app/logtail.py"]
DOCK

cat > "${DOCKER_DIR}/logtail/logtail.py" <<'PY'
import os, re, json, time, datetime

DATA="/data"
CHAT=os.path.join(DATA,"chat.json")
PLAY=os.path.join(DATA,"players.json")
ALLOW=os.path.join(DATA,"allowlist.json")
LOG1=os.path.join(DATA,"bds_console.log")
LOG2=os.path.join(DATA,"bedrock_server.log")

ALLOW_ENROLL=os.getenv("ALLOWLIST_ENROLL","false").lower()=="true"

re_join = re.compile(r'INFO\] Player connected: ([^,]+),')
re_leave= re.compile(r'INFO\] Player disconnected: ([^,]+),')
# 例: "INFO] * Steve: hello"
re_me   = re.compile(r'INFO\]\s*\*\s(.+?)\s*:\s(.+)')

def jload(path, defv):
  try:
    with open(path,"r",encoding="utf-8") as f: return json.load(f)
  except: return defv

def jdump(path, obj):
  tmp=path+".tmp"
  with open(tmp,"w",encoding="utf-8") as f: json.dump(obj,f,ensure_ascii=False)
  os.replace(tmp,path)

def ensure_files():
  if not os.path.exists(CHAT): jdump(CHAT, [])
  if not os.path.exists(PLAY): jdump(PLAY, [])
  if not os.path.exists(ALLOW): jdump(ALLOW, [])

def add_chat(player, message, tag=None):
  d=jload(CHAT,[])
  m={"player":str(player), "message":str(message), "timestamp":datetime.datetime.now().isoformat()}
  if tag: m["tag"]=tag
  d.append(m); d=d[-200:]
  jdump(CHAT,d)

def add_player(name):
  s=set(jload(PLAY,[])); s.add(name); jdump(PLAY,sorted(s))
  if ALLOW_ENROLL:
    al=jload(ALLOW,[])
    if not any((isinstance(x,dict) and x.get("name")==name) for x in al):
      al.append({"ignoresPlayerLimit": False, "name": name})
      jdump(ALLOW, al)

def remove_player(name):
  s=set(jload(PLAY,[])); s.discard(name); jdump(PLAY,sorted(s))

def follow(paths):
  fps={p:None for p in paths}
  while True:
    for p in list(fps.keys()):
      try:
        if fps[p] is None:
          fps[p]=open(p,"r",encoding="utf-8",errors="ignore"); fps[p].seek(0, os.SEEK_END)
        pos=fps[p].tell()
        line=fps[p].readline()
        if not line:
          time.sleep(0.2); fps[p].seek(pos); continue
        yield line.rstrip("\r\n")
      except FileNotFoundError:
        time.sleep(0.5)
      except Exception:
        time.sleep(0.5)

def main():
  ensure_files()
  add_chat("SYSTEM","Log tail started","system")
  for line in follow([LOG1,LOG2]):
    try:
      if "Player connected:" in line:
        m=re_join.search(line)
        if m:
          name=m.group(1).strip()
          add_player(name)
          add_chat("SYSTEM", f"{name} が参加", "join")
          continue
      if "Player disconnected:" in line:
        m=re_leave.search(line)
        if m:
          name=m.group(1).strip()
          remove_player(name)
          add_chat("SYSTEM", f"{name} が退出", "leave")
          continue
      if "INFO] * " in line:
        m=re_me.search(line)
        if m:
          name=m.group(1).strip()
          msg =m.group(2).strip()
          add_chat(name, msg, "chat")
          continue
    except Exception:
      pass

if __name__=="__main__":
  main()
PY

# ---- monitor（/players, /chat） ----------------------------------------------
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
MAX_CHAT=200

app=FastAPI()

def read_json(p,defv):
  try:
    with open(p,"r",encoding="utf-8") as f: return json.load(f)
  except Exception: return defv

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
  return {"server":SERVER_NAME,"latest":j[-MAX_CHAT:],"count":len(j),
          "timestamp":datetime.datetime.now().isoformat()}

@app.post("/chat")
def post_chat(body: ChatIn, x_api_key: str = Header(None)):
  if x_api_key != API_TOKEN: raise HTTPException(status_code=403, detail="Forbidden")
  return {"status":"ng","reason":"not implemented"}  # 外部→ゲーム内送信は未対応

if __name__=="__main__":
  uvicorn.run(app, host="0.0.0.0", port=13900, log_level="info")
PY

# ---- web（既存UIの簡易版） ---------------------------------------------------
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
.chat-list{border:1px solid #ddd;border-radius:.5rem;height:60vh;overflow:auto;padding:.5rem;background:#fafafa;font-family:ui-monospace,Menlo,Consolas,monospace}
.chat-item{margin:.25rem 0;padding:.35rem .5rem;border-radius:.25rem;background:#fff;border:1px solid #eee;white-space:pre-wrap}
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
  setInterval(refreshPlayers,15000); setInterval(refreshChat,5000);
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
    (d.latest||[]).forEach(m=>{
      const el=document.createElement("div");
      el.className="chat-item";
      const ts=(m.timestamp||'').replace('T',' ').slice(0,19);
      el.textContent=`[${ts}] ${m.player}: ${m.message}`;
      list.appendChild(el);
    });
    list.scrollTop=list.scrollHeight;
  }catch(_){}
}
JS

# ---- map 出力先（初回） ------------------------------------------------------
mkdir -p "${DATA_DIR}/map"
if [[ ! -f "${DATA_DIR}/map/index.html" ]]; then
  echo '<!doctype html><meta charset="utf-8"><p>uNmINeD の Web 出力がここに作成されます。</p>' > "${DATA_DIR}/map/index.html"
fi

# ---- uNmINeD 自動DL & web render（ARM64 glibc） ------------------------------
cat > "${BASE}/update_map.sh" <<'BASH'
#!/usr/bin/env bash
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
need_cmd curl; need_cmd grep; need_cmd sed; need_cmd awk
command -v tar >/dev/null 2>&1 || true
command -v unzip >/dev/null 2>&1 || true
command -v file >/dev/null 2>&1 || true

pick_arm_url(){
  local page tmp url
  page="https://unmined.net/downloads/"
  tmp="$(mktemp -d)"
  log "scanning downloads page..."
  curl -fsSL "$page" > "$tmp/page.html"
  url="$(grep -Eo 'https://unmined\.net/download/unmined-cli-linux-arm64-dev/\?tmstv=[0-9]+' "$tmp/page.html" | head -n1 || true)"
  rm -rf "$tmp"
  [ -n "$url" ] || return 1
  echo "$url"
}

install_from_archive(){
  local url="$1" tmp ext ctype root
  tmp="$(mktemp -d)"
  log "downloading: ${url}"
  curl -fL --retry 3 --retry-delay 2 -D "$tmp/headers" -o "$tmp/pkg" "$url"
  if command -v file >/dev/null 2>&1; then
    if file "$tmp/pkg" | grep -qi 'Zip archive data'; then ext="zip"
    elif file "$tmp/pkg" | grep -qi 'gzip compressed data'; then ext="tgz"
    else
      ctype="$(awk 'BEGIN{IGNORECASE=1}/^Content-Type:/{print $2}' "$tmp/headers" | tr -d '\r' || true)"
      case "${ctype:-}" in
        application/zip) ext="zip" ;;
        application/gzip|application/x-gzip|application/x-tgz) ext="tgz" ;;
        *) ext="unknown" ;;
      esac
    fi
  else
    ctype="$(awk 'BEGIN{IGNORECASE=1}/^Content-Type:/{print $2}' "$tmp/headers" | tr -d '\r' || true)"
    case "${ctype:-}" in
      application/zip) ext="zip" ;;
      application/gzip|application/x-gzip|application/x-tgz) ext="tgz" ;;
      *) ext="unknown" ;;
    esac
  fi
  mkdir -p "$tmp/x"
  case "$ext" in
    tgz) tar xzf "$tmp/pkg" -C "$tmp/x" ;;
    zip) unzip -qo "$tmp/pkg" -d "$tmp/x" ;;
    *) log "ERROR: unsupported archive format"; rm -rf "$tmp"; return 1 ;;
  esac
  root="$(find "$tmp/x" -maxdepth 2 -type d -name 'unmined-cli*' | head -n1 || true)"
  [ -n "$root" ] || root="$tmp/x"
  if [ ! -f "$root/unmined-cli" ]; then
    root="$(dirname "$(find "$tmp/x" -type f -name 'unmined-cli' | head -n1 || true)")"
  fi
  [ -n "$root" ] && [ -f "$root/unmined-cli" ] || { log "ERROR: unmined-cli not found in archive"; rm -rf "$tmp"; return 1; }
  mkdir -p "${TOOLS}"
  rsync -a "$root"/ "${TOOLS}/" 2>/dev/null || cp -rf "$root"/ "${TOOLS}/"
  chmod +x "${BIN}"
  rm -rf "$tmp"
  if [ ! -f "${TPL_ZIP}" ]; then
    if [ -d "${TPL_DIR}" ] && [ -f "${TPL_DIR}/default.web.template.zip" ]; then :; else
      log "ERROR: templates/default.web.template.zip missing in package"; return 1
    fi
  fi
  return 0
}

render_map(){
  log "rendering web map from: ${WORLD}"
  mkdir -p "${OUT}"
  pushd "${TOOLS}" >/dev/null
  if [ ! -f "${CFG_DIR}/blocktags.js" ]; then
    mkdir -p "${CFG_DIR}"
    cat > "${CFG_DIR}/blocktags.js" <<'JS'
export default {};
JS
  fi
  "./unmined-cli" --version || true
  "./unmined-cli" web render --world "${WORLD}" --output "${OUT}" --chunkprocessors 4
  local rc=$?
  popd >/dev/null
  return $rc
}

main(){
  if [ ! -x "${BIN}" ] || [ ! -f "${TPL_ZIP}" ]; then
    url="$(pick_arm_url || true)"
    [ -n "${url:-}" ] || { log "ERROR: could not discover ARM64 (glibc) URL"; exit 1; }
    log "URL picked: ${url}"
    install_from_archive "$url"
  else
    log "uNmINeD CLI already installed"
  fi
  if render_map; then
    log "done -> ${OUT}"
  else
    log "ERROR: render failed"; exit 1
  fi
}
main "$@"
BASH
chmod +x "${BASE}/update_map.sh"

# ---- ビルド & 起動 -----------------------------------------------------------
echo "[BUILD] images..."
sudo docker compose -f "${DOCKER_DIR}/compose.yml" build --no-cache

echo "[PREFETCH] BDS payload ..."
sudo docker run --rm -e TZ=Asia/Tokyo --entrypoint /usr/local/bin/get_bds.sh -v "${DATA_DIR}:/data" local/bds-box64:latest

echo "[UP] compose up -d ..."
sudo docker compose -f "${DOCKER_DIR}/compose.yml" up -d

sleep 3
cat <<MSG

== 動作確認 ==
curl -s -S "http://${MONITOR_BIND}:${MONITOR_PORT}/health" | jq .
curl -s -S -H "x-api-key: ${API_TOKEN}" "http://${MONITOR_BIND}:${MONITOR_PORT}/players" | jq .
curl -s -S -H "x-api-key: ${API_TOKEN}" "http://${MONITOR_BIND}:${MONITOR_PORT}/chat"    | jq .

# 使い方:
# - クライアントで通常チャット → サーバーログに「* <名前>: <本文>」として出力（/me）
# - logtail が /me 行と入退室を拾い、/data/chat.json / /data/players.json を更新
# - allowlist 自動登録を止める場合は、compose の ALLOWLIST_ENROLL を "false" に

# マップ更新（必要時）
${BASE}/update_map.sh
MSG

