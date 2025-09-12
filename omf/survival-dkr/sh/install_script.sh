#!/usr/bin/env bash
# =====================================================================
# OMFS installer（アドオン外部投入 + world_*安全適用 / Web&curl送信 / バックアップ安全化 / BETA切替）
#  - host resource:  ~/omf/survival-dkr/resource/ → data/resource_packs + world_resource_packs.json へ適用
#  - host behavior:  ~/omf/survival-dkr/behavior/ → data/behavior_packs + world_behavior_packs.json へ適用
#  - world_* は一度空に初期化 → ホスト配布パックのみ追記（バニラ類は無視）
#  - Script API 依存の判定により、BETA_ON=false なら beta 依存 BP を自動スキップ
#  - SEED_POINT → level-seed, AUTH_CHEAT → permissions 権限
#  - ALLOWLIST_ON or ALLOWLIST_AUTOADD で allowlist 追記＋permissions 同期
#  - /say は chat.json に反映
#  - POST /chat: {"message","sender"} 受け付け（sender 未入力は「名無し」）
#  - バックアップは ~/omf/survival-dkr/backups/（ALL_CLEAN でも保持）
#    * backup_now.sh（アドオン関連は除外） / restore_backup.sh（一覧から選択）
#  - Web:
#    * /content/html_server.html を読み込み、サーバー情報本文を外部化
#    * ?token=... or 初回モーダルで API_TOKEN を保存。未設定はブロッキング表示
#    * モバイル最適化 & ピンチズーム禁止
#    * チャット時刻表示を [MM/DD HH:MM] 形式に
#    * 名前ボックス幅を約6文字に縮小
#  - permissions.json は「登録時」＋「起動時」に AUTH_CHEAT へ再同期
# =====================================================================
set -euo pipefail

# ---------- 変数 ----------
USER_NAME="${SUDO_USER:-$USER}"
HOME_DIR="$(getent passwd "$USER_NAME" | cut -d: -f6)"
BASE="${HOME_DIR}/omf/survival-dkr"
OBJ="${BASE}/obj"
DOCKER_DIR="${OBJ}/docker}"
DOCKER_DIR="${OBJ}/docker"   # 修正（上行typo保険）
DATA_DIR="${OBJ}/data"
WEB_SITE_DIR="${DOCKER_DIR}/web/site"
TOOLS_DIR="${OBJ}/tools"
EXT_RES="${BASE}/resource"        # ホスト: resource packs
EXT_BEH="${BASE}/behavior"        # ホスト: behavior packs
HOST_BKP_DIR="${BASE}/backups"    # バックアップ先（ALL_CLEAN 対象外）
KEY_FILE="${BASE}/key/key.conf"

mkdir -p "${DOCKER_DIR}" "${DATA_DIR}" "${WEB_SITE_DIR}" "${TOOLS_DIR}" "${EXT_RES}" "${EXT_BEH}" "${HOST_BKP_DIR}"
sudo chown -R "${USER_NAME}:${USER_NAME}" "${BASE}" || true

[[ -f "${KEY_FILE}" ]] || { echo "[ERR] key.conf が見つかりません: ${KEY_FILE}"; exit 1; }
# shellcheck disable=SC1090
source "${KEY_FILE}"
: "${SERVER_NAME:?SERVER_NAME を key.conf に設定してください}"
: "${API_TOKEN:?API_TOKEN を key.conf に設定してください}"
: "${GAS_URL:?GAS_URL を key.conf に設定してください}"
SEED_POINT="${SEED_POINT:-}"                         # level-seed
AUTH_CHEAT="${AUTH_CHEAT:-member}"                  # visitor/member/operator
BETA_ON="${BETA_ON:-false}"

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
  # Dockerはクリーン、OBJは削除。ただし BASE/backups は保持
  sudo docker system prune -a -f || true
  rm -rf "${OBJ}"
fi

