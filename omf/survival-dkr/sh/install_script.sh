#!/usr/bin/env bash
# =====================================================================
# OMFS installer（完全版）
#  - bds_console.log の OMF-CHAT / OMF-DEATH を取り込み → chat.json へ
#  - Web チャット UI：2行レイアウト＋色分け、NAME フィールド削除（URL name を使用）
#  - token/name 不備時はエラーページを表示
#  - GAS：各プレイヤーごとに“その日”(07:50〜25:10)の初回入室を一度だけ POST
#  - ホスト addons を同期（vanilla/chemistry/experimental を除外）
#  - gamerule（座標表示/1人寝）を FIFO で適用
# =====================================================================
set -euo pipefail

# ---------- パス / 変数 ----------
USER_NAME="${SUDO_USER:-$USER}"
HOME_DIR="$(getent passwd "$USER_NAME" | cut -d: -f6)"
BASE="${HOME_DIR}/omf/survival-dkr"
OBJ="${BASE}/obj"
DOCKER_DIR="${OBJ}/docker"
DATA_DIR="${OBJ}/data"
BKP_DIR="${BASE}/backups"         # ALL_CLEAN 対象外
WEB_SITE_DIR="${DOCKER_DIR}/web/site"
TOOLS_DIR="${OBJ}/tools"
KEY_FILE="${BASE}/key/key.conf"

HOST_BEHAVIOR="${BASE}/behavior"
HOST_RESOURCE="${BASE}/resource"

mkdir -p "${DOCKER_DIR}" "${DATA_DIR}" "${BKP_DIR}" "${WEB_SITE_DIR}" "${TOOLS_DIR}" \
         "${HOST_BEHAVIOR}" "${HOST_RESOURCE}"
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

ALLOWLIST_ON="${ALLOWLIST_ON:-true}"
ALLOWLIST_AUTOADD="${ALLOWLIST_AUTOADD:-true}"
ONLINE_MODE="${ONLINE_MODE:-true}"
AUTH_CHEAT="${AUTH_CHEAT:-member}"
SEED_POINT="${SEED_POINT:-}"
BETA_ON="${BETA_ON:-false}"

echo "[INFO] OMFS start user=${USER_NAME} base=${BASE} ALL_CLEAN=${ALL_CLEAN}"

# ---------- 既存 stack 停止/掃除 ----------
echo "[CLEAN] stopping old stack..."
if [[ -f "${DOCKER_DIR}/compose.yml" ]]; then
  sudo docker compose -f "${DOCKER_DIR}/compose.yml" down --remove-orphans || true
fi
for c in bds bds-monitor bds-web; do sudo docker rm -f "$c" >/dev/null 2>&1 || true; done
if [[ "${ALL_CLEAN}" == "true" ]]; then
  sudo docker system prune -a -f || true
  rm -rf "${OBJ}"   # backups は消さない
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
      - \${HOST_BEHAVIOR}:/host_behavior:ro
      - \${HOST_RESOURCE}:/host_resource:ro
    ports:
      - "\${BDS_PORT_PUBLIC_V4}:\${BDS_PORT_PUBLIC_V4}/udp"
      - "\${BDS_PORT_V6}:\${BDS_PORT_V6}/udp"

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
      GAS_URL: \${GAS_URL}
    volumes:
      - ../data:/data
    ports:
      - "${MONITOR_BIND}:${MONITOR_PORT}:13900/tcp"
    depends_on:
      bds:
        condition: service_started

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
YAML

# ---------- bds image ----------
mkdir -p "${DOCKER_DIR}/bds"

