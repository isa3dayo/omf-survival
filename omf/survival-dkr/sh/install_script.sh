#!/usr/bin/env bash
# =====================================================================
# OMFS installer — stable log-based chat & join/leave (no addons)
#  - アドオンは使わず、BDSログから入退室と /say を取得
#  - allowlist.json を自動生成＆入室時に未登録なら追記
#  - 任意で OP 自動付与（OP_AUTO=true）→ permissions.json を更新
#  - world_*packs.json は /data と /data/worlds/<level>/ に同期（Pack Stack None対策）
# =====================================================================
set -euo pipefail

USER_NAME="${SUDO_USER:-$USER}"
HOME_DIR="$(getent passwd "$USER_NAME" | cut -d: -f6)"
BASE="${HOME_DIR}/omf/survival-dkr"
OBJ="${BASE}/obj"
DOCKER_DIR="${OBJ}/docker}"
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

BDS_PORT_PUBLIC_V4="${BDS_PORT_PUBLIC_V4:-13922}"
BDS_PORT_V6="${BDS_PORT_V6:-19132}"
MONITOR_BIND="${MONITOR_BIND:-127.0.0.1}"
MONITOR_PORT="${MONITOR_PORT:-13900}"
WEB_BIND="${WEB_BIND:-0.0.0.0}"
WEB_PORT="${WEB_PORT:-13901}"
BDS_URL="${BDS_URL:-}"
ALL_CLEAN="${ALL_CLEAN:-false}"
# 入室検知時に自動で OP 付与するか（true/false）
OP_AUTO="${OP_AUTO:-false}"

echo "[INFO] OMFS start user=${USER_NAME} base=${BASE} ALL_CLEAN=${ALL_CLEAN} OP_AUTO=${OP_AUTO}"

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
OP_AUTO=${OP_AUTO}
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
      BDS_PORT_V4: \${BDS_PORT_PUBLIC_V4}
      BDS_PORT_V6: \${BDS_PORT_V6}
    volumes:
      - ../data:/data
    ports:
      - "\${BDS_PORT_PUBLIC_V4}:\${BDS_PORT_PUBLIC_V4}/udp"
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
      API_TOKEN: \${API_TOKEN}
      OP_AUTO: \${OP_AUTO}
    volumes:
      - ../data:/data
    ports:
      - "${MONITOR_BIND}:${MONITOR_PORT}:13900/tcp"
    depends_on:
      bds:
        condition: service_started
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

# --- Addons 反映（Pack Stack None 対策：/data と worlds/<level> 両方に書く） ---
cat > "${DOCKER_DIR}/bds/update_addons.py" <<'PY'
import os, json, re

ROOT = "/data"
BP   = os.path.join(ROOT,"behavior_packs")
RP   = os.path.join(ROOT,"resource_packs")

def _load_lenient(p):
  s=open(p,"r",encoding="utf-8").read()
  s=re.sub(r'//.*','',s); s=re.sub(r'/\*.*?\*/','',s,flags=re.S); s=re.sub(r',\s*([}\]])',r'\1',s)
  return json.loads(s)

def scan_packs(dirpath, tp):
  out=[]
  if not os.path.isdir(dirpath): return out
  for name in sorted(os.listdir(dirpath)):
    p=os.path.join(dirpath,name); mf=os.path.join(p,"manifest.json")
    if not (os.path.isdir(p) and os.path.isfile(mf)): continue
    try:
      mfj=_load_lenient(mf)
      uuid=mfj["header"]["uuid"]; ver=mfj["header"]["version"]
      if not(isinstance(ver,list) and len(ver)==3): raise ValueError("bad version")
      out.append({"pack_id":uuid,"version":ver,"type":tp})
      print(f"[addons] {tp} {name} {uuid} {ver}")
    except Exception as e:
      print(f"[addons] skip {name}: {e}")
  return out

def write_json(p, data):
  os.makedirs(os.path.dirname(p), exist_ok=True)
  with open(p,"w",encoding="utf-8") as f:
    json.dump(data,f,ensure_ascii=False,indent=2)
  print(f"[addons] wrote {p} ({len(data)} entries)")

