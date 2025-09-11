#!/usr/bin/env bash
# =====================================================================
# OMFS (install_script.sh) — A案: Script API (Beta) でチャット取得
#  - Beta API 有効化（allow-experimental-gameplay=true）
#  - OMF Chat Logger (Beta) を自動配置し、[Scripting][OMFCHAT]{JSON} を出力
#  - monitor が bds_console.log を tail して chat.json / players.json を更新
#  - 既存ワールドで Beta が効かない場合は RESET_WORLD_FOR_BETA=true で新規生成
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

# ---- ベータ実験制御 ----
ALLOW_EXPERIMENTS="${ALLOW_EXPERIMENTS:-true}"   # server.properties: allow-experimental-gameplay
RESET_WORLD_FOR_BETA="${RESET_WORLD_FOR_BETA:-false}"  # 初回のみ、既存 world をバックアップして再生成

# ポート等
BDS_PORT_PUBLIC_V4="${BDS_PORT_PUBLIC_V4:-13922}"
BDS_PORT_V6="${BDS_PORT_V6:-19132}"
MONITOR_BIND="${MONITOR_BIND:-127.0.0.1}"
MONITOR_PORT="${MONITOR_PORT:-13900}"
WEB_BIND="${WEB_BIND:-0.0.0.0}"
WEB_PORT="${WEB_PORT:-13901}"
BDS_URL="${BDS_URL:-}"
ALL_CLEAN="${ALL_CLEAN:-false}"

echo "[INFO] OMFS start user=${USER_NAME} base=${BASE} ALL_CLEAN=${ALL_CLEAN} ALLOW_EXPERIMENTS=${ALLOW_EXPERIMENTS} RESET_WORLD_FOR_BETA=${RESET_WORLD_FOR_BETA}"

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
sudo apt-get install -y --no-install-recommends ca-certificates curl wget jq unzip git tzdata xz-utils build-essential python3 xterm rsync

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
ALLOW_EXPERIMENTS=${ALLOW_EXPERIMENTS}
ENV

# ------------------ compose ------------------
cat > "${DOCKER_DIR}/compose.yml" <<YAML
services:
  # ---- Bedrock Dedicated Server（box64 実行） ----
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
      ALLOW_EXPERIMENTS: \${ALLOW_EXPERIMENTS}
    volumes:
      - ../data:/data
    ports:
      - "\${BDS_PORT_PUBLIC_V4}:\${BDS_PORT_PUBLIC_V4}/udp"
      - "\${BDS_PORT_V6}:\${BDS_PORT_V6}/udp"
    restart: unless-stopped

  # ---- 監視 API（bds_console.log を tail し JSON へ反映） ----
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

# --- アドオン JSON 更新（世界の pack stack を生成） ---
cat > "${DOCKER_DIR}/bds/update_addons.py" <<'PY'
import os, json, re
ROOT="/data"
BP=os.path.join(ROOT,"behavior_packs")
RP=os.path.join(ROOT,"resource_packs")
WBP=os.path.join(ROOT,"worlds/world/world_behavior_packs.json")
WRP=os.path.join(ROOT,"worlds/world/world_resource_packs.json")

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
  os.makedirs(os.path.dirname(p), exist_ok=True)
  with open(p,"w",encoding="utf-8") as f:
    json.dump(items, f, indent=2, ensure_ascii=False)
  print(f"[addons] wrote {p} ({len(items)} packs)")

if __name__=="__main__":
  write(WBP,scan(BP,"data"))
  write(WRP,scan(RP,"resources"))
PY

# --- エントリ（BDS 起動） ---
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
content-log-file-name=bds_content.log
allow-experimental-gameplay=${ALLOW_EXPERIMENTS:-true}
PROP
else
  sed -i "s/^server-port=.*/server-port=${BDS_PORT_V4:-13922}/" server.properties
  sed -i "s/^server-portv6=.*/server-portv6=${BDS_PORT_V6:-19132}/" server.properties
  sed -i "s/^content-log-file-enabled=.*/content-log-file-enabled=true/" server.properties
  sed -i "s/^content-log-file-name=.*/content-log-file-name=bds_content.log/" server.properties
  sed -i "s/^allow-experimental-gameplay=.*/allow-experimental-gameplay=${ALLOW_EXPERIMENTS:-true}/" server.properties
fi

# 必要ディレクトリ
mkdir -p behavior_packs resource_packs worlds/world/db

