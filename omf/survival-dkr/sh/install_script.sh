#!/usr/bin/env bash
# =============================================================================
# OMFS installer
#  - 安定運用：Script API 不使用（ベータ不要、クラッシュ回避）
#  - /data 直下の world_behavior_packs.json / world_resource_packs.json のみを使用
#    （worlds/<name>/world_* は削除）
#  - テスト用アドオン「OMF Hello」を自動生成（初回 join 時に画面表示）
#  - /say と join/leave を bedrock_server.log から監視 → /chat /players API
#  - allowlist/permissions の自動連携は従来どおり（環境変数で制御）
# =============================================================================
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

# 任意オプション（キーが無ければデフォルト）
ALLOWLIST_ON="${ALLOWLIST_ON:-false}"            # true で allowlist 有効（server.properties）
ALLOWLIST_AUTOADD="${ALLOWLIST_AUTOADD:-false}"  # true で join ログ検知 → allowlist へ自動追記
AUTH_CHEAT="${AUTH_CHEAT:-member}"               # permissions.json のデフォルト権限 (visitor|member|operator)

# ポート類
BDS_PORT_PUBLIC_V4="${BDS_PORT_PUBLIC_V4:-13922}"   # 公開ポート（ゲーム用）
BDS_PORT_V6="${BDS_PORT_V6:-19132}"                 # LAN
MONITOR_BIND="${MONITOR_BIND:-127.0.0.1}"
MONITOR_PORT="${MONITOR_PORT:-13900}"
WEB_BIND="${WEB_BIND:-0.0.0.0}"
WEB_PORT="${WEB_PORT:-13901}"
BDS_URL="${BDS_URL:-}"
ALL_CLEAN="${ALL_CLEAN:-false}"

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

# ------------------ apt ------------------
echo "[SETUP] apt..."
sudo apt-get update -y
sudo apt-get install -y --no-install-recommends ca-certificates curl wget jq unzip git tzdata xz-utils build-essential rsync

# ------------------ .env ------------------
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

# allowlist/permissions 連携
ALLOWLIST_ON=${ALLOWLIST_ON}
ALLOWLIST_AUTOADD=${ALLOWLIST_AUTOADD}
AUTH_CHEAT=${AUTH_CHEAT}
ENV

# ------------------ compose ------------------
cat > "${DOCKER_DIR}/compose.yml" <<YAML
services:
  # ---- Bedrock Dedicated Server（box64 実行、公開ポートで待受） ----
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
      AUTH_CHEAT: \${AUTH_CHEAT}
    volumes:
      - ../data:/data
    ports:
      - "\${BDS_PORT_PUBLIC_V4}:\${BDS_PORT_PUBLIC_V4}/udp"
      - "\${BDS_PORT_V6}:\${BDS_PORT_V6}/udp"
    restart: unless-stopped

  # ---- 監視 API（/players, /chat, /announce, /allowlist/*） ----
  monitor:
    build: { context: ./monitor }
    image: local/bds-monitor:latest
    container_name: bds-monitor
    env_file: .env
    environment:
      TZ: \${TZ}
      SERVER_NAME: \${SERVER_NAME}
      API_TOKEN: \${API_TOKEN}
      ALLOWLIST_AUTOADD: \${ALLOWLIST_AUTOADD}
      AUTH_CHEAT: \${AUTH_CHEAT}
    volumes:
      - ../data:/data
    ports:
      - "${MONITOR_BIND}:${MONITOR_PORT}:13900/tcp"
    depends_on:
      bds:
        condition: service_started
    restart: unless-stopped

  # ---- Web（/map と /api を提供） ----
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
    restart: unless-stopped
YAML

