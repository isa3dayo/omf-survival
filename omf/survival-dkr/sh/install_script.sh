#!/usr/bin/env bash
# =====================================================================
# OMFS installer（完全版：ホストaddonsを確実反映）
#  - ホスト: ~/omf/survival-dkr/{behavior,resource} を bds にROマウント
#  - update_addons.py がホスト→/dataへ同期し world_*_packs.json を再生成
#  - /chat（サーバー内 say）と /webchat（Webのみ）を両立
#  - 座標常時表示/一人寝: FIFO へ /gamerule 投入
#  - BDS: 起動毎に最新URL確認→失敗なら現状維持
#  - uNmINeD: downloads をスクレイピングして ARM64 glibc を導入
#  - バックアップ: BASE/backups（ALL_CLEAN 対象外）、addons含む/除くを選択
# =====================================================================
set -euo pipefail

# ---------- パス / 変数 ----------
USER_NAME="${SUDO_USER:-$USER}"
HOME_DIR="$(getent passwd "$USER_NAME" | cut -d: -f6)"
BASE="${HOME_DIR}/omf/survival-dkr"
OBJ="${BASE}/obj"
DOCKER_DIR="${OBJ}/docker"
DATA_DIR="${OBJ}/data"
BKP_DIR="${BASE}/backups"         # ★ ALL_CLEAN 対象外
WEB_SITE_DIR="${DOCKER_DIR}/web/site"
TOOLS_DIR="${OBJ}/tools"
KEY_FILE="${BASE}/key/key.conf"

# ホストのアドオン配置
HOST_BEHAVIOR="${BASE}/behavior"
HOST_RESOURCE="${BASE}/resource"

mkdir -p "${DOCKER_DIR}" "${DATA_DIR}" "${BKP_DIR}" "${WEB_SITE_DIR}" "${TOOLS_DIR}" \
         "${HOST_BEHAVIOR}" "${HOST_RESOURCE}"
sudo chown -R "${USER_NAME}:${USER_NAME}" "${BASE}" || true

[[ -f "${KEY_FILE}" ]] || { echo "[ERR] key.conf が見つかりません: ${KEY_FILE}"; exit 1; }
# shellcheck disable=SC1090
source "${KEY_FILE}"

# 必須キー
: "${SERVER_NAME:?SERVER_NAME を key.conf に設定してください}"
: "${API_TOKEN:?API_TOKEN を key.conf に設定してください}"
: "${GAS_URL:?GAS_URL を key.conf に設定してください}"

# 任意キー（既定値）
BDS_PORT_PUBLIC_V4="${BDS_PORT_PUBLIC_V4:-13922}"
BDS_PORT_V6="${BDS_PORT_V6:-19132}"
MONITOR_BIND="${MONITOR_BIND:-127.0.0.1}"
MONITOR_PORT="${MONITOR_PORT:-13900}"
WEB_BIND="${WEB_BIND:-0.0.0.0}"
WEB_PORT="${WEB_PORT:-13901}"
BDS_URL="${BDS_URL:-}"                 # 空なら API から自動
ALL_CLEAN="${ALL_CLEAN:-false}"

# 認証/許可
ALLOWLIST_ON="${ALLOWLIST_ON:-true}"
ALLOWLIST_AUTOADD="${ALLOWLIST_AUTOADD:-true}"
ONLINE_MODE="${ONLINE_MODE:-true}"
AUTH_CHEAT="${AUTH_CHEAT:-member}"
SEED_POINT="${SEED_POINT:-}"
BETA_ON="${BETA_ON:-false}"

echo "[INFO] OMFS start user=${USER_NAME} base=${BASE} ALL_CLEAN=${ALL_CLEAN}"

# ---------- 既存 stack 停止/掃除（バックアップは消さない） ----------
echo "[CLEAN] stopping old stack..."
if [[ -f "${DOCKER_DIR}/compose.yml" ]]; then
  sudo docker compose -f "${DOCKER_DIR}/compose.yml" down --remove-orphans || true
fi
for c in bds bds-monitor bds-web; do sudo docker rm -f "$c" >/dev/null 2>&1 || true; done
if [[ "${ALL_CLEAN}" == "true" ]]; then
  sudo docker system prune -a -f || true
  rm -rf "${OBJ}"                 # ★ obj だけ削除
else
  sudo docker system prune -f || true
fi
mkdir -p "${DOCKER_DIR}" "${DATA_DIR}" "${BKP_DIR}" "${WEB_SITE_DIR}" "${TOOLS_DIR}"
sudo chown -R "${USER_NAME}:${USER_NAME}" "${OBJ}" || true

# ---------- ホスト依存 ----------
echo "[SETUP] apt..."
sudo apt-get update -y
sudo apt-get install -y --no-install-recommends ca-certificates curl wget jq unzip git tzdata xz-utils rsync python3 build-essential

