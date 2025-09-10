#!/usr/bin/env bash
# =====================================================================
# OMFS (install_script.sh) — RPi5 / RPi OS Lite
#  - LeviLamina 優先 / 旧 LLSE フォールバック（box64 実行）
#  - uNmINeD: ARM64 glibc/musl 自動DL + web render、templates & config 同梱
#  - 監視API & Web は現状維持
# =====================================================================
set -euo pipefail

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

BDS_PORT_V4="${BDS_PORT_V4:-13922}"
BDS_PORT_V6="${BDS_PORT_V6:-19132}"
MONITOR_BIND="${MONITOR_BIND:-127.0.0.1}"
MONITOR_PORT="${MONITOR_PORT:-13900}"
WEB_BIND="${WEB_BIND:-0.0.0.0}"
WEB_PORT="${WEB_PORT:-13901}"
BDS_URL="${BDS_URL:-}"             # 固定BDS URL（空=自動）
LLSE_URL="${LLSE_URL:-}"           # 旧LLSE直リンク（空=自動）
LLM_URL="${LLM_URL:-}"             # LeviLamina 直リンク（空=最新）
SCRIPTENG_URL="${SCRIPTENG_URL:-}" # ScriptEngine 直リンク（空=最新）
ALL_CLEAN="${ALL_CLEAN:-false}"
ENABLE_CHAT_LOGGER="${ENABLE_CHAT_LOGGER:-true}"

echo "[INFO] OMFS start user=${USER_NAME} base=${BASE} ALL_CLEAN=${ALL_CLEAN}"

# ------------------ 停止と掃除 ------------------
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
mkdir -p "${DOCKER_DIR}" "${DATA_DIR}" "${BKP_DIR}" "${WEB_SITE_DIR}" "${TOOLS_DIR}"
sudo chown -R "${USER_NAME}:${USER_NAME}" "${OBJ}" || true

# ------------------ ホスト依存 ------------------
echo "[SETUP] apt..."
sudo apt-get update -y
sudo apt-get install -y --no-install-recommends ca-certificates curl wget jq unzip git tzdata xz-utils

# ------------------ .env ------------------
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
LLSE_URL=${LLSE_URL}
LLM_URL=${LLM_URL}
SCRIPTENG_URL=${SCRIPTENG_URL}
ENABLE_CHAT_LOGGER=${ENABLE_CHAT_LOGGER}
ENV

# ------------------ compose ------------------
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
      LLSE_URL: \${LLSE_URL}
      LLM_URL: \${LLM_URL}
      SCRIPTENG_URL: \${SCRIPTENG_URL}
      ENABLE_CHAT_LOGGER: \${ENABLE_CHAT_LOGGER}
      BDS_PORT_V4: \${BDS_PORT_V4}
      BDS_PORT_V6: \${BDS_PORT_V6}
    volumes:
      - ../data:/data
    ports:
      - "\${BDS_PORT_V4}:\${BDS_PORT_V4}/udp"
      - "\${BDS_PORT_V6}:\${BDS_PORT_V6}/udp"
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

# ------------------ bds イメージ ------------------
mkdir -p "${DOCKER_DIR}/bds"

