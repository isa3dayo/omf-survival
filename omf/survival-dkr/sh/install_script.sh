#!/usr/bin/env bash
# =====================================================================
# OMFS (install_script.sh) — RPi5 / RPi OS Lite
#  - LLSE 確実導入 & JSプラグインでチャット/死亡ログ収集
#  - bds-monitor: /health でヘルスチェック
#  - uNmINeD: arm64 glibc/musl 自動DL + web render
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
BDS_URL="${BDS_URL:-}"          # 固定BDS URL（空ならAPIで自動）
LLSE_URL="${LLSE_URL:-}"        # 固定LLSE URL（空ならAPIで自動）
ALL_CLEAN="${ALL_CLEAN:-false}" # true で worlds 等も含め完全初期化
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
mkdir -p "${DOCKER_DIR}" "${DATA_DIR}" "${BKP_DIR}" "${WEB_SITE_DIR}" "${TOOLS_DIR}"
sudo chown -R "${USER_NAME}:${USER_NAME}" "${OBJ}" || true

# ---------------------------------------------------------------------
# 1) ホスト最低限
# ---------------------------------------------------------------------
echo "[SETUP] apt packages (host-side) ..."
sudo apt-get update -y
sudo apt-get install -y --no-install-recommends ca-certificates curl wget jq unzip git tzdata xz-utils

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
# 3) docker compose（monitor に /health ヘルスチェック）
# ---------------------------------------------------------------------
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

# ---------------------------------------------------------------------
# 4) bds/ イメージ（LLSE 自動導入 + ランチャー優先起動）
# ---------------------------------------------------------------------
mkdir -p "${DOCKER_DIR}/bds"

cat > "${DOCKER_DIR}/bds/Dockerfile" <<'DOCK'
FROM debian:bookworm-slim
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates curl wget unzip jq xz-utils \
    build-essential git cmake python3 ninja-build procps \
 && rm -rf /var/lib/apt/lists/*

# box64
RUN git clone --depth=1 https://github.com/ptitSeb/box64 /tmp/box64 \
 && cmake -S /tmp/box64 -B /tmp/box64/build -G Ninja \
      -DARM_DYNAREC=ON -DDEFAULT_PAGESIZE=16384 -DCMAKE_BUILD_TYPE=RelWithDebInfo \
 && cmake --build /tmp/box64/build -j \
 && cmake --install /tmp/box64/build \
 && rm -rf /tmp/box64

WORKDIR /usr/local/bin
COPY get_bds.sh install_llse.sh update_addons.py entry-bds.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/*.sh

WORKDIR /data
EXPOSE 13922/udp 19132/udp
CMD ["/usr/local/bin/entry-bds.sh"]
DOCK

# === BDS 取得 ===
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

# === LLSE 取得（GitHub API → wget -L） ===
cat > "${DOCKER_DIR}/bds/install_llse.sh" <<'BASH'
#!/usr/bin/env bash
set -euo pipefail
cd /data
[ "${ENABLE_CHAT_LOGGER:-true}" = "true" ] || { echo "[llse] disabled by env"; exit 0; }

# 既に導入済みならスキップ
if [ -x "/data/ll" ] || [ -x "/data/bedrock_server_mod" ] || [ -d "/data/LiteLoader" ]; then
  echo "[llse] already present"; exit 0;
fi

get_llse_url() {
  if [ -n "${LLSE_URL:-}" ]; then echo "${LLSE_URL}"; return 0; fi
  curl -fsSL https://api.github.com/repos/LiteLDev/LiteLoaderBDS/releases/latest \
  | jq -r '.assets[]?.browser_download_url' \
  | grep -iE 'linux.*(x64|amd64).*\.zip$' \
  | head -n1
}
URL="$(get_llse_url || true)"
[ -n "$URL" ] || { echo "[llse] could not determine download URL"; exit 1; }

echo "[llse] downloading: $URL"
TMP="$(mktemp -d)"
if ! wget -q -L -O "${TMP}/llse.zip" "$URL"; then
  curl -fsSL -o "${TMP}/llse.zip" "$URL" || { echo "[llse] download failed"; rm -rf "$TMP"; exit 1; }
fi

unzip -qo "${TMP}/llse.zip" -d "${TMP}/u" || { echo "[llse] unzip failed"; rm -rf "$TMP"; exit 1; }

# 代表ファイルを探索して配置
# ll / bedrock_server_mod / LiteLoader/ のいずれかがあれば十分
find "${TMP}/u" -type f -name 'll' -print -quit | xargs -r -I{} cp -f {} /data/ll
find "${TMP}/u" -type f -name 'bedrock_server_mod' -print -quit | xargs -r -I{} cp -f {} /data/bedrock_server_mod
find "${TMP}/u" -type d -name 'LiteLoader' -print -quit | xargs -r -I{} cp -r {} /data/

chmod +x /data/ll 2>/dev/null || true
chmod +x /data/bedrock_server_mod 2>/dev/null || true

rm -rf "$TMP"

if [ ! -x "/data/ll" ] && [ ! -x "/data/bedrock_server_mod" ] && [ ! -d "/data/LiteLoader" ]; then
  echo "[llse] install failed (no launcher found)"; exit 1
fi

# ---- OMFS JSプラグイン（onChat / onPlayerDie / 参加者同期）----
mkdir -p /data/plugins/omfs-chat-logger
cat > /data/plugins/omfs-chat-logger/entry.js <<'JS'
/**
 * OMFS Chat/Death Logger for LLSE
 * - 保存: /data/chat.json（最新50件）
 * - 追記: /data/omfs_chat.log（確認用）
 * - players.json は monitor 側で読み取り
 */