# ---------- .env ----------
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
ALLOWLIST_ON=${ALLOWLIST_ON}
ALLOWLIST_AUTOADD=${ALLOWLIST_AUTOADD}
ONLINE_MODE=${ONLINE_MODE}
AUTH_CHEAT=${AUTH_CHEAT}
BETA_ON=${BETA_ON}
# ★ ホストアドオンの絶対パスを渡す
HOST_BEHAVIOR=${HOST_BEHAVIOR}
HOST_RESOURCE=${HOST_RESOURCE}
ENV

# ---------- docker compose ----------
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
      ALLOWLIST_ON: \${ALLOWLIST_ON}
      ONLINE_MODE: \${ONLINE_MODE}
      BETA_ON: \${BETA_ON}
    volumes:
      - ../data:/data
      # ★ ホストの addons を RO マウント
      - \${HOST_BEHAVIOR}:/host_behavior:ro
      - \${HOST_RESOURCE}:/host_resource:ro
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

# ---------- bds image ----------
mkdir -p "${DOCKER_DIR}/bds"

cat > "${DOCKER_DIR}/bds/Dockerfile" <<'DOCK'
FROM debian:bookworm-slim
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates curl wget unzip jq xz-utils procps build-essential git cmake ninja-build python3 rsync \
 && rm -rf /var/lib/apt/lists/*

# box64（x86_64 BDS を ARM 等で実行）
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

# --- BDS 取得（失敗時はスキップして既存維持） ---
cat > "${DOCKER_DIR}/bds/get_bds.sh" <<'BASH'
#!/usr/bin/env bash
set -euo pipefail
mkdir -p /data
cd /data
log(){ echo "[get_bds] $*" >&2; }

API="https://net-secondary.web.minecraft-services.net/api/v1.0/download/links"
get_url_api(){
  curl --http1.1 -fsSL -H 'Accept: application/json' --retry 3 --retry-delay 2 "$API" \
  | jq -r '.result.links[] | select(.downloadType=="serverBedrockLinux") | .downloadUrl' \
  | head -n1
}

URL="${BDS_URL:-}"
if [ -z "$URL" ]; then URL="$(get_url_api || true)"; fi
if [ -z "$URL" ]; then log "WARN: could not resolve latest URL (keep current)"; exit 0; fi

# 既存と同一URLならスキップ
if [ -f "/data/.bds_url" ] && [ "$(cat /data/.bds_url 2>/dev/null || true)" = "$URL" ]; then
  log "same URL → skip download"
  exit 0
fi

log "downloading: ${URL}"
if ! wget -q -O bedrock-server.zip "${URL}"; then
  if ! curl --http1.1 -fL -o bedrock-server.zip "${URL}"; then
    log "ERROR: download failed (keep current)"; exit 0
  fi
fi

unzip -qo bedrock-server.zip -x server.properties allowlist.json || { log "ERROR: unzip failed (keep current)"; rm -f bedrock_server.zip; exit 0; }
rm -f bedrock-server.zip
echo "$URL" > /data/.bds_url
log "updated BDS payload"
BASH

# --- world_*_packs.json を「ホスト配下の behavior/resource だけで」再生成 ---
cat > "${DOCKER_DIR}/bds/update_addons.py" <<'PY'
import os, json, re, shutil

ROOT="/data"
BP_DIR=os.path.join(ROOT,"behavior_packs")
RP_DIR=os.path.join(ROOT,"resource_packs")
HOST_BP="/host_behavior"
HOST_RP="/host_resource"

WBP=os.path.join(ROOT,"worlds","world","world_behavior_packs.json")
WRP=os.path.join(ROOT,"worlds","world","world_resource_packs.json")

# 除外パターン（vanilla/chemistry/experimental は採用しない）
EXCLUDE = re.compile(r'^(vanilla(_\d|\b)|chemistry|experimental)', re.IGNORECASE)

def load_manifest(path):
    s=open(path,"r",encoding="utf-8").read()
    s=re.sub(r'//.*','',s); s=re.sub(r'/\*.*?\*/','',s,flags=re.S); s=re.sub(r',\s*([}\]])',r'\1',s)
    return json.loads(s)

def scan_and_sync(host_src, dst_dir):
    """ホストのアドオンを dst_dir にミラー（除外名はスキップ）。"""
    os.makedirs(dst_dir, exist_ok=True)
    found=[]
    names_in_host=set()
    if os.path.isdir(host_src):
        for name in sorted(os.listdir(host_src)):
            if EXCLUDE.match(name):
                continue
            src=os.path.join(host_src,name)
            mf=os.path.join(src,"manifest.json")
            if not (os.path.isdir(src) and os.path.isfile(mf)):
                continue
            names_in_host.add(name)
            dst=os.path.join(dst_dir,name)
            if os.path.isdir(dst):
                shutil.rmtree(dst)
            shutil.copytree(src,dst)
            try:
                m=load_manifest(mf)
                uuid=m["header"]["uuid"]; ver=m["header"]["version"]
                if isinstance(ver,list) and len(ver)==3:
                    found.append((name,uuid,ver))
            except Exception:
                pass
    # dst からホストに無いものを削除（整合性維持）
    for name in list(os.listdir(dst_dir)):
        if EXCLUDE.match(name):
            continue
        if name not in names_in_host:
            shutil.rmtree(os.path.join(dst_dir,name), ignore_errors=True)
    return found