# クリーン後の再作成
mkdir -p "${DOCKER_DIR}" "${DATA_DIR}" "${WEB_SITE_DIR}" "${TOOLS_DIR}" "${EXT_RES}" "${EXT_BEH}" "${HOST_BKP_DIR}"
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
BETA_ON=${BETA_ON}
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
      BETA_ON: \${BETA_ON}
      BDS_URL: \${BDS_URL}
      BDS_PORT_V4: \${BDS_PORT_PUBLIC_V4}
      BDS_PORT_V6: \${BDS_PORT_V6}
      ALLOWLIST_ON: \${ALLOWLIST_ON}
      ONLINE_MODE: \${ONLINE_MODE}
    volumes:
      - ../data:/data
      - ../../resource:/ext/resource:ro    # ホストの resource/
      - ../../behavior:/ext/behavior:ro    # ホストの behavior/
    ports:
      - "\${BDS_PORT_PUBLIC_V4}:\${BDS_PORT_PUBLIC_V4}/udp"
      - "\${BDS_PORT_V6}:\${BDS_PORT_V6}/udp"
    restart: unless-stopped

  # ---- 監視API（/players, /chat, /allowlist/*, GAS初回通知） ----
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

  # ---- Web（/map と /api と /content を提供） ----
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
      - ../data:/data-ro:ro           # ← /content/ で配信するため
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

# --- world_* を /world 直下に空で用意 → 外部パックだけ追記（BETA_ON判定込み） ---
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
BETA_ON=os.getenv("BETA_ON","false").lower()=="true"

def ensure_dirs():
    os.makedirs(WORLD, exist_ok=True)
    os.makedirs(RES_DST, exist_ok=True)
    os.makedirs(BEH_DST, exist_ok=True)

def write_empty(p):
    with open(p,"w",encoding="utf-8") as f: json.dump([],f,ensure_ascii=False)

def load_json(path):
    try:
        with open(path,"r",encoding="utf-8") as f:
            return json.load(f)
    except: return None

def manifest_beta_required(manifest):
    deps = (manifest or {}).get("dependencies", [])
    for d in deps:
        try:
            name = (d.get("module_name") or d.get("name") or "").lower()
            ver  = (d.get("version") or "")
            if name.startswith("@minecraft/") and isinstance(ver,str) and "beta" in ver:
                return True
        except: pass
    return False

def module_type(manifest):
    mods = (manifest or {}).get("modules",[])
    mtypes = [m.get("type") for m in mods if isinstance(m,dict)]
    if "resources" in mtypes: return "resources"
    if "data" in mtypes: return "data"
    return None

def copy_pack(src_dir, dst_root):
    if not os.path.isdir(src_dir): return None
    name=os.path.basename(src_dir.rstrip("/"))
    dst=os.path.join(dst_root, name)
    if os.path.exists(dst): shutil.rmtree(dst)
    shutil.copytree(src_dir, dst)
    mani = load_json(os.path.join(dst,"manifest.json"))
    if not mani: return None
    pack_id = (mani.get("header",{}) or {}).get("uuid") or (mani.get("header",{}) or {}).get("pack_id")
    version = (mani.get("header",{}) or {}).get("version")
    ptype = module_type(mani)
    beta_req = manifest_beta_required(mani)
    if not (pack_id and isinstance(version,list) and len(version)==3 and ptype):
        return None
    return (dst, pack_id, version, ptype, beta_req)

def collect_packs(src_root, dst_root):
    added=[]
    for p in sorted(glob.glob(os.path.join(src_root,"*"))):
        if not os.path.isdir(p): continue
        info = copy_pack(p, dst_root)
        if info: added.append(info)
    return added

if __name__=="__main__":
    ensure_dirs()
    write_empty(WBP); write_empty(WRP)

    res = collect_packs(EXT_RES, RES_DST)
    beh = collect_packs(EXT_BEH, BEH_DST)

    wrp=[]; wbp=[]
    for (_path, pid, ver, typ, beta_req) in res:
        if typ=="resources":
            wrp.append({"pack_id": pid, "version": ver})
    for (_path, pid, ver, typ, beta_req) in beh:
        if typ=="data":
            if beta_req and not BETA_ON:
                continue
            wbp.append({"pack_id": pid, "version": ver, "type":"data"})
    with open(WRP,"w",encoding="utf-8") as f: json.dump(wrp, f, ensure_ascii=False, indent=2)
    with open(WBP,"w",encoding="utf-8") as f: json.dump(wbp, f, ensure_ascii=False, indent=2)
    print(f"[addons] RP:{len(wrp)} BP:{len(wbp)} (beta_on={BETA_ON})")
