# FF14 自動挖寶（SND）

SND（Something Need Doing）Lua 腳本，戰士單人循環挖寶與寶物庫。

| 腳本 | 狀態 | 地圖 | 藏寶地區 | 寶物庫 |
| --- | --- | --- | --- | --- |
| [G12_AutoTreasure.lua](G12_AutoTreasure.lua) | 新寫，尚未實測（由 G15 / G17 組合） | Timeworn Zonureskin Map | 漆黑版 6 區（Lakeland、Kholusia、Amh Araeng、Il Mheg、The Rak'tika Greatwood、The Tempest） | Lyhe Ghiah：進去才知道是選門型（The Dungeons）或轉盤型（The Shifting Oubliettes），依地區自動分流 |
| [G14_AutoTreasure.lua](G14_AutoTreasure.lua) | 新寫，尚未實測（架構與選門流程同 G12） | 陳舊的地圖G14（Timeworn Kumbhiraskin Map） | 曉月版 5 區（Labyrinthos、Thavnair、Garlemald、Mare Lamentorum、Ultima Thule） | 驚奇百寶城（The Excitatron 6000，選門型，5 層） |
| [G15_AutoTreasure.lua](G15_AutoTreasure.lua) | 實測調整中 | 陳舊的地圖G15（Timeworn Ophiotauroskin Map） | 厄爾庇斯 | The Shifting Gymnasion Agonon（輪盤型，5 關） |
| [G17_AutoTreasure.lua](G17_AutoTreasure.lua) | 由 G15 改寫（寶物庫為選門流程），尚未實測 | 陳舊的地圖G17（Timeworn Br'aaxskin Map，8 人圖） | 黃金版 5 區（Living Memory 除外） | Cenote Ja Ja Gural（選門型，5 關） |

直接下載（貼進 SND）：

- G12：https://raw.githubusercontent.com/forgefkcode/ff14-autotreasure/main/G12_AutoTreasure.lua
- G14：https://raw.githubusercontent.com/forgefkcode/ff14-autotreasure/main/G14_AutoTreasure.lua
- G15：https://raw.githubusercontent.com/forgefkcode/ff14-autotreasure/main/G15_AutoTreasure.lua
- G17：https://raw.githubusercontent.com/forgefkcode/ff14-autotreasure/main/G17_AutoTreasure.lua

測試工具（`tools/`）：

- 市場板搜尋診斷：https://raw.githubusercontent.com/forgefkcode/ff14-autotreasure/main/tools/MarketSearchTest.lua
- 強欲陷阱牌面數字診斷（強欲陷阱視窗出現時執行，按「挑戰解除陷阱」後看牌）：https://raw.githubusercontent.com/forgefkcode/ff14-autotreasure/main/tools/GambleTest.lua

## 需求