# ------------------ bds イメージ ------------------
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
COPY get_bds.sh update_addons.py entry-bds.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/*.sh

WORKDIR /data
EXPOSE 19132/udp 13922/udp
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

# --- アドオン JSON 更新（BP/RP を /data 直下の world_* に反映。worlds/<name>/ は削除） ---
cat > "${DOCKER_DIR}/bds/update_addons.py" <<'PY'
import os, json, re, shutil
ROOT="/data"
BP=os.path.join(ROOT,"behavior_packs")
RP=os.path.join(ROOT,"resource_packs")
WBP=os.path.join(ROOT,"world_behavior_packs.json")
WRP=os.path.join(ROOT,"world_resource_packs.json")
# 誤配置ファイル（削除対象）
LEG_WBP=os.path.join(ROOT,"worlds","world","world_behavior_packs.json")
LEG_WRP=os.path.join(ROOT,"worlds","world","world_resource_packs.json")

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
      out.append({"pack_id":uuid,"version":ver,"type":tp}); print(f"[addons] {name} {uuid} {ver}")
    except Exception as e: print(f"[addons] invalid manifest in {name}: {e}")
  return out

def write(p,items):
  with open(p,"w",encoding="utf-8") as f:
    json.dump(items,f,indent=2,ensure_ascii=False)
  print(f"[addons] wrote {p} ({len(items)} packs)")

if __name__=="__main__":
  items = scan(BP,"data")
  write(WBP, items)
  items_r = scan(RP,"resources")
  write(WRP, items_r)
  # worlds/<name>/ 側は削除して混乱を避ける
  for legacy in (LEG_WBP, LEG_WRP):
    if os.path.exists(legacy):
      try:
        os.remove(legacy); print(f"[addons] removed legacy {legacy}")
      except Exception as e:
        print(f"[addons] failed to remove legacy {legacy}: {e}")
PY

# --- エントリ（BDS 起動 / server.properties 整備 / OMF Hello BP 展開） ---
cat > "${DOCKER_DIR}/bds/entry-bds.sh" <<'BASH'
#!/usr/bin/env bash
set -euo pipefail
export TZ="${TZ:-Asia/Tokyo}"
cd /data; mkdir -p /data

# 初回 server.properties（公開ポート）
if [ ! -f server.properties ]; then
  cat > server.properties <<PROP
server-name=${SERVER_NAME:-OMF}
gamemode=survival
difficulty=normal
allow-cheats=true
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
white-list=${ALLOWLIST_ON:-false}
PROP
else
  sed -i "s/^server-port=.*/server-port=${BDS_PORT_V4:-13922}/" server.properties
  sed -i "s/^server-portv6=.*/server-portv6=${BDS_PORT_V6:-19132}/" server.properties
  sed -i "s/^allow-cheats=.*/allow-cheats=true/" server.properties
  sed -i "s/^white-list=.*/white-list=${ALLOWLIST_ON:-false}/" server.properties
  sed -i "s/^content-log-file-enabled=.*/content-log-file-enabled=true/" server.properties
  sed -i "s/^content-log-file-name=.*/content-log-file-name=content.log/" server.properties
fi

# データ系初期化
[ -f allowlist.json ] || echo "[]" > allowlist.json
[ -f permissions.json ] || echo "[]" > permissions.json
[ -f chat.json ] || echo "[]" > chat.json
[ -d worlds/world/db ] || mkdir -p worlds/world/db
echo "[]" > /data/players.json || true
touch bedrock_server.log bds_console.log

# ---- テスト用 BP: OMF Hello（Script API 不要。join 後にプレイヤーへ一度だけ案内表示） ----
BP_DIR="/data/behavior_packs/omf_hello"
mkdir -p "$BP_DIR"
cat > "$BP_DIR/manifest.json" <<'JSON'
{
  "format_version": 2,
  "header": {
    "name": "OMF Hello",
    "description": "Join 時に一度だけ画面に案内を表示（Script API 不要）",
    "uuid": "e5b1ab3d-7c35-42be-8f3f-0b1e1a3b4c5d",
    "version": [1,0,0],
    "min_engine_version": [1,21,0]
  },
  "modules": [
    { "type": "data", "uuid": "a7f2f3e4-55a6-47b8-98a1-112233445566", "version": [1,0,0] }
  ]
}
JSON

# tellraw/title を一度だけ出す（タグで既読管理）
mkdir -p "$BP_DIR/functions/omf"
cat > "$BP_DIR/functions/omf/hello_tick.mcfunction" <<'MCF'
# 既に表示済みでないプレイヤーだけ対象
execute as @a[tag=!omf_hello_seen] run titleraw @s actionbar {"rawtext":[{"text":"§aOMF サーバーへようこそ！§r"}]}
execute as @a[tag=!omf_hello_seen] run tellraw @s {"rawtext":[{"text":"§7このメッセージは動作確認用（アドオン）です。§r"}]}
tag @a[tag=!omf_hello_seen] add omf_hello_seen
MCF

# 1tick ごとに hello_tick.mcfunction を実行
cat > "$BP_DIR/functions/tick.json" <<'JSON'
{
  "values": [
    "omf/hello_tick"
  ]
}
JSON

# BDS 本体取得／BP 反映（/data 直下の world_* を更新、worlds/world 側は削除）
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
d.append({"player":"SYSTEM","message":"サーバーが起動しました","timestamp":datetime.datetime.now().isoformat()})
d=d[-200:]
open(f,"w",encoding="utf-8").write(json.dumps(d,ensure_ascii=False))
PY

echo "[entry-bds] exec: box64 ./bedrock_server"
box64 ./bedrock_server 2>&1 | tee -a /data/bds_console.log
BASH
chmod +x "${DOCKER_DIR}/bds/"*.sh

