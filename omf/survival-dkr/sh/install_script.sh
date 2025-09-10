#!/usr/bin/env bash
# =====================================================================
# OMFS (install_script.sh) — LLSE経由起動/チャット・死亡ログ確実化 + uNmINeD自動DL
# Raspberry Pi 5 / Raspberry Pi OS Lite
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
KEY_FILE="${BASE}/key/key.conf"

mkdir -p "${DOCKER_DIR}" "${DATA_DIR}" "${BKP_DIR}" "${WEB_SITE_DIR}"
sudo chown -R "${USER_NAME}:${USER_NAME}" "${BASE}" || true

[[ -f "${KEY_FILE}" ]] || { echo "[ERR] key.conf が見つかりません: ${KEY_FILE}"; exit 1; }
# shellcheck disable=SC1090
source "${KEY_FILE}"

# ======== 必須 ========
: "${SERVER_NAME:?SERVER_NAME を key.conf に設定してください}"
: "${API_TOKEN:?API_TOKEN を key.conf に設定してください}"
: "${GAS_URL:?GAS_URL を key.conf に設定してください}"

# ======== 任意/既定 ========
BDS_PORT_V4="${BDS_PORT_V4:-13922}"
BDS_PORT_V6="${BDS_PORT_V6:-19132}"
MONITOR_BIND="${MONITOR_BIND:-127.0.0.1}"
MONITOR_PORT="${MONITOR_PORT:-13900}"
WEB_BIND="${WEB_BIND:-0.0.0.0}"
WEB_PORT="${WEB_PORT:-13901}"
BDS_URL="${BDS_URL:-}"              # 固定BDS URL（空ならAPIで自動）
LLSE_URL="${LLSE_URL:-}"            # LiteLoaderBDS 固定URL（空ならAPIで自動）
ALL_CLEAN="${ALL_CLEAN:-false}"     # true で worlds 等も含め完全初期化
ENABLE_CHAT_LOGGER="${ENABLE_CHAT_LOGGER:-true}"

echo "[INFO] OMFS start  user=${USER_NAME} base=${BASE} obj=${OBJ} all_clean=${ALL_CLEAN}"

# ---------------------------------------------------------------------
# 0) セーフクリーン
# ---------------------------------------------------------------------
echo "[CLEAN] stopping old stack (if any) ..."
if [[ -f "${DOCKER_DIR}/compose.yml" ]]; then
  sudo docker compose -f "${DOCKER_DIR}/compose.yml" down --remove-orphans || true
fi
for c in bds bds-monitor bds-web; do sudo docker rm -f "$c" >/dev/null 2>&1 || true; done

if [[ "${ALL_CLEAN}" == "true" ]]; then
  echo "[CLEAN] docker system prune -a -f"
  sudo docker system prune -a -f || true
else
  echo "[CLEAN] docker system prune -f"
  sudo docker system prune -f || true
fi

if [[ "${ALL_CLEAN}" == "true" ]]; then
  echo "[CLEAN] removing OBJ completely: ${OBJ}"
  rm -rf "${OBJ}"
fi
mkdir -p "${DOCKER_DIR}" "${DATA_DIR}" "${BKP_DIR}" "${WEB_SITE_DIR}"
sudo chown -R "${USER_NAME}:${USER_NAME}" "${OBJ}" || true

# ---------------------------------------------------------------------
# 1) ホスト最低限
# ---------------------------------------------------------------------
echo "[SETUP] apt packages (host-side) ..."
sudo apt-get update -y
sudo apt-get install -y --no-install-recommends ca-certificates curl wget jq unzip git tzdata

# ---------------------------------------------------------------------
# 2) .env
# ---------------------------------------------------------------------
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
ENABLE_CHAT_LOGGER=${ENABLE_CHAT_LOGGER}
ENV

