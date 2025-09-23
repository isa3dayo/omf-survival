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

- v1.1.3 (2025-09-10)
  - 変更: version bump
  - 変更ファイル一覧:
    - omf/survival-dkr/sh/install_script.sh
    - omf/survival-dkr/update_map.sh
  - 変更サマリ(stat):
     omf/survival-dkr/sh/install_script.sh | 70 +++++++++++++++++------------------
     omf/survival-dkr/update_map.sh        | 25 +++----------
     2 files changed, 40 insertions(+), 55 deletions(-)

- v1.1.4 (2025-09-10)
  - 変更: version bump
  - 変更ファイル一覧:
    - omf/survival-dkr/sh/install_script.sh
    - omf/survival-dkr/update_map.sh
  - 変更サマリ(stat):
     omf/survival-dkr/sh/install_script.sh | 143 +++++++++++++++++++---------------
     omf/survival-dkr/update_map.sh        |   5 +-
     2 files changed, 85 insertions(+), 63 deletions(-)

- v1.1.5 (2025-09-10)
  - 変更: version bump
  - 変更ファイル一覧:
    - omf/survival-dkr/sh/install_script.sh
    - omf/survival-dkr/update_map.sh
  - 変更サマリ(stat):
     omf/survival-dkr/sh/install_script.sh | 785 ++++++++++++++--------------------
     omf/survival-dkr/update_map.sh        |  67 +--
     2 files changed, 335 insertions(+), 517 deletions(-)

- v1.1.6 (2025-09-10)
  - 変更: version bump
  - 変更ファイル一覧:
    - omf/survival-dkr/sh/install_script.sh
    - omf/survival-dkr/update_map.sh
  - 変更サマリ(stat):
     omf/survival-dkr/sh/install_script.sh | 158 ++++++++++++++++++----------------
     omf/survival-dkr/update_map.sh        |  20 ++++-
     2 files changed, 102 insertions(+), 76 deletions(-)

- v1.1.7 (2025-09-10)
  - 変更: version bump
  - 変更ファイル一覧:
    - omf/survival-dkr/sh/install_script.sh
    - omf/survival-dkr/update_map.sh
  - 変更サマリ(stat):
     omf/survival-dkr/sh/install_script.sh | 137 ++++++++++++++++------------------
     omf/survival-dkr/update_map.sh        |  36 ++++++---
     2 files changed, 90 insertions(+), 83 deletions(-)

- v1.1.8 (2025-09-10)
  - 変更: version bump
(差分はありません)

- v1.1.9 (2025-09-10)
  - 変更: version bump
  - 変更ファイル一覧:
    - omf/survival-dkr/sh/install_script.sh
    - omf/survival-dkr/update_map.sh
  - 変更サマリ(stat):
     omf/survival-dkr/sh/install_script.sh | 296 ++++++++++++++++------------------
     omf/survival-dkr/update_map.sh        | 102 ++++--------
     2 files changed, 176 insertions(+), 222 deletions(-)

- v1.1.10 (2025-09-10)
  - 変更: version bump
  - 変更ファイル一覧:
    - omf/survival-dkr/sh/install_script.sh
    - omf/survival-dkr/update_map.sh
  - 変更サマリ(stat):
     omf/survival-dkr/sh/install_script.sh | 233 ++++++++++++++++++++++------------
     omf/survival-dkr/update_map.sh        | 119 +++++++++--------
     2 files changed, 212 insertions(+), 140 deletions(-)

- v1.1.11 (2025-09-10)
  - 変更: version bump
  - 変更ファイル一覧:
    - omf/survival-dkr/sh/install_script.sh
    - omf/survival-dkr/update_map.sh
  - 変更サマリ(stat):
     omf/survival-dkr/sh/install_script.sh | 512 ++++++++++++++++++----------------
     omf/survival-dkr/update_map.sh        | 229 +++++++++------
     2 files changed, 417 insertions(+), 324 deletions(-)

- v1.1.12 (2025-09-10)
  - 変更: version bump
  - 変更ファイル一覧:
    - omf/survival-dkr/sh/install_script.sh
    - omf/survival-dkr/update_map.sh
  - 変更サマリ(stat):
     omf/survival-dkr/sh/install_script.sh | 350 +++++++++++++++-------------------
     omf/survival-dkr/update_map.sh        |  35 +---
     2 files changed, 162 insertions(+), 223 deletions(-)

- v1.1.13 (2025-09-11)
  - 変更: version bump
  - 変更ファイル一覧:
    - omf/survival-dkr/sh/install_script.sh
    - omf/survival-dkr/update_map.sh
  - 変更サマリ(stat):
     omf/survival-dkr/sh/install_script.sh | 403 ++++++++++++++++++++--------------
     omf/survival-dkr/update_map.sh        |  24 +-
     2 files changed, 239 insertions(+), 188 deletions(-)

- v1.1.14 (2025-09-11)
  - 変更: version bump
  - 変更ファイル一覧:
    - omf/survival-dkr/sh/install_script.sh
    - omf/survival-dkr/update_map.sh
  - 変更サマリ(stat):
     omf/survival-dkr/sh/install_script.sh | 443 +++++++++++++++++-----------------
     omf/survival-dkr/update_map.sh        |  77 ++----
     2 files changed, 235 insertions(+), 285 deletions(-)

- v1.1.15 (2025-09-11)
  - 変更: version bump
  - 変更ファイル一覧:
    - omf/survival-dkr/sh/install_script.sh
    - omf/survival-dkr/update_map.sh
  - 変更サマリ(stat):
     omf/survival-dkr/sh/install_script.sh | 200 ++++++++++------------------------
     omf/survival-dkr/update_map.sh        |  40 ++-----
     2 files changed, 66 insertions(+), 174 deletions(-)

- v1.1.16 (2025-09-11)
  - 変更: version bump
  - 変更ファイル一覧:
    - omf/survival-dkr/sh/install_script.sh
    - omf/survival-dkr/update_map.sh
  - 変更サマリ(stat):
     omf/survival-dkr/sh/install_script.sh | 548 +++++++++++++++++++---------------
     omf/survival-dkr/update_map.sh        |  34 +--
     2 files changed, 314 insertions(+), 268 deletions(-)

- v1.1.17 (2025-09-11)
  - 変更: version bump
  - 変更ファイル一覧:
    - omf/survival-dkr/sh/install_script.sh
    - omf/survival-dkr/update_map.sh
  - 変更サマリ(stat):
     omf/survival-dkr/sh/install_script.sh | 105 +++++++++++++++++++---------------
     omf/survival-dkr/update_map.sh        |   1 -
     2 files changed, 59 insertions(+), 47 deletions(-)

- v1.1.18 (2025-09-11)
  - 変更: version bump
  - 変更ファイル一覧:
    - omf/survival-dkr/sh/install_script.sh
  - 変更サマリ(stat):
     omf/survival-dkr/sh/install_script.sh | 179 ++++++++++++++++++----------------
     1 file changed, 94 insertions(+), 85 deletions(-)

- v1.1.19 (2025-09-11)
  - 変更: version bump
  - 変更ファイル一覧:
    - omf/survival-dkr/sh/install_script.sh
    - omf/survival-dkr/update_map.sh
  - 変更サマリ(stat):
     omf/survival-dkr/sh/install_script.sh | 715 +++++++++++++---------------------
     omf/survival-dkr/update_map.sh        |  65 +++-
     2 files changed, 320 insertions(+), 460 deletions(-)

- v1.1.20 (2025-09-11)
  - 変更: version bump
(差分はありません)

- v1.1.21 (2025-09-11)
  - 変更: version bump
(差分はありません)

- v1.1.22 (2025-09-11)
  - 変更: version bump
  - 変更ファイル一覧:
    - omf/survival-dkr/sh/install_script.sh
    - omf/survival-dkr/update_map.sh
  - 変更サマリ(stat):
     omf/survival-dkr/sh/install_script.sh | 743 ++++++++++++++++++++--------------
     omf/survival-dkr/update_map.sh        |  48 ++-
     2 files changed, 467 insertions(+), 324 deletions(-)

- v1.1.23 (2025-09-11)
  - 変更: version bump
  - 変更ファイル一覧:
    - omf/survival-dkr/sh/install_script.sh
  - 変更サマリ(stat):
     omf/survival-dkr/sh/install_script.sh | 419 ++++++++++++----------------------
     1 file changed, 151 insertions(+), 268 deletions(-)

- v1.1.25 (2025-09-11)
  - 変更: version bump
  - 変更ファイル一覧:
    - omf/survival-dkr/sh/install_script.sh
  - 変更サマリ(stat):
     omf/survival-dkr/sh/install_script.sh | 157 ++++++++++++++++++++--------------
     1 file changed, 92 insertions(+), 65 deletions(-)

- v1.1.26 (2025-09-12)
  - 変更: version bump
  - 変更ファイル一覧:
    - omf/survival-dkr/sh/install_script.sh
  - 変更サマリ(stat):
     omf/survival-dkr/sh/install_script.sh | 865 +++++++++++++++++-----------------
     1 file changed, 434 insertions(+), 431 deletions(-)

- v1.1.27 (2025-09-12)
  - 変更: version bump
  - 変更ファイル一覧:
    - omf/survival-dkr/sh/install_script.sh
  - 変更サマリ(stat):
     omf/survival-dkr/sh/install_script.sh | 454 +++++++++++++++-------------------
     1 file changed, 195 insertions(+), 259 deletions(-)

- v1.1.28 (2025-09-12)
  - 変更: version bump
  - 変更ファイル一覧:
    - omf/survival-dkr/sh/install_script.sh
  - 変更サマリ(stat):
     omf/survival-dkr/sh/install_script.sh | 317 ++++++++++++++--------------------
     1 file changed, 127 insertions(+), 190 deletions(-)

- v1.1.29 (2025-09-12)
  - 変更: version bump
  - 変更ファイル一覧:
    - omf/survival-dkr/sh/install_script.sh
  - 変更サマリ(stat):
     omf/survival-dkr/sh/install_script.sh | 137 +++++++++++++++++++---------------
     1 file changed, 78 insertions(+), 59 deletions(-)

- v1.1.30 (2025-09-12)
  - 変更: version bump
  - 変更ファイル一覧:
    - omf/survival-dkr/sh/install_script.sh
    - omf/survival-dkr/update_map.sh
  - 変更サマリ(stat):
     omf/survival-dkr/sh/install_script.sh | 849 ++++++++++++++++++++++------------
     omf/survival-dkr/update_map.sh        |  99 +---
     2 files changed, 576 insertions(+), 372 deletions(-)

- v1.1.31 (2025-09-12)
  - 変更: version bump
(差分はありません)

- v1.2.0 (2025-09-12)
  - 変更: version bump
  - 変更ファイル一覧:
    - omf/survival-dkr/sh/install_script.sh
  - 変更サマリ(stat):
     omf/survival-dkr/sh/install_script.sh | 901 ++++++++++++++--------------------
     1 file changed, 382 insertions(+), 519 deletions(-)

- v1.2.1 (2025-09-12)
  - 変更: version bump
  - 変更ファイル一覧:
    - omf/survival-dkr/sh/install_script.sh
  - 変更サマリ(stat):
     omf/survival-dkr/sh/install_script.sh | 195 +++++++++++++++++-----------------
     1 file changed, 97 insertions(+), 98 deletions(-)

- v1.3.0 (2025-09-12)
  - 変更: version bump
  - 変更ファイル一覧:
    - omf/survival-dkr/sh/install_script.sh
  - 変更サマリ(stat):
     omf/survival-dkr/sh/install_script.sh | 141 ++++++++++++++++++++++------------
     1 file changed, 94 insertions(+), 47 deletions(-)

- v1.3.1 (2025-09-12)
  - 変更: version bump
  - 変更ファイル一覧:
    - omf/survival-dkr/behavior/omf_dimherb_bp/items/omf_dimherb.json
    - omf/survival-dkr/behavior/omf_dimherb_bp/manifest.json
    - omf/survival-dkr/behavior/omf_dimherb_bp/recipes/omf_dimherb.json
    - omf/survival-dkr/resource/omf_dimherb_rp/manifest.json
    - omf/survival-dkr/resource/omf_dimherb_rp/pack_icon.png
    - omf/survival-dkr/resource/omf_dimherb_rp/texts/en_US.lang
    - omf/survival-dkr/resource/omf_dimherb_rp/texts/ja_JP.lang
    - omf/survival-dkr/resource/omf_dimherb_rp/textures/item_texture.json
    - omf/survival-dkr/resource/omf_dimherb_rp/textures/items/omf_dimherb.png
    - omf/survival-dkr/sh/install_script.sh
  - 変更サマリ(stat):
     .../behavior/omf_dimherb_bp/items/omf_dimherb.json |  23 +++
     .../behavior/omf_dimherb_bp/manifest.json          |  24 +++
     .../omf_dimherb_bp/recipes/omf_dimherb.json        |  22 +++
     .../resource/omf_dimherb_rp/manifest.json          |  18 ++
     .../resource/omf_dimherb_rp/pack_icon.png          | Bin 0 -> 23511 bytes
     .../resource/omf_dimherb_rp/texts/en_US.lang       |   2 +
     .../resource/omf_dimherb_rp/texts/ja_JP.lang       |   1 +
     .../omf_dimherb_rp/textures/item_texture.json      |  10 +
     .../omf_dimherb_rp/textures/items/omf_dimherb.png  | Bin 0 -> 830 bytes
     omf/survival-dkr/sh/install_script.sh              | 216 +++++++++++++++------
     10 files changed, 253 insertions(+), 63 deletions(-)

- v1.3.2 (2025-09-12)
  - 変更: version bump
  - 変更ファイル一覧:
    - omf/survival-dkr/backup_now.sh
    - omf/survival-dkr/restore_backup.sh
    - omf/survival-dkr/sh/install_script.sh
  - 変更サマリ(stat):
     omf/survival-dkr/backup_now.sh        |  43 +++++--
     omf/survival-dkr/restore_backup.sh    |  63 ++++++++++
     omf/survival-dkr/sh/install_script.sh | 213 ++++++++++++++++++++++++----------
     3 files changed, 247 insertions(+), 72 deletions(-)

- v1.3.3 (2025-09-13)
  - 変更: version bump
  - 変更ファイル一覧:
    - omf/survival-dkr/backup_now.sh
    - omf/survival-dkr/behavior/omf_dimherb_bp/items/omf_dimherb.json
    - omf/survival-dkr/restore_backup.sh
    - omf/survival-dkr/sh/install_script.sh
  - 変更サマリ(stat):
     omf/survival-dkr/backup_now.sh                     |  19 +-
     .../behavior/omf_dimherb_bp/items/omf_dimherb.json |  15 +-
     omf/survival-dkr/restore_backup.sh                 |  30 +-
     omf/survival-dkr/sh/install_script.sh              | 432 ++++++++++++++-------
     4 files changed, 302 insertions(+), 194 deletions(-)

- v1.4.0 (2025-09-13)
  - 変更: version bump
(差分はありません)

- v1.4.1 (2025-09-13)
  - 変更: version bump
  - 変更ファイル一覧:
    - omf/survival-dkr/behavior/BP_magodosen/functions/build_ship.mcfunction
    - omf/survival-dkr/behavior/BP_magodosen/functions/lightproof.mcfunction
    - omf/survival-dkr/behavior/BP_magodosen/functions/place_signs.mcfunction
    - omf/survival-dkr/behavior/BP_magodosen/manifest.json
    - omf/survival-dkr/behavior/BP_magodosen/scripts/main.js
    - omf/survival-dkr/resource/RP_magodosen/manifest.json
    - omf/survival-dkr/restore_backup.sh
    - omf/survival-dkr/sh/install_script.sh
  - 変更サマリ(stat):
     .../BP_magodosen/functions/build_ship.mcfunction   |  6 --
     .../BP_magodosen/functions/lightproof.mcfunction   |  1 -
     .../BP_magodosen/functions/place_signs.mcfunction  |  7 --
     .../behavior/BP_magodosen/manifest.json            | 28 -------
     .../behavior/BP_magodosen/scripts/main.js          | 90 ----------------------
     .../resource/RP_magodosen/manifest.json            | 17 ----
     omf/survival-dkr/restore_backup.sh                 |  2 +
     omf/survival-dkr/sh/install_script.sh              | 39 ++++++----
     8 files changed, 25 insertions(+), 165 deletions(-)

- v1.4.2 (2025-09-13)
  - 変更: version bump
  - 変更ファイル一覧:
    - omf/survival-dkr/.backup.lock
    - omf/survival-dkr/backup.cron.log
    - omf/survival-dkr/backups/backup-20250913-073001.tar.gz
    - omf/survival-dkr/behavior/BP_magodosen/functions/build_ship.mcfunction
    - omf/survival-dkr/behavior/BP_magodosen/functions/lightproof.mcfunction
    - omf/survival-dkr/behavior/BP_magodosen/functions/magodosen/light_grid.mcfunction
    - omf/survival-dkr/behavior/BP_magodosen/functions/magodosen/ship_shape.mcfunction
    - omf/survival-dkr/behavior/BP_magodosen/functions/place_signs.mcfunction
    - omf/survival-dkr/behavior/BP_magodosen/manifest.json
    - omf/survival-dkr/behavior/BP_magodosen/scripts/main.js
    - omf/survival-dkr/behavior/omf_dimherb_bp/items/omf_dimherb.json
    - omf/survival-dkr/behavior/omf_dimherb_bp/manifest.json
    - omf/survival-dkr/behavior/omf_dimherb_bp/recipes/omf_dimherb.json
    - omf/survival-dkr/cleanup.cron.log
    - omf/survival-dkr/resource/RP_magodosen/manifest.json
    - omf/survival-dkr/resource/omf_dimherb_rp/manifest.json
    - omf/survival-dkr/resource/omf_dimherb_rp/pack_icon.png
    - omf/survival-dkr/resource/omf_dimherb_rp/texts/en_US.lang
    - omf/survival-dkr/resource/omf_dimherb_rp/texts/ja_JP.lang
    - omf/survival-dkr/resource/omf_dimherb_rp/textures/item_texture.json
    - omf/survival-dkr/resource/omf_dimherb_rp/textures/items/omf_dimherb.png
  - 変更サマリ(stat):
     omf/survival-dkr/.backup.lock                      |   0
     omf/survival-dkr/backup.cron.log                   |   9 +++
     .../backups/backup-20250913-073001.tar.gz          | Bin 0 -> 274 bytes
     .../BP_magodosen/functions/build_ship.mcfunction   |   9 ---
     .../BP_magodosen/functions/lightproof.mcfunction   |   2 -
     .../functions/magodosen/light_grid.mcfunction      |  37 +++++++++
     .../functions/magodosen/ship_shape.mcfunction      |  17 ++++
     .../BP_magodosen/functions/place_signs.mcfunction  |   4 -
     .../behavior/BP_magodosen/manifest.json            |  10 +--
     .../behavior/BP_magodosen/scripts/main.js          |  87 ++++++++++-----------
     .../behavior/omf_dimherb_bp/items/omf_dimherb.json |  22 ------
     .../behavior/omf_dimherb_bp/manifest.json          |  24 ------
     .../omf_dimherb_bp/recipes/omf_dimherb.json        |  22 ------
     omf/survival-dkr/cleanup.cron.log                  |   0
     .../resource/RP_magodosen/manifest.json            |   6 +-
     .../resource/omf_dimherb_rp/manifest.json          |  18 -----
     .../resource/omf_dimherb_rp/pack_icon.png          | Bin 23511 -> 0 bytes
     .../resource/omf_dimherb_rp/texts/en_US.lang       |   2 -
     .../resource/omf_dimherb_rp/texts/ja_JP.lang       |   1 -
     .../omf_dimherb_rp/textures/item_texture.json      |  10 ---
     .../omf_dimherb_rp/textures/items/omf_dimherb.png  | Bin 830 -> 0 bytes
     21 files changed, 113 insertions(+), 167 deletions(-)

- v1.5.0 (2025-09-13)
  - 変更: version bump
  - 変更ファイル一覧:
    - omf/survival-dkr/backup_now.sh
    - omf/survival-dkr/backups/backup-20250913-191650.tar.gz
    - omf/survival-dkr/behavior/BP_magodosen/functions/magodosen/light_grid.mcfunction
    - omf/survival-dkr/behavior/BP_magodosen/functions/magodosen/ship_shape.mcfunction
    - omf/survival-dkr/behavior/BP_magodosen/functions/magodosen/torch_grid.mcfunction
    - omf/survival-dkr/behavior/BP_magodosen/manifest.json
    - omf/survival-dkr/behavior/BP_magodosen/scripts/main.js
    - omf/survival-dkr/resource/RP_magodosen/manifest.json
    - omf/survival-dkr/restore_backup.sh
    - omf/survival-dkr/sh/install_script.sh
  - 変更サマリ(stat):
     omf/survival-dkr/backup_now.sh                     |   6 +-
     .../backups/backup-20250913-191650.tar.gz          | Bin 0 -> 24441636 bytes
     .../functions/magodosen/light_grid.mcfunction      |  37 --
     .../functions/magodosen/ship_shape.mcfunction      |  17 -
     .../functions/magodosen/torch_grid.mcfunction      |  37 ++
     .../behavior/BP_magodosen/manifest.json            |  10 +-
     .../behavior/BP_magodosen/scripts/main.js          |  61 +--
     .../resource/RP_magodosen/manifest.json            |   4 +-
     omf/survival-dkr/restore_backup.sh                 |  39 +-
     omf/survival-dkr/sh/install_script.sh              | 412 +++++++++++++++------
     10 files changed, 415 insertions(+), 208 deletions(-)

- v1.5.1 (2025-09-14)
  - 変更: version bump
  - 変更ファイル一覧:
    - omf/survival-dkr/behavior/BP_magodosen/functions/magodosen/torch_grid.mcfunction
    - omf/survival-dkr/behavior/BP_magodosen/manifest.json
    - omf/survival-dkr/behavior/BP_magodosen/scripts/main.js
    - omf/survival-dkr/resource/RP_magodosen/manifest.json
  - 変更サマリ(stat):
     .../functions/magodosen/torch_grid.mcfunction      | 37 ---------------
     .../behavior/BP_magodosen/manifest.json            | 54 ----------------------
     .../behavior/BP_magodosen/scripts/main.js          | 48 -------------------
     .../resource/RP_magodosen/manifest.json            | 29 ------------
     4 files changed, 168 deletions(-)

- v1.5.2 (2025-09-14)
  - 変更: version bump
  - 変更ファイル一覧:
    - omf/survival-dkr/sh/install_script.sh
  - 変更サマリ(stat):
     omf/survival-dkr/sh/install_script.sh | 257 ++++++++++++++++------------------
     1 file changed, 117 insertions(+), 140 deletions(-)

