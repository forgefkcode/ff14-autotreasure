# FF14 自動挖寶（SND）

SND（Something Need Doing）Lua 腳本，戰士單人循環挖寶與寶物庫。

| 腳本 | 狀態 | 地圖 | 藏寶地區 | 寶物庫 |
| --- | --- | --- | --- | --- |
| [G15_AutoTreasure.lua](G15_AutoTreasure.lua) | 實測調整中 | 陳舊的地圖G15（Timeworn Ophiotauroskin Map） | 厄爾庇斯 | The Shifting Gymnasion Agonon（輪盤型，5 關） |
| [G17_AutoTreasure.lua](G17_AutoTreasure.lua) | 尚未實測，之後再調整 | 陳舊的地圖G17（Timeworn Br'aaxskin Map，8 人圖） | 黃金版 5 區（Living Memory 除外） | Cenote Ja Ja Gural（選門型，5 關） |

直接下載（貼進 SND）：

- G15：https://raw.githubusercontent.com/forgefkcode/ff14-autotreasure/main/G15_AutoTreasure.lua
- G17：https://raw.githubusercontent.com/forgefkcode/ff14-autotreasure/main/G17_AutoTreasure.lua

測試工具（`tools/`）：

- 市場板搜尋診斷：https://raw.githubusercontent.com/forgefkcode/ff14-autotreasure/main/tools/MarketSearchTest.lua
- 喝藥測試：https://raw.githubusercontent.com/forgefkcode/ff14-autotreasure/main/tools/PotionTest.lua

## 需求

- SND（Lua 引擎）、vnavmesh（移動）、Lifestream（傳送）、Wrath Combo、BossMod 或 BossMod Reborn（擇一，只開閃避；`BossModPlugin` 預設自動偵測）
- 建議：[XIV 藏寶圖工具小幫手](https://github.com/cycleapple/xiv-party-treasure-helper)（XivTreasureParty），開啟「解碼後自動開地圖打旗標」，解讀後自動在藏寶點插旗；沒裝就要手動插旗

## 自動買圖

`AutoBuy` 開啟時，腳本維持身上 1 張已解讀 + 1 張未解讀（地圖是獨特物品，未解讀的只能帶 1 張；已解讀的算不同物品）：
買 1 張 → 關市場板 → 解讀 → 再買 1 張 → 關市場板 → 出發挖寶，挖完回來再補，一直循環。
買不到（沒貨、超過 `MaxMapPrice`、gil 會低於 `GilFloor`）時，先用身上剩下的圖挖完再結束。

## 跨伺服器買圖

`CrossWorld` 開啟時（預設開），每輪開始前會查 [Universalis](https://universalis.app) 上 `DataCenter`（預設「陸行鳥」）內這張地圖最便宜的單張上架，用 Lifestream 傳送到那個伺服器買圖並在那裡挖寶。

- 一輪 = 買齊 1 張已解讀 + 1 張未解讀，兩張都挖完、身上完全沒圖時才重新比價
- Universalis 的價格是玩家上傳的，可能有延遲；到了之後實際價格超過 `MaxMapPrice` 或已被買走，會排除該伺服器、改去下一個最便宜的
- 查不到價格（網路問題、沒有符合條件的上架）時，留在目前伺服器照常買

## 使用前準備

- **自動買圖必做：** 在市場板把要買的地圖（G15「陳舊的地圖G15」、G17「陳舊的地圖G17」等，以遊戲內名稱為準）加入「我的最愛」，腳本會在我的最愛清單裡依名稱找到它並點開；沒加入的話買圖會卡在搜尋步驟

## 使用前必填

- 共通：`MaxMapPrice`（每張圖最多付多少 gil）
- 以太之光、市場板名稱留空即可，腳本會從遊戲資料自動取客戶端語系的名稱；買圖時傳送到利姆薩·羅敏薩下層甲板大水晶（`MarketTerritoryId` 129），再走到市場板旁 `-121, 18, 12`（`MarketX/Y/Z`）

- G17：`ChestName`、`PortalName`、`DoorName`；
- G15：`ChestName`、`PortalName`、`SphereName`

## 狀態

兩支都尚未在遊戲內實測。標 `TODO` 的 Api 函式需依實測修正。G17 是 8 人圖，單刷可行性沒有來源。