- SND（Lua 引擎）、vnavmesh（移動）、Lifestream（傳送）、自動輸出 RotationSolver Reborn 或 Wrath Combo（擇一，`RotationPlugin` 預設自動偵測，優先 RSR）、閃避 BossMod 或 BossMod Reborn（擇一，只開 AI 閃避；G15 / G17 用 `BossModPlugin` 選擇，預設優先 BossMod；G12 固定用 BossMod（沒啟用才退回 BossMod Reborn，並停用 BMR 的自動循環））。G15、G17 都支援 RSR，喝藥交給 RSR 處理
- 建議：[XIV 藏寶圖工具小幫手](https://github.com/cycleapple/xiv-party-treasure-helper)（XivTreasureParty），開啟「解碼後自動開地圖打旗標」，解讀後自動在藏寶點插旗；沒裝就要手動插旗
  - 它偶爾解讀後不打旗標（只打一次、遊戲沒接受也不重試）：腳本 10 秒沒等到新旗標，會用 `/xldisableplugin`、`/xlenableplugin` 重新載入它，每張圖最多 2 次。插件不能放在 Dalamud 的插件集合（collection）裡，不然指令管不到它

## 使用的插件版本

G15 目前實測使用的組合（感謝兩位大神）：

| 用途 | 插件 | 版本來源 |
| --- | --- | --- |
| 閃避（AI，只在寶物庫戰鬥中開） | BossMod | lilasrepo 大神的版本 |
| 自動輸出、自動吃藥 | RotationSolver Reborn | cycleapple 大神的版本 |

## 自動買圖

`AutoBuy` 開啟時，腳本維持身上 1 張已解讀 + 1 張未解讀（地圖是獨特物品，未解讀的只能帶 1 張；已解讀的算不同物品）：
買 1 張 → 關市場板 → 解讀 → 再買 1 張 → 關市場板 → 出發挖寶，挖完回來再補，一直循環。
買不到（沒貨、超過 `MaxMapPrice`、gil 會低於 `GilFloor`）時，先用身上剩下的圖挖完再結束。

## 跨伺服器買圖

`CrossWorld` 開啟時（預設開），每次買圖前都會查 [Universalis](https://universalis.app) 上 `DataCenter`（預設「陸行鳥」）內這張地圖最便宜的單張上架，用 Lifestream 傳送到那個伺服器買圖並在那裡挖寶。

- 一輪 = 買齊 1 張已解讀 + 1 張未解讀，兩張都挖完、身上完全沒圖時開始下一輪
- 每次買圖前都重新比價（一輪查 2 次）：比價 → 買 1 張 → 關市場板 → 解讀 → 再比價 → 買 1 張 → 關市場板 → 出發挖寶
- Universalis 的價格是玩家上傳的，可能有延遲；到了之後實際價格超過 `MaxMapPrice` 或已被買走，會排除該伺服器、改去下一個最便宜的
- 查不到價格（網路問題、沒有符合條件的上架）時，留在目前伺服器照常買

## G17 寶物庫（Cenote Ja Ja Gural，選門型）

每一層：跑到寶箱 → 開寶箱打怪 → 開殘留寶箱、處理強欲陷阱 → 兩扇「寶物庫的門」選一扇 → 等開門動畫 → 走進門踩傳送法陣到下一層，共 5 層。

- 出現「右側的門發光了！」或「左側的門發光了！」時只會剩一扇門可以互動，選那扇；沒有提示就等 `DoorHintWait` 秒後依 `DoorChoice` 隨機選
- 門後的傳送法陣不能互動、沒有名稱：穿過門再往前 `PassageDistance`；角色被傳送（位置瞬間跳動）就算到下一層
- 強欲陷阱（大／小魔法球）依 `GambleMode` 處理：`Ignore`（預設，不互動）/ `Big` / `Small`

## G14 寶物庫（驚奇百寶城，選門型）

G14 由 G12 產生，選門型流程和 G12 相同（見下方 G12 選門型），只換成 G14 自己的地圖、藏寶地區、藏寶點與寶物庫地區（1000）。唯一不同的是第 1 層入口：進去後等 20 秒 → 沿面向直線往前走到傳送法陣 → 等過場動畫結束才去找寶箱。門、寶箱、退出點等物件名稱沿用 G12 的預設值，驚奇百寶城裡的實際名稱尚未確認。

## G12 寶物庫（Lyhe Ghiah，選門型或轉盤型）

G12 的寶物庫進去之後才知道是哪一種，腳本進入時依所在地區判斷並分流：

- 地區 879 The Dungeons of Lyhe Ghiah → 選門型，流程同 G14（見下方）
- 地區 924 The Shifting Oubliettes of Lyhe Ghiah → 轉盤型，流程同 G15（點召喚魔法陣 → 等輪盤 → 打怪 → 開寶箱 → 下一關）

兩種都是最多 5 關／層。

G12 選門型每一層（第 1 層進去先等 10 秒）：走到寶箱旁互動 → 飛斧開怪、自動戰鬥 → 寶箱自動打開 → 強欲陷阱 → 選門 → 過場動畫 → 下一層。

- 每一層都一定要打一次怪才會開寶箱；換層後先等過場動畫結束（看狀態旗標），停掉舊導航再重新規劃路徑
- 飛斧開怪：先走到怪物旁（5 碼內）才選取、丟飛斧；走過去 3 秒沒前進就改成直線走（轉盤型維持 18 碼）
- 選門：互動後確認門真的有反應（「打開了…大門」訊息、動畫旗標、門變成不能互動），沒反應就走近一點再互動，最多 3 次
- 第 4 → 5 層：走進門 → 等過場動畫結束（這段動畫可能不亮任何旗標，用「導航在跑但 2 秒沒移動」判斷）→ 走到怪物旁開怪 → 打完後走過去開寶箱（最終區的寶箱不會自動打開）→ 退出點
- 強欲陷阱：看不到卡牌數字，一律自動放棄（按「不挑戰解除陷阱」，不看 `GambleMode`）；放棄不了才暫停讓你手動處理，處理完會自動繼續，或在聊天框輸入 `/echo #繼續`。`GambleDiag`（預設開）在暫停期間印出寶箱周圍物件的記憶體變化（同 `tools/GambleTest.lua` v0.5，`[G12][強欲]` 開頭）

## 使用前準備

- **每個等級用各自的 SND 腳本：** 把新內容貼進已存在的腳本時，SND 會保留舊的同名設定值。地圖 ID 已寫死在各腳本裡不受影響，但其他設定（價格上限、等待秒數等）會沿用舊值，建議 G12、G15、G17 各建一支腳本

- **自動買圖必做：** 在市場板把要買的地圖（G15「陳舊的地圖G15」、G17「陳舊的地圖G17」等，以遊戲內名稱為準）加入「我的最愛」，腳本會在我的最愛清單裡依名稱找到它並點開；沒加入的話買圖會卡在搜尋步驟

## 使用前必填

- 共通：`MaxMapPrice`（每張圖最多付多少 gil）
- 以太之光、市場板名稱留空即可，腳本會從遊戲資料自動取客戶端語系的名稱；買圖時傳送到利姆薩·羅敏薩下層甲板大水晶（`MarketTerritoryId` 129），再走到市場板旁 `-121, 18, 12`（`MarketX/Y/Z`）

- G17：`ChestName`、`PortalName`、`DoorName`；
- G15：`ChestName`、`PortalName`、`SphereName`
- G12：`ChestName`、`PortalName`、`DoorName`、`SphereName`（兩種寶物庫的物件名稱都要對）
- G14：`ChestName`、`PortalName`、`DoorName`

## 狀態

兩支都尚未在遊戲內實測。標 `TODO` 的 Api 函式需依實測修正。G17 是 8 人圖，單刷可行性沒有來源。