- v1.5.3 (2025-09-14)
  - 変更: version bump
  - 変更ファイル一覧:
    - omf/survival-dkr/backup_now.sh
    - omf/survival-dkr/behavior/FFLBehaviorPack/functions/acacia1.2.mcfunction
    - omf/survival-dkr/behavior/FFLBehaviorPack/functions/acacia1.mcfunction
    - omf/survival-dkr/behavior/FFLBehaviorPack/functions/acacia2.2.mcfunction
    - omf/survival-dkr/behavior/FFLBehaviorPack/functions/acacia2.mcfunction
    - omf/survival-dkr/behavior/FFLBehaviorPack/functions/acacia3.2.mcfunction
    - omf/survival-dkr/behavior/FFLBehaviorPack/functions/acacia3.mcfunction
    - omf/survival-dkr/behavior/FFLBehaviorPack/functions/acacia4.2.mcfunction
    - omf/survival-dkr/behavior/FFLBehaviorPack/functions/acacia4.mcfunction
    - omf/survival-dkr/behavior/FFLBehaviorPack/functions/acacia5.2.mcfunction
    - omf/survival-dkr/behavior/FFLBehaviorPack/functions/acacia5.mcfunction
    - omf/survival-dkr/behavior/FFLBehaviorPack/functions/acacia6.2.mcfunction
    - omf/survival-dkr/behavior/FFLBehaviorPack/functions/acacia6.mcfunction
    - omf/survival-dkr/behavior/FFLBehaviorPack/functions/acacia7.2.mcfunction
    - omf/survival-dkr/behavior/FFLBehaviorPack/functions/acacia7.mcfunction
    - omf/survival-dkr/behavior/FFLBehaviorPack/functions/acacia8.2.mcfunction
    - omf/survival-dkr/behavior/FFLBehaviorPack/functions/acacia8.mcfunction
    - omf/survival-dkr/behavior/FFLBehaviorPack/functions/acacia9.2.mcfunction
    - omf/survival-dkr/behavior/FFLBehaviorPack/functions/acacia9.mcfunction
    - omf/survival-dkr/behavior/FFLBehaviorPack/functions/azalea1.2.mcfunction
    - omf/survival-dkr/behavior/FFLBehaviorPack/functions/azalea1.mcfunction
    - omf/survival-dkr/behavior/FFLBehaviorPack/functions/azalea2.2.mcfunction
    - omf/survival-dkr/behavior/FFLBehaviorPack/functions/azalea2.mcfunction
    - omf/survival-dkr/behavior/FFLBehaviorPack/functions/azalea3.2.mcfunction
    - omf/survival-dkr/behavior/FFLBehaviorPack/functions/azalea3.mcfunction
    - omf/survival-dkr/behavior/FFLBehaviorPack/functions/azalea4.2.mcfunction
    - omf/survival-dkr/behavior/FFLBehaviorPack/functions/azalea4.mcfunction
    - omf/survival-dkr/behavior/FFLBehaviorPack/functions/azalea5.2.mcfunction
    - omf/survival-dkr/behavior/FFLBehaviorPack/functions/azalea5.mcfunction
    - omf/survival-dkr/behavior/FFLBehaviorPack/functions/azalea6.2.mcfunction
    - omf/survival-dkr/behavior/FFLBehaviorPack/functions/azalea6.mcfunction
    - omf/survival-dkr/behavior/FFLBehaviorPack/functions/azalea7.2.mcfunction
    - omf/survival-dkr/behavior/FFLBehaviorPack/functions/azalea7.mcfunction
    - omf/survival-dkr/behavior/FFLBehaviorPack/functions/azalea8.2.mcfunction
    - omf/survival-dkr/behavior/FFLBehaviorPack/functions/azalea8.mcfunction
    - omf/survival-dkr/behavior/FFLBehaviorPack/functions/azalea9.2.mcfunction
    - omf/survival-dkr/behavior/FFLBehaviorPack/functions/azalea9.mcfunction
    - omf/survival-dkr/behavior/FFLBehaviorPack/functions/azaleaflowered1.2.mcfunction
    - omf/survival-dkr/behavior/FFLBehaviorPack/functions/azaleaflowered1.mcfunction
    - omf/survival-dkr/behavior/FFLBehaviorPack/functions/azaleaflowered2.2.mcfunction
    - omf/survival-dkr/behavior/FFLBehaviorPack/functions/azaleaflowered2.mcfunction
    - omf/survival-dkr/behavior/FFLBehaviorPack/functions/azaleaflowered3.2.mcfunction
    - omf/survival-dkr/behavior/FFLBehaviorPack/functions/azaleaflowered3.mcfunction
    - omf/survival-dkr/behavior/FFLBehaviorPack/functions/azaleaflowered4.2.mcfunction
    - omf/survival-dkr/behavior/FFLBehaviorPack/functions/azaleaflowered4.mcfunction
    - omf/survival-dkr/behavior/FFLBehaviorPack/functions/azaleaflowered5.2.mcfunction
    - omf/survival-dkr/behavior/FFLBehaviorPack/functions/azaleaflowered5.mcfunction
    - omf/survival-dkr/behavior/FFLBehaviorPack/functions/azaleaflowered6.2.mcfunction
    - omf/survival-dkr/behavior/FFLBehaviorPack/functions/azaleaflowered6.mcfunction
    - omf/survival-dkr/behavior/FFLBehaviorPack/functions/azaleaflowered7.2.mcfunction
    - omf/survival-dkr/behavior/FFLBehaviorPack/functions/azaleaflowered7.mcfunction
    - omf/survival-dkr/behavior/FFLBehaviorPack/functions/azaleaflowered8.2.mcfunction
    - omf/survival-dkr/behavior/FFLBehaviorPack/functions/azaleaflowered8.mcfunction
    - omf/survival-dkr/behavior/FFLBehaviorPack/functions/azaleaflowered9.2.mcfunction
    - omf/survival-dkr/behavior/FFLBehaviorPack/functions/azaleaflowered9.mcfunction
    - omf/survival-dkr/behavior/FFLBehaviorPack/functions/birch1.2.mcfunction
    - omf/survival-dkr/behavior/FFLBehaviorPack/functions/birch1.mcfunction
    - omf/survival-dkr/behavior/FFLBehaviorPack/functions/birch2.2.mcfunction
    - omf/survival-dkr/behavior/FFLBehaviorPack/functions/birch2.mcfunction
    - omf/survival-dkr/behavior/FFLBehaviorPack/functions/birch3.2.mcfunction
    - omf/survival-dkr/behavior/FFLBehaviorPack/functions/birch3.mcfunction
    - omf/survival-dkr/behavior/FFLBehaviorPack/functions/birch4.2.mcfunction
    - omf/survival-dkr/behavior/FFLBehaviorPack/functions/birch4.mcfunction
    - omf/survival-dkr/behavior/FFLBehaviorPack/functions/birch5.2.mcfunction
    - omf/survival-dkr/behavior/FFLBehaviorPack/functions/birch5.mcfunction
    - omf/survival-dkr/behavior/FFLBehaviorPack/functions/birch6.2.mcfunction
    - omf/survival-dkr/behavior/FFLBehaviorPack/functions/birch6.mcfunction
    - omf/survival-dkr/behavior/FFLBehaviorPack/functions/birch7.2.mcfunction
    - omf/survival-dkr/behavior/FFLBehaviorPack/functions/birch7.mcfunction
    - omf/survival-dkr/behavior/FFLBehaviorPack/functions/birch8.2.mcfunction
    - omf/survival-dkr/behavior/FFLBehaviorPack/functions/birch8.mcfunction
    - omf/survival-dkr/behavior/FFLBehaviorPack/functions/birch9.2.mcfunction
    - omf/survival-dkr/behavior/FFLBehaviorPack/functions/birch9.mcfunction
    - omf/survival-dkr/behavior/FFLBehaviorPack/functions/dark_oak1.2.mcfunction
    - omf/survival-dkr/behavior/FFLBehaviorPack/functions/dark_oak1.mcfunction
    - omf/survival-dkr/behavior/FFLBehaviorPack/functions/dark_oak2.2.mcfunction
    - omf/survival-dkr/behavior/FFLBehaviorPack/functions/dark_oak2.mcfunction
    - omf/survival-dkr/behavior/FFLBehaviorPack/functions/dark_oak3.2.mcfunction
    - omf/survival-dkr/behavior/FFLBehaviorPack/functions/dark_oak3.mcfunction
    - omf/survival-dkr/behavior/FFLBehaviorPack/functions/dark_oak4.2.mcfunction
    - omf/survival-dkr/behavior/FFLBehaviorPack/functions/dark_oak4.mcfunction
    - omf/survival-dkr/behavior/FFLBehaviorPack/functions/dark_oak5.2.mcfunction
    - omf/survival-dkr/behavior/FFLBehaviorPack/functions/dark_oak5.mcfunction
    - omf/survival-dkr/behavior/FFLBehaviorPack/functions/dark_oak6.2.mcfunction
    - omf/survival-dkr/behavior/FFLBehaviorPack/functions/dark_oak6.mcfunction
    - omf/survival-dkr/behavior/FFLBehaviorPack/functions/dark_oak7.2.mcfunction
    - omf/survival-dkr/behavior/FFLBehaviorPack/functions/dark_oak7.mcfunction
    - omf/survival-dkr/behavior/FFLBehaviorPack/functions/dark_oak8.2.mcfunction
    - omf/survival-dkr/behavior/FFLBehaviorPack/functions/dark_oak8.mcfunction
    - omf/survival-dkr/behavior/FFLBehaviorPack/functions/dark_oak9.2.mcfunction
    - omf/survival-dkr/behavior/FFLBehaviorPack/functions/dark_oak9.mcfunction
    - omf/survival-dkr/behavior/FFLBehaviorPack/functions/jungle1.2.mcfunction
    - omf/survival-dkr/behavior/FFLBehaviorPack/functions/jungle1.mcfunction
    - omf/survival-dkr/behavior/FFLBehaviorPack/functions/jungle2.2.mcfunction
    - omf/survival-dkr/behavior/FFLBehaviorPack/functions/jungle2.mcfunction
    - omf/survival-dkr/behavior/FFLBehaviorPack/functions/jungle3.2.mcfunction
    - omf/survival-dkr/behavior/FFLBehaviorPack/functions/jungle3.mcfunction
    - omf/survival-dkr/behavior/FFLBehaviorPack/functions/jungle4.2.mcfunction
    - omf/survival-dkr/behavior/FFLBehaviorPack/functions/jungle4.mcfunction
    - omf/survival-dkr/behavior/FFLBehaviorPack/functions/jungle5.2.mcfunction
    - omf/survival-dkr/behavior/FFLBehaviorPack/functions/jungle5.mcfunction
    - omf/survival-dkr/behavior/FFLBehaviorPack/functions/jungle6.2.mcfunction
    - omf/survival-dkr/behavior/FFLBehaviorPack/functions/jungle6.mcfunction
    - omf/survival-dkr/behavior/FFLBehaviorPack/functions/jungle7.2.mcfunction
    - omf/survival-dkr/behavior/FFLBehaviorPack/functions/jungle7.mcfunction
    - omf/survival-dkr/behavior/FFLBehaviorPack/functions/jungle8.2.mcfunction
    - omf/survival-dkr/behavior/FFLBehaviorPack/functions/jungle8.mcfunction
    - omf/survival-dkr/behavior/FFLBehaviorPack/functions/jungle9.2.mcfunction
    - omf/survival-dkr/behavior/FFLBehaviorPack/functions/jungle9.mcfunction
    - omf/survival-dkr/behavior/FFLBehaviorPack/functions/mangrove1.2.mcfunction
    - omf/survival-dkr/behavior/FFLBehaviorPack/functions/mangrove1.mcfunction
    - omf/survival-dkr/behavior/FFLBehaviorPack/functions/mangrove2.2.mcfunction
    - omf/survival-dkr/behavior/FFLBehaviorPack/functions/mangrove2.mcfunction
    - omf/survival-dkr/behavior/FFLBehaviorPack/functions/mangrove3.2.mcfunction
    - omf/survival-dkr/behavior/FFLBehaviorPack/functions/mangrove3.mcfunction
    - omf/survival-dkr/behavior/FFLBehaviorPack/functions/mangrove4.2.mcfunction
    - omf/survival-dkr/behavior/FFLBehaviorPack/functions/mangrove4.mcfunction
    - omf/survival-dkr/behavior/FFLBehaviorPack/functions/mangrove5.2.mcfunction
    - omf/survival-dkr/behavior/FFLBehaviorPack/functions/mangrove5.mcfunction
    - omf/survival-dkr/behavior/FFLBehaviorPack/functions/mangrove6.2.mcfunction
    - omf/survival-dkr/behavior/FFLBehaviorPack/functions/mangrove6.mcfunction
    - omf/survival-dkr/behavior/FFLBehaviorPack/functions/mangrove7.2.mcfunction
    - omf/survival-dkr/behavior/FFLBehaviorPack/functions/mangrove7.mcfunction
    - omf/survival-dkr/behavior/FFLBehaviorPack/functions/mangrove8.2.mcfunction
    - omf/survival-dkr/behavior/FFLBehaviorPack/functions/mangrove8.mcfunction
    - omf/survival-dkr/behavior/FFLBehaviorPack/functions/mangrove9.2.mcfunction
    - omf/survival-dkr/behavior/FFLBehaviorPack/functions/mangrove9.mcfunction
    - omf/survival-dkr/behavior/FFLBehaviorPack/functions/megafused.mcfunction
    - omf/survival-dkr/behavior/FFLBehaviorPack/functions/oak1.2.mcfunction
    - omf/survival-dkr/behavior/FFLBehaviorPack/functions/oak1.mcfunction
    - omf/survival-dkr/behavior/FFLBehaviorPack/functions/oak2.2.mcfunction
    - omf/survival-dkr/behavior/FFLBehaviorPack/functions/oak2.mcfunction
    - omf/survival-dkr/behavior/FFLBehaviorPack/functions/oak3.2.mcfunction
    - omf/survival-dkr/behavior/FFLBehaviorPack/functions/oak3.mcfunction
    - omf/survival-dkr/behavior/FFLBehaviorPack/functions/oak4.2.mcfunction
    - omf/survival-dkr/behavior/FFLBehaviorPack/functions/oak4.mcfunction
    - omf/survival-dkr/behavior/FFLBehaviorPack/functions/oak5.2.mcfunction
    - omf/survival-dkr/behavior/FFLBehaviorPack/functions/oak5.mcfunction
    - omf/survival-dkr/behavior/FFLBehaviorPack/functions/oak6.2.mcfunction
    - omf/survival-dkr/behavior/FFLBehaviorPack/functions/oak6.mcfunction
    - omf/survival-dkr/behavior/FFLBehaviorPack/functions/oak7.2.mcfunction
    - omf/survival-dkr/behavior/FFLBehaviorPack/functions/oak7.mcfunction
    - omf/survival-dkr/behavior/FFLBehaviorPack/functions/oak8.2.mcfunction
    - omf/survival-dkr/behavior/FFLBehaviorPack/functions/oak8.mcfunction
    - omf/survival-dkr/behavior/FFLBehaviorPack/functions/oak9.2.mcfunction
    - omf/survival-dkr/behavior/FFLBehaviorPack/functions/oak9.mcfunction
    - omf/survival-dkr/behavior/FFLBehaviorPack/functions/spruce1.2.mcfunction
    - omf/survival-dkr/behavior/FFLBehaviorPack/functions/spruce1.mcfunction
    - omf/survival-dkr/behavior/FFLBehaviorPack/functions/spruce2.2.mcfunction
    - omf/survival-dkr/behavior/FFLBehaviorPack/functions/spruce2.mcfunction
    - omf/survival-dkr/behavior/FFLBehaviorPack/functions/spruce3.2.mcfunction
    - omf/survival-dkr/behavior/FFLBehaviorPack/functions/spruce3.mcfunction
    - omf/survival-dkr/behavior/FFLBehaviorPack/functions/spruce4.2.mcfunction
    - omf/survival-dkr/behavior/FFLBehaviorPack/functions/spruce4.mcfunction
    - omf/survival-dkr/behavior/FFLBehaviorPack/functions/spruce5.2.mcfunction
    - omf/survival-dkr/behavior/FFLBehaviorPack/functions/spruce5.mcfunction
    - omf/survival-dkr/behavior/FFLBehaviorPack/functions/spruce6.2.mcfunction
    - omf/survival-dkr/behavior/FFLBehaviorPack/functions/spruce6.mcfunction
    - omf/survival-dkr/behavior/FFLBehaviorPack/functions/spruce7.2.mcfunction
    - omf/survival-dkr/behavior/FFLBehaviorPack/functions/spruce7.mcfunction
    - omf/survival-dkr/behavior/FFLBehaviorPack/functions/spruce8.2.mcfunction
    - omf/survival-dkr/behavior/FFLBehaviorPack/functions/spruce8.mcfunction
    - omf/survival-dkr/behavior/FFLBehaviorPack/functions/spruce9.2.mcfunction
    - omf/survival-dkr/behavior/FFLBehaviorPack/functions/spruce9.mcfunction
    - omf/survival-dkr/behavior/FFLBehaviorPack/functions/tick.json
    - omf/survival-dkr/behavior/FFLBehaviorPack/manifest.json
    - omf/survival-dkr/behavior/FFLBehaviorPack/pack_icon.png
    - omf/survival-dkr/behavior/RaiyonsDyBe/blocks/torches/black_torch.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/blocks/torches/blue_torch.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/blocks/torches/brown_torch.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/blocks/torches/cyan_torch.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/blocks/torches/gray_torch.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/blocks/torches/green_torch.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/blocks/torches/light_blue_torch.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/blocks/torches/light_gray_torch.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/blocks/torches/lime_torch.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/blocks/torches/magenta_torch.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/blocks/torches/orange_torch.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/blocks/torches/pink_torch.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/blocks/torches/purple_torch.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/blocks/torches/red_torch.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/blocks/torches/white_torch.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/blocks/torches/yellow_torch.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/functions/player.mcfunction
    - omf/survival-dkr/behavior/RaiyonsDyBe/functions/tick.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/item_catalog/crafting_item_catalog.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/items/dyed_helmets/chain/chainmail_black_torch_helmet.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/items/dyed_helmets/chain/chainmail_blue_torch_helmet.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/items/dyed_helmets/chain/chainmail_brown_torch_helmet.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/items/dyed_helmets/chain/chainmail_cyan_torch_helmet.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/items/dyed_helmets/chain/chainmail_gray_torch_helmet.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/items/dyed_helmets/chain/chainmail_green_torch_helmet.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/items/dyed_helmets/chain/chainmail_light_blue_torch_helmet.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/items/dyed_helmets/chain/chainmail_light_gray_torch_helmet.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/items/dyed_helmets/chain/chainmail_lime_torch_helmet.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/items/dyed_helmets/chain/chainmail_magenta_torch_helmet.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/items/dyed_helmets/chain/chainmail_orange_torch_helmet.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/items/dyed_helmets/chain/chainmail_pink_torch_helmet.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/items/dyed_helmets/chain/chainmail_purple_torch_helmet.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/items/dyed_helmets/chain/chainmail_red_torch_helmet.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/items/dyed_helmets/chain/chainmail_redstone_torch_helmet.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/items/dyed_helmets/chain/chainmail_sea_torch_helmet.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/items/dyed_helmets/chain/chainmail_soul_torch_helmet.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/items/dyed_helmets/chain/chainmail_white_torch_helmet.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/items/dyed_helmets/chain/chainmail_yellow_torch_helmet.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/items/dyed_helmets/diamond/diamond_black_torch_helmet.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/items/dyed_helmets/diamond/diamond_blue_torch_helmet.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/items/dyed_helmets/diamond/diamond_brown_torch_helmet.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/items/dyed_helmets/diamond/diamond_cyan_torch_helmet.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/items/dyed_helmets/diamond/diamond_gray_torch_helmet.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/items/dyed_helmets/diamond/diamond_green_torch_helmet.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/items/dyed_helmets/diamond/diamond_light_blue_torch_helmet.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/items/dyed_helmets/diamond/diamond_light_gray_torch_helmet.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/items/dyed_helmets/diamond/diamond_lime_torch_helmet.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/items/dyed_helmets/diamond/diamond_magenta_torch_helmet.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/items/dyed_helmets/diamond/diamond_orange_torch_helmet.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/items/dyed_helmets/diamond/diamond_pink_torch_helmet.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/items/dyed_helmets/diamond/diamond_purple_torch_helmet.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/items/dyed_helmets/diamond/diamond_red_torch_helmet.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/items/dyed_helmets/diamond/diamond_redstone_torch_helmet.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/items/dyed_helmets/diamond/diamond_sea_torch_helmet.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/items/dyed_helmets/diamond/diamond_soul_torch_helmet.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/items/dyed_helmets/diamond/diamond_white_torch_helmet.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/items/dyed_helmets/diamond/diamond_yellow_torch_helmet.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/items/dyed_helmets/gold/golden_black_torch_helmet.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/items/dyed_helmets/gold/golden_blue_torch_helmet.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/items/dyed_helmets/gold/golden_brown_torch_helmet.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/items/dyed_helmets/gold/golden_cyan_torch_helmet.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/items/dyed_helmets/gold/golden_gray_torch_helmet.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/items/dyed_helmets/gold/golden_green_torch_helmet.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/items/dyed_helmets/gold/golden_light_blue_torch_helmet.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/items/dyed_helmets/gold/golden_light_gray_torch_helmet.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/items/dyed_helmets/gold/golden_lime_torch_helmet.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/items/dyed_helmets/gold/golden_magenta_torch_helmet.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/items/dyed_helmets/gold/golden_orange_torch_helmet.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/items/dyed_helmets/gold/golden_pink_torch_helmet.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/items/dyed_helmets/gold/golden_purple_torch_helmet.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/items/dyed_helmets/gold/golden_red_torch_helmet.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/items/dyed_helmets/gold/golden_redstone_torch_helmet.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/items/dyed_helmets/gold/golden_sea_torch_helmet.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/items/dyed_helmets/gold/golden_soul_torch_helmet.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/items/dyed_helmets/gold/golden_white_torch_helmet.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/items/dyed_helmets/gold/golden_yellow_torch_helmet.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/items/dyed_helmets/iron/iron_black_torch_helmet.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/items/dyed_helmets/iron/iron_blue_torch_helmet.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/items/dyed_helmets/iron/iron_brown_torch_helmet.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/items/dyed_helmets/iron/iron_cyan_torch_helmet.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/items/dyed_helmets/iron/iron_gray_torch_helmet.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/items/dyed_helmets/iron/iron_green_torch_helmet.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/items/dyed_helmets/iron/iron_light_blue_torch_helmet.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/items/dyed_helmets/iron/iron_light_gray_torch_helmet.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/items/dyed_helmets/iron/iron_lime_torch_helmet.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/items/dyed_helmets/iron/iron_magenta_torch_helmet.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/items/dyed_helmets/iron/iron_orange_torch_helmet.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/items/dyed_helmets/iron/iron_pink_torch_helmet.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/items/dyed_helmets/iron/iron_purple_torch_helmet.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/items/dyed_helmets/iron/iron_red_torch_helmet.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/items/dyed_helmets/iron/iron_redstone_torch_helmet.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/items/dyed_helmets/iron/iron_sea_torch_helmet.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/items/dyed_helmets/iron/iron_soul_torch_helmet.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/items/dyed_helmets/iron/iron_white_torch_helmet.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/items/dyed_helmets/iron/iron_yellow_torch_helmet.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/items/dyed_helmets/leather/leather_black_torch_helmet.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/items/dyed_helmets/leather/leather_blue_torch_helmet.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/items/dyed_helmets/leather/leather_brown_torch_helmet.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/items/dyed_helmets/leather/leather_cyan_torch_helmet.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/items/dyed_helmets/leather/leather_gray_torch_helmet.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/items/dyed_helmets/leather/leather_green_torch_helmet.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/items/dyed_helmets/leather/leather_light_blue_torch_helmet.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/items/dyed_helmets/leather/leather_light_gray_torch_helmet.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/items/dyed_helmets/leather/leather_lime_torch_helmet.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/items/dyed_helmets/leather/leather_magenta_torch_helmet.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/items/dyed_helmets/leather/leather_orange_torch_helmet.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/items/dyed_helmets/leather/leather_pink_torch_helmet.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/items/dyed_helmets/leather/leather_purple_torch_helmet.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/items/dyed_helmets/leather/leather_red_torch_helmet.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/items/dyed_helmets/leather/leather_redstone_torch_helmet.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/items/dyed_helmets/leather/leather_sea_torch_helmet.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/items/dyed_helmets/leather/leather_soul_torch_helmet.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/items/dyed_helmets/leather/leather_white_torch_helmet.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/items/dyed_helmets/leather/leather_yellow_torch_helmet.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/items/dyed_helmets/netherite/netherite_black_torch_helmet.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/items/dyed_helmets/netherite/netherite_blue_torch_helmet.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/items/dyed_helmets/netherite/netherite_brown_torch_helmet.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/items/dyed_helmets/netherite/netherite_cyan_torch_helmet.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/items/dyed_helmets/netherite/netherite_gray_torch_helmet.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/items/dyed_helmets/netherite/netherite_green_torch_helmet.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/items/dyed_helmets/netherite/netherite_light_blue_torch_helmet.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/items/dyed_helmets/netherite/netherite_light_gray_torch_helmet.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/items/dyed_helmets/netherite/netherite_lime_torch_helmet.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/items/dyed_helmets/netherite/netherite_magenta_torch_helmet.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/items/dyed_helmets/netherite/netherite_orange_torch_helmet.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/items/dyed_helmets/netherite/netherite_pink_torch_helmet.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/items/dyed_helmets/netherite/netherite_purple_torch_helmet.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/items/dyed_helmets/netherite/netherite_red_torch_helmet.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/items/dyed_helmets/netherite/netherite_redstone_torch_helmet.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/items/dyed_helmets/netherite/netherite_sea_torch_helmet.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/items/dyed_helmets/netherite/netherite_soul_torch_helmet.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/items/dyed_helmets/netherite/netherite_white_torch_helmet.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/items/dyed_helmets/netherite/netherite_yellow_torch_helmet.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/items/dyed_helmets/turtle/turtle_black_torch_helmet.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/items/dyed_helmets/turtle/turtle_blue_torch_helmet.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/items/dyed_helmets/turtle/turtle_brown_torch_helmet.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/items/dyed_helmets/turtle/turtle_cyan_torch_helmet.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/items/dyed_helmets/turtle/turtle_gray_torch_helmet.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/items/dyed_helmets/turtle/turtle_green_torch_helmet.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/items/dyed_helmets/turtle/turtle_light_blue_torch_helmet.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/items/dyed_helmets/turtle/turtle_light_gray_torch_helmet.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/items/dyed_helmets/turtle/turtle_lime_torch_helmet.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/items/dyed_helmets/turtle/turtle_magenta_torch_helmet.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/items/dyed_helmets/turtle/turtle_orange_torch_helmet.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/items/dyed_helmets/turtle/turtle_pink_torch_helmet.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/items/dyed_helmets/turtle/turtle_purple_torch_helmet.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/items/dyed_helmets/turtle/turtle_red_torch_helmet.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/items/dyed_helmets/turtle/turtle_redstone_torch_helmet.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/items/dyed_helmets/turtle/turtle_sea_torch_helmet.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/items/dyed_helmets/turtle/turtle_soul_torch_helmet.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/items/dyed_helmets/turtle/turtle_white_torch_helmet.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/items/dyed_helmets/turtle/turtle_yellow_torch_helmet.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/items/helmets/chainmail.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/items/helmets/diamond.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/items/helmets/gold.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/items/helmets/iron.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/items/helmets/leather.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/items/helmets/netherite.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/items/helmets/turtle.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/items/torches/dyed/black_torch_item.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/items/torches/dyed/blue_torch_item.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/items/torches/dyed/brown_torch_item.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/items/torches/dyed/cyan_torch_item.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/items/torches/dyed/gray_torch_item.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/items/torches/dyed/green_torch_item.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/items/torches/dyed/light_blue_torch_item.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/items/torches/dyed/light_gray_torch_item.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/items/torches/dyed/lime_torch_item.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/items/torches/dyed/magenta_torch_item.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/items/torches/dyed/orange_torch_item.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/items/torches/dyed/pink_torch_item.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/items/torches/dyed/purple_torch_item.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/items/torches/dyed/red_torch_item.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/items/torches/dyed/white_torch_item.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/items/torches/dyed/yellow_torch_item.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/items/torches/sea_torch.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/manifest.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/pack_icon.png
    - omf/survival-dkr/behavior/RaiyonsDyBe/recipes/dyed_helmets/chainmail_black_torch_helmet_recipe.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/recipes/dyed_helmets/chainmail_blue_torch_helmet_recipe.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/recipes/dyed_helmets/chainmail_brown_torch_helmet_recipe.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/recipes/dyed_helmets/chainmail_cyan_torch_helmet_recipe.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/recipes/dyed_helmets/chainmail_gray_torch_helmet_recipe.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/recipes/dyed_helmets/chainmail_green_torch_helmet_recipe.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/recipes/dyed_helmets/chainmail_light_blue_torch_helmet_recipe.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/recipes/dyed_helmets/chainmail_light_gray_torch_helmet_recipe.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/recipes/dyed_helmets/chainmail_lime_torch_helmet_recipe.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/recipes/dyed_helmets/chainmail_magenta_torch_helmet_recipe.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/recipes/dyed_helmets/chainmail_orange_torch_helmet_recipe.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/recipes/dyed_helmets/chainmail_pink_torch_helmet_recipe.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/recipes/dyed_helmets/chainmail_purple_torch_helmet_recipe.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/recipes/dyed_helmets/chainmail_red_torch_helmet_recipe.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/recipes/dyed_helmets/chainmail_redstone_torch_helmet_recipe.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/recipes/dyed_helmets/chainmail_sea_torch_helmet_recipe.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/recipes/dyed_helmets/chainmail_soul_torch_helmet_recipe.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/recipes/dyed_helmets/chainmail_white_torch_helmet_recipe.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/recipes/dyed_helmets/chainmail_yellow_torch_helmet_recipe.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/recipes/dyed_helmets/diamond_black_torch_helmet_recipe.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/recipes/dyed_helmets/diamond_blue_torch_helmet_recipe.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/recipes/dyed_helmets/diamond_brown_torch_helmet_recipe.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/recipes/dyed_helmets/diamond_cyan_torch_helmet_recipe.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/recipes/dyed_helmets/diamond_gray_torch_helmet_recipe.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/recipes/dyed_helmets/diamond_green_torch_helmet_recipe.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/recipes/dyed_helmets/diamond_light_blue_torch_helmet_recipe.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/recipes/dyed_helmets/diamond_light_gray_torch_helmet_recipe.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/recipes/dyed_helmets/diamond_lime_torch_helmet_recipe.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/recipes/dyed_helmets/diamond_magenta_torch_helmet_recipe.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/recipes/dyed_helmets/diamond_orange_torch_helmet_recipe.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/recipes/dyed_helmets/diamond_pink_torch_helmet_recipe.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/recipes/dyed_helmets/diamond_purple_torch_helmet_recipe.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/recipes/dyed_helmets/diamond_red_torch_helmet_recipe.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/recipes/dyed_helmets/diamond_redstone_torch_helmet_recipe.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/recipes/dyed_helmets/diamond_sea_torch_helmet_recipe.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/recipes/dyed_helmets/diamond_soul_torch_helmet_recipe.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/recipes/dyed_helmets/diamond_white_torch_helmet_recipe.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/recipes/dyed_helmets/diamond_yellow_torch_helmet_recipe.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/recipes/dyed_helmets/golden_black_torch_helmet_recipe.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/recipes/dyed_helmets/golden_blue_torch_helmet_recipe.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/recipes/dyed_helmets/golden_brown_torch_helmet_recipe.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/recipes/dyed_helmets/golden_cyan_torch_helmet_recipe.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/recipes/dyed_helmets/golden_gray_torch_helmet_recipe.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/recipes/dyed_helmets/golden_green_torch_helmet_recipe.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/recipes/dyed_helmets/golden_light_blue_torch_helmet_recipe.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/recipes/dyed_helmets/golden_light_gray_torch_helmet_recipe.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/recipes/dyed_helmets/golden_lime_torch_helmet_recipe.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/recipes/dyed_helmets/golden_magenta_torch_helmet_recipe.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/recipes/dyed_helmets/golden_orange_torch_helmet_recipe.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/recipes/dyed_helmets/golden_pink_torch_helmet_recipe.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/recipes/dyed_helmets/golden_purple_torch_helmet_recipe.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/recipes/dyed_helmets/golden_red_torch_helmet_recipe.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/recipes/dyed_helmets/golden_redstone_torch_helmet_recipe.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/recipes/dyed_helmets/golden_sea_torch_helmet_recipe.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/recipes/dyed_helmets/golden_soul_torch_helmet_recipe.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/recipes/dyed_helmets/golden_white_torch_helmet_recipe.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/recipes/dyed_helmets/golden_yellow_torch_helmet_recipe.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/recipes/dyed_helmets/iron_black_torch_helmet_recipe.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/recipes/dyed_helmets/iron_blue_torch_helmet_recipe.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/recipes/dyed_helmets/iron_brown_torch_helmet_recipe.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/recipes/dyed_helmets/iron_cyan_torch_helmet_recipe.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/recipes/dyed_helmets/iron_gray_torch_helmet_recipe.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/recipes/dyed_helmets/iron_green_torch_helmet_recipe.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/recipes/dyed_helmets/iron_light_blue_torch_helmet_recipe.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/recipes/dyed_helmets/iron_light_gray_torch_helmet_recipe.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/recipes/dyed_helmets/iron_lime_torch_helmet_recipe.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/recipes/dyed_helmets/iron_magenta_torch_helmet_recipe.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/recipes/dyed_helmets/iron_orange_torch_helmet_recipe.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/recipes/dyed_helmets/iron_pink_torch_helmet_recipe.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/recipes/dyed_helmets/iron_purple_torch_helmet_recipe.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/recipes/dyed_helmets/iron_red_torch_helmet_recipe.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/recipes/dyed_helmets/iron_redstone_torch_helmet_recipe.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/recipes/dyed_helmets/iron_sea_torch_helmet_recipe.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/recipes/dyed_helmets/iron_soul_torch_helmet_recipe.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/recipes/dyed_helmets/iron_white_torch_helmet_recipe.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/recipes/dyed_helmets/iron_yellow_torch_helmet_recipe.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/recipes/dyed_helmets/leather_black_torch_helmet_recipe.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/recipes/dyed_helmets/leather_blue_torch_helmet_recipe.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/recipes/dyed_helmets/leather_brown_torch_helmet_recipe.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/recipes/dyed_helmets/leather_cyan_torch_helmet_recipe.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/recipes/dyed_helmets/leather_gray_torch_helmet_recipe.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/recipes/dyed_helmets/leather_green_torch_helmet_recipe.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/recipes/dyed_helmets/leather_light_blue_torch_helmet_recipe.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/recipes/dyed_helmets/leather_light_gray_torch_helmet_recipe.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/recipes/dyed_helmets/leather_lime_torch_helmet_recipe.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/recipes/dyed_helmets/leather_magenta_torch_helmet_recipe.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/recipes/dyed_helmets/leather_orange_torch_helmet_recipe.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/recipes/dyed_helmets/leather_pink_torch_helmet_recipe.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/recipes/dyed_helmets/leather_purple_torch_helmet_recipe.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/recipes/dyed_helmets/leather_red_torch_helmet_recipe.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/recipes/dyed_helmets/leather_redstone_torch_helmet_recipe.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/recipes/dyed_helmets/leather_sea_torch_helmet_recipe.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/recipes/dyed_helmets/leather_soul_torch_helmet_recipe.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/recipes/dyed_helmets/leather_white_torch_helmet_recipe.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/recipes/dyed_helmets/leather_yellow_torch_helmet_recipe.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/recipes/dyed_helmets/netherite_black_torch_helmet_recipe.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/recipes/dyed_helmets/netherite_blue_torch_helmet_recipe.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/recipes/dyed_helmets/netherite_brown_torch_helmet_recipe.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/recipes/dyed_helmets/netherite_cyan_torch_helmet_recipe.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/recipes/dyed_helmets/netherite_gray_torch_helmet_recipe.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/recipes/dyed_helmets/netherite_green_torch_helmet_recipe.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/recipes/dyed_helmets/netherite_light_blue_torch_helmet_recipe.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/recipes/dyed_helmets/netherite_light_gray_torch_helmet_recipe.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/recipes/dyed_helmets/netherite_lime_torch_helmet_recipe.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/recipes/dyed_helmets/netherite_magenta_torch_helmet_recipe.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/recipes/dyed_helmets/netherite_orange_torch_helmet_recipe.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/recipes/dyed_helmets/netherite_pink_torch_helmet_recipe.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/recipes/dyed_helmets/netherite_purple_torch_helmet_recipe.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/recipes/dyed_helmets/netherite_red_torch_helmet_recipe.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/recipes/dyed_helmets/netherite_redstone_torch_helmet_recipe.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/recipes/dyed_helmets/netherite_sea_torch_helmet_recipe.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/recipes/dyed_helmets/netherite_soul_torch_helmet_recipe.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/recipes/dyed_helmets/netherite_white_torch_helmet_recipe.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/recipes/dyed_helmets/netherite_yellow_torch_helmet_recipe.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/recipes/dyed_helmets/turtle_black_torch_helmet_recipe.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/recipes/dyed_helmets/turtle_blue_torch_helmet_recipe.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/recipes/dyed_helmets/turtle_brown_torch_helmet_recipe.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/recipes/dyed_helmets/turtle_cyan_torch_helmet_recipe.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/recipes/dyed_helmets/turtle_gray_torch_helmet_recipe.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/recipes/dyed_helmets/turtle_green_torch_helmet_recipe.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/recipes/dyed_helmets/turtle_light_blue_torch_helmet_recipe.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/recipes/dyed_helmets/turtle_light_gray_torch_helmet_recipe.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/recipes/dyed_helmets/turtle_lime_torch_helmet_recipe.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/recipes/dyed_helmets/turtle_magenta_torch_helmet_recipe.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/recipes/dyed_helmets/turtle_orange_torch_helmet_recipe.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/recipes/dyed_helmets/turtle_pink_torch_helmet_recipe.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/recipes/dyed_helmets/turtle_purple_torch_helmet_recipe.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/recipes/dyed_helmets/turtle_red_torch_helmet_recipe.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/recipes/dyed_helmets/turtle_redstone_torch_helmet_recipe.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/recipes/dyed_helmets/turtle_sea_torch_helmet_recipe.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/recipes/dyed_helmets/turtle_soul_torch_helmet_recipe.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/recipes/dyed_helmets/turtle_white_torch_helmet_recipe.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/recipes/dyed_helmets/turtle_yellow_torch_helmet_recipe.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/recipes/helmets/diamond_helmet.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/recipes/helmets/golden_helmet.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/recipes/helmets/iron_helmet.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/recipes/helmets/leather_helmet.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/recipes/helmets/netherite_helmet.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/recipes/helmets/turtle_helmet.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/recipes/torches/black_torch.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/recipes/torches/blue_torch.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/recipes/torches/brown_torch.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/recipes/torches/cyan_torch.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/recipes/torches/gray_torch.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/recipes/torches/green_torch.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/recipes/torches/light_blue_torch.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/recipes/torches/light_gray_torch.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/recipes/torches/lime_torch.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/recipes/torches/magenta_torch.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/recipes/torches/orange_torch.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/recipes/torches/pink_torch.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/recipes/torches/purple_torch.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/recipes/torches/red_torch.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/recipes/torches/sea_torch.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/recipes/torches/white_torch.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/recipes/torches/yellow_torch.json
    - omf/survival-dkr/behavior/RaiyonsDyBe/scripts/dynamic_light/dyed_torches.js
    - omf/survival-dkr/behavior/RaiyonsDyBe/scripts/dynamic_light/export.js
    - omf/survival-dkr/behavior/RaiyonsDyBe/scripts/dynamic_light/levels.js
    - omf/survival-dkr/behavior/RaiyonsDyBe/scripts/dynamic_light/main.js
    - omf/survival-dkr/behavior/RaiyonsDyBe/scripts/dynamic_light/offhand.js
    - omf/survival-dkr/behavior/RaiyonsDyBe/scripts/dynamic_light/properties.js
    - omf/survival-dkr/behavior/RaiyonsDyBe/scripts/dynamic_light/underwater.js
    - omf/survival-dkr/behavior/RaiyonsDyBe/scripts/dynamic_light/utilities.js
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/concrete/concrete_powder/waystone_black_concrete_powder.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/concrete/concrete_powder/waystone_blue_concrete_powder.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/concrete/concrete_powder/waystone_brown_concrete_powder.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/concrete/concrete_powder/waystone_cyan_concrete_powder.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/concrete/concrete_powder/waystone_gray_concrete_powder.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/concrete/concrete_powder/waystone_green_concrete_powder.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/concrete/concrete_powder/waystone_light_blue_concrete_powder.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/concrete/concrete_powder/waystone_light_gray_concrete_powder.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/concrete/concrete_powder/waystone_lime_concrete_powder.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/concrete/concrete_powder/waystone_magenta_concrete_powder.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/concrete/concrete_powder/waystone_orange_concrete_powder.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/concrete/concrete_powder/waystone_pink_concrete_powder.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/concrete/concrete_powder/waystone_purple_concrete_powder.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/concrete/concrete_powder/waystone_red_concrete_powder.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/concrete/concrete_powder/waystone_white_concrete_powder.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/concrete/concrete_powder/waystone_yellow_concrete_powder.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/concrete/waystone_black_concrete.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/concrete/waystone_blue_concrete.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/concrete/waystone_brown_concrete.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/concrete/waystone_cyan_concrete.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/concrete/waystone_gray_concrete.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/concrete/waystone_green_concrete.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/concrete/waystone_light_blue_concrete.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/concrete/waystone_light_gray_concrete.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/concrete/waystone_lime_concrete.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/concrete/waystone_magenta_concrete.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/concrete/waystone_orange_concrete.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/concrete/waystone_pink_concrete.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/concrete/waystone_purple_concrete.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/concrete/waystone_red_concrete.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/concrete/waystone_white_concrete.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/concrete/waystone_yellow_concrete.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/deepslate/waystone_chiseled_deepslate.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/deepslate/waystone_cobbled_deepslate.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/deepslate/waystone_deepslate.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/deepslate/waystone_deepslate_bricks.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/deepslate/waystone_deepslate_tiles.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/deepslate/waystone_polished_deepslate.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/end/waystone_end_stone.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/end/waystone_end_stone_bricks.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/end/waystone_purpur_block.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/end/waystone_purpur_pillar_side.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/glass/waystone_black_glass.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/glass/waystone_blue_glass.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/glass/waystone_brown_glass.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/glass/waystone_cyan_glass.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/glass/waystone_glass.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/glass/waystone_gray_glass.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/glass/waystone_green_glass.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/glass/waystone_light_blue_glass.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/glass/waystone_light_gray_glass.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/glass/waystone_lime_glass.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/glass/waystone_magenta_glass.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/glass/waystone_orange_glass.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/glass/waystone_pink_glass.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/glass/waystone_purple_glass.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/glass/waystone_red_glass.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/glass/waystone_white_glass.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/glass/waystone_yellow_glass.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/log/stripped/waystone_stripped_acacia_log.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/log/stripped/waystone_stripped_bamboo_block.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/log/stripped/waystone_stripped_birch_log.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/log/stripped/waystone_stripped_cherry_log.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/log/stripped/waystone_stripped_crimson_stem.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/log/stripped/waystone_stripped_dark_oak_log.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/log/stripped/waystone_stripped_jungle_log.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/log/stripped/waystone_stripped_mangrove_log.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/log/stripped/waystone_stripped_oak_log.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/log/stripped/waystone_stripped_pale_oak_log.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/log/stripped/waystone_stripped_spruce_log.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/log/stripped/waystone_warped_stem.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/log/waystone_acacia_log.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/log/waystone_bamboo_block.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/log/waystone_bamboo_mosaic.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/log/waystone_birch_log.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/log/waystone_cherry_log.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/log/waystone_creaking_heart_top.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/log/waystone_crimson_stem.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/log/waystone_dark_oak_log.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/log/waystone_jungle_log.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/log/waystone_mangrove_log.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/log/waystone_oak_log.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/log/waystone_pale_oak_log.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/log/waystone_spruce_log.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/log/waystone_warped_stem.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/mud/waystone_mud_bricks.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/mud/waystone_packed_mud.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/nether/basalt/waystone_basalt.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/nether/basalt/waystone_polished_basalt.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/nether/basalt/waystone_smooth_basalt.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/nether/blackstone/waystone_blackstone.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/nether/blackstone/waystone_chiseled_polished_blackstone.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/nether/blackstone/waystone_polished_blackstone.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/nether/blackstone/waystone_polished_blackstone_bricks.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/nether/waystone_chiseled_nether_bricks.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/nether/waystone_glowstone.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/nether/waystone_magma.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/nether/waystone_nether_bricks.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/nether/waystone_nether_wart_block.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/nether/waystone_red_nether_bricks.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/nether/waystone_soul_sand.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/nether/waystone_soul_soil.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/nether/waystone_warped_wart_block.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/ocean/ice/waystone_blue_ice.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/ocean/ice/waystone_ice.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/ocean/ice/waystone_packed_ice.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/ocean/waystone_dark_prismarine.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/ocean/waystone_prismarine.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/ocean/waystone_prismarine_bricks.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/ocean/waystone_sea_lantern.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/ocean/waystone_snow.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/ore/copper/waystone_chiseled_copper.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/ore/copper/waystone_copper_block.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/ore/copper/waystone_cut_copper.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/ore/copper/waystone_exposed_chiseled_copper.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/ore/copper/waystone_exposed_copper.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/ore/copper/waystone_exposed_cut_copper.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/ore/copper/waystone_oxidized_chiseled_copper.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/ore/copper/waystone_oxidized_copper.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/ore/copper/waystone_oxidized_cut_copper.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/ore/copper/waystone_weathered_chiseled_copper.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/ore/copper/waystone_weathered_copper.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/ore/copper/waystone_weathered_cut_copper.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/ore/quartz/waystone_chiseled_quartz_block_side.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/ore/quartz/waystone_chiseled_quartz_block_top.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/ore/quartz/waystone_quartz_block_side.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/ore/quartz/waystone_quartz_bricks.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/ore/quartz/waystone_quartz_pillar.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/ore/quartz/waystone_quartz_pillar_side.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/ore/raw/waystone_raw_copper_block.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/ore/raw/waystone_raw_gold_block.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/ore/raw/waystone_raw_iron_block.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/ore/waystone_amethyst_block.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/ore/waystone_coal_block.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/ore/waystone_diamond_block.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/ore/waystone_emerald_block.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/ore/waystone_gold_block.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/ore/waystone_iron_block.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/ore/waystone_lapis_block.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/ore/waystone_netherite_block.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/ore/waystone_redstone_block.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/resin/waystone_chiseled_resin_bricks.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/resin/waystone_resin_block.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/resin/waystone_resin_bricks.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/sand/waystone_chiseled_red_sandstone.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/sand/waystone_chiseled_sandstone.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/sand/waystone_cut_red_sandstone.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/sand/waystone_cut_sandstone.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/sand/waystone_red_sand.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/sand/waystone_sand.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/sculk/waystone_sculk_catalyst_side.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/sculk/waystone_sculk_catalyst_top.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/sculk/waystone_sculk_shrieker.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/stone/tuff/waystone_chiseled_tuff.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/stone/tuff/waystone_chiseled_tuff_bricks.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/stone/tuff/waystone_polished_tuff.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/stone/tuff/waystone_tuff.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/stone/tuff/waystone_tuff_bricks.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/stone/waystone_andesite.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/stone/waystone_chiseled_stone_bricks.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/stone/waystone_cobblestone.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/stone/waystone_crying_obsidian.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/stone/waystone_diorite.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/stone/waystone_dripstone_block.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/stone/waystone_granite.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/stone/waystone_mossy_cobblestone.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/stone/waystone_mossy_stone_bricks.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/stone/waystone_obsidian.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/stone/waystone_polished_andesite.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/stone/waystone_polished_diorite.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/stone/waystone_polished_granite.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/stone/waystone_smooth_stone.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/stone/waystone_stone.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/stone/waystone_stone_bricks.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/tables/waystone_anvil.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/tables/waystone_barrel_bottom.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/tables/waystone_barrel_side.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/tables/waystone_beacon.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/tables/waystone_bee_nest_side.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/tables/waystone_beehive_side.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/tables/waystone_blast_furnace_front_off.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/tables/waystone_blast_furnace_top.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/tables/waystone_bookshelf.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/tables/waystone_cauldron_inner.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/tables/waystone_chest.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/tables/waystone_chiseled_bookshelf.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/tables/waystone_crafter_north.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/tables/waystone_crafter_top.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/tables/waystone_crafting_table.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/tables/waystone_ender_chest.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/tables/waystone_furnace.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/tables/waystone_glow_item_frame.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/tables/waystone_item_frame.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/tables/waystone_lodestone.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/tables/waystone_note_block.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/tables/waystone_respawn_anchor.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/tables/waystone_smoker.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/tables/waystone_target_block.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/terracotta/waystone_black_terracota.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/terracotta/waystone_blue_terracota.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/terracotta/waystone_brown_terracota.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/terracotta/waystone_cyan_terracota.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/terracotta/waystone_gray_terracota.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/terracotta/waystone_green_terracota.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/terracotta/waystone_light_blue_terracota.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/terracotta/waystone_light_gray_terracota.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/terracotta/waystone_lime_terracota.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/terracotta/waystone_magenta_terracota.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/terracotta/waystone_orange_terracota.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/terracotta/waystone_pink_terracota.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/terracotta/waystone_purple_terracota.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/terracotta/waystone_red_terracota.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/terracotta/waystone_terracota.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/terracotta/waystone_white_terracota.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/terracotta/waystone_yellow_terracota.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/waystone_bamboo_planks.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/waystone_bone_block_top.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/waystone_redstone_lamp_on.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/wood/stripped/waystone_stripped_acacia_wood.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/wood/stripped/waystone_stripped_birch_wood.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/wood/stripped/waystone_stripped_cherry_wood.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/wood/stripped/waystone_stripped_crimson_hyphae.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/wood/stripped/waystone_stripped_dark_oak_wood.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/wood/stripped/waystone_stripped_jungle_wood.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/wood/stripped/waystone_stripped_mangrove_wood.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/wood/stripped/waystone_stripped_oak_wood.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/wood/stripped/waystone_stripped_pale_oak_wood.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/wood/stripped/waystone_stripped_spruce_wood.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/wood/stripped/waystone_warped_hyphae.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/wood/waystone_acacia_wood.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/wood/waystone_birch_wood.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/wood/waystone_cherry_wood.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/wood/waystone_crimson_hyphae.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/wood/waystone_dark_oak_wood.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/wood/waystone_jungle_wood.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/wood/waystone_mangrove_wood.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/wood/waystone_oak_wood.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/wood/waystone_pale_oak_wood.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/wood/waystone_spruce_wood.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/wood/waystone_warped_hyphae.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/wool/waystone_black_wool.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/wool/waystone_blue_wool.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/wool/waystone_brown_wool.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/wool/waystone_cyan_wool.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/wool/waystone_gray_wool.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/wool/waystone_green_wool.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/wool/waystone_light_blue_wool.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/wool/waystone_light_gray_wool.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/wool/waystone_lime_wool.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/wool/waystone_magenta_wool.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/wool/waystone_orange_wool.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/wool/waystone_pink_wool.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/wool/waystone_purple_wool.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/wool/waystone_red_wool.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/wool/waystone_white_wool.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/blocks/simples_waystone/wool/waystone_yellow_wool.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/feature_rules/simple_waystone_default_structure_rule.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/feature_rules/simple_waystone_desert_structure_rule.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/feature_rules/simple_waystone_taiga_structure_rule.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/features/simple_waystone_default_structure_feature.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/features/simple_waystone_desert_structure_feature.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/features/simple_waystone_taiga_structure_feature.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/functions/simples_waystone/resetDefault.mcfunction
    - omf/survival-dkr/behavior/SimpleWaystoneBP/functions/simples_waystone/setCostNoXp.mcfunction
    - omf/survival-dkr/behavior/SimpleWaystoneBP/functions/simples_waystone/setCostXp.mcfunction
    - omf/survival-dkr/behavior/SimpleWaystoneBP/item_catalog/crafting_item_catalog.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/items/simples_waystone/golden_feather.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/items/simples_waystone/return_scroll.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/items/simples_waystone/warpstone.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/manifest.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/pack_icon.png
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/golden_feather.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/return_scroll.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/warpstone.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/bamboo_planks.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/bone_block_top.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/concrete/black_concrete.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/concrete/blue_concrete.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/concrete/brown_concrete.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/concrete/concrete_powder/black_concrete_powder.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/concrete/concrete_powder/blue_concrete_powder.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/concrete/concrete_powder/brown_concrete_powder.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/concrete/concrete_powder/cyan_concrete_powder.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/concrete/concrete_powder/gray_concrete_powder.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/concrete/concrete_powder/green_concrete_powder.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/concrete/concrete_powder/light_blue_concrete_powder.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/concrete/concrete_powder/light_gray_concrete_powder.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/concrete/concrete_powder/lime_concrete_powder.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/concrete/concrete_powder/magenta_concrete_powder.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/concrete/concrete_powder/orange_concrete_powder.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/concrete/concrete_powder/pink_concrete_powder.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/concrete/concrete_powder/purple_concrete_powder.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/concrete/concrete_powder/red_concrete_powder.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/concrete/concrete_powder/white_concrete_powder.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/concrete/concrete_powder/yellow_concrete_powder.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/concrete/cyan_concrete.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/concrete/gray_concrete.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/concrete/green_concrete.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/concrete/light_blue_concrete.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/concrete/light_gray_concrete.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/concrete/lime_concrete.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/concrete/magenta_concrete.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/concrete/orange_concrete.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/concrete/pink_concrete.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/concrete/purple_concrete.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/concrete/red_concrete.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/concrete/white_concrete.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/concrete/yellow_concrete.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/deepslate/chiseled_deepslate.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/deepslate/cobbled_deepslate.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/deepslate/deepslate.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/deepslate/deepslate_bricks.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/deepslate/deepslate_tiles.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/deepslate/polished_deepslate.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/end/end_stone.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/end/end_stone_bricks.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/end/purpur_block.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/end/purpur_pillar.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/glass/black_glass.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/glass/blue_glass.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/glass/brown_glass.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/glass/cyan_glass.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/glass/glass.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/glass/gray_glass.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/glass/green_glass.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/glass/light_blue_glass.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/glass/light_gray_glass.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/glass/lime_glass.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/glass/magenta_glass.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/glass/orange_glass.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/glass/pink_glass.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/glass/purple_glass.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/glass/red_glass.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/glass/white_glass.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/glass/yellow_glass.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/log/acacia_log.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/log/bamboo_block.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/log/bamboo_mosaic.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/log/birch_log.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/log/cherry_log.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/log/creaking_heart.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/log/crimson_stem.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/log/dark_oak_log.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/log/jungle_log.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/log/mangrove_log.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/log/oak_log.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/log/pale_oak_log.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/log/spruce_log.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/log/stripped/stripped_acacia_log.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/log/stripped/stripped_bamboo_block.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/log/stripped/stripped_birch_log.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/log/stripped/stripped_cherry_log.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/log/stripped/stripped_crimson_stem.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/log/stripped/stripped_dark_oak_log.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/log/stripped/stripped_jungle_log.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/log/stripped/stripped_mangrove_log.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/log/stripped/stripped_oak_log.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/log/stripped/stripped_pale_oak_log.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/log/stripped/stripped_spruce_log.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/log/stripped/stripped_warped_stem.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/log/stripped_warped_stem.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/mud/mud_bricks.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/mud/packed_mud.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/nether/basalt/basalt.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/nether/basalt/polished_basalt.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/nether/basalt/smooth_basalt.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/nether/blackstone/blackstone.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/nether/blackstone/chiseled_polished_blackstone.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/nether/blackstone/polished_blackstone.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/nether/blackstone/polished_blackstone_bricks.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/nether/chiseled_nether_bricks.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/nether/glowstone.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/nether/magma.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/nether/nether_bricks.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/nether/nether_wart_block.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/nether/red_nether_bricks.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/nether/soul_sand.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/nether/soul_soil.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/nether/warped_wart_block.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/ocean/dark_prismarine.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/ocean/ice/blue_ice.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/ocean/ice/ice.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/ocean/ice/packed_ice.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/ocean/prismarine.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/ocean/prismarine_bricks.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/ocean/sea_lantern.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/ocean/snow.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/ore/amethyst_block.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/ore/coal_block.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/ore/copper/chiseled_copper.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/ore/copper/copper_block.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/ore/copper/cut_copper.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/ore/copper/exposed_chiseled_copper.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/ore/copper/exposed_copper_block.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/ore/copper/exposed_cut_copper.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/ore/copper/oxidized_chiseled_copper.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/ore/copper/oxidized_copper_block.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/ore/copper/oxidized_cut_copper.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/ore/copper/weathered_chiseled_copper.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/ore/copper/weathered_copper_block.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/ore/copper/weathered_cut_copper.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/ore/diamond_block.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/ore/emerald_block.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/ore/gold_block.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/ore/iron_block.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/ore/lapis_block.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/ore/netherite_block.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/ore/quartz/chiseled_quartz_block_side.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/ore/quartz/chiseled_quartz_block_side1.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/ore/quartz/chiseled_quartz_block_top.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/ore/quartz/quartz_block_side.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/ore/quartz/quartz_bricks.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/ore/quartz/quartz_pillar_side.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/ore/quartz/quartz_pillar_top.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/ore/quartz/quartz_pillar_top1.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/ore/raw/raw_copper_block.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/ore/raw/raw_gold_block.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/ore/raw/raw_iron_block.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/ore/redstone_block.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/redstone_lamp_on.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/resin/chiseled_resin_bricks.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/resin/resin_block.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/resin/resin_bricks.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/sand/chiseled_red_sandstone.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/sand/chiseled_sandstone.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/sand/cut_red_sandstone.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/sand/cut_sandstone.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/sand/red_sand.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/sand/sand.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/sculk/sculk_catalyst_side.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/sculk/sculk_catalyst_top.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/sculk/sculk_catalyst_top1.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/sculk/sculk_shrieker.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/stone/andesite.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/stone/chiseled_stone_bricks.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/stone/cobblestone.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/stone/crying_obsidian.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/stone/diorite.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/stone/dripstone_block.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/stone/granite.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/stone/mossy_cobblestone.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/stone/mossy_stone_bricks.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/stone/obsidian.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/stone/polished_andesite.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/stone/polished_diorite.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/stone/polished_granite.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/stone/smooth_stone.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/stone/stone.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/stone/stone_bricks.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/stone/tuff/chiseled_tuff.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/stone/tuff/chiseled_tuff_bricks.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/stone/tuff/polished_tuff.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/stone/tuff/tuff.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/stone/tuff/tuff_bricks.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/tables/anvil.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/tables/barrel_bottom.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/tables/barrel_side.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/tables/barrel_side1.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/tables/beacon.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/tables/bee_nest_side.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/tables/beehive_side.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/tables/blast_furnace_front_off.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/tables/blast_furnace_front_off1.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/tables/blast_furnace_top.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/tables/bookshelf.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/tables/cauldron_inner.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/tables/chest.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/tables/chiseled_bookshelf.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/tables/crafter_north.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/tables/crafter_north1.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/tables/crafter_top.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/tables/crafting_table.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/tables/ender_chest.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/tables/furnace.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/tables/glow_item_frame.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/tables/item_frame.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/tables/lodestone.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/tables/note_block.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/tables/respawn_anchor.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/tables/smoker.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/tables/target_block.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/terracotta/black_terracotta.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/terracotta/blue_terracotta.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/terracotta/brown_terracotta.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/terracotta/cyan_terracotta.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/terracotta/gray_terracotta.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/terracotta/green_terracotta.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/terracotta/light_blue_terracotta.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/terracotta/light_gray_terracotta.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/terracotta/lime_terracotta.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/terracotta/magenta_terracotta.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/terracotta/orange_terracotta.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/terracotta/pink_terracotta.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/terracotta/purple_terracotta.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/terracotta/red_terracotta.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/terracotta/terracotta.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/terracotta/white_terracotta.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/terracotta/yellow_terracotta.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/wood/acacia_wood.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/wood/birch_wood.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/wood/cherry_wood.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/wood/crimson_wood.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/wood/dark_oak_wood.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/wood/jungle_wood.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/wood/mangrove_wood.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/wood/oak_wood.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/wood/pale_oak_wood.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/wood/spruce_wood.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/wood/stripped/stripped_acacia_wood.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/wood/stripped/stripped_birch_wood.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/wood/stripped/stripped_cherry_wood.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/wood/stripped/stripped_crimson_hyphae.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/wood/stripped/stripped_dark_oak_wood.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/wood/stripped/stripped_jungle_wood.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/wood/stripped/stripped_mangrove_wood.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/wood/stripped/stripped_oak_wood.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/wood/stripped/stripped_pale_oak_wood.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/wood/stripped/stripped_spruce_wood.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/wood/stripped/stripped_warped_wood.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/wood/warped_wood.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/wool/black_wool.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/wool/blue_wool.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/wool/brown_wool.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/wool/cyan_wool.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/wool/gray_wool.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/wool/green_wool.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/wool/light_blue_wool.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/wool/light_gray_wool.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/wool/lime_wool.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/wool/magenta_wool.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/wool/orange_wool.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/wool/pink_wool.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/wool/purple_wool.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/wool/red_wool.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/wool/white_wool.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/recipes/simples_waystone/waystones/wool/yellow_wool.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/scripts/simple_waystone/customComponent/customComponent.js
    - omf/survival-dkr/behavior/SimpleWaystoneBP/scripts/simple_waystone/dev.js
    - omf/survival-dkr/behavior/SimpleWaystoneBP/scripts/simple_waystone/functions/convertOld.js
    - omf/survival-dkr/behavior/SimpleWaystoneBP/scripts/simple_waystone/functions/destroy.js
    - omf/survival-dkr/behavior/SimpleWaystoneBP/scripts/simple_waystone/functions/placeWaystones.js
    - omf/survival-dkr/behavior/SimpleWaystoneBP/scripts/simple_waystone/lib/apiConfig.js
    - omf/survival-dkr/behavior/SimpleWaystoneBP/scripts/simple_waystone/lib/apiItem.js
    - omf/survival-dkr/behavior/SimpleWaystoneBP/scripts/simple_waystone/lib/apiOrganize.js
    - omf/survival-dkr/behavior/SimpleWaystoneBP/scripts/simple_waystone/lib/apiwaystone/create.js
    - omf/survival-dkr/behavior/SimpleWaystoneBP/scripts/simple_waystone/lib/apiwaystone/info.js
    - omf/survival-dkr/behavior/SimpleWaystoneBP/scripts/simple_waystone/lib/apiwaystone/save.js
    - omf/survival-dkr/behavior/SimpleWaystoneBP/scripts/simple_waystone/lib/apiwaystone/space.js
    - omf/survival-dkr/behavior/SimpleWaystoneBP/scripts/simple_waystone/lib/vector.js
    - omf/survival-dkr/behavior/SimpleWaystoneBP/scripts/simple_waystone/lib/warn.js
    - omf/survival-dkr/behavior/SimpleWaystoneBP/scripts/simple_waystone/main.js
    - omf/survival-dkr/behavior/SimpleWaystoneBP/scripts/simple_waystone/ui/mainUi.js
    - omf/survival-dkr/behavior/SimpleWaystoneBP/scripts/simple_waystone/variables.js
    - omf/survival-dkr/behavior/SimpleWaystoneBP/src/customComponent/customComponent.ts
    - omf/survival-dkr/behavior/SimpleWaystoneBP/src/dev.ts
    - omf/survival-dkr/behavior/SimpleWaystoneBP/src/functions/convertOld.ts
    - omf/survival-dkr/behavior/SimpleWaystoneBP/src/functions/destroy.ts
    - omf/survival-dkr/behavior/SimpleWaystoneBP/src/functions/placeWaystones.ts
    - omf/survival-dkr/behavior/SimpleWaystoneBP/src/lib/apiConfig.ts
    - omf/survival-dkr/behavior/SimpleWaystoneBP/src/lib/apiItem.ts
    - omf/survival-dkr/behavior/SimpleWaystoneBP/src/lib/apiOrganize.ts
    - omf/survival-dkr/behavior/SimpleWaystoneBP/src/lib/apiwaystone/create.ts
    - omf/survival-dkr/behavior/SimpleWaystoneBP/src/lib/apiwaystone/info.ts
    - omf/survival-dkr/behavior/SimpleWaystoneBP/src/lib/apiwaystone/save.ts
    - omf/survival-dkr/behavior/SimpleWaystoneBP/src/lib/apiwaystone/space.ts
    - omf/survival-dkr/behavior/SimpleWaystoneBP/src/lib/vector.ts
    - omf/survival-dkr/behavior/SimpleWaystoneBP/src/lib/warn.ts
    - omf/survival-dkr/behavior/SimpleWaystoneBP/src/main.ts
    - omf/survival-dkr/behavior/SimpleWaystoneBP/src/ui/mainUi.ts
    - omf/survival-dkr/behavior/SimpleWaystoneBP/src/variables.ts
    - omf/survival-dkr/behavior/SimpleWaystoneBP/structures/simple_waystone_default_structure.mcstructure
    - omf/survival-dkr/behavior/SimpleWaystoneBP/structures/simple_waystone_desert_structure.mcstructure
    - omf/survival-dkr/behavior/SimpleWaystoneBP/structures/simple_waystone_taiga_structure.mcstructure
    - omf/survival-dkr/behavior/SimpleWaystoneBP/subpacks/free/scripts/simple_waystone/variables.js
    - omf/survival-dkr/behavior/SimpleWaystoneBP/texts/en_US.lang
    - omf/survival-dkr/behavior/SimpleWaystoneBP/texts/languages.json
    - omf/survival-dkr/behavior/SimpleWaystoneBP/texts/pt_BR.lang
    - omf/survival-dkr/resource/FFLResourcePack/manifest.json
    - omf/survival-dkr/resource/FFLResourcePack/pack_icon.png
    - omf/survival-dkr/resource/FFLResourcePack/particles/acacia_leaf.json
    - omf/survival-dkr/resource/FFLResourcePack/particles/azalea_flowered_leaf.json
    - omf/survival-dkr/resource/FFLResourcePack/particles/azalea_leaf.json
    - omf/survival-dkr/resource/FFLResourcePack/particles/birch_leaf.json
    - omf/survival-dkr/resource/FFLResourcePack/particles/dark_oak_leaf.json
    - omf/survival-dkr/resource/FFLResourcePack/particles/jungle_leaf.json
    - omf/survival-dkr/resource/FFLResourcePack/particles/mangrove_leaf.json
    - omf/survival-dkr/resource/FFLResourcePack/particles/oak_leaf.json
    - omf/survival-dkr/resource/FFLResourcePack/particles/spruce_leaf.json
    - omf/survival-dkr/resource/FFLResourcePack/textures/particle/acacia_leaf.png
    - omf/survival-dkr/resource/FFLResourcePack/textures/particle/azalea_flowered_leaf.png
    - omf/survival-dkr/resource/FFLResourcePack/textures/particle/azalea_leaf.png
    - omf/survival-dkr/resource/FFLResourcePack/textures/particle/birch_leaf.png
    - omf/survival-dkr/resource/FFLResourcePack/textures/particle/dark_oak_leaf.png
    - omf/survival-dkr/resource/FFLResourcePack/textures/particle/jungle_leaf.png
    - omf/survival-dkr/resource/FFLResourcePack/textures/particle/mangrove_leaf.png
    - omf/survival-dkr/resource/FFLResourcePack/textures/particle/oak_leaf.png
    - omf/survival-dkr/resource/FFLResourcePack/textures/particle/spruce_leaf.png
    - omf/survival-dkr/resource/RaiyonsDyRE/attachables/chainmail_helmet.json
    - omf/survival-dkr/resource/RaiyonsDyRE/attachables/diamond_helmet.json
    - omf/survival-dkr/resource/RaiyonsDyRE/attachables/dyed_helmets/chainmail_black_torch_helmet_attachable.json
    - omf/survival-dkr/resource/RaiyonsDyRE/attachables/dyed_helmets/chainmail_blue_torch_helmet_attachable.json
    - omf/survival-dkr/resource/RaiyonsDyRE/attachables/dyed_helmets/chainmail_brown_torch_helmet_attachable.json
    - omf/survival-dkr/resource/RaiyonsDyRE/attachables/dyed_helmets/chainmail_cyan_torch_helmet_attachable.json
    - omf/survival-dkr/resource/RaiyonsDyRE/attachables/dyed_helmets/chainmail_gray_torch_helmet_attachable.json
    - omf/survival-dkr/resource/RaiyonsDyRE/attachables/dyed_helmets/chainmail_green_torch_helmet_attachable.json
    - omf/survival-dkr/resource/RaiyonsDyRE/attachables/dyed_helmets/chainmail_light_blue_torch_helmet_attachable.json
    - omf/survival-dkr/resource/RaiyonsDyRE/attachables/dyed_helmets/chainmail_light_gray_torch_helmet_attachable.json
    - omf/survival-dkr/resource/RaiyonsDyRE/attachables/dyed_helmets/chainmail_lime_torch_helmet_attachable.json
    - omf/survival-dkr/resource/RaiyonsDyRE/attachables/dyed_helmets/chainmail_magenta_torch_helmet_attachable.json
    - omf/survival-dkr/resource/RaiyonsDyRE/attachables/dyed_helmets/chainmail_orange_torch_helmet_attachable.json
    - omf/survival-dkr/resource/RaiyonsDyRE/attachables/dyed_helmets/chainmail_pink_torch_helmet_attachable.json
    - omf/survival-dkr/resource/RaiyonsDyRE/attachables/dyed_helmets/chainmail_purple_torch_helmet_attachable.json
    - omf/survival-dkr/resource/RaiyonsDyRE/attachables/dyed_helmets/chainmail_red_torch_helmet_attachable.json
    - omf/survival-dkr/resource/RaiyonsDyRE/attachables/dyed_helmets/chainmail_redstone_torch_helmet_attachable.json
    - omf/survival-dkr/resource/RaiyonsDyRE/attachables/dyed_helmets/chainmail_sea_torch_helmet_attachable.json
    - omf/survival-dkr/resource/RaiyonsDyRE/attachables/dyed_helmets/chainmail_soul_torch_helmet_attachable.json
    - omf/survival-dkr/resource/RaiyonsDyRE/attachables/dyed_helmets/chainmail_white_torch_helmet_attachable.json
    - omf/survival-dkr/resource/RaiyonsDyRE/attachables/dyed_helmets/chainmail_yellow_torch_helmet_attachable.json
    - omf/survival-dkr/resource/RaiyonsDyRE/attachables/dyed_helmets/diamond_black_torch_helmet_attachable.json
    - omf/survival-dkr/resource/RaiyonsDyRE/attachables/dyed_helmets/diamond_blue_torch_helmet_attachable.json
    - omf/survival-dkr/resource/RaiyonsDyRE/attachables/dyed_helmets/diamond_brown_torch_helmet_attachable.json
    - omf/survival-dkr/resource/RaiyonsDyRE/attachables/dyed_helmets/diamond_cyan_torch_helmet_attachable.json
    - omf/survival-dkr/resource/RaiyonsDyRE/attachables/dyed_helmets/diamond_gray_torch_helmet_attachable.json
    - omf/survival-dkr/resource/RaiyonsDyRE/attachables/dyed_helmets/diamond_green_torch_helmet_attachable.json
    - omf/survival-dkr/resource/RaiyonsDyRE/attachables/dyed_helmets/diamond_light_blue_torch_helmet_attachable.json
    - omf/survival-dkr/resource/RaiyonsDyRE/attachables/dyed_helmets/diamond_light_gray_torch_helmet_attachable.json
    - omf/survival-dkr/resource/RaiyonsDyRE/attachables/dyed_helmets/diamond_lime_torch_helmet_attachable.json
    - omf/survival-dkr/resource/RaiyonsDyRE/attachables/dyed_helmets/diamond_magenta_torch_helmet_attachable.json
    - omf/survival-dkr/resource/RaiyonsDyRE/attachables/dyed_helmets/diamond_orange_torch_helmet_attachable.json
    - omf/survival-dkr/resource/RaiyonsDyRE/attachables/dyed_helmets/diamond_pink_torch_helmet_attachable.json
    - omf/survival-dkr/resource/RaiyonsDyRE/attachables/dyed_helmets/diamond_purple_torch_helmet_attachable.json
    - omf/survival-dkr/resource/RaiyonsDyRE/attachables/dyed_helmets/diamond_red_torch_helmet_attachable.json
    - omf/survival-dkr/resource/RaiyonsDyRE/attachables/dyed_helmets/diamond_redstone_torch_helmet_attachable.json
    - omf/survival-dkr/resource/RaiyonsDyRE/attachables/dyed_helmets/diamond_sea_torch_helmet_attachable.json
    - omf/survival-dkr/resource/RaiyonsDyRE/attachables/dyed_helmets/diamond_soul_torch_helmet_attachable.json
    - omf/survival-dkr/resource/RaiyonsDyRE/attachables/dyed_helmets/diamond_white_torch_helmet_attachable.json
    - omf/survival-dkr/resource/RaiyonsDyRE/attachables/dyed_helmets/diamond_yellow_torch_helmet_attachable.json
    - omf/survival-dkr/resource/RaiyonsDyRE/attachables/dyed_helmets/golden_black_torch_helmet_attachable.json
    - omf/survival-dkr/resource/RaiyonsDyRE/attachables/dyed_helmets/golden_blue_torch_helmet_attachable.json
    - omf/survival-dkr/resource/RaiyonsDyRE/attachables/dyed_helmets/golden_brown_torch_helmet_attachable.json
    - omf/survival-dkr/resource/RaiyonsDyRE/attachables/dyed_helmets/golden_cyan_torch_helmet_attachable.json
    - omf/survival-dkr/resource/RaiyonsDyRE/attachables/dyed_helmets/golden_gray_torch_helmet_attachable.json
    - omf/survival-dkr/resource/RaiyonsDyRE/attachables/dyed_helmets/golden_green_torch_helmet_attachable.json
    - omf/survival-dkr/resource/RaiyonsDyRE/attachables/dyed_helmets/golden_light_blue_torch_helmet_attachable.json
    - omf/survival-dkr/resource/RaiyonsDyRE/attachables/dyed_helmets/golden_light_gray_torch_helmet_attachable.json
    - omf/survival-dkr/resource/RaiyonsDyRE/attachables/dyed_helmets/golden_lime_torch_helmet_attachable.json
    - omf/survival-dkr/resource/RaiyonsDyRE/attachables/dyed_helmets/golden_magenta_torch_helmet_attachable.json
    - omf/survival-dkr/resource/RaiyonsDyRE/attachables/dyed_helmets/golden_orange_torch_helmet_attachable.json
    - omf/survival-dkr/resource/RaiyonsDyRE/attachables/dyed_helmets/golden_pink_torch_helmet_attachable.json
    - omf/survival-dkr/resource/RaiyonsDyRE/attachables/dyed_helmets/golden_purple_torch_helmet_attachable.json
    - omf/survival-dkr/resource/RaiyonsDyRE/attachables/dyed_helmets/golden_red_torch_helmet_attachable.json
    - omf/survival-dkr/resource/RaiyonsDyRE/attachables/dyed_helmets/golden_redstone_torch_helmet_attachable.json
    - omf/survival-dkr/resource/RaiyonsDyRE/attachables/dyed_helmets/golden_sea_torch_helmet_attachable.json
    - omf/survival-dkr/resource/RaiyonsDyRE/attachables/dyed_helmets/golden_soul_torch_helmet_attachable.json
    - omf/survival-dkr/resource/RaiyonsDyRE/attachables/dyed_helmets/golden_white_torch_helmet_attachable.json
    - omf/survival-dkr/resource/RaiyonsDyRE/attachables/dyed_helmets/golden_yellow_torch_helmet_attachable.json
    - omf/survival-dkr/resource/RaiyonsDyRE/attachables/dyed_helmets/iron_black_torch_helmet_attachable.json
    - omf/survival-dkr/resource/RaiyonsDyRE/attachables/dyed_helmets/iron_blue_torch_helmet_attachable.json
    - omf/survival-dkr/resource/RaiyonsDyRE/attachables/dyed_helmets/iron_brown_torch_helmet_attachable.json
    - omf/survival-dkr/resource/RaiyonsDyRE/attachables/dyed_helmets/iron_cyan_torch_helmet_attachable.json
    - omf/survival-dkr/resource/RaiyonsDyRE/attachables/dyed_helmets/iron_gray_torch_helmet_attachable.json
    - omf/survival-dkr/resource/RaiyonsDyRE/attachables/dyed_helmets/iron_green_torch_helmet_attachable.json
    - omf/survival-dkr/resource/RaiyonsDyRE/attachables/dyed_helmets/iron_light_blue_torch_helmet_attachable.json
    - omf/survival-dkr/resource/RaiyonsDyRE/attachables/dyed_helmets/iron_light_gray_torch_helmet_attachable.json
    - omf/survival-dkr/resource/RaiyonsDyRE/attachables/dyed_helmets/iron_lime_torch_helmet_attachable.json
    - omf/survival-dkr/resource/RaiyonsDyRE/attachables/dyed_helmets/iron_magenta_torch_helmet_attachable.json
    - omf/survival-dkr/resource/RaiyonsDyRE/attachables/dyed_helmets/iron_orange_torch_helmet_attachable.json
    - omf/survival-dkr/resource/RaiyonsDyRE/attachables/dyed_helmets/iron_pink_torch_helmet_attachable.json
    - omf/survival-dkr/resource/RaiyonsDyRE/attachables/dyed_helmets/iron_purple_torch_helmet_attachable.json
    - omf/survival-dkr/resource/RaiyonsDyRE/attachables/dyed_helmets/iron_red_torch_helmet_attachable.json
    - omf/survival-dkr/resource/RaiyonsDyRE/attachables/dyed_helmets/iron_redstone_torch_helmet_attachable.json
    - omf/survival-dkr/resource/RaiyonsDyRE/attachables/dyed_helmets/iron_sea_torch_helmet_attachable.json
    - omf/survival-dkr/resource/RaiyonsDyRE/attachables/dyed_helmets/iron_soul_torch_helmet_attachable.json
    - omf/survival-dkr/resource/RaiyonsDyRE/attachables/dyed_helmets/iron_white_torch_helmet_attachable.json
    - omf/survival-dkr/resource/RaiyonsDyRE/attachables/dyed_helmets/iron_yellow_torch_helmet_attachable.json
    - omf/survival-dkr/resource/RaiyonsDyRE/attachables/dyed_helmets/leather_black_torch_helmet_attachable.json
    - omf/survival-dkr/resource/RaiyonsDyRE/attachables/dyed_helmets/leather_blue_torch_helmet_attachable.json
    - omf/survival-dkr/resource/RaiyonsDyRE/attachables/dyed_helmets/leather_brown_torch_helmet_attachable.json
    - omf/survival-dkr/resource/RaiyonsDyRE/attachables/dyed_helmets/leather_cyan_torch_helmet_attachable.json
    - omf/survival-dkr/resource/RaiyonsDyRE/attachables/dyed_helmets/leather_gray_torch_helmet_attachable.json
    - omf/survival-dkr/resource/RaiyonsDyRE/attachables/dyed_helmets/leather_green_torch_helmet_attachable.json
    - omf/survival-dkr/resource/RaiyonsDyRE/attachables/dyed_helmets/leather_light_blue_torch_helmet_attachable.json
    - omf/survival-dkr/resource/RaiyonsDyRE/attachables/dyed_helmets/leather_light_gray_torch_helmet_attachable.json
    - omf/survival-dkr/resource/RaiyonsDyRE/attachables/dyed_helmets/leather_lime_torch_helmet_attachable.json
    - omf/survival-dkr/resource/RaiyonsDyRE/attachables/dyed_helmets/leather_magenta_torch_helmet_attachable.json
    - omf/survival-dkr/resource/RaiyonsDyRE/attachables/dyed_helmets/leather_orange_torch_helmet_attachable.json
    - omf/survival-dkr/resource/RaiyonsDyRE/attachables/dyed_helmets/leather_pink_torch_helmet_attachable.json
    - omf/survival-dkr/resource/RaiyonsDyRE/attachables/dyed_helmets/leather_purple_torch_helmet_attachable.json
    - omf/survival-dkr/resource/RaiyonsDyRE/attachables/dyed_helmets/leather_red_torch_helmet_attachable.json
    - omf/survival-dkr/resource/RaiyonsDyRE/attachables/dyed_helmets/leather_redstone_torch_helmet_attachable.json
    - omf/survival-dkr/resource/RaiyonsDyRE/attachables/dyed_helmets/leather_sea_torch_helmet_attachable.json
    - omf/survival-dkr/resource/RaiyonsDyRE/attachables/dyed_helmets/leather_soul_torch_helmet_attachable.json
    - omf/survival-dkr/resource/RaiyonsDyRE/attachables/dyed_helmets/leather_white_torch_helmet_attachable.json
    - omf/survival-dkr/resource/RaiyonsDyRE/attachables/dyed_helmets/leather_yellow_torch_helmet_attachable.json
    - omf/survival-dkr/resource/RaiyonsDyRE/attachables/dyed_helmets/netherite_black_torch_helmet_attachable.json
    - omf/survival-dkr/resource/RaiyonsDyRE/attachables/dyed_helmets/netherite_blue_torch_helmet_attachable.json
    - omf/survival-dkr/resource/RaiyonsDyRE/attachables/dyed_helmets/netherite_brown_torch_helmet_attachable.json
    - omf/survival-dkr/resource/RaiyonsDyRE/attachables/dyed_helmets/netherite_cyan_torch_helmet_attachable.json
    - omf/survival-dkr/resource/RaiyonsDyRE/attachables/dyed_helmets/netherite_gray_torch_helmet_attachable.json
    - omf/survival-dkr/resource/RaiyonsDyRE/attachables/dyed_helmets/netherite_green_torch_helmet_attachable.json
    - omf/survival-dkr/resource/RaiyonsDyRE/attachables/dyed_helmets/netherite_light_blue_torch_helmet_attachable.json
    - omf/survival-dkr/resource/RaiyonsDyRE/attachables/dyed_helmets/netherite_light_gray_torch_helmet_attachable.json
    - omf/survival-dkr/resource/RaiyonsDyRE/attachables/dyed_helmets/netherite_lime_torch_helmet_attachable.json
    - omf/survival-dkr/resource/RaiyonsDyRE/attachables/dyed_helmets/netherite_magenta_torch_helmet_attachable.json
    - omf/survival-dkr/resource/RaiyonsDyRE/attachables/dyed_helmets/netherite_orange_torch_helmet_attachable.json
    - omf/survival-dkr/resource/RaiyonsDyRE/attachables/dyed_helmets/netherite_pink_torch_helmet_attachable.json
    - omf/survival-dkr/resource/RaiyonsDyRE/attachables/dyed_helmets/netherite_purple_torch_helmet_attachable.json
    - omf/survival-dkr/resource/RaiyonsDyRE/attachables/dyed_helmets/netherite_red_torch_helmet_attachable.json
    - omf/survival-dkr/resource/RaiyonsDyRE/attachables/dyed_helmets/netherite_redstone_torch_helmet_attachable.json
    - omf/survival-dkr/resource/RaiyonsDyRE/attachables/dyed_helmets/netherite_sea_torch_helmet_attachable.json
    - omf/survival-dkr/resource/RaiyonsDyRE/attachables/dyed_helmets/netherite_soul_torch_helmet_attachable.json
    - omf/survival-dkr/resource/RaiyonsDyRE/attachables/dyed_helmets/netherite_white_torch_helmet_attachable.json
    - omf/survival-dkr/resource/RaiyonsDyRE/attachables/dyed_helmets/netherite_yellow_torch_helmet_attachable.json
    - omf/survival-dkr/resource/RaiyonsDyRE/attachables/dyed_helmets/turtle_black_torch_helmet_attachable.json
    - omf/survival-dkr/resource/RaiyonsDyRE/attachables/dyed_helmets/turtle_blue_torch_helmet_attachable.json
    - omf/survival-dkr/resource/RaiyonsDyRE/attachables/dyed_helmets/turtle_brown_torch_helmet_attachable.json
    - omf/survival-dkr/resource/RaiyonsDyRE/attachables/dyed_helmets/turtle_cyan_torch_helmet_attachable.json
    - omf/survival-dkr/resource/RaiyonsDyRE/attachables/dyed_helmets/turtle_gray_torch_helmet_attachable.json
    - omf/survival-dkr/resource/RaiyonsDyRE/attachables/dyed_helmets/turtle_green_torch_helmet_attachable.json
    - omf/survival-dkr/resource/RaiyonsDyRE/attachables/dyed_helmets/turtle_light_blue_torch_helmet_attachable.json
    - omf/survival-dkr/resource/RaiyonsDyRE/attachables/dyed_helmets/turtle_light_gray_torch_helmet_attachable.json
    - omf/survival-dkr/resource/RaiyonsDyRE/attachables/dyed_helmets/turtle_lime_torch_helmet_attachable.json
    - omf/survival-dkr/resource/RaiyonsDyRE/attachables/dyed_helmets/turtle_magenta_torch_helmet_attachable.json
    - omf/survival-dkr/resource/RaiyonsDyRE/attachables/dyed_helmets/turtle_orange_torch_helmet_attachable.json
    - omf/survival-dkr/resource/RaiyonsDyRE/attachables/dyed_helmets/turtle_pink_torch_helmet_attachable.json
    - omf/survival-dkr/resource/RaiyonsDyRE/attachables/dyed_helmets/turtle_purple_torch_helmet_attachable.json
    - omf/survival-dkr/resource/RaiyonsDyRE/attachables/dyed_helmets/turtle_red_torch_helmet_attachable.json
    - omf/survival-dkr/resource/RaiyonsDyRE/attachables/dyed_helmets/turtle_redstone_torch_helmet_attachable.json
    - omf/survival-dkr/resource/RaiyonsDyRE/attachables/dyed_helmets/turtle_sea_torch_helmet_attachable.json
    - omf/survival-dkr/resource/RaiyonsDyRE/attachables/dyed_helmets/turtle_soul_torch_helmet_attachable.json
    - omf/survival-dkr/resource/RaiyonsDyRE/attachables/dyed_helmets/turtle_white_torch_helmet_attachable.json
    - omf/survival-dkr/resource/RaiyonsDyRE/attachables/dyed_helmets/turtle_yellow_torch_helmet_attachable.json
    - omf/survival-dkr/resource/RaiyonsDyRE/attachables/golden_helmet.json
    - omf/survival-dkr/resource/RaiyonsDyRE/attachables/iron_helmet.json
    - omf/survival-dkr/resource/RaiyonsDyRE/attachables/leather_helmet.json
    - omf/survival-dkr/resource/RaiyonsDyRE/attachables/netherite_helmet.json
    - omf/survival-dkr/resource/RaiyonsDyRE/attachables/turtle_helmet.json
    - omf/survival-dkr/resource/RaiyonsDyRE/blocks.json
    - omf/survival-dkr/resource/RaiyonsDyRE/manifest.json
    - omf/survival-dkr/resource/RaiyonsDyRE/models/blocks/torchSide.json
    - omf/survival-dkr/resource/RaiyonsDyRE/models/blocks/torchUp.json
    - omf/survival-dkr/resource/RaiyonsDyRE/models/entity/miner_helmet.geo.json
    - omf/survival-dkr/resource/RaiyonsDyRE/models/entity/torch_helmet.json
    - omf/survival-dkr/resource/RaiyonsDyRE/models/entity/vanilla_helmet.json
    - omf/survival-dkr/resource/RaiyonsDyRE/pack_icon.png
    - omf/survival-dkr/resource/RaiyonsDyRE/particles/fire.json
    - omf/survival-dkr/resource/RaiyonsDyRE/particles/light.json
    - omf/survival-dkr/resource/RaiyonsDyRE/render_controllers/miner_armor.json
    - omf/survival-dkr/resource/RaiyonsDyRE/render_controllers/miner_helmet.json
    - omf/survival-dkr/resource/RaiyonsDyRE/render_controllers/torch_helmet.json
    - omf/survival-dkr/resource/RaiyonsDyRE/texts/bg_BG.lang
    - omf/survival-dkr/resource/RaiyonsDyRE/texts/cs_CZ.lang
    - omf/survival-dkr/resource/RaiyonsDyRE/texts/da_DK.lang
    - omf/survival-dkr/resource/RaiyonsDyRE/texts/de_DE.lang
    - omf/survival-dkr/resource/RaiyonsDyRE/texts/el_GR.lang
    - omf/survival-dkr/resource/RaiyonsDyRE/texts/en_GB.lang
    - omf/survival-dkr/resource/RaiyonsDyRE/texts/en_US.lang
    - omf/survival-dkr/resource/RaiyonsDyRE/texts/es_ES.lang
    - omf/survival-dkr/resource/RaiyonsDyRE/texts/es_MX.lang
    - omf/survival-dkr/resource/RaiyonsDyRE/texts/fi_FI.lang
    - omf/survival-dkr/resource/RaiyonsDyRE/texts/fr_CA.lang
    - omf/survival-dkr/resource/RaiyonsDyRE/texts/fr_FR.lang
    - omf/survival-dkr/resource/RaiyonsDyRE/texts/hu_HU.lang
    - omf/survival-dkr/resource/RaiyonsDyRE/texts/id_ID.lang
    - omf/survival-dkr/resource/RaiyonsDyRE/texts/it_IT.lang
    - omf/survival-dkr/resource/RaiyonsDyRE/texts/ja_JP.lang
    - omf/survival-dkr/resource/RaiyonsDyRE/texts/ko_KR.lang
    - omf/survival-dkr/resource/RaiyonsDyRE/texts/languages.json
    - omf/survival-dkr/resource/RaiyonsDyRE/texts/nb_NO.lang
    - omf/survival-dkr/resource/RaiyonsDyRE/texts/nl_NL.lang
    - omf/survival-dkr/resource/RaiyonsDyRE/texts/pl_PL.lang
    - omf/survival-dkr/resource/RaiyonsDyRE/texts/pt_BR.lang
    - omf/survival-dkr/resource/RaiyonsDyRE/texts/pt_PT.lang
    - omf/survival-dkr/resource/RaiyonsDyRE/texts/ru_RU.lang
    - omf/survival-dkr/resource/RaiyonsDyRE/texts/sk_SK.lang
    - omf/survival-dkr/resource/RaiyonsDyRE/texts/sv_SE.lang
    - omf/survival-dkr/resource/RaiyonsDyRE/texts/tr_TR.lang
    - omf/survival-dkr/resource/RaiyonsDyRE/texts/uk_UA.lang
    - omf/survival-dkr/resource/RaiyonsDyRE/texts/zh_CN.lang
    - omf/survival-dkr/resource/RaiyonsDyRE/texts/zh_TW.lang
    - omf/survival-dkr/resource/RaiyonsDyRE/textures/armor/miner_helmet.png
    - omf/survival-dkr/resource/RaiyonsDyRE/textures/armor/torches/black_torch.png
    - omf/survival-dkr/resource/RaiyonsDyRE/textures/armor/torches/blue_torch.png
    - omf/survival-dkr/resource/RaiyonsDyRE/textures/armor/torches/brown_torch.png
    - omf/survival-dkr/resource/RaiyonsDyRE/textures/armor/torches/custom_torch.png
    - omf/survival-dkr/resource/RaiyonsDyRE/textures/armor/torches/cyan_torch.png
    - omf/survival-dkr/resource/RaiyonsDyRE/textures/armor/torches/gray_torch.png
    - omf/survival-dkr/resource/RaiyonsDyRE/textures/armor/torches/green_torch.png
    - omf/survival-dkr/resource/RaiyonsDyRE/textures/armor/torches/light_blue_torch.png
    - omf/survival-dkr/resource/RaiyonsDyRE/textures/armor/torches/light_gray_torch.png
    - omf/survival-dkr/resource/RaiyonsDyRE/textures/armor/torches/lime_torch.png
    - omf/survival-dkr/resource/RaiyonsDyRE/textures/armor/torches/magenta_torch.png
    - omf/survival-dkr/resource/RaiyonsDyRE/textures/armor/torches/orange_torch.png
    - omf/survival-dkr/resource/RaiyonsDyRE/textures/armor/torches/pink_torch.png
    - omf/survival-dkr/resource/RaiyonsDyRE/textures/armor/torches/purple_torch.png
    - omf/survival-dkr/resource/RaiyonsDyRE/textures/armor/torches/red_torch.png
    - omf/survival-dkr/resource/RaiyonsDyRE/textures/armor/torches/redstone_torch.png
    - omf/survival-dkr/resource/RaiyonsDyRE/textures/armor/torches/sea_torch.png
    - omf/survival-dkr/resource/RaiyonsDyRE/textures/armor/torches/soul_torch.png
    - omf/survival-dkr/resource/RaiyonsDyRE/textures/armor/torches/torch_on.png
    - omf/survival-dkr/resource/RaiyonsDyRE/textures/armor/torches/white_torch.png
    - omf/survival-dkr/resource/RaiyonsDyRE/textures/armor/torches/yellow_torch.png
    - omf/survival-dkr/resource/RaiyonsDyRE/textures/blocks/black_torch.png
    - omf/survival-dkr/resource/RaiyonsDyRE/textures/blocks/blue_torch.png
    - omf/survival-dkr/resource/RaiyonsDyRE/textures/blocks/brown_torch.png
    - omf/survival-dkr/resource/RaiyonsDyRE/textures/blocks/custom_torch.png
    - omf/survival-dkr/resource/RaiyonsDyRE/textures/blocks/cyan_torch.png
    - omf/survival-dkr/resource/RaiyonsDyRE/textures/blocks/gray_torch.png
    - omf/survival-dkr/resource/RaiyonsDyRE/textures/blocks/green_torch.png
    - omf/survival-dkr/resource/RaiyonsDyRE/textures/blocks/light_blue_torch.png
    - omf/survival-dkr/resource/RaiyonsDyRE/textures/blocks/light_gray_torch.png
    - omf/survival-dkr/resource/RaiyonsDyRE/textures/blocks/lime_torch.png
    - omf/survival-dkr/resource/RaiyonsDyRE/textures/blocks/magenta_torch.png
    - omf/survival-dkr/resource/RaiyonsDyRE/textures/blocks/orange_torch.png
    - omf/survival-dkr/resource/RaiyonsDyRE/textures/blocks/pink_torch.png
    - omf/survival-dkr/resource/RaiyonsDyRE/textures/blocks/purple_torch.png
    - omf/survival-dkr/resource/RaiyonsDyRE/textures/blocks/red_torch.png
    - omf/survival-dkr/resource/RaiyonsDyRE/textures/blocks/redstone_torch_on.png
    - omf/survival-dkr/resource/RaiyonsDyRE/textures/blocks/soul_torch.png
    - omf/survival-dkr/resource/RaiyonsDyRE/textures/blocks/torch_on.png
    - omf/survival-dkr/resource/RaiyonsDyRE/textures/blocks/torch_underwater.png
    - omf/survival-dkr/resource/RaiyonsDyRE/textures/blocks/white_torch.png
    - omf/survival-dkr/resource/RaiyonsDyRE/textures/blocks/yellow_torch.png
    - omf/survival-dkr/resource/RaiyonsDyRE/textures/item_texture.json
    - omf/survival-dkr/resource/RaiyonsDyRE/textures/items/helmets/chainmail.png
    - omf/survival-dkr/resource/RaiyonsDyRE/textures/items/helmets/diamond.png
    - omf/survival-dkr/resource/RaiyonsDyRE/textures/items/helmets/dyeable_icons/chainmail.png
    - omf/survival-dkr/resource/RaiyonsDyRE/textures/items/helmets/dyeable_icons/diamond.png
    - omf/survival-dkr/resource/RaiyonsDyRE/textures/items/helmets/dyeable_icons/golden.png
    - omf/survival-dkr/resource/RaiyonsDyRE/textures/items/helmets/dyeable_icons/iron.png
    - omf/survival-dkr/resource/RaiyonsDyRE/textures/items/helmets/dyeable_icons/leather.png
    - omf/survival-dkr/resource/RaiyonsDyRE/textures/items/helmets/dyeable_icons/netherite.png
    - omf/survival-dkr/resource/RaiyonsDyRE/textures/items/helmets/dyeable_icons/torch/#black.png
    - omf/survival-dkr/resource/RaiyonsDyRE/textures/items/helmets/dyeable_icons/torch/#blue.png
    - omf/survival-dkr/resource/RaiyonsDyRE/textures/items/helmets/dyeable_icons/torch/#brown.png
    - omf/survival-dkr/resource/RaiyonsDyRE/textures/items/helmets/dyeable_icons/torch/#cyan.png
    - omf/survival-dkr/resource/RaiyonsDyRE/textures/items/helmets/dyeable_icons/torch/#gray.png
    - omf/survival-dkr/resource/RaiyonsDyRE/textures/items/helmets/dyeable_icons/torch/#green.png
    - omf/survival-dkr/resource/RaiyonsDyRE/textures/items/helmets/dyeable_icons/torch/#light_blue.png
    - omf/survival-dkr/resource/RaiyonsDyRE/textures/items/helmets/dyeable_icons/torch/#light_gray.png
    - omf/survival-dkr/resource/RaiyonsDyRE/textures/items/helmets/dyeable_icons/torch/#lime.png
    - omf/survival-dkr/resource/RaiyonsDyRE/textures/items/helmets/dyeable_icons/torch/#magenta.png
    - omf/survival-dkr/resource/RaiyonsDyRE/textures/items/helmets/dyeable_icons/torch/#orange.png
    - omf/survival-dkr/resource/RaiyonsDyRE/textures/items/helmets/dyeable_icons/torch/#pink.png
    - omf/survival-dkr/resource/RaiyonsDyRE/textures/items/helmets/dyeable_icons/torch/#purple.png
    - omf/survival-dkr/resource/RaiyonsDyRE/textures/items/helmets/dyeable_icons/torch/#red.png
    - omf/survival-dkr/resource/RaiyonsDyRE/textures/items/helmets/dyeable_icons/torch/#redstone.png
    - omf/survival-dkr/resource/RaiyonsDyRE/textures/items/helmets/dyeable_icons/torch/#sea.png
    - omf/survival-dkr/resource/RaiyonsDyRE/textures/items/helmets/dyeable_icons/torch/#soul.png
    - omf/survival-dkr/resource/RaiyonsDyRE/textures/items/helmets/dyeable_icons/torch/#white.png
    - omf/survival-dkr/resource/RaiyonsDyRE/textures/items/helmets/dyeable_icons/torch/#yellow.png
    - omf/survival-dkr/resource/RaiyonsDyRE/textures/items/helmets/dyeable_icons/turtle.png
    - omf/survival-dkr/resource/RaiyonsDyRE/textures/items/helmets/golden.png
    - omf/survival-dkr/resource/RaiyonsDyRE/textures/items/helmets/iron.png
    - omf/survival-dkr/resource/RaiyonsDyRE/textures/items/helmets/leather.png
    - omf/survival-dkr/resource/RaiyonsDyRE/textures/items/helmets/netherite.png
    - omf/survival-dkr/resource/RaiyonsDyRE/textures/items/helmets/turtle.png
    - omf/survival-dkr/resource/RaiyonsDyRE/textures/items/light_block_11.png
    - omf/survival-dkr/resource/RaiyonsDyRE/textures/items/light_block_15.png
    - omf/survival-dkr/resource/RaiyonsDyRE/textures/items/light_block_8.png
    - omf/survival-dkr/resource/RaiyonsDyRE/textures/items/sea_torch.png
    - omf/survival-dkr/resource/RaiyonsDyRE/textures/models/armor/miner/chain_1.png
    - omf/survival-dkr/resource/RaiyonsDyRE/textures/models/armor/miner/cloth_1.png
    - omf/survival-dkr/resource/RaiyonsDyRE/textures/models/armor/miner/diamond_1.png
    - omf/survival-dkr/resource/RaiyonsDyRE/textures/models/armor/miner/gold_1.png
    - omf/survival-dkr/resource/RaiyonsDyRE/textures/models/armor/miner/iron_1.png
    - omf/survival-dkr/resource/RaiyonsDyRE/textures/models/armor/miner/netherite_1.png
    - omf/survival-dkr/resource/RaiyonsDyRE/textures/models/armor/miner/turtle_1.png
    - omf/survival-dkr/resource/RaiyonsDyRE/textures/particles/colorfire.png
    - omf/survival-dkr/resource/RaiyonsDyRE/textures/particles/lightning.png
    - omf/survival-dkr/resource/RaiyonsDyRE/textures/terrain_texture.json
    - omf/survival-dkr/resource/RaiyonsDyRE/textures/textures_list.json
    - omf/survival-dkr/resource/SimpleWaystoneRP/blocks.json
    - omf/survival-dkr/resource/SimpleWaystoneRP/font/glyph_E7.png
    - omf/survival-dkr/resource/SimpleWaystoneRP/manifest.json
    - omf/survival-dkr/resource/SimpleWaystoneRP/models/blocks/simple_waystone/waystone.geo.json
    - omf/survival-dkr/resource/SimpleWaystoneRP/pack_icon.png
    - omf/survival-dkr/resource/SimpleWaystoneRP/sounds/sound_definitions.json
    - omf/survival-dkr/resource/SimpleWaystoneRP/texts/en_US.lang
    - omf/survival-dkr/resource/SimpleWaystoneRP/texts/languages.json
    - omf/survival-dkr/resource/SimpleWaystoneRP/texts/pt_BR.lang
    - omf/survival-dkr/resource/SimpleWaystoneRP/textures/blocks/simple_waystone/letters.png
    - omf/survival-dkr/resource/SimpleWaystoneRP/textures/blocks/simple_waystone/letters.texture_set.json
    - omf/survival-dkr/resource/SimpleWaystoneRP/textures/blocks/simple_waystone/letters_black.png
    - omf/survival-dkr/resource/SimpleWaystoneRP/textures/blocks/simple_waystone/letters_black.texture_set.json
    - omf/survival-dkr/resource/SimpleWaystoneRP/textures/blocks/simple_waystone/letters_blue.png
    - omf/survival-dkr/resource/SimpleWaystoneRP/textures/blocks/simple_waystone/letters_blue.texture_set.json
    - omf/survival-dkr/resource/SimpleWaystoneRP/textures/blocks/simple_waystone/letters_brown.png
    - omf/survival-dkr/resource/SimpleWaystoneRP/textures/blocks/simple_waystone/letters_brown.texture_set.json
    - omf/survival-dkr/resource/SimpleWaystoneRP/textures/blocks/simple_waystone/letters_cyan.png
    - omf/survival-dkr/resource/SimpleWaystoneRP/textures/blocks/simple_waystone/letters_cyan.texture_set.json
    - omf/survival-dkr/resource/SimpleWaystoneRP/textures/blocks/simple_waystone/letters_glow.png
    - omf/survival-dkr/resource/SimpleWaystoneRP/textures/blocks/simple_waystone/letters_gray.png
    - omf/survival-dkr/resource/SimpleWaystoneRP/textures/blocks/simple_waystone/letters_gray.texture_set.json
    - omf/survival-dkr/resource/SimpleWaystoneRP/textures/blocks/simple_waystone/letters_green.png
    - omf/survival-dkr/resource/SimpleWaystoneRP/textures/blocks/simple_waystone/letters_green.texture_set.json
    - omf/survival-dkr/resource/SimpleWaystoneRP/textures/blocks/simple_waystone/letters_light_blue.png
    - omf/survival-dkr/resource/SimpleWaystoneRP/textures/blocks/simple_waystone/letters_light_blue.texture_set.json
    - omf/survival-dkr/resource/SimpleWaystoneRP/textures/blocks/simple_waystone/letters_light_gray.png
    - omf/survival-dkr/resource/SimpleWaystoneRP/textures/blocks/simple_waystone/letters_light_gray.texture_set.json
    - omf/survival-dkr/resource/SimpleWaystoneRP/textures/blocks/simple_waystone/letters_lime.png
    - omf/survival-dkr/resource/SimpleWaystoneRP/textures/blocks/simple_waystone/letters_lime.texture_set.json
    - omf/survival-dkr/resource/SimpleWaystoneRP/textures/blocks/simple_waystone/letters_magenta.png
    - omf/survival-dkr/resource/SimpleWaystoneRP/textures/blocks/simple_waystone/letters_magenta.texture_set.json
    - omf/survival-dkr/resource/SimpleWaystoneRP/textures/blocks/simple_waystone/letters_orange.png
    - omf/survival-dkr/resource/SimpleWaystoneRP/textures/blocks/simple_waystone/letters_orange.texture_set.json
    - omf/survival-dkr/resource/SimpleWaystoneRP/textures/blocks/simple_waystone/letters_pink.png
    - omf/survival-dkr/resource/SimpleWaystoneRP/textures/blocks/simple_waystone/letters_pink.texture_set.json
    - omf/survival-dkr/resource/SimpleWaystoneRP/textures/blocks/simple_waystone/letters_purple.png
    - omf/survival-dkr/resource/SimpleWaystoneRP/textures/blocks/simple_waystone/letters_purple.texture_set.json
    - omf/survival-dkr/resource/SimpleWaystoneRP/textures/blocks/simple_waystone/letters_red.png
    - omf/survival-dkr/resource/SimpleWaystoneRP/textures/blocks/simple_waystone/letters_red.texture_set.json
    - omf/survival-dkr/resource/SimpleWaystoneRP/textures/blocks/simple_waystone/letters_yellow.png
    - omf/survival-dkr/resource/SimpleWaystoneRP/textures/blocks/simple_waystone/letters_yellow.texture_set.json
    - omf/survival-dkr/resource/SimpleWaystoneRP/textures/flipbook_textures.json
    - omf/survival-dkr/resource/SimpleWaystoneRP/textures/item_texture.json
    - omf/survival-dkr/resource/SimpleWaystoneRP/textures/items/simple_waystone/golden_feather.png
    - omf/survival-dkr/resource/SimpleWaystoneRP/textures/items/simple_waystone/return_scroll.png
    - omf/survival-dkr/resource/SimpleWaystoneRP/textures/items/simple_waystone/warpstone.png
    - omf/survival-dkr/resource/SimpleWaystoneRP/textures/terrain_texture.json
    - omf/survival-dkr/restore_backup.sh
    - omf/survival-dkr/sh/install_script.sh
    - omf/survival-dkr/update_map.sh
  - 変更サマリ(stat):
     omf/survival-dkr/backup_now.sh                     |   47 +-
     .../FFLBehaviorPack/functions/acacia1.2.mcfunction |  500 ++++++++
     .../FFLBehaviorPack/functions/acacia1.mcfunction   |  500 ++++++++
     .../FFLBehaviorPack/functions/acacia2.2.mcfunction |  500 ++++++++
     .../FFLBehaviorPack/functions/acacia2.mcfunction   |  500 ++++++++
     .../FFLBehaviorPack/functions/acacia3.2.mcfunction |  500 ++++++++
     .../FFLBehaviorPack/functions/acacia3.mcfunction   |  500 ++++++++
     .../FFLBehaviorPack/functions/acacia4.2.mcfunction |  500 ++++++++
     .../FFLBehaviorPack/functions/acacia4.mcfunction   |  500 ++++++++
     .../FFLBehaviorPack/functions/acacia5.2.mcfunction |  500 ++++++++
     .../FFLBehaviorPack/functions/acacia5.mcfunction   |  500 ++++++++
     .../FFLBehaviorPack/functions/acacia6.2.mcfunction |  500 ++++++++
     .../FFLBehaviorPack/functions/acacia6.mcfunction   |  500 ++++++++
     .../FFLBehaviorPack/functions/acacia7.2.mcfunction |  500 ++++++++
     .../FFLBehaviorPack/functions/acacia7.mcfunction   |  500 ++++++++
     .../FFLBehaviorPack/functions/acacia8.2.mcfunction |  500 ++++++++
     .../FFLBehaviorPack/functions/acacia8.mcfunction   |  500 ++++++++
     .../FFLBehaviorPack/functions/acacia9.2.mcfunction |  500 ++++++++
     .../FFLBehaviorPack/functions/acacia9.mcfunction   |  761 ++++++++++++
     .../FFLBehaviorPack/functions/azalea1.2.mcfunction |  500 ++++++++
     .../FFLBehaviorPack/functions/azalea1.mcfunction   |  500 ++++++++
     .../FFLBehaviorPack/functions/azalea2.2.mcfunction |  500 ++++++++
     .../FFLBehaviorPack/functions/azalea2.mcfunction   |  500 ++++++++
     .../FFLBehaviorPack/functions/azalea3.2.mcfunction |  500 ++++++++
     .../FFLBehaviorPack/functions/azalea3.mcfunction   |  500 ++++++++
     .../FFLBehaviorPack/functions/azalea4.2.mcfunction |  500 ++++++++
     .../FFLBehaviorPack/functions/azalea4.mcfunction   |  500 ++++++++
     .../FFLBehaviorPack/functions/azalea5.2.mcfunction |  500 ++++++++
     .../FFLBehaviorPack/functions/azalea5.mcfunction   |  500 ++++++++
     .../FFLBehaviorPack/functions/azalea6.2.mcfunction |  500 ++++++++
     .../FFLBehaviorPack/functions/azalea6.mcfunction   |  500 ++++++++
     .../FFLBehaviorPack/functions/azalea7.2.mcfunction |  500 ++++++++
     .../FFLBehaviorPack/functions/azalea7.mcfunction   |  500 ++++++++
     .../FFLBehaviorPack/functions/azalea8.2.mcfunction |  500 ++++++++
     .../FFLBehaviorPack/functions/azalea8.mcfunction   |  500 ++++++++
     .../FFLBehaviorPack/functions/azalea9.2.mcfunction |  500 ++++++++
     .../FFLBehaviorPack/functions/azalea9.mcfunction   |  761 ++++++++++++
     .../functions/azaleaflowered1.2.mcfunction         |  500 ++++++++
     .../functions/azaleaflowered1.mcfunction           |  500 ++++++++
     .../functions/azaleaflowered2.2.mcfunction         |  500 ++++++++
     .../functions/azaleaflowered2.mcfunction           |  500 ++++++++
     .../functions/azaleaflowered3.2.mcfunction         |  500 ++++++++
     .../functions/azaleaflowered3.mcfunction           |  500 ++++++++
     .../functions/azaleaflowered4.2.mcfunction         |  500 ++++++++
     .../functions/azaleaflowered4.mcfunction           |  500 ++++++++
     .../functions/azaleaflowered5.2.mcfunction         |  500 ++++++++
     .../functions/azaleaflowered5.mcfunction           |  500 ++++++++
     .../functions/azaleaflowered6.2.mcfunction         |  500 ++++++++
     .../functions/azaleaflowered6.mcfunction           |  500 ++++++++
     .../functions/azaleaflowered7.2.mcfunction         |  500 ++++++++
     .../functions/azaleaflowered7.mcfunction           |  500 ++++++++
     .../functions/azaleaflowered8.2.mcfunction         |  500 ++++++++
     .../functions/azaleaflowered8.mcfunction           |  500 ++++++++
     .../functions/azaleaflowered9.2.mcfunction         |  500 ++++++++
     .../functions/azaleaflowered9.mcfunction           |  761 ++++++++++++
     .../FFLBehaviorPack/functions/birch1.2.mcfunction  |  500 ++++++++
     .../FFLBehaviorPack/functions/birch1.mcfunction    |  500 ++++++++
     .../FFLBehaviorPack/functions/birch2.2.mcfunction  |  500 ++++++++
     .../FFLBehaviorPack/functions/birch2.mcfunction    |  500 ++++++++
     .../FFLBehaviorPack/functions/birch3.2.mcfunction  |  500 ++++++++
     .../FFLBehaviorPack/functions/birch3.mcfunction    |  500 ++++++++
     .../FFLBehaviorPack/functions/birch4.2.mcfunction  |  500 ++++++++
     .../FFLBehaviorPack/functions/birch4.mcfunction    |  500 ++++++++
     .../FFLBehaviorPack/functions/birch5.2.mcfunction  |  500 ++++++++
     .../FFLBehaviorPack/functions/birch5.mcfunction    |  500 ++++++++
     .../FFLBehaviorPack/functions/birch6.2.mcfunction  |  500 ++++++++
     .../FFLBehaviorPack/functions/birch6.mcfunction    |  500 ++++++++
     .../FFLBehaviorPack/functions/birch7.2.mcfunction  |  500 ++++++++
     .../FFLBehaviorPack/functions/birch7.mcfunction    |  500 ++++++++
     .../FFLBehaviorPack/functions/birch8.2.mcfunction  |  500 ++++++++
     .../FFLBehaviorPack/functions/birch8.mcfunction    |  500 ++++++++
     .../FFLBehaviorPack/functions/birch9.2.mcfunction  |  500 ++++++++
     .../FFLBehaviorPack/functions/birch9.mcfunction    |  761 ++++++++++++
     .../functions/dark_oak1.2.mcfunction               |  500 ++++++++
     .../FFLBehaviorPack/functions/dark_oak1.mcfunction |  500 ++++++++
     .../functions/dark_oak2.2.mcfunction               |  500 ++++++++
     .../FFLBehaviorPack/functions/dark_oak2.mcfunction |  500 ++++++++
     .../functions/dark_oak3.2.mcfunction               |  500 ++++++++
     .../FFLBehaviorPack/functions/dark_oak3.mcfunction |  500 ++++++++
     .../functions/dark_oak4.2.mcfunction               |  500 ++++++++
     .../FFLBehaviorPack/functions/dark_oak4.mcfunction |  500 ++++++++
     .../functions/dark_oak5.2.mcfunction               |  500 ++++++++
     .../FFLBehaviorPack/functions/dark_oak5.mcfunction |  500 ++++++++
     .../functions/dark_oak6.2.mcfunction               |  500 ++++++++
     .../FFLBehaviorPack/functions/dark_oak6.mcfunction |  500 ++++++++
     .../functions/dark_oak7.2.mcfunction               |  500 ++++++++
     .../FFLBehaviorPack/functions/dark_oak7.mcfunction |  500 ++++++++
     .../functions/dark_oak8.2.mcfunction               |  500 ++++++++
     .../FFLBehaviorPack/functions/dark_oak8.mcfunction |  500 ++++++++
     .../functions/dark_oak9.2.mcfunction               |  500 ++++++++
     .../FFLBehaviorPack/functions/dark_oak9.mcfunction |  761 ++++++++++++
     .../FFLBehaviorPack/functions/jungle1.2.mcfunction |  500 ++++++++
     .../FFLBehaviorPack/functions/jungle1.mcfunction   |  500 ++++++++
     .../FFLBehaviorPack/functions/jungle2.2.mcfunction |  500 ++++++++
     .../FFLBehaviorPack/functions/jungle2.mcfunction   |  500 ++++++++
     .../FFLBehaviorPack/functions/jungle3.2.mcfunction |  500 ++++++++
     .../FFLBehaviorPack/functions/jungle3.mcfunction   |  500 ++++++++
     .../FFLBehaviorPack/functions/jungle4.2.mcfunction |  500 ++++++++
     .../FFLBehaviorPack/functions/jungle4.mcfunction   |  500 ++++++++
     .../FFLBehaviorPack/functions/jungle5.2.mcfunction |  500 ++++++++
     .../FFLBehaviorPack/functions/jungle5.mcfunction   |  500 ++++++++
     .../FFLBehaviorPack/functions/jungle6.2.mcfunction |  500 ++++++++
     .../FFLBehaviorPack/functions/jungle6.mcfunction   |  500 ++++++++
     .../FFLBehaviorPack/functions/jungle7.2.mcfunction |  500 ++++++++
     .../FFLBehaviorPack/functions/jungle7.mcfunction   |  500 ++++++++
     .../FFLBehaviorPack/functions/jungle8.2.mcfunction |  500 ++++++++
     .../FFLBehaviorPack/functions/jungle8.mcfunction   |  500 ++++++++
     .../FFLBehaviorPack/functions/jungle9.2.mcfunction |  500 ++++++++
     .../FFLBehaviorPack/functions/jungle9.mcfunction   |  761 ++++++++++++
     .../functions/mangrove1.2.mcfunction               |  500 ++++++++
     .../FFLBehaviorPack/functions/mangrove1.mcfunction |  500 ++++++++
     .../functions/mangrove2.2.mcfunction               |  500 ++++++++
     .../FFLBehaviorPack/functions/mangrove2.mcfunction |  500 ++++++++
     .../functions/mangrove3.2.mcfunction               |  500 ++++++++
     .../FFLBehaviorPack/functions/mangrove3.mcfunction |  500 ++++++++
     .../functions/mangrove4.2.mcfunction               |  500 ++++++++
     .../FFLBehaviorPack/functions/mangrove4.mcfunction |  500 ++++++++
     .../functions/mangrove5.2.mcfunction               |  500 ++++++++
     .../FFLBehaviorPack/functions/mangrove5.mcfunction |  500 ++++++++
     .../functions/mangrove6.2.mcfunction               |  500 ++++++++
     .../FFLBehaviorPack/functions/mangrove6.mcfunction |  500 ++++++++
     .../functions/mangrove7.2.mcfunction               |  500 ++++++++
     .../FFLBehaviorPack/functions/mangrove7.mcfunction |  500 ++++++++
     .../functions/mangrove8.2.mcfunction               |  500 ++++++++
     .../FFLBehaviorPack/functions/mangrove8.mcfunction |  500 ++++++++
     .../functions/mangrove9.2.mcfunction               |  500 ++++++++
     .../FFLBehaviorPack/functions/mangrove9.mcfunction |  761 ++++++++++++
     .../FFLBehaviorPack/functions/megafused.mcfunction |  175 +++
     .../FFLBehaviorPack/functions/oak1.2.mcfunction    |  500 ++++++++
     .../FFLBehaviorPack/functions/oak1.mcfunction      |  500 ++++++++
     .../FFLBehaviorPack/functions/oak2.2.mcfunction    |  500 ++++++++
     .../FFLBehaviorPack/functions/oak2.mcfunction      |  500 ++++++++
     .../FFLBehaviorPack/functions/oak3.2.mcfunction    |  500 ++++++++
     .../FFLBehaviorPack/functions/oak3.mcfunction      |  500 ++++++++
     .../FFLBehaviorPack/functions/oak4.2.mcfunction    |  500 ++++++++
     .../FFLBehaviorPack/functions/oak4.mcfunction      |  500 ++++++++
     .../FFLBehaviorPack/functions/oak5.2.mcfunction    |  500 ++++++++
     .../FFLBehaviorPack/functions/oak5.mcfunction      |  500 ++++++++
     .../FFLBehaviorPack/functions/oak6.2.mcfunction    |  500 ++++++++
     .../FFLBehaviorPack/functions/oak6.mcfunction      |  500 ++++++++
     .../FFLBehaviorPack/functions/oak7.2.mcfunction    |  500 ++++++++
     .../FFLBehaviorPack/functions/oak7.mcfunction      |  500 ++++++++
     .../FFLBehaviorPack/functions/oak8.2.mcfunction    |  500 ++++++++
     .../FFLBehaviorPack/functions/oak8.mcfunction      |  500 ++++++++
     .../FFLBehaviorPack/functions/oak9.2.mcfunction    |  500 ++++++++
     .../FFLBehaviorPack/functions/oak9.mcfunction      |  761 ++++++++++++
     .../FFLBehaviorPack/functions/spruce1.2.mcfunction |  500 ++++++++
     .../FFLBehaviorPack/functions/spruce1.mcfunction   |  500 ++++++++
     .../FFLBehaviorPack/functions/spruce2.2.mcfunction |  500 ++++++++
     .../FFLBehaviorPack/functions/spruce2.mcfunction   |  500 ++++++++
     .../FFLBehaviorPack/functions/spruce3.2.mcfunction |  500 ++++++++
     .../FFLBehaviorPack/functions/spruce3.mcfunction   |  500 ++++++++
     .../FFLBehaviorPack/functions/spruce4.2.mcfunction |  500 ++++++++
     .../FFLBehaviorPack/functions/spruce4.mcfunction   |  500 ++++++++
     .../FFLBehaviorPack/functions/spruce5.2.mcfunction |  500 ++++++++
     .../FFLBehaviorPack/functions/spruce5.mcfunction   |  500 ++++++++
     .../FFLBehaviorPack/functions/spruce6.2.mcfunction |  500 ++++++++
     .../FFLBehaviorPack/functions/spruce6.mcfunction   |  500 ++++++++
     .../FFLBehaviorPack/functions/spruce7.2.mcfunction |  500 ++++++++
     .../FFLBehaviorPack/functions/spruce7.mcfunction   |  500 ++++++++
     .../FFLBehaviorPack/functions/spruce8.2.mcfunction |  500 ++++++++
     .../FFLBehaviorPack/functions/spruce8.mcfunction   |  500 ++++++++
     .../FFLBehaviorPack/functions/spruce9.2.mcfunction |  500 ++++++++
     .../FFLBehaviorPack/functions/spruce9.mcfunction   |  761 ++++++++++++
     .../behavior/FFLBehaviorPack/functions/tick.json   |    5 +
     .../behavior/FFLBehaviorPack/manifest.json         |   29 +
     .../behavior/FFLBehaviorPack/pack_icon.png         |  Bin 0 -> 1701481 bytes
     .../RaiyonsDyBe/blocks/torches/black_torch.json    |  137 ++
     .../RaiyonsDyBe/blocks/torches/blue_torch.json     |  137 ++
     .../RaiyonsDyBe/blocks/torches/brown_torch.json    |  137 ++
     .../RaiyonsDyBe/blocks/torches/cyan_torch.json     |  137 ++
     .../RaiyonsDyBe/blocks/torches/gray_torch.json     |  137 ++
     .../RaiyonsDyBe/blocks/torches/green_torch.json    |  137 ++
     .../blocks/torches/light_blue_torch.json           |  137 ++
     .../blocks/torches/light_gray_torch.json           |  137 ++
     .../RaiyonsDyBe/blocks/torches/lime_torch.json     |  137 ++
     .../RaiyonsDyBe/blocks/torches/magenta_torch.json  |  137 ++
     .../RaiyonsDyBe/blocks/torches/orange_torch.json   |  137 ++
     .../RaiyonsDyBe/blocks/torches/pink_torch.json     |  137 ++
     .../RaiyonsDyBe/blocks/torches/purple_torch.json   |  137 ++
     .../RaiyonsDyBe/blocks/torches/red_torch.json      |  137 ++
     .../RaiyonsDyBe/blocks/torches/white_torch.json    |  137 ++
     .../RaiyonsDyBe/blocks/torches/yellow_torch.json   |  137 ++
     .../RaiyonsDyBe/functions/player.mcfunction        |    1 +
     .../behavior/RaiyonsDyBe/functions/tick.json       |    6 +
     .../item_catalog/crafting_item_catalog.json        |   73 ++
     .../chain/chainmail_black_torch_helmet.json        |   55 +
     .../chain/chainmail_blue_torch_helmet.json         |   55 +
     .../chain/chainmail_brown_torch_helmet.json        |   55 +
     .../chain/chainmail_cyan_torch_helmet.json         |   55 +
     .../chain/chainmail_gray_torch_helmet.json         |   55 +
     .../chain/chainmail_green_torch_helmet.json        |   55 +
     .../chain/chainmail_light_blue_torch_helmet.json   |   55 +
     .../chain/chainmail_light_gray_torch_helmet.json   |   55 +
     .../chain/chainmail_lime_torch_helmet.json         |   55 +
     .../chain/chainmail_magenta_torch_helmet.json      |   55 +
     .../chain/chainmail_orange_torch_helmet.json       |   55 +
     .../chain/chainmail_pink_torch_helmet.json         |   55 +
     .../chain/chainmail_purple_torch_helmet.json       |   55 +
     .../chain/chainmail_red_torch_helmet.json          |   55 +
     .../chain/chainmail_redstone_torch_helmet.json     |   55 +
     .../chain/chainmail_sea_torch_helmet.json          |   55 +
     .../chain/chainmail_soul_torch_helmet.json         |   55 +
     .../chain/chainmail_white_torch_helmet.json        |   55 +
     .../chain/chainmail_yellow_torch_helmet.json       |   55 +
     .../diamond/diamond_black_torch_helmet.json        |   55 +
     .../diamond/diamond_blue_torch_helmet.json         |   55 +
     .../diamond/diamond_brown_torch_helmet.json        |   55 +
     .../diamond/diamond_cyan_torch_helmet.json         |   55 +
     .../diamond/diamond_gray_torch_helmet.json         |   55 +
     .../diamond/diamond_green_torch_helmet.json        |   55 +
     .../diamond/diamond_light_blue_torch_helmet.json   |   55 +
     .../diamond/diamond_light_gray_torch_helmet.json   |   55 +
     .../diamond/diamond_lime_torch_helmet.json         |   55 +
     .../diamond/diamond_magenta_torch_helmet.json      |   55 +
     .../diamond/diamond_orange_torch_helmet.json       |   55 +
     .../diamond/diamond_pink_torch_helmet.json         |   55 +
     .../diamond/diamond_purple_torch_helmet.json       |   55 +
     .../diamond/diamond_red_torch_helmet.json          |   55 +
     .../diamond/diamond_redstone_torch_helmet.json     |   55 +
     .../diamond/diamond_sea_torch_helmet.json          |   55 +
     .../diamond/diamond_soul_torch_helmet.json         |   55 +
     .../diamond/diamond_white_torch_helmet.json        |   55 +
     .../diamond/diamond_yellow_torch_helmet.json       |   55 +
     .../gold/golden_black_torch_helmet.json            |   55 +
     .../gold/golden_blue_torch_helmet.json             |   55 +
     .../gold/golden_brown_torch_helmet.json            |   55 +
     .../gold/golden_cyan_torch_helmet.json             |   55 +
     .../gold/golden_gray_torch_helmet.json             |   55 +
     .../gold/golden_green_torch_helmet.json            |   55 +
     .../gold/golden_light_blue_torch_helmet.json       |   55 +
     .../gold/golden_light_gray_torch_helmet.json       |   55 +
     .../gold/golden_lime_torch_helmet.json             |   55 +
     .../gold/golden_magenta_torch_helmet.json          |   55 +
     .../gold/golden_orange_torch_helmet.json           |   55 +
     .../gold/golden_pink_torch_helmet.json             |   55 +
     .../gold/golden_purple_torch_helmet.json           |   55 +
     .../dyed_helmets/gold/golden_red_torch_helmet.json |   55 +
     .../gold/golden_redstone_torch_helmet.json         |   55 +
     .../dyed_helmets/gold/golden_sea_torch_helmet.json |   55 +
     .../gold/golden_soul_torch_helmet.json             |   55 +
     .../gold/golden_white_torch_helmet.json            |   55 +
     .../gold/golden_yellow_torch_helmet.json           |   55 +
     .../dyed_helmets/iron/iron_black_torch_helmet.json |   55 +
     .../dyed_helmets/iron/iron_blue_torch_helmet.json  |   55 +
     .../dyed_helmets/iron/iron_brown_torch_helmet.json |   55 +
     .../dyed_helmets/iron/iron_cyan_torch_helmet.json  |   55 +
     .../dyed_helmets/iron/iron_gray_torch_helmet.json  |   55 +
     .../dyed_helmets/iron/iron_green_torch_helmet.json |   55 +
     .../iron/iron_light_blue_torch_helmet.json         |   55 +
     .../iron/iron_light_gray_torch_helmet.json         |   55 +
     .../dyed_helmets/iron/iron_lime_torch_helmet.json  |   55 +
     .../iron/iron_magenta_torch_helmet.json            |   55 +
     .../iron/iron_orange_torch_helmet.json             |   55 +
     .../dyed_helmets/iron/iron_pink_torch_helmet.json  |   55 +
     .../iron/iron_purple_torch_helmet.json             |   55 +
     .../dyed_helmets/iron/iron_red_torch_helmet.json   |   55 +
     .../iron/iron_redstone_torch_helmet.json           |   55 +
     .../dyed_helmets/iron/iron_sea_torch_helmet.json   |   55 +
     .../dyed_helmets/iron/iron_soul_torch_helmet.json  |   55 +
     .../dyed_helmets/iron/iron_white_torch_helmet.json |   55 +
     .../iron/iron_yellow_torch_helmet.json             |   55 +
     .../leather/leather_black_torch_helmet.json        |   55 +
     .../leather/leather_blue_torch_helmet.json         |   55 +
     .../leather/leather_brown_torch_helmet.json        |   55 +
     .../leather/leather_cyan_torch_helmet.json         |   55 +
     .../leather/leather_gray_torch_helmet.json         |   55 +
     .../leather/leather_green_torch_helmet.json        |   55 +
     .../leather/leather_light_blue_torch_helmet.json   |   55 +
     .../leather/leather_light_gray_torch_helmet.json   |   55 +
     .../leather/leather_lime_torch_helmet.json         |   55 +
     .../leather/leather_magenta_torch_helmet.json      |   55 +
     .../leather/leather_orange_torch_helmet.json       |   55 +
     .../leather/leather_pink_torch_helmet.json         |   55 +
     .../leather/leather_purple_torch_helmet.json       |   55 +
     .../leather/leather_red_torch_helmet.json          |   55 +
     .../leather/leather_redstone_torch_helmet.json     |   55 +
     .../leather/leather_sea_torch_helmet.json          |   55 +
     .../leather/leather_soul_torch_helmet.json         |   55 +
     .../leather/leather_white_torch_helmet.json        |   55 +
     .../leather/leather_yellow_torch_helmet.json       |   55 +
     .../netherite/netherite_black_torch_helmet.json    |   55 +
     .../netherite/netherite_blue_torch_helmet.json     |   55 +
     .../netherite/netherite_brown_torch_helmet.json    |   55 +
     .../netherite/netherite_cyan_torch_helmet.json     |   55 +
     .../netherite/netherite_gray_torch_helmet.json     |   55 +
     .../netherite/netherite_green_torch_helmet.json    |   55 +
     .../netherite_light_blue_torch_helmet.json         |   55 +
     .../netherite_light_gray_torch_helmet.json         |   55 +
     .../netherite/netherite_lime_torch_helmet.json     |   55 +
     .../netherite/netherite_magenta_torch_helmet.json  |   55 +
     .../netherite/netherite_orange_torch_helmet.json   |   55 +
     .../netherite/netherite_pink_torch_helmet.json     |   55 +
     .../netherite/netherite_purple_torch_helmet.json   |   55 +
     .../netherite/netherite_red_torch_helmet.json      |   55 +
     .../netherite/netherite_redstone_torch_helmet.json |   55 +
     .../netherite/netherite_sea_torch_helmet.json      |   55 +
     .../netherite/netherite_soul_torch_helmet.json     |   55 +
     .../netherite/netherite_white_torch_helmet.json    |   55 +
     .../netherite/netherite_yellow_torch_helmet.json   |   55 +
     .../turtle/turtle_black_torch_helmet.json          |   55 +
     .../turtle/turtle_blue_torch_helmet.json           |   55 +
     .../turtle/turtle_brown_torch_helmet.json          |   55 +
     .../turtle/turtle_cyan_torch_helmet.json           |   55 +
     .../turtle/turtle_gray_torch_helmet.json           |   55 +
     .../turtle/turtle_green_torch_helmet.json          |   55 +
     .../turtle/turtle_light_blue_torch_helmet.json     |   55 +
     .../turtle/turtle_light_gray_torch_helmet.json     |   55 +
     .../turtle/turtle_lime_torch_helmet.json           |   55 +
     .../turtle/turtle_magenta_torch_helmet.json        |   55 +
     .../turtle/turtle_orange_torch_helmet.json         |   55 +
     .../turtle/turtle_pink_torch_helmet.json           |   55 +
     .../turtle/turtle_purple_torch_helmet.json         |   55 +
     .../turtle/turtle_red_torch_helmet.json            |   55 +
     .../turtle/turtle_redstone_torch_helmet.json       |   55 +
     .../turtle/turtle_sea_torch_helmet.json            |   55 +
     .../turtle/turtle_soul_torch_helmet.json           |   55 +
     .../turtle/turtle_white_torch_helmet.json          |   55 +
     .../turtle/turtle_yellow_torch_helmet.json         |   55 +
     .../RaiyonsDyBe/items/helmets/chainmail.json       |   44 +
     .../RaiyonsDyBe/items/helmets/diamond.json         |   55 +
     .../behavior/RaiyonsDyBe/items/helmets/gold.json   |   54 +
     .../behavior/RaiyonsDyBe/items/helmets/iron.json   |   54 +
     .../RaiyonsDyBe/items/helmets/leather.json         |   54 +
     .../RaiyonsDyBe/items/helmets/netherite.json       |   54 +
     .../behavior/RaiyonsDyBe/items/helmets/turtle.json |   54 +
     .../items/torches/dyed/black_torch_item.json       |   27 +
     .../items/torches/dyed/blue_torch_item.json        |   27 +
     .../items/torches/dyed/brown_torch_item.json       |   27 +
     .../items/torches/dyed/cyan_torch_item.json        |   27 +
     .../items/torches/dyed/gray_torch_item.json        |   27 +
     .../items/torches/dyed/green_torch_item.json       |   27 +
     .../items/torches/dyed/light_blue_torch_item.json  |   27 +
     .../items/torches/dyed/light_gray_torch_item.json  |   27 +
     .../items/torches/dyed/lime_torch_item.json        |   27 +
     .../items/torches/dyed/magenta_torch_item.json     |   27 +
     .../items/torches/dyed/orange_torch_item.json      |   27 +
     .../items/torches/dyed/pink_torch_item.json        |   27 +
     .../items/torches/dyed/purple_torch_item.json      |   27 +
     .../items/torches/dyed/red_torch_item.json         |   27 +
     .../items/torches/dyed/white_torch_item.json       |   27 +
     .../items/torches/dyed/yellow_torch_item.json      |   27 +
     .../RaiyonsDyBe/items/torches/sea_torch.json       |   24 +
     .../behavior/RaiyonsDyBe/manifest.json             |   39 +
     .../behavior/RaiyonsDyBe/pack_icon.png             |  Bin 0 -> 2442 bytes
     .../chainmail_black_torch_helmet_recipe.json       |   33 +
     .../chainmail_blue_torch_helmet_recipe.json        |   33 +
     .../chainmail_brown_torch_helmet_recipe.json       |   33 +
     .../chainmail_cyan_torch_helmet_recipe.json        |   33 +
     .../chainmail_gray_torch_helmet_recipe.json        |   33 +
     .../chainmail_green_torch_helmet_recipe.json       |   33 +
     .../chainmail_light_blue_torch_helmet_recipe.json  |   33 +
     .../chainmail_light_gray_torch_helmet_recipe.json  |   33 +
     .../chainmail_lime_torch_helmet_recipe.json        |   33 +
     .../chainmail_magenta_torch_helmet_recipe.json     |   33 +
     .../chainmail_orange_torch_helmet_recipe.json      |   33 +
     .../chainmail_pink_torch_helmet_recipe.json        |   33 +
     .../chainmail_purple_torch_helmet_recipe.json      |   33 +
     .../chainmail_red_torch_helmet_recipe.json         |   33 +
     .../chainmail_redstone_torch_helmet_recipe.json    |   33 +
     .../chainmail_sea_torch_helmet_recipe.json         |   33 +
     .../chainmail_soul_torch_helmet_recipe.json        |   33 +
     .../chainmail_white_torch_helmet_recipe.json       |   33 +
     .../chainmail_yellow_torch_helmet_recipe.json      |   33 +
     .../diamond_black_torch_helmet_recipe.json         |   33 +
     .../diamond_blue_torch_helmet_recipe.json          |   33 +
     .../diamond_brown_torch_helmet_recipe.json         |   33 +
     .../diamond_cyan_torch_helmet_recipe.json          |   33 +
     .../diamond_gray_torch_helmet_recipe.json          |   33 +
     .../diamond_green_torch_helmet_recipe.json         |   33 +
     .../diamond_light_blue_torch_helmet_recipe.json    |   33 +
     .../diamond_light_gray_torch_helmet_recipe.json    |   33 +
     .../diamond_lime_torch_helmet_recipe.json          |   33 +
     .../diamond_magenta_torch_helmet_recipe.json       |   33 +
     .../diamond_orange_torch_helmet_recipe.json        |   33 +
     .../diamond_pink_torch_helmet_recipe.json          |   33 +
     .../diamond_purple_torch_helmet_recipe.json        |   33 +
     .../diamond_red_torch_helmet_recipe.json           |   33 +
     .../diamond_redstone_torch_helmet_recipe.json      |   33 +
     .../diamond_sea_torch_helmet_recipe.json           |   33 +
     .../diamond_soul_torch_helmet_recipe.json          |   33 +
     .../diamond_white_torch_helmet_recipe.json         |   33 +
     .../diamond_yellow_torch_helmet_recipe.json        |   33 +
     .../golden_black_torch_helmet_recipe.json          |   33 +
     .../golden_blue_torch_helmet_recipe.json           |   33 +
     .../golden_brown_torch_helmet_recipe.json          |   33 +
     .../golden_cyan_torch_helmet_recipe.json           |   33 +
     .../golden_gray_torch_helmet_recipe.json           |   33 +
     .../golden_green_torch_helmet_recipe.json          |   33 +
     .../golden_light_blue_torch_helmet_recipe.json     |   33 +
     .../golden_light_gray_torch_helmet_recipe.json     |   33 +
     .../golden_lime_torch_helmet_recipe.json           |   33 +
     .../golden_magenta_torch_helmet_recipe.json        |   33 +
     .../golden_orange_torch_helmet_recipe.json         |   33 +
     .../golden_pink_torch_helmet_recipe.json           |   33 +
     .../golden_purple_torch_helmet_recipe.json         |   33 +
     .../golden_red_torch_helmet_recipe.json            |   33 +
     .../golden_redstone_torch_helmet_recipe.json       |   33 +
     .../golden_sea_torch_helmet_recipe.json            |   33 +
     .../golden_soul_torch_helmet_recipe.json           |   33 +
     .../golden_white_torch_helmet_recipe.json          |   33 +
     .../golden_yellow_torch_helmet_recipe.json         |   33 +
     .../iron_black_torch_helmet_recipe.json            |   33 +
     .../iron_blue_torch_helmet_recipe.json             |   33 +
     .../iron_brown_torch_helmet_recipe.json            |   33 +
     .../iron_cyan_torch_helmet_recipe.json             |   33 +
     .../iron_gray_torch_helmet_recipe.json             |   33 +
     .../iron_green_torch_helmet_recipe.json            |   33 +
     .../iron_light_blue_torch_helmet_recipe.json       |   33 +
     .../iron_light_gray_torch_helmet_recipe.json       |   33 +
     .../iron_lime_torch_helmet_recipe.json             |   33 +
     .../iron_magenta_torch_helmet_recipe.json          |   33 +
     .../iron_orange_torch_helmet_recipe.json           |   33 +
     .../iron_pink_torch_helmet_recipe.json             |   33 +
     .../iron_purple_torch_helmet_recipe.json           |   33 +
     .../dyed_helmets/iron_red_torch_helmet_recipe.json |   33 +
     .../iron_redstone_torch_helmet_recipe.json         |   33 +
     .../dyed_helmets/iron_sea_torch_helmet_recipe.json |   33 +
     .../iron_soul_torch_helmet_recipe.json             |   33 +
     .../iron_white_torch_helmet_recipe.json            |   33 +
     .../iron_yellow_torch_helmet_recipe.json           |   33 +
     .../leather_black_torch_helmet_recipe.json         |   33 +
     .../leather_blue_torch_helmet_recipe.json          |   33 +
     .../leather_brown_torch_helmet_recipe.json         |   33 +
     .../leather_cyan_torch_helmet_recipe.json          |   33 +
     .../leather_gray_torch_helmet_recipe.json          |   33 +
     .../leather_green_torch_helmet_recipe.json         |   33 +
     .../leather_light_blue_torch_helmet_recipe.json    |   33 +
     .../leather_light_gray_torch_helmet_recipe.json    |   33 +
     .../leather_lime_torch_helmet_recipe.json          |   33 +
     .../leather_magenta_torch_helmet_recipe.json       |   33 +
     .../leather_orange_torch_helmet_recipe.json        |   33 +
     .../leather_pink_torch_helmet_recipe.json          |   33 +
     .../leather_purple_torch_helmet_recipe.json        |   33 +
     .../leather_red_torch_helmet_recipe.json           |   33 +
     .../leather_redstone_torch_helmet_recipe.json      |   33 +
     .../leather_sea_torch_helmet_recipe.json           |   33 +
     .../leather_soul_torch_helmet_recipe.json          |   33 +
     .../leather_white_torch_helmet_recipe.json         |   33 +
     .../leather_yellow_torch_helmet_recipe.json        |   33 +
     .../netherite_black_torch_helmet_recipe.json       |   33 +
     .../netherite_blue_torch_helmet_recipe.json        |   33 +
     .../netherite_brown_torch_helmet_recipe.json       |   33 +
     .../netherite_cyan_torch_helmet_recipe.json        |   33 +
     .../netherite_gray_torch_helmet_recipe.json        |   33 +
     .../netherite_green_torch_helmet_recipe.json       |   33 +
     .../netherite_light_blue_torch_helmet_recipe.json  |   33 +
     .../netherite_light_gray_torch_helmet_recipe.json  |   33 +
     .../netherite_lime_torch_helmet_recipe.json        |   33 +
     .../netherite_magenta_torch_helmet_recipe.json     |   33 +
     .../netherite_orange_torch_helmet_recipe.json      |   33 +
     .../netherite_pink_torch_helmet_recipe.json        |   33 +
     .../netherite_purple_torch_helmet_recipe.json      |   33 +
     .../netherite_red_torch_helmet_recipe.json         |   33 +
     .../netherite_redstone_torch_helmet_recipe.json    |   33 +
     .../netherite_sea_torch_helmet_recipe.json         |   33 +
     .../netherite_soul_torch_helmet_recipe.json        |   33 +
     .../netherite_white_torch_helmet_recipe.json       |   33 +
     .../netherite_yellow_torch_helmet_recipe.json      |   33 +
     .../turtle_black_torch_helmet_recipe.json          |   33 +
     .../turtle_blue_torch_helmet_recipe.json           |   33 +
     .../turtle_brown_torch_helmet_recipe.json          |   33 +
     .../turtle_cyan_torch_helmet_recipe.json           |   33 +
     .../turtle_gray_torch_helmet_recipe.json           |   33 +
     .../turtle_green_torch_helmet_recipe.json          |   33 +
     .../turtle_light_blue_torch_helmet_recipe.json     |   33 +
     .../turtle_light_gray_torch_helmet_recipe.json     |   33 +
     .../turtle_lime_torch_helmet_recipe.json           |   33 +
     .../turtle_magenta_torch_helmet_recipe.json        |   33 +
     .../turtle_orange_torch_helmet_recipe.json         |   33 +
     .../turtle_pink_torch_helmet_recipe.json           |   33 +
     .../turtle_purple_torch_helmet_recipe.json         |   33 +
     .../turtle_red_torch_helmet_recipe.json            |   33 +
     .../turtle_redstone_torch_helmet_recipe.json       |   33 +
     .../turtle_sea_torch_helmet_recipe.json            |   33 +
     .../turtle_soul_torch_helmet_recipe.json           |   33 +
     .../turtle_white_torch_helmet_recipe.json          |   33 +
     .../turtle_yellow_torch_helmet_recipe.json         |   33 +
     .../recipes/helmets/diamond_helmet.json            |   31 +
     .../RaiyonsDyBe/recipes/helmets/golden_helmet.json |   31 +
     .../RaiyonsDyBe/recipes/helmets/iron_helmet.json   |   31 +
     .../recipes/helmets/leather_helmet.json            |   31 +
     .../recipes/helmets/netherite_helmet.json          |   31 +
     .../RaiyonsDyBe/recipes/helmets/turtle_helmet.json |   31 +
     .../RaiyonsDyBe/recipes/torches/black_torch.json   |   32 +
     .../RaiyonsDyBe/recipes/torches/blue_torch.json    |   32 +
     .../RaiyonsDyBe/recipes/torches/brown_torch.json   |   32 +
     .../RaiyonsDyBe/recipes/torches/cyan_torch.json    |   32 +
     .../RaiyonsDyBe/recipes/torches/gray_torch.json    |   32 +
     .../RaiyonsDyBe/recipes/torches/green_torch.json   |   32 +
     .../recipes/torches/light_blue_torch.json          |   32 +
     .../recipes/torches/light_gray_torch.json          |   32 +
     .../RaiyonsDyBe/recipes/torches/lime_torch.json    |   32 +
     .../RaiyonsDyBe/recipes/torches/magenta_torch.json |   32 +
     .../RaiyonsDyBe/recipes/torches/orange_torch.json  |   32 +
     .../RaiyonsDyBe/recipes/torches/pink_torch.json    |   32 +
     .../RaiyonsDyBe/recipes/torches/purple_torch.json  |   32 +
     .../RaiyonsDyBe/recipes/torches/red_torch.json     |   32 +
     .../RaiyonsDyBe/recipes/torches/sea_torch.json     |   30 +
     .../RaiyonsDyBe/recipes/torches/white_torch.json   |   32 +
     .../RaiyonsDyBe/recipes/torches/yellow_torch.json  |   32 +
     .../scripts/dynamic_light/dyed_torches.js          |  264 ++++
     .../RaiyonsDyBe/scripts/dynamic_light/export.js    |    4 +
     .../RaiyonsDyBe/scripts/dynamic_light/levels.js    |   49 +
     .../RaiyonsDyBe/scripts/dynamic_light/main.js      |   18 +
     .../RaiyonsDyBe/scripts/dynamic_light/offhand.js   |   42 +
     .../scripts/dynamic_light/properties.js            |  308 +++++
     .../scripts/dynamic_light/underwater.js            |   14 +
     .../RaiyonsDyBe/scripts/dynamic_light/utilities.js |   16 +
     .../waystone_black_concrete_powder.json            |    1 +
     .../waystone_blue_concrete_powder.json             |    1 +
     .../waystone_brown_concrete_powder.json            |    1 +
     .../waystone_cyan_concrete_powder.json             |    1 +
     .../waystone_gray_concrete_powder.json             |    1 +
     .../waystone_green_concrete_powder.json            |    1 +
     .../waystone_light_blue_concrete_powder.json       |    1 +
     .../waystone_light_gray_concrete_powder.json       |    1 +
     .../waystone_lime_concrete_powder.json             |    1 +
     .../waystone_magenta_concrete_powder.json          |    1 +
     .../waystone_orange_concrete_powder.json           |    1 +
     .../waystone_pink_concrete_powder.json             |    1 +
     .../waystone_purple_concrete_powder.json           |    1 +
     .../waystone_red_concrete_powder.json              |    1 +
     .../waystone_white_concrete_powder.json            |    1 +
     .../waystone_yellow_concrete_powder.json           |    1 +
     .../concrete/waystone_black_concrete.json          |    1 +
     .../concrete/waystone_blue_concrete.json           |    1 +
     .../concrete/waystone_brown_concrete.json          |    1 +
     .../concrete/waystone_cyan_concrete.json           |    1 +
     .../concrete/waystone_gray_concrete.json           |    1 +
     .../concrete/waystone_green_concrete.json          |    1 +
     .../concrete/waystone_light_blue_concrete.json     |    1 +
     .../concrete/waystone_light_gray_concrete.json     |    1 +
     .../concrete/waystone_lime_concrete.json           |    1 +
     .../concrete/waystone_magenta_concrete.json        |    1 +
     .../concrete/waystone_orange_concrete.json         |    1 +
     .../concrete/waystone_pink_concrete.json           |    1 +
     .../concrete/waystone_purple_concrete.json         |    1 +
     .../concrete/waystone_red_concrete.json            |    1 +
     .../concrete/waystone_white_concrete.json          |    1 +
     .../concrete/waystone_yellow_concrete.json         |    1 +
     .../deepslate/waystone_chiseled_deepslate.json     |    1 +
     .../deepslate/waystone_cobbled_deepslate.json      |    1 +
     .../deepslate/waystone_deepslate.json              |    1 +
     .../deepslate/waystone_deepslate_bricks.json       |    1 +
     .../deepslate/waystone_deepslate_tiles.json        |    1 +
     .../deepslate/waystone_polished_deepslate.json     |    1 +
     .../simples_waystone/end/waystone_end_stone.json   |    1 +
     .../end/waystone_end_stone_bricks.json             |    1 +
     .../end/waystone_purpur_block.json                 |    1 +
     .../end/waystone_purpur_pillar_side.json           |    1 +
     .../glass/waystone_black_glass.json                |    1 +
     .../glass/waystone_blue_glass.json                 |    1 +
     .../glass/waystone_brown_glass.json                |    1 +
     .../glass/waystone_cyan_glass.json                 |    1 +
     .../simples_waystone/glass/waystone_glass.json     |    1 +
     .../glass/waystone_gray_glass.json                 |    1 +
     .../glass/waystone_green_glass.json                |    1 +
     .../glass/waystone_light_blue_glass.json           |    1 +
     .../glass/waystone_light_gray_glass.json           |    1 +
     .../glass/waystone_lime_glass.json                 |    1 +
     .../glass/waystone_magenta_glass.json              |    1 +
     .../glass/waystone_orange_glass.json               |    1 +
     .../glass/waystone_pink_glass.json                 |    1 +
     .../glass/waystone_purple_glass.json               |    1 +
     .../simples_waystone/glass/waystone_red_glass.json |    1 +
     .../glass/waystone_white_glass.json                |    1 +
     .../glass/waystone_yellow_glass.json               |    1 +
     .../log/stripped/waystone_stripped_acacia_log.json |    1 +
     .../stripped/waystone_stripped_bamboo_block.json   |    1 +
     .../log/stripped/waystone_stripped_birch_log.json  |    1 +
     .../log/stripped/waystone_stripped_cherry_log.json |    1 +
     .../stripped/waystone_stripped_crimson_stem.json   |    1 +
     .../stripped/waystone_stripped_dark_oak_log.json   |    1 +
     .../log/stripped/waystone_stripped_jungle_log.json |    1 +
     .../stripped/waystone_stripped_mangrove_log.json   |    1 +
     .../log/stripped/waystone_stripped_oak_log.json    |    1 +
     .../stripped/waystone_stripped_pale_oak_log.json   |    1 +
     .../log/stripped/waystone_stripped_spruce_log.json |    1 +
     .../log/stripped/waystone_warped_stem.json         |    1 +
     .../simples_waystone/log/waystone_acacia_log.json  |    1 +
     .../log/waystone_bamboo_block.json                 |    1 +
     .../log/waystone_bamboo_mosaic.json                |    1 +
     .../simples_waystone/log/waystone_birch_log.json   |    1 +
     .../simples_waystone/log/waystone_cherry_log.json  |    1 +
     .../log/waystone_creaking_heart_top.json           |    1 +
     .../log/waystone_crimson_stem.json                 |    1 +
     .../log/waystone_dark_oak_log.json                 |    1 +
     .../simples_waystone/log/waystone_jungle_log.json  |    1 +
     .../log/waystone_mangrove_log.json                 |    1 +
     .../simples_waystone/log/waystone_oak_log.json     |    1 +
     .../log/waystone_pale_oak_log.json                 |    1 +
     .../simples_waystone/log/waystone_spruce_log.json  |    1 +
     .../simples_waystone/log/waystone_warped_stem.json |    1 +
     .../simples_waystone/mud/waystone_mud_bricks.json  |    1 +
     .../simples_waystone/mud/waystone_packed_mud.json  |    1 +
     .../nether/basalt/waystone_basalt.json             |    1 +
     .../nether/basalt/waystone_polished_basalt.json    |    1 +
     .../nether/basalt/waystone_smooth_basalt.json      |    1 +
     .../nether/blackstone/waystone_blackstone.json     |    1 +
     .../waystone_chiseled_polished_blackstone.json     |    1 +
     .../blackstone/waystone_polished_blackstone.json   |    1 +
     .../waystone_polished_blackstone_bricks.json       |    1 +
     .../nether/waystone_chiseled_nether_bricks.json    |    1 +
     .../nether/waystone_glowstone.json                 |    1 +
     .../simples_waystone/nether/waystone_magma.json    |    1 +
     .../nether/waystone_nether_bricks.json             |    1 +
     .../nether/waystone_nether_wart_block.json         |    1 +
     .../nether/waystone_red_nether_bricks.json         |    1 +
     .../nether/waystone_soul_sand.json                 |    1 +
     .../nether/waystone_soul_soil.json                 |    1 +
     .../nether/waystone_warped_wart_block.json         |    1 +
     .../ocean/ice/waystone_blue_ice.json               |    1 +
     .../simples_waystone/ocean/ice/waystone_ice.json   |    1 +
     .../ocean/ice/waystone_packed_ice.json             |    1 +
     .../ocean/waystone_dark_prismarine.json            |    1 +
     .../ocean/waystone_prismarine.json                 |    1 +
     .../ocean/waystone_prismarine_bricks.json          |    1 +
     .../ocean/waystone_sea_lantern.json                |    1 +
     .../simples_waystone/ocean/waystone_snow.json      |    1 +
     .../ore/copper/waystone_chiseled_copper.json       |    1 +
     .../ore/copper/waystone_copper_block.json          |    1 +
     .../ore/copper/waystone_cut_copper.json            |    1 +
     .../copper/waystone_exposed_chiseled_copper.json   |    1 +
     .../ore/copper/waystone_exposed_copper.json        |    1 +
     .../ore/copper/waystone_exposed_cut_copper.json    |    1 +
     .../copper/waystone_oxidized_chiseled_copper.json  |    1 +
     .../ore/copper/waystone_oxidized_copper.json       |    1 +
     .../ore/copper/waystone_oxidized_cut_copper.json   |    1 +
     .../copper/waystone_weathered_chiseled_copper.json |    1 +
     .../ore/copper/waystone_weathered_copper.json      |    1 +
     .../ore/copper/waystone_weathered_cut_copper.json  |    1 +
     .../waystone_chiseled_quartz_block_side.json       |    1 +
     .../quartz/waystone_chiseled_quartz_block_top.json |    1 +
     .../ore/quartz/waystone_quartz_block_side.json     |    1 +
     .../ore/quartz/waystone_quartz_bricks.json         |    1 +
     .../ore/quartz/waystone_quartz_pillar.json         |    1 +
     .../ore/quartz/waystone_quartz_pillar_side.json    |    1 +
     .../ore/raw/waystone_raw_copper_block.json         |    1 +
     .../ore/raw/waystone_raw_gold_block.json           |    1 +
     .../ore/raw/waystone_raw_iron_block.json           |    1 +
     .../ore/waystone_amethyst_block.json               |    1 +
     .../simples_waystone/ore/waystone_coal_block.json  |    1 +
     .../ore/waystone_diamond_block.json                |    1 +
     .../ore/waystone_emerald_block.json                |    1 +
     .../simples_waystone/ore/waystone_gold_block.json  |    1 +
     .../simples_waystone/ore/waystone_iron_block.json  |    1 +
     .../simples_waystone/ore/waystone_lapis_block.json |    1 +
     .../ore/waystone_netherite_block.json              |    1 +
     .../ore/waystone_redstone_block.json               |    1 +
     .../resin/waystone_chiseled_resin_bricks.json      |    1 +
     .../resin/waystone_resin_block.json                |    1 +
     .../resin/waystone_resin_bricks.json               |    1 +
     .../sand/waystone_chiseled_red_sandstone.json      |    1 +
     .../sand/waystone_chiseled_sandstone.json          |    1 +
     .../sand/waystone_cut_red_sandstone.json           |    1 +
     .../sand/waystone_cut_sandstone.json               |    1 +
     .../simples_waystone/sand/waystone_red_sand.json   |    1 +
     .../simples_waystone/sand/waystone_sand.json       |    1 +
     .../sculk/waystone_sculk_catalyst_side.json        |    1 +
     .../sculk/waystone_sculk_catalyst_top.json         |    1 +
     .../sculk/waystone_sculk_shrieker.json             |    1 +
     .../stone/tuff/waystone_chiseled_tuff.json         |    1 +
     .../stone/tuff/waystone_chiseled_tuff_bricks.json  |    1 +
     .../stone/tuff/waystone_polished_tuff.json         |    1 +
     .../simples_waystone/stone/tuff/waystone_tuff.json |    1 +
     .../stone/tuff/waystone_tuff_bricks.json           |    1 +
     .../simples_waystone/stone/waystone_andesite.json  |    1 +
     .../stone/waystone_chiseled_stone_bricks.json      |    1 +
     .../stone/waystone_cobblestone.json                |    1 +
     .../stone/waystone_crying_obsidian.json            |    1 +
     .../simples_waystone/stone/waystone_diorite.json   |    1 +
     .../stone/waystone_dripstone_block.json            |    1 +
     .../simples_waystone/stone/waystone_granite.json   |    1 +
     .../stone/waystone_mossy_cobblestone.json          |    1 +
     .../stone/waystone_mossy_stone_bricks.json         |    1 +
     .../simples_waystone/stone/waystone_obsidian.json  |    1 +
     .../stone/waystone_polished_andesite.json          |    1 +
     .../stone/waystone_polished_diorite.json           |    1 +
     .../stone/waystone_polished_granite.json           |    1 +
     .../stone/waystone_smooth_stone.json               |    1 +
     .../simples_waystone/stone/waystone_stone.json     |    1 +
     .../stone/waystone_stone_bricks.json               |    1 +
     .../simples_waystone/tables/waystone_anvil.json    |    1 +
     .../tables/waystone_barrel_bottom.json             |    1 +
     .../tables/waystone_barrel_side.json               |    1 +
     .../simples_waystone/tables/waystone_beacon.json   |    1 +
     .../tables/waystone_bee_nest_side.json             |    1 +
     .../tables/waystone_beehive_side.json              |    1 +
     .../tables/waystone_blast_furnace_front_off.json   |    1 +
     .../tables/waystone_blast_furnace_top.json         |    1 +
     .../tables/waystone_bookshelf.json                 |    1 +
     .../tables/waystone_cauldron_inner.json            |    1 +
     .../simples_waystone/tables/waystone_chest.json    |    1 +
     .../tables/waystone_chiseled_bookshelf.json        |    1 +
     .../tables/waystone_crafter_north.json             |    1 +
     .../tables/waystone_crafter_top.json               |    1 +
     .../tables/waystone_crafting_table.json            |    1 +
     .../tables/waystone_ender_chest.json               |    1 +
     .../simples_waystone/tables/waystone_furnace.json  |    1 +
     .../tables/waystone_glow_item_frame.json           |    1 +
     .../tables/waystone_item_frame.json                |    1 +
     .../tables/waystone_lodestone.json                 |    1 +
     .../tables/waystone_note_block.json                |    1 +
     .../tables/waystone_respawn_anchor.json            |    1 +
     .../simples_waystone/tables/waystone_smoker.json   |    1 +
     .../tables/waystone_target_block.json              |    1 +
     .../terracotta/waystone_black_terracota.json       |    1 +
     .../terracotta/waystone_blue_terracota.json        |    1 +
     .../terracotta/waystone_brown_terracota.json       |    1 +
     .../terracotta/waystone_cyan_terracota.json        |    1 +
     .../terracotta/waystone_gray_terracota.json        |    1 +
     .../terracotta/waystone_green_terracota.json       |    1 +
     .../terracotta/waystone_light_blue_terracota.json  |    1 +
     .../terracotta/waystone_light_gray_terracota.json  |    1 +
     .../terracotta/waystone_lime_terracota.json        |    1 +
     .../terracotta/waystone_magenta_terracota.json     |    1 +
     .../terracotta/waystone_orange_terracota.json      |    1 +
     .../terracotta/waystone_pink_terracota.json        |    1 +
     .../terracotta/waystone_purple_terracota.json      |    1 +
     .../terracotta/waystone_red_terracota.json         |    1 +
     .../terracotta/waystone_terracota.json             |    1 +
     .../terracotta/waystone_white_terracota.json       |    1 +
     .../terracotta/waystone_yellow_terracota.json      |    1 +
     .../simples_waystone/waystone_bamboo_planks.json   |    1 +
     .../simples_waystone/waystone_bone_block_top.json  |    1 +
     .../waystone_redstone_lamp_on.json                 |    1 +
     .../stripped/waystone_stripped_acacia_wood.json    |    1 +
     .../stripped/waystone_stripped_birch_wood.json     |    1 +
     .../stripped/waystone_stripped_cherry_wood.json    |    1 +
     .../stripped/waystone_stripped_crimson_hyphae.json |    1 +
     .../stripped/waystone_stripped_dark_oak_wood.json  |    1 +
     .../stripped/waystone_stripped_jungle_wood.json    |    1 +
     .../stripped/waystone_stripped_mangrove_wood.json  |    1 +
     .../wood/stripped/waystone_stripped_oak_wood.json  |    1 +
     .../stripped/waystone_stripped_pale_oak_wood.json  |    1 +
     .../stripped/waystone_stripped_spruce_wood.json    |    1 +
     .../wood/stripped/waystone_warped_hyphae.json      |    1 +
     .../wood/waystone_acacia_wood.json                 |    1 +
     .../simples_waystone/wood/waystone_birch_wood.json |    1 +
     .../wood/waystone_cherry_wood.json                 |    1 +
     .../wood/waystone_crimson_hyphae.json              |    1 +
     .../wood/waystone_dark_oak_wood.json               |    1 +
     .../wood/waystone_jungle_wood.json                 |    1 +
     .../wood/waystone_mangrove_wood.json               |    1 +
     .../simples_waystone/wood/waystone_oak_wood.json   |    1 +
     .../wood/waystone_pale_oak_wood.json               |    1 +
     .../wood/waystone_spruce_wood.json                 |    1 +
     .../wood/waystone_warped_hyphae.json               |    1 +
     .../simples_waystone/wool/waystone_black_wool.json |    1 +
     .../simples_waystone/wool/waystone_blue_wool.json  |    1 +
     .../simples_waystone/wool/waystone_brown_wool.json |    1 +
     .../simples_waystone/wool/waystone_cyan_wool.json  |    1 +
     .../simples_waystone/wool/waystone_gray_wool.json  |    1 +
     .../simples_waystone/wool/waystone_green_wool.json |    1 +
     .../wool/waystone_light_blue_wool.json             |    1 +
     .../wool/waystone_light_gray_wool.json             |    1 +
     .../simples_waystone/wool/waystone_lime_wool.json  |    1 +
     .../wool/waystone_magenta_wool.json                |    1 +
     .../wool/waystone_orange_wool.json                 |    1 +
     .../simples_waystone/wool/waystone_pink_wool.json  |    1 +
     .../wool/waystone_purple_wool.json                 |    1 +
     .../simples_waystone/wool/waystone_red_wool.json   |    1 +
     .../simples_waystone/wool/waystone_white_wool.json |    1 +
     .../wool/waystone_yellow_wool.json                 |    1 +
     .../simple_waystone_default_structure_rule.json    |   55 +
     .../simple_waystone_desert_structure_rule.json     |   36 +
     .../simple_waystone_taiga_structure_rule.json      |   43 +
     .../simple_waystone_default_structure_feature.json |   15 +
     .../simple_waystone_desert_structure_feature.json  |   15 +
     .../simple_waystone_taiga_structure_feature.json   |   15 +
     .../simples_waystone/resetDefault.mcfunction       |    1 +
     .../simples_waystone/setCostNoXp.mcfunction        |    3 +
     .../simples_waystone/setCostXp.mcfunction          |    3 +
     .../item_catalog/crafting_item_catalog.json        |    1 +
     .../items/simples_waystone/golden_feather.json     |    1 +
     .../items/simples_waystone/return_scroll.json      |    1 +
     .../items/simples_waystone/warpstone.json          |    1 +
     .../behavior/SimpleWaystoneBP/manifest.json        |   53 +
     .../behavior/SimpleWaystoneBP/pack_icon.png        |  Bin 0 -> 13019 bytes
     .../recipes/simples_waystone/golden_feather.json   |    1 +
     .../recipes/simples_waystone/return_scroll.json    |    1 +
     .../recipes/simples_waystone/warpstone.json        |    1 +
     .../simples_waystone/waystones/bamboo_planks.json  |    1 +
     .../simples_waystone/waystones/bone_block_top.json |    1 +
     .../waystones/concrete/black_concrete.json         |    1 +
     .../waystones/concrete/blue_concrete.json          |    1 +
     .../waystones/concrete/brown_concrete.json         |    1 +
     .../concrete_powder/black_concrete_powder.json     |    1 +
     .../concrete_powder/blue_concrete_powder.json      |    1 +
     .../concrete_powder/brown_concrete_powder.json     |    1 +
     .../concrete_powder/cyan_concrete_powder.json      |    1 +
     .../concrete_powder/gray_concrete_powder.json      |    1 +
     .../concrete_powder/green_concrete_powder.json     |    1 +
     .../light_blue_concrete_powder.json                |    1 +
     .../light_gray_concrete_powder.json                |    1 +
     .../concrete_powder/lime_concrete_powder.json      |    1 +
     .../concrete_powder/magenta_concrete_powder.json   |    1 +
     .../concrete_powder/orange_concrete_powder.json    |    1 +
     .../concrete_powder/pink_concrete_powder.json      |    1 +
     .../concrete_powder/purple_concrete_powder.json    |    1 +
     .../concrete_powder/red_concrete_powder.json       |    1 +
     .../concrete_powder/white_concrete_powder.json     |    1 +
     .../concrete_powder/yellow_concrete_powder.json    |    1 +
     .../waystones/concrete/cyan_concrete.json          |    1 +
     .../waystones/concrete/gray_concrete.json          |    1 +
     .../waystones/concrete/green_concrete.json         |    1 +
     .../waystones/concrete/light_blue_concrete.json    |    1 +
     .../waystones/concrete/light_gray_concrete.json    |    1 +
     .../waystones/concrete/lime_concrete.json          |    1 +
     .../waystones/concrete/magenta_concrete.json       |    1 +
     .../waystones/concrete/orange_concrete.json        |    1 +
     .../waystones/concrete/pink_concrete.json          |    1 +
     .../waystones/concrete/purple_concrete.json        |    1 +
     .../waystones/concrete/red_concrete.json           |    1 +
     .../waystones/concrete/white_concrete.json         |    1 +
     .../waystones/concrete/yellow_concrete.json        |    1 +
     .../waystones/deepslate/chiseled_deepslate.json    |    1 +
     .../waystones/deepslate/cobbled_deepslate.json     |    1 +
     .../waystones/deepslate/deepslate.json             |    1 +
     .../waystones/deepslate/deepslate_bricks.json      |    1 +
     .../waystones/deepslate/deepslate_tiles.json       |    1 +
     .../waystones/deepslate/polished_deepslate.json    |    1 +
     .../simples_waystone/waystones/end/end_stone.json  |    1 +
     .../waystones/end/end_stone_bricks.json            |    1 +
     .../waystones/end/purpur_block.json                |    1 +
     .../waystones/end/purpur_pillar.json               |    1 +
     .../waystones/glass/black_glass.json               |    1 +
     .../waystones/glass/blue_glass.json                |    1 +
     .../waystones/glass/brown_glass.json               |    1 +
     .../waystones/glass/cyan_glass.json                |    1 +
     .../simples_waystone/waystones/glass/glass.json    |    1 +
     .../waystones/glass/gray_glass.json                |    1 +
     .../waystones/glass/green_glass.json               |    1 +
     .../waystones/glass/light_blue_glass.json          |    1 +
     .../waystones/glass/light_gray_glass.json          |    1 +
     .../waystones/glass/lime_glass.json                |    1 +
     .../waystones/glass/magenta_glass.json             |    1 +
     .../waystones/glass/orange_glass.json              |    1 +
     .../waystones/glass/pink_glass.json                |    1 +
     .../waystones/glass/purple_glass.json              |    1 +
     .../waystones/glass/red_glass.json                 |    1 +
     .../waystones/glass/white_glass.json               |    1 +
     .../waystones/glass/yellow_glass.json              |    1 +
     .../simples_waystone/waystones/log/acacia_log.json |    1 +
     .../waystones/log/bamboo_block.json                |    1 +
     .../waystones/log/bamboo_mosaic.json               |    1 +
     .../simples_waystone/waystones/log/birch_log.json  |    1 +
     .../simples_waystone/waystones/log/cherry_log.json |    1 +
     .../waystones/log/creaking_heart.json              |    1 +
     .../waystones/log/crimson_stem.json                |    1 +
     .../waystones/log/dark_oak_log.json                |    1 +
     .../simples_waystone/waystones/log/jungle_log.json |    1 +
     .../waystones/log/mangrove_log.json                |    1 +
     .../simples_waystone/waystones/log/oak_log.json    |    1 +
     .../waystones/log/pale_oak_log.json                |    1 +
     .../simples_waystone/waystones/log/spruce_log.json |    1 +
     .../log/stripped/stripped_acacia_log.json          |    1 +
     .../log/stripped/stripped_bamboo_block.json        |    1 +
     .../waystones/log/stripped/stripped_birch_log.json |    1 +
     .../log/stripped/stripped_cherry_log.json          |    1 +
     .../log/stripped/stripped_crimson_stem.json        |    1 +
     .../log/stripped/stripped_dark_oak_log.json        |    1 +
     .../log/stripped/stripped_jungle_log.json          |    1 +
     .../log/stripped/stripped_mangrove_log.json        |    1 +
     .../waystones/log/stripped/stripped_oak_log.json   |    1 +
     .../log/stripped/stripped_pale_oak_log.json        |    1 +
     .../log/stripped/stripped_spruce_log.json          |    1 +
     .../log/stripped/stripped_warped_stem.json         |    1 +
     .../waystones/log/stripped_warped_stem.json        |    1 +
     .../simples_waystone/waystones/mud/mud_bricks.json |    1 +
     .../simples_waystone/waystones/mud/packed_mud.json |    1 +
     .../waystones/nether/basalt/basalt.json            |    1 +
     .../waystones/nether/basalt/polished_basalt.json   |    1 +
     .../waystones/nether/basalt/smooth_basalt.json     |    1 +
     .../waystones/nether/blackstone/blackstone.json    |    1 +
     .../blackstone/chiseled_polished_blackstone.json   |    1 +
     .../nether/blackstone/polished_blackstone.json     |    1 +
     .../blackstone/polished_blackstone_bricks.json     |    1 +
     .../waystones/nether/chiseled_nether_bricks.json   |    1 +
     .../waystones/nether/glowstone.json                |    1 +
     .../simples_waystone/waystones/nether/magma.json   |    1 +
     .../waystones/nether/nether_bricks.json            |    1 +
     .../waystones/nether/nether_wart_block.json        |    1 +
     .../waystones/nether/red_nether_bricks.json        |    1 +
     .../waystones/nether/soul_sand.json                |    1 +
     .../waystones/nether/soul_soil.json                |    1 +
     .../waystones/nether/warped_wart_block.json        |    1 +
     .../waystones/ocean/dark_prismarine.json           |    1 +
     .../waystones/ocean/ice/blue_ice.json              |    1 +
     .../simples_waystone/waystones/ocean/ice/ice.json  |    1 +
     .../waystones/ocean/ice/packed_ice.json            |    1 +
     .../waystones/ocean/prismarine.json                |    1 +
     .../waystones/ocean/prismarine_bricks.json         |    1 +
     .../waystones/ocean/sea_lantern.json               |    1 +
     .../simples_waystone/waystones/ocean/snow.json     |    1 +
     .../waystones/ore/amethyst_block.json              |    1 +
     .../simples_waystone/waystones/ore/coal_block.json |    1 +
     .../waystones/ore/copper/chiseled_copper.json      |    1 +
     .../waystones/ore/copper/copper_block.json         |    1 +
     .../waystones/ore/copper/cut_copper.json           |    1 +
     .../ore/copper/exposed_chiseled_copper.json        |    1 +
     .../waystones/ore/copper/exposed_copper_block.json |    1 +
     .../waystones/ore/copper/exposed_cut_copper.json   |    1 +
     .../ore/copper/oxidized_chiseled_copper.json       |    1 +
     .../ore/copper/oxidized_copper_block.json          |    1 +
     .../waystones/ore/copper/oxidized_cut_copper.json  |    1 +
     .../ore/copper/weathered_chiseled_copper.json      |    1 +
     .../ore/copper/weathered_copper_block.json         |    1 +
     .../waystones/ore/copper/weathered_cut_copper.json |    1 +
     .../waystones/ore/diamond_block.json               |    1 +
     .../waystones/ore/emerald_block.json               |    1 +
     .../simples_waystone/waystones/ore/gold_block.json |    1 +
     .../simples_waystone/waystones/ore/iron_block.json |    1 +
     .../waystones/ore/lapis_block.json                 |    1 +
     .../waystones/ore/netherite_block.json             |    1 +
     .../ore/quartz/chiseled_quartz_block_side.json     |    1 +
     .../ore/quartz/chiseled_quartz_block_side1.json    |    1 +
     .../ore/quartz/chiseled_quartz_block_top.json      |    1 +
     .../waystones/ore/quartz/quartz_block_side.json    |    1 +
     .../waystones/ore/quartz/quartz_bricks.json        |    1 +
     .../waystones/ore/quartz/quartz_pillar_side.json   |    1 +
     .../waystones/ore/quartz/quartz_pillar_top.json    |    1 +
     .../waystones/ore/quartz/quartz_pillar_top1.json   |    1 +
     .../waystones/ore/raw/raw_copper_block.json        |    1 +
     .../waystones/ore/raw/raw_gold_block.json          |    1 +
     .../waystones/ore/raw/raw_iron_block.json          |    1 +
     .../waystones/ore/redstone_block.json              |    1 +
     .../waystones/redstone_lamp_on.json                |    1 +
     .../waystones/resin/chiseled_resin_bricks.json     |    1 +
     .../waystones/resin/resin_block.json               |    1 +
     .../waystones/resin/resin_bricks.json              |    1 +
     .../waystones/sand/chiseled_red_sandstone.json     |    1 +
     .../waystones/sand/chiseled_sandstone.json         |    1 +
     .../waystones/sand/cut_red_sandstone.json          |    1 +
     .../waystones/sand/cut_sandstone.json              |    1 +
     .../simples_waystone/waystones/sand/red_sand.json  |    1 +
     .../simples_waystone/waystones/sand/sand.json      |    1 +
     .../waystones/sculk/sculk_catalyst_side.json       |    1 +
     .../waystones/sculk/sculk_catalyst_top.json        |    1 +
     .../waystones/sculk/sculk_catalyst_top1.json       |    1 +
     .../waystones/sculk/sculk_shrieker.json            |    1 +
     .../simples_waystone/waystones/stone/andesite.json |    1 +
     .../waystones/stone/chiseled_stone_bricks.json     |    1 +
     .../waystones/stone/cobblestone.json               |    1 +
     .../waystones/stone/crying_obsidian.json           |    1 +
     .../simples_waystone/waystones/stone/diorite.json  |    1 +
     .../waystones/stone/dripstone_block.json           |    1 +
     .../simples_waystone/waystones/stone/granite.json  |    1 +
     .../waystones/stone/mossy_cobblestone.json         |    1 +
     .../waystones/stone/mossy_stone_bricks.json        |    1 +
     .../simples_waystone/waystones/stone/obsidian.json |    1 +
     .../waystones/stone/polished_andesite.json         |    1 +
     .../waystones/stone/polished_diorite.json          |    1 +
     .../waystones/stone/polished_granite.json          |    1 +
     .../waystones/stone/smooth_stone.json              |    1 +
     .../simples_waystone/waystones/stone/stone.json    |    1 +
     .../waystones/stone/stone_bricks.json              |    1 +
     .../waystones/stone/tuff/chiseled_tuff.json        |    1 +
     .../waystones/stone/tuff/chiseled_tuff_bricks.json |    1 +
     .../waystones/stone/tuff/polished_tuff.json        |    1 +
     .../waystones/stone/tuff/tuff.json                 |    1 +
     .../waystones/stone/tuff/tuff_bricks.json          |    1 +
     .../simples_waystone/waystones/tables/anvil.json   |    1 +
     .../waystones/tables/barrel_bottom.json            |    1 +
     .../waystones/tables/barrel_side.json              |    1 +
     .../waystones/tables/barrel_side1.json             |    1 +
     .../simples_waystone/waystones/tables/beacon.json  |    1 +
     .../waystones/tables/bee_nest_side.json            |    1 +
     .../waystones/tables/beehive_side.json             |    1 +
     .../waystones/tables/blast_furnace_front_off.json  |    1 +
     .../waystones/tables/blast_furnace_front_off1.json |    1 +
     .../waystones/tables/blast_furnace_top.json        |    1 +
     .../waystones/tables/bookshelf.json                |    1 +
     .../waystones/tables/cauldron_inner.json           |    1 +
     .../simples_waystone/waystones/tables/chest.json   |    1 +
     .../waystones/tables/chiseled_bookshelf.json       |    1 +
     .../waystones/tables/crafter_north.json            |    1 +
     .../waystones/tables/crafter_north1.json           |    1 +
     .../waystones/tables/crafter_top.json              |    1 +
     .../waystones/tables/crafting_table.json           |    1 +
     .../waystones/tables/ender_chest.json              |    1 +
     .../simples_waystone/waystones/tables/furnace.json |    1 +
     .../waystones/tables/glow_item_frame.json          |    1 +
     .../waystones/tables/item_frame.json               |    1 +
     .../waystones/tables/lodestone.json                |    1 +
     .../waystones/tables/note_block.json               |    1 +
     .../waystones/tables/respawn_anchor.json           |    1 +
     .../simples_waystone/waystones/tables/smoker.json  |    1 +
     .../waystones/tables/target_block.json             |    1 +
     .../waystones/terracotta/black_terracotta.json     |    1 +
     .../waystones/terracotta/blue_terracotta.json      |    1 +
     .../waystones/terracotta/brown_terracotta.json     |    1 +
     .../waystones/terracotta/cyan_terracotta.json      |    1 +
     .../waystones/terracotta/gray_terracotta.json      |    1 +
     .../waystones/terracotta/green_terracotta.json     |    1 +
     .../terracotta/light_blue_terracotta.json          |    1 +
     .../terracotta/light_gray_terracotta.json          |    1 +
     .../waystones/terracotta/lime_terracotta.json      |    1 +
     .../waystones/terracotta/magenta_terracotta.json   |    1 +
     .../waystones/terracotta/orange_terracotta.json    |    1 +
     .../waystones/terracotta/pink_terracotta.json      |    1 +
     .../waystones/terracotta/purple_terracotta.json    |    1 +
     .../waystones/terracotta/red_terracotta.json       |    1 +
     .../waystones/terracotta/terracotta.json           |    1 +
     .../waystones/terracotta/white_terracotta.json     |    1 +
     .../waystones/terracotta/yellow_terracotta.json    |    1 +
     .../waystones/wood/acacia_wood.json                |    1 +
     .../waystones/wood/birch_wood.json                 |    1 +
     .../waystones/wood/cherry_wood.json                |    1 +
     .../waystones/wood/crimson_wood.json               |    1 +
     .../waystones/wood/dark_oak_wood.json              |    1 +
     .../waystones/wood/jungle_wood.json                |    1 +
     .../waystones/wood/mangrove_wood.json              |    1 +
     .../simples_waystone/waystones/wood/oak_wood.json  |    1 +
     .../waystones/wood/pale_oak_wood.json              |    1 +
     .../waystones/wood/spruce_wood.json                |    1 +
     .../wood/stripped/stripped_acacia_wood.json        |    1 +
     .../wood/stripped/stripped_birch_wood.json         |    1 +
     .../wood/stripped/stripped_cherry_wood.json        |    1 +
     .../wood/stripped/stripped_crimson_hyphae.json     |    1 +
     .../wood/stripped/stripped_dark_oak_wood.json      |    1 +
     .../wood/stripped/stripped_jungle_wood.json        |    1 +
     .../wood/stripped/stripped_mangrove_wood.json      |    1 +
     .../waystones/wood/stripped/stripped_oak_wood.json |    1 +
     .../wood/stripped/stripped_pale_oak_wood.json      |    1 +
     .../wood/stripped/stripped_spruce_wood.json        |    1 +
     .../wood/stripped/stripped_warped_wood.json        |    1 +
     .../waystones/wood/warped_wood.json                |    1 +
     .../waystones/wool/black_wool.json                 |    1 +
     .../simples_waystone/waystones/wool/blue_wool.json |    1 +
     .../waystones/wool/brown_wool.json                 |    1 +
     .../simples_waystone/waystones/wool/cyan_wool.json |    1 +
     .../simples_waystone/waystones/wool/gray_wool.json |    1 +
     .../waystones/wool/green_wool.json                 |    1 +
     .../waystones/wool/light_blue_wool.json            |    1 +
     .../waystones/wool/light_gray_wool.json            |    1 +
     .../simples_waystone/waystones/wool/lime_wool.json |    1 +
     .../waystones/wool/magenta_wool.json               |    1 +
     .../waystones/wool/orange_wool.json                |    1 +
     .../simples_waystone/waystones/wool/pink_wool.json |    1 +
     .../waystones/wool/purple_wool.json                |    1 +
     .../simples_waystone/waystones/wool/red_wool.json  |    1 +
     .../waystones/wool/white_wool.json                 |    1 +
     .../waystones/wool/yellow_wool.json                |    1 +
     .../customComponent/customComponent.js             |  102 ++
     .../scripts/simple_waystone/dev.js                 |   41 +
     .../simple_waystone/functions/convertOld.js        |   54 +
     .../scripts/simple_waystone/functions/destroy.js   |   75 ++
     .../simple_waystone/functions/placeWaystones.js    |  340 +++++
     .../scripts/simple_waystone/lib/apiConfig.js       |   36 +
     .../scripts/simple_waystone/lib/apiItem.js         |   41 +
     .../scripts/simple_waystone/lib/apiOrganize.js     |   45 +
     .../simple_waystone/lib/apiwaystone/create.js      |   13 +
     .../simple_waystone/lib/apiwaystone/info.js        |  133 ++
     .../simple_waystone/lib/apiwaystone/save.js        |   22 +
     .../simple_waystone/lib/apiwaystone/space.js       |   77 ++
     .../scripts/simple_waystone/lib/vector.js          |   58 +
     .../scripts/simple_waystone/lib/warn.js            |   27 +
     .../scripts/simple_waystone/main.js                |    5 +
     .../scripts/simple_waystone/ui/mainUi.js           |  160 +++
     .../scripts/simple_waystone/variables.js           |    9 +
     .../src/customComponent/customComponent.ts         |  101 ++
     .../behavior/SimpleWaystoneBP/src/dev.ts           |   43 +
     .../SimpleWaystoneBP/src/functions/convertOld.ts   |   71 ++
     .../SimpleWaystoneBP/src/functions/destroy.ts      |   76 ++
     .../src/functions/placeWaystones.ts                |  367 ++++++
     .../behavior/SimpleWaystoneBP/src/lib/apiConfig.ts |   48 +
     .../behavior/SimpleWaystoneBP/src/lib/apiItem.ts   |   43 +
     .../SimpleWaystoneBP/src/lib/apiOrganize.ts        |   49 +
     .../SimpleWaystoneBP/src/lib/apiwaystone/create.ts |   22 +
     .../SimpleWaystoneBP/src/lib/apiwaystone/info.ts   |  151 +++
     .../SimpleWaystoneBP/src/lib/apiwaystone/save.ts   |   22 +
     .../SimpleWaystoneBP/src/lib/apiwaystone/space.ts  |   79 ++
     .../behavior/SimpleWaystoneBP/src/lib/vector.ts    |   64 +
     .../behavior/SimpleWaystoneBP/src/lib/warn.ts      |   39 +
     .../behavior/SimpleWaystoneBP/src/main.ts          |    5 +
     .../behavior/SimpleWaystoneBP/src/ui/mainUi.ts     |  162 +++
     .../behavior/SimpleWaystoneBP/src/variables.ts     |   11 +
     .../simple_waystone_default_structure.mcstructure  |  Bin 0 -> 4179 bytes
     .../simple_waystone_desert_structure.mcstructure   |  Bin 0 -> 4020 bytes
     .../simple_waystone_taiga_structure.mcstructure    |  Bin 0 -> 4526 bytes
     .../free/scripts/simple_waystone/variables.js      |   11 +
     .../behavior/SimpleWaystoneBP/texts/en_US.lang     |    2 +
     .../behavior/SimpleWaystoneBP/texts/languages.json |    4 +
     .../behavior/SimpleWaystoneBP/texts/pt_BR.lang     |    2 +
     .../resource/FFLResourcePack/manifest.json         |   18 +
     .../resource/FFLResourcePack/pack_icon.png         |  Bin 0 -> 1701481 bytes
     .../FFLResourcePack/particles/acacia_leaf.json     |   64 +
     .../particles/azalea_flowered_leaf.json            |   64 +
     .../FFLResourcePack/particles/azalea_leaf.json     |   64 +
     .../FFLResourcePack/particles/birch_leaf.json      |   64 +
     .../FFLResourcePack/particles/dark_oak_leaf.json   |   67 +
     .../FFLResourcePack/particles/jungle_leaf.json     |   64 +
     .../FFLResourcePack/particles/mangrove_leaf.json   |   64 +
     .../FFLResourcePack/particles/oak_leaf.json        |   68 +
     .../FFLResourcePack/particles/spruce_leaf.json     |   64 +
     .../textures/particle/acacia_leaf.png              |  Bin 0 -> 405 bytes
     .../textures/particle/azalea_flowered_leaf.png     |  Bin 0 -> 374 bytes
     .../textures/particle/azalea_leaf.png              |  Bin 0 -> 515 bytes
     .../textures/particle/birch_leaf.png               |  Bin 0 -> 475 bytes
     .../textures/particle/dark_oak_leaf.png            |  Bin 0 -> 888 bytes
     .../textures/particle/jungle_leaf.png              |  Bin 0 -> 433 bytes
     .../textures/particle/mangrove_leaf.png            |  Bin 0 -> 528 bytes
     .../FFLResourcePack/textures/particle/oak_leaf.png |  Bin 0 -> 890 bytes
     .../textures/particle/spruce_leaf.png              |  Bin 0 -> 499 bytes
     .../RaiyonsDyRE/attachables/chainmail_helmet.json  |   36 +
     .../RaiyonsDyRE/attachables/diamond_helmet.json    |   35 +
     .../chainmail_black_torch_helmet_attachable.json   |   38 +
     .../chainmail_blue_torch_helmet_attachable.json    |   38 +
     .../chainmail_brown_torch_helmet_attachable.json   |   38 +
     .../chainmail_cyan_torch_helmet_attachable.json    |   38 +
     .../chainmail_gray_torch_helmet_attachable.json    |   38 +
     .../chainmail_green_torch_helmet_attachable.json   |   38 +
     ...ainmail_light_blue_torch_helmet_attachable.json |   38 +
     ...ainmail_light_gray_torch_helmet_attachable.json |   38 +
     .../chainmail_lime_torch_helmet_attachable.json    |   38 +
     .../chainmail_magenta_torch_helmet_attachable.json |   38 +
     .../chainmail_orange_torch_helmet_attachable.json  |   38 +
     .../chainmail_pink_torch_helmet_attachable.json    |   38 +
     .../chainmail_purple_torch_helmet_attachable.json  |   38 +
     .../chainmail_red_torch_helmet_attachable.json     |   38 +
     ...chainmail_redstone_torch_helmet_attachable.json |   38 +
     .../chainmail_sea_torch_helmet_attachable.json     |   38 +
     .../chainmail_soul_torch_helmet_attachable.json    |   38 +
     .../chainmail_white_torch_helmet_attachable.json   |   38 +
     .../chainmail_yellow_torch_helmet_attachable.json  |   38 +
     .../diamond_black_torch_helmet_attachable.json     |   38 +
     .../diamond_blue_torch_helmet_attachable.json      |   38 +
     .../diamond_brown_torch_helmet_attachable.json     |   38 +
     .../diamond_cyan_torch_helmet_attachable.json      |   38 +
     .../diamond_gray_torch_helmet_attachable.json      |   38 +
     .../diamond_green_torch_helmet_attachable.json     |   38 +
     ...diamond_light_blue_torch_helmet_attachable.json |   38 +
     ...diamond_light_gray_torch_helmet_attachable.json |   38 +
     .../diamond_lime_torch_helmet_attachable.json      |   38 +
     .../diamond_magenta_torch_helmet_attachable.json   |   38 +
     .../diamond_orange_torch_helmet_attachable.json    |   38 +
     .../diamond_pink_torch_helmet_attachable.json      |   38 +
     .../diamond_purple_torch_helmet_attachable.json    |   38 +
     .../diamond_red_torch_helmet_attachable.json       |   38 +
     .../diamond_redstone_torch_helmet_attachable.json  |   38 +
     .../diamond_sea_torch_helmet_attachable.json       |   38 +
     .../diamond_soul_torch_helmet_attachable.json      |   38 +
     .../diamond_white_torch_helmet_attachable.json     |   38 +
     .../diamond_yellow_torch_helmet_attachable.json    |   38 +
     .../golden_black_torch_helmet_attachable.json      |   38 +
     .../golden_blue_torch_helmet_attachable.json       |   38 +
     .../golden_brown_torch_helmet_attachable.json      |   38 +
     .../golden_cyan_torch_helmet_attachable.json       |   38 +
     .../golden_gray_torch_helmet_attachable.json       |   38 +
     .../golden_green_torch_helmet_attachable.json      |   38 +
     .../golden_light_blue_torch_helmet_attachable.json |   38 +
     .../golden_light_gray_torch_helmet_attachable.json |   38 +
     .../golden_lime_torch_helmet_attachable.json       |   38 +
     .../golden_magenta_torch_helmet_attachable.json    |   38 +
     .../golden_orange_torch_helmet_attachable.json     |   38 +
     .../golden_pink_torch_helmet_attachable.json       |   38 +
     .../golden_purple_torch_helmet_attachable.json     |   38 +
     .../golden_red_torch_helmet_attachable.json        |   38 +
     .../golden_redstone_torch_helmet_attachable.json   |   38 +
     .../golden_sea_torch_helmet_attachable.json        |   38 +
     .../golden_soul_torch_helmet_attachable.json       |   38 +
     .../golden_white_torch_helmet_attachable.json      |   38 +
     .../golden_yellow_torch_helmet_attachable.json     |   38 +
     .../iron_black_torch_helmet_attachable.json        |   38 +
     .../iron_blue_torch_helmet_attachable.json         |   38 +
     .../iron_brown_torch_helmet_attachable.json        |   38 +
     .../iron_cyan_torch_helmet_attachable.json         |   38 +
     .../iron_gray_torch_helmet_attachable.json         |   38 +
     .../iron_green_torch_helmet_attachable.json        |   38 +
     .../iron_light_blue_torch_helmet_attachable.json   |   38 +
     .../iron_light_gray_torch_helmet_attachable.json   |   38 +
     .../iron_lime_torch_helmet_attachable.json         |   38 +
     .../iron_magenta_torch_helmet_attachable.json      |   38 +
     .../iron_orange_torch_helmet_attachable.json       |   38 +
     .../iron_pink_torch_helmet_attachable.json         |   38 +
     .../iron_purple_torch_helmet_attachable.json       |   38 +
     .../iron_red_torch_helmet_attachable.json          |   38 +
     .../iron_redstone_torch_helmet_attachable.json     |   38 +
     .../iron_sea_torch_helmet_attachable.json          |   38 +
     .../iron_soul_torch_helmet_attachable.json         |   38 +
     .../iron_white_torch_helmet_attachable.json        |   38 +
     .../iron_yellow_torch_helmet_attachable.json       |   38 +
     .../leather_black_torch_helmet_attachable.json     |   38 +
     .../leather_blue_torch_helmet_attachable.json      |   38 +
     .../leather_brown_torch_helmet_attachable.json     |   38 +
     .../leather_cyan_torch_helmet_attachable.json      |   38 +
     .../leather_gray_torch_helmet_attachable.json      |   38 +
     .../leather_green_torch_helmet_attachable.json     |   38 +
     ...leather_light_blue_torch_helmet_attachable.json |   38 +
     ...leather_light_gray_torch_helmet_attachable.json |   38 +
     .../leather_lime_torch_helmet_attachable.json      |   38 +
     .../leather_magenta_torch_helmet_attachable.json   |   38 +
     .../leather_orange_torch_helmet_attachable.json    |   38 +
     .../leather_pink_torch_helmet_attachable.json      |   38 +
     .../leather_purple_torch_helmet_attachable.json    |   38 +
     .../leather_red_torch_helmet_attachable.json       |   38 +
     .../leather_redstone_torch_helmet_attachable.json  |   38 +
     .../leather_sea_torch_helmet_attachable.json       |   38 +
     .../leather_soul_torch_helmet_attachable.json      |   38 +
     .../leather_white_torch_helmet_attachable.json     |   38 +
     .../leather_yellow_torch_helmet_attachable.json    |   38 +
     .../netherite_black_torch_helmet_attachable.json   |   38 +
     .../netherite_blue_torch_helmet_attachable.json    |   38 +
     .../netherite_brown_torch_helmet_attachable.json   |   38 +
     .../netherite_cyan_torch_helmet_attachable.json    |   38 +
     .../netherite_gray_torch_helmet_attachable.json    |   38 +
     .../netherite_green_torch_helmet_attachable.json   |   38 +
     ...therite_light_blue_torch_helmet_attachable.json |   38 +
     ...therite_light_gray_torch_helmet_attachable.json |   38 +
     .../netherite_lime_torch_helmet_attachable.json    |   38 +
     .../netherite_magenta_torch_helmet_attachable.json |   38 +
     .../netherite_orange_torch_helmet_attachable.json  |   38 +
     .../netherite_pink_torch_helmet_attachable.json    |   38 +
     .../netherite_purple_torch_helmet_attachable.json  |   38 +
     .../netherite_red_torch_helmet_attachable.json     |   38 +
     ...netherite_redstone_torch_helmet_attachable.json |   38 +
     .../netherite_sea_torch_helmet_attachable.json     |   38 +
     .../netherite_soul_torch_helmet_attachable.json    |   38 +
     .../netherite_white_torch_helmet_attachable.json   |   38 +
     .../netherite_yellow_torch_helmet_attachable.json  |   38 +
     .../turtle_black_torch_helmet_attachable.json      |   38 +
     .../turtle_blue_torch_helmet_attachable.json       |   38 +
     .../turtle_brown_torch_helmet_attachable.json      |   38 +
     .../turtle_cyan_torch_helmet_attachable.json       |   38 +
     .../turtle_gray_torch_helmet_attachable.json       |   38 +
     .../turtle_green_torch_helmet_attachable.json      |   38 +
     .../turtle_light_blue_torch_helmet_attachable.json |   38 +
     .../turtle_light_gray_torch_helmet_attachable.json |   38 +
     .../turtle_lime_torch_helmet_attachable.json       |   38 +
     .../turtle_magenta_torch_helmet_attachable.json    |   38 +
     .../turtle_orange_torch_helmet_attachable.json     |   38 +
     .../turtle_pink_torch_helmet_attachable.json       |   38 +
     .../turtle_purple_torch_helmet_attachable.json     |   38 +
     .../turtle_red_torch_helmet_attachable.json        |   38 +
     .../turtle_redstone_torch_helmet_attachable.json   |   38 +
     .../turtle_sea_torch_helmet_attachable.json        |   38 +
     .../turtle_soul_torch_helmet_attachable.json       |   38 +
     .../turtle_white_torch_helmet_attachable.json      |   38 +
     .../turtle_yellow_torch_helmet_attachable.json     |   38 +
     .../RaiyonsDyRE/attachables/golden_helmet.json     |   34 +
     .../RaiyonsDyRE/attachables/iron_helmet.json       |   34 +
     .../RaiyonsDyRE/attachables/leather_helmet.json    |   34 +
     .../RaiyonsDyRE/attachables/netherite_helmet.json  |   35 +
     .../RaiyonsDyRE/attachables/turtle_helmet.json     |   35 +
     omf/survival-dkr/resource/RaiyonsDyRE/blocks.json  |    8 +
     .../resource/RaiyonsDyRE/manifest.json             |   33 +
     .../RaiyonsDyRE/models/blocks/torchSide.json       |   37 +
     .../RaiyonsDyRE/models/blocks/torchUp.json         |   35 +
     .../models/entity/miner_helmet.geo.json            |   79 ++
     .../RaiyonsDyRE/models/entity/torch_helmet.json    |   42 +
     .../RaiyonsDyRE/models/entity/vanilla_helmet.json  |   30 +
     .../resource/RaiyonsDyRE/pack_icon.png             |  Bin 0 -> 2442 bytes
     .../resource/RaiyonsDyRE/particles/fire.json       |   36 +
     .../resource/RaiyonsDyRE/particles/light.json      |   49 +
     .../render_controllers/miner_armor.json            |   10 +
     .../render_controllers/miner_helmet.json           |   11 +
     .../render_controllers/torch_helmet.json           |   11 +
     .../resource/RaiyonsDyRE/texts/bg_BG.lang          |   11 +
     .../resource/RaiyonsDyRE/texts/cs_CZ.lang          |   11 +
     .../resource/RaiyonsDyRE/texts/da_DK.lang          |   12 +
     .../resource/RaiyonsDyRE/texts/de_DE.lang          |   12 +
     .../resource/RaiyonsDyRE/texts/el_GR.lang          |   12 +
     .../resource/RaiyonsDyRE/texts/en_GB.lang          |   12 +
     .../resource/RaiyonsDyRE/texts/en_US.lang          |   22 +
     .../resource/RaiyonsDyRE/texts/es_ES.lang          |    7 +
     .../resource/RaiyonsDyRE/texts/es_MX.lang          |    7 +
     .../resource/RaiyonsDyRE/texts/fi_FI.lang          |    7 +
     .../resource/RaiyonsDyRE/texts/fr_CA.lang          |    7 +
     .../resource/RaiyonsDyRE/texts/fr_FR.lang          |    7 +
     .../resource/RaiyonsDyRE/texts/hu_HU.lang          |    7 +
     .../resource/RaiyonsDyRE/texts/id_ID.lang          |    7 +
     .../resource/RaiyonsDyRE/texts/it_IT.lang          |    7 +
     .../resource/RaiyonsDyRE/texts/ja_JP.lang          |    7 +
     .../resource/RaiyonsDyRE/texts/ko_KR.lang          |    7 +
     .../resource/RaiyonsDyRE/texts/languages.json      |   31 +
     .../resource/RaiyonsDyRE/texts/nb_NO.lang          |    7 +
     .../resource/RaiyonsDyRE/texts/nl_NL.lang          |    7 +
     .../resource/RaiyonsDyRE/texts/pl_PL.lang          |    7 +
     .../resource/RaiyonsDyRE/texts/pt_BR.lang          |    7 +
     .../resource/RaiyonsDyRE/texts/pt_PT.lang          |    7 +
     .../resource/RaiyonsDyRE/texts/ru_RU.lang          |    7 +
     .../resource/RaiyonsDyRE/texts/sk_SK.lang          |    7 +
     .../resource/RaiyonsDyRE/texts/sv_SE.lang          |    7 +
     .../resource/RaiyonsDyRE/texts/tr_TR.lang          |    7 +
     .../resource/RaiyonsDyRE/texts/uk_UA.lang          |    7 +
     .../resource/RaiyonsDyRE/texts/zh_CN.lang          |    7 +
     .../resource/RaiyonsDyRE/texts/zh_TW.lang          |    7 +
     .../RaiyonsDyRE/textures/armor/miner_helmet.png    |  Bin 0 -> 575 bytes
     .../textures/armor/torches/black_torch.png         |  Bin 0 -> 186 bytes
     .../textures/armor/torches/blue_torch.png          |  Bin 0 -> 190 bytes
     .../textures/armor/torches/brown_torch.png         |  Bin 0 -> 190 bytes
     .../textures/armor/torches/custom_torch.png        |  Bin 0 -> 175 bytes
     .../textures/armor/torches/cyan_torch.png          |  Bin 0 -> 183 bytes
     .../textures/armor/torches/gray_torch.png          |  Bin 0 -> 194 bytes
     .../textures/armor/torches/green_torch.png         |  Bin 0 -> 190 bytes
     .../textures/armor/torches/light_blue_torch.png    |  Bin 0 -> 183 bytes
     .../textures/armor/torches/light_gray_torch.png    |  Bin 0 -> 181 bytes
     .../textures/armor/torches/lime_torch.png          |  Bin 0 -> 183 bytes
     .../textures/armor/torches/magenta_torch.png       |  Bin 0 -> 182 bytes
     .../textures/armor/torches/orange_torch.png        |  Bin 0 -> 182 bytes
     .../textures/armor/torches/pink_torch.png          |  Bin 0 -> 182 bytes
     .../textures/armor/torches/purple_torch.png        |  Bin 0 -> 183 bytes
     .../textures/armor/torches/red_torch.png           |  Bin 0 -> 182 bytes
     .../textures/armor/torches/redstone_torch.png      |  Bin 0 -> 181 bytes
     .../textures/armor/torches/sea_torch.png           |  Bin 0 -> 216 bytes
     .../textures/armor/torches/soul_torch.png          |  Bin 0 -> 183 bytes
     .../textures/armor/torches/torch_on.png            |  Bin 0 -> 182 bytes
     .../textures/armor/torches/white_torch.png         |  Bin 0 -> 183 bytes
     .../textures/armor/torches/yellow_torch.png        |  Bin 0 -> 181 bytes
     .../RaiyonsDyRE/textures/blocks/black_torch.png    |  Bin 0 -> 174 bytes
     .../RaiyonsDyRE/textures/blocks/blue_torch.png     |  Bin 0 -> 175 bytes
     .../RaiyonsDyRE/textures/blocks/brown_torch.png    |  Bin 0 -> 176 bytes
     .../RaiyonsDyRE/textures/blocks/custom_torch.png   |  Bin 0 -> 175 bytes
     .../RaiyonsDyRE/textures/blocks/cyan_torch.png     |  Bin 0 -> 176 bytes
     .../RaiyonsDyRE/textures/blocks/gray_torch.png     |  Bin 0 -> 177 bytes
     .../RaiyonsDyRE/textures/blocks/green_torch.png    |  Bin 0 -> 176 bytes
     .../textures/blocks/light_blue_torch.png           |  Bin 0 -> 176 bytes
     .../textures/blocks/light_gray_torch.png           |  Bin 0 -> 178 bytes
     .../RaiyonsDyRE/textures/blocks/lime_torch.png     |  Bin 0 -> 176 bytes
     .../RaiyonsDyRE/textures/blocks/magenta_torch.png  |  Bin 0 -> 175 bytes
     .../RaiyonsDyRE/textures/blocks/orange_torch.png   |  Bin 0 -> 176 bytes
     .../RaiyonsDyRE/textures/blocks/pink_torch.png     |  Bin 0 -> 176 bytes
     .../RaiyonsDyRE/textures/blocks/purple_torch.png   |  Bin 0 -> 176 bytes
     .../RaiyonsDyRE/textures/blocks/red_torch.png      |  Bin 0 -> 178 bytes
     .../textures/blocks/redstone_torch_on.png          |  Bin 0 -> 175 bytes
     .../RaiyonsDyRE/textures/blocks/soul_torch.png     |  Bin 0 -> 189 bytes
     .../RaiyonsDyRE/textures/blocks/torch_on.png       |  Bin 0 -> 167 bytes
     .../textures/blocks/torch_underwater.png           |  Bin 0 -> 234 bytes
     .../RaiyonsDyRE/textures/blocks/white_torch.png    |  Bin 0 -> 176 bytes
     .../RaiyonsDyRE/textures/blocks/yellow_torch.png   |  Bin 0 -> 178 bytes
     .../RaiyonsDyRE/textures/item_texture.json         | 1306 ++++++++++++++++++++
     .../textures/items/helmets/chainmail.png           |  Bin 0 -> 283 bytes
     .../RaiyonsDyRE/textures/items/helmets/diamond.png |  Bin 0 -> 293 bytes
     .../items/helmets/dyeable_icons/chainmail.png      |  Bin 0 -> 268 bytes
     .../items/helmets/dyeable_icons/diamond.png        |  Bin 0 -> 283 bytes
     .../items/helmets/dyeable_icons/golden.png         |  Bin 0 -> 287 bytes
     .../textures/items/helmets/dyeable_icons/iron.png  |  Bin 0 -> 264 bytes
     .../items/helmets/dyeable_icons/leather.png        |  Bin 0 -> 297 bytes
     .../items/helmets/dyeable_icons/netherite.png      |  Bin 0 -> 280 bytes
     .../items/helmets/dyeable_icons/torch/#black.png   |  Bin 0 -> 98 bytes
     .../items/helmets/dyeable_icons/torch/#blue.png    |  Bin 0 -> 96 bytes
     .../items/helmets/dyeable_icons/torch/#brown.png   |  Bin 0 -> 96 bytes
     .../items/helmets/dyeable_icons/torch/#cyan.png    |  Bin 0 -> 96 bytes
     .../items/helmets/dyeable_icons/torch/#gray.png    |  Bin 0 -> 98 bytes
     .../items/helmets/dyeable_icons/torch/#green.png   |  Bin 0 -> 96 bytes
     .../helmets/dyeable_icons/torch/#light_blue.png    |  Bin 0 -> 96 bytes
     .../helmets/dyeable_icons/torch/#light_gray.png    |  Bin 0 -> 99 bytes
     .../items/helmets/dyeable_icons/torch/#lime.png    |  Bin 0 -> 96 bytes
     .../items/helmets/dyeable_icons/torch/#magenta.png |  Bin 0 -> 95 bytes
     .../items/helmets/dyeable_icons/torch/#orange.png  |  Bin 0 -> 96 bytes
     .../items/helmets/dyeable_icons/torch/#pink.png    |  Bin 0 -> 96 bytes
     .../items/helmets/dyeable_icons/torch/#purple.png  |  Bin 0 -> 96 bytes
     .../items/helmets/dyeable_icons/torch/#red.png     |  Bin 0 -> 98 bytes
     .../helmets/dyeable_icons/torch/#redstone.png      |  Bin 0 -> 97 bytes
     .../items/helmets/dyeable_icons/torch/#sea.png     |  Bin 0 -> 99 bytes
     .../items/helmets/dyeable_icons/torch/#soul.png    |  Bin 0 -> 96 bytes
     .../items/helmets/dyeable_icons/torch/#white.png   |  Bin 0 -> 96 bytes
     .../items/helmets/dyeable_icons/torch/#yellow.png  |  Bin 0 -> 99 bytes
     .../items/helmets/dyeable_icons/turtle.png         |  Bin 0 -> 299 bytes
     .../RaiyonsDyRE/textures/items/helmets/golden.png  |  Bin 0 -> 302 bytes
     .../RaiyonsDyRE/textures/items/helmets/iron.png    |  Bin 0 -> 278 bytes
     .../RaiyonsDyRE/textures/items/helmets/leather.png |  Bin 0 -> 314 bytes
     .../textures/items/helmets/netherite.png           |  Bin 0 -> 300 bytes
     .../RaiyonsDyRE/textures/items/helmets/turtle.png  |  Bin 0 -> 311 bytes
     .../RaiyonsDyRE/textures/items/light_block_11.png  |  Bin 0 -> 83 bytes
     .../RaiyonsDyRE/textures/items/light_block_15.png  |  Bin 0 -> 83 bytes
     .../RaiyonsDyRE/textures/items/light_block_8.png   |  Bin 0 -> 83 bytes
     .../RaiyonsDyRE/textures/items/sea_torch.png       |  Bin 0 -> 247 bytes
     .../textures/models/armor/miner/chain_1.png        |  Bin 0 -> 328 bytes
     .../textures/models/armor/miner/cloth_1.png        |  Bin 0 -> 1023 bytes
     .../textures/models/armor/miner/diamond_1.png      |  Bin 0 -> 600 bytes
     .../textures/models/armor/miner/gold_1.png         |  Bin 0 -> 602 bytes
     .../textures/models/armor/miner/iron_1.png         |  Bin 0 -> 589 bytes
     .../textures/models/armor/miner/netherite_1.png    |  Bin 0 -> 468 bytes
     .../textures/models/armor/miner/turtle_1.png       |  Bin 0 -> 573 bytes
     .../RaiyonsDyRE/textures/particles/colorfire.png   |  Bin 0 -> 141 bytes
     .../RaiyonsDyRE/textures/particles/lightning.png   |  Bin 0 -> 299 bytes
     .../RaiyonsDyRE/textures/terrain_texture.json      |   59 +
     .../RaiyonsDyRE/textures/textures_list.json        |    1 +
     .../resource/SimpleWaystoneRP/blocks.json          |  285 +++++
     .../resource/SimpleWaystoneRP/font/glyph_E7.png    |  Bin 0 -> 1175 bytes
     .../resource/SimpleWaystoneRP/manifest.json        |   26 +
     .../blocks/simple_waystone/waystone.geo.json       |  685 ++++++++++
     .../resource/SimpleWaystoneRP/pack_icon.png        |  Bin 0 -> 13019 bytes
     .../SimpleWaystoneRP/sounds/sound_definitions.json |   89 ++
     .../resource/SimpleWaystoneRP/texts/en_US.lang     |  370 ++++++
     .../resource/SimpleWaystoneRP/texts/languages.json |    4 +
     .../resource/SimpleWaystoneRP/texts/pt_BR.lang     |  370 ++++++
     .../textures/blocks/simple_waystone/letters.png    |  Bin 0 -> 236 bytes
     .../simple_waystone/letters.texture_set.json       |    7 +
     .../blocks/simple_waystone/letters_black.png       |  Bin 0 -> 210 bytes
     .../simple_waystone/letters_black.texture_set.json |    7 +
     .../blocks/simple_waystone/letters_blue.png        |  Bin 0 -> 237 bytes
     .../simple_waystone/letters_blue.texture_set.json  |    7 +
     .../blocks/simple_waystone/letters_brown.png       |  Bin 0 -> 239 bytes
     .../simple_waystone/letters_brown.texture_set.json |    7 +
     .../blocks/simple_waystone/letters_cyan.png        |  Bin 0 -> 239 bytes
     .../simple_waystone/letters_cyan.texture_set.json  |    7 +
     .../blocks/simple_waystone/letters_glow.png        |  Bin 0 -> 224 bytes
     .../blocks/simple_waystone/letters_gray.png        |  Bin 0 -> 231 bytes
     .../simple_waystone/letters_gray.texture_set.json  |    7 +
     .../blocks/simple_waystone/letters_green.png       |  Bin 0 -> 235 bytes
     .../simple_waystone/letters_green.texture_set.json |    7 +
     .../blocks/simple_waystone/letters_light_blue.png  |  Bin 0 -> 239 bytes
     .../letters_light_blue.texture_set.json            |    7 +
     .../blocks/simple_waystone/letters_light_gray.png  |  Bin 0 -> 231 bytes
     .../letters_light_gray.texture_set.json            |    7 +
     .../blocks/simple_waystone/letters_lime.png        |  Bin 0 -> 236 bytes
     .../simple_waystone/letters_lime.texture_set.json  |    7 +
     .../blocks/simple_waystone/letters_magenta.png     |  Bin 0 -> 239 bytes
     .../letters_magenta.texture_set.json               |    7 +
     .../blocks/simple_waystone/letters_orange.png      |  Bin 0 -> 239 bytes
     .../letters_orange.texture_set.json                |    7 +
     .../blocks/simple_waystone/letters_pink.png        |  Bin 0 -> 239 bytes
     .../simple_waystone/letters_pink.texture_set.json  |    7 +
     .../blocks/simple_waystone/letters_purple.png      |  Bin 0 -> 239 bytes
     .../letters_purple.texture_set.json                |    7 +
     .../blocks/simple_waystone/letters_red.png         |  Bin 0 -> 234 bytes
     .../simple_waystone/letters_red.texture_set.json   |    7 +
     .../blocks/simple_waystone/letters_yellow.png      |  Bin 0 -> 236 bytes
     .../letters_yellow.texture_set.json                |    7 +
     .../textures/flipbook_textures.json                |   16 +
     .../SimpleWaystoneRP/textures/item_texture.json    |    9 +
     .../items/simple_waystone/golden_feather.png       |  Bin 0 -> 353 bytes
     .../items/simple_waystone/return_scroll.png        |  Bin 0 -> 370 bytes
     .../textures/items/simple_waystone/warpstone.png   |  Bin 0 -> 351 bytes
     .../SimpleWaystoneRP/textures/terrain_texture.json |   32 +
     omf/survival-dkr/restore_backup.sh                 |   87 +-
     omf/survival-dkr/sh/install_script.sh              | 1249 ++++++++-----------
     omf/survival-dkr/update_map.sh                     |  113 +-
     1432 files changed, 113790 insertions(+), 841 deletions(-)