def write_world(items, path, typ):
    arr=[{"pack_id":u,"version":v,"type":typ} for (_,u,v) in items]
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path,"w",encoding="utf-8") as f:
        json.dump(arr, f, indent=2, ensure_ascii=False)
    print(f"[addons] wrote {path} ({len(arr)} items)")

if __name__=="__main__":
    bp=scan_and_sync(HOST_BP, BP_DIR)
    rp=scan_and_sync(HOST_RP, RP_DIR)
    write_world(bp, WBP, "data")
    write_world(rp, WRP, "resources")
PY

# --- エントリ（server.properties 整備 / FIFO 準備 / 起動） ---
cat > "${DOCKER_DIR}/bds/entry-bds.sh" <<'BASH'
#!/usr/bin/env bash
set -euo pipefail
export TZ="${TZ:-Asia/Tokyo}"
cd /data; mkdir -p /data /data/worlds/world

# 初回 server.properties（座標はここでは設定しない→起動後にgameruleで有効化）
if [ ! -f server.properties ]; then
  cat > server.properties <<PROP
server-name=${SERVER_NAME:-OMF}
gamemode=survival
difficulty=normal
allow-cheats=true
max-players=8
online-mode=${ONLINE_MODE:-true}
allow-list=${ALLOWLIST_ON:-true}
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
${SEED_POINT:+level-seed=${SEED_POINT}}
PROP
else
  sed -i "s/^server-port=.*/server-port=${BDS_PORT_V4:-13922}/" server.properties
  sed -i "s/^server-portv6=.*/server-portv6=${BDS_PORT_V6:-19132}/" server.properties
  sed -i "s/^allow-cheats=.*/allow-cheats=true/" server.properties
  sed -i "s/^online-mode=.*/online-mode=${ONLINE_MODE:-true}/" server.properties
  if grep -q '^allow-list=' server.properties; then
    sed -i "s/^allow-list=.*/allow-list=${ALLOWLIST_ON:-true}/" server.properties
  else
    echo "allow-list=${ALLOWLIST_ON:-true}" >> server.properties
  fi
  sed -i "s/^content-log-file-enabled=.*/content-log-file-enabled=true/" server.properties
  sed -i "s/^content-log-file-name=.*/content-log-file-name=content.log/" server.properties
  if [ -n "${SEED_POINT:-}" ]; then
    if grep -q '^level-seed=' server.properties; then
      sed -i "s/^level-seed=.*/level-seed=${SEED_POINT}/" server.properties
    else
      echo "level-seed=${SEED_POINT}" >> server.properties
    fi
  fi
fi

# 必須 files
[ -f allowlist.json ] || echo "[]" > allowlist.json
[ -f permissions.json ] || echo "[]" > permissions.json
[ -f chat.json ] || echo "[]" > chat.json
[ -f players.json ] || echo "[]" > players.json
touch bedrock_server.log bds_console.log

# FIFO 準備
rm -f in.pipe; mkfifo in.pipe

# BDS 更新（失敗時は既存継続）
/usr/local/bin/get_bds.sh || true

# ホスト addons → /data へ同期 & world_*_packs.json 再生成
python3 /usr/local/bin/update_addons.py || true

# 起動メッセージ
python3 - <<'PY' || true
import json,os,datetime
f="chat.json"
try:
  arr=json.load(open(f,"r",encoding="utf-8"))
  if not isinstance(arr,list): arr=[]
except: arr=[]
arr.append({"player":"SYSTEM","message":"サーバーが起動しました","timestamp":datetime.datetime.now().isoformat()})
arr=arr[-300:]
json.dump(arr,open(f,"w",encoding="utf-8"),ensure_ascii=False,indent=2)
PY

LAUNCH="box64 ./bedrock_server"
echo "[entry-bds] exec: $LAUNCH (stdin: /data/in.pipe)"
( tail -F /data/in.pipe | eval "$LAUNCH" 2>&1 | tee -a /data/bds_console.log ) | tee -a /data/bedrock_server.log
BASH
chmod +x "${DOCKER_DIR}/bds/"*.sh

# ---------- monitor（API・ログ監視・初期gamerule・/chat & /webchat） ----------
mkdir -p "${DOCKER_DIR}/monitor"

