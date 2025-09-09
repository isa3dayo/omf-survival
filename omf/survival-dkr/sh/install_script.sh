#!/usr/bin/env bash
# =====================================================================
# OMFS v1.0.1 / Minecraft Bedrock (Docker 完全版・JP対応ログ監視・Web初回トークン保存)
# - Web: /api は bds-monitor へリバプロ、/map は /data-map を alias
# - box64: -DARM_DYNAREC=ON -DDEFAULT_PAGESIZE=16384 -G Ninja
# - クリーン機構: docker/イメージ/obj を安全掃除（ALL_CLEAN=true で worlds も初期化）
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

if [[ ! -f "${KEY_FILE}" ]]; then
  echo "[ERR] key.conf が見つかりません: ${KEY_FILE}"; exit 1
fi
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
BDS_URL="${BDS_URL:-}"
ALL_CLEAN="${ALL_CLEAN:-false}"

echo "[INFO] OMFS v1.0.1  user=${USER_NAME} base=${BASE} obj=${OBJ} all_clean=${ALL_CLEAN}"

# ---------------------------------------------------------------------
# 0) セーフクリーン
# ---------------------------------------------------------------------
echo "[CLEAN] stopping old stack (if any) ..."
if [[ -f "${DOCKER_DIR}/compose.yml" ]]; then
  sudo docker compose -f "${DOCKER_DIR}/compose.yml" down --remove-orphans || true
fi
for c in bds bds-monitor bds-web; do
  sudo docker rm -f "$c" >/dev/null 2>&1 || true
done

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
  mkdir -p "${DOCKER_DIR}" "${DATA_DIR}" "${BKP_DIR}" "${WEB_SITE_DIR}"
else
  echo "[CLEAN] refreshing docker build tree (keep data)"
  rm -rf "${DOCKER_DIR}"
  mkdir -p "${DOCKER_DIR}" "${WEB_SITE_DIR}"
fi
sudo chown -R "${USER_NAME}:${USER_NAME}" "${OBJ}" || true

# ---------------------------------------------------------------------
# 1) ホスト最低限パッケージ
# ---------------------------------------------------------------------
echo "[SETUP] apt packages (host-side) ..."
sudo apt-get update -y
sudo apt-get install -y --no-install-recommends ca-certificates curl wget jq unzip git tzdata

# ---------------------------------------------------------------------
# 2) .env（compose に渡す環境）
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
ENV

# ---------------------------------------------------------------------
# 3) docker compose（/api→monitor 逆プロキシ、/map→alias）
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
# 4) bds/ イメージ
# ---------------------------------------------------------------------
mkdir -p "${DOCKER_DIR}/bds"

