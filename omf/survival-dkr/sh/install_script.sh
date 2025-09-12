#!/usr/bin/env bash
# =====================================================================
# OMFS installer（アドオン外部投入 + world_*への安全適用 / Web&curl送信 / 時刻オーバーレイ）
#  - host resource:  ~/omf/survival-dkr/resource/ → data/resource_packs + world_resource_packs.json へ適用
#  - host behavior:  ~/omf/survival-dkr/behavior/ → data/behavior_packs + world_behavior_packs.json へ適用
#  - world_* は一度空に初期化 → ホスト配布パックのみ追記（バニラ類は無視）
#  - SEED_POINT → level-seed, AUTH_CHEAT → permissions 権限
#  - ALLOWLIST_ON or ALLOWLIST_AUTOADD で allowlist 追記＋permissions 同期
#  - /say は chat.json に反映
#  - POST /chat: {"message","sender"} 受け付け（sender 未入力は「名無し」）
#  - 画面下のアクションバーに「現実時刻 | マイクラ時刻」を定期表示（/title）
# =====================================================================
set -euo pipefail

# ---------- 変数 ----------
USER_NAME="${SUDO_USER:-$USER}"
HOME_DIR="$(getent passwd "$USER_NAME" | cut -d: -f6)"
BASE="${HOME_DIR}/omf/survival-dkr"
OBJ="${BASE}/obj"
DOCKER_DIR="${OBJ}/docker"
DATA_DIR="${OBJ}/data"
BKP_DIR="${DATA_DIR}/backups"
WEB_SITE_DIR="${DOCKER_DIR}/web/site"
TOOLS_DIR="${OBJ}/tools"
EXT_RES="${BASE}/resource"   # ← 追加（ホストのリソースパック置き場）
EXT_BEH="${BASE}/behavior"   # ← 追加（ホストのビヘイビアパック置き場）
KEY_FILE="${BASE}/key/key.conf"

mkdir -p "${DOCKER_DIR}" "${DATA_DIR}" "${BKP_DIR}" "${WEB_SITE_DIR}" "${TOOLS_DIR}" "${EXT_RES}" "${EXT_BEH}"
sudo chown -R "${USER_NAME}:${USER_NAME}" "${BASE}" || true

[[ -f "${KEY_FILE}" ]] || { echo "[ERR] key.conf が見つかりません: ${KEY_FILE}"; exit 1; }
# shellcheck disable=SC1090
source "${KEY_FILE}"
: "${SERVER_NAME:?SERVER_NAME を key.conf に設定してください}"
: "${API_TOKEN:?API_TOKEN を key.conf に設定してください}"
: "${GAS_URL:?GAS_URL を key.conf に設定してください}"
SEED_POINT="${SEED_POINT:-}"                         # level-seed
AUTH_CHEAT="${AUTH_CHEAT:-member}"                  # visitor/member/operator

# ポート/設定（必要に応じて key.conf で上書き可）
BDS_PORT_PUBLIC_V4="${BDS_PORT_PUBLIC_V4:-13922}"  # 公開（IPv4/UDP）
BDS_PORT_V6="${BDS_PORT_V6:-19132}"                # LAN（UDP）
MONITOR_BIND="${MONITOR_BIND:-0.0.0.0}"
MONITOR_PORT="${MONITOR_PORT:-13900}"
WEB_BIND="${WEB_BIND:-0.0.0.0}"
WEB_PORT="${WEB_PORT:-13901}"
BDS_URL="${BDS_URL:-}"
ALL_CLEAN="${ALL_CLEAN:-false}"

# allowlist / 認証
ALLOWLIST_ON="${ALLOWLIST_ON:-true}"               # server.properties の allow-list
ALLOWLIST_AUTOADD="${ALLOWLIST_AUTOADD:-true}"     # 監視で name+xuid を自動追加
ONLINE_MODE="${ONLINE_MODE:-true}"                 # XBL 認証（xuid 解決）

echo "[INFO] OMFS start user=${USER_NAME} base=${BASE} ALL_CLEAN=${ALL_CLEAN}"

# ---------- 既存 stack 停止/掃除 ----------
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

# ---------- apt ----------
echo "[SETUP] apt..."
sudo apt-get update -y
sudo apt-get install -y --no-install-recommends ca-certificates curl wget jq unzip git tzdata xz-utils build-essential rsync