def get_level_name():
  sp=os.path.join(ROOT,"server.properties")
  lv="world"
  try:
    with open(sp,"r",encoding="utf-8") as f:
      for ln in f:
        if ln.startswith("level-name="):
          lv=ln.strip().split("=",1)[1] or "world"
          break
  except: pass
  return lv

if __name__=="__main__":
  bp=scan_packs(BP,"data")
  rp=scan_packs(RP,"resources")
  write_json(os.path.join(ROOT,"world_behavior_packs.json"), bp)
  write_json(os.path.join(ROOT,"world_resource_packs.json"), rp)
  level=get_level_name()
  wdir=os.path.join(ROOT,"worlds",level)
  os.makedirs(wdir,exist_ok=True)
  write_json(os.path.join(wdir,"world_behavior_packs.json"), bp)
  write_json(os.path.join(wdir,"world_resource_packs.json"), rp)
PY

# --- エントリ：必須ファイル作成、OPはここでは付与しない（monitor側で任意付与） ---
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
PROP
else
  sed -i "s/^server-port=.*/server-port=${BDS_PORT_V4:-13922}/" server.properties
  sed -i "s/^server-portv6=.*/server-portv6=${BDS_PORT_V6:-19132}/" server.properties
  sed -i "s/^allow-cheats=.*/allow-cheats=true/" server.properties
  sed -i "s/^content-log-file-enabled=.*/content-log-file-enabled=true/" server.properties
  sed -i "s/^content-log-file-name=.*/content-log-file-name=content.log/" server.properties
fi

# 初期ファイル
[ -f allowlist.json ] || echo "[]" > allowlist.json
[ -f permissions.json ] || echo "[]" > permissions.json
[ -f chat.json ] || echo "[]" > chat.json
echo "[]" > players.json || true
touch bedrock_server.log bds_console.log

# BDS 本体取得
/usr/local/bin/get_bds.sh

# Addons 反映（Pack Stack None 対策）
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

# ------------------ monitor（入退室 & /say 取得 + allowlist/OP 自動更新） ------------------
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
LOGS = [os.path.join(DATA, "bedrock_server.log"), os.path.join(DATA, "bds_console.log")]
CHAT = os.path.join(DATA, "chat.json")
PLAY = os.path.join(DATA, "players.json")
ALLOW= os.path.join(DATA, "allowlist.json")
PERMS= os.path.join(DATA, "permissions.json")

API_TOKEN  = os.getenv("API_TOKEN", "")
SERVER_NAME= os.getenv("SERVER_NAME", "OMF")
MAX_CHAT   = 200
OP_AUTO    = (os.getenv("OP_AUTO","false").lower()=="true")

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
        j.append({"player": player, "message": str(message), "timestamp": datetime.datetime.now().isoformat()})
        j = j[-MAX_CHAT:]
        jdump(CHAT, j)

def set_players(lst):
    with lock:
        jdump(PLAY, sorted(set(lst)))

def upsert_allowlist(name, xuid):
    with lock:
        arr = jload(ALLOW, [])
        if not any(str(e.get("xuid"))==str(xuid) for e in arr):
            arr.append({"ignoresPlayerInvite": False, "name": name, "xuid": str(xuid)})
            jdump(ALLOW, arr)

def grant_op(xuid):
    with lock:
        arr = jload(PERMS, [])
        if not any(str(e.get("xuid"))==str(xuid) for e in arr):
            arr.append({"permission":"operator","xuid":str(xuid)})
            jdump(PERMS, arr)

RE_JOIN   = re.compile(r'Player connected:\s*([^,]+),\s*xuid:\s*([0-9]+)')
RE_LEAVE  = re.compile(r'Player disconnected:\s*([^,]+),\s*xuid:\s*([0-9]+)')
RE_SAY1   = re.compile(r'\[Server\]\s*(.+)$')   # [Server] Hello
RE_SAY2   = re.compile(r'\bServer:\s*(.+)$')    # ... Server: Hello