cat > "${DOCKER_DIR}/bds/Dockerfile" <<'DOCK'
FROM debian:bookworm-slim
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates curl wget unzip jq xz-utils procps build-essential git cmake ninja-build python3 rsync \
 && rm -rf /var/lib/apt/lists/*

# box64
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

# --- BDS 取得（失敗時はスキップで現状維持） ---
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

if [ -f "/data/.bds_url" ] && [ "$(cat /data/.bds_url 2>/dev/null || true)" = "$URL" ]; then
  log "same URL → skip download"; exit 0
fi

log "downloading: ${URL}"
if ! wget -q -O bedrock-server.zip "${URL}"; then
  if ! curl --http1.1 -fL -o bedrock-server.zip "${URL}"; then
    log "ERROR: download failed (keep current)"; exit 0
  fi
fi
unzip -qo bedrock-server.zip -x server.properties allowlist.json || { log "ERROR: unzip failed (keep current)"; rm -f bedrock-server.zip; exit 0; }
rm -f bedrock-server.zip
echo "$URL" > /data/.bds_url
log "updated BDS payload"
BASH

# --- ホスト addons → /data へ同期し world_* を再生成 ---
cat > "${DOCKER_DIR}/bds/update_addons.py" <<'PY'
import os, json, re, shutil

ROOT="/data"
BP_DIR=os.path.join(ROOT,"behavior_packs")
RP_DIR=os.path.join(ROOT,"resource_packs")
HOST_BP="/host_behavior"
HOST_RP="/host_resource"

WBP=os.path.join(ROOT,"worlds","world","world_behavior_packs.json")
WRP=os.path.join(ROOT,"worlds","world","world_resource_packs.json")

EXCLUDE = re.compile(r'^(vanilla(_\d|\b)|chemistry|experimental)', re.IGNORECASE)

def load_manifest(path):
    import re, json
    s=open(path,"r",encoding="utf-8").read()
    s=re.sub(r'//.*','',s); s=re.sub(r'/\*.*?\*/','',s,flags=re.S); s=re.sub(r',\s*([}\]])',r'\1',s)
    return json.loads(s)

def scan_and_sync(host_src, dst_dir):
    os.makedirs(dst_dir, exist_ok=True)
    found=[]
    names_in_host=set()
    if os.path.isdir(host_src):
        for name in sorted(os.listdir(host_src)):
            if EXCLUDE.match(name): continue
            src=os.path.join(host_src,name)
            mf=os.path.join(src,"manifest.json")
            if not (os.path.isdir(src) and os.path.isfile(mf)): continue
            names_in_host.add(name)
            dst=os.path.join(dst_dir,name)
            if os.path.isdir(dst): shutil.rmtree(dst)
            shutil.copytree(src,dst)
            try:
                m=load_manifest(mf)
                uuid=m["header"]["uuid"]; ver=m["header"]["version"]
                if isinstance(ver,list) and len(ver)==3:
                    found.append((name,uuid,ver))
            except Exception: pass
    # dst からホストに無いものを削除
    for name in list(os.listdir(dst_dir)):
        if EXCLUDE.match(name): continue
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

# --- エントリ（server.properties 整備 / FIFO / addons 同期 / 起動） ---
cat > "${DOCKER_DIR}/bds/entry-bds.sh" <<'BASH'
#!/usr/bin/env bash
set -euo pipefail
export TZ="${TZ:-Asia/Tokyo}"
cd /data; mkdir -p /data /data/worlds/world

# server.properties
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

[ -f allowlist.json ] || echo "[]" > allowlist.json
[ -f permissions.json ] || echo "[]" > permissions.json
[ -f chat.json ] || echo "[]" > chat.json
[ -f players.json ] || echo "[]" > players.json
touch bedrock_server.log bds_console.log

rm -f in.pipe; mkfifo in.pipe

/usr/local/bin/get_bds.sh || true
python3 /usr/local/bin/update_addons.py || true

python3 - <<'PY' || true
import json,os,datetime
f="chat.json"
try:
  arr=json.load(open(f,"r",encoding="utf-8"))
  if not isinstance(arr,list): arr=[]
except: arr=[]
arr.append({"player":"SYSTEM","message":"サーバーが起動しました","timestamp":datetime.datetime.now().isoformat(),"kind":"system"})
arr=arr[-500:]
json.dump(arr,open(f,"w",encoding="utf-8"),ensure_ascii=False,indent=2)
PY

LAUNCH="box64 ./bedrock_server"
echo "[entry-bds] exec: $LAUNCH (stdin: /data/in.pipe)"
( tail -F /data/in.pipe | eval "$LAUNCH" 2>&1 | tee -a /data/bds_console.log ) | tee -a /data/bedrock_server.log
BASH
chmod +x "${DOCKER_DIR}/bds/"*.sh

# ---------- monitor（OMF-CHAT/DEATH 解析・GAS per-user/day・UI 用 API） ----------
mkdir -p "${DOCKER_DIR}/monitor"

