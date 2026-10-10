# FF14 自動挖寶（SND）

SND（Something Need Doing）Lua 腳本，戰士單人循環挖寶與寶物庫。

| 腳本 | 地圖 | 藏寶地區 | 寶物庫 |
| --- | --- | --- | --- |
| [G17_AutoTreasure.lua](G17_AutoTreasure.lua) | 古舊的布拉克斯革地圖（Timeworn Br'aaxskin Map，8 人圖） | 黃金版 5 區（Living Memory 除外） | Cenote Ja Ja Gural（選門型，5 關） |
| [G15_AutoTreasure.lua](G15_AutoTreasure.lua) | 古舊的蛇牛革地圖（Timeworn Ophiotauroskin Map） | 厄爾庇斯 | The Shifting Gymnasion Agonon（輪盤型，5 關） |

直接下載（貼進 SND）：

- G17：https://raw.githubusercontent.com/forgefkcode/ff14-g15-autotreasure/main/G17_AutoTreasure.lua
- G15：https://raw.githubusercontent.com/forgefkcode/ff14-g15-autotreasure/main/G15_AutoTreasure.lua

## 需求

- SND（Lua 引擎）、vnavmesh、Wrath Combo、BossMod Reborn（只開閃避）
- 建議：Globetrotter（`/tmap` 時自動在精確藏寶點插旗）

## 使用前必填

- G17：`MapItemId`、`ChestName`、`PortalName`、`DoorName`；各地區傳送目的地依客戶端語系調整
- G15：`MapItemId`、`ChestName`、`PortalName`、`SphereName`

## 狀態

兩支都尚未在遊戲內實測。標 `TODO` 的 Api 函式需依實測修正。G17 是 8 人圖，單刷可行性沒有來源。