cat > "${DOCKER_DIR}/bds/Dockerfile" <<'DOCK'
FROM debian:bookworm-slim
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates curl wget unzip jq xz-utils \
    build-essential git cmake python3 ninja-build \
 && rm -rf /var/lib/apt/lists/*

RUN git clone --depth=1 https://github.com/ptitSeb/box64 /tmp/box64 \
 && cmake -S /tmp/box64 -B /tmp/box64/build -G Ninja \
      -DARM_DYNAREC=ON -DDEFAULT_PAGESIZE=16384 -DCMAKE_BUILD_TYPE=RelWithDebInfo \
 && cmake --build /tmp/box64/build -j \
 && cmake --install /tmp/box64/build \
 && rm -rf /tmp/box64

WORKDIR /usr/local/bin
COPY get_bds.sh /usr/local/bin/get_bds.sh
COPY update_addons.py /usr/local/bin/update_addons.py
COPY entry-bds.sh /usr/local/bin/entry-bds.sh
RUN chmod +x /usr/local/bin/get_bds.sh /usr/local/bin/entry-bds.sh

WORKDIR /data
EXPOSE 13922/udp 19132/udp
CMD ["/usr/local/bin/entry-bds.sh"]
DOCK

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
if [ -z "${URL}" ] && [ -n "${BDS_URL:-}" ]; then
  URL="${BDS_URL}"
fi
if [ -z "${URL}" ]; then
  log "ERROR: could not obtain download url"
  exit 10
fi

log "downloading: ${URL}"
if ! wget -q -O bedrock-server.zip "${URL}"; then
  curl --http1.1 -fL -o bedrock-server.zip "${URL}"
fi

unzip -qo bedrock-server.zip -x server.properties allowlist.json
rm -f bedrock-server.zip
log "updated BDS payload"
BASH

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

cat > "${DOCKER_DIR}/bds/entry-bds.sh" <<'BASH'
#!/usr/bin/env bash
set -euo pipefail
export TZ="${TZ:-Asia/Tokyo}"

mkdir -p /data
cd /data

# 初回ひな形
if [ ! -f server.properties ]; then
  ports_v4="${BDS_PORT_V4:-13922}"
  ports_v6="${BDS_PORT_V6:-19132}"
  cat > server.properties <<PROP
server-name=${SERVER_NAME:-SurvivalServer}
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
PROP
fi
[ -f allowlist.json ] || echo "[]" > allowlist.json
[ -f chat.json ] || echo "[]" > chat.json
[ -d worlds/world/db ] || mkdir -p worlds/world/db

# players.json はサーバー開始時に毎回クリア
echo "[]" > /data/players.json || true

# ログ・FIFO
touch bedrock_server.log bds_console.log
[ -p in.pipe ] && rm -f in.pipe || true
mkfifo in.pipe

# 最新BDSを取得 & アドオン反映
/usr/local/bin/get_bds.sh
python3 /usr/local/bin/update_addons.py || true

# 起動メッセージ1件
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

echo "[entry-bds] launching BDS (stdin: /data/in.pipe)"
( tail -F /data/in.pipe | box64 ./bedrock_server 2>&1 | tee -a /data/bds_console.log ) | tee -a /data/bedrock_server.log
BASH
chmod +x "${DOCKER_DIR}/bds/entry-bds.sh" "${DOCKER_DIR}/bds/get_bds.sh"

# ---------------------------------------------------------------------
# 5) monitor/（JP/ENのチャット＆死亡ログ検出を強化）
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
import os, re, json, datetime, time, threading, requests
from fastapi import FastAPI, Header, HTTPException
from pydantic import BaseModel
import uvicorn

DATA="/data"
CFG_GAS=os.getenv("GAS_URL","")
API_TOKEN=os.getenv("API_TOKEN","")
SERVER_NAME=os.getenv("SERVER_NAME","SurvivalServer")

LOG_PRIMARY=os.path.join(DATA,"bds_console.log")
LOG_FALLBACK=os.path.join(DATA,"bedrock_server.log")
PLAYERS_FILE=os.path.join(DATA,"players.json")
CHAT_FILE=os.path.join(DATA,"chat.json")
IN_PIPE=os.path.join(DATA,"in.pipe")
MAX_CHAT=200   # 少し増やす

players=set()
first_notified_date=None

# ---------------- Detect rules ----------------
# 接続/切断（Bedrock標準）
RE_CONNECT = re.compile(r"Player connected:\s*(.+?),\s*xuid:\s*([0-9]+)", re.I)
RE_DISCONN = re.compile(r"Player disconnected:\s*(.+?)(?:,|$)", re.I)
RE_KICK    = re.compile(r"Kicked\s+(.+?)\s+for", re.I)
RE_TIMEOUT = re.compile(r"Timed out\s+(.+?)\s+from server", re.I)

RE_STOP1   = re.compile(r"Server stop requested", re.I)
RE_STOP2   = re.compile(r"Closing server", re.I)
RE_STARTED = re.compile(r"Server started\.", re.I)

# チャット:
# - A: 明示 [CHAT] 形式（MODやプラグイン等）
RE_CHAT_A  = re.compile(r"\[CHAT\]\s*(.+?):\s*(.+)")

# - B: Bedrock でよく見る "PlayerName: message" 形式（前段の [INFO] 等を許容）
#      ただし誤検出（Version: など）を避けるためブラックリスト語を除外
BLACK_PREFIX = set([
    "Version","Session ID","Build ID","Branch","Commit ID","Configuration",
    "Level Name","Game mode","Difficulty","Server started","IPv4 supported, port",
    "IPv6 supported, port","IPv4 supported","IPv6 supported","Gamerule","pack",
    "Pack","Content","Server stop","Running","Level Seed","Level seed",
    "Player Spawned","RakNet","Subchunk","Standard"
])
RE_CHAT_B  = re.compile(r"^\s*(?:\[.*?\])?\s*([^:\[\]]{1,32})\s*:\s*(.+)$")

# - 死亡メッセージ（英語の代表例）
RE_DEATH_EN = re.compile(
    r"\b(was slain by|was shot by|was blown up by|fell from a high place|hit the ground too hard|"
    r"drowned|tried to swim in lava|went up in flames|burned to death|starved to death|was pricked to death|"
    r"suffocated in a wall|withered away|was pummeled by|experienced kinetic energy)\b", re.I)

# - 死亡メッセージ（日本語の代表例・網羅ではない）
RE_DEATH_JP = re.compile(
    r"(は.*に倒された|は高い所から落ちた|は地面に激突した|は溺れ死んだ|は溶岩で焼け死んだ|は炎に包まれた|"
    r"は餓死した|はサボテンに刺さって死んだ|は壁の中で窒息した|はウィザーの効果で死亡した|"
    r"は粉々になった|は爆発で死亡した|は電撃で死亡した)")

def name_looks_like_player(s:str)->bool:
    # "Version" など明確なシステム語を除外
    if s in BLACK_PREFIX: return False
    # 角括弧や大きすぎる/空を除外
    s=s.strip()
    if not s or len(s)>32: return False
    # 先頭が英数字/日本語っぽい
    return True

def write_players():
    try: json.dump(sorted(list(players)), open(PLAYERS_FILE,"w"), ensure_ascii=False)
    except Exception as e: print("[players][ERROR]", e)

def clear_players(reason=""):
    global players
    players=set(); write_players()
    if reason: print(f"[players] cleared ({reason})")

def post_to_gas(first_player):
    global first_notified_date
    if not CFG_GAS: return
    today=datetime.date.today().isoformat()
    if first_notified_date==today: return
    payload={"event":"first_login_of_day","server":SERVER_NAME,
             "player":first_player,"online_count":len(players),
             "timestamp":datetime.datetime.now().isoformat()}
    try:
        requests.post(CFG_GAS,json=payload,timeout=6)
        first_notified_date=today
    except Exception as e:
        print("[GAS] ERROR:",e)

def append_chat(entry):
    chat=[]
    if os.path.exists(CHAT_FILE):
        try:
            chat=json.load(open(CHAT_FILE))
            if not isinstance(chat,list): chat=[]
        except Exception: chat=[]
    chat.append(entry); chat=chat[-MAX_CHAT:]
    json.dump(chat, open(CHAT_FILE,"w"), ensure_ascii=False)

def sanitize_chat_message(s):
    if s is None: return ""
    s="".join(ch for ch in str(s) if ch.isprintable()).replace("\n"," ").replace("\r"," ").strip()
    return (s[:200]+"…") if len(s)>200 else s

def send_cmd(cmd:str):
    try:
        with open(IN_PIPE,'w',encoding='utf-8') as f:
            f.write(cmd+"\n")
    except Exception as e:
        print("[PIPE][ERROR]",e)

def open_logfile():
    for path in (LOG_PRIMARY, LOG_FALLBACK):
        if os.path.exists(path):
            print(f"[monitor] tailing {path}")
            return open(path,"r",encoding="utf-8",errors="ignore")
    while True:
        for path in (LOG_PRIMARY, LOG_FALLBACK):
            if os.path.exists(path):
                print(f"[monitor] tailing {path}")
                return open(path,"r",encoding="utf-8",errors="ignore")
        print("[monitor] waiting for log file ..."); time.sleep(2)

def handle_line(line:str):
    # stop/start
    if RE_STARTED.search(line): clear_players("server started"); return
    if RE_STOP1.search(line) or RE_STOP2.search(line): clear_players("server stop"); return

    # connect/disconnect
    m=RE_CONNECT.search(line)
    if m:
        name=m.group(1).strip()
        was_empty=(len(players)==0)
        players.add(name); write_players()
        if was_empty: post_to_gas(name)
        return

    m=RE_DISCONN.search(line)
    if m:
        name=m.group(1).strip()
        if name in players: players.remove(name); write_players()
        return

    m=RE_KICK.search(line)
    if m:
        name=m.group(1).strip()
        if name in players: players.remove(name); write_players()
        return

    m=RE_TIMEOUT.search(line)
    if m:
        name=m.group(1).strip()
        if name in players: players.remove(name); write_players()
        return

    # death (JP/EN)
    if RE_DEATH_EN.search(line) or RE_DEATH_JP.search(line):
        ts=datetime.datetime.now().isoformat()
        # 死亡文そのままを message に
        msg=line.strip()
        append_chat({"player":"死亡","message":msg,"timestamp":ts})
        return

    # chat detect
    m=RE_CHAT_A.search(line)
    if m:
        player=m.group(1).strip(); message=m.group(2).strip()
        ts=datetime.datetime.now().isoformat()
        append_chat({"player":player,"message":message,"timestamp":ts})
        return

    m=RE_CHAT_B.search(line)
    if m:
        player=m.group(1).strip()
        if not name_looks_like_player(player): return
        message=m.group(2).strip()
        # よくある誤検出の弾き（コロン以降が "xuid:" のような管理情報だけは除外）
        if re.match(r"^(xuid|pfid|port|used for|use d for|Server|IPv[46])", message, re.I):
            return
        ts=datetime.datetime.now().isoformat()
        append_chat({"player":player,"message":message,"timestamp":ts})
        return

def tail_log_loop():
    clear_players("monitor start")
    if not os.path.exists(CHAT_FILE):
        json.dump([], open(CHAT_FILE,"w"))
    f=open_logfile()
    f.seek(0,2)
    while True:
        line=f.readline()
        if not line:
            time.sleep(0.2); continue
        try:
            handle_line(line)
        except Exception as e:
            print("[parse][ERROR]", e)

# ---------------- FastAPI ----------------
app=FastAPI()
class ChatIn(BaseModel): message:str

@app.get("/players")
def get_players(x_api_key: str = Header(None)):
    if x_api_key != API_TOKEN: raise HTTPException(status_code=403, detail="Forbidden")
    try: current=json.load(open(PLAYERS_FILE))
    except Exception: current=[]
    return {"server":SERVER_NAME,"players":current,"timestamp":datetime.datetime.now().isoformat()}

@app.get("/chat")
def get_chat(x_api_key: str = Header(None)):
    if x_api_key != API_TOKEN: raise HTTPException(status_code=403, detail="Forbidden")
    try:
        chat=json.load(open(CHAT_FILE))
        if not isinstance(chat,list): chat=[]
    except Exception:
        chat=[]
    return {"server":SERVER_NAME,"latest":chat,"count":len(chat),"timestamp":datetime.datetime.now().isoformat()}

@app.post("/chat")
def post_chat(body: ChatIn, x_api_key: str = Header(None)):
    if x_api_key != API_TOKEN: raise HTTPException(status_code=403, detail="Forbidden")
    msg=sanitize_chat_message(body.message)
    if not msg: raise HTTPException(status_code=400, detail="Empty message")
    send_cmd(f"say {msg}")
    append_chat({"player":"API","message":msg,"timestamp":datetime.datetime.now().isoformat()})
    return {"status":"ok"}

if __name__=="__main__":
    t=threading.Thread(target=tail_log_loop,daemon=True); t.start()
    uvicorn.run(app, host="0.0.0.0", port=13900, log_level="info")
PY

# ---------------------------------------------------------------------
# 6) web（/api→monitor 逆プロキシ、/map→/data-map alias、初回トークン保存UI）
# ---------------------------------------------------------------------
mkdir -p "${DOCKER_DIR}/web"

cat > "${DOCKER_DIR}/web/nginx.conf" <<'NGX'
server {
  listen 80 default_server;
  server_name _;

  # API: bds-monitor へ内部プロキシ
  location /api/ {
    proxy_pass http://bds-monitor:13900/;
    proxy_set_header Host $host;
    proxy_set_header X-Forwarded-Proto $scheme;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
  }

  # マップ: /data-map を公開（obj/data/map を RO マウント）
  location /map/ {
    alias /data-map/;
    autoindex on;
  }

  # 静的サイト
  location / {
    root /usr/share/nginx/html;
    index index.html;
    try_files $uri $uri/ =404;
  }
}
NGX

cat > "${DOCKER_DIR}/web/Dockerfile" <<'DOCK'
FROM nginx:alpine
# conf/site は compose でマウント
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
      <div class="token-box">
        <label>API Token:
          <input id="token-input" type="password" placeholder="x-api-key を入力"/>
        </label>
        <button id="token-save">保存</button>
        <span class="mini">初回はここで保存（?token=XXXXXXXX をURLに付けてもOK）</span>
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
      <div class="map-header">マップデータ（/map/）</div>
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
.token-box{margin-top:1rem;padding:.5rem;border:1px dashed #999;border-radius:.5rem}
.token-box input{margin-left:.5rem}
.token-box .mini{margin-left:.5rem;color:#666;font-size:.85em}
CSS

cat > "${WEB_SITE_DIR}/main.js" <<'JS'
const API_BASE = "/api"; // nginx が bds-monitor へプロキシ
function getToken(){
  const url = new URL(location.href);
  const t = url.searchParams.get("token");
  if(t){ localStorage.setItem("x_api_key", t); history.replaceState({}, "", location.pathname); return t; }
  return localStorage.getItem("x_api_key") || "";
}
let API_TOKEN = getToken();
const SERVER_NAME = localStorage.getItem("server_name") || "";

function needToken(){ return !API_TOKEN || API_TOKEN.length < 6; }

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

  // token UI
  const tokenInput = document.getElementById("token-input");
  const tokenSave = document.getElementById("token-save");
  tokenInput.value = API_TOKEN;
  tokenSave.addEventListener("click", ()=>{
    const v = tokenInput.value.trim();
    if(!v){ alert("トークンを入力してください"); return; }
    localStorage.setItem("x_api_key", v);
    API_TOKEN = v;
    alert("保存しました");
    refreshPlayers(); refreshChat();
  });

  // 初回トークン未設定なら案内
  if(needToken()){
    document.querySelector('[data-target="info"]').click();
  }else{
    refreshPlayers(); refreshChat();
    setInterval(refreshPlayers, 15000);
    setInterval(refreshChat, 15000);
  }

  document.getElementById("chat-form").addEventListener("submit", async (e)=>{
    e.preventDefault();
    if(needToken()){ alert("先に API Token を保存してください"); return; }
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
    if(needToken()) return;
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
    if(needToken()) return;
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

# /data/map プレースホルダ（初回のみ）
mkdir -p "${DATA_DIR}/map"
if [[ ! -f "${DATA_DIR}/map/index.html" ]]; then
  cat > "${DATA_DIR}/map/index.html" <<'HTML'
<!doctype html><meta charset="utf-8">
<title>Map Placeholder</title>
<p>ここに uNmINeD の出力（index.html）が配置されます。</p>
HTML
fi

# ---------------------------------------------------------------------
# 7) マップ手動更新スクリプト
# ---------------------------------------------------------------------
cat > "${BASE}/update_map.sh" <<'BASH'
#!/usr/bin/env bash
set -euo pipefail
BASE_DIR="$(cd "$(dirname "$0")" && pwd)"
DATA="${BASE_DIR}/obj/data"
WORLD="${DATA}/worlds/world"
OUT="${DATA}/map"

if ! command -v unmined-cli >/dev/null 2>&1; then
  echo "[update_map] uNmINeD CLI が見つかりません。例:"
  echo "  sudo apt-get install -y openjdk-17-jre-headless  # Javaが必要な版の場合"
  echo "  # または公式CLIを取得して PATH へ配置"
  echo "手動で OUT=${OUT} に index.html を出力してください。"
  exit 0
fi

mkdir -p "${OUT}"
echo "[update_map] rendering map from: ${WORLD}"
unmined-cli render --world "${WORLD}" --output "${OUT}" --zoomlevels 1-4 || true
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

================= ✅ 確認コマンド（実行例） =================
API_TOKEN="${API_TOKEN_PRINT}"

# monitor は既定で ${MONITOR_BIND}:${MONITOR_PORT}
curl -s -S -H "x-api-key: \$API_TOKEN" "http://${MONITOR_BIND}:${MONITOR_PORT}/players" | jq .
curl -s -S -H "x-api-key: \$API_TOKEN" "http://${MONITOR_BIND}:${MONITOR_PORT}/chat" | jq .
curl -s -S -X POST -H "Content-Type: application/json" -H "x-api-key: \$API_TOKEN" \
  -d '{"message":"APIからのテスト"}' "http://${MONITOR_BIND}:${MONITOR_PORT}/chat" | jq .

# Web (nginx): http://${WEB_BIND}:${WEB_PORT}
#  - 初回は画面上で API Token を保存 または URL に ?token=XXXXXXXX を付けてアクセス
#  - /api/* → monitor へ内部プロキシ（CORS不要）
#  - マップは /map/ （obj/data/map を RO マウント）
#  - 手動更新: ${BASE}/update_map.sh（起動時自動化は systemd/cron 等でこのスクリプトを実行）
============================================================
データ: ${DATA_DIR}
ログ:   ${DATA_DIR}/bedrock_server.log / bds_console.log
============================================================
CONFIRM

