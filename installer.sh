#!/usr/bin/env bash
# ============================================================================
# OMF bootstrap / top-level installer (NO key.conf generation + diff summary)
# 役割:
#  - 初回: ディレクトリ雛形・README・.gitignore を生成（key.conf は作らない）
#  - 引数なし: sh/install_script.sh を実行し、差分があれば commit（pushはしない）
#  - 引数に semver を渡す: install_script.sh は実行せず、version.md を更新し、
#           直近差分を要約追記 → commit & tag(vX.Y.Z) & push（origin があれば）
# Git 対象: installer.sh, README.md, omf/** （key.conf と obj/ は .gitignore で除外）
# ============================================================================
set -euo pipefail

# ---------- 共通パス ----------
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

# ---------- README（無ければ作成）----------
if [[ ! -f "${HOME_DIR}/README.md" ]]; then
  cat > "${HOME_DIR}/README.md" <<'MD'
# OMF (Omni Minecraft Fabric) — survival-dkr

## 構成
- `installer.sh` … トップレベルのブートストラップ
- `omf/survival-dkr/`
  - `sh/install_script.sh` … 一括セットアップ本体（Docker 完全版）
  - `key/key.conf` … 秘密/可変パラメータ（Git追跡**除外**・本スクリプトでは生成しません）
  - `ver/version.md` … 変更履歴
  - `git/` … Git関連
  - `obj/` … 展開先（Dockerfile/compose生成物, data 等・**Git追跡除外**）

## 運用
- `./installer.sh` … セットアップ実行（差分があれば commit）
- `./installer.sh 1.0.1` … セットアップは実行せず、`ver/version.md` に追記し commit & tag & push
MD
fi

# ---------- .gitignore（自動補正込み） ----------
if [[ ! -f "${HOME_DIR}/.gitignore" ]]; then
  cat > "${HOME_DIR}/.gitignore" <<'IGN'
