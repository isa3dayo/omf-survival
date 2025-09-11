#!/usr/bin/env bash
# =====================================================================
# OMFS install_script.sh  (Bedrock 1.21.x 向け)
# - 既存 "手紙" アドオンを廃止（クラッシュ源を撤去）
# - 安定APIのみで「通常チャット→ /me」に変換（β不要 / OP不要）
# - bds_console.log / bedrock_server.log を tail して
#     * /me の本文を chat.json に記録（チャットログ）
#     * 入退室を players.json / chat.json に記録
#     * allowlist.json 自動追記（任意・既定 OFF）
# - world_behavior_packs.json / world_resource_packs.json を
#   /data と /data/worlds/world/ の両方へ出力（Pack Stack - None 回避）
# - 監視API: /health /players /chat に加え、/allowlist/add /allowlist/del を実装
# =====================================================================
set -euo pipefail

# ---- 変数 --------------------------------------------------------------
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

# ポート等
BDS_PORT_V4="${BDS_PORT_V4:-13922}"     # ゲームUDP
BDS_PORT_V6="${BDS_PORT_V6:-19132}"     # LAN
MONITOR_BIND="${MONITOR_BIND:-127.0.0.1}"
MONITOR_PORT="${MONITOR_PORT:-13900}"
WEB_BIND="${WEB_BIND:-0.0.0.0}"
WEB_PORT="${WEB_PORT:-13901}"
BDS_URL="${BDS_URL:-}"

echo "[INFO] OMFS start user=${USER_NAME} base=${BASE}"

# ---- スタック停止/掃除 ------------------------------------------------
echo "[CLEAN] stopping old stack..."
if [[ -f "${DOCKER_DIR}/compose.yml" ]]; then
  sudo docker compose -f "${DOCKER_DIR}/compose.yml" down --remove-orphans || true
fi
for c in bds bds-monitor bds-web logtail; do sudo docker rm -f "$c" >/dev/null 2>&1 || true; done
sudo docker system prune -f || true
sudo rm -rf "${DOCKER_DIR}/bds" "${DOCKER_DIR}/logtail" "${DOCKER_DIR}/monitor" "${DOCKER_DIR}/web" || true
mkdir -p "${DOCKER_DIR}" "${DATA_DIR}" "${BKP_DIR}" "${WEB_SITE_DIR}" "${TOOLS_DIR}"
sudo chown -R "${USER_NAME}:${USER_NAME}" "${OBJ}" || true

# ---- パッケージ --------------------------------------------------------
echo "[SETUP] apt..."
sudo apt-get update -y
sudo apt-get install -y --no-install-recommends ca-certificates curl wget jq unzip git tzdata xz-utils build-essential rsync procps

# ---- .env --------------------------------------------------------------
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
# allowlist自動追記（"true" で有効）。allow-list=true の場合、
# 初回接続は拒否 → 自動追記 → 再接続で入れる運用になります。
ALLOWLIST_ENROLL=false
ENV

# ---- compose -----------------------------------------------------------
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
      ALLOWLIST_ENROLL: \${ALLOWLIST_ENROLL}
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
      timeout: 5s
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

# ---- bds イメージ ------------------------------------------------------
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

# ---- get_bds.sh --------------------------------------------------------
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
# vanillaから allowlist.json / server.properties は上書きしない
unzip -qo bedrock-server.zip -x server.properties allowlist.json
rm -f bedrock-server.zip
log "updated BDS payload"
BASH

# ---- update_addons.py --------------------------------------------------
cat > "${DOCKER_DIR}/bds/update_addons.py" <<'PY'
import os, json, re
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
  world_dir=os.path.dirname(WWBP)
  if os.path.isdir(world_dir):
    write(WWBP,b); write(WWRP,r)
  else:
    print("[addons] WARN: world dir not found, skip world_* writes")
PY

# ---- entry-bds.sh ------------------------------------------------------
cat > "${DOCKER_DIR}/bds/entry-bds.sh" <<'BASH'
#!/usr/bin/env bash
set -euo pipefail
export TZ="${TZ:-Asia/Tokyo}"
cd /data; mkdir -p /data

# server.properties
if [ ! -f server.properties ]; then
  cat > server.properties <<PROP
server-name=${SERVER_NAME:-OMF}
gamemode=survival
difficulty=normal
allow-cheats=false
max-players=10
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

# 重要: allowlist.json / permissions.json / chat.json 初期化
[ -f allowlist.json ]   || echo "[]" > allowlist.json
[ -f permissions.json ] || echo "[]" > permissions.json
[ -f chat.json ]        || echo "[]" > chat.json
echo "[]" > /data/players.json || true

# ワールドディレクトリ（Pack Stack 用の world_* を出すため必要）
mkdir -p worlds/world/db
touch bedrock_server.log bds_console.log

# BDS 本体取得/更新
/usr/local/bin/get_bds.sh