def tail_many(paths):
    poss = {p:0 for p in paths}
    players = set(jload(PLAY, []))
    while True:
        for p in paths:
            try:
                with open(p, "r", encoding="utf-8", errors="ignore") as f:
                    f.seek(poss[p], os.SEEK_SET)
                    while True:
                        line = f.readline()
                        if not line:
                            poss[p] = f.tell()
                            break
                        line = line.rstrip("\r\n")

                        m = RE_JOIN.search(line)
                        if m:
                            name = m.group(1).strip(); xuid = m.group(2).strip()
                            if name:
                                players.add(name); set_players(list(players))
                                upsert_allowlist(name, xuid)
                                if OP_AUTO: grant_op(xuid)
                                push_chat("SYSTEM", f"{name} が入室しました")
                            continue
                        m = RE_LEAVE.search(line)
                        if m:
                            name = m.group(1).strip()
                            if name and name in players:
                                players.discard(name); set_players(list(players))
                                push_chat("SYSTEM", f"{name} が退出しました")
                            continue

                        m = RE_SAY1.search(line) or RE_SAY2.search(line)
                        if m:
                            msg = m.group(1).strip()
                            if msg:
                                push_chat("SERVER", msg)
                            continue
            except FileNotFoundError:
                pass
            except Exception:
                pass
        time.sleep(0.2)

class AnnounceIn(BaseModel):
    message: str

@app.on_event("startup")
def _startup():
    for p,ini in [(CHAT,[]),(PLAY,[]),(ALLOW,[]),(PERMS,[])]:
        if not os.path.exists(p): jdump(p, ini)
    threading.Thread(target=tail_many, args=(LOGS,), daemon=True).start()

@app.get("/health")
def health():
    return {"ok": True, "logs": {p: os.path.exists(p) for p in LOGS}, "ts": datetime.datetime.now().isoformat()}

@app.get("/players")
def players(x_api_key: str = Header(None)):
    if x_api_key != API_TOKEN: raise HTTPException(status_code=403, detail="Forbidden")
    return {"server": SERVER_NAME, "players": jload(PLAY, []), "timestamp": datetime.datetime.now().isoformat()}

@app.get("/chat")
def chat(x_api_key: str = Header(None)):
    if x_api_key != API_TOKEN: raise HTTPException(status_code=403, detail="Forbidden")
    j = jload(CHAT, [])
    return {"server": SERVER_NAME, "latest": j[-MAX_CHAT:], "count": len(j), "timestamp": datetime.datetime.now().isoformat()}

@app.post("/announce")
def announce(body: AnnounceIn, x_api_key: str = Header(None)):
    if x_api_key != API_TOKEN: raise HTTPException(status_code=403, detail="Forbidden")
    msg = (body.message or "").trim() if hasattr(str,"trim") else (body.message or "").strip()
    if not msg: raise HTTPException(status_code=400, detail="Empty")
    push_chat("SERVER", msg)
    return {"status":"ok"}

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=13900, log_level="info")
PY

# ------------------ web（簡易UI・据え置き） ------------------
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
<section id="info" class="panel show"><h1>サーバー情報</h1><p>ようこそ！<strong id="sv-name"></strong></p><p>外部告知は Web から送信すると <code>SERVER:</code> として表示されます。</p></section>
<section id="chat" class="panel">
  <div class="status-row"><span>現在接続中:</span><div id="players" class="pill-row"></div></div>
  <div class="chat-list" id="chat-list"></div>
  <form id="chat-form" class="chat-form"><input id="chat-input" type="text" placeholder="メッセージ（外部告知）..." maxlength="200"/><button type="submit">送信</button></form>
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

== 重要ポイント ==
- アドオンは撤去（最新スキーマの変更でクラッシュ要因のため）
- 入退室は bds_console.log/bedrock_server.log を監視し、/chat に
  「<名前> が入室/退出しました」を記録
- 「Player connected: <name>, xuid: <id>」検知で allowlist.json に未登録なら自動追記
- OP 自動付与：key.conf に OP_AUTO=true を入れると、入室時に permissions.json に operator を自動追記
- /say は BDS ログの「[Server] ... / Server: ...」形式を収集（外部からは /api/announce）

MSG