- v1.5.4 (2025-09-14)
  - 変更: version bump
  - 変更ファイル一覧:
    - omf/survival-dkr/backup_now.sh
    - omf/survival-dkr/restore_backup.sh
    - omf/survival-dkr/sh/install_script.sh
    - omf/survival-dkr/update_map.sh
  - 変更サマリ(stat):
     omf/survival-dkr/backup_now.sh        |  12 +-
     omf/survival-dkr/restore_backup.sh    |  19 +-
     omf/survival-dkr/sh/install_script.sh | 333 ++++++++++++----------------------
     omf/survival-dkr/update_map.sh        |  87 ++-------
     4 files changed, 140 insertions(+), 311 deletions(-)

- v1.5.5 (2025-09-14)
  - 変更: version bump
(差分はありません)

- v1.4.2 (2025-09-15)
  - 変更: version bump
(差分はありません)

- v1.5.2 (2025-09-15)
  - 変更: version bump
(差分はありません)

- v1.5.4 (2025-09-15)
  - 変更: version bump
(差分はありません)

- v1.5.5 (2025-09-16)
  - 変更: version bump
(差分はありません)

- v1.5.6 (2025-09-16)
  - 変更: version bump
(差分はありません)

- v1.6.0 (2025-09-16)
  - 変更: version bump