# ---------- .env ----------
cat > "${DOCKER_DIR}/.env" <<ENV
TZ=Asia/Tokyo
GAS_URL=${GAS_URL}
API_TOKEN=${API_TOKEN}
SERVER_NAME=${SERVER_NAME}
SEED_POINT=${SEED_POINT}
AUTH_CHEAT=${AUTH_CHEAT}
BDS_PORT_PUBLIC_V4=${BDS_PORT_PUBLIC_V4}
BDS_PORT_V6=${BDS_PORT_V6}
MONITOR_BIND=${MONITOR_BIND}
MONITOR_PORT=${MONITOR_PORT}
WEB_BIND=${WEB_BIND}
WEB_PORT=${WEB_PORT}
BDS_URL=${BDS_URL}
ALLOWLIST_ON=${ALLOWLIST_ON}
ALLOWLIST_AUTOADD=${ALLOWLIST_AUTOADD}
ONLINE_MODE=${ONLINE_MODE}
ENV

# ---------- compose ----------
cat > "${DOCKER_DIR}/compose.yml" <<YAML
services:
  # ---- Bedrock Dedicated Server（box64で公式BDSを実行） ----
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
      SEED_POINT: \${SEED_POINT}
      AUTH_CHEAT: \${AUTH_CHEAT}
      BDS_URL: \${BDS_URL}
      BDS_PORT_V4: \${BDS_PORT_PUBLIC_V4}
      BDS_PORT_V6: \${BDS_PORT_V6}
      ALLOWLIST_ON: \${ALLOWLIST_ON}
      ONLINE_MODE: \${ONLINE_MODE}
    volumes:
      - ../data:/data
      - ../../resource:/ext/resource:ro    # ← ホストの resource/
      - ../../behavior:/ext/behavior:ro    # ← ホストの behavior/
    ports:
      - "\${BDS_PORT_PUBLIC_V4}:\${BDS_PORT_PUBLIC_V4}/udp"
      - "\${BDS_PORT_V6}:\${BDS_PORT_V6}/udp"
    restart: unless-stopped

  # ---- 監視API（/players, /chat, /allowlist/*, GAS初回通知, 時刻オーバーレイ） ----
  monitor:
    build: { context: ./monitor }
    image: local/bds-monitor:latest
    container_name: bds-monitor
    env_file: .env
    environment:
      TZ: \${TZ}
      SERVER_NAME: \${SERVER_NAME}
      API_TOKEN: \${API_TOKEN}
      GAS_URL: \${GAS_URL}
      AUTH_CHEAT: \${AUTH_CHEAT}
      ALLOWLIST_ON: \${ALLOWLIST_ON}
      ALLOWLIST_AUTOADD: \${ALLOWLIST_AUTOADD}
    volumes:
      - ../data:/data
    ports:
      - "\${MONITOR_BIND}:\${MONITOR_PORT}:13900/tcp"
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
      - "\${WEB_BIND}:\${WEB_PORT}:80"
    depends_on:
      monitor:
        condition: service_started
    restart: unless-stopped
YAML

# ---------- bds イメージ ----------
mkdir -p "${DOCKER_DIR}/bds"