# ---------------------------------------------------------------------
# 3) docker compose
# ---------------------------------------------------------------------
cat > "${DOCKER_DIR}/compose.yml" <<YAML
services:
  bds:
    build:
      context: ./bds
    image: local/bds-box64:latest
    container_name: bds
    env_file: .env
    environment:
      - TZ=\${TZ}
      - SERVER_NAME=\${SERVER_NAME}
      - GAS_URL=\${GAS_URL}
      - API_TOKEN=\${API_TOKEN}
      - BDS_URL=\${BDS_URL}
      - LLSE_URL=\${LLSE_URL}
      - ENABLE_CHAT_LOGGER=\${ENABLE_CHAT_LOGGER}
      - BDS_PORT_V4=\${BDS_PORT_V4}
      - BDS_PORT_V6=\${BDS_PORT_V6}
    volumes:
      - ../data:/data
    ports:
      - "\${BDS_PORT_V4}:\${BDS_PORT_V4}/udp"
      - "\${BDS_PORT_V6}:\${BDS_PORT_V6}/udp"
    restart: unless-stopped

  monitor:
    build:
      context: ./monitor
    image: local/bds-monitor:latest
    container_name: bds-monitor
    env_file: .env
    environment:
      - TZ=\${TZ}
      - SERVER_NAME=\${SERVER_NAME}
      - GAS_URL=\${GAS_URL}
      - API_TOKEN=\${API_TOKEN}
    volumes:
      - ../data:/data
    ports:
      - "${MONITOR_BIND}:${MONITOR_PORT}:13900/tcp"
    depends_on:
      - bds
    restart: unless-stopped

  web:
    build:
      context: ./web
    image: local/bds-web:latest
    container_name: bds-web
    env_file: .env
    environment:
      - TZ=\${TZ}
      - MONITOR_INTERNAL=http://bds-monitor:13900
    volumes:
      - ./web/nginx.conf:/etc/nginx/conf.d/default.conf:ro
      - ./web/site:/usr/share/nginx/html:ro
      - ../data/map:/data-map:ro
    ports:
      - "${WEB_BIND}:${WEB_PORT}:80"
    depends_on:
      - monitor
    restart: unless-stopped
YAML

# ---------------------------------------------------------------------
# 4) bds/ イメージ（LLSE 自動導入 + ランチャー経由起動）
# ---------------------------------------------------------------------
mkdir -p "${DOCKER_DIR}/bds"