# ---- OMF Chat Logger (Beta) を配置 ----
BP_DIR="behavior_packs/omf_chatlogger"
if [ ! -d "$BP_DIR" ]; then
  mkdir -p "$BP_DIR/scripts"
  cat > "$BP_DIR/manifest.json" <<'JSON'
{
  "format_version": 2,
  "header": {
    "name": "OMF Chat Logger",
    "description": "Chat/Join/Leave/Death -> console JSON",
    "uuid": "8f6e9a32-bb0b-47df-8f0e-12b7df0e3d77",
    "version": [1,0,0],
    "min_engine_version": [1,21,0]
  },
  "modules": [
    {
      "type": "script",
      "language": "javascript",
      "entry": "scripts/main.js",
      "uuid": "b1f8c0b7-1b4a-4e4a-9b8b-e6f8f0b1d0e1",
      "version": [1,0,0]
    }
  ],
  "dependencies": [
    { "module_name": "@minecraft/server",    "version": "1.13.0-beta" }
  ]
}
JSON
  cat > "$BP_DIR/scripts/main.js" <<'JS'
// OMF Chat Logger (Beta API)
// 出力形式: [Scripting] [OMFCHAT] {"type":"chat","name":"...","message":"..."}

import { world, system, Player, EntityHurtAfterEvent, EntityDieAfterEvent } from "@minecraft/server";

const log = (obj) => console.warn(`[OMFCHAT] ${JSON.stringify(obj)}`);

// ---- チャット ----
try {
  world.afterEvents.chatSend.subscribe(ev => {
    try {
      if (!ev?.sender || typeof ev.message !== "string") return;
      const name = ev.sender.name ?? "Unknown";
      log({ type: "chat", name, message: ev.message });
    } catch {}
  });
} catch {
  log({ type: "system", message: "chat hook NOT available" });
}

// ---- 参加/退出 ----
try {
  world.afterEvents.playerSpawn.subscribe(ev => {
    try {
      const p = ev.player; if (!p) return;
      // 初回スポーン時のみ「join」相当
      if (ev.initialSpawn === true) log({ type: "join", name: p.name });
    } catch {}
  });
} catch {}

try {
  world.afterEvents.playerLeave.subscribe(ev => {
    try { if (ev?.playerName) log({ type: "leave", name: ev.playerName }); } catch {}
  });
} catch {}

// ---- 死亡（対応 API がある場合） ----
try {
  world.afterEvents.entityDie.subscribe(ev => {
    try {
      const e = ev?.deadEntity;
      if (e?.typeId === "minecraft:player") {
        // deathMessage は API 側に未定義の可能性があるので極力安全に
        log({ type: "death", name: e.name ?? "Unknown", message: "died" });
      }
    } catch {}
  });
} catch {
  // entityDie が無い場合は Health 監視で補完はしない（誤検知が多いため）
}

// ---- 定期: プレイヤー一覧（冪等）
system.runInterval(() => {
  try {
    const list = [...world.getPlayers()].map(p => p.name);
    log({ type: "players", list });
  } catch {}
}, 100);
JS
fi

# BDS バイナリ展開
/usr/local/bin/get_bds.sh

# world_*_packs.json を反映
python3 /usr/local/bin/update_addons.py || true

# 既存ワールドをベータ前提でリセット（必要なときのみ）
if [ "${ALLOW_EXPERIMENTS:-true}" = "true" ] && [ "${RESET_WORLD_FOR_BETA:-false}" = "true" ]; then
  if [ -d worlds/world/db ]; then
    ts="$(date +%Y%m%d-%H%M%S)"
    mkdir -p "/data/backups"
    tar czf "/data/backups/world_before_beta_${ts}.tgz" worlds/world || true
    rm -rf worlds/world/db
    mkdir -p worlds/world/db
    echo "[entry-bds] world reset for Beta (backup: /data/backups/world_before_beta_${ts}.tgz)"
  fi
fi

# 起動案内
[ -f chat.json ] || echo "[]" > chat.json
[ -f players.json ] || echo "[]" > players.json
touch bds_console.log bedrock_server.log

echo "[entry-bds] exec: box64 ./bedrock_server"
box64 ./bedrock_server 2>&1 | tee -a /data/bds_console.log
BASH
chmod +x "${DOCKER_DIR}/bds/"*.sh

# ------------------ monitor（bds_console.log を tail） ------------------
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
import uvicorn

DATA="/data"
LOG=os.path.join(DATA,"bds_console.log")
CHAT=os.path.join(DATA,"chat.json")
PLAY=os.path.join(DATA,"players.json")
API_TOKEN=os.getenv("API_TOKEN","")
SERVER_NAME=os.getenv("SERVER_NAME","OMF")

app=FastAPI()
lock=threading.Lock()
MAX_CHAT=100

def jload(p, d):
  try:
    with open(p,"r",encoding="utf-8") as f: return json.load(f)
  except: return d

def jdump(p, obj):
  tmp=p+".tmp"
  with open(tmp,"w",encoding="utf-8") as f: json.dump(obj,f,ensure_ascii=False)
  os.replace(tmp,p)