cat > "${DOCKER_DIR}/bds/Dockerfile" <<'DOCK'
FROM debian:bookworm-slim
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates curl wget unzip jq xz-utils procps build-essential git cmake ninja-build python3 rsync \
 && rm -rf /var/lib/apt/lists/*

# box64: 公式BDS(x86_64)をARM等で実行するため
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

# --- world_* を /world 直下に空で用意 → 外部パックだけ追記 ---
# --- /ext/resource, /ext/behavior を data/*_packs にコピーしつつ manifest.json から pack_id/version を抽出 ---
cat > "${DOCKER_DIR}/bds/update_addons.py" <<'PY'
import os, json, shutil, glob

ROOT="/data"
WORLD=os.path.join(ROOT,"worlds","world")
WBP=os.path.join(WORLD,"world_behavior_packs.json")
WRP=os.path.join(WORLD,"world_resource_packs.json")
RES_DST=os.path.join(ROOT,"resource_packs")
BEH_DST=os.path.join(ROOT,"behavior_packs")
EXT_RES="/ext/resource"
EXT_BEH="/ext/behavior"

def ensure_dirs():
    os.makedirs(WORLD, exist_ok=True)
    os.makedirs(RES_DST, exist_ok=True)
    os.makedirs(BEH_DST, exist_ok=True)

def write_empty(p):
    with open(p,"w",encoding="utf-8") as f: json.dump([],f,ensure_ascii=False)

def load_manifest(path):
    try:
        with open(path,"r",encoding="utf-8") as f:
            return json.load(f)
    except: return None

def copy_pack(src_dir, dst_root):
    """src_dir（各パックのルート）を dst_root/<name> にコピー。戻り値=(dst_path, pack_id, version, type)"""
    if not os.path.isdir(src_dir): return None
    name=os.path.basename(src_dir.rstrip("/"))
    dst=os.path.join(dst_root, name)
    # まるごと置き換え
    if os.path.exists(dst): shutil.rmtree(dst)
    shutil.copytree(src_dir, dst)
    # manifest 解析
    mani = load_manifest(os.path.join(dst,"manifest.json"))
    if not mani: return None
    pack_id = mani.get("header",{}).get("uuid") or mani.get("header",{}).get("pack_id")
    version = mani.get("header",{}).get("version")
    # type 推定（modules[].type に resources/data があればそれ）
    mtypes = [m.get("type") for m in mani.get("modules",[]) if isinstance(m,dict) and "type" in m]
    ptype = "data" if "data" in mtypes else ("resources" if "resources" in mtypes else None)
    if not (pack_id and isinstance(version,list) and len(version)==3 and ptype):
        return None
    return (dst, pack_id, version, "data" if ptype=="data" else "resources")

def collect_packs(src_root, dst_root):
    added=[]
    for p in sorted(glob.glob(os.path.join(src_root,"*"))):
        if not os.path.isdir(p): continue
        info = copy_pack(p, dst_root)
        if info: added.append(info)
    return added

if __name__=="__main__":
    ensure_dirs()
    # 初期化（空）
    write_empty(WBP)
    write_empty(WRP)

    res = collect_packs(EXT_RES, RES_DST)
    beh = collect_packs(EXT_BEH, BEH_DST)

    # world_* にホスト投入分だけ反映
    wrp=[]; wbp=[]
    for (_path, pid, ver, typ) in res:
        if typ=="resources":
            wrp.append({"pack_id": pid, "version": ver})
    for (_path, pid, ver, typ) in beh:
        if typ=="data":
            wbp.append({"pack_id": pid, "version": ver, "type":"data"})
    # 書き込み
    with open(WRP,"w",encoding="utf-8") as f: json.dump(wrp, f, ensure_ascii=False, indent=2)
    with open(WBP,"w",encoding="utf-8") as f: json.dump(wbp, f, ensure_ascii=False, indent=2)

    print(f"[addons] resource packs applied: {len(wrp)}")
    print(f"[addons] behavior packs applied: {len(wbp)}")
PY

# --- エントリ：FIFO経由でBDSにコマンド投入（/say 送信用） + SEED_POINT 反映 + アドオン適用 ---
cat > "${DOCKER_DIR}/bds/entry-bds.sh" <<'BASH'
#!/usr/bin/env bash
set -euo pipefail
export TZ="${TZ:-Asia/Tokyo}"
cd /data; mkdir -p /data

# 必要ファイル/ディレクトリ
[ -f allowlist.json ] || echo "[]" > allowlist.json
[ -f permissions.json ] || echo "[]" > permissions.json
[ -f chat.json ] || echo "[]" > chat.json
[ -d worlds/world/db ] || mkdir -p worlds/world/db
touch bedrock_server.log bds_console.log

# server.properties（初回 or 更新）
if [ ! -f server.properties ]; then
  cat > server.properties <<PROP
server-name=${SERVER_NAME:-OMF}
gamemode=survival
difficulty=normal
allow-cheats=true
max-players=5
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
fi

# SEED_POINT → level-seed
if [ -n "${SEED_POINT:-}" ]; then
  if grep -q '^level-seed=' server.properties; then
    sed -i "s/^level-seed=.*/level-seed=${SEED_POINT}/" server.properties
  else
    echo "level-seed=${SEED_POINT}" >> server.properties
  fi
fi

# world_* は空→外部パックのみ追記
python3 /usr/local/bin/update_addons.py || true

# BDS 本体を取得/更新
/usr/local/bin/get_bds.sh