let fs = require('fs');
const DATA    = '/data';
const CHATJS  = DATA + '/chat.json';
const CHATLOG = DATA + '/omfs_chat.log';
const PLAYERS = DATA + '/players.json';

function safeReadJSON(path, defv){
  try {
    if (!fs.existsSync(path)) return defv;
    let j = JSON.parse(fs.readFileSync(path, {encoding:'utf8'}));
    if (Array.isArray(defv) && !Array.isArray(j)) return defv;
    return j;
  } catch(e){ return defv; }
}
function savePlayers(){
  try {
    let list = mc.getOnlinePlayers().map(p=>p.realName);
    fs.writeFileSync(PLAYERS, JSON.stringify(list.sort(), null, 2));
  } catch(e){}
}
function appendChat(entry){
  let chat = safeReadJSON(CHATJS, []);
  chat.push(entry);
  if (chat.length > 50) chat = chat.slice(-50);
  fs.writeFileSync(CHATJS, JSON.stringify(chat, null, 2));
  try { fs.appendFileSync(CHATLOG, `[${entry.timestamp}] ${entry.player}: ${entry.message}\n`); } catch(e){}
}

// 初期ファイル
if (!fs.existsSync(CHATJS)) fs.writeFileSync(CHATJS, '[]');
if (!fs.existsSync(PLAYERS)) fs.writeFileSync(PLAYERS, '[]');
try { fs.appendFileSync(CHATLOG, `[${new Date().toISOString()}] SYSTEM: OMFS logger loaded\n`); } catch(e){}

// 参加/退出
mc.listen('onJoin', (pl)=>{ savePlayers(); });
mc.listen('onLeft', (pl)=>{ savePlayers(); });

// チャット（return しない → メッセージをブロックしない）
mc.listen('onChat', (pl, msg)=>{
  appendChat({player: pl.realName, message: String(msg), timestamp: new Date().toISOString()});
});

// 死亡
mc.listen('onPlayerDie', (player, source, cause, damage)=>{
  let who = player ? player.realName : 'unknown';
  let causeText = (cause!==undefined && cause!==null) ? String(cause) : 'death';
  appendChat({player: 'DEATH', message: `${who} が死亡 (${causeText})`, timestamp: new Date().toISOString()});
});

logger.info('[OMFS] chat/death logger loaded');
JS

echo "[llse] installed with OMFS plugin"
BASH

# === アドオン反映 ===
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

# === エントリ（LiteLoader を最優先で起動） ===
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
# content.log を試す（ただし LLSE が主役）
content-log-file-enabled=true
content-log-file-name=content.log
PROP
fi
[ -f allowlist.json ] || echo "[]" > allowlist.json
[ -f chat.json ]     || echo "[]" > chat.json
[ -d worlds/world/db ] || mkdir -p worlds/world/db
echo "[]" > /data/players.json || true