cat > "${DOCKER_DIR}/monitor/Dockerfile" <<'DOCK'
FROM python:3.11-slim
RUN apt-get update && apt-get install -y --no-install-recommends ca-certificates curl jq procps \
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
LOG_BDS  = os.path.join(DATA, "bedrock_server.log")
LOG_CON  = os.path.join(DATA, "bds_console.log")
CHAT = os.path.join(DATA, "chat.json")
PLAY = os.path.join(DATA, "players.json")
ALLOW = os.path.join(DATA, "allowlist.json")
PERM  = os.path.join(DATA, "permissions.json")
FIFO  = os.path.join(DATA, "in.pipe")

API_TOKEN   = os.getenv("API_TOKEN", "")
SERVER_NAME = os.getenv("SERVER_NAME", "OMF")
MAX_CHAT    = 300
AUTOADD     = os.getenv("ALLOWLIST_AUTOADD","true").lower()=="true"
ROLE_RAW    = os.getenv("AUTH_CHEAT","member").lower().strip()
ROLE        = ROLE_RAW if ROLE_RAW in ("visitor","member","operator") else "member"

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
        j.append({
            "player": str(player),
            "message": str(message),
            "timestamp": datetime.datetime.now().isoformat()
        })
        j = j[-MAX_CHAT:]
        jdump(CHAT, j)

def set_players(lst):
    with lock:
        jdump(PLAY, sorted(set(lst)))

def add_allowlist(name, xuid, ignores=False):
    with lock:
        arr = jload(ALLOW, [])
        for it in arr:
            if (xuid and it.get("xuid")==xuid) or (it.get("name")==name):
                upd=False
                if xuid and not it.get("xuid"):
                    it["xuid"]=xuid; upd=True
                if "ignoresPlayerLimit" not in it:
                    it["ignoresPlayerLimit"]=bool(ignores); upd=True
                if upd: jdump(ALLOW, arr)
                return False
        arr.append({"name": name, "xuid": xuid, "ignoresPlayerLimit": bool(ignores)})
        jdump(ALLOW, arr)
        return True

def add_permissions(xuid, role):
    if not xuid:
        return False
    with lock:
        arr = jload(PERM, [])
        for it in arr:
            if it.get("xuid")==xuid:
                if it.get("permission") != role:
                    it["permission"]=role
                    jdump(PERM, arr)
                return False
        arr.append({"permission": role, "xuid": xuid})
        jdump(PERM, arr)
        return True

RE_JOIN    = re.compile(r'Player connected:\s*([^,]+),\s*xuid:\s*(\d+)')
RE_JOIN_NX = re.compile(r'Player connected:\s*([^,]+)')
RE_LEAVE   = re.compile(r'Player disconnected:\s*([^,]+)')
RE_SAY1    = re.compile(r'\[Server\]\s*(.+)$')
RE_SAY2    = re.compile(r'\bServer:\s*(.+)$')
RE_DEATHS  = [
    re.compile(r'^(.*) was (?:slain by|shot by|killed by|blown up by).+$'),
    re.compile(r'^(.*) (?:fell|drowned|burned to death|starved to death|died).*$'),
    re.compile(r'^(.*) (?:hit the ground too hard|went up in flames).*$')
]

def tail_file(path, handler):
    pos = 0
    while True:
        try:
            with open(path, "r", encoding="utf-8", errors="ignore") as f:
                f.seek(pos, os.SEEK_SET)
                while True:
                    line = f.readline()
                    if not line:
                        pos = f.tell()
                        time.sleep(0.2)
                        break
                    handler(line.rstrip("\r\n"))
        except FileNotFoundError:
            time.sleep(0.5)
        except Exception:
            time.sleep(0.5)

def handle_console(line, known):
    m = RE_JOIN.search(line)
    if m:
        name = m.group(1).strip()
        xuid = m.group(2).strip()
        if name:
            known.add(name); set_players(list(known))
            push_chat("SYSTEM", f"{name} が参加")
            if AUTOADD:
                try:
                    add_allowlist(name, xuid, ignores=False)
                    add_permissions(xuid, ROLE)
                except: pass
        return
    m = RE_JOIN_NX.search(line)
    if m and not RE_JOIN.search(line):
        name = m.group(1).strip()
        if name:
            known.add(name); set_players(list(known))
            push_chat("SYSTEM", f"{name} が参加")
            if AUTOADD:
                try:
                    add_allowlist(name, "", ignores=False)
                except: pass
        return
    m = RE_LEAVE.search(line)
    if m:
        name = m.group(1).strip()
        if name and name in known:
            known.discard(name); set_players(list(known))
            push_chat("SYSTEM", f"{name} が退出")
        return

def handle_bedrock(line):
    m = RE_SAY1.search(line) or RE_SAY2.search(line)
    if m:
        msg = m.group(1).strip()
        if msg: push_chat("SERVER", msg); return
    text = line.split("]")[-1].strip()
    for rx in RE_DEATHS:
        mm = rx.match(text)
        if mm:
            push_chat("SYSTEM", text)
            return

def tail_workers():
    known = set(jload(PLAY, []))
    t1 = threading.Thread(target=tail_file, args=(LOG_CON, lambda ln: handle_console(ln, known)), daemon=True)
    t2 = threading.Thread(target=tail_file, args=(LOG_BDS, handle_bedrock), daemon=True)
    t1.start(); t2.start()