# === ここが重要: 余計な旧アドオンを物理削除（クラッシュ対策） =========
# 以前の "手紙" 系アドオンを完全撤去
rm -rf /data/behavior_packs/omf_letter || true

# === チャット→ /me 変換アドオン（安定APIのみ） ============================
mkdir -p /data/behavior_packs/omf_mechat/scripts
cat > /data/behavior_packs/omf_mechat/manifest.json <<'JSON'
{
  "format_version": 2,
  "header": {
    "name": "OMF MeChat",
    "description": "Convert normal chat to /me for logging",
    "uuid": "a1a1f2f2-1b1b-4c4c-9d9d-1010101010aa",
    "version": [1,0,1],
    "min_engine_version": [1,21,0]
  },
  "modules": [
    {
      "type": "script",
      "language": "javascript",
      "entry": "scripts/main.js",
      "uuid": "b2b2c3c3-2d2d-4e4e-9f9f-2020202020bb",
      "version": [1,0,1]
    }
  ],
  "dependencies": [
    { "module_name": "@minecraft/server", "version": "1.11.0" }
  ]
}
JSON

cat > /data/behavior_packs/omf_mechat/scripts/main.js <<'JS'
import { world, system } from "@minecraft/server";

// 可能なら beforeEvents.chatSend でキャンセル＆変換。
// 使えない環境では afterEvents.chatSend にフォールバック（重複表示は許容）。
function sanitize(s){ try{ return String(s??"").replace(/\s+/g," ").trim().slice(0,200);}catch{ return ""; } }
function runAsMe(player, text){
  const name = sanitize(player?.name ?? "Player");
  const body = sanitize(text);
  if(!body) return;
  system.run(()=>{ try { player.runCommandAsync(`me ${name}: ${body}`); } catch {} });
}