# ログ・FIFO
touch bedrock_server.log bds_console.log
[ -p in.pipe ] && rm -f in.pipe || true
mkfifo in.pipe

/usr/local/bin/get_bds.sh
/usr/local/bin/install_llse.sh || echo "[entry-bds] WARN: LLSE install failed. Continue without LLSE."
python3 /usr/local/bin/update_addons.py || true

# 起動メッセージ
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

# LiteLoader を最優先で起動
LAUNCH=""
if [ -x ./ll ] || [ -d ./LiteLoader ]; then
  LAUNCH="box64 ./ll"
elif [ -x ./bedrock_server_mod ]; then
  LAUNCH="box64 ./bedrock_server_mod"
else
  LAUNCH="box64 ./bedrock_server"
fi
echo "[entry-bds] exec: $LAUNCH (stdin: /data/in.pipe)"

( tail -F /data/in.pipe | eval "$LAUNCH" 2>&1 | tee -a /data/bds_console.log ) | tee -a /data/bedrock_server.log
BASH
chmod +x "${DOCKER_DIR}/bds/"*.sh

# ---------------------------------------------------------------------
# 5) monitor/（/health 追加・LLSE稼働検出を強化）
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
import os, json, datetime
from fastapi import FastAPI, Header, HTTPException
from pydantic import BaseModel
import uvicorn, requests

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
        with open(path,"r",encoding="utf-8") as f:
            return json.load(f)
    except Exception:
        return defv

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

@app.get("/health")
def health():
    try:
        ok_chat = os.path.exists(CHAT_FILE)
        ok_players = os.path.exists(PLAYERS_FILE)
        return {"ok": True, "chat_file": ok_chat, "players_file": ok_players,
                "ts": datetime.datetime.now().isoformat()}
    except Exception:
        return {"ok": True, "ts": datetime.datetime.now().isoformat()}

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
    # 稼働判定: ファイル存在 + サイズ + 直近更新
    llse_ok = os.path.exists(LLSE_LOG) and os.path.getsize(LLSE_LOG)>0
    content_ok = os.path.exists(CONTENT_LOG) and os.path.getsize(CONTENT_LOG)>0
    return {"server":SERVER_NAME,"latest":chat[-MAX_CHAT:], "count":len(chat),
            "content_log_active": bool(content_ok),
            "llse_active": bool(llse_ok or os.path.isdir(os.path.join(DATA,"LiteLoader"))),
            "timestamp": datetime.datetime.now().isoformat()}

@app.post("/chat")
def post_chat(body: ChatIn, x_api_key: str = Header(None)):
    if x_api_key != API_TOKEN: raise HTTPException(status_code=403, detail="Forbidden")
    msg=str(body.message).strip()
    if not msg: raise HTTPException(status_code=400, detail="Empty message")
    try:
        with open(os.path.join(DATA,"in.pipe"),"w",encoding="utf-8") as f: f.write("say "+msg+"\n")
    except Exception: pass
    chat=read_json(CHAT_FILE,[])
    chat.append({"player":"API","message":msg,"timestamp":datetime.datetime.now().isoformat()})
    chat=chat[-MAX_CHAT:]
    try:
        with open(CHAT_FILE,"w",encoding="utf-8") as f: json.dump(chat,f,ensure_ascii=False)
    except Exception: pass
    return {"status":"ok"}

if __name__=="__main__":
    print("[monitor] starting on 0.0.0.0:13900")
    uvicorn.run(app, host="0.0.0.0", port=13900, log_level="info")
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
      <div class="map-header">マップ（uNmINeD Web 出力）</div>
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

# /data/map placeholder（初回のみ）
mkdir -p "${DATA_DIR}/map"
if [[ ! -f "${DATA_DIR}/map/index.html" ]]; then
  cat > "${DATA_DIR}/map/index.html" <<'HTML'
<!doctype html><meta charset="utf-8">
<title>Map Placeholder</title>
<p>ここに uNmINeD の Web 出力（index.html）が配置されます。</p>
HTML
fi