PY

# --- エントリ：FIFO経由でBDSにコマンド投入 + SEED_POINT 反映 + アドオン適用 ---
cat > "${DOCKER_DIR}/bds/entry-bds.sh" <<'BASH'
#!/usr/bin/env bash
set -euo pipefail
export TZ="${TZ:-Asia/Tokyo}"
cd /data; mkdir -p /data

[ -f allowlist.json ] || echo "[]" > allowlist.json
[ -f permissions.json ] || echo "[]" > permissions.json
[ -f chat.json ] || echo "[]" > chat.json
[ -d worlds/world/db ] || mkdir -p worlds/world/db
touch bedrock_server.log bds_console.log

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

# 外部パック適用
python3 /usr/local/bin/update_addons.py || true

/usr/local/bin/get_bds.sh

FIFO="/data/console.in"
if [ ! -p "$FIFO" ]; then
  rm -f "$FIFO"; mkfifo "$FIFO"; chmod 666 "$FIFO"
fi

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

# ---------- monitor（ログ監視API + GAS/権限同期 + /chat→BDSへsay） ----------
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
last_perm_sync = None

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

def sync_permissions_full():
    """起動時に allowlist の xuid を基準に permissions を AUTH_CHEAT へ再同期"""
    changed = 0
    allow = jload(ALLOW, [])
    per = jload(PERM, [])
    # 既存 permissions を dict 化
    per_map = {p.get("xuid"): p for p in per if p.get("xuid")}
    for a in allow:
        x = (a.get("xuid") or "").strip()
        if not x: continue
        cur = per_map.get(x)
        if cur:
            if cur.get("permission") != ROLE:
                cur["permission"] = ROLE
                changed += 1
        else:
            per.append({"permission": ROLE, "xuid": x})
            changed += 1
    if changed:
        jdump(PERM, per)
    return changed

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

def handle_bedrock(line):
    m = RE_SAY1.search(line) or RE_SAY2.search(line)
    if m:
        msg = m.group(1).strip()
        if msg: push_chat("SERVER", msg); return
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

class ChatIn(BaseModel):
    message: str
    sender: str | None = None

class AllowIn(BaseModel):
    name: str
    ignoresPlayerLimit: bool = False
    xuid: str | None = None

def _bds_cmd(cmd):
    try:
        with open(CMD_IN, "w", encoding="utf-8", buffering=1) as f:
            f.write(cmd.strip()+"\n")
        return True
    except:
        return False

def bds_say(sender: str, msg: str):
    s = (sender or "").strip() or "名無し"
    m = (msg or "").replace("\n"," ").strip()
    if not m: return False
    return _bds_cmd(f"say {s}: {m}")

@app.on_event("startup")
def _startup():
    for p,init in [(CHAT,[]),(PLAY,[]),(ALLOW,[]),(PERM,[])]:
        if not os.path.exists(p): jdump(p, init)
    global first_join_notified, last_perm_sync
    first_join_notified = False
    if not os.path.exists(CMD_IN):
        try: os.mkfifo(CMD_IN); os.chmod(CMD_IN, 0o666)
        except: pass
    # 起動時に権限を AUTH_CHEAT で再同期
    changed = sync_permissions_full()
    last_perm_sync = {"changed": changed, "role": ROLE, "ts": datetime.datetime.now().isoformat()}
    tail_workers()

