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