# ---------------------------------------------------------------------
# 7) uNmINeD: arm64 glibc/musl 自動DL & web render
# ---------------------------------------------------------------------
cat > "${BASE}/update_map.sh" <<'BASH'
#!/usr/bin/env bash
set -euo pipefail
BASE_DIR="$(cd "$(dirname "$0")" && pwd)"
DATA="${BASE_DIR}/obj/data"
WORLD="${DATA}/worlds/world"
OUT="${DATA}/map"
TOOLS="${BASE_DIR}/obj/tools/unmined"
BIN="${TOOLS}/unmined-cli"
mkdir -p "${TOOLS}" "${OUT}"

arch="$(uname -m)"
libc="glibc"
if ldd --version 2>&1 | grep -qi musl; then libc="musl"; fi

pick_url() {
  if [ "$arch" != "aarch64" ] && [ "$arch" != "arm64" ]; then
    echo "unsupported-arch"; return
  fi
  if [ "$libc" = "musl" ]; then
    echo "https://unmined.net/download/unmined-cli-linux-musl-arm64-dev/"
  else
    echo "https://unmined.net/download/unmined-cli-linux-arm64-dev/"
  fi
}

download_and_extract() {
  local page="$1"
  local tmp; tmp="$(mktemp -d)"
  echo "[update_map] fetching: $page"
  if ! wget -q --content-disposition -L -P "$tmp" "$page"; then
    echo "[update_map] initial fetch failed"; rm -rf "$tmp"; return 1
  fi
  local file; file="$(ls -1 "$tmp" | head -n1 || true)"
  [ -n "$file" ] || { echo "[update_map] no file"; rm -rf "$tmp"; return 1; }
  file="$tmp/$file"
  if echo "$file" | grep -qiE '\.zip$'; then
    unzip -qo "$file" -d "$tmp/x" || { rm -rf "$tmp"; return 1; }
  else
    mkdir -p "$tmp/x"
    tar xf "$file" -C "$tmp/x" || { rm -rf "$tmp"; return 1; }
  fi
  local found; found="$(find "$tmp/x" -type f -iname 'unmined-cli*' | head -n1 || true)"
  [ -n "$found" ] || { echo "[update_map] binary not found"; rm -rf "$tmp"; return 1; }
  cp -f "$found" "$BIN"; chmod +x "$BIN"; rm -rf "$tmp"; return 0
}

URL="$(pick_url)"
if [ "$URL" = "unsupported-arch" ]; then
  echo "[update_map] unsupported arch: $(uname -m)"; exit 0
fi

if [[ ! -x "$BIN" ]]; then
  echo "[update_map] downloading uNmINeD CLI (arch=$(uname -m) libc=$libc)"
  if ! download_and_extract "$URL"; then
    if echo "$URL" | grep -q musl; then
      echo "[update_map] fallback to glibc"
      download_and_extract "https://unmined.net/download/unmined-cli-linux-arm64-dev/" || true
    else
      echo "[update_map] fallback to musl"
      download_and_extract "https://unmined.net/download/unmined-cli-linux-musl-arm64-dev/" || true
    fi
  fi
fi

if [[ ! -x "$BIN" ]]; then
  echo "[update_map] 自動DLに失敗。手動で ${BIN} を配置してください。"; exit 0
fi

mkdir -p "${OUT}"
echo "[update_map] rendering web map from: ${WORLD}"
# ← 重要：web render を使用
"$BIN" web render --world "${WORLD}" --output "${OUT}" --maxrenderthreads 4 || true
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

sleep 3
API_TOKEN_PRINT="${API_TOKEN}"
cat <<CONFIRM

================= ✅ 確認コマンド（例） =================
API_TOKEN="${API_TOKEN_PRINT}"

# ヘルスチェック（認証不要）
curl -s -S "http://${MONITOR_BIND}:${MONITOR_PORT}/health" | jq .

# API (キー必要)
curl -s -S -H "x-api-key: \$API_TOKEN" "http://${MONITOR_BIND}:${MONITOR_PORT}/players" | jq .
curl -s -S -H "x-api-key: \$API_TOKEN" "http://${MONITOR_BIND}:${MONITOR_PORT}/chat"    | jq .

# マップ更新
${BASE}/update_map.sh
# ブラウザ: http://${WEB_BIND}:${WEB_PORT} → [マップ] タブ
============================================================
データ: ${DATA_DIR}
ログ:   ${DATA_DIR}/bedrock_server.log / bds_console.log / omfs_chat.log
============================================================
CONFIRM