def push_chat(player, message):
  with lock:
    j=jload(CHAT,[])
    j.append({"player":player,"message":message,"timestamp":datetime.datetime.now().isoformat()})
    j=j[-MAX_CHAT:]
    jdump(CHAT,j)

def set_players(lst):
  with lock:
    jdump(PLAY, sorted(set(lst)))

# 形式: ... [Scripting] [OMFCHAT] {json}
RE_LINE=re.compile(r'\[Scripting\]\s+\[OMFCHAT\]\s+(\{.*\})\s*$')

def tailer():
  # 初回はファイル末尾へ
  pos=0
  while True:
    try:
      with open(LOG,"r",encoding="utf-8",errors="ignore") as f:
        f.seek(pos)
        while True:
          line=f.readline()
          if not line:
            pos=f.tell()
            time.sleep(0.2)
            break
          m=RE_LINE.search(line)
          if not m:
            continue
          try:
            obj=json.loads(m.group(1))
            typ=obj.get("type")
            if typ=="chat":
              push_chat(obj.get("name",""), obj.get("message",""))
            elif typ=="join":
              push_chat("SYSTEM", f"{obj.get('name','')} が参加")
              cur=jload(PLAY,[])
              cur.append(obj.get("name",""))
              set_players(cur)
            elif typ=="leave":
              push_chat("SYSTEM", f"{obj.get('name','')} が退出")
              cur=set(jload(PLAY,[]))
              cur.discard(obj.get("name",""))
              set_players(list(cur))
            elif typ=="death":
              push_chat("DEATH", f"{obj.get('name','')}: {obj.get('message','死亡')}")
            elif typ=="players":
              set_players(obj.get("list",[]))
            elif typ=="system":
              push_chat("SYSTEM", obj.get("message",""))
          except Exception:
            pass
    except FileNotFoundError:
      time.sleep(0.5)
    except Exception:
      time.sleep(0.5)

@app.on_event("startup")
def _startup():
  threading.Thread(target=tailer, daemon=True).start()

@app.get("/health")
def health():
  return {"ok":True,"log_exists":os.path.exists(LOG),"ts":datetime.datetime.now().isoformat()}

@app.get("/players")
def players(x_api_key: str = Header(None)):
  if x_api_key != API_TOKEN: raise HTTPException(status_code=403, detail="Forbidden")
  return {"server":SERVER_NAME,"players":jload(PLAY,[]),"timestamp":datetime.datetime.now().isoformat()}

@app.get("/chat")
def chat(x_api_key: str = Header(None)):
  if x_api_key != API_TOKEN: raise HTTPException(status_code=403, detail="Forbidden")
  j=jload(CHAT,[])
  return {"server":SERVER_NAME,"latest":j[-MAX_CHAT:],"count":len(j),
          "timestamp":datetime.datetime.now().isoformat()}

if __name__=="__main__":
  uvicorn.run(app, host="0.0.0.0", port=13900, log_level="info")
PY

# ------------------ web（見出しを「昨日までのマップデータ」に固定） ------------------
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
  <form id="chat-form" class="chat-form" onsubmit="return false;">
    <input id="chat-input" type="text" placeholder="閲覧専用（送信は未対応）" disabled />
    <button type="button" disabled>送信</button>
  </form>
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
  const refresh = async()=>{
    try{
      const pr = await fetch(API+"/players",{headers:{"x-api-key":TOKEN}}); 
      const cr = await fetch(API+"/chat",{headers:{"x-api-key":TOKEN}});
      if(pr.ok){
        const d=await pr.json(); const row=document.getElementById("players"); row.innerHTML="";
        (d.players||[]).forEach(n=>{ const el=document.createElement("div"); el.className="pill"; el.textContent=n; row.appendChild(el); });
      }
      if(cr.ok){
        const d=await cr.json(); const list=document.getElementById("chat-list"); list.innerHTML="";
        (d.latest||[]).forEach(m=>{ const el=document.createElement("div"); el.className="chat-item"; el.textContent=`[${(m.timestamp||'').replace('T',' ').slice(0,19)}] ${m.player}: ${m.message}`; list.appendChild(el); });
        list.scrollTop=list.scrollHeight;
      }
    }catch(_){}
  };
  refresh(); setInterval(refresh, 3000);
});
JS

# map 置き場の案内
mkdir -p "${DATA_DIR}/map"
if [[ ! -f "${DATA_DIR}/map/index.html" ]]; then
  echo '<!doctype html><meta charset="utf-8"><p>uNmINeD の Web 出力がここに作成されます。</p>' > "${DATA_DIR}/map/index.html"
fi