def send_startup_commands():
    cmds = [
        "gamerule showcoordinates true",
        "gamerule playersSleepingPercentage 0"
    ]
    for _ in range(60):
        try:
            if os.path.exists(FIFO):
                with open(FIFO, "w", encoding="utf-8") as f:
                    for c in cmds:
                        f.write(c+"\n")
                push_chat("SYSTEM", "初期設定: 座標表示/1人寝 を適用しました")
                break
        except Exception:
            pass
        time.sleep(1)

class ChatIn(BaseModel):
    message: str
    sender: str | None = None

class AnnounceIn(BaseModel):
    message: str

class AllowIn(BaseModel):
    name: str
    ignoresPlayerLimit: bool = False
    xuid: str | None = None

app.on_event("startup")(lambda: (
    [jdump(p, init) for p,init in [(CHAT,[]),(PLAY,[]),(ALLOW,[]),(PERM,[]) ] if not os.path.exists(p)],
    tail_workers(),
    threading.Thread(target=send_startup_commands, daemon=True).start()
))

@app.get("/health")
def health():
    return {"ok": True, "console": os.path.exists(LOG_CON), "bds": os.path.exists(LOG_BDS),
            "role": ROLE, "autoadd": AUTOADD,
            "ts": datetime.datetime.now().isoformat()}

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

# サーバーへも流す
@app.post("/chat")
def post_chat(body: ChatIn, x_api_key: str = Header(None)):
    if x_api_key != API_TOKEN: raise HTTPException(status_code=403, detail="Forbidden")
    msg=(body.message or "").strip()
    who=(body.sender or "").strip() or "API"
    if not msg: raise HTTPException(status_code=400, detail="Empty")
    try:
        with open(FIFO,"w",encoding="utf-8") as f:
            f.write("say "+msg+"\n")
    except Exception:
        pass
    push_chat(who, msg)
    return {"status":"ok","routed":"server+web"}

# Web のみ
@app.post("/webchat")
def post_webchat(body: ChatIn, x_api_key: str = Header(None)):
    if x_api_key != API_TOKEN: raise HTTPException(status_code=403, detail="Forbidden")
    msg=(body.message or "").strip()
    who=(body.sender or "").strip() or "名無し"
    if not msg: raise HTTPException(status_code=400, detail="Empty")
    push_chat(who, msg)
    return {"status":"ok","routed":"web-only"}

@app.post("/allowlist/add")
def allow_add(body: AllowIn, x_api_key: str = Header(None)):
    if x_api_key != API_TOKEN: raise HTTPException(status_code=403, detail="Forbidden")
    name = (body.name or "").strip()
    xuid = (body.xuid or "").strip()
    if not name: raise HTTPException(status_code=400, detail="name required")
    added = add_allowlist(name, xuid, body.ignoresPlayerLimit)
    if xuid:
        add_permissions(xuid, ROLE)
    return {"ok": True, "added": added}

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=13900, log_level="info")
PY

# ---------- web（UIは前回と同等：名前12ch、iPhone最適化、MM/DD hh:mm表示、/webchat対応） ----------
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

# サイト
mkdir -p "${WEB_SITE_DIR}"
cat > "${WEB_SITE_DIR}/index.html" <<'HTML'
<!doctype html>
<html lang="ja">
<meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1,maximum-scale=1,user-scalable=no">
<title>OMF Portal</title>
<link rel="stylesheet" href="styles.css">
<script defer src="main.js"></script>
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
    <div id="server-info"></div>
  </section>
  <section id="chat" class="panel">
    <div class="status-row">
      <span>現在接続中:</span><div id="players" class="pill-row"></div>
    </div>
    <div class="chat-list" id="chat-list"></div>
    <form id="chat-form" class="chat-form">
      <input id="name-input" class="name-input" type="text" placeholder="名前" maxlength="16" autocomplete="username">
      <input id="chat-input" class="msg-input" type="text" placeholder="メッセージ本文" maxlength="200" autocomplete="off">
      <label class="onlyweb"><input type="checkbox" id="only-web"> 外部掲示のみ</label>
      <button type="submit">送信</button>
    </form>
    <div class="token-hint">
      API キー未設定時は利用できません。URL 例: <code>http://HOST:PORT/?token=YOUR_API_TOKEN&name=OMF</code>
    </div>
  </section>
  <section id="map" class="panel">
    <div class="map-header">昨日までのマップデータ</div>
    <div class="map-frame"><iframe id="map-iframe" src="/map/index.html"></iframe></div>
  </section>
</main>
</body>
</html>
HTML