cat > "${DOCKER_DIR}/bds/Dockerfile" <<'DOCK'
FROM debian:bookworm-slim
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates curl wget unzip jq xz-utils \
    build-essential git cmake python3 ninja-build \
 && rm -rf /var/lib/apt/lists/*

# box64 (x64 BDS 実行)
RUN git clone --depth=1 https://github.com/ptitSeb/box64 /tmp/box64 \
 && cmake -S /tmp/box64 -B /tmp/box64/build -G Ninja \
      -DARM_DYNAREC=ON -DDEFAULT_PAGESIZE=16384 -DCMAKE_BUILD_TYPE=RelWithDebInfo \
 && cmake --build /tmp/box64/build -j \
 && cmake --install /tmp/box64/build \
 && rm -rf /tmp/box64

WORKDIR /usr/local/bin
COPY get_bds.sh /usr/local/bin/get_bds.sh
COPY install_llse.sh /usr/local/bin/install_llse.sh
COPY update_addons.py /usr/local/bin/update_addons.py
COPY entry-bds.sh /usr/local/bin/entry-bds.sh
RUN chmod +x /usr/local/bin/*.sh

WORKDIR /data
EXPOSE 13922/udp 19132/udp
CMD ["/usr/local/bin/entry-bds.sh"]
DOCK

# BDS 取得
cat > "${DOCKER_DIR}/bds/get_bds.sh" <<'BASH'
#!/usr/bin/env bash
set -euo pipefail
mkdir -p /data
cd /data
log(){ echo "[get_bds] $*"; }

API="https://net-secondary.web.minecraft-services.net/api/v1.0/download/links"
get_url_api(){
  curl --http1.1 -fsSL --retry 3 --retry-delay 2 "$API" \
  | jq -r '.result.links[] | select(.downloadType=="serverBedrockLinux") | .downloadUrl' \
  | head -n1
}

URL="$(get_url_api || true)"
if [ -z "${URL}" ] && [ -n "${BDS_URL:-}" ]; then URL="${BDS_URL}"; fi
[ -n "${URL}" ] || { log "ERROR: could not obtain BDS url"; exit 10; }

log "downloading: ${URL}"
if ! wget -q -O bedrock-server.zip "${URL}"; then
  curl --http1.1 -fL -o bedrock-server.zip "${URL}"
fi

unzip -qo bedrock-server.zip -x server.properties allowlist.json
rm -f bedrock-server.zip
log "updated BDS payload"
BASH

# LLSE 取得（GitHub API で最新版の linux x64 アセットを解決）
cat > "${DOCKER_DIR}/bds/install_llse.sh" <<'BASH'
#!/usr/bin/env bash
set -euo pipefail
cd /data
[ "${ENABLE_CHAT_LOGGER:-true}" = "true" ] || { echo "[llse] disabled by env"; exit 0; }

if [ -x "/data/ll" ] || [ -x "/data/bedrock_server_mod" ] || [ -d "/data/LiteLoader" ]; then
  echo "[llse] already present"; exit 0;
fi

get_llse_url() {
  if [ -n "${LLSE_URL:-}" ]; then echo "${LLSE_URL}"; return 0; fi
  # GitHub API から最新版 release assets を走査し、linux & x64 & zip を優先
  curl -fsSL https://api.github.com/repos/LiteLDev/LiteLoaderBDS/releases/latest \
  | jq -r '.assets[]?.browser_download_url' \
  | grep -iE 'linux.*(x64|amd64).*\.zip$' \
  | head -n1
}

URL="$(get_llse_url || true)"
[ -n "$URL" ] || { echo "[llse] could not determine download URL"; exit 1; }

echo "[llse] downloading: $URL"
TMP="$(mktemp -d)"
if ! curl -fsSL -o "${TMP}/llse.zip" "$URL"; then
  echo "[llse] download failed"; rm -rf "$TMP"; exit 1
fi

if ! unzip -qo "${TMP}/llse.zip" -d "${TMP}/u"; then
  echo "[llse] unzip failed"; rm -rf "$TMP"; exit 1
fi

# 代表的なランチャー： ll または bedrock_server_mod
# 配置先は /data 直下
if [ -f "${TMP}/u/ll" ]; then
  cp -f "${TMP}/u/ll" /data/ll
  chmod +x /data/ll
fi
if [ -f "${TMP}/u/bedrock_server_mod" ]; then
  cp -f "${TMP}/u/bedrock_server_mod" /data/bedrock_server_mod
  chmod +x /data/bedrock_server_mod
fi
# LiteLoader ディレクトリや plugins 同梱があればコピー
[ -d "${TMP}/u/LiteLoader" ] && cp -r "${TMP}/u/LiteLoader" /data/
[ -d "${TMP}/u/plugins" ] && cp -r "${TMP}/u/plugins" /data/

rm -rf "$TMP"

if [ ! -x "/data/ll" ] && [ ! -x "/data/bedrock_server_mod" ] && [ ! -d "/data/LiteLoader" ]; then
  echo "[llse] install failed (no launcher found)"; exit 1
fi

# OMFS プラグイン設置（チャット/死亡/入退室）
mkdir -p /data/plugins/omfs-chat-logger
cat > /data/plugins/omfs-chat-logger/entry.js <<'JS'
// LiteLoaderBDS plugin: OMFS chat/death/player logger
let fs = require('fs');
const DATA   = '/data';
const CHATJS = DATA + '/chat.json';
const CHATLOG= DATA + '/omfs_chat.log';
const PLAYJS = DATA + '/players.json';

function safeReadJSON(path, defv){
  try { if (!fs.existsSync(path)) return defv;
        let j = JSON.parse(fs.readFileSync(path, {encoding:'utf8'}));
        if (Array.isArray(defv) && !Array.isArray(j)) return defv;
        return j;
  } catch(e){ return defv; }
}
function appendChat(entry){
  let chat = safeReadJSON(CHATJS, []);
  chat.push(entry); if (chat.length>50) chat = chat.slice(-50);
  fs.writeFileSync(CHATJS, JSON.stringify(chat, null, 2));
  try { fs.appendFileSync(CHATLOG, `[${entry.timestamp}] ${entry.player}: ${entry.message}\n`); } catch(e){}
}
function writePlayers(){
  try {
    let list = Array.from(mc.getOnlinePlayers()).map(p=>p.realName);
    fs.writeFileSync(PLAYJS, JSON.stringify(list.sort(), null, 2));
  } catch(e){}
}

// 初期化：ファイルを必ず用意し、ロード行を1行書く（llse_active判定用）
if (!fs.existsSync(CHATJS)) fs.writeFileSync(CHATJS, '[]');
if (!fs.existsSync(PLAYJS)) fs.writeFileSync(PLAYJS, '[]');
try { fs.appendFileSync(CHATLOG, `[${new Date().toISOString()}] SYSTEM: OMFS logger loaded\n`); } catch(e){}

mc.listen('onJoin', (pl)=>{ writePlayers(); });
mc.listen('onLeft', (pl)=>{ writePlayers(); });
mc.listen('onChat', (pl, msg)=>{
  let entry = {player: pl.realName, message: String(msg), timestamp: new Date().toISOString()};
  appendChat(entry);
  return false;
});
mc.listen('onPlayerDie', (player, source, cause, damage)=>{
  let who = player ? player.realName : 'unknown';
  let causeText = (cause!==undefined && cause!==null) ? String(cause) : 'death';
  let entry = {player: 'DEATH', message: `${who} が死亡 (${causeText})`, timestamp: new Date().toISOString()};
  appendChat(entry);
});
logger.info('[OMFS] chat/death logger loaded');
JS

echo "[llse] installed with OMFS plugin"
BASH

# アドオン反映
cat > "${DOCKER_DIR}/bds/update_addons.py" <<'PY'
import os, json, re
ROOT="/data"
BP=os.path.join(ROOT,"behavior_packs")
RP=os.path.join(ROOT,"resource_packs")
WBP=os.path.join(ROOT,"world_behavior_packs.json")
WRP=os.path.join(ROOT,"world_resource_packs.json")

def _load_lenient(p):
    s=open(p,"r",encoding="utf-8").read()
    s=re.sub(r'//.*','',s)
    s=re.sub(r'/\*.*?\*/','',s,flags=re.S)
    s=re.sub(r',\s*([}\]])',r'\1',s)
    return json.loads(s)