@app.get("/health")
def health():
    return {"ok": True,
            "console": os.path.exists(LOG_CON),
            "bds": os.path.exists(LOG_BDS),
            "cmd_fifo": os.path.exists(CMD_IN),
            "role": ROLE, "autoadd": AUTOADD, "gas_url": bool(GAS_URL),
            "perm_sync": last_perm_sync,
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

# ---------- web（UI: 時刻フォーマット & 名前幅縮小 & トークンゲート） ----------
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
  location /content/ { alias /data-ro/; autoindex off; }

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
<html lang="ja">
  <head>
    <meta charset="utf-8">
    <!-- ピンチズーム禁止 -->
    <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no">
    <title>OMF Portal</title>
    <link rel="stylesheet" href="styles.css">
    <script defer src="main.js"></script>
  </head>
  <body>
    <div id="token-gate" class="gate hidden">
      <div class="gate-card">
        <h2>API トークンが必要です</h2>
        <p>URL に <code>?token=...</code> を付けるか、下に入力してください。</p>
        <input id="gate-token" type="password" placeholder="API トークン">
        <button id="gate-save">保存して開く</button>
        <p class="hint">例: <code>http://HOST_OR_IP:13901/?token=YOUR_API_TOKEN</code></p>
      </div>
    </div>

    <header>
      <nav class="tabs">
        <button class="tab active" data-target="info">サーバー情報</button>
        <button class="tab" data-target="chat">チャット</button>
        <button class="tab" data-target="map">マップ</button>
      </nav>
    </header>

    <main>
      <section id="info" class="panel show">
        <div id="info-contents" class="card"></div>
      </section>

      <section id="chat" class="panel">
        <div class="card">
          <div class="status-row">
            <span>現在接続中:</span>
            <div id="players" class="pill-row"></div>
          </div>

          <div class="chat-list" id="chat-list"></div>

          <form id="chat-form" class="chat-form">
            <input id="chat-sender" class="name" type="text" placeholder="名前（空は『名無し』）" maxlength="24"/>
            <input id="chat-input" class="message" type="text" placeholder="（外部送信）メッセージ..." maxlength="200"/>
            <button class="send" type="submit">送信</button>
          </form>
        </div>
      </section>

      <section id="map" class="panel">
        <div class="card">
          <div class="map-header">昨日までのマップデータ</div>
          <div class="map-frame"><iframe id="map-iframe" src="/map/index.html"></iframe></div>
        </div>
      </section>
    </main>
  </body>
</html>
HTML

cat > "${WEB_SITE_DIR}/styles.css" <<'CSS'
:root{
  --bg:#0b0d10; --card:#12161b; --muted:#8aa0b2; --fg:#e9f0f6; --acc:#4da3ff; --border:#1f2730;
}
*{box-sizing:border-box}
html,body{height:100%}
body{margin:0;font-family:system-ui,Segoe UI,Roboto,Helvetica,Arial;background:var(--bg);color:var(--fg)}

header{position:sticky;top:0;background:rgba(11,13,16,.7);backdrop-filter:saturate(140%) blur(8px);z-index:10;border-bottom:1px solid var(--border)}
.tabs{display:flex;gap:.25rem;padding:.5rem}
.tab{flex:1;padding:.7rem 0;border:0;background:#0e1318;color:var(--muted);cursor:pointer;border-radius:.5rem}
.tab.active{background:var(--acc);color:#fff;font-weight:600}

main{padding:1rem;max-width:1100px;margin:0 auto}
.panel{display:none}.panel.show{display:block}

.card{background:var(--card);border:1px solid var(--border);border-radius:.8rem;box-shadow:0 .4rem 1rem rgba(0,0,0,.25);padding:1rem}

.status-row{display:flex;gap:.5rem;align-items:center;margin-bottom:.75rem;color:var(--muted)}
.pill-row{display:flex;gap:.5rem;overflow-x:auto;padding:.25rem .5rem;border:1px solid var(--border);border-radius:.5rem;min-height:2.2rem;background:#0e1318}
.pill{padding:.25rem .6rem;border-radius:999px;background:#0b1117;border:1px solid var(--border);color:var(--fg);white-space:nowrap}

.chat-list{border:1px solid var(--border);border-radius:.6rem;height:50vh;max-height:60vh;overflow:auto;padding:.5rem;background:#0e1318}
.chat-item{margin:.25rem 0;padding:.45rem .6rem;border-radius:.4rem;background:#0b1117;border:1px solid var(--border);color:var(--fg)}

.chat-form{display:grid;grid-template-columns:minmax(4.5rem,8ch) 1fr auto;gap:.5rem;margin-top:.6rem}
.chat-form .name{width:8ch}       /* ≒6文字前後の幅 */
.chat-form .message{min-width:8rem}
.chat-form .send{padding:.6rem 1rem;border:0;background:var(--acc);color:#fff;border-radius:.5rem;cursor:pointer}
.chat-form input{padding:.6rem;border:1px solid var(--border);border-radius:.5rem;background:#0e1318;color:var(--fg)}

.map-header{margin:.5rem 0 .8rem;font-weight:600;color:var(--muted)}
.map-frame{height:70vh;border:1px solid var(--border);border-radius:.6rem;overflow:hidden;background:#0e1318}
.map-frame iframe{width:100%;height:100%;border:0}

#token-gate.gate{position:fixed;inset:0;background:#0b0d10;display:flex;align-items:center;justify-content:center;z-index:9999}
#token-gate.hidden{display:none}
.gate-card{background:var(--card);border:1px solid var(--border);border-radius:.8rem;box-shadow:0 .4rem 1rem rgba(0,0,0,.35);padding:1.2rem;max-width:480px;width:92%}
.gate-card h2{margin:.2rem 0  .6rem}
.gate-card input{width:100%;padding:.7rem;border:1px solid var(--border);border-radius:.5rem;background:#0e1318;color:var(--fg);margin:.4rem 0}
.gate-card button{width:100%;padding:.7rem;border:0;background:var(--acc);color:#fff;border-radius:.5rem;cursor:pointer}
.gate-card .hint{color:var(--muted);font-size:.9rem;margin-top:.5rem}

@media (max-width: 420px){
  main{padding:.7rem}
  .chat-list{height:52vh}
}
CSS

cat > "${WEB_SITE_DIR}/main.js" <<'JS'
const API="/api";
function getQueryToken(){ const m=location.search.match(/[?&]token=([^&]+)/); return m?decodeURIComponent(m[1]):""; }
function token(){ return localStorage.getItem("x_api_key")||""; }
function setToken(t){ localStorage.setItem("x_api_key",t||""); }
function requireToken(){
  const t = token();
  if(!t){ document.getElementById("token-gate").classList.remove("hidden"); return false; }
  return true;
}
function initGate(){
  const qtok=getQueryToken();
  if(qtok){ setToken(qtok); history.replaceState(null,"",location.pathname); }
  document.getElementById("gate-save").addEventListener("click", ()=>{
    const v=document.getElementById("gate-token").value.trim();
    if(!v){ alert("トークンを入力してください"); return; }
    setToken(v); location.reload();
  });
}

function fmt(ts){
  // [MM/DD HH:MM] に整形
  try{
    const d=new Date(ts);
    const MM=String(d.getMonth()+1).padStart(2,'0');
    const DD=String(d.getDate()).padStart(2,'0');
    const HH=String(d.getHours()).padStart(2,'0');
    const mm=String(d.getMinutes()).padStart(2,'0');
    return `${MM}/${DD} ${HH}:${mm}`;
  }catch(_){ return ts; }
}

document.addEventListener("DOMContentLoaded", ()=>{
  initGate();
  if(!requireToken()) return;

  document.querySelectorAll(".tab").forEach(b=>{
    b.addEventListener("click", ()=>{
      document.querySelectorAll(".tab").forEach(x=>x.classList.remove("active"));
      document.querySelectorAll(".panel").forEach(x=>x.classList.remove("show"));
      b.classList.add("active"); document.getElementById(b.dataset.target).classList.add("show");
    });
  });

  fetch("/content/html_server.html", {cache:"no-cache"})
    .then(r=> r.ok ? r.text(): Promise.reject())
    .then(tx=>{ document.getElementById("info-contents").innerHTML = tx; })
    .catch(_=>{ document.getElementById("info-contents").innerHTML="<p>サーバー情報を読み込めませんでした。</p>"; });

  refreshPlayers(); refreshChat();
  setInterval(refreshPlayers,15000); setInterval(refreshChat,15000);

  const savedSender = localStorage.getItem("chat_sender") || "";
  document.getElementById("chat-sender").value = savedSender;

  document.getElementById("chat-form").addEventListener("submit", async(e)=>{
    e.preventDefault();
    const sender=(document.getElementById("chat-sender").value||"").trim();
    const message=(document.getElementById("chat-input").value||"").trim();
    if(!message) return;
    try{
      const r=await fetch(API+"/chat",{method:"POST",headers:{"Content-Type":"application/json","x-api-key":token()},body:JSON.stringify({message, sender})});
      if(!r.ok) throw 0;
      localStorage.setItem("chat_sender", sender);
      document.getElementById("chat-input").value="";
      refreshChat();
    }catch(_){ alert("送信失敗（トークンを確認）"); }
  });
});

async function refreshPlayers(){
  try{
    const r=await fetch(API+"/players",{headers:{"x-api-key":token()}}); if(!r.ok) return;
    const d=await r.json(); const row=document.getElementById("players"); row.innerHTML="";
    (d.players||[]).forEach(n=>{ const el=document.createElement("div"); el.className="pill"; el.textContent=n; row.appendChild(el); });
  }catch(_){}
}

async function refreshChat(){
  try{
    const r=await fetch(API+"/chat",{headers:{"x-api-key":token()}}); if(!r.ok) return;
    const d=await r.json(); const list=document.getElementById("chat-list"); list.innerHTML="";
    (d.latest||[]).forEach(m=>{
      const ts=fmt(m.timestamp||'');
      const nm=m.player||'名無し';
      const text=m.message||'';
      const el=document.createElement("div"); el.className="chat-item";
      el.textContent=`[${ts}] ${nm}: ${text}`;
      list.appendChild(el);
    });
    list.scrollTop=list.scrollHeight;
  }catch(_){}
}
JS

# 初回のサーバー情報 HTML
mkdir -p "${DATA_DIR}"
if [[ ! -f "${DATA_DIR}/html_server.html" ]]; then
  cat > "${DATA_DIR}/html_server.html" <<'HTML'
<h1>サーバー情報</h1>
<p>ようこそ！<strong>OMF</strong></p>
<p>掲示は Web または外部 API（<code>/api/chat</code>）から送れます。</p>
HTML
fi

# map プレースホルダ
mkdir -p "${DATA_DIR}/map"
if [[ ! -f "${DATA_DIR}/map/index.html" ]]; then
  echo '<!doctype html><meta charset="utf-8"><p>uNmINeD の Web 出力がここに作成されます。</p>' > "${DATA_DIR}/map/index.html"
fi

# ---------- バックアップ（アドオン除外） ----------
cat > "${BASE}/backup_now.sh" <<'BASH'
#!/usr/bin/env bash
set -euo pipefail
BASE="$(cd "$(dirname "$0")" && pwd)"
OBJ="${BASE}/obj"
DATA="${OBJ}/data"
BKP="${BASE}/backups"
COMPOSE="${OBJ}/docker/compose.yml"

mkdir -p "${BKP}"
ts="$(date +%Y%m%d-%H%M%S)"
name="backup-${ts}.tar.gz"

echo "[INFO] stopping BDS..."
if [[ -f "${COMPOSE}" ]]; then docker compose -f "${COMPOSE}" stop bds || true; fi

echo "[INFO] packing world & configs (addons excluded)..."
cd "${OBJ}"
tar -czf "${BKP}/${name}" \
  --warning=no-file-changed \
  data/worlds/world/db \
  data/server.properties \
  data/allowlist.json \
  data/permissions.json \
  data/chat.json \
  data/players.json \
  data/map

echo "[INFO] starting BDS..."
if [[ -f "${COMPOSE}" ]]; then docker compose -f "${COMPOSE}" start bds || docker compose -f "${COMPOSE}" up -d bds; fi
echo "[OK] ${BKP}/${name}"
BASH
chmod +x "${BASE}/backup_now.sh"

# ---------- 復元（アドオンは現行ホストを再適用） ----------
cat > "${BASE}/restore_backup.sh" <<'BASH'
#!/usr/bin/env bash
set -euo pipefail
BASE="$(cd "$(dirname "$0")" && pwd)"
OBJ="${BASE}/obj"
DATA="${OBJ}/data"
BKP="${BASE}/backups"
COMPOSE="${OBJ}/docker/compose.yml"

shopt -s nullglob
files=( "${BKP}"/backup-*.tar.gz )
if (( ${#files[@]} == 0 )); then echo "[ERR] backups not found in ${BKP}"; exit 1; fi
IFS=$'\n' files=( $(ls -1t "${BKP}"/backup-*.tar.gz) ); unset IFS

echo "== バックアップ一覧 =="
idx=1
for f in "${files[@]}"; do
  ts="$(basename "$f" | sed -E 's/^backup-([0-9]{8}-[0-9]{6}).*/\1/')"
  mt="$(date -r "$f" '+%Y-%m-%d %H:%M:%S')"
  size="$(du -h "$f" | cut -f1)"
  printf "%2d) %s  (mtime: %s, size: %s)\n" "$idx" "$ts" "$mt" "$size"
  idx=$((idx+1))
done

read -rp "番号を選んでください: " sel
if ! [[ "$sel" =~ ^[0-9]+$ ]] || (( sel < 1 || sel > ${#files[@]} )); then echo "[ERR] invalid selection"; exit 2; fi
target="${files[$((sel-1))]}"

echo "[WARN] サーバーを停止して復元します。続行しますか？ (yes/no)"
read -r ans
if [[ "${ans}" != "yes" ]]; then echo "中止しました"; exit 0; fi

echo "[INFO] stopping stack..."
if [[ -f "${COMPOSE}" ]]; then docker compose -f "${COMPOSE}" down || true; fi

echo "[INFO] restoring from: ${target}"
mkdir -p "${OBJ}"
cd "${OBJ}"
rm -rf "${DATA}/worlds/world/db"
mkdir -p "${DATA}"
tar -xzf "${target}" -C "${OBJ}"

chown -R "$(id -u)":"$(id -g)" "${OBJ}"

echo "[INFO] starting stack..."
if [[ -f "${COMPOSE}" ]]; then docker compose -f "${COMPOSE}" up -d; fi

echo "[OK] 復元完了（アドオンは現行ホストの内容を起動時に再適用）"
BASH
chmod +x "${BASE}/restore_backup.sh"

# ---------- ビルド & 起動 ----------
echo "[BUILD] images..."
sudo docker compose -f "${DOCKER_DIR}/compose.yml" build --no-cache

echo "[PREFETCH] BDS payload ..."
sudo docker run --rm -e TZ=Asia/Tokyo \
  --entrypoint /usr/local/bin/get_bds.sh \
  -v "${DATA_DIR}:/data" \
  -v "${BASE}/resource:/ext/resource:ro" \
  -v "${BASE}/behavior:/ext/behavior:ro" \
  local/bds-box64:latest

echo "[UP] compose up -d ..."
sudo docker compose -f "${DOCKER_DIR}/compose.yml" up -d

cat <<'MSG'
== アクセス ==
Web:  http://<ホスト名またはIP>:13901/?token=YOUR_API_TOKEN
API:  curl -sS -H "x-api-key: ${API_TOKEN}" -H "Content-Type: application/json" \
          -d '{"message":"外部からこんにちは！","sender":"Webhook"}' \
          http://${MONITOR_BIND}:${MONITOR_PORT}/chat | jq .

== 確認 ==
curl -sS "http://${MONITOR_BIND}:${MONITOR_PORT}/health" | jq .
curl -sS -H "x-api-key: ${API_TOKEN}" "http://${MONITOR_BIND}:${MONITOR_PORT}/players" | jq .
curl -sS -H "x-api-key: ${API_TOKEN}" "http://${MONITOR_BIND}:${MONITOR_PORT}/chat" | jq .
curl -sS -H "x-api-key: ${API_TOKEN}" "http://${MONITOR_BIND}:${MONITOR_PORT}/allowlist/list" | jq .

== 備考 ==
- バックアップは ~/omf/survival-dkr/backups/ に保存（ALL_CLEAN でも保持）
- backup_now.sh はアドオンを含めません。復元後は起動時の update_addons.py が現行ホストのアドオンを適用します。
- BETA_ON=true で Script API beta 依存の BP が world に適用。false の場合は安全にスキップ。
- permissions.json は登録時に付与し、さらに起動時に allowlist と権限を一括再同期します。
MSG