(差分はありません)

- v1.6.1 (2025-09-16)
  - 変更: version bump
(差分はありません)

- v1.7.0 (2025-09-16)
  - 変更: version bump
(差分はありません)

- v1.7.1 (2025-09-16)
  - 変更: version bump
  - 変更ファイル一覧:
    - omf/survival-dkr/backup_now.sh
    - omf/survival-dkr/resource/teleport_rp/manifest.json
    - omf/survival-dkr/resource/teleport_rp/texts/en_US.lang
    - omf/survival-dkr/resource/teleport_rp/texts/ja_JP.lang
    - omf/survival-dkr/resource/teleport_rp/textures/terrain_texture.json
    - omf/survival-dkr/restore_backup.sh
    - omf/survival-dkr/sh/install_script.sh
    - omf/survival-dkr/update_map.sh
  - 変更サマリ(stat):
     omf/survival-dkr/backup_now.sh                     | 47 +++++++----
     .../resource/teleport_rp/manifest.json             | 19 +++--
     .../resource/teleport_rp/texts/en_US.lang          |  2 +-
     .../resource/teleport_rp/texts/ja_JP.lang          |  2 +-
     .../teleport_rp/textures/terrain_texture.json      |  2 -
     omf/survival-dkr/restore_backup.sh                 | 90 ++++++++++++++++++----
     omf/survival-dkr/sh/install_script.sh              | 50 +++++++++---
     omf/survival-dkr/update_map.sh                     | 80 ++++++++++++-------
     8 files changed, 214 insertions(+), 78 deletions(-)