def scan(d, tp):
    out=[]
    if not os.path.isdir(d): return out
    for name in sorted(os.listdir(d)):
        p=os.path.join(d,name); mf=os.path.join(p,"manifest.json")
        if not os.path.isdir(p) or not os.path.isfile(mf): continue
        try:
            m=_load_lenient(mf)
            uuid=m["header"]["uuid"]; ver=m["header"]["version"]
            if not (isinstance(ver,list) and len(ver)==3): raise ValueError("version must be [x,y,z]")
            out.append({"pack_id":uuid,"version":ver,"type":tp})
            print(f"[addons] {name} {uuid} {ver}")
        except Exception as e:
            print(f"[addons] invalid manifest in {name}: {e}")
    return out

def write(p, items):
    with open(p,"w",encoding="utf-8") as f:
        json.dump(items,f,indent=2,ensure_ascii=False)
    print(f"[addons] wrote {p} ({len(items)} packs)")

if __name__=="__main__":
    write(WBP, scan(BP,"data"))
    write(WRP, scan(RP,"resources"))
PY

# エントリ（LLSE ランチャー自動検出で起動）
cat > "${DOCKER_DIR}/bds/entry-bds.sh" <<'BASH'
#!/usr/bin/env bash
set -euo pipefail
export TZ="${TZ:-Asia/Tokyo}"

mkdir -p /data
cd /data

# 初回 server.properties
if [ ! -f server.properties ]; then
  ports_v4="${BDS_PORT_V4:-13922}"
  ports_v6="${BDS_PORT_V6:-19132}"
  cat > server.properties <<PROP
server-name=${SERVER_NAME:-OMF}
gamemode=survival
difficulty=normal
allow-cheats=false
max-players=5
online-mode=true
server-port=${ports_v4}
server-portv6=${ports_v6}
view-distance=32
tick-distance=4
player-idle-timeout=30
max-threads=4
level-name=world
level-seed=
default-player-permission-level=member
texturepack-required=false
server-authoritative-movement=server-auth
enable-lan-visibility=true
enable-clone=false
allow-list=false
# 補助のcontent.log（LLSEが主）
content-log-file-enabled=true
content-log-file-name=content.log
PROP
fi

# 補助ファイル
[ -f allowlist.json ] || echo "[]" > allowlist.json
[ -f chat.json ]     || echo "[]" > chat.json
[ -d worlds/world/db ] || mkdir -p worlds/world/db
echo "[]" > /data/players.json || true

# ログ・FIFO
touch bedrock_server.log bds_console.log
[ -p in.pipe ] && rm -f in.pipe || true
mkfifo in.pipe