# ------------------ uNmINeD 自動DL & web render（あなたの成功版と同じ方式） ------------------
cat > "${BASE}/update_map.sh" <<'BASH'
#!/usr/bin/env bash
# uNmINeD Web マップ更新 (ARM64 glibc 専用) — あなたの安定版を反映
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
  local url="$1"
  local tmp ext ctype root
  tmp="$(mktemp -d)"
  log "downloading: ${url}"
  curl -fL --retry 3 --retry-delay 2 -D "$tmp/headers" -o "$tmp/pkg" "$url"
  if command -v file >/dev/null 2>&1; then
    if file "$tmp/pkg" | grep -qi 'Zip archive data'; then ext="zip"
    elif file "$tmp/pkg" | grep -qi 'gzip compressed data'; then ext="tgz"
    else
      ctype="$(awk 'BEGIN{IGNORECASE=1}/^Content-Type:/{print $2}' "$tmp/headers" | tr -d '\r' || true)"
      case "${ctype:-}" in application/zip) ext="zip" ;; application/gzip|application/x-gzip|application/x-tgz) ext="tgz" ;; *) ext="unknown";; esac
    fi
  else
    ctype="$(awk 'BEGIN{IGNORECASE=1}/^Content-Type:/{print $2}' "$tmp/headers" | tr -d '\r' || true)"
    case "${ctype:-}" in application/zip) ext="zip" ;; application/gzip|application/x-gzip|application/x-tgz) ext="tgz" ;; *) ext="unknown";; esac
  fi
  mkdir -p "$tmp/x"
  case "$ext" in
    tgz) tar xzf "$tmp/pkg" -C "$tmp/x" ;;
    zip) unzip -qo "$tmp/pkg" -d "$tmp/x" ;;
    *) log "ERROR: unsupported archive format"; rm -rf "$tmp"; return 1 ;;
  esac
  root="$(find "$tmp/x" -maxdepth 2 -type d -name 'unmined-cli*' | head -n1 || true)"; [ -n "$root" ] || root="$tmp/x"
  if [ ! -f "$root/unmined-cli" ]; then root="$(dirname "$(find "$tmp/x" -type f -name 'unmined-cli' | head -n1 || true)")"; fi
  [ -n "$root" ] && [ -f "$root/unmined-cli" ] || { log "ERROR: unmined-cli not found in archive"; rm -rf "$tmp"; return 1; }
  mkdir -p "${TOOLS}"; rsync -a "$root"/ "${TOOLS}/" 2>/dev/null || cp -rf "$root"/ "${TOOLS}/"
  chmod +x "${BIN}"; rm -rf "$tmp"
  if [ ! -f "${TPL_ZIP}" ]; then
    if [ -d "${TPL_DIR}" ] && [ -f "${TPL_DIR}/default.web.template.zip" ]; then :; else
      log "ERROR: templates/default.web.template.zip missing in package"; return 1
    fi
  fi
  return 0
}

render_map(){
  log "rendering web map from: ${WORLD}"
  mkdir -p "${OUT}"; pushd "${TOOLS}" >/dev/null
  if [ ! -f "${CFG_DIR}/blocktags.js" ]; then
    mkdir -p "${CFG_DIR}"
    cat > "${CFG_DIR}/blocktags.js" <<'JS'
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
  else
    log "uNmINeD CLI already installed"
  fi
  if render_map; then log "done -> ${OUT}"; else log "ERROR: render failed"; exit 1; fi
}
main "$@"
BASH
chmod +x "${BASE}/update_map.sh"

# ------------------ ビルド & 起動 ------------------
echo "[BUILD] images..."
sudo docker compose -f "${DOCKER_DIR}/compose.yml" build --no-cache

echo "[PREFETCH] BDS payload ..."
sudo docker run --rm -e TZ=Asia/Tokyo --entrypoint /usr/local/bin/get_bds.sh -v "${DATA_DIR}:/data" local/bds-box64:latest

echo "[UP] compose up -d ..."
sudo docker compose -f "${DOCKER_DIR}/compose.yml" up -d

sleep 2
cat <<MSG

== 使い方 ==
1) ベータ API の有効化が反映されない場合は、key.conf か環境変数で
   RESET_WORLD_FOR_BETA=true を指定してから本スクリプトを再実行してください
   （既存 world を backups/ に退避したうえで新規生成します）

2) 動作確認（ログ/プレイヤー/チャット）
   curl -s -S "http://${MONITOR_BIND}:${MONITOR_PORT}/health" | jq .
   curl -s -S -H "x-api-key: ${API_TOKEN}" "http://${MONITOR_BIND}:${MONITOR_PORT}/players" | jq .
   curl -s -S -H "x-api-key: ${API_TOKEN}" "http://${MONITOR_BIND}:${MONITOR_PORT}/chat"    | jq .

3) マップ更新
   ${BASE}/update_map.sh

※ ベータ API は将来破壊的変更の可能性があります。不安定になった場合は
   ALLOW_EXPERIMENTS=false にしてチャット取得を諦めるのが安全です。
MSG

