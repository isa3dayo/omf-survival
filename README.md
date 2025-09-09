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