# BDS・LLSE
/usr/local/bin/get_bds.sh
if ! /usr/local/bin/install_llse.sh; then
  echo "[entry-bds] WARN: LLSE install failed. Continue without LLSE."
fi

# アドオン
python3 /usr/local/bin/update_addons.py || true

# 起動メッセージ(参考)
python3 - <<'PY' || true
import json, os, datetime
f="chat.json"
try:
    data=json.load(open(f)) if os.path.exists(f) else []
    if not isinstance(data, list): data=[]
except Exception:
    data=[]
data.append({"player":"SYSTEM","message":"サーバーが起動しました","timestamp":datetime.datetime.now().isoformat()})
data=data[-50:]
json.dump(data, open(f,"w"), ensure_ascii=False)
PY

echo "[entry-bds] launching (stdin: /data/in.pipe)"
LAUNCH=""
if [ -x ./ll ]; then
  LAUNCH="box64 ./ll"
elif [ -x ./bedrock_server_mod ]; then
  LAUNCH="box64 ./bedrock_server_mod"
else
  LAUNCH="box64 ./bedrock_server"
fi
echo "[entry-bds] exec: $LAUNCH"
( tail -F /data/in.pipe | eval "$LAUNCH" 2>&1 | tee -a /data/bds_console.log ) | tee -a /data/bedrock_server.log
BASH
chmod +x "${DOCKER_DIR}/bds/"*.sh