# まず全て無視
*
# 明示的に許可するもの
!.gitignore
!README.md
!installer.sh
!omf/
!omf/**

# omf 内で Git 管理から外すもの
omf/survival-dkr/key/key.conf
omf/survival-dkr/obj/
IGN
else
  # 既存 .gitignore に必須ルールが無ければ追記（空行は追加しない）
  add_line() { grep -qF "$1" "${HOME_DIR}/.gitignore" || echo "$1" >> "${HOME_DIR}/.gitignore"; }
  add_line '!omf/**'
  add_line 'omf/survival-dkr/key/key.conf'
  add_line 'omf/survival-dkr/obj/'
fi

# ---------- version.md（存在しなければ作成） ----------
if [[ ! -f "${VER_DIR}/version.md" ]]; then
  cat > "${VER_DIR}/version.md" <<'VER'
# OMF survival-dkr 変更履歴

- v1.0.1 (YYYY-MM-DD)
  - 追加: Docker 完全版の初版
  - 修正: 監視API/WEBのポート設定を key.conf へ移動
  - セキュリティ: monitor API を 127.0.0.1 にバインド（デフォルト）
VER
fi

# ---------- Git 初期化 ----------
cd "${ROOT}"

# key.conf があれば Git の署名者などを設定（**生成はしない**）
if [[ -f "${KEY_DIR}/key.conf" ]]; then
  # shellcheck disable=SC1090
  source "${KEY_DIR}/key.conf"
  [[ -n "${GIT_USER_NAME:-}"  ]] && git config user.name  "${GIT_USER_NAME}"
  [[ -n "${GIT_USER_EMAIL:-}" ]] && git config user.email "${GIT_USER_EMAIL}"
else
  echo "[warn] ${KEY_DIR}/key.conf が見つかりません（Git設定はデフォルトを使用）。"
fi

DEFAULT_BRANCH="${GIT_DEFAULT_BRANCH:-main}"

if [[ ! -d "${ROOT}/.git" ]]; then
  if git init -b "${DEFAULT_BRANCH}" 2>/dev/null; then
    echo "[git] init repository (default branch: ${DEFAULT_BRANCH})"
  else
    git init
    git symbolic-ref HEAD "refs/heads/${DEFAULT_BRANCH}" || true
    echo "[git] init repository (HEAD -> ${DEFAULT_BRANCH})"
  fi
else
  if [[ -z "$(git rev-parse --verify HEAD 2>/dev/null || true)" ]]; then
    git symbolic-ref HEAD "refs/heads/${DEFAULT_BRANCH}" || true
    echo "[git] adjusted HEAD to ${DEFAULT_BRANCH}"
  fi
fi

# origin が未設定なら（key.conf に GITHUB_REPO があれば）追加
if ! git remote | grep -qE '^origin$'; then
  if [[ -n "${GITHUB_REPO:-}" ]]; then
    git remote add origin "${GITHUB_REPO}"
    echo "[git] added origin: ${GITHUB_REPO}"
  fi
fi

# もし現在ブランチが空の場合は checkout（初回のみ）
current_branch="$(git branch --show-current || true)"
if [[ -z "${current_branch}" ]]; then
  git checkout -B "${DEFAULT_BRANCH}"
fi

# ---------- 便利関数 ----------
have_staged_changes() { ! git diff --cached --quiet; }

# index に誤って乗った重い/秘匿ファイルを毎回外す（履歴は別途クリーニング済想定）
deindex_ignored_heavy() {
  git rm -r --cached --quiet omf/survival-dkr/obj 2>/dev/null || true
  git rm -r --cached --quiet omf/survival-dkr/key/key.conf 2>/dev/null || true
}

safe_commit() {
  local msg="$1"
  deindex_ignored_heavy
  git add installer.sh README.md .gitignore omf/
  if have_staged_changes; then
    git commit -m "${msg}" >/dev/null 2>&1 || {
      echo "[git] 変更なしのため commit はスキップ。"
      return 0
    }
    echo "[git] committed: ${msg}"
  else
    echo "[git] 変更なしのため commit はスキップ。"
  fi
}

get_latest_tag_or_empty() { git describe --tags --abbrev=0 2>/dev/null || echo ""; }

# 最後のタグ〜HEAD の差分要約（無ければ 1つ前のコミット〜HEAD）
make_diff_summary() {
  local base ref
  base="$(get_latest_tag_or_empty)"
  if [[ -n "$base" ]]; then
    ref="${base}..HEAD"
  else
    if git rev-parse HEAD~1 >/dev/null 2>&1; then
      ref="HEAD~1..HEAD"
    else
      echo "(初回のため差分はありません)"; return 0
    fi
  fi
  local names stat
  names="$(git diff --name-only "${ref}" -- 'installer.sh' 'omf/**' | sed 's/^/- /')"
  stat="$(git diff --stat "${ref}" -- 'installer.sh' 'omf/**')"
  if [[ -z "${names// }" ]]; then
    echo "(差分はありません)"; return 0
  fi
  {
    echo "  - 変更ファイル一覧:"
    echo "${names}" | sed 's/^/    /'
    echo "  - 変更サマリ(stat):"
    printf '%s\n' "${stat}" | sed 's/^/    /'
  }
}

safe_push_with_tag() {
  local semver="$1"
  local branch; branch="$(git branch --show-current)"
  if git rev-parse "v${semver}" >/dev/null 2>&1; then
    echo "[git] tag v${semver} は既に存在します（作成スキップ）。"
  else
    git tag -a "v${semver}" -m "release: v${semver}" || true
    echo "[git] created tag v${semver}"
  fi
  if git remote | grep -qE '^origin$'; then
    git push -u origin "${branch}" || true
    git push origin --tags || true
    echo "[git] pushed branch & tags"
  else
    echo "[git] origin 未設定のため push は実行しませんでした。"
    echo "      追加コマンド例:"
    echo "        git remote add origin git@github.com:<YOUR_NAME>/<REPO>.git"
    echo "        git push -u origin ${branch}"
    echo "        git push origin --tags"
  fi
}

# ---------- 引数の判定 ----------
SEMVER="${1:-}"

# 引数なし: セットアップ実行 → 差分があれば commit（push しない）
if [[ -z "${SEMVER}" ]]; then
  if [[ ! -x "${SH_DIR}/install_script.sh" ]]; then
    echo "[ERR] install_script.sh がありません: ${SH_DIR}/install_script.sh"
    exit 1
  fi
  echo "[run] ${SH_DIR}/install_script.sh"
  bash "${SH_DIR}/install_script.sh"
  safe_commit "chore: run install_script.sh and update generated files"
  exit 0
fi

# 引数あり（semver チェック）
if ! [[ "${SEMVER}" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  echo "[ERR] バージョン表記は semver で渡してください (例: 1.0.2)"; exit 1
fi

# install は実行せず、version.md を追記（差分要約も記載）
ts="$(date +%Y-%m-%d)"
new_line="- v${SEMVER} (${ts})"
if grep -qF "${new_line}" "${VER_DIR}/version.md"; then
  echo "[version] v${SEMVER} は既に version.md に存在します。"
else
  {
    echo ""
    echo "${new_line}"
    echo "  - 変更: version bump"
    make_diff_summary
  } >> "${VER_DIR}/version.md"
  echo "[version] version.md に v${SEMVER} と差分要約を追記しました。"
fi

safe_commit "release: v${SEMVER}"
safe_push_with_tag "${SEMVER}"

