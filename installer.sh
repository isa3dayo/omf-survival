#!/usr/bin/env bash
# ============================================================================
# OMF bootstrap / top-level installer
# 役割:
#  - 初回: ディレクトリ雛形・README・.gitignore・key.conf(テンプレ) を生成
#  - 引数なし: install_script.sh を実行し、差分をコミット（pushはしない）
#  - 引数に semver を渡す: install_script.sh は実行せず、version.md を更新し commit & push
#    例)  ./installer.sh 1.0.2
# Git 対象: installer.sh, README.md, omf/ 以下（※ key.conf と obj/ は .gitignore で除外）
# ============================================================================
set -euo pipefail

USER_NAME="${SUDO_USER:-$USER}"
HOME_DIR="$(getent passwd "$USER_NAME" | cut -d: -f6)"
ROOT="${HOME_DIR}"
OMF_BASE="${HOME_DIR}/omf/survival-dkr"
SH_DIR="${OMF_BASE}/sh"
VER_DIR="${OMF_BASE}/ver"
KEY_DIR="${OMF_BASE}/key"
GIT_DIR="${OMF_BASE}/git"
OBJ_DIR="${OMF_BASE}/obj"

mkdir -p "${OMF_BASE}" "${SH_DIR}" "${VER_DIR}" "${KEY_DIR}" "${GIT_DIR}" "${OBJ_DIR}"

# --- README（なければ作成） ---
if [[ ! -f "${HOME_DIR}/README.md" ]]; then
  cat > "${HOME_DIR}/README.md" <<'MD'
# OMF (Omni Minecraft Fabric) — survival-dkr

## 構成
- `installer.sh` … トップレベルのブートストラップ
- `omf/survival-dkr/`
  - `sh/install_script.sh` … 一括セットアップ本体（Docker 完全版）
  - `key/key.conf` … 秘密/可変パラメータ（Git追跡**除外**）
  - `ver/version.md` … 変更履歴
  - `git/` … Git関連（将来のフックスクリプトやメモ等）
  - `obj/` … 展開先（Dockerfile/compose生成物, data 等・**Git追跡除外**）

## 運用
- `./installer.sh` … セットアップ実行（差分は commit）
- `./installer.sh 1.0.1` … セットアップは実行せず、`ver/version.md` に追記し commit & push
MD
fi

# --- .gitignore（トップレベル / HOME直下） ---
if [[ ! -f "${HOME_DIR}/.gitignore" ]]; then
  cat > "${HOME_DIR}/.gitignore" <<'IGN'
# 全体は無視してから必要なものだけ許可
*
!.gitignore
!README.md
!installer.sh
!omf/
# omf 以下の除外
omf/survival-dkr/key/key.conf
omf/survival-dkr/obj/
IGN
fi

# --- key.conf テンプレ（存在しなければ作成） ---
#if [[ ! -f "${KEY_DIR}/key.conf" ]]; then
#  cat > "${KEY_DIR}/key.conf" <<'CONF'
# ===== 必須 =====
#SERVER_NAME=""
#API_TOKEN=""
#GAS_URL=""

# ===== 公開面の制御（GitHubに固定ポートを晒したくない/環境で変える）=====
# Bedrockサーバ本体ポート（IPv4 / IPv6）
#BDS_PORT_V4=""
#BDS_PORT_V6=""

# 監視API（FastAPI）
#MONITOR_BIND=""   # 外に公開したくないのでデフォルトは localhost
#MONITOR_PORT=""

# Web（nginx, 静的UI）
#WEB_BIND=""         # 外に出す場合は0.0.0.0
#WEB_PORT=""

# オプション: BDS 固定URL（空なら毎回APIで最新取得）
# BDS_URL=""

# ===== GitHub 関連 =====
#GIT_USER_NAME=""
#GIT_USER_EMAIL=""
# SSH 推奨（例: git@github.com:yourname/dkr.git）
#GITHUB_REPO=""
#GIT_DEFAULT_BRANCH=""
#CONF
#  echo "[bootstrap] key.conf (template) created: ${KEY_DIR}/key.conf"
#fi

# --- version.md（存在しなければ作成） ---
if [[ ! -f "${VER_DIR}/version.md" ]]; then
  cat > "${VER_DIR}/version.md" <<'VER'
# OMF survival-dkr 変更履歴

- v1.0.1 (YYYY-MM-DD)
  - 追加: Docker 完全版の初版
  - 修正: 監視API/WEBのポート設定を key.conf へ移動
  - セキュリティ: monitor API を 127.0.0.1 にバインド（デフォルト）
VER
fi

# --- Git 初期化（HOME直下をワークツリーに） ---
cd "${ROOT}"
if [[ ! -d "${ROOT}/.git" ]]; then
  git init
  echo "[git] init repository at ${ROOT}"
fi

# key.conf 読み込み（Git情報）
# shellcheck disable=SC1090
source "${KEY_DIR}/key.conf"

git config user.name  "${GIT_USER_NAME}"
git config user.email "${GIT_USER_EMAIL}"

# リモート設定（存在しなければ追加）
if ! git remote | grep -qE '^origin$'; then
  if [[ -n "${GITHUB_REPO:-}" ]]; then
    git remote add origin "${GITHUB_REPO}"
    echo "[git] added origin: ${GITHUB_REPO}"
  fi
fi
# デフォルトブランチ作成（最初だけ）
current_branch="$(git branch --show-current || true)"
if [[ -z "${current_branch}" ]]; then
  git checkout -b "${GIT_DEFAULT_BRANCH:-main}"
fi

# --- 引数の判定 ---
SEMVER="${1:-}"

# 引数なし: セットアップ実行 → 変更を commit（pushはしない）
if [[ -z "${SEMVER}" ]]; then
  if [[ ! -x "${SH_DIR}/install_script.sh" ]]; then
    echo "[ERR] install_script.sh がありません: ${SH_DIR}/install_script.sh"
    exit 1
  fi
  echo "[run] ${SH_DIR}/install_script.sh"
  bash "${SH_DIR}/install_script.sh"

  git add installer.sh README.md .gitignore omf/
  git commit -m "chore: run install_script.sh and update generated files"
  echo "[git] committed (no push). 必要なら: git push -u origin $(git branch --show-current)"
  exit 0
fi

# 引数あり（semver っぽいか軽くチェック）
if ! grep -qE '^[0-9]+\.[0-9]+\.[0-9]+$' <<<"${SEMVER}"; then
  echo "[ERR] バージョン表記は semver で渡してください (例: 1.0.2)"; exit 1
fi

# install は実行せず、version.md を追記してコミット & push
ts="$(date +%Y-%m-%d)"
{
  echo ""
  echo "- v${SEMVER} (${ts})"
  echo "  - 変更: version bump"
} >> "${VER_DIR}/version.md"

git add installer.sh README.md .gitignore omf/
git commit -m "release: v${SEMVER}"
if git remote | grep -qE '^origin$'; then
  git push -u origin "$(git branch --show-current)"
  echo "[git] pushed to origin"
else
  echo "[git] origin 未設定のため push していません。"
fi