# ---------------------------------------------------------------------
# 5) monitor/（LLSEログ優先）
# ---------------------------------------------------------------------
mkdir -p "${DOCKER_DIR}/monitor"
cat > "${DOCKER_DIR}/monitor/Dockerfile" <<'DOCK'
FROM python:3.11-slim
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates curl jq procps \
 && rm -rf /var/lib/apt/lists/*
WORKDIR /app
RUN pip install --no-cache-dir fastapi uvicorn requests pydantic
COPY monitor_players.py /app/monitor_players.py
EXPOSE 13900/tcp
CMD ["python","/app/monitor_players.py"]
DOCK

cat > "${DOCKER_DIR}/monitor/monitor_players.py" <<'PY'
import os, json, datetime, threading
from fastapi import FastAPI, Header, HTTPException
from pydantic import BaseModel
import uvicorn, requests, time

DATA="/data"
CFG_GAS=os.getenv("GAS_URL","")
API_TOKEN=os.getenv("API_TOKEN","")
SERVER_NAME=os.getenv("SERVER_NAME","OMF")

PLAYERS_FILE=os.path.join(DATA,"players.json")
CHAT_FILE=os.path.join(DATA,"chat.json")
LLSE_LOG=os.path.join(DATA,"omfs_chat.log")
CONTENT_LOG=os.path.join(DATA,"content.log")

MAX_CHAT=50
players_notified_date=None

def read_json(path,defv):
    try:
        with open(path,"r",encoding="utf-8") as f: return json.load(f)
    except Exception: return defv

def gas_first_login(first_player):
    global players_notified_date
    if not CFG_GAS: return
    today=datetime.date.today().isoformat()
    if players_notified_date==today: return
    payload={"event":"first_login_of_day","server":SERVER_NAME,
             "player":first_player,"timestamp":datetime.datetime.now().isoformat()}
    try: requests.post(CFG_GAS,json=payload,timeout=5)
    except Exception: pass
    players_notified_date=today

app=FastAPI()
class ChatIn(BaseModel): message:str

@app.get("/players")
def get_players(x_api_key: str = Header(None)):
    if x_api_key != API_TOKEN: raise HTTPException(status_code=403, detail="Forbidden")
    current=read_json(PLAYERS_FILE,[])
    if isinstance(current,list) and current:
        gas_first_login(current[0])
    return {"server":SERVER_NAME,"players":current,"timestamp":datetime.datetime.now().isoformat()}

@app.get("/chat")
def get_chat(x_api_key: str = Header(None)):
    if x_api_key != API_TOKEN: raise HTTPException(status_code=403, detail="Forbidden")
    chat=read_json(CHAT_FILE,[])
    llse_ok = os.path.exists(LLSE_LOG) and os.path.getsize(LLSE_LOG)>=1
    content_ok = os.path.exists(CONTENT_LOG) and os.path.getsize(CONTENT_LOG)>0
    return {"server":SERVER_NAME,"latest":chat[-MAX_CHAT:], "count":len(chat),
            "content_log_active": bool(content_ok),
            "llse_active": bool(llse_ok),
            "timestamp": datetime.datetime.now().isoformat()}

@app.post("/chat")
def post_chat(body: ChatIn, x_api_key: str = Header(None)):
    if x_api_key != API_TOKEN: raise HTTPException(status_code=403, detail="Forbidden")
    msg=str(body.message).strip()
    if not msg: raise HTTPException(status_code=400, detail="Empty message")
    try:
        with open(os.path.join(DATA,"in.pipe"),"w",encoding="utf-8") as f: f.write("say "+msg+"\n")
    except Exception: pass
    # 送信分は即座に chat.json にも残す
    chat=read_json(CHAT_FILE,[])
    chat.append({"player":"API","message":msg,"timestamp":datetime.datetime.now().isoformat()})
    chat=chat[-MAX_CHAT:]
    with open(CHAT_FILE,"w",encoding="utf-8") as f: json.dump(chat,f,ensure_ascii=False)
    return {"status":"ok"}
PY

# ---------------------------------------------------------------------
# 6) web（/api→monitor、/map alias）
# ---------------------------------------------------------------------
mkdir -p "${DOCKER_DIR}/web"

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

cat > "${DOCKER_DIR}/web/Dockerfile" <<'DOCK'
FROM nginx:alpine
DOCK

# ---- site assets ----
mkdir -p "${WEB_SITE_DIR}"
cat > "${WEB_SITE_DIR}/index.html" <<'HTML'
<!doctype html>
<html lang="ja">
<head>
  <meta charset="utf-8"/>
  <meta name="viewport" content="width=device-width,initial-scale=1"/>
  <title>OMF Portal</title>
  <link rel="stylesheet" href="styles.css"/>
  <script defer src="main.js"></script>
</head>
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
      <div id="server-text">
        <p>ようこそ！このサーバーは <strong id="sv-name"></strong> です。</p>
        <p>利用ルールや連絡事項などをここに記載してください。</p>
      </div>
    </section>

    <section id="chat" class="panel">
      <div class="status-row">
        <span>現在接続中:</span>
        <div id="players" class="pill-row"></div>
      </div>
      <div class="chat-list" id="chat-list"></div>
      <form id="chat-form" class="chat-form">
        <input id="chat-input" type="text" placeholder="メッセージを入力..." maxlength="200"/>
        <button type="submit">送信</button>
      </form>
    </section>

    <section id="map" class="panel">
      <div class="map-header">昨日までのマップデータ</div>
      <div class="map-frame">
        <iframe id="map-iframe" src="/map/index.html" title="map"></iframe>
      </div>
    </section>
  </main>
</body>
</html>
HTML

cat > "${WEB_SITE_DIR}/styles.css" <<'CSS'
*{box-sizing:border-box}body{margin:0;font-family:system-ui,-apple-system,Segoe UI,Roboto,Helvetica,Arial}
header{position:sticky;top:0;background:#111;color:#fff}
.tabs{display:flex;gap:.25rem;padding:.5rem}
.tab{flex:1;padding:.6rem 0;border:0;background:#222;color:#eee;cursor:pointer}
.tab.active{background:#0a84ff;color:#fff;font-weight:600}
.panel{display:none;padding:1rem}
.panel.show{display:block}
.status-row{display:flex;gap:.5rem;align-items:center;margin-bottom:.5rem}
.pill-row{display:flex;gap:.5rem;overflow-x:auto;padding:.25rem .5rem;border:1px solid #ddd;border-radius:.5rem;min-height:2.2rem}
.pill{padding:.25rem .6rem;border-radius:999px;background:#f1f1f1;white-space:nowrap;border:1px solid #ddd}
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
const API_BASE = "/api";
const API_TOKEN = localStorage.getItem("x_api_key") || "";
const SERVER_NAME = localStorage.getItem("server_name") || "";

document.addEventListener("DOMContentLoaded", ()=>{
  document.querySelectorAll(".tab").forEach(btn=>{
    btn.addEventListener("click", ()=>{
      document.querySelectorAll(".tab").forEach(b=>b.classList.remove("active"));
      document.querySelectorAll(".panel").forEach(p=>p.classList.remove("show"));
      btn.classList.add("active");
      document.getElementById(btn.dataset.target).classList.add("show");
    });
  });

  const sv = SERVER_NAME || "OMF Server";
  document.getElementById("sv-name").textContent = sv;

  refreshPlayers();
  refreshChat();
  setInterval(refreshPlayers, 15000);
  setInterval(refreshChat, 15000);

  document.getElementById("chat-form").addEventListener("submit", async (e)=>{
    e.preventDefault();
    const input = document.getElementById("chat-input");
    const msg = input.value.trim();
    if(!msg) return;
    try{
      const res = await fetch(API_BASE + "/chat", {
        method:"POST",
        headers:{ "Content-Type":"application/json", "x-api-key": API_TOKEN },
        body: JSON.stringify({message: msg})
      });
      if(!res.ok) throw new Error("POST failed");
      input.value="";
      refreshChat();
    }catch(err){
      alert("送信に失敗しました");
    }
  });
});

async function refreshPlayers(){
  try{
    const res = await fetch(API_BASE + "/players", {headers:{"x-api-key": API_TOKEN}});
    if(!res.ok) return;
    const data = await res.json();
    const row = document.getElementById("players");
    row.innerHTML = "";
    (data.players || []).forEach(name=>{
      const d = document.createElement("div");
      d.className = "pill";
      d.textContent = name;
      row.appendChild(d);
    });
  }catch(e){}
}

async function refreshChat(){
  try{
    const res = await fetch(API_BASE + "/chat", {headers:{"x-api-key": API_TOKEN}});
    if(!res.ok) return;
    const data = await res.json();
    const list = document.getElementById("chat-list");
    list.innerHTML = "";
    (data.latest || []).forEach(item=>{
      const d = document.createElement("div");
      d.className = "chat-item";
      d.textContent = `[${(item.timestamp||"").replace("T"," ").slice(0,19)}] ${item.player}: ${item.message}`;
      list.appendChild(d);
    });
    list.scrollTop = list.scrollHeight;
  }catch(e){}
}
JS

# /data/map placeholder（初回だけ）
mkdir -p "${DATA_DIR}/map"
if [[ ! -f "${DATA_DIR}/map/index.html" ]]; then
  cat > "${DATA_DIR}/map/index.html" <<'HTML'
<!doctype html><meta charset="utf-8">
<title>Map Placeholder</title>
<p>ここに uNmINeD の出力（index.html）が配置されます。</p>
HTML
fi

# ---------------------------------------------------------------------
# 7) マップ自動DL対応 update_map.sh（GitHub APIで .jar を取得）
# ---------------------------------------------------------------------
cat > "${BASE}/update_map.sh" <<'BASH'
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
BASH
chmod +x "${BASE}/update_map.sh"

# ---------------------------------------------------------------------
# 8) ビルド & プリフェッチ & 起動
# ---------------------------------------------------------------------
echo "[BUILD] docker images ..."
sudo docker compose -f "${DOCKER_DIR}/compose.yml" build --no-cache

echo "[PREFETCH] latest BDS payload ..."
sudo docker run --rm \
  -e TZ=Asia/Tokyo \
  --entrypoint /usr/local/bin/get_bds.sh \
  -v "${DATA_DIR}:/data" \
  local/bds-box64:latest

echo "[UP] docker compose up -d ..."
sudo docker compose -f "${DOCKER_DIR}/compose.yml" up -d

sleep 2
API_TOKEN_PRINT="${API_TOKEN}"
cat <<CONFIRM

================= ✅ 確認（例） =================
API_TOKEN="${API_TOKEN_PRINT}"
curl -s -S -H "x-api-key: \$API_TOKEN" "http://${MONITOR_BIND}:${MONITOR_PORT}/players" | jq .
curl -s -S -H "x-api-key: \$API_TOKEN" "http://${MONITOR_BIND}:${MONITOR_PORT}/chat"    | jq .

# Web: http://${WEB_BIND}:${WEB_PORT}
# - /api/* → monitor
# - /map/   → obj/data/map
# - マップ更新: ${BASE}/update_map.sh
=================================================
データ: ${DATA_DIR}
ログ:   ${DATA_DIR}/bedrock_server.log / bds_console.log / omfs_chat.log
=================================================
CONFIRM