# FIFO（BDS stdin 接続）
FIFO="/data/console.in"
if [ ! -p "$FIFO" ]; then
  rm -f "$FIFO"; mkfifo "$FIFO"; chmod 666 "$FIFO"
fi

# 起動メッセージ（Web 表示用）
python3 - <<'PY' || true
import json,os,datetime
f="/data/chat.json"; d=[]
try:
  if os.path.exists(f): d=json.load(open(f,"r",encoding="utf-8"))
except: d=[]
if not isinstance(d,list): d=[]
d.append({"player":"SYSTEM","message":"サーバーが起動しました（アドオン適用済み）","timestamp":datetime.datetime.now().isoformat()})
d=d[-200:]
open(f,"w",encoding="utf-8").write(json.dumps(d,ensure_ascii=False))
PY

echo "[entry-bds] exec: tail -f /data/console.in | box64 ./bedrock_server"
stdbuf -oL -eL tail -n +1 -f "$FIFO" | stdbuf -oL -eL box64 ./bedrock_server 2>&1 | tee -a /data/bds_console.log
BASH
chmod +x "${DOCKER_DIR}/bds/"*.sh

# ---------- monitor（ログ監視API + GAS 初回入室通知 + /chat→BDSへsay + ALLOWLIST同期 + 時刻表示） ----------
mkdir -p "${DOCKER_DIR}/monitor"
cat > "${DOCKER_DIR}/monitor/Dockerfile" <<'DOCK'
FROM python:3.11-slim
RUN apt-get update && apt-get install -y --no-install-recommends ca-certificates procps curl \
 && rm -rf /var/lib/apt/lists/*
WORKDIR /app
RUN pip install --no-cache-dir fastapi uvicorn pydantic requests
COPY monitor.py /app/monitor.py
EXPOSE 13900/tcp
CMD ["python","/app/monitor.py"]
DOCK

cat > "${DOCKER_DIR}/monitor/monitor.py" <<'PY'
import os, json, threading, time, re, datetime, requests
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
CMD_IN = os.path.join(DATA, "console.in")

API_TOKEN   = os.getenv("API_TOKEN", "")
SERVER_NAME = os.getenv("SERVER_NAME", "OMF")
GAS_URL     = os.getenv("GAS_URL", "")
AUTH_CHEAT  = os.getenv("AUTH_CHEAT","member").lower().strip()
ALLOW_ON    = os.getenv("ALLOWLIST_ON","true").lower()=="true"
ALLOW_AUTO  = os.getenv("ALLOWLIST_AUTOADD","true").lower()=="true"
AUTOADD     = ALLOW_ON or ALLOW_AUTO
ROLE = AUTH_CHEAT if AUTH_CHEAT in ("visitor","member","operator") else "member"
MAX_CHAT    = 200

app = FastAPI()
lock = threading.Lock()
first_join_notified = False

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
        j.append({"player": str(player), "message": str(message), "timestamp": datetime.datetime.now().isoformat()})
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
                if xuid and not it.get("xuid"): it["xuid"]=xuid; upd=True
                if "ignoresPlayerLimit" not in it: it["ignoresPlayerLimit"]=bool(ignores); upd=True
                if upd: jdump(ALLOW, arr)
                return False
        arr.append({"name": name, "xuid": xuid, "ignoresPlayerLimit": bool(ignores)})
        jdump(ALLOW, arr)
        return True

def add_permissions(xuid, role):
    if not xuid: return False
    with lock:
        arr = jload(PERM, [])
        for it in arr:
            if it.get("xuid")==xuid:
                if it.get("permission") != role:
                    it["permission"]=role; jdump(PERM, arr)
                return False
        arr.append({"permission": role, "xuid": xuid}); jdump(PERM, arr)
        return True

# 解析用正規表現
RE_JOIN    = re.compile(r'Player connected:\s*([^,]+),\s*xuid:\s*([0-9]+)')
RE_JOIN_NX = re.compile(r'Player connected:\s*([^,]+)')
RE_LEAVE   = re.compile(r'Player disconnected:\s*([^,]+)')
RE_SAY1    = re.compile(r'\[Server\]\s*(.+)$')
RE_SAY2    = re.compile(r'\bServer:\s*(.+)$')
RE_DEATHS  = [
    re.compile(r'^(.*) was (?:slain by|shot by|killed by|blown up by).+$'),
    re.compile(r'^(.*) (?:fell|drowned|burned to death|starved to death|died).*$'),
    re.compile(r'^(.*) (?:hit the ground too hard|went up in flames).*$')
]
# /time query daytime の出力例にマッチ（環境差異により動かない場合あり）
RE_TIMEQ   = re.compile(r'.*Daytime\s*is\s*(\d+)', re.IGNORECASE)

def gas_notify_first_join(name, xuid):
    global first_join_notified
    if first_join_notified or not GAS_URL:
        return
    try:
        payload = {
            "event": "first_join_after_boot",
            "server": SERVER_NAME,
            "player": name,
            "xuid": xuid,
            "timestamp": datetime.datetime.now().isoformat()
        }
        requests.post(GAS_URL, json=payload, timeout=5)
        first_join_notified = True
        push_chat("SYSTEM", f"GAS通知送信: {name}")
    except Exception as e:
        push_chat("SYSTEM", f"GAS通知失敗: {e}")

def tail_file(path, handler):
    pos = 0
    while True:
        try:
            with open(path, "r", encoding="utf-8", errors="ignore") as f:
                f.seek(pos, os.SEEK_SET)
                while True:
                    line = f.readline()
                    if not line:
                        pos = f.tell(); time.sleep(0.2); break
                    handler(line.rstrip("\r\n"))
        except FileNotFoundError:
            time.sleep(0.5)
        except Exception:
            time.sleep(0.5)

def handle_console(line, known):
    m = RE_JOIN.search(line)
    if m:
        name = m.group(1).strip(); xuid = m.group(2).strip()
        if name:
            known.add(name); set_players(list(known)); push_chat("SYSTEM", f"{name} が参加")
            if AUTOADD:
                try: add_allowlist(name, xuid, False); add_permissions(xuid, ROLE)
                except: pass
            gas_notify_first_join(name, xuid); return
    m = RE_JOIN_NX.search(line)
    if m and not RE_JOIN.search(line):
        name = m.group(1).strip()
        if name:
            known.add(name); set_players(list(known)); push_chat("SYSTEM", f"{name} が参加")
            if AUTOADD:
                try: add_allowlist(name, "", False)
                except: pass
            gas_notify_first_join(name, ""); return
    m = RE_LEAVE.search(line)
    if m:
        name = m.group(1).strip()
        if name and name in known:
            known.discard(name); set_players(list(known)); push_chat("SYSTEM", f"{name} が退出")
        return
    # /time query daytime 結果
    m = RE_TIMEQ.match(line)
    if m:
        try:
            dt = int(m.group(1)) % 24000
            # Java/Bedrock とも 0 ≒ 06:00 として換算（おおよそ）
            mins = int(((dt + 0) / 24000) * 24 * 60)
            hh, mm = (mins // 60), (mins % 60)
            text = f"{hh:02d}:{mm:02d}"
            _set_mc_time(text)
        except: pass

def handle_bedrock(line):
    # /say → chat.json
    m = RE_SAY1.search(line) or RE_SAY2.search(line)
    if m:
        msg = m.group(1).strip()
        if msg: push_chat("SERVER", msg); return
    # 簡易死亡
    text = line.split("]")[-1].strip()
    for rx in RE_DEATHS:
        mm = rx.match(text)
        if mm:
            push_chat("SYSTEM", text); return

def tail_workers():
    known = set(jload(PLAY, []))
    t1 = threading.Thread(target=tail_file, args=(LOG_CON, lambda ln: handle_console(ln, known)), daemon=True)
    t2 = threading.Thread(target=tail_file, args=(LOG_BDS, handle_bedrock), daemon=True)
    t1.start(); t2.start()

# ===== 時刻オーバーレイ =====
_mc_time = "??:??"
def _set_mc_time(s):  # console ログ解析で更新
    global _mc_time
    _mc_time = s

def _bds_cmd(cmd):
    try:
        with open(CMD_IN, "w", encoding="utf-8", buffering=1) as f:
            f.write(cmd.strip()+"\n")
        return True
    except:
        return False

def overlay_loop():
    # 周期的に actionbar を更新。マイクラ時間は取得できた場合のみ併記。
    while True:
        now = datetime.datetime.now().strftime("%H:%M:%S")
        msg = f"現実 {now} | マイクラ {_mc_time}"
        _bds_cmd(f"title @a actionbar {msg}")
        # たまに daytime を問い合わせ（取得できない環境もある）
        _bds_cmd("time query daytime")
        time.sleep(10)

class ChatIn(BaseModel):
    message: str
    sender: str | None = None

class AllowIn(BaseModel):
    name: str
    ignoresPlayerLimit: bool = False
    xuid: str | None = None

def bds_say(sender: str, msg: str):
    s = (sender or "").strip() or "名無し"
    m = (msg or "").replace("\n"," ").strip()
    if not m: return False
    return _bds_cmd(f"say {s}: {m}")

@app.on_event("startup")
def _startup():
    for p,init in [(CHAT,[]),(PLAY,[]),(ALLOW,[]),(PERM,[])]:
        if not os.path.exists(p): jdump(p, init)
    global first_join_notified; first_join_notified = False
    # FIFO が無ければ作成（通常は bds 側で作成済み）
    if not os.path.exists(CMD_IN):
        try: os.mkfifo(CMD_IN); os.chmod(CMD_IN, 0o666)
        except: pass
    tail_workers()
    threading.Thread(target=overlay_loop, daemon=True).start()

@app.get("/health")
def health():
    return {"ok": True,
            "console": os.path.exists(LOG_CON),
            "bds": os.path.exists(LOG_BDS),
            "cmd_fifo": os.path.exists(CMD_IN),
            "role": ROLE, "autoadd": AUTOADD, "gas_url": bool(GAS_URL),
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

@app.post("/chat")
def post_chat(body: ChatIn, x_api_key: str = Header(None)):
    """外部→BDSへ /say '<sender>: <message>' + chat.jsonへも記録"""
    if x_api_key != API_TOKEN: raise HTTPException(status_code=403, detail="Forbidden")
    msg=(body.message or "").strip()
    sender=(body.sender or "").strip() or "名無し"
    if not msg: raise HTTPException(status_code=400, detail="Empty")
    ok = bds_say(sender, msg)
    push_chat(sender, msg)
    if not ok: raise HTTPException(status_code=500, detail="deliver failed")
    return {"status":"ok"}

@app.get("/allowlist/list")
def allow_list(x_api_key: str = Header(None)):
    if x_api_key != API_TOKEN: raise HTTPException(status_code=403, detail="Forbidden")
    return {"allowlist": jload(ALLOW, []), "permissions": jload(PERM, [])}

@app.post("/allowlist/add")
def allow_add(body: AllowIn, x_api_key: str = Header(None)):
    if x_api_key != API_TOKEN: raise HTTPException(status_code=403, detail="Forbidden")
    name = (body.name or "").strip()
    xuid = (body.xuid or "").strip()
    if not name: raise HTTPException(status_code=400, detail="name required")
    added = add_allowlist(name, xuid, body.ignoresPlayerLimit)
    if ALLOW_ON and xuid:
        add_permissions(xuid, ROLE)
    return {"ok": True, "added": added, "count": len(jload(ALLOW, [])), "role": ROLE}

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=13900, log_level="info")
PY

# ---------- web（UI: 名前 + メッセージを /api/chat へ送信） ----------
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

  location /map/ { alias /data-map/; autoindex on; }

  location / {
    root /usr/share/nginx/html;
    index index.html;
    try_files $uri $uri/ =404;
  }
}
NGX

mkdir -p "${WEB_SITE_DIR}"
cat > "${WEB_SITE_DIR}/index.html" <<'HTML'
<!doctype html>
<html lang="ja"><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>OMF Portal</title>
<link rel="stylesheet" href="styles.css"><script defer src="main.js"></script>
<body>
<header><nav class="tabs">
  <button class="tab active" data-target="info">サーバー情報</button>
  <button class="tab" data-target="chat">チャット</button>
  <button class="tab" data-target="map">マップ</button>
</nav></header>
<main>
<section id="info" class="panel show"><h1>サーバー情報</h1>
  <p>ようこそ！<strong id="sv-name"></strong></p>
  <p>掲示は Web または外部API（/api/chat）から送れます。</p>
</section>
<section id="chat" class="panel">
  <div class="status-row"><span>現在接続中:</span><div id="players" class="pill-row"></div></div>
  <div class="chat-list" id="chat-list"></div>
  <form id="chat-form" class="chat-form">
    <input id="chat-sender" type="text" placeholder="名前（空は『名無し』）" maxlength="24"/>
    <input id="chat-input" type="text" placeholder="（外部送信）メッセージ..." maxlength="200"/>
    <button type="submit">送信</button>
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
.chat-form{display:flex;gap:.5rem;margin-top:.5rem}
.chat-form input{flex:1;padding:.6rem;border:1px solid #ccc;border-radius:.4rem}
#chat-sender{max-width:14rem}
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

  const savedSender = localStorage.getItem("chat_sender") || "";
  document.getElementById("chat-sender").value = savedSender;

  refreshPlayers(); refreshChat();
  setInterval(refreshPlayers,15000); setInterval(refreshChat,15000);
  document.getElementById("chat-form").addEventListener("submit", async(e)=>{
    e.preventDefault();
    const sender=(document.getElementById("chat-sender").value||"").trim();
    const message=(document.getElementById("chat-input").value||"").trim();
    if(!message) return;
    try{
      const r=await fetch(API+"/chat",{method:"POST",headers:{"Content-Type":"application/json","x-api-key":TOKEN},body:JSON.stringify({message, sender})});
      if(!r.ok) throw 0;
      localStorage.setItem("chat_sender", sender);
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
async function refreshChat(){
  try{
    const r=await fetch(API+"/chat",{headers:{"x-api-key":TOKEN}}); if(!r.ok) return;
    const d=await r.json(); const list=document.getElementById("chat-list"); list.innerHTML="";
    (d.latest||[]).forEach(m=>{ const ts=(m.timestamp||'').replace('T',' ').slice(0,19); const nm=m.player||'名無し'; const text=m.message||''; 
      const el=document.createElement("div"); el.className="chat-item"; el.textContent=`[${ts}] ${nm}: ${text}`; list.appendChild(el); });
    list.scrollTop=list.scrollHeight;
  }catch(_){}
}
JS

# map 出力先（プレースホルダ）
mkdir -p "${DATA_DIR}/map"
if [[ ! -f "${DATA_DIR}/map/index.html" ]]; then
  echo '<!doctype html><meta charset="utf-8"><p>uNmINeD の Web 出力がここに作成されます。</p>' > "${DATA_DIR}/map/index.html"
fi

# ---------- ビルド & 起動 ----------
echo "[BUILD] images..."
sudo docker compose -f "${DOCKER_DIR}/compose.yml" build --no-cache

echo "[PREFETCH] BDS payload ..."
sudo docker run --rm -e TZ=Asia/Tokyo --entrypoint /usr/local/bin/get_bds.sh -v "${DATA_DIR}:/data" -v "${BASE}/resource:/ext/resource:ro" -v "${BASE}/behavior:/ext/behavior:ro" local/bds-box64:latest

echo "[UP] compose up -d ..."
sudo docker compose -f "${DOCKER_DIR}/compose.yml" up -d

cat <<'MSG'
== 使い方 ==
# 1) アドオンを配置（ホスト）
~/omf/survival-dkr/resource/<あなたのRP>（manifest.json 必須）
~/omf/survival-dkr/behavior/<あなたのBP>（manifest.json 必須）

# 2) インストーラ実行（このスクリプト）
#   → world_* を空に初期化 → ホスト配布パックのみを world_* に追記 → 即遊べます

== API 例（curlで投下） ==
curl -sS -H "x-api-key: ${API_TOKEN}" -H "Content-Type: application/json" \
     -d '{"message":"外部からこんにちは！","sender":"Webhook"}' \
     http://${MONITOR_BIND}:${MONITOR_PORT}/chat | jq .

== 確認 ==
curl -sS "http://${MONITOR_BIND}:${MONITOR_PORT}/health" | jq .
curl -sS -H "x-api-key: ${API_TOKEN}" "http://${MONITOR_BIND}:${MONITOR_PORT}/players" | jq .
curl -sS -H "x-api-key: ${API_TOKEN}" "http://${MONITOR_BIND}:${MONITOR_PORT}/chat" | jq .
curl -sS -H "x-api-key: ${API_TOKEN}" "http://${MONITOR_BIND}:${MONITOR_PORT}/allowlist/list" | jq .

== 備考 ==
- 「現実 | マイクラ」時刻は actionbar に表示します。/time query daytime が取得できない実行環境では現実時刻のみになります。
- AUTH_CHEAT=visitor/member/operator（permissions 同期の既定権限）
- SEED_POINT は server.properties の level-seed に反映
MSG
