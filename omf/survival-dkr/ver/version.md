# OMF survival-dkr 変更履歴

- v1.0.1 (YYYY-MM-DD)
  - 追加: Docker 完全版の初版
  - 修正: 監視API/WEBのポート設定を key.conf へ移動
  - セキュリティ: monitor API を 127.0.0.1 にバインド（デフォルト）

- v1.0.1 (2025-09-09)
  - 変更: version bump

- v1.0.1 (2025-09-09)
  - 変更: version bump

- v1.0.1 (2025-09-09)
  - 変更: version bump
(初回のため差分はありません)

- v1.0.3 (2025-09-09)
  - 変更: version bump
  - 変更ファイル一覧:
    - installer.sh
    - omf/survival-dkr/.gitignore
    - omf/survival-dkr/sh/install_script.sh
    - omf/survival-dkr/update_map.sh
    - omf/survival-dkr/ver/version.md
  - 変更サマリ(stat):
     installer.sh                          |    57 +-
     omf/survival-dkr/.gitignore           |     4 +
     omf/survival-dkr/sh/install_script.sh |    80 +-
     omf/survival-dkr/update_map.sh        |     2 +-
     omf/survival-dkr/ver/version.md       | 16330 --------------------------------
     5 files changed, 112 insertions(+), 16361 deletions(-)

- v1.0.4 (2025-09-09)
  - 変更: version bump
  - 変更ファイル一覧:
    - installer.sh
    - omf/survival-dkr/.gitignore
    - omf/survival-dkr/sh/install_script.sh
    - omf/survival-dkr/update_map.sh
    - omf/survival-dkr/ver/version.md
  - 変更サマリ(stat):
     installer.sh                          |    57 +-
     omf/survival-dkr/.gitignore           |     4 +
     omf/survival-dkr/sh/install_script.sh |   281 +-
     omf/survival-dkr/update_map.sh        |    13 +-
     omf/survival-dkr/ver/version.md       | 16332 +-------------------------------
     5 files changed, 252 insertions(+), 16435 deletions(-)

- v1.0.4 (2025-09-10)
  - 変更: version bump
  - 変更ファイル一覧:
    - omf/survival-dkr/sh/install_script.sh
  - 変更サマリ(stat):
     omf/survival-dkr/sh/install_script.sh | 359 ++++++++++++++++------------------
     1 file changed, 173 insertions(+), 186 deletions(-)

- v1.0.5 (2025-09-10)
  - 変更: version bump
  - 変更ファイル一覧:
    - omf/survival-dkr/sh/install_script.sh
    - omf/survival-dkr/update_map.sh
    - omf/survival-dkr/ver/version.md
  - 変更サマリ(stat):
     omf/survival-dkr/sh/install_script.sh | 614 +++++++++++++++-------------------
     omf/survival-dkr/update_map.sh        |   9 +-
     omf/survival-dkr/ver/version.md       |   8 +
     3 files changed, 285 insertions(+), 346 deletions(-)

- v1.0.6 (2025-09-10)
  - 変更: version bump
  - 変更ファイル一覧:
    - omf/survival-dkr/sh/install_script.sh
  - 変更サマリ(stat):
     omf/survival-dkr/sh/install_script.sh | 265 +++++++++++++---------------------
     1 file changed, 97 insertions(+), 168 deletions(-)

- v1.1.0 (2025-09-10)
  - 変更: version bump
  - 変更ファイル一覧:
    - omf/survival-dkr/sh/install_script.sh
    - omf/survival-dkr/update_map.sh
  - 変更サマリ(stat):
     omf/survival-dkr/sh/install_script.sh | 786 +++++++++++++++++++---------------
     omf/survival-dkr/update_map.sh        |  46 +-
     2 files changed, 478 insertions(+), 354 deletions(-)

- v1.1.1 (2025-09-10)
  - 変更: version bump
  - 変更ファイル一覧:
    - omf/survival-dkr/sh/install_script.sh
    - omf/survival-dkr/update_map.sh
  - 変更サマリ(stat):
     omf/survival-dkr/sh/install_script.sh | 274 +++++++++++++++++-----------------
     omf/survival-dkr/update_map.sh        |  51 ++++---
     2 files changed, 166 insertions(+), 159 deletions(-)

- v1.1.2 (2025-09-10)
  - 変更: version bump
(差分はありません)