cat > "${WEB_SITE_DIR}/styles.css" <<'CSS'
*{box-sizing:border-box}body{margin:0;font-family:system-ui,Segoe UI,Roboto,Helvetica,Arial}
header{position:sticky;top:0;background:#111;color:#fff;z-index:10}
.tabs{display:flex;gap:.25rem;padding:.5rem}
.tab{flex:1;padding:.6rem 0;border:0;background:#222;color:#eee;cursor:pointer}
.tab.active{background:#0a84ff;color:#fff;font-weight:600}
.panel{display:none;padding:1rem}.panel.show{display:block}
.status-row{display:flex;gap:.5rem;align-items:center;margin-bottom:.5rem}
.pill-row{display:flex;gap:.5rem;overflow-x:auto;padding:.25rem .5rem;border:1px solid #ddd;border-radius:.5rem;min-height:2.2rem}
.pill{padding:.25rem .6rem;border-radius:999px;background:#f1f1f1;border:1px solid #ddd}
.chat-list{border:1px solid #ddd;border-radius:.5rem;height:50vh;overflow:auto;padding:.5rem;background:#fafafa}
.chat-item{margin:.25rem 0;padding:.35rem .5rem;border-radius:.25rem;background:#fff;border:1px solid #eee;word-break:break-word}
.chat-form{display:flex;gap:.5rem;margin-top:.5rem;align-items:center}
.name-input{width:12ch;padding:.5rem;border:1px solid #ccc;border-radius:.4rem}
.msg-input{flex:1;padding:.5rem;border:1px solid #ccc;border-radius:.4rem}
.onlyweb{white-space:nowrap;font-size:.9rem;color:#333}
.chat-form button{padding:.6rem 1rem;border:0;background:#0a84ff;color:#fff;border-radius:.4rem;cursor:pointer}
.map-header{margin:.5rem 0;font-weight:600}
.map-frame{height:70vh;border:1px solid #ddd;border-radius:.5rem;overflow:hidden}
.map-frame iframe{width:100%;height:100%;border:0}
.token-hint{margin-top:.5rem;color:#666;font-size:.9rem}
@media (max-width:480px){
  .onlyweb{font-size:.8rem}
  .chat-form button{padding:.55rem .8rem}
}
CSS

cat > "${WEB_SITE_DIR}/main.js" <<'JS'
const API = "/api";
function qs(k){ return new URL(location.href).searchParams.get(k)||""; }
const TOKEN = qs("token") || localStorage.getItem("x_api_key") || "";
const SV = qs("name") || localStorage.getItem("server_name") || "OMF";
if(qs("token")) localStorage.setItem("x_api_key", qs("token"));
if(qs("name"))  localStorage.setItem("server_name", qs("name"));

function fmt(ts){
  if(!ts) return "";
  const d=new Date(ts);
  const MM=String(d.getMonth()+1).padStart(2,"0");
  const DD=String(d.getDate()).padStart(2,"0");
  const hh=String(d.getHours()).padStart(2,"0");
  const mm=String(d.getMinutes()).padStart(2,"0");
  return `[${MM}/${DD} ${hh}:${mm}]`;
}

document.addEventListener("DOMContentLoaded", ()=>{
  const info = document.getElementById("server-info");
  info.innerHTML = `<p>ようこそ！<strong>${SV}</strong></p><p>掲示は Web または外部 API（<code>/api/chat</code> または <code>/api/webchat</code>）から送れます。</p>`;
  document.querySelectorAll(".tab").forEach(b=>{
    b.addEventListener("click", ()=>{
      document.querySelectorAll(".tab").forEach(x=>x.classList.remove("active"));
      document.querySelectorAll(".panel").forEach(x=>x.classList.remove("show"));
      b.classList.add("active"); document.getElementById(b.dataset.target).classList.add("show");
    });
  });

  if(!TOKEN){
    document.getElementById("chat-list").innerHTML = `<div class="chat-item">API トークンが未指定です。URL に <code>?token=YOUR_API_TOKEN</code> を付けて開いてください。</div>`;
  }

  document.getElementById("name-input").value = qs("from") || localStorage.getItem("sender_name") || "";

  refreshPlayers(); refreshChat();
  setInterval(refreshPlayers,15000); setInterval(refreshChat,15000);

  document.getElementById("chat-form").addEventListener("submit", async(e)=>{
    e.preventDefault();
    const name = (document.getElementById("name-input").value || "").trim() || "名無し";
    const msg  = (document.getElementById("chat-input").value || "").trim();
    const onlyWeb = document.getElementById("only-web").checked;
    if(!TOKEN){ alert("API トークンがありません"); return; }
    if(!msg) return;
    localStorage.setItem("sender_name", name);
    try{
      const ep = onlyWeb ? "/webchat" : "/chat";
      const r=await fetch(API+ep,{method:"POST",headers:{"Content-Type":"application/json","x-api-key":TOKEN},body:JSON.stringify({message:msg,sender:name})});
      if(!r.ok) throw 0; document.getElementById("chat-input").value=""; refreshChat();
    }catch(_){ alert("送信失敗"); }
  });
});

async function refreshPlayers(){
  if(!TOKEN) return;
  try{
    const r=await fetch(API+"/players",{headers:{"x-api-key":TOKEN}}); if(!r.ok) return;
    const d=await r.json(); const row=document.getElementById("players"); row.innerHTML="";
    (d.players||[]).forEach(n=>{ const el=document.createElement("div"); el.className="pill"; el.textContent=n; row.appendChild(el); });
  }catch(_){}
}

async function refreshChat(){
  if(!TOKEN) return;
  try{
    const r=await fetch(API+"/chat",{headers:{"x-api-key":TOKEN}}); if(!r.ok) return;
    const d=await r.json(); const list=document.getElementById("chat-list"); list.innerHTML="";
    (d.latest||[]).forEach(m=>{
      const el=document.createElement("div"); el.className="chat-item";
      el.textContent=`${fmt(m.timestamp)} ${m.player}: ${m.message}`;
      list.appendChild(el);
    });
    list.scrollTop=list.scrollHeight;
  }catch(_){}
}
JS

# ---------- マップ更新（uNmINeD：downloads スクレイピング） ----------
cat > "${BASE}/update_map.sh" <<'BASH'
#!/usr/bin/env bash
set -euo pipefail
BASE_DIR="$(cd "$(dirname "$0")" && pwd)"
DATA="${BASE_DIR}/obj/data"
WORLD="${DATA}/worlds/world"
OUT="${DATA}/map"
TOOLS="${BASE_DIR}/obj/tools/unmined"
BIN="${TOOLS}/unmined-cli"
log(){ echo "[update_map] $*" >&2; }
need(){ command -v "$1" >/dev/null 2>&1 || { log "need '$1'"; exit 2; }; }
need curl; need grep; need sed; need awk
command -v tar >/dev/null 2>&1 || true
command -v unzip >/dev/null 2>&1 || true
command -v file >/dev/null 2>&1 || true
pick_arm_url(){
  local tmp url
  tmp="$(mktemp -d)"
  curl -fsSL "https://unmined.net/downloads/" > "$tmp/p.html"
  url="$(grep -Eo 'https://unmined\.net/download/unmined-cli-linux-arm64-dev/\?tmstv=[0-9]+' "$tmp/p.html" | head -n1 || true)"
  rm -rf "$tmp"; [ -n "$url" ] || return 1; echo "$url"
}
install_from_url(){
  local url="$1" tmp ext ctype root
  tmp="$(mktemp -d)"; curl -fL --retry 3 --retry-delay 2 -D "$tmp/h" -o "$tmp/p" "$url" || { rm -rf "$tmp"; return 1; }
  if command -v file >/dev/null 2>&1 && file "$tmp/p" | grep -qi 'Zip archive data'; then ext="zip"
  elif command -v file >/dev/null 2>&1 && file "$tmp/p" | grep -qi 'gzip compressed data'; then ext="tgz"
  else ctype="$(awk 'BEGIN{IGNORECASE=1}/^Content-Type:/{print $2}' "$tmp/h" | tr -d '\r' || true)"
       case "${ctype:-}" in application/zip) ext="zip";; application/gzip|application/x-gzip|application/x-tgz) ext="tgz";; *) ext="unknown";; esac
  fi
  mkdir -p "$tmp/x"
  case "$ext" in tgz) tar xzf "$tmp/p" -C "$tmp/x";; zip) unzip -qo "$tmp/p" -d "$tmp/x";; *) rm -rf "$tmp"; return 1;; esac
  root="$(find "$tmp/x" -maxdepth 2 -type d -name 'unmined-cli*' | head -n1 || true)"; [ -n "$root" ] || root="$tmp/x"
  [ -f "$root/unmined-cli" ] || root="$(dirname "$(find "$tmp/x" -type f -name 'unmined-cli' | head -n1 || true)")"
  [ -n "$root" ] && [ -f "$root/unmined-cli" ] || { rm -rf "$tmp"; return 1; }
  mkdir -p "${TOOLS}"; rsync -a "$root"/ "${TOOLS}/" 2>/dev/null || cp -rf "$root"/ "${TOOLS}/"
  chmod +x "${BIN}" || true; rm -rf "$tmp"
}
ensure_cli(){
  mkdir -p "${TOOLS}" "${OUT}"
  if [ -x "${BIN}" ]; then return 0; fi
  local url; url="$(pick_arm_url || true)"; [ -n "${url:-}" ] || return 1; install_from_url "$url"
}
render(){ "${BIN}" --version || true; "${BIN}" web render --world "${WORLD}" --output "${OUT}" --chunkprocessors 4; }
main(){ ensure_cli && render || { echo "[update_map] skipped/failed"; exit 0; } }
main "$@"
BASH
chmod +x "${BASE}/update_map.sh"

# ---------- バックアップ ----------
cat > "${BASE}/backup_now.sh" <<'BASH'
#!/usr/bin/env bash
set -euo pipefail
BASE_DIR="$(cd "$(dirname "$0")" && pwd)"
DATA="${BASE_DIR}/obj/data"
DEST="${BASE_DIR}/backups"
TS="$(date +%Y%m%d-%H%M%S)"
INCLUDE_ADDONS="${INCLUDE_ADDONS:-true}"
mkdir -p "$DEST"
OUT="${DEST}/backup-${TS}.tar.zst"
tmp="$(mktemp -d)"; trap 'rm -rf "$tmp"' EXIT
rsync -a --exclude 'map/*' --exclude 'content.log*' "$DATA/" "$tmp/data/"
if [ "${INCLUDE_ADDONS}" != "true" ]; then
  rm -rf "$tmp/data/behavior_packs" "$tmp/data/resource_packs"
  rm -f "$tmp/data/worlds/world/world_behavior_packs.json" "$tmp/data/worlds/world/world_resource_packs.json"
fi
tar -I 'zstd -19 -T0' -cf "$OUT" -C "$tmp" data
echo "[backup] created: $OUT"
BASH
chmod +x "${BASE}/backup_now.sh"

cat > "${BASE}/restore_backup.sh" <<'BASH'
#!/usr/bin/env bash
set -euo pipefail
BASE_DIR="$(cd "$(dirname "$0")" && pwd)"
DATA="${BASE_DIR}/obj/data"
SRC="${BASE_DIR}/backups"
echo "== バックアップ一覧 =="
select f in $(ls -1 ${SRC}/backup-*.tar.zst 2>/dev/null | sort); do
  [ -n "$f" ] || { echo "選択なし"; exit 1; }
  echo "選択: $f"; break
done
read -rp "アドオンも復元しますか？ [y/N]: " yn
WITH_ADDONS=false; [[ "$yn" =~ ^[Yy]$ ]] && WITH_ADDONS=true
tmp="$(mktemp -d)"; trap 'rm -rf "$tmp"' EXIT
tar -I zstd -xf "$f" -C "$tmp"
mkdir -p "$DATA"; rsync -a --delete "$tmp/data/" "$DATA/"
if [ "$WITH_ADDONS" != "true" ]; then
  rm -rf "$DATA/behavior_packs" "$DATA/resource_packs"
  rm -f "$DATA/worlds/world/world_behavior_packs.json" "$DATA/worlds/world/world_resource_packs.json"
fi
echo "[restore] done."
BASH
chmod +x "${BASE}/restore_backup.sh"

# ---------- マップ 出力先（プレースホルダ） ----------
mkdir -p "${DATA_DIR}/map"
if [[ ! -f "${DATA_DIR}/map/index.html" ]]; then
  echo '<!doctype html><meta charset="utf-8"><p>uNmINeD の Web 出力がここに作成されます。</p>' > "${DATA_DIR}/map/index.html"
fi

# ---------- ビルド & 先取りDL & 起動 ----------
echo "[BUILD] images..."
sudo docker compose -f "${DOCKER_DIR}/compose.yml" build --no-cache

echo "[PREFETCH] BDS payload ..."
sudo docker run --rm -e TZ=Asia/Tokyo \
  -e HOST_BEHAVIOR="${HOST_BEHAVIOR}" -e HOST_RESOURCE="${HOST_RESOURCE}" \
  --entrypoint /usr/local/bin/get_bds.sh \
  -v "${DATA_DIR}:/data" local/bds-box64:latest || true

echo "[UP] compose up -d ..."
sudo docker compose -f "${DOCKER_DIR}/compose.yml" up -d

cat <<MSG

== 確認 ==
curl -s -S "http://${MONITOR_BIND}:${MONITOR_PORT}/health" | jq .
curl -s -S -H "x-api-key: ${API_TOKEN}" "http://${MONITOR_BIND}:${MONITOR_PORT}/players" | jq .
curl -s -S -H "x-api-key: ${API_TOKEN}" "http://${MONITOR_BIND}:${MONITOR_PORT}/chat"    | jq .

== Web ポータル ==
URL 例: http://${WEB_BIND}:${WEB_PORT}/?token=${API_TOKEN}&name=${SERVER_NAME}

== 外部からの投稿 ==
# サーバー内にも流す
curl -s -S -H "x-api-key: ${API_TOKEN}" -H "Content-Type: application/json" \
  -d '{"message":"外部からのテストです","sender":"curl"}' \
  "http://${MONITOR_BIND}:${MONITOR_PORT}/chat" | jq .

# Webのみ
curl -s -S -H "x-api-key: ${API_TOKEN}" -H "Content-Type: application/json" \
  -d '{"message":"Webのみの掲示","sender":"curl"}' \
  "http://${MONITOR_BIND}:${MONITOR_PORT}/webchat" | jq .

== マップ更新 ==
${BASE}/update_map.sh

== ホスト addons の置き場所（ここに入れて実行） ==
- ${HOST_BEHAVIOR}
- ${HOST_RESOURCE}

MSG