cat > "${DOCKER_DIR}/monitor/Dockerfile" <<'DOCK'
FROM python:3.11-slim
RUN apt-get update && apt-get install -y --no-install-recommends ca-certificates curl jq procps \
 && rm -rf /var/lib/apt/lists/*
WORKDIR /app
RUN pip install --no-cache-dir fastapi uvicorn pydantic requests
COPY monitor.py /app/monitor.py
EXPOSE 13900/tcp
CMD ["python","/app/monitor.py"]
DOCK

cat > "${DOCKER_DIR}/monitor/monitor.py" <<'PY'
import os, json, threading, time, re, datetime
from fastapi import FastAPI, Header, HTTPException
from pydantic import BaseModel
import uvicorn, requests

DATA  = "/data"
LOG_B = os.path.join(DATA, "bedrock_server.log")
LOG_C = os.path.join(DATA, "bds_console.log")
CHAT  = os.path.join(DATA, "chat.json")
PLAY  = os.path.join(DATA, "players.json")
ALLOW = os.path.join(DATA, "allowlist.json")
PERM  = os.path.join(DATA, "permissions.json")
FIFO  = os.path.join(DATA, "in.pipe")

API_TOKEN   = os.getenv("API_TOKEN", "")
SERVER_NAME = os.getenv("SERVER_NAME", "OMF")
GAS_URL     = os.getenv("GAS_URL","").strip()
MAX_CHAT    = 800
AUTOADD     = os.getenv("ALLOWLIST_AUTOADD","true").lower()=="true"
ROLE_RAW    = os.getenv("AUTH_CHEAT","member").lower().strip()
ROLE        = ROLE_RAW if ROLE_RAW in ("visitor","member","operator") else "member"

# per-user/day 記録（07:50〜翌01:10）
GAS_MARK = os.path.join(DATA, ".gas_first_join.json")

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

def push_chat(player, message, kind="user", line2=None, line3=None):
    with lock:
        j = jload(CHAT, [])
        rec = {
            "player": str(player),
            "message": str(message),
            "timestamp": datetime.datetime.now().isoformat(),
            "kind": kind
        }
        if line2: rec["line2"] = line2
        if line3: rec["line3"] = line3
        j.append(rec)
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

# "その日" の判定（07:50〜翌01:10）※Asia/Tokyo 前提
def in_window_and_key():
    now = datetime.datetime.now()
    day_start = now.replace(hour=7, minute=50, second=0, microsecond=0)
    day_end   = (day_start + datetime.timedelta(hours=17, minutes=20)) # 07:50 + 17:20 = 25:10
    if now < day_start:
        # 深夜帯（〜07:50）は前日のウィンドウの外 → カウントしない
        return False, None
    if now > day_end:
        # 25:10 以降は今日のウィンドウ外
        return False, None
    # 同一「日付キー」は day_start の日付文字列
    key = day_start.date().isoformat()
    return True, key

def post_gas_first_join(player_name:str):
    if not GAS_URL:
        return
    ok, daykey = in_window_and_key()
    if not ok:
        return
    try:
        db = jload(GAS_MARK, {})
        if not isinstance(db, dict):
            db = {}
        seen = set(db.get(daykey, []))
        if player_name in seen:
            return
        payload = {
            "event": "first_join_window",
            "server": SERVER_NAME,
            "player": player_name,
            "window": {"start":"07:50","end":"25:10"},
            "timestamp": datetime.datetime.now().isoformat()
        }
        try:
            requests.post(GAS_URL, json=payload, timeout=5)
        except Exception:
            pass
        seen.add(player_name)
        db[daykey] = sorted(seen)
        jdump(GAS_MARK, db)
    except Exception:
        pass

# 既存 join/leave
RE_JOIN    = re.compile(r'Player connected:\s*([^,]+),\s*xuid:\s*(\d+)')
RE_JOIN_NX = re.compile(r'Player connected:\s*([^,]+)')
RE_LEAVE   = re.compile(r'Player disconnected:\s*([^,]+)')
RE_SAY1    = re.compile(r'\[Server\]\s*(.+)$')
RE_SAY2    = re.compile(r'\bServer:\s*(.+)$')

# OMF-CHAT / OMF-DEATH
RE_OMF_CHAT_JSON  = re.compile(r'^\[OMF-CHAT\]\s*(\{.*\})\s*$')
RE_OMF_CHAT_FAIL  = re.compile(r'^\[OMF-CHAT\]\s*particle_ok:\s*.+$')
RE_OMF_DEATH_JSON = re.compile(r'^\[OMF-DEATH\]\s*(\{.*\})\s*$')

def parse_killer(k):
    k = (k or "").strip()
    if k.startswith("minecraft:"):
        k = k.split(":",1)[1]
    return k if k else "不明"

def handle_console(line, known):
    # join（xuid あり）
    m = RE_JOIN.search(line)
    if m:
        name = m.group(1).strip()
        xuid = m.group(2).strip()
        if name:
            known.add(name); set_players(list(known))
            push_chat("SYSTEM", f"{name} が参加", kind="system")
            post_gas_first_join(name)
            if AUTOADD:
                try:
                    add_allowlist(name, xuid, ignores=False)
                    add_permissions(xuid, ROLE)
                except: pass
        return
    # join（xuid なし）
    m = RE_JOIN_NX.search(line)
    if m and not RE_JOIN.search(line):
        name = m.group(1).strip()
        if name:
            known.add(name); set_players(list(known))
            push_chat("SYSTEM", f"{name} が参加", kind="system")
            post_gas_first_join(name)
            if AUTOADD:
                try:
                    add_allowlist(name, "", ignores=False)
                except: pass
        return
    # leave
    m = RE_LEAVE.search(line)
    if m:
        name = m.group(1).strip()
        if name and name in known:
            known.discard(name); set_players(list(known))
            push_chat("SYSTEM", f"{name} が退出", kind="system")
        return
    # OMF-CHAT failure
    if RE_OMF_CHAT_FAIL.match(line):
        push_chat("SYSTEM", "誰かの手紙は虚空に消えました。", kind="system")
        return
    # OMF-CHAT JSON
    m = RE_OMF_CHAT_JSON.match(line)
    if m:
        try:
            obj = json.loads(m.group(1))
            if obj.get("type") == "note_use":
                player = obj.get("player") or "名無し"
                msg    = obj.get("message") or ""
                if msg:
                    push_chat(player, msg, kind="user")
        except Exception:
            pass
        return
    # OMF-DEATH JSON
    m = RE_OMF_DEATH_JSON.match(line)
    if m:
        try:
            obj = json.loads(m.group(1))
            if obj.get("type") == "death":
                who = obj.get("player") or "誰か"
                killer = parse_killer(obj.get("killerType") or obj.get("killerName"))
                pos = obj.get("position") or {}
                xyz = f"x={pos.get('x','?')} y={pos.get('y','?')} z={pos.get('z','?')}"
                push_chat(f"死因:{killer}", f"{who}さんが死亡しました。", kind="death", line3=xyz)
        except Exception:
            pass
        return

def handle_bedrock(line):
    # 任意で /say を拾っておく（副作用なし）
    m = RE_SAY1.search(line) or RE_SAY2.search(line)
    if m:
        msg = m.group(1).strip()
        if msg: push_chat("SERVER", msg, kind="system"); return

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

def tail_workers():
    known = set(jload(PLAY, []))
    t1 = threading.Thread(target=tail_file, args=(LOG_C, lambda ln: handle_console(ln, known)), daemon=True)
    t2 = threading.Thread(target=tail_file, args=(LOG_B, handle_bedrock), daemon=True)
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
                push_chat("SYSTEM", "初期設定: 座標表示/1人寝 を適用しました", kind="system")
                break
        except Exception:
            pass
        time.sleep(1)

class ChatIn(BaseModel):
    message: str
    sender: str | None = None

class AllowIn(BaseModel):
    name: str
    ignoresPlayerLimit: bool = False
    xuid: str | None = None

@app.on_event("startup")
def _startup():
    for p,init in [(CHAT,[]),(PLAY,[]),(ALLOW,[]),(PERM,[])]:
        if not os.path.exists(p): jdump(p, init)
    tail_workers()
    threading.Thread(target=send_startup_commands, daemon=True).start()

@app.get("/health")
def health():
    return {"ok": True, "console": os.path.exists(LOG_C), "bds": os.path.exists(LOG_B),
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

# サーバーへも流す + Web に記録
@app.post("/chat")
def post_chat(body: ChatIn, x_api_key: str = Header(None)):
    if x_api_key != API_TOKEN: raise HTTPException(status_code=403, detail="Forbidden")
    msg=(body.message or "").strip()
    who=(body.sender or "").strip() or "名無し"
    if not msg: raise HTTPException(status_code=400, detail="Empty")
    try:
        with open(FIFO,"w",encoding="utf-8") as f:
            f.write("say "+msg+"\n")
    except Exception:
        pass
    push_chat(who, msg, kind="user")
    return {"status":"ok","routed":"server+web"}

# Web のみ
@app.post("/webchat")
def post_webchat(body: ChatIn, x_api_key: str = Header(None)):
    if x_api_key != API_TOKEN: raise HTTPException(status_code=403, detail="Forbidden")
    msg=(body.message or "").strip()
    who=(body.sender or "").strip() or "名無し"
    if not msg: raise HTTPException(status_code=400, detail="Empty")
    push_chat(who, msg, kind="user")
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

# ---------- web（UI：2行レイアウト/色分け、name フィールド削除、エラーページ対応） ----------
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

cat > "${WEB_SITE_DIR}/index.html" <<'HTML'
<!doctype html>
<html lang="ja">
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width,initial-scale=1,maximum-scale=1,user-scalable=no">
  <title>OMF Portal</title>
  <link rel="stylesheet" href="styles.css">
  <script defer src="main.js"></script>
  <body>
    <div class="bg"></div>
    <header class="glass">
      <nav class="tabs">
        <button class="tab active" data-target="info">サーバー情報</button>
        <button class="tab" data-target="chat">チャット</button>
        <button class="tab" data-target="map">マップ</button>
      </nav>
    </header>
    <main id="main">
      <section id="info" class="panel show glass card">
        <h1 class="gradient">サーバー情報</h1>
        <div id="server-info"></div>
      </section>
      <section id="chat" class="panel glass card">
        <h2 class="gradient">チャット</h2>
        <div class="status-row"><span>現在接続中:</span><div id="players" class="pill-row"></div></div>
        <div class="chat-list" id="chat-list"></div>
        <form id="chat-form" class="chat-form">
          <input id="chat-input" class="msg-input" type="text" placeholder="メッセージ本文" maxlength="200" autocomplete="off">
          <button type="submit" class="send">送信</button>
        </form>
      </section>
      <section id="map" class="panel glass card">
        <h2 class="gradient">昨日までのマップデータ</h2>
        <div class="map-frame"><iframe id="map-iframe" src="/map/index.html"></iframe></div>
      </section>
    </main>
    <div id="gate" class="gate hidden">
      <div class="gate-card">
        <h2>ページを開けません</h2>
        <p>URL に <code>?token=YOUR_API_TOKEN&amp;name=YOUR_NAME</code> を付けてアクセスしてください。</p>
      </div>
    </div>
  </body>
</html>
HTML

cat > "${WEB_SITE_DIR}/styles.css" <<'CSS'
:root{
  --bg1:#0f172a; --bg2:#020617; --glass:rgba(255,255,255,.12);
  --border:rgba(255,255,255,.18); --text:#e5e7eb; --muted:#9ca3af;
  --accent1:#60a5fa; --accent2:#a78bfa; --accent3:#22d3ee;
  --shadow: 0 10px 30px rgba(0,0,0,.35);
  --green:#55FF55; --gray:#AAAAAA; --red:#FF5555; --white:#FFFFFF;
}
*{box-sizing:border-box}
html,body{height:100%}
body{margin:0;color:var(--text);font-family:ui-sans-serif,system-ui,Segoe UI,Roboto,Helvetica,Arial;background:radial-gradient(1200px 600px at 10% -10%,#1f2937 0%,transparent 50%), radial-gradient(800px 400px at 110% 10%,#111827 0%,transparent 40%), linear-gradient(160deg,var(--bg1),var(--bg2));}
.bg{position:fixed;inset:0;background:radial-gradient(600px 300px at 20% 80%,rgba(96,165,250,.15),transparent 50%), radial-gradient(600px 300px at 80% 10%,rgba(167,139,250,.18),transparent 50%);filter:blur(40px);z-index:-1}
header.glass{position:sticky;top:0;backdrop-filter:blur(14px);background:linear-gradient(180deg,rgba(0,0,0,.55),rgba(0,0,0,.25));border-bottom:1px solid var(--border);z-index:10}
.tabs{display:flex;gap:.4rem;padding:.6rem 1rem;max-width:1100px;margin:0 auto}
.tab{flex:1;padding:.7rem 0;border:1px solid var(--border);background:var(--glass);color:var(--text);cursor:pointer;border-radius:.6rem;transition:.2s}
.tab:hover{transform:translateY(-1px)}
.tab.active{background:linear-gradient(135deg,rgba(96,165,250,.25),rgba(167,139,250,.25));border-color:rgba(255,255,255,.35);font-weight:700}
main{max-width:1100px;margin:1rem auto;padding:0 1rem;display:grid;gap:1rem}
.glass{backdrop-filter:blur(12px);background:linear-gradient(180deg,rgba(255,255,255,.08),rgba(255,255,255,.04));border:1px solid var(--border)}
.card{border-radius:1rem;box-shadow:var(--shadow);padding:1rem}
.panel{display:none}.panel.show{display:block}
.gradient{background:linear-gradient(90deg,var(--accent1),var(--accent2),var(--accent3));-webkit-background-clip:text;background-clip:text;color:transparent;margin:.2rem 0 1rem;font-weight:800;letter-spacing:.02em}
.status-row{display:flex;gap:.5rem;align-items:center;margin:.5rem 0 1rem}
.pill-row{display:flex;gap:.5rem;overflow-x:auto;padding:.25rem .5rem;border:1px solid var(--border);border-radius:999px;min-height:2.2rem;background:rgba(0,0,0,.15)}
.pill{padding:.25rem .6rem;border-radius:999px;background:rgba(255,255,255,.08);border:1px solid var(--border);white-space:nowrap}

.chat-list{border:1px solid var(--border);border-radius:.8rem;height:60vh;overflow:auto;padding:.6rem;background:rgba(0,0,0,.25)}
.chat-item{margin:.35rem 0;padding:.5rem .7rem;border-radius:.7rem;background:rgba(255,255,255,.06);border:1px solid var(--border);animation:fadeIn .2s ease}
.chat-h1{display:flex;justify-content:space-between;align-items:center;font-size:.9rem;margin-bottom:.25rem}
.chat-time{opacity:.9}
.chat-name{opacity:.9}
.chat-body{font-size:1.05rem;white-space:pre-wrap;word-break:break-word}
.chat-death-extra{margin-top:.25rem;opacity:.95}

.chat-user .chat-h1{color:var(--green)}
.chat-user .chat-body{color:var(--white)}
.chat-system .chat-h1,.chat-system .chat-body{color:var(--gray)}
.chat-death .chat-h1,.chat-death .chat-body,.chat-death .chat-death-extra{color:var(--red)}

@keyframes fadeIn{from{opacity:0;transform:translateY(3px)}to{opacity:1;transform:none}}

.chat-form{display:flex;gap:.6rem;margin-top:.8rem;align-items:center}
.msg-input{flex:1;padding:.7rem;border:1px solid var(--border);border-radius:.7rem;background:rgba(255,255,255,.08);color:var(--text)}
.send{padding:.75rem 1.4rem;border:1px solid rgba(255,255,255,.35);background:linear-gradient(135deg,rgba(96,165,250,.5),rgba(167,139,250,.5));color:#fff;border-radius:.8rem;cursor:pointer;transition:.15s}
.send:hover{transform:translateY(-1px)}
.map-frame{height:70vh;border:1px solid var(--border);border-radius:.8rem;overflow:hidden;background:rgba(0,0,0,.25)}
.map-frame iframe{width:100%;height:100%;border:0}

#gate{position:fixed;inset:0;display:flex;align-items:center;justify-content:center;background:rgba(0,0,0,.55);backdrop-filter:blur(6px)}
#gate.hidden{display:none}
.gate-card{background:#151a2b;color:#e5e7eb;border:1px solid var(--border);padding:2rem;border-radius:1rem;box-shadow:var(--shadow);text-align:center}
.gate-card h2{margin-top:0}
CSS

cat > "${WEB_SITE_DIR}/main.js" <<'JS'
const API="/api";
function qs(k){ return new URL(location.href).searchParams.get(k)||""; }
const TOKEN = qs("token") || localStorage.getItem("x_api_key") || "";
const SENDER = qs("name")  || localStorage.getItem("sender_name") || "";
const SV = qs("sv") || qs("server") || localStorage.getItem("server_name") || "OMF";

if(qs("token")) localStorage.setItem("x_api_key", qs("token"));
if(qs("name"))  localStorage.setItem("sender_name", qs("name"));
if(qs("sv") || qs("server")) localStorage.setItem("server_name", SV);

const gate = document.getElementById("gate");
const main = document.getElementById("main");

function guard(){
  if(!TOKEN || !SENDER){
    gate.classList.remove("hidden");
    main.style.filter="blur(4px)";
    return false;
  }
  gate.classList.add("hidden");
  main.style.filter="";
  return true;
}

function fmt(ts){
  if(!ts) return "";
  const d=new Date(ts);
  const hh=String(d.getHours()).padStart(2,"0");
  const mm=String(d.getMinutes()).padStart(2,"0");
  return `[${hh}:${mm}]`;
}

document.addEventListener("DOMContentLoaded", ()=>{
  document.querySelectorAll(".tab").forEach(b=>{
    b.addEventListener("click", ()=>{
      document.querySelectorAll(".tab").forEach(x=>x.classList.remove("active"));
      document.querySelectorAll(".panel").forEach(x=>x.classList.remove("show"));
      b.classList.add("active"); document.getElementById(b.dataset.target).classList.add("show");
    });
  });

  const info = document.getElementById("server-info");
  info.innerHTML = `<p>ようこそ！<strong>${SV}</strong></p><p>掲示は Web または外部 API（<code>/api/chat</code> / <code>/api/webchat</code>）から送れます。</p>`;

  if(!guard()) return;

  refreshPlayers(); refreshChat();
  setInterval(refreshPlayers,15000); setInterval(refreshChat,8000);

  document.getElementById("chat-form").addEventListener("submit", async(e)=>{
    e.preventDefault();
    const v=(document.getElementById("chat-input").value||"").trim();
    if(!v) return;
    try{
      const r=await fetch(API+"/chat",{method:"POST",headers:{"Content-Type":"application/json","x-api-key":TOKEN},body:JSON.stringify({message:v,sender:SENDER})});
      if(!r.ok) throw 0;
      document.getElementById("chat-input").value="";
      refreshChat();
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

function renderChat(list, data){
  list.innerHTML="";
  (data.latest||[]).forEach(m=>{
    const kind = (m.kind|| (m.player==="SYSTEM"?"system":"user"));
    const item = document.createElement("div");
    item.className = "chat-item " + (kind==="death"?"chat-death":(kind==="system"?"chat-system":"chat-user"));
    const h1 = document.createElement("div"); h1.className="chat-h1";
    const left = document.createElement("div"); left.className="chat-time"; left.textContent=fmt(m.timestamp);
    const right= document.createElement("div"); right.className="chat-name"; right.textContent=m.player||"";
    h1.appendChild(left); h1.appendChild(right);
    const body = document.createElement("div"); body.className="chat-body"; body.textContent=m.message||"";
    item.appendChild(h1); item.appendChild(body);
    if (m.line2){ const b2=document.createElement("div"); b2.className="chat-body"; b2.textContent=m.line2; item.appendChild(b2); }
    if (m.line3){ const b3=document.createElement("div"); b3.className="chat-death-extra"; b3.textContent=m.line3; item.appendChild(b3); }
    list.appendChild(item);
  });
  list.scrollTop=list.scrollHeight;
}

async function refreshChat(){
  try{
    const r=await fetch(API+"/chat",{headers:{"x-api-key":TOKEN}}); if(!r.ok) return;
    const d=await r.json();
    const list=document.getElementById("chat-list");
    renderChat(list, d);
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
  case "$ext$" in tgz$) tar xzf "$tmp/p" -C "$tmp/x";; zip$) unzip -qo "$tmp/p" -d "$tmp/x";; *) rm -rf "$tmp"; return 1;; esac
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

# ---------- バックアップ（addons 含む/除く選択可） ----------
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

# ---------- マップ出力先（プレースホルダ） ----------
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

== Web ==
URL 例: http://${WEB_BIND}:${WEB_PORT}/?token=${API_TOKEN}&name=YOUR_NAME&sv=${SERVER_NAME}

== 外部からの投稿 ==
# サーバー内 + Web
curl -s -S -H "x-api-key: ${API_TOKEN}" -H "Content-Type: application/json" \
  -d '{"message":"外部からのテストです","sender":"curl"}' \
  "http://${MONITOR_BIND}:${MONITOR_PORT}/chat" | jq .

# Web のみ
curl -s -S -H "x-api-key: ${API_TOKEN}" -H "Content-Type: application/json" \
  -d '{"message":"Webのみの掲示","sender":"curl"}' \
  "http://${MONITOR_BIND}:${MONITOR_PORT}/webchat" | jq .

== GAS 通知 ==
- 「その日」= 07:50〜25:10。各プレイヤーがその期間に初入室した時 1 回だけ送信。
- 記録: ${DATA_DIR}/.gas_first_join.json

MSG