# ------------------ monitor（/say & join/leave 監視 + allowlist/permissions 連携） ------------------
mkdir -p "${DOCKER_DIR}/monitor"
cat > "${DOCKER_DIR}/monitor/Dockerfile" <<'DOCK'
FROM python:3.11-slim
RUN apt-get update && apt-get install -y --no-install-recommends ca-certificates procps \
 && rm -rf /var/lib/apt/lists/*
WORKDIR /app
RUN pip install --no-cache-dir fastapi uvicorn pydantic
COPY monitor.py /app/monitor.py
EXPOSE 13900/tcp
CMD ["python","/app/monitor.py"]
DOCK

cat > "${DOCKER_DIR}/monitor/monitor.py" <<'PY'
import os, json, threading, time, re, datetime
from fastapi import FastAPI, Header, HTTPException
from pydantic import BaseModel
import uvicorn

DATA = "/data"
LOG  = os.path.join(DATA, "bedrock_server.log")  # /say はここに出る
CHAT = os.path.join(DATA, "chat.json")
PLAY = os.path.join(DATA, "players.json")
ALLOW = os.path.join(DATA, "allowlist.json")
PERM = os.path.join(DATA, "permissions.json")

API_TOKEN  = os.getenv("API_TOKEN", "")
SERVER_NAME= os.getenv("SERVER_NAME", "OMF")
MAX_CHAT   = 200
ALLOWLIST_AUTOADD = os.getenv("ALLOWLIST_AUTOADD","false").lower()=="true"
AUTH_CHEAT = os.getenv("AUTH_CHEAT","member")

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

def push_chat(player, message):
    with lock:
        j = jload(CHAT, [])
        j.append({"player": player, "message": str(message),
                  "timestamp": datetime.datetime.now().isoformat()})
        j = j[-MAX_CHAT:]
        jdump(CHAT, j)

def set_players(lst):
    with lock:
        jdump(PLAY, sorted(set(lst)))

def add_allow(name):
    with lock:
        names = [x.get("name") for x in jload(ALLOW, [])]
        if name not in names:
            arr = jload(ALLOW, [])
            arr.append({"name":name, "ignoresPlayerLimit": False})
            jdump(ALLOW, arr)

        # permissions.json にも重複なく追記
        perms = jload(PERM, [])
        if not any((p.get("xuid")==name) or (p.get("name")==name) for p in perms):
            # Bedrock Dedicated Server は name 指定でも許容される
            perms.append({"permission": AUTH_CHEAT, "name": name})
            jdump(PERM, perms)

RE_JOIN  = re.compile(r'Player connected:\s*([^,]+)')
RE_LEAVE = re.compile(r'Player disconnected:\s*([^,]+)')
RE_SAY1  = re.compile(r'\[Server\]\s*(.+)$')
RE_SAY2  = re.compile(r'\bServer:\s*(.+)$')

def tail_log():
    pos = 0
    known = set(jload(PLAY, []))
    while True:
        try:
            with open(LOG, "r", encoding="utf-8", errors="ignore") as f:
                f.seek(pos, os.SEEK_SET)
                while True:
                    line = f.readline()
                    if not line:
                        pos = f.tell()
                        time.sleep(0.2)
                        break
                    line = line.rstrip("\r\n")

                    m = RE_JOIN.search(line)
                    if m:
                        name = m.group(1).strip()
                        if name:
                            known.add(name); set_players(list(known))
                            push_chat("SYSTEM", f"{name} が参加")
                            if ALLOWLIST_AUTOADD:
                                add_allow(name)
                        continue
                    m = RE_LEAVE.search(line)
                    if m:
                        name = m.group(1).strip()
                        if name and name in known:
                            known.discard(name); set_players(list(known))
                            push_chat("SYSTEM", f"{name} が退出")
                        continue

                    m = RE_SAY1.search(line) or RE_SAY2.search(line)
                    if m:
                        msg = m.group(1).strip()
                        if msg:
                            push_chat("SERVER", msg)
                        continue
        except FileNotFoundError:
            time.sleep(0.5)
        except Exception:
            time.sleep(0.5)

class AnnounceIn(BaseModel):
    message: str

class AllowIn(BaseModel):
    name: str
    ignoresPlayerLimit: bool = False

@app.on_event("startup")
def _startup():
    for p,init in ((CHAT,[]),(PLAY,[]),(ALLOW,[]),(PERM,[])):
        if not os.path.exists(p): jdump(p, init)
    threading.Thread(target=tail_log, daemon=True).start()

@app.get("/health")
def health():
    return {"ok": True, "log_exists": os.path.exists(LOG), "ts": datetime.datetime.now().isoformat()}

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

@app.post("/announce")
def announce(body: AnnounceIn, x_api_key: str = Header(None)):
    if x_api_key != API_TOKEN: raise HTTPException(status_code=403, detail="Forbidden")
    msg = (body.message or "").trim() if hasattr(body.message,"trim") else (body.message or "").strip()
    if not msg: raise HTTPException(status_code=400, detail="Empty")
    push_chat("SERVER", msg)
    return {"status":"ok"}

@app.post("/allowlist/add")
def allow_add(body: AllowIn, x_api_key: str = Header(None)):
    if x_api_key != API_TOKEN: raise HTTPException(status_code=403, detail="Forbidden")
    name = (body.name or "").strip()
    if not name: raise HTTPException(status_code=400, detail="Empty name")
    add_allow(name)
    return {"ok": True, "count": len(jload(ALLOW, []))}

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=13900, log_level="info")
PY

# ------------------ web（簡易ポータル） ------------------
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
if [[ ! -f "${WEB_SITE_DIR}/index.html" ]]; then
  cat > "${WEB_SITE_DIR}/index.html" <<'HTML'
<!doctype html><html lang="ja"><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>OMF Portal</title>
<link rel="stylesheet" href="styles.css"><script defer src="main.js"></script>
<body>
<header><nav class="tabs"><button class="tab active" data-target="info">サーバー情報</button><button class="tab" data-target="chat">チャット</button><button class="tab" data-target="map">マップ</button></nav></header>
<main>
<section id="info" class="panel show"><h1>サーバー情報</h1><p>ようこそ！<strong id="sv-name"></strong></p><p>本番チャットは通常のゲーム内チャット、外部掲示は「送信」から。</p></section>
<section id="chat" class="panel">
  <div class="status-row"><span>現在接続中:</span><div id="players" class="pill-row"></div></div>
  <div class="chat-list" id="chat-list"></div>
  <form id="chat-form" class="chat-form"><input id="chat-input" type="text" placeholder="外部掲示メッセージ..." maxlength="200"/><button type="submit">送信</button></form>
</section>
<section id="map" class="panel"><div class="map-header">マップ</div><div class="map-frame"><iframe id="map-iframe" src="/map/index.html"></iframe></div></section>
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
const API="/api", TOKEN=localStorage.getItem("x_api_key")||"", SV=localStorage.getItem("server_name")||"OMF";
document.addEventListener("DOMContentLoaded", ()=>{
  document.getElementById("sv-name").textContent=SV;
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
      const r=await fetch(API+"/announce",{method:"POST",headers:{"Content-Type":"application/json","x-api-key":TOKEN},body:JSON.stringify({message:v})});
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
fi

# map 出力先プレースホルダ
mkdir -p "${DATA_DIR}/map"
if [[ ! -f "${DATA_DIR}/map/index.html" ]]; then
  echo '<!doctype html><meta charset="utf-8"><p>uNmINeD の Web 出力がここに作成されます。</p>' > "${DATA_DIR}/map/index.html"
fi

# ------------------ ビルド & 起動 ------------------
echo "[BUILD] images..."
sudo docker compose -f "${DOCKER_DIR}/compose.yml" build --no-cache

echo "[PREFETCH] BDS payload ..."
sudo docker run --rm -e TZ=Asia/Tokyo --entrypoint /usr/local/bin/get_bds.sh -v "${DATA_DIR}:/data" local/bds-box64:latest

echo "[UP] compose up -d ..."
sudo docker compose -f "${DOCKER_DIR}/compose.yml" up -d

cat <<MSG

== 確認 ==
curl -s -S "http://${MONITOR_BIND}:${MONITOR_PORT}/health" | jq .
curl -s -S -H "x-api-key: ${API_TOKEN}" "http://${MONITOR_BIND}:${MONITOR_PORT}/players" | jq .
curl -s -S -H "x-api-key: ${API_TOKEN}" "http://${MONITOR_BIND}:${MONITOR_PORT}/chat"    | jq .

== テスト用アドオン ==
- 「OMF Hello」BP が自動展開され、各プレイヤーに一度だけ画面表示します。
- /data/world_behavior_packs.json / /data/world_resource_packs.json のみ有効です。
  worlds/<name>/world_* は自動削除しています。

== 監視 ==
- join/leave と /say を bedrock_server.log から検知して /chat へ反映。
- ALLOWLIST_AUTOADD=true の場合は、初回参加名を allowlist.json と permissions.json に重複なく自動追記
  （permissions 権限は AUTH_CHEAT=${AUTH_CHEAT} を使用）

MSG