- v1.7.0 (2025-09-17)
  - 変更: version bump
  - 変更ファイル一覧:
    - omf/survival-dkr/backup.cron.log
    - omf/survival-dkr/backup_now.sh
    - omf/survival-dkr/resource/teleport_rp/manifest.json
    - omf/survival-dkr/resource/teleport_rp/texts/en_US.lang
    - omf/survival-dkr/resource/teleport_rp/texts/ja_JP.lang
    - omf/survival-dkr/restore_backup.sh
    - omf/survival-dkr/sh/install_script.sh
    - omf/survival-dkr/update_map.sh
  - 変更サマリ(stat):
     omf/survival-dkr/backup.cron.log                   |   1 +
     omf/survival-dkr/backup_now.sh                     |  12 +-
     .../resource/teleport_rp/manifest.json             |  20 +-
     .../resource/teleport_rp/texts/en_US.lang          |   2 +-
     .../resource/teleport_rp/texts/ja_JP.lang          |   2 +-
     omf/survival-dkr/restore_backup.sh                 |  29 +-
     omf/survival-dkr/sh/install_script.sh              | 452 +++++++++++++--------
     omf/survival-dkr/update_map.sh                     |  43 +-
     8 files changed, 334 insertions(+), 227 deletions(-)

- v1.8.0 (2025-09-18)
  - 変更: version bump
  - 変更ファイル一覧:
    - omf/html_server.html
    - omf/survival-dkr/backup.cron.log
    - omf/survival-dkr/backup_now.sh
    - omf/survival-dkr/docker-prune.cron.log
    - omf/survival-dkr/resource/SimpleWaystoneTexture/blocks.json
    - omf/survival-dkr/resource/SimpleWaystoneTexture/font/glyph_E7.png
    - omf/survival-dkr/resource/SimpleWaystoneTexture/manifest.json
    - omf/survival-dkr/resource/SimpleWaystoneTexture/models/blocks/simple_waystone/waystone.geo.json
    - omf/survival-dkr/resource/SimpleWaystoneTexture/pack_icon.png
    - omf/survival-dkr/resource/SimpleWaystoneTexture/sounds/sound_definitions.json
    - omf/survival-dkr/resource/SimpleWaystoneTexture/texts/en_US.lang
    - omf/survival-dkr/resource/SimpleWaystoneTexture/texts/ja_JP.lang
    - omf/survival-dkr/resource/SimpleWaystoneTexture/texts/languages.json
    - omf/survival-dkr/resource/SimpleWaystoneTexture/texts/pt_BR.lang
    - omf/survival-dkr/resource/SimpleWaystoneTexture/textures/blocks/simple_waystone/letters.png
    - omf/survival-dkr/resource/SimpleWaystoneTexture/textures/blocks/simple_waystone/letters.texture_set.json
    - omf/survival-dkr/resource/SimpleWaystoneTexture/textures/blocks/simple_waystone/letters_black.png
    - omf/survival-dkr/resource/SimpleWaystoneTexture/textures/blocks/simple_waystone/letters_black.texture_set.json
    - omf/survival-dkr/resource/SimpleWaystoneTexture/textures/blocks/simple_waystone/letters_blue.png
    - omf/survival-dkr/resource/SimpleWaystoneTexture/textures/blocks/simple_waystone/letters_blue.texture_set.json
    - omf/survival-dkr/resource/SimpleWaystoneTexture/textures/blocks/simple_waystone/letters_brown.png
    - omf/survival-dkr/resource/SimpleWaystoneTexture/textures/blocks/simple_waystone/letters_brown.texture_set.json
    - omf/survival-dkr/resource/SimpleWaystoneTexture/textures/blocks/simple_waystone/letters_cyan.png
    - omf/survival-dkr/resource/SimpleWaystoneTexture/textures/blocks/simple_waystone/letters_cyan.texture_set.json
    - omf/survival-dkr/resource/SimpleWaystoneTexture/textures/blocks/simple_waystone/letters_glow.png
    - omf/survival-dkr/resource/SimpleWaystoneTexture/textures/blocks/simple_waystone/letters_gray.png
    - omf/survival-dkr/resource/SimpleWaystoneTexture/textures/blocks/simple_waystone/letters_gray.texture_set.json
    - omf/survival-dkr/resource/SimpleWaystoneTexture/textures/blocks/simple_waystone/letters_green.png
    - omf/survival-dkr/resource/SimpleWaystoneTexture/textures/blocks/simple_waystone/letters_green.texture_set.json
    - omf/survival-dkr/resource/SimpleWaystoneTexture/textures/blocks/simple_waystone/letters_light_blue.png
    - omf/survival-dkr/resource/SimpleWaystoneTexture/textures/blocks/simple_waystone/letters_light_blue.texture_set.json
    - omf/survival-dkr/resource/SimpleWaystoneTexture/textures/blocks/simple_waystone/letters_light_gray.png
    - omf/survival-dkr/resource/SimpleWaystoneTexture/textures/blocks/simple_waystone/letters_light_gray.texture_set.json
    - omf/survival-dkr/resource/SimpleWaystoneTexture/textures/blocks/simple_waystone/letters_lime.png
    - omf/survival-dkr/resource/SimpleWaystoneTexture/textures/blocks/simple_waystone/letters_lime.texture_set.json
    - omf/survival-dkr/resource/SimpleWaystoneTexture/textures/blocks/simple_waystone/letters_magenta.png
    - omf/survival-dkr/resource/SimpleWaystoneTexture/textures/blocks/simple_waystone/letters_magenta.texture_set.json
    - omf/survival-dkr/resource/SimpleWaystoneTexture/textures/blocks/simple_waystone/letters_orange.png
    - omf/survival-dkr/resource/SimpleWaystoneTexture/textures/blocks/simple_waystone/letters_orange.texture_set.json
    - omf/survival-dkr/resource/SimpleWaystoneTexture/textures/blocks/simple_waystone/letters_pink.png
    - omf/survival-dkr/resource/SimpleWaystoneTexture/textures/blocks/simple_waystone/letters_pink.texture_set.json
    - omf/survival-dkr/resource/SimpleWaystoneTexture/textures/blocks/simple_waystone/letters_purple.png
    - omf/survival-dkr/resource/SimpleWaystoneTexture/textures/blocks/simple_waystone/letters_purple.texture_set.json
    - omf/survival-dkr/resource/SimpleWaystoneTexture/textures/blocks/simple_waystone/letters_red.png
    - omf/survival-dkr/resource/SimpleWaystoneTexture/textures/blocks/simple_waystone/letters_red.texture_set.json
    - omf/survival-dkr/resource/SimpleWaystoneTexture/textures/blocks/simple_waystone/letters_yellow.png
    - omf/survival-dkr/resource/SimpleWaystoneTexture/textures/blocks/simple_waystone/letters_yellow.texture_set.json
    - omf/survival-dkr/resource/SimpleWaystoneTexture/textures/flipbook_textures.json
    - omf/survival-dkr/resource/SimpleWaystoneTexture/textures/item_texture.json
    - omf/survival-dkr/resource/SimpleWaystoneTexture/textures/items/simple_waystone/golden_feather.png
    - omf/survival-dkr/resource/SimpleWaystoneTexture/textures/items/simple_waystone/return_scroll.png
    - omf/survival-dkr/resource/SimpleWaystoneTexture/textures/items/simple_waystone/warpstone.png
    - omf/survival-dkr/resource/SimpleWaystoneTexture/textures/terrain_texture.json
    - omf/survival-dkr/resource/teleport_rp/manifest.json
    - omf/survival-dkr/resource/teleport_rp/texts/en_US.lang
    - omf/survival-dkr/resource/teleport_rp/texts/ja_JP.lang
    - omf/survival-dkr/resource/teleport_rp/textures/item_texture.json
    - omf/survival-dkr/resource/teleport_rp/textures/terrain_texture.json
    - omf/survival-dkr/restore_backup.sh
    - omf/survival-dkr/sh/install_script.sh
    - omf/survival-dkr/update_map.sh
    - omf/survival-dkr/ver/version.md
  - 変更サマリ(stat):
     omf/html_server.html                               | 242 +++++++
     omf/survival-dkr/backup.cron.log                   |   2 +
     omf/survival-dkr/backup_now.sh                     |  12 +-
     omf/survival-dkr/docker-prune.cron.log             |   1 +
     .../resource/SimpleWaystoneTexture/blocks.json     | 285 ++++++++
     .../SimpleWaystoneTexture/font/glyph_E7.png        | Bin 0 -> 1175 bytes
     .../resource/SimpleWaystoneTexture/manifest.json   |  26 +
     .../blocks/simple_waystone/waystone.geo.json       | 685 ++++++++++++++++++++
     .../resource/SimpleWaystoneTexture/pack_icon.png   | Bin 0 -> 13019 bytes
     .../sounds/sound_definitions.json                  |  89 +++
     .../SimpleWaystoneTexture/texts/en_US.lang         | 370 +++++++++++
     .../SimpleWaystoneTexture/texts/ja_JP.lang         | 370 +++++++++++
     .../SimpleWaystoneTexture/texts/languages.json     |   5 +
     .../SimpleWaystoneTexture/texts/pt_BR.lang         | 370 +++++++++++
     .../textures/blocks/simple_waystone/letters.png    | Bin 0 -> 236 bytes
     .../simple_waystone/letters.texture_set.json       |   7 +
     .../blocks/simple_waystone/letters_black.png       | Bin 0 -> 210 bytes
     .../simple_waystone/letters_black.texture_set.json |   7 +
     .../blocks/simple_waystone/letters_blue.png        | Bin 0 -> 237 bytes
     .../simple_waystone/letters_blue.texture_set.json  |   7 +
     .../blocks/simple_waystone/letters_brown.png       | Bin 0 -> 239 bytes
     .../simple_waystone/letters_brown.texture_set.json |   7 +
     .../blocks/simple_waystone/letters_cyan.png        | Bin 0 -> 239 bytes
     .../simple_waystone/letters_cyan.texture_set.json  |   7 +
     .../blocks/simple_waystone/letters_glow.png        | Bin 0 -> 224 bytes
     .../blocks/simple_waystone/letters_gray.png        | Bin 0 -> 231 bytes
     .../simple_waystone/letters_gray.texture_set.json  |   7 +
     .../blocks/simple_waystone/letters_green.png       | Bin 0 -> 235 bytes
     .../simple_waystone/letters_green.texture_set.json |   7 +
     .../blocks/simple_waystone/letters_light_blue.png  | Bin 0 -> 239 bytes
     .../letters_light_blue.texture_set.json            |   7 +
     .../blocks/simple_waystone/letters_light_gray.png  | Bin 0 -> 231 bytes
     .../letters_light_gray.texture_set.json            |   7 +
     .../blocks/simple_waystone/letters_lime.png        | Bin 0 -> 236 bytes
     .../simple_waystone/letters_lime.texture_set.json  |   7 +
     .../blocks/simple_waystone/letters_magenta.png     | Bin 0 -> 239 bytes
     .../letters_magenta.texture_set.json               |   7 +
     .../blocks/simple_waystone/letters_orange.png      | Bin 0 -> 239 bytes
     .../letters_orange.texture_set.json                |   7 +
     .../blocks/simple_waystone/letters_pink.png        | Bin 0 -> 239 bytes
     .../simple_waystone/letters_pink.texture_set.json  |   7 +
     .../blocks/simple_waystone/letters_purple.png      | Bin 0 -> 239 bytes
     .../letters_purple.texture_set.json                |   7 +
     .../blocks/simple_waystone/letters_red.png         | Bin 0 -> 234 bytes
     .../simple_waystone/letters_red.texture_set.json   |   7 +
     .../blocks/simple_waystone/letters_yellow.png      | Bin 0 -> 236 bytes
     .../letters_yellow.texture_set.json                |   7 +
     .../textures/flipbook_textures.json                |  16 +
     .../textures/item_texture.json                     |   9 +
     .../items/simple_waystone/golden_feather.png       | Bin 0 -> 353 bytes
     .../items/simple_waystone/return_scroll.png        | Bin 0 -> 370 bytes
     .../textures/items/simple_waystone/warpstone.png   | Bin 0 -> 351 bytes
     .../textures/terrain_texture.json                  |  32 +
     .../resource/teleport_rp/manifest.json             |  29 -
     .../resource/teleport_rp/texts/en_US.lang          |   2 -
     .../resource/teleport_rp/texts/ja_JP.lang          |   2 -
     .../teleport_rp/textures/item_texture.json         |   9 -
     .../teleport_rp/textures/terrain_texture.json      |   9 -
     omf/survival-dkr/restore_backup.sh                 |  29 +-
     omf/survival-dkr/sh/install_script.sh              | 720 ++++++++++++++-------
     omf/survival-dkr/update_map.sh                     |  43 +-
     omf/survival-dkr/ver/version.md                    |  22 +
     62 files changed, 3177 insertions(+), 314 deletions(-)