try{
  if (world?.beforeEvents?.chatSend) {
    world.beforeEvents.chatSend.subscribe(ev=>{
      const msg = String(ev.message||"");
      if (!msg.startsWith("/")) { // コマンドはスルー
        runAsMe(ev.sender, msg);
        ev.cancel = true;        // 元チャットを消す
      }
    });
    console.warn("[OMF-MECHAT] using beforeEvents.chatSend");
  } else if (world?.afterEvents?.chatSend) {
    world.afterEvents.chatSend.subscribe(ev=>{
      const msg = String(ev.message||"");
      if (!msg.startsWith("/")) runAsMe(ev.sender, msg); // 元は残る
    });
    console.warn("[OMF-MECHAT] using afterEvents.chatSend (fallback)");
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

# ---- logtail: ログ→ chat.json / players.json / allowlist --------------
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

# 検知用
re_join = re.compile(r'INFO\] Player connected: ([^,]+),')
re_leave= re.compile(r'INFO\] Player disconnected: ([^,]+),')
# /me 行: 例 "INFO] * Steve: hello"
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
      add_chat("SYSTEM", f"{name} を allowlist に追加しました（再接続で入室可）", "system")

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

# ---- monitor: /players /chat + allowlist API ---------------------------
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
API_TOKEN=os.getenv("API_TOKEN","")
SERVER_NAME=os.getenv("SERVER_NAME","OMF")

PLAYERS_FILE=os.path.join(DATA,"players.json")
CHAT_FILE=os.path.join(DATA,"chat.json")
ALLOW_FILE=os.path.join(DATA,"allowlist.json")
MAX_CHAT=200

app=FastAPI()

def read_json(p,defv):
  try:
    with open(p,"r",encoding="utf-8") as f: return json.load(f)
  except Exception: return defv

def write_json(p,obj):
  tmp=p+".tmp"
  with open(tmp,"w",encoding="utf-8") as f: json.dump(obj,f,ensure_ascii=False)
  os.replace(tmp,p)

@app.get("/health")
def health():
  return {
    "ok": True,
    "files": { "chat": os.path.exists(CHAT_FILE), "players": os.path.exists(PLAYERS_FILE), "allowlist": os.path.exists(ALLOW_FILE) },
    "ts": datetime.datetime.now().isoformat()
  }

class AllowItem(BaseModel):
  name: str
  ignoresPlayerLimit: bool = False

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

@app.post("/allowlist/add")
def allow_add(item: AllowItem, x_api_key: str = Header(None)):
  if x_api_key != API_TOKEN: raise HTTPException(status_code=403, detail="Forbidden")
  al=read_json(ALLOW_FILE,[])
  if not any((isinstance(x,dict) and x.get("name")==item.name) for x in al):
    al.append({"ignoresPlayerLimit": item.ignoresPlayerLimit, "name": item.name})
    write_json(ALLOW_FILE, al)
  return {"ok":True,"count":len(al)}

@app.post("/allowlist/del")
def allow_del(item: AllowItem, x_api_key: str = Header(None)):
  if x_api_key != API_TOKEN: raise HTTPException(status_code=403, detail="Forbidden")
  al=[x for x in read_json(ALLOW_FILE,[]) if not (isinstance(x,dict) and x.get("name")==item.name)]
  write_json(ALLOW_FILE, al)
  return {"ok":True,"count":len(al)}

if __name__=="__main__":
  uvicorn.run(app, host="0.0.0.0", port=13900, log_level="info")
PY

# ---- web（最小UI） ----------------------------------------------------
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

  location / {
    root /usr/share/nginx/html;
    index index.html;
    try_files $uri $uri/ =404;
  }
}
NGX
mkdir -p "${WEB_SITE_DIR}"
cat > "${WEB_SITE_DIR}/index.html" <<'HTML'
<!doctype html><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>OMF Portal</title>
<style>
body{font-family:system-ui,Segoe UI,Roboto,Helvetica,Arial;margin:1rem;max-width:900px}
pre{background:#111;color:#0f0;padding:.5rem;border-radius:.25rem;overflow:auto}
.box{border:1px solid #ddd;border-radius:.5rem;padding:1rem;margin:.75rem 0}
.pill{display:inline-block;padding:.25rem .6rem;border:1px solid #ddd;border-radius:999px;margin:.15rem}
.chat{font-family:ui-monospace,Menlo,Consolas,monospace;border:1px solid #eee;background:#fafafa;border-radius:.5rem;padding:.5rem;height:40vh;overflow:auto}
</style>
<h1>OMF Portal</h1>
<div class="box"><h3>Players</h3><div id="players"></div></div>
<div class="box"><h3>Chat</h3><div id="chat" class="chat"></div></div>
<script>
const API="/api"; const TOKEN="__TOKEN__";
async function j(url){const r=await fetch(url,{headers:{"x-api-key":TOKEN}});if(!r.ok)return null;return r.json();}
async function refresh(){
  const p=await j(API+"/players"); const c=await j(API+"/chat");
  const pr=document.getElementById("players"); pr.innerHTML="";
  (p?.players||[]).forEach(n=>{const d=document.createElement("span");d.className="pill";d.textContent=n;pr.appendChild(d);});
  const cl=document.getElementById("chat"); cl.innerHTML="";
  (c?.latest||[]).forEach(m=>{const ts=(m.timestamp||'').replace('T',' ').slice(0,19); const div=document.createElement("div"); div.textContent=`[${ts}] ${m.player}: ${m.message}`; cl.appendChild(div);});
  cl.scrollTop=cl.scrollHeight;
}
refresh(); setInterval(refresh,5000);
</script>
HTML
# トークンを埋め込み（簡易UIのため）
sed -i "s/__TOKEN__/${API_TOKEN}/g" "${WEB_SITE_DIR}/index.html"

# ---- uNmINeD ダミー（必要に応じて後日） -------------------------------
mkdir -p "${DATA_DIR}/map"
if [[ ! -f "${DATA_DIR}/map/index.html" ]]; then
  echo '<!doctype html><meta charset="utf-8"><p>Map placeholder.</p>' > "${DATA_DIR}/map/index.html"
fi

# ---- ビルド & 起動 -----------------------------------------------------
echo "[BUILD] images..."
sudo docker compose -f "${DOCKER_DIR}/compose.yml" build --no-cache

echo "[PREFETCH] BDS payload ..."
sudo docker run --rm -e TZ=Asia/Tokyo --entrypoint /usr/local/bin/get_bds.sh -v "${DATA_DIR}:/data" local/bds-box64:latest

echo "[UP] compose up -d ..."
sudo docker compose -f "${DOCKER_DIR}/compose.yml" up -d

sleep 2
cat <<'MSG'

== 使い方 / チェック ==
1) 起動ヘルス:
   curl -sS http://127.0.0.1:13900/health | jq .
2) プレイヤー:
   curl -sS -H "x-api-key: ${API_TOKEN}" http://127.0.0.1:13900/players | jq .
3) チャット:
   curl -sS -H "x-api-key: ${API_TOKEN}" http://127.0.0.1:13900/chat | jq .

== allow-list=true の挙動について ==
- allowlist.json に未登録のプレイヤーは "最終的に" 入れません。
- 本構成では 2つの方法で登録可能です:
  (A) API 手動登録:
      curl -sS -H "x-api-key: ${API_TOKEN}" -H "content-type: application/json" \
        -d '{"name":"プレイヤー名","ignoresPlayerLimit":false}' \
        http://127.0.0.1:13900/allowlist/add | jq .
  (B) ログ監視による自動追記 (ALLOWLIST_ENROLL=true にした場合):
      初回接続試行時に名前をリストへ追記 → プレイヤーは一度拒否されます。
      **その後の再接続で入室可能** になります（BDS は起動時の読み込みが基本のため）。

※ 旧「手紙」アドオンは本スクリプトで物理削除済みです（クラッシュの芽を排除）。
※ チャットはプレイヤーの通常発言を /me "<name>: <text>" に変換 → BDS ログへ確実に出力。
   logtail がそれを抽出し /data/chat.json に蓄積します。
MSG