cat > "${DOCKER_DIR}/bds/Dockerfile" <<'DOCK'
FROM debian:bookworm-slim
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates curl wget unzip jq xz-utils procps build-essential git cmake ninja-build python3 \
 && rm -rf /var/lib/apt/lists/*

# box64（x64 ELF 実行用）
RUN git clone --depth=1 https://github.com/ptitSeb/box64 /tmp/box64 \
 && cmake -S /tmp/box64 -B /tmp/box64/build -G Ninja \
      -DARM_DYNAREC=ON -DDEFAULT_PAGESIZE=16384 -DCMAKE_BUILD_TYPE=RelWithDebInfo \
 && cmake --build /tmp/box64/build -j && cmake --install /tmp/box64/build \
 && rm -rf /tmp/box64

WORKDIR /usr/local/bin
COPY get_bds.sh install_layer.sh update_addons.py entry-bds.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/*.sh

WORKDIR /data
EXPOSE 13922/udp 19132/udp
CMD ["/usr/local/bin/entry-bds.sh"]
DOCK

# --- BDS ---
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

# --- LeviLamina / LLSE インストーラ（jq+awk で小文字マッチ） ---
cat > "${DOCKER_DIR}/bds/install_layer.sh" <<'BASH'
#!/usr/bin/env bash
set -euo pipefail
cd /data
[ "${ENABLE_CHAT_LOGGER:-true}" = "true" ] || { echo "[layer] disabled"; exit 0; }

have() { command -v "$1" >/dev/null 2>&1; }

gh_pick_asset(){
  # $1: repo (org/name), $2..: awk 条件（tolower($0) ~ /.../）
  local repo="$1"; shift
  local JSON; JSON="$(curl -fsSL -H 'Accept: application/vnd.github+json' "https://api.github.com/repos/${repo}/releases/latest" || true)"
  [ -n "$JSON" ] || return 1
  echo "$JSON" | jq -r '.assets[]?.browser_download_url' \
    | awk 'BEGIN{IGNORECASE=1} {print tolower($0)}' \
    | awk "$*" \
    | head -n1
}

install_levilamina() {
  local URL="${LLM_URL:-}"
  if [ -z "$URL" ]; then
    URL="$(gh_pick_asset 'LiteLDev/LeviLamina' ' /linux/ && /(x64|amd64)/ && /\.(zip|tar\.gz|tar\.xz)$/ ' || true)"
  fi
  if [ -z "$URL" ]; then
    URL="$(curl -fsSL https://github.com/LiteLDev/LeviLamina/releases/latest \
      | tr '"' '\n' | awk 'BEGIN{IGNORECASE=1}{print tolower($0)}' \
      | awk '/https:\/\/.*levilamina.*(linux).*(x64|amd64).*\.(zip|tar\.gz|tar\.xz)/{print; exit}' || true)"
  fi
  [ -n "$URL" ] || { echo "[levilamina] not found"; return 1; }

  echo "[levilamina] downloading: $URL"
  local tmp; tmp="$(mktemp -d)"
  if ! wget -q -L -O "$tmp/llm.pkg" "$URL"; then
    curl -fsSL -o "$tmp/llm.pkg" "$URL" || { rm -rf "$tmp"; return 1; }
  fi
  mkdir -p "$tmp/x"
  if echo "$URL" | grep -qiE '\.zip$'; then unzip -qo "$tmp/llm.pkg" -d "$tmp/x" || { rm -rf "$tmp"; return 1; }
  elif echo "$URL" | grep -qiE '\.tar\.gz$'; then tar xzf "$tmp/llm.pkg" -C "$tmp/x" || { rm -rf "$tmp"; return 1; }
  else tar xJf "$tmp/llm.pkg" -C "$tmp/x" || { rm -rf "$tmp"; return 1; }
  fi

  mkdir -p /data/plugins
  cp -rf "$tmp/x"/. /data/
  find /data -type f -name 'levilamina' -o -name 'll' -o -name 'bedrock_server_mod' | while read -r f; do chmod +x "$f" || true; done
  rm -rf "$tmp"
  echo "[levilamina] installed"
  return 0
}

install_llse_legacy() {
  local URL="${LLSE_URL:-}"
  if [ -z "$URL" ]; then
    URL="$(gh_pick_asset 'LiteLDev/LiteLoaderBDS' ' /linux/ && /(x64|amd64)/ && /\.(zip|tar\.gz|tar\.xz)$/ ' || true)"
  fi
  [ -n "$URL" ] || { echo "[llse] not found"; return 1; }
  echo "[llse] downloading: $URL"
  local tmp; tmp="$(mktemp -d)"
  if ! wget -q -L -O "$tmp/llse.pkg" "$URL"; then
    curl -fsSL -o "$tmp/llse.pkg" "$URL" || { rm -rf "$tmp"; return 1; }
  fi
  mkdir -p "$tmp/u"
  if echo "$URL" | grep -qiE '\.zip$'; then unzip -qo "$tmp/llse.pkg" -d "$tmp/u" || { rm -rf "$tmp"; return 1; }
  elif echo "$URL" | grep -qiE '\.tar\.gz$'; then tar xzf "$tmp/llse.pkg" -C "$tmp/u" || { rm -rf "$tmp"; return 1; }
  else tar xJf "$tmp/llse.pkg" -C "$tmp/u" || { rm -rf "$tmp"; return 1; }
  fi
  mkdir -p /data/plugins
  cp -rf "$tmp/u"/. /data/
  find /data -type f -name 'll' -o -name 'bedrock_server_mod' | while read -r f; do chmod +x "$f" || true; done
  rm -rf "$tmp"
  echo "[llse] installed"
  return 0
}

install_script_engine() {
  local URL="${SCRIPTENG_URL:-}"
  if [ -z "$URL" ]; then
    URL="$(gh_pick_asset 'LiteLDev/LeviLaminaScriptEngine' ' /(linux|unix)/ && /(x64|amd64)/ && /\.(zip|tar\.gz|tar\.xz)$/ ' || true)"
  fi
  [ -n "$URL" ] || { echo "[scripteng] not found (optional)"; return 1; }
  echo "[scripteng] downloading: $URL"
  local tmp; tmp="$(mktemp -d)"
  if ! wget -q -L -O "$tmp/lseng.pkg" "$URL"; then
    curl -fsSL -o "$tmp/lseng.pkg" "$URL" || { rm -rf "$tmp"; return 1; }
  fi
  mkdir -p "$tmp/x"
  if echo "$URL" | grep -qiE '\.zip$'; then unzip -qo "$tmp/lseng.pkg" -d "$tmp/x" || { rm -rf "$tmp"; return 1; }
  elif echo "$URL" | grep -qiE '\.tar\.gz$'; then tar xzf "$tmp/lseng.pkg" -C "$tmp/x" || { rm -rf "$tmp"; return 1; }
  else tar xJf "$tmp/lseng.pkg" -C "$tmp/x" || { rm -rf "$tmp"; return 1; }
  fi
  mkdir -p /data/plugins
  cp -rf "$tmp/x"/. /data/
  rm -rf "$tmp"
  echo "[scripteng] installed (if layout matched)"
}

install_js_logger() {
  [ "${ENABLE_CHAT_LOGGER:-true}" = "true" ] || return 0
  mkdir -p /data/plugins/omfs-chat-logger
  cat > /data/plugins/omfs-chat-logger/entry.js <<'JS'
let fs = require('fs');
const DATA='/data';
const CHAT=DATA+'/chat.json';
const LOG =DATA+'/omfs_chat.log';
const PLAY=DATA+'/players.json';
function safe(path,defv){ try{ if(!fs.existsSync(path)) return defv; return JSON.parse(fs.readFileSync(path,'utf8')); }catch(e){ return defv; } }
function savePlayers(){ try{ let names = mc.getOnlinePlayers().map(p=>p.realName).sort(); fs.writeFileSync(PLAY,JSON.stringify(names,null,2)); }catch(e){} }
function pushChat(p,m){ let j=safe(CHAT,[]); j.push({player:p,message:String(m),timestamp:new Date().toISOString()}); if(j.length>50) j=j.slice(-50); fs.writeFileSync(CHAT,JSON.stringify(j,null,2)); try{ fs.appendFileSync(LOG,`[${new Date().toISOString()}] ${p}: ${m}\n`);}catch(e){} }
if(!fs.existsSync(CHAT)) fs.writeFileSync(CHAT,'[]'); if(!fs.existsSync(PLAY)) fs.writeFileSync(PLAY,'[]');
mc.listen('onJoin',(pl)=>{ savePlayers(); });
mc.listen('onLeft',(pl)=>{ savePlayers(); });
mc.listen('onChat',(pl,msg)=>{ pushChat(pl.realName,msg); });
logger.info('[OMFS] chat logger loaded');
JS
  echo "[logger] JS logger installed"
}

mkdir -p /data/plugins
if install_levilamina; then
  install_script_engine || true
  install_js_logger
  exit 0
fi
echo "[levilamina] failed; try legacy LLSE..."
if install_llse_legacy; then
  install_js_logger
  exit 0
fi
echo "[layer] no mod layer installed (chat logging unavailable)"
exit 0
BASH

# --- アドオン JSON 更新 ---
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
if __name__=="__main__": write(WBP,scan(BP,"data")); write(WRP,scan(RP,"resources"))
PY

# --- エントリ ---
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
fi
[ -f allowlist.json ] || echo "[]" > allowlist.json
[ -f chat.json ] || echo "[]" > chat.json
[ -d worlds/world/db ] || mkdir -p worlds/world/db
echo "[]" > /data/players.json || true
touch bedrock_server.log bds_console.log
rm -f in.pipe; mkfifo in.pipe

/usr/local/bin/get_bds.sh
/usr/local/bin/install_layer.sh || echo "[entry-bds] WARN: mod layer install failed"
python3 /usr/local/bin/update_addons.py || true

python3 - <<'PY' || true
import json,os,datetime
f="chat.json"; d=[]
try:
  if os.path.exists(f):
    d=json.load(open(f))
except: d=[]
if not isinstance(d,list): d=[]
d.append({"player":"SYSTEM","message":"サーバーが起動しました","timestamp":datetime.datetime.now().isoformat()})
d=d[-50:]; json.dump(d,open(f,"w"),ensure_ascii=False)
PY

LAUNCH=""
if   [ -x ./levilamina ];        then LAUNCH="box64 ./levilamina && echo [entry-bds] launched: levilamina"
elif [ -x ./ll ];                then LAUNCH="box64 ./ll && echo [entry-bds] launched: ll"
elif [ -x ./bedrock_server_mod ];then LAUNCH="box64 ./bedrock_server_mod && echo [entry-bds] launched: bedrock_server_mod"
else                                  LAUNCH="box64 ./bedrock_server && echo [entry-bds] launched: bedrock_server"
fi
echo "[entry-bds] exec: $LAUNCH (stdin: /data/in.pipe)"
( tail -F /data/in.pipe | eval "$LAUNCH" 2>&1 | tee -a /data/bds_console.log ) | tee -a /data/bedrock_server.log
BASH
chmod +x "${DOCKER_DIR}/bds/"*.sh

# ------------------ monitor ------------------
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
LLSE_LOG=os.path.join(DATA,"omfs_chat.log")
CONTENT_LOG=os.path.join(DATA,"content.log")
MAX_CHAT=50

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
  llse_ok = os.path.exists(LLSE_LOG) and os.path.getsize(LLSE_LOG)>0
  content_ok = os.path.exists(CONTENT_LOG) and os.path.getsize(CONTENT_LOG)>0
  j=read_json(CHAT_FILE,[])
  return {"server":SERVER_NAME,"latest":j[-MAX_CHAT:],"count":len(j),
          "content_log_active": bool(content_ok),
          "llse_active": bool(llse_ok or os.path.isdir(os.path.join(DATA,"LiteLoader")) or os.path.exists(os.path.join(DATA,"levilamina")) or os.path.exists(os.path.join(DATA,"ll"))),
          "timestamp":datetime.datetime.now().isoformat()}

@app.post("/chat")
def post_chat(body: ChatIn, x_api_key: str = Header(None)):
  if x_api_key != API_TOKEN: raise HTTPException(status_code=403, detail="Forbidden")
  msg=body.message.strip()
  if not msg: raise HTTPException(status_code=400, detail="Empty")
  try:
    with open(os.path.join(DATA,"in.pipe"),"w",encoding="utf-8") as f: f.write("say "+msg+"\n")
  except Exception: pass
  j=read_json(CHAT_FILE,[]); j.append({"player":"API","message":msg,"timestamp":datetime.datetime.now().isoformat()}); j=j[-MAX_CHAT:]
  try:
    with open(CHAT_FILE,"w",encoding="utf-8") as f: json.dump(j,f,ensure_ascii=False)
  except Exception: pass
  return {"status":"ok"}

if __name__=="__main__":
  uvicorn.run(app, host="0.0.0.0", port=13900, log_level="info")
PY

# ------------------ web ------------------
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
<section id="map" class="panel"><div class="map-header">uNmINeD Web</div><div class="map-frame"><iframe id="map-iframe" src="/map/index.html"></iframe></div></section>
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

# map 出力先プレースホルダ
mkdir -p "${DATA_DIR}/map"
if [[ ! -f "${DATA_DIR}/map/index.html" ]]; then
  echo '<!doctype html><meta charset="utf-8"><p>uNmINeD の Web 出力がここに作成されます。</p>' > "${DATA_DIR}/map/index.html"
fi

# ------------------ uNmINeD 自動DL & web render（templates 同梱） ------------------
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
mkdir -p "${TOOLS}" "${OUT}" "${CFG_DIR}"

# 必要最低限の blocktags.js（空で良い）
if [[ ! -f "${CFG_DIR}/blocktags.js" ]]; then
  cat > "${CFG_DIR}/blocktags.js" <<'JS'
// minimal placeholder for uNmINeD web render
export default {};
JS
fi

arch="$(uname -m)"
libc="glibc"; (ldd --version 2>&1 | grep -qi musl) && libc="musl"

pick_url(){ 
  if [ "$arch" = "aarch64" ] || [ "$arch" = "arm64" ]; then
    if [ "$libc" = "musl" ]; then echo "https://unmined.net/download/unmined-cli-linux-musl-arm64-dev/"; else echo "https://unmined.net/download/unmined-cli-linux-arm64-dev/"; fi
  else
    echo "unsupported"
  fi
}

fetch_pkg(){
  local page="$1" tmp; tmp="$(mktemp -d)"
  echo "[update_map] fetching: $page"
  if ! wget -q --content-disposition -L -P "$tmp" "$page"; then rm -rf "$tmp"; return 1; fi
  local f; f="$(ls -1 "$tmp" | head -n1 || true)"; [ -n "$f" ] || { rm -rf "$tmp"; return 1; }
  f="$tmp/$f"; mkdir -p "$tmp/x"
  if echo "$f" | grep -qiE '\.zip$'; then unzip -qo "$f" -d "$tmp/x" || { rm -rf "$tmp"; return 1; }
  else tar xf "$f" -C "$tmp/x" || { rm -rf "$tmp"; return 1; }
  fi
  # パッケージ全体を TOOLS にコピー（templates 等を保持）
  rm -rf "${TOOLS:?}/"* || true
  cp -rf "$tmp/x"/. "${TOOLS}/"
  # 代表バイナリ検出
  local found; found="$(find "${TOOLS}" -maxdepth 2 -type f -iname 'unmined-cli*' | head -n1 || true)"
  [ -n "$found" ] || { rm -rf "$tmp"; return 1; }
  mv -f "$found" "${BIN}"
  chmod +x "${BIN}"
  rm -rf "$tmp"
  return 0
}

URL="$(pick_url)"
if [ "$URL" = "unsupported" ]; then echo "[update_map] unsupported arch $(uname -m)"; exit 0; fi

if [[ ! -x "$BIN" ]] || [[ ! -d "$TPL_DIR" ]]; then
  echo "[update_map] downloading uNmINeD CLI (arch=$(uname -m) libc=$libc)"
  fetch_pkg "$URL" || true
  if [[ ! -x "$BIN" ]] || [[ ! -d "$TPL_DIR" ]]; then
    if echo "$URL" | grep -q musl; then fetch_pkg "https://unmined.net/download/unmined-cli-linux-arm64-dev/" || true
    else fetch_pkg "https://unmined.net/download/unmined-cli-linux-musl-arm64-dev/" || true
    fi
  fi
fi
if [[ ! -x "$BIN" ]] || [[ ! -d "$TPL_DIR" ]]; then
  echo "[update_map] 自動DLに失敗。手動で ${TOOLS} に一式配置してください（templates/ を含む）"
  exit 0
fi

echo "[update_map] rendering web map from: ${WORLD}"
pushd "${TOOLS}" >/dev/null
"./unmined-cli" web render --world "${WORLD}" --output "${OUT}" --chunkprocessors 4 || true
popd >/dev/null
echo "[update_map] done -> ${OUT}"
BASH
chmod +x "${BASE}/update_map.sh"

# ------------------ ビルド & 起動 ------------------
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
# Web: http://${WEB_BIND}:${WEB_PORT} → [マップ] タブ
MSG