- v1.8.1 (2025-09-18)
  - 変更: version bump
  - 変更ファイル一覧:
    - omf/survival-dkr/backup.cron.log
    - omf/survival-dkr/sh/install_script.sh
  - 変更サマリ(stat):
     omf/survival-dkr/backup.cron.log      |  1 +
     omf/survival-dkr/sh/install_script.sh | 64 ++++++++++++++++++++++++++++-------
     2 files changed, 53 insertions(+), 12 deletions(-)

- v1.8.2 (2025-09-18)
  - 変更: version bump
  - 変更ファイル一覧:
    - omf/survival-dkr/sh/install_script.sh
  - 変更サマリ(stat):
     omf/survival-dkr/sh/install_script.sh | 77 +++++++++++++++--------------------
     1 file changed, 32 insertions(+), 45 deletions(-)

- v2.0.0 (2025-09-18)
  - 変更: version bump
  - 変更ファイル一覧:
    - omf/survival-dkr/sh/install_script.sh
  - 変更サマリ(stat):
     omf/survival-dkr/sh/install_script.sh | 4 ++--
     1 file changed, 2 insertions(+), 2 deletions(-)

- v2.0.1 (2025-09-18)
  - 変更: version bump
(差分はありません)

- v2.0.2 (2025-09-19)
  - 変更: version bump
(差分はありません)

- v2.0.3 (2025-09-21)
  - 変更: version bump
  - 変更ファイル一覧:
    - omf/survival-dkr/sh/install_script.sh
  - 変更サマリ(stat):
     omf/survival-dkr/sh/install_script.sh | 6 +++++-
     1 file changed, 5 insertions(+), 1 deletion(-)

- v2.1.0 (2025-09-23)
  - 変更: version bump
(差分はありません)
