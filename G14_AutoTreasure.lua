--[=====[
[[SND Metadata]]
author: forgefk
version: 0.1.0
description: FF14 G14 自動挖寶（陳舊的地圖G14，Timeworn Kumbhiraskin Map）+ 寶物庫 驚奇百寶城（The Excitatron 6000，選門型）。架構與選門流程同 G12。
plugin_dependencies:
- vnavmesh
- Lifestream
function_chat_filters:
  OnChatMessage:
    message_regex: "."
configs:
  MaxRounds:
    default: 0
    description: 要刷幾輪（一輪 = 買齊 1 張已解讀 + 1 張未解讀並兩張都挖完），0 = 無限循環
    min: 0
    max: 9999
  MaxMaps:
    default: 0
    description: 本次最多跑幾張，0 = 不限
    min: 0
    max: 9999
  AutoBuy:
    default: true
    description: 圖不夠時自動到市場板買圖（維持身上 1 張已解讀 + 1 張未解讀）。事前記得在市場板把要買的地圖加入「我的最愛」
  RotationPlugin:
    default: "Auto"
    description: 自動輸出插件：Auto（有 RotationSolver Reborn 用 RSR，否則用 Wrath Combo）/ RotationSolver / WrathCombo
  CrossWorld:
    default: true
    description: 每次買圖前（一輪買 2 張、查 2 次）查 Universalis，傳送到資料中心內地圖最便宜的伺服器買圖並挖寶（需要 Lifestream）
  DataCenter:
    default: "陸行鳥"
    description: 要比價的資料中心（Universalis 上的名稱，繁中服是「陸行鳥」）
  MaxMapPrice:
    default: 0
    description: 每張圖最多付多少 gil（AutoBuy 開啟時必填，0 = 未設定，INIT 會停止）
    min: 0
    max: 999999999
  GilFloor:
    default: 0
    description: 買完後身上至少保留多少 gil
    min: 0
    max: 999999999
  MarketTerritoryId:
    default: 129
    description: 買圖的城市地區 ID（129 = 利姆薩·羅敏薩下層甲板，傳送到該區大水晶）
    min: 0
    max: 9999
  MarketAetheryte:
    default: ""
    description: 買圖城市的以太之光名稱（留空 = 依 MarketTerritoryId 自動從遊戲資料取）
  MarketX:
    default: -121
    description: 傳送到大水晶後要走去的市場板位置 X
    min: -3000
    max: 3000
  MarketY:
    default: 18
    description: 市場板位置 Y（高度）
    min: -3000
    max: 3000
  MarketZ:
    default: 12
    description: 市場板位置 Z
    min: -3000
    max: 3000
  FavoritesCallback:
    default: "12 6"
    description: 打開市場板「我的最愛」清單的 callback 參數（實測事件 12 會顯示我的最愛，後面的數字不影響；空白 = 不切換）
  MarketBoardName:
    default: ""
    description: 市場板物件名稱（留空 = 自動從遊戲資料取）
  FlagWait:
    default: 120
    description: 解讀後等藏寶點旗標的秒數（XivTreasureParty 自動打，或你手動插）
    min: 0
    max: 3600
  EnterDungeon:
    default: true
    description: 出現傳送門時是否進入寶物庫
  WalkRadius:
    default: 15
    description: 飛到離旗標多近就下坐騎改走路（飛行停點不準，近距離走路比較準）
    min: 0
    max: 200
  DigRadius:
    default: 3
    description: 距離旗標多近開始挖寶
    min: 0
    max: 50
  LeashRadius:
    default: 15
    description: 野外戰鬥時離寶箱（觸發陷阱的位置）多遠就走回去，太遠陷阱戰鬥會被重置
    min: 0
    max: 200
  FieldLootDelay:
    default: 5
    description: 野外打完怪後等幾秒再開寶箱
    min: 0
    max: 120
  PortalWait:
    default: 10
    description: 開箱後等待傳送門出現的秒數
    min: 0
    max: 300
  EnemyWait:
    default: 20
    description: 寶物庫戰鬥開始後最多等幾秒等怪物出現
    min: 0
    max: 600
  EnemySearchRange:
    default: 100
    description: 寶物庫內掃描敵人的範圍（判斷怪物出現、是否打完；不會選取目標）
    min: 0
    max: 500
  UseSprint:
    default: false
    description: 移動時是否使用衝刺
  MaxErrors:
    default: 3
    description: 連續錯誤幾次後停止腳本
    min: 0
    max: 100
  DoorName:
    default: "寶物庫的門"
    description: 寶物庫兩扇門的物件名稱（繁中客戶端）
  DoorChoice:
    default: "Random"
    description: 沒有發光提示時怎麼選門：Random（隨機）/ First（第一個找到的）
  DoorHintWait:
    default: 5
    description: 選門前等幾秒看有沒有「右側／左側的門發光了！」提示
    min: 0
    max: 120
  DoorAnimWait:
    default: 10
    description: 互動門之後等開門（或關門）動畫幾秒，動畫結束才走進去
    min: 0
    max: 120
  PassageDistance:
    default: 10
    description: 穿過門後再往前走多遠去踩傳送法陣（法陣不能互動、沒有名稱，只能往前走）
    min: 0
    max: 100
  GambleMode:
    default: "Pause"
    description: G14 不看這個設定：遇到強欲陷阱一律自動放棄（不挑戰），放棄不了才暫停讓你手動處理
  GambleBigName:
    default: "大"
    description: 強欲陷阱「大」魔法球的物件名稱
  GambleDiag:
    default: true
    description: 強欲陷阱暫停時自動跑診斷，在聊天框印出視窗、物件、聊天訊息的變化，用來找牌面數字讀不讀得到（不會按按鈕）
  GambleSmallName:
    default: "小"
    description: 強欲陷阱「小」魔法球的物件名稱
  ChestName:
    default: "寶箱"
    description: 野外寶箱物件名稱（繁中客戶端）
  DungeonChestName:
    default: "寶箱"
    description: 寶物庫寶箱物件名稱（空白 = 同 ChestName）
  PortalName:
    default: "傳送魔紋"
    description: 傳送門物件名稱（繁中客戶端）
  ExitPortalName:
    default: "退出點"
    description: 寶物庫第 5 關後離開用的傳送門物件名稱（實測是「退出點」；找不到這個名稱時腳本也會再找「退出點」）
  EchoLogs:
    default: "All"
    description: 日誌層級 All / Errors / None
[[End Metadata]]
--]=====]

import("System.Numerics")

--[[
結構
  1. 常數與設定
  2. Api 轉接層：所有「待確認事項」的遊戲／插件呼叫都集中在這裡，實測後只改這一層
  3. 工具函式（日誌、計時、移動、互動、戰鬥）
  4. 狀態處理函式（主流程 + 寶物庫子流程），每個回傳下一個狀態
  5. 主迴圈
]]

-------------------------------------------------------------------------------
-- 1. 常數與設定
-------------------------------------------------------------------------------

local WARRIOR_JOB_ID   = 21
-- 寶物庫（驚奇百寶城 The Excitatron 6000，選門型）的地區 ID，取自 XIVAPI ContentFinderCondition 819
local DOOR_VAULT_TERRITORY = 1000
local VAULT_TERRITORIES = { [DOOR_VAULT_TERRITORY] = true }

-- G14 的藏寶地區：曉月版 5 區（Labyrinthos、Thavnair、Garlemald、Mare Lamentorum、Ultima Thule；Elpis 沒有）
local G14_ZONES = { [956] = true, [957] = true, [958] = true, [959] = true, [960] = true }

-- 一般動作 ID（GeneralAction 表，取自 XIVAPI），用 ID 執行不受客戶端語系影響
local GA = {
    sprint        = 4,
    mountRoulette = 9,
    decipher      = 19,
    dig           = 20,
    dismount      = 23,
}

-- G14 的 40 個藏寶點（5 個地區各 8 個）的真正座標（含高度），取自 XIVAPI TreasureSpot（TreasureHuntRank 22）→ Level。
-- 格式：{ 地區 ID, X, Y（高度）, Z }
local TREASURE_SPOTS = {
    { 956, -143.93, -23.90, -167.07 },
    { 956, 162.41, -24.70, 410.09 },
    { 956, -733.87, -1.95, -26.82 },
    { 956, 20.55, -6.45, 805.51 },
    { 956, 138.44, 80.74, -528.54 },
    { 956, -651.64, -25.43, 449.09 },
    { 956, 518.35, 164.38, -350.44 },
    { 956, 174.52, -19.52, 16.72 },
    { 957, 268.29, 6.59, 373.21 },
    { 957, 24.47, 25.13, -21.51 },
    { 957, -20.01, 49.32, 290.72 },
    { 957, 540.59, 10.96, -352.60 },
    { 957, -96.87, 37.67, -362.70 },
    { 957, -332.71, 8.91, 259.61 },
    { 957, -337.21, 57.92, -677.81 },
    { 957, 283.27, 8.42, -626.73 },
    { 958, 195.67, 23.62, -451.23 },
    { 958, 639.38, 15.84, -574.87 },
    { 958, -253.41, 10.80, -464.50 },
    { 958, 649.25, 13.33, -207.91 },
    { 958, -265.37, 12.89, -180.42 },
    { 958, -482.00, 45.74, 212.18 },
    { 958, 335.67, -8.85, 250.52 },
    { 958, 393.70, -18.82, 697.73 },
    { 959, 668.35, 146.05, 423.07 },
    { 959, 210.73, 83.65, 592.51 },
    { 959, -217.06, 122.67, -103.73 },
    { 959, -134.07, 62.29, 213.60 },
    { 959, -463.59, 129.33, 258.76 },
    { 959, -278.78, 116.95, 648.76 },
    { 959, 451.88, 103.64, 174.77 },
    { 959, 66.26, 111.32, 741.28 },
    { 960, 264.07, 391.64, 701.90 },
    { 960, -0.81, 61.67, 744.21 },
    { 960, -765.30, 68.75, -119.85 },
    { 960, 408.63, 286.25, -603.24 },
    { 960, 214.70, 234.77, -211.25 },
    { 960, -665.94, 81.02, 462.78 },
    { 960, -178.06, 73.38, 277.13 },
    { 960, -436.64, 264.46, -403.35 },
}

local Cond = {
    dead            = 2,
    mounted         = 4,
    inCombat        = 26,
    casting         = 27,
    occupiedInEvent = 31,
    boundByDuty     = 34,
    boundByDuty56   = 56,
    betweenAreas    = 45,
    flying          = 77,
}

local Cfg = {
    -- 地圖 ID 寫死、不放設定：SND 把新內容貼進舊腳本時會保留舊的同名設定值，放設定會用到別的等級的圖
    MapItemId        = 36612,
    MaxRounds        = Config.Get("MaxRounds"),
    MaxMaps          = Config.Get("MaxMaps"),
    EnterDungeon     = Config.Get("EnterDungeon"),
    DecipheredItemId = 2003246,   -- 解讀後的重要物品 ID（取自 XIVAPI TreasureHuntRank），同樣寫死
    FlagWait   = Config.Get("FlagWait"),
    AutoBuy          = Config.Get("AutoBuy"),
    RotationPlugin   = Config.Get("RotationPlugin"),
    CrossWorld       = Config.Get("CrossWorld"),
    DataCenter       = Config.Get("DataCenter"),
    MaxMapPrice      = Config.Get("MaxMapPrice"),
    GilFloor         = Config.Get("GilFloor"),
    MarketTerritoryId = Config.Get("MarketTerritoryId"),
    MarketAetheryte  = Config.Get("MarketAetheryte"),
    MarketX          = Config.Get("MarketX"),
    MarketY          = Config.Get("MarketY"),
    MarketZ          = Config.Get("MarketZ"),
    FavoritesCallback = Config.Get("FavoritesCallback"),
    MarketBoardName  = Config.Get("MarketBoardName"),
    WalkRadius       = Config.Get("WalkRadius"),
    DigRadius        = Config.Get("DigRadius"),
    LeashRadius      = Config.Get("LeashRadius"),
    FieldLootDelay   = Config.Get("FieldLootDelay"),
    PortalWait       = Config.Get("PortalWait"),
    EnemyWait        = Config.Get("EnemyWait"),
    EnemySearchRange = Config.Get("EnemySearchRange"),
    UseSprint        = Config.Get("UseSprint"),
    MaxErrors        = Config.Get("MaxErrors"),
    DoorName         = Config.Get("DoorName"),
    DoorChoice       = Config.Get("DoorChoice"),
    DoorHintWait     = Config.Get("DoorHintWait"),
    DoorAnimWait     = Config.Get("DoorAnimWait"),
    PassageDistance  = Config.Get("PassageDistance"),
    GambleMode       = Config.Get("GambleMode"),
    GambleBigName    = Config.Get("GambleBigName"),
    GambleSmallName  = Config.Get("GambleSmallName"),
    GambleDiag       = Config.Get("GambleDiag"),
    ChestName        = Config.Get("ChestName"),
    DungeonChestName = Config.Get("DungeonChestName"),
    PortalName       = Config.Get("PortalName"),
    ExitPortalName   = Config.Get("ExitPortalName"),
    EchoLogs         = Config.Get("EchoLogs"),
}
if Cfg.DungeonChestName == nil or Cfg.DungeonChestName == "" then
    Cfg.DungeonChestName = Cfg.ChestName
end

-- 各狀態逾時（秒），建議初值，實測後調整
local Timeout = {
    CHECK_MAP        = 3,
    DECIPHER         = 10,
    -- LOCATE 不設：自己判斷 FlagWait，還要留時間重新載入藏寶圖工具小幫手
    TRAVEL           = 180,
    DIG              = 8,
    OPEN_COFFER      = 15,
    FIELD_COMBAT     = 600,   -- 遊戲戰鬥時限未知，先給寬鬆上限
    FIELD_FIGHT      = 600,
    LOOT             = 20,    -- 含確認框
    PORTAL_CHECK     = Cfg.PortalWait,
    ENTER_DUNGEON    = 60,
    DEAD             = 120,
    WORLD_TRAVEL     = 300,
    MB_TRAVEL        = 120,
    MB_OPEN          = 15,
    MB_SEARCH        = 180,   -- 含等待手動搜尋的時間
    MB_LIST          = 15,
    MB_BUY           = 15,
    MB_CLOSE        = 10,
    DUNGEON_INIT     = 30,
    DUNGEON_COMBAT   = 3600,  -- 副本限時 60 分鐘
    DUNGEON_ENTRY    = 150,   -- 入口：等 20 秒 + 直線往前走到傳送法陣 + 動畫
    DUNGEON_CHEST    = 120,   -- 含跑到寶箱的時間
    DUNGEON_LOOT     = 180,   -- 含強欲陷阱
    DUNGEON_DOOR     = 90,    -- 含走到門附近
    DUNGEON_DOOR_WAIT = 60,
    DUNGEON_PASSAGE  = 60,
    DUNGEON_PULL     = 180,   -- 找怪 3 次的保底
    DUNGEON_EXIT     = 180,
}

local DECIPHER_RETRIES = 2
local DIG_RETRIES      = 3
local DIG_OFFSET       = 5
local STUCK_INTERVAL   = 10
local STUCK_DISTANCE   = 1
local MAX_STAGES       = 5
local VAULT_CHEST_WAIT = 10   -- 寶物庫打完怪後最多等幾秒讓寶箱自動打開（寶物庫的寶箱不用互動）

-------------------------------------------------------------------------------
-- 2. Api 轉接層（SND v2 API；標 TODO 者為「待確認事項」，實測後修正）
-------------------------------------------------------------------------------

-- 先宣告 Log / LogError（定義在第 3 段），Api 的函式也要用得到
local Log, LogError

local Api = {}

-- .NET 列舉轉成名稱：NLua 的 tostring(列舉) 會得到「BattleNpc: 2」這種格式，直接跟 "BattleNpc" 比永遠不相等
--（SND 用的 NLua 1.7.9 實測）。只取冒號前的名稱再比
local function EnumName(v)
    local s = tostring(v)
    return s:match("^([%w_]+)") or s
end

function Api.Condition(id)
    return Svc.Condition[id] == true
end

-- 直接查 Dalamud 已載入的插件，用 InternalName 比對。
-- 不用 IPC.IsInstalled：它只認 SND 內建的 IPC 包裝（例如沒有 BossModReborn），
-- 而且比對的是顯示名稱（Wrath 顯示為 "Wrath Combo"），兩個都會誤判成沒裝
function Api.PluginInstalled(internalName)
    for plugin in luanet.each(Svc.PluginInterface.InstalledPlugins) do
        if plugin.InternalName == internalName and plugin.IsLoaded then
            return true
        end
    end
    return false
end

-- 插件裝了沒、載入了沒：nil = 沒裝，true = 已載入，false = 裝了但沒載入
function Api.PluginLoaded(internalName)
    for plugin in luanet.each(Svc.PluginInterface.InstalledPlugins) do
        if plugin.InternalName == internalName then return plugin.IsLoaded == true end
    end
    return nil
end

function Api.JobId()
    return Player.Job.Id
end

function Api.PlayerPos()
    return Entity.Player.Position
end

function Api.HpPercent()
    local p = Entity.Player
    if p == nil or p.MaxHp == 0 then return 100 end
    return p.CurrentHp / p.MaxHp * 100
end

function Api.Territory()
    return Svc.ClientState.TerritoryType
end

function Api.ItemCount(itemId)
    return Inventory.GetItemCount(itemId)
end

-- 解讀後的地圖是重要物品（DecipheredItemId），SND 的 Inventory.GetItemCount 支援重要物品
function Api.HasDecipheredMap()
    local ok, count = pcall(function() return Inventory.GetItemCount(Cfg.DecipheredItemId) end)
    if ok and count ~= nil then return count > 0 end
    return State.deciphered == true
end

function Api.IsFlagSet()
    return Instances.Map.IsFlagMarkerSet
end

function Api.FlagTerritory()
    return Instances.Map.Flag.TerritoryId
end

-- 旗標的世界座標；Y（高度）由 vnavmesh 自行處理
function Api.FlagPos()
    return Instances.Map.Flag.Vector3
end

-- TODO 待確認：地圖座標 → 旗標的 API 名稱與參數
function Api.SetFlag(territory, mapX, mapY)
    Instances.Map.Flag:SetFlagMapMarker(territory, mapX, mapY)
end

-- 名稱相符且可選取的最近物件（Dalamud 物件）。Entity.GetEntityByName 只回傳第一個同名物件、
-- 不管能不能選取，開過的寶箱還留在原地時會一直抓到它；有多個寶箱時也只看得到一個
function Api.NearestTargetable(name)
    if name == nil or name == "" then return nil end
    local ok, obj = pcall(function()
        local me = Api.PlayerPos()
        local objs = Svc.Objects
        local best, bestDist = nil, math.huge
        for i = 0, objs.Length - 1 do
            local o = objs[i]
            if o ~= nil and o.IsTargetable and o.Name.TextValue == name then
                local dx, dy, dz = o.Position.X - me.X, o.Position.Y - me.Y, o.Position.Z - me.Z
                local d = dx * dx + dy * dy + dz * dz
                if d < bestDist then best, bestDist = o, d end
            end
        end
        return best
    end)
    if ok then return obj end
    -- 列舉失敗時退回 SND 的 GetEntityByName，只接受可選取的
    local e = Entity.GetEntityByName(name)
    if e ~= nil and e.IsTargetable then return e end
    return nil
end

-- 場上還有沒有可互動的這種物件
function Api.GetEntity(name)
    return Api.NearestTargetable(name)
end

-- 選取最近、可互動的同名物件
function Api.Target(name)
    local o = Api.NearestTargetable(name)
    if o == nil then return false end
    local ok = pcall(function() Svc.Targets.Target = o end)
    if not ok then pcall(function() o:SetAsTarget() end) end
    return true
end

function Api.InteractTarget()
    local t = Entity.Target
    if t ~= nil then t:Interact() end
end

function Api.AddonReady(name)
    local a = Addons.GetAddon(name)
    return a ~= nil and a.Ready
end

function Api.HasHostileNearby(maxDistance)
    -- TODO 待確認：SND 是否提供敵對物件列舉；先以「目前目標是否為存活敵人」近似
    local t = Entity.Target
    return t ~= nil and t.IsHostile == true and t.CurrentHp > 0
        and t.DistanceTo ~= nil and t.DistanceTo < maxDistance
end

function Api.NavReady()
    return IPC.vnavmesh.IsReady()
end

function Api.NavRunning()
    return IPC.vnavmesh.IsRunning() or IPC.vnavmesh.PathfindInProgress()
end

-- 從 (x, 1024, z) 往下找 vnavmesh 地面，取得該點真正的高度（寫法同 pot0to 腳本）。找不到回 nil
function Api.PointOnFloor(x, z)
    local ok, p = pcall(function() return IPC.vnavmesh.PointOnFloor(Vector3(x, 1024, z), false, 5) end)
    if ok and p ~= nil then return p end
    return nil
end

function Api.NavMoveTo(pos, fly)
    IPC.vnavmesh.PathfindAndMoveTo(pos, fly)
end

function Api.NavStop()
    if Api.NavRunning() then IPC.vnavmesh.Stop() end
end

-- 地區主要大水晶的 ID（TerritoryType.Aetheryte）
function Api.TerritoryAetheryteId(territoryId)
    local ok, id = pcall(function() return Excel.GetRow("TerritoryType", territoryId).Aetheryte.RowId end)
    if ok and id ~= nil and tonumber(id) ~= nil and tonumber(id) > 0 then return tonumber(id) end
    return nil
end

-- 大水晶的實際座標（SND Instances.Telepo），取不到回 nil
function Api.AetherytePosition(aetheryteId)
    local ok, pos = pcall(function() return Instances.Telepo:GetAetherytePosition(aetheryteId) end)
    if ok and pos ~= nil and (pos.X ~= 0 or pos.Z ~= 0) then return pos end
    return nil
end

-- 直接傳送到指定大水晶（遊戲原生傳送，同地區也能傳）
function Api.TeleportToAetheryte(aetheryteId)
    local ok = pcall(function() Actions.Teleport(aetheryteId) end)
    return ok
end

-- 從遊戲資料取得地區主要以太之光的名稱（自動是客戶端語系），寫法取自 pot0to 的 SND 腳本
function Api.AetheryteName(territoryId)
    local ok, name = pcall(function()
        return tostring(Excel.GetRow("TerritoryType", territoryId).Aetheryte.PlaceName.Name)
    end)
    if ok and name ~= nil and name ~= "" and name ~= "nil" then return name end
    return nil
end

-- 市場板的物件名稱（EObjName 2000073，客戶端語系）
function Api.MarketBoardObjectName()
    local ok, name = pcall(function() return tostring(Excel.GetRow("EObjName", 2000073).Singular) end)
    if ok and name ~= nil and name ~= "" and name ~= "nil" then return name end
    return nil
end

-- 目前所在伺服器 ID（SND EntityWrapper.CurrentWorld）
function Api.CurrentWorldId()
    local ok, id = pcall(function() return Entity.Player.CurrentWorld end)
    if ok and id ~= nil then return tonumber(id) end
    return nil
end

-- 伺服器名稱（客戶端語系），Lifestream 跨伺服器傳送用
function Api.WorldName(worldId)
    local ok, name = pcall(function() return tostring(Excel.GetRow("World", worldId).Name) end)
    if ok and name ~= nil and name ~= "" and name ~= "nil" then return name end
    return nil
end

-- HTTP GET：先用 .NET HttpClient，失敗改用 PowerShell。回傳 (內容, nil) 或 (nil, 錯誤原因)
function Api.HttpGet(url)
    local ok, body = pcall(function()
        luanet.load_assembly("System.Net.Http")
        local clientType = luanet.import_type("System.Net.Http.HttpClient")
        if clientType == nil then error("找不到 HttpClient") end
        local client = clientType()
        pcall(function() client.Timeout = luanet.import_type("System.TimeSpan").FromSeconds(15) end)
        local result = client:GetStringAsync(url).Result
        client:Dispose()
        return tostring(result)
    end)
    if ok and body ~= nil and body ~= "" then return body, nil end
    local httpErr = ok and "回應是空的" or tostring(body)

    local psOut = nil
    ok, psOut = pcall(function()
        luanet.load_assembly("System.Diagnostics.Process")
        local encoding = luanet.import_type("System.Text.Encoding")
        local script = "[Console]::OutputEncoding=[Text.Encoding]::UTF8; "
            .. "(Invoke-WebRequest -UseBasicParsing -TimeoutSec 15 -Uri '" .. url .. "').Content"
        local b64 = luanet.import_type("System.Convert").ToBase64String(encoding.Unicode:GetBytes(script))
        local psi = luanet.import_type("System.Diagnostics.ProcessStartInfo")()
        psi.FileName = "powershell.exe"
        psi.Arguments = "-NoProfile -NonInteractive -WindowStyle Hidden -EncodedCommand " .. b64
        psi.CreateNoWindow = true
        psi.UseShellExecute = false
        psi.RedirectStandardOutput = true
        psi.StandardOutputEncoding = encoding.UTF8
        local p = luanet.import_type("System.Diagnostics.Process").Start(psi)
        local out = p.StandardOutput:ReadToEnd()
        p:WaitForExit(20000)
        return tostring(out)
    end)
    if ok and psOut ~= nil and psOut:find("listings", 1, true) then return psOut, nil end
    local psErr = ok and ("回應：" .. (psOut or ""):sub(1, 80)) or tostring(psOut)
    return nil, "HttpClient：" .. httpErr .. "；PowerShell：" .. psErr
end

-- 查 Universalis：資料中心內這張地圖最便宜的上架（只算單張、不超過 MaxMapPrice、不在 excluded 裡的伺服器）。
-- 回傳 { world = 伺服器ID, price = 單價 }；查不到回 (nil, 原因)。Universalis 的資料是玩家上傳的，可能有幾小時延遲
function Api.CheapestWorld(itemId, excluded)
    -- 網址編碼用純 Lua 做（System.Uri 所在的組件 SND 沒載入，import_type 會拿到 nil）
    local dc = Cfg.DataCenter:gsub("[^%w%-_%.~]", function(c) return string.format("%%%02X", string.byte(c)) end)
    local url = string.format(
        "https://universalis.app/api/v2/%s/%d?listings=50&entries=0&fields=listings.worldID%%2Clistings.pricePerUnit%%2Clistings.quantity",
        dc, itemId)
    local body, err = Api.HttpGet(url)
    if body == nil then return nil, "連不上 Universalis（" .. tostring(err) .. "）" end
    local best = nil
    for obj in body:gmatch("{[^{}]*}") do
        local price = tonumber(obj:match('"pricePerUnit":(%d+)'))
        local qty = tonumber(obj:match('"quantity":(%d+)'))
        local world = tonumber(obj:match('"worldID":(%d+)'))
        if price and qty == 1 and world and not excluded[world] and price <= Cfg.MaxMapPrice then
            if best == nil or price < best.price then best = { world = world, price = price } end
        end
    end
    if best == nil then return nil, "Universalis 上沒有 MaxMapPrice 以內的單張上架" end
    return best, nil
end

-- 切換成戰士：先找職業是戰士的套裝並裝備，找不到再用 /gs change <職業名稱>
function Api.SwitchToWarrior()
    local ok = pcall(function()
        local sets = Player.Gearsets
        for i = 0, sets.Count - 1 do
            local g = sets[i]
            if g.IsValid and g.ClassJob == WARRIOR_JOB_ID then
                g:Equip()
                return
            end
        end
        error("no warrior gearset")
    end)
    if ok then return true end
    local name = nil
    pcall(function() name = tostring(Excel.GetRow("ClassJob", WARRIOR_JOB_ID).Name) end)
    if name == nil or name == "" or name == "nil" then return false end
    yield("/gs change " .. name)
    return true
end

-- 物品名稱（客戶端語系），用來在市場板搜尋，避免手填名稱打錯而搜到別張圖
function Api.ItemName(itemId)
    local ok, name = pcall(function() return tostring(Excel.GetRow("Item", itemId).Name) end)
    if ok and name ~= nil and name ~= "" and name ~= "nil" then return name end
    return nil
end

-- 角色可操作（傳送、讀取、詠唱、過場都不算），寫法同 pot0to 腳本
function Api.PlayerReady()
    local ok, ready = pcall(function() return Player.Available and not Player.IsBusy end)
    return ok and ready == true
end

-- 解除目前的選取，讓 Wrath 自動選怪
function Api.ClearTarget()
    local ok = pcall(function() Entity.Player:ClearTarget() end)
    if not ok then ok = pcall(function() Svc.Targets.Target = nil end) end
    if not ok then yield("/send ESCAPE") end
end

-- 掃描全場物件（不選取目標），找 maxDistance 內最近的敵人：戰鬥 NPC、敵人類（SubKind 5 = Enemy）、可選取、還活著。
-- 回傳 Dalamud 物件或 nil
function Api.NearestEnemyObject(maxDistance)
    local ok, obj = pcall(function()
        local me = Api.PlayerPos()
        local objs = Svc.Objects
        local best, bestDist = nil, maxDistance * maxDistance
        for i = 0, objs.Length - 1 do
            local o = objs[i]
            if o ~= nil and o.IsTargetable and not o.IsDead
                and EnumName(o.ObjectKind) == "BattleNpc" and tonumber(o.SubKind) == 5 then
                local dx, dy, dz = o.Position.X - me.X, o.Position.Y - me.Y, o.Position.Z - me.Z
                local d = dx * dx + dy * dy + dz * dz
                if d <= bestDist then best, bestDist = o, d end
            end
        end
        return best
    end)
    if ok then return obj end
    return nil
end

-- maxDistance 內還有沒有敵人：只掃描場上物件，不選取目標（選目標交給 RSR，避免衝突）
function Api.AnyEnemyLeft(maxDistance)
    return Api.NearestEnemyObject(maxDistance) ~= nil
end

function Api.GeneralAction(id)
    Actions.ExecuteGeneralAction(id)
end

-- 傳送一律交給 Lifestream（/tp 是 Teleporter 插件的指令，沒裝就不存在）
-- destination = 以太之光名稱，依客戶端語系填
function Api.Teleport(destination)
    local ok = pcall(function() IPC.Lifestream.ExecuteCommand(destination) end)
    if not ok then yield("/li " .. destination) end
end

function Api.LifestreamBusy()
    local ok, busy = pcall(function() return IPC.Lifestream.IsBusy() end)
    return ok and busy == true
end

-- 開關自動輸出（RSR 或 Wrath，依 State.rotation）時同步記錄狀態，CombatTick / TRAVEL 依 State.wrathOn 判斷要不要再開。
-- 閃避 AI（BMR：/bmrai，BossMod：/vbm ai）只在寶物庫內跟著一起開：野外開 AI 會跟「離寶箱太遠就走回去」互相拉扯
local function BossAiCmd(on)
    if State.bossCmd == "/bmr" then return on and "/bmrai on" or "/bmrai off" end
    if State.bossCmd == "/vbm" then return on and "/vbm ai on" or "/vbm ai off" end
    return nil
end

function Api.WrathOn()
    yield(State.rotation == "RotationSolver" and "/rotation Auto" or "/wrath auto on")
    local aiCmd = BossAiCmd(true)
    if aiCmd ~= nil and VAULT_TERRITORIES[Api.Territory()] then
        yield(aiCmd)
        State.vbmAiOn = true
    end
    State.wrathOn = true
end

-- 寶物庫內自動輸出和閃避一直開著（進寶物庫就開，離開寶物庫才關）：寶物庫內一般的關閉呼叫（互動保護、打完怪）都跳過，
-- 只有 force = true（錯誤、結束）才真的關
function Api.WrathOff(force)
    if not force and VAULT_TERRITORIES[Api.Territory()] then return end
    yield(State.rotation == "RotationSolver" and "/rotation Off" or "/wrath auto off")
    if State.vbmAiOn then
        local aiCmd = BossAiCmd(false)
        if aiCmd ~= nil then yield(aiCmd) end
        State.vbmAiOn = false
    end
    State.aiSuspended = false
    State.wrathOn = false
end


-- 寶物庫（室內、各層上下疊在一起）的移動目的地：以 (x, y, z) 的高度找附近最近的可走點。
-- 不用 PointOnFloor：它從高度 1024 往下找地面，室內會先碰到上一層的地板或屋頂，目的地落在走不到的地方
function Api.NearestMeshPoint(x, y, z)
    local ok, p = pcall(function() return IPC.vnavmesh.NearestPoint(Vector3(x, y, z), 3, 6) end)
    if ok and p ~= nil then return p end
    return nil
end

function Api.VaultMoveTo(x, y, z)
    Api.NavMoveTo(Api.NearestMeshPoint(x, y, z) or Vector3(x, y, z), false)
end

-- 直線走到 pos，不做路徑規劃（vnavmesh 把目的地當成走不到時用）。List<Vector3> 的泛型參數要寫組件名稱（NLua 1.7.9 實測）
function Api.MoveStraight(pos)
    return pcall(function()
        local ListType = luanet.import_type("System.Collections.Generic.List`1[[System.Numerics.Vector3, System.Numerics.Vectors]]")
            or luanet.import_type("System.Collections.Generic.List`1[[System.Numerics.Vector3, System.Private.CoreLib]]")
        local list = ListType()
        list:Add(Vector3(pos.X, pos.Y, pos.Z))
        IPC.vnavmesh.MoveTo(list, false)
    end)
end

-- 暫時關掉閃避 AI（走路時被 AI 拉住用）；進入戰鬥時 CombatTick 呼叫 Api.ResumeAi 打開
function Api.SuspendAi()
    if not State.vbmAiOn then return end
    local aiCmd = BossAiCmd(false)
    if aiCmd ~= nil then yield(aiCmd) end
    State.vbmAiOn, State.aiSuspended = false, true
end

function Api.ResumeAi()
    if not State.aiSuspended then return end
    State.aiSuspended = false
    local aiCmd = BossAiCmd(true)
    if aiCmd ~= nil and VAULT_TERRITORIES[Api.Territory()] then
        yield(aiCmd)
        State.vbmAiOn = true
    end
end

-- 遊戲清單元件各列的文字，依畫面由上到下：第 0 列在節點 51001、第 1 列 51002…，最後一列在節點 5。
-- 社群腳本的順序（5 → 51001 → 51002）會整個錯開一格：實測點 G12 開到 G15、G15 開到 G17、G17 開到 G12
function Api.ListRows(addonName, listNodeId, textNodeId)
    local function text(id)
        local ok, t = pcall(function() return tostring(Addons.GetAddon(addonName):GetNode(1, listNodeId, id, textNodeId).Text) end)
        if not ok or t == nil or t == "nil" then return "" end
        return t
    end
    local rows = {}
    for j = 0, 98 do
        local t = text(51001 + j)
        if t == "" then break end
        table.insert(rows, t)
    end
    local last = text(5)
    if last ~= "" then table.insert(rows, last) end
    return rows
end

-- 解讀視窗是 SelectIconString（標題「解讀」）。依名稱在清單裡找這張地圖是第幾列（從 0 起算），
-- 節點路徑取自社群腳本 Narrr13/snd OpenMap.lua（列的順序已更正）。讀不到清單文字時退回第 1 列
function Api.FindDecipherIndex(name)
    local rows = Api.ListRows("SelectIconString", 3, 2)
    if #rows == 0 then return 0 end
    for i, text in ipairs(rows) do
        if text == name or text:find(name, 1, true) then return i - 1 end
    end
    return nil
end

function Api.ConfirmYes()
    if Api.AddonReady("SelectYesno") then
        yield("/callback SelectYesno true 0")
        return true
    end
    return false
end

-- 市場板操作：callback 參數取自社群 SND 腳本（ShamelessEnd/SomethingNeedScripts），
-- 原本是 SND v1 寫法；節點讀取改用 SND v2 的 Addons API。TODO 待實測
function Api.Gil()
    return Inventory.GetItemCount(1)
end

function Api.CloseAddon(name)
    if Api.AddonReady(name) then yield("/callback " .. name .. " true -1") end
end

function Api.AddonNodeText(addon, ...)
    local path = { ... }
    local ok, node = pcall(function() return Addons.GetAddon(addon):GetNode(table.unpack(path)) end)
    if not ok or node == nil or node.Text == nil then return "" end
    return tostring(node.Text)
end

-- SND 沒辦法把文字寫進市場板搜尋框（插件是呼叫遊戲內部的 SetText + RunSearch，Lua 碰不到；
-- /callback ItemSearch 帶名稱也不會執行搜尋）。改成：名稱放進剪貼簿 → Ctrl+A、Ctrl+V、Enter。
-- 注意：會覆蓋你剪貼簿裡原本的內容。

-- 寫入剪貼簿：先用 PowerShell Set-Clipboard（任何執行緒都能用），失敗再試 Dalamud 的 ImGui。回傳用了哪種方法
function Api.SetClipboard(text)
    local ok = pcall(function()
        luanet.load_assembly("System.Diagnostics.Process")
        local script = "Set-Clipboard -Value '" .. text:gsub("'", "''") .. "'"
        local bytes = luanet.import_type("System.Text.Encoding").Unicode:GetBytes(script)
        local b64 = luanet.import_type("System.Convert").ToBase64String(bytes)
        local psi = luanet.import_type("System.Diagnostics.ProcessStartInfo")()
        psi.FileName = "powershell.exe"
        psi.Arguments = "-NoProfile -NonInteractive -WindowStyle Hidden -EncodedCommand " .. b64
        psi.CreateNoWindow = true
        psi.UseShellExecute = false
        local p = luanet.import_type("System.Diagnostics.Process").Start(psi)
        if not p:WaitForExit(5000) or p.ExitCode ~= 0 then error("powershell failed") end
    end)
    if ok then return "PowerShell" end
    ok = pcall(function()
        luanet.load_assembly("Dalamud.Bindings.ImGui")
        luanet.import_type("Dalamud.Bindings.ImGui.ImGui").SetClipboardText(text)
    end)
    if ok then return "ImGui" end
    return nil
end

-- 在市場板搜尋框貼上名稱並按 Enter，再點第一筆結果
function Api.TypeIntoSearch(text)
    local method = Api.SetClipboard(text)
    if method == nil then return nil end
    yield("/send CONTROL+A")
    yield("/wait 0.2")
    yield("/send CONTROL+V")
    yield("/wait 0.3")
    yield("/send RETURN")
    yield("/wait 1.5")
    return method
end

-- 在市場板左側清單（我的最愛或搜尋結果）依名稱找出這個物品是第幾列（從 0 起算），找不到回 nil。
-- 節點路徑取自社群腳本 ShamelessEnd/SomethingNeedScripts（列的順序已更正，見 Api.ListRows）；
-- 名稱太長時清單會截斷成「...」，比對前半段
function Api.FindInResults(name)
    for i, text in ipairs(Api.ListRows("ItemSearch", 139, 13)) do
        if text == name then return i - 1 end
        if text:sub(-3) == "..." and name:find(text:sub(1, -4), 1, true) == 1 then return i - 1 end
    end
    return nil
end

-- 按「顯示我的最愛」（實測 ItemSearch 事件 12，後面的數字不影響），等清單出現（最多 3 秒）
function Api.ShowFavorites()
    yield("/callback ItemSearch true " .. Cfg.FavoritesCallback)
    for _ = 1, 6 do
        yield("/wait 0.5")
        if #Api.ListRows("ItemSearch", 139, 13) > 0 then return true end
    end
    return false
end

-- 點清單第 index 項，打開上架清單
function Api.MarketOpenResult(index)
    yield("/callback ItemSearch true 5 " .. index)
end

function Api.MarketOpenFirstResult()
    yield("/callback ItemSearch true 5 0")
end

-- 回傳最便宜一筆的單價與數量；還在讀取回傳 nil；沒有上架回傳 false
function Api.MarketFirstListing()
    local price = tonumber((Api.AddonNodeText("ItemSearchResult", 1, 26, 4, 5):gsub("%D", "")))
    local count = tonumber((Api.AddonNodeText("ItemSearchResult", 1, 26, 4, 6):gsub("%D", "")))
    if price ~= nil and price > 0 and count ~= nil and count > 0 then return price, count end
    local msg = Api.AddonNodeText("ItemSearchResult", 1, 5)
    if msg:find("No items found") or msg:find("沒有") then return false end
    return nil
end

-- SND 包裝的 IEnumerable（AddonWrapper.AtkValues / Nodes 等）轉成 Lua 陣列。
-- 那些是 C# 編譯器產生的 iterator，NLua 叫不到它的 GetEnumerator（luanet.each 會出錯），
-- 所以先丟進 .NET 的 List<object>，再用索引一筆一筆讀。失敗回傳 nil
function Api.ToLuaList(enumerable)
    local ok, items = pcall(function()
        local ListType = luanet.import_type("System.Collections.Generic.List`1[System.Object]")
        local list = ListType(enumerable)
        local out = {}
        for i = 0, list.Count - 1 do
            local item = list[i]
            if item == nil then item = list:get_Item(i) end
            out[#out + 1] = item
        end
        return out
    end)
    if ok then return items end
    return nil
end

function Api.MarketBuyFirstListing()
    yield("/callback ItemSearchResult true 2 0")
end

function Api.ProbeDecipheredMap()
    return Api.HasDecipheredMap()
end

-- 使用者手動中止：目前在 SND 介面按停止即可（會直接終止腳本，不跑 END 統計）。
-- TODO 若要軟停止（先收乾淨再結束），需找到 SND 可讀取的外部訊號後在這裡設定 State.stopRequested
function Api.StopRequested()
    return State.stopRequested
end

-------------------------------------------------------------------------------
-- 3. 工具函式
-------------------------------------------------------------------------------

State = {
    current       = "INIT",
    enteredAt     = os.clock(),
    deciphered    = false,
    retries       = 0,
    errors        = 0,
    stage         = 1,
    mapsDone      = 0,
    dungeonRuns   = 0,
    errorCount    = 0,
    lastPos       = nil,
    lastPosAt     = 0,
    rePathed      = false,
    digOffsetIdx  = 0,
    errorFrom     = nil,
    stopRequested = false,
    stageLog      = {},
}

function Log(msg)
    if Cfg.EchoLogs == "All" then yield("/echo [G14] " .. msg) end
end

function LogError(msg)
    if Cfg.EchoLogs ~= "None" then yield("/echo [G14][錯誤] " .. msg) end
end

local function Elapsed()
    return os.clock() - State.enteredAt
end

local function TimedOut(state)
    local t = Timeout[state]
    return t ~= nil and Elapsed() > t
end

local function Distance2D(a, b)
    local dx, dz = a.X - b.X, a.Z - b.Z
    return math.sqrt(dx * dx + dz * dz)
end

-- 是否在寶物庫內：看所在地區。不用角色狀態 34 / 56（被副本綁定），
-- 野外觸發陷阱後那個狀態也會亮，會誤判成已進副本而跳過傳送魔紋
local function InDuty()
    return VAULT_TERRITORIES[Api.Territory()] == true
end

local function Busy()
    return Api.Condition(Cond.betweenAreas) or Api.Condition(Cond.casting) or Api.LifestreamBusy()
end

local function StopAutomation()
    Api.WrathOff(true)   -- 錯誤、結束：寶物庫內也要關
    Api.NavStop()
end

-- 移動中卡住偵測：10 秒位移 < 1 → 重新尋路一次；再卡 → 回傳 "stuck"
local function CheckStuck(repath)
    local now, pos = os.clock(), Api.PlayerPos()
    if State.lastPos == nil then
        State.lastPos, State.lastPosAt = pos, now
        return "ok"
    end
    if now - State.lastPosAt < STUCK_INTERVAL then return "ok" end
    local moved = Distance2D(pos, State.lastPos)
    State.lastPos, State.lastPosAt = pos, now
    if moved >= STUCK_DISTANCE or not Api.NavRunning() then return "ok" end
    if State.rePathed then return "stuck" end
    Log("疑似卡住，重新尋路")
    State.rePathed = true
    repath()
    return "ok"
end

-- 上坐騎：重複執行直到真的騎上（剛傳送完、詠唱中送出會被吃掉）。回傳是否已在坐騎上
local function Mount()
    for _ = 1, 5 do
        if Api.Condition(Cond.mounted) then return true end
        if Api.PlayerReady() then Api.GeneralAction(GA.mountRoulette) end
        yield("/wait 1.5")
    end
    return Api.Condition(Cond.mounted)
end

-- 下坐騎：重複執行直到真的下來（飛行中第一次只會降落，要再按一次）。回傳是否已下坐騎
local function Dismount()
    for _ = 1, 20 do   -- 從高空下來要先降落，給到 20 秒
        if not Api.Condition(Cond.mounted) then return true end
        Api.GeneralAction(GA.dismount)
        yield("/wait 1")
    end
    return not Api.Condition(Cond.mounted)
end

-- 設定有填就用設定，留空就從遊戲資料取該地區的以太之光名稱
function Api.ResolveAetheryte(configured, territoryId)
    if configured ~= nil and configured ~= "" then return configured end
    return Api.AetheryteName(territoryId)
end

-- 選取並走到物件旁互動；回傳 true 表示已送出互動
local function ApproachAndInteract(name)
    if not Api.Target(name) then return false end
    local t = Entity.Target
    if t ~= nil and t.DistanceTo ~= nil and t.DistanceTo > 3 then
        if not Api.NavRunning() then yield("/vnav movetarget") end
        return false
    end
    Api.NavStop()
    Api.WrathOff()   -- 互動保護
    if not Dismount() then return false end   -- 騎著坐騎不能互動
    Api.InteractTarget()
    return true
end

local MARKET_ADDONS = { "ItemHistory", "ItemSearchResult", "ItemSearch" }

local function MarketOpen()
    for _, name in ipairs(MARKET_ADDONS) do
        if Api.AddonReady(name) then return true end
    end
    return false
end

-- 由內往外關市場視窗；每個視窗重複送 -1 直到真的消失（寫法同社群腳本 CloseAddon）
local function CloseMarket()
    for _, name in ipairs(MARKET_ADDONS) do
        local tries = 0
        while Api.AddonReady(name) and tries < 10 do
            yield("/callback " .. name .. " true -1")
            yield("/wait 0.3")
            tries = tries + 1
        end
    end
end

-------------------------------------------------------------------------------
-- 4. 狀態處理函式
-------------------------------------------------------------------------------

-- 買圖、換伺服器、解讀期間 Wrath 一律關閉（傳送到藏寶地區後才在 TRAVEL 開啟）
local function EnsureWrathOff()
    if State.wrathOn ~= false then
        Api.WrathOff()
    end
end

-- 聊天訊息觸發（每則聊天都會呼叫：強欲陷阱暫停時要收集所有訊息；函式只設旗標、收集訊息，不做別的事）：
--   「將陷阱引來的魔物全部打倒了！」→ 野外陷阱打完，去開寶箱
--   「右側的門發光了！」「左側的門發光了！」→ 寶物庫裡只會剩一扇門可以互動，選那扇
--   「強欲陷阱發動了！」→ 出現大／小兩顆魔法球，依 GambleMode 處理
function OnChatMessage()
    local ok, msg = pcall(function() return tostring(TriggerData.message) end)
    if not ok or msg == nil then return end
    if msg:sub(1, 5) == "[G14]" then return end   -- 腳本自己印的訊息（含診斷轉印的聊天內容）不處理
    if State.gambleDiagOn and #State.gambleChat < 60 then table.insert(State.gambleChat, msg) end
    if msg:find("將陷阱引來的魔物全部打倒了", 1, true) then
        State.fieldCleared = true
    elseif msg:find("打開了", 1, true) and msg:find("大門", 1, true) then
        State.doorOpened = true   -- 「打開了通往第二區的大門！」：選的門有反應
    elseif msg:find("右側的門發光了", 1, true) then
        State.doorHint = "右側"
    elseif msg:find("左側的門發光了", 1, true) then
        State.doorHint = "左側"
    elseif msg:find("強欲陷阱發動了", 1, true) then
        State.gambleActive = true
    elseif msg:match("^%s*#繼續%s*$") then
        State.resumeRequested = true   -- 你在聊天框輸入 /echo #繼續（整行只有這幾個字；腳本自己的提示訊息開頭是 [G14]，不會觸發）
    end
end

local Handlers = {}

function Handlers.INIT()
    local missing = {}
    for _, p in ipairs({ "vnavmesh", "Lifestream" }) do
        if not Api.PluginInstalled(p) then table.insert(missing, p) end
    end
    if #missing > 0 then
        LogError("缺少或未啟用的插件：" .. table.concat(missing, "、") .. "（請確認已在 /xlplugins 啟用）")
        return "END"
    end
    if Api.JobId() ~= WARRIOR_JOB_ID then
        Log("切換成戰士")
        Api.SwitchToWarrior()
        for _ = 1, 10 do
            yield("/wait 0.5")
            if Api.JobId() == WARRIOR_JOB_ID then break end
        end
        if Api.JobId() ~= WARRIOR_JOB_ID then
            LogError("切換戰士失敗：請先建立戰士的套裝")
            return "END"
        end
    end
    -- 自動輸出插件：RotationSolver Reborn（/rotation Auto|Off）或 Wrath Combo（/wrath auto on|off）
    local hasRsr, hasWrath = Api.PluginInstalled("RotationSolver"), Api.PluginInstalled("WrathCombo")
    local rotChoice = Cfg.RotationPlugin or "Auto"
    local rotation = nil
    if rotChoice == "RotationSolver" or (rotChoice == "Auto" and hasRsr) then
        rotation = hasRsr and "RotationSolver" or nil
    elseif rotChoice == "WrathCombo" or (rotChoice == "Auto" and hasWrath) then
        rotation = hasWrath and "WrathCombo" or nil
    end
    if rotation == nil then
        LogError("沒有偵測到啟用中的 RotationSolver Reborn / Wrath Combo（設定：" .. rotChoice .. "）")
        return "END"
    end
    if hasRsr and hasWrath then Log("提醒：RotationSolver 和 Wrath Combo 同時啟用，兩個會搶著放技能，建議只開一個") end
    State.rotation = rotation

    -- 閃避插件：G14 固定用 BossMod（/vbm ai on|off），只用 AI 閃避、寶物庫內才開。
    -- 不看閃避插件的設定：SND 會保留舊的同名設定值，可能選錯插件。
    -- BossMod 沒啟用時才退回 BossMod Reborn（/bmrai on|off）並提醒
    local hasVbm, hasBmr = Api.PluginInstalled("BossMod"), Api.PluginInstalled("BossModReborn")
    local bossCmd = nil
    if hasVbm then
        bossCmd = "/vbm"
    elseif hasBmr then
        bossCmd = "/bmr"
        Log("提醒：沒偵測到啟用中的 BossMod，改用 BossMod Reborn。G14 預定用 BossMod，請在 /xlplugins 啟用 BossMod")
    else
        LogError("沒有偵測到啟用中的 BossMod / BossMod Reborn（請在 /xlplugins 啟用 BossMod）")
        return "END"
    end
    if hasVbm and hasBmr then Log("提醒：BossMod 和 BossMod Reborn 同時啟用，兩個會搶著閃避，建議只開一個") end
    State.bossCmd = bossCmd
    -- 停用 BossMod / BMR 自己的自動循環，避免跟 RSR / Wrath 搶著放技能；它們只負責 AI 閃避
    if bossCmd == "/bmr" then
        -- /bmr ar disable：自動循環強制停用。
        -- /bmrai setpresetname null：清掉「AI 自動循環預設」（會存進 BMR 設定）。不清的話 /bmrai on 時 AI 每一幀都會
        -- 把自動循環換成這個預設，BMR 會自己放技能、自己選目標，跟 RSR 衝突
        yield("/bmr ar disable")
        yield("/bmrai setpresetname null")
    else
        yield(bossCmd .. " ar clear")
    end
    Log("輸出：" .. (rotation == "RotationSolver" and "RotationSolver Reborn" or "Wrath Combo")
        .. "；閃避：" .. (bossCmd == "/bmr" and "BossMod Reborn" or "BossMod") .. " AI（只在寶物庫內開）")
    if Cfg.MapItemId == 0 then
        LogError("未設定 MapItemId")
        return "END"
    end
    if Cfg.AutoBuy and Cfg.MaxMapPrice <= 0 then
        LogError("AutoBuy 開啟但未設定 MaxMapPrice")
        return "END"
    end
    State.deciphered = Api.ProbeDecipheredMap()
    Log("身上已解讀的圖：" .. (State.deciphered and "有" or "沒有")
        .. "，未解讀：" .. Api.ItemCount(Cfg.MapItemId) .. " 張")
    for _, k in ipairs({ "ChestName", "PortalName", "DoorName" }) do
        if Cfg[k] == "" then Log("提醒：" .. k .. " 未填，相關步驟會逾時") end
    end
    Cfg.MapItemName = Api.ItemName(Cfg.MapItemId)
    if Cfg.MapItemName == nil then
        LogError("從遊戲資料查不到物品 " .. Cfg.MapItemId .. " 的名稱")
        return "END"
    end
    Log("要買的地圖：" .. Cfg.MapItemName .. "（" .. Cfg.MapItemId .. "）")
    if Cfg.AutoBuy then
        Log("提醒：自動買圖前，請確認已在市場板把「" .. Cfg.MapItemName .. "」加入我的最愛")
    end
    if Cfg.MarketBoardName == "" then
        Cfg.MarketBoardName = Api.MarketBoardObjectName() or "Market Board"
    end
    if not Api.PluginInstalled("XivTreasureParty") then
        Log("提醒：沒偵測到 XivTreasureParty，解讀後需手動插旗")
    end
    Api.WrathOff()
    return "CHECK_MAP"
end

function Handlers.CHECK_MAP()
    if Cfg.MaxMaps > 0 and State.mapsDone >= Cfg.MaxMaps then
        Log("已達 MaxMaps")
        return "END"
    end
    -- 一輪 = 買齊 1 張已解讀 + 1 張未解讀，兩張都挖完（身上完全沒圖）才開始下一輪。
    -- 每次要買圖前都重新比價：CrossWorld 時先查當下最便宜的伺服器並傳送過去（PICK_WORLD → WORLD_TRAVEL），一輪查 2 次。
    -- 依序：比價 → 買 1 張 → 關市場板 → 解讀 → 再比價 → 買 1 張 → 關市場板 → 出發挖寶。
    -- 買不到時排除該伺服器、換下一個最便宜的；都買不到就不再買圖，用身上的圖挖完後結束
    local hasDeciphered = Api.HasDecipheredMap()
    local hasUndeciphered = Api.ItemCount(Cfg.MapItemId) > 0
    if Cfg.AutoBuy and not State.buyBlocked then
        -- 新的一輪：身上完全沒圖；或剛啟動、身上還沒湊齊 1 已解讀 + 1 未解讀
        local firstCheck = State.roundStarted == nil
        State.roundStarted = true
        if not State.roundBuying and ((not hasDeciphered and not hasUndeciphered)
            or (firstCheck and not (hasDeciphered and hasUndeciphered))) then
            -- 上一輪的圖都挖完了：計數，達到 MaxRounds 就結束（0 = 無限循環）
            if not firstCheck then
                State.roundsDone = (State.roundsDone or 0) + 1
                Log("完成第 " .. State.roundsDone .. " 輪")
                if Cfg.MaxRounds > 0 and State.roundsDone >= Cfg.MaxRounds then
                    Log("已達 MaxRounds（" .. Cfg.MaxRounds .. " 輪）")
                    return "END"
                end
            end
            State.roundBuying = true
            State.worldChosen = false
            State.badWorlds = {}
        end
        if State.roundBuying then
            -- 每次要買圖前都重新比價（第一張、第二張都去當下最便宜的伺服器）
            if not hasUndeciphered then
                if Cfg.CrossWorld and not State.worldChosen then return "PICK_WORLD" end
                return "MB_TRAVEL"
            end
            if not hasDeciphered then
                State.retries = 0
                return "DECIPHER"
            end
            State.roundBuying = false
            Log("本輪買齊（1 張已解讀 + 1 張未解讀），出發挖寶")
        end
    end
    if Api.HasDecipheredMap() then return "LOCATE" end
    if Api.ItemCount(Cfg.MapItemId) > 0 then
        State.retries = 0
        return "DECIPHER"
    end
    Log("沒有 G14 地圖了")
    return "END"
end

function Handlers.DECIPHER()
    EnsureWrathOff()
    if Api.HasDecipheredMap() then
        Api.CloseAddon("SelectIconString")
        State.deciphered = true
        Log("解讀完成")
        return "CHECK_MAP"
    end
    if Api.ConfirmYes() then return nil end
    if Api.AddonReady("SelectIconString") then
        local idx = Api.FindDecipherIndex(Cfg.MapItemName)
        if idx == nil then
            LogError("解讀清單裡找不到「" .. Cfg.MapItemName .. "」")
            Api.CloseAddon("SelectIconString")
            return "ERROR"
        end
        yield("/callback SelectIconString true " .. idx)
        yield("/wait 0.5")
        return nil
    end
    -- 還沒打開解讀視窗：角色可操作時按「解讀」，3 秒沒反應再按一次
    if Api.PlayerReady() and Elapsed() - (State.decipherAt or -10) > 3 then
        Api.GeneralAction(GA.decipher)
        State.decipherAt = Elapsed()
    end
    if TimedOut("DECIPHER") then
        if State.retries < DECIPHER_RETRIES then
            State.retries = State.retries + 1
            Log("解讀重試 " .. State.retries)
            return "DECIPHER"
        end
        return "ERROR"
    end
end

-- LOCATE：解讀後由 XivTreasureParty（設定「解碼後自動開地圖打旗標」）在藏寶點插旗；
-- 沒裝或沒開該選項時，等使用者手動插旗（FlagWait 秒）。上一張圖用過的旗標不算，避免拿舊旗標重跑
-- 旗標可以用：有旗標，而且不是上一張圖的舊旗標；或已等了 5 秒還在同一位置（新圖剛好在同一個藏寶點，
-- XivTreasureParty 看到藏寶點沒變不會重插，旗標本來就該在原處）
-- 旗標是不是新的：位置跟上一張圖挖過的旗標（State.lastFlag）不同才算
local function FlagIsNew()
    if not Api.IsFlagSet() then return false end
    local last = State.lastFlag
    return last == nil or Distance2D(Api.FlagPos(), last) > 1
end

-- 藏寶圖工具小幫手（XivTreasureParty）解讀後偶爾不打旗標：它只在偵測到新圖的那一刻打一次，
-- 遊戲當下沒接受也不會重試，重新載入插件才會再打。解讀後（或上一次重新載入後）FLAG_RELOAD_WAIT 秒
-- 還沒有新旗標，就用 Dalamud 的 /xldisableplugin、/xlenableplugin 重新載入它，每張圖最多 FLAG_RELOAD_MAX 次
local FLAG_PLUGIN      = "XivTreasureParty"
local FLAG_RELOAD_WAIT = 10
local FLAG_RELOAD_MAX  = 2
local FLAG_RELOAD_STEP = 20   -- 停用、啟用各最多等幾秒

-- 重新載入進行中就往下做一步，回傳 true（LOCATE 先不做別的事）；沒有在重新載入回傳 false
local function ReloadFlagPlugin()
    local r = State.flagReload
    if r == nil then return false end
    local loaded = Api.PluginLoaded(FLAG_PLUGIN)
    if r.phase == "disable" then
        if loaded == false then
            yield("/xlenableplugin " .. FLAG_PLUGIN)
            r.phase, r.at = "enable", Elapsed()
        elseif Elapsed() - r.at > FLAG_RELOAD_STEP then
            LogError("停用藏寶圖工具小幫手 " .. FLAG_RELOAD_STEP .. " 秒都沒反應，不再重新載入")
            State.flagReload, State.flagReloads, State.flagReloadDoneAt = nil, FLAG_RELOAD_MAX, Elapsed()
            return false
        end
        return true
    end
    if loaded == true then
        Log("藏寶圖工具小幫手已重新載入，等它打旗標")
        State.flagReload, State.flagReloadDoneAt, State.flagReloaded = nil, Elapsed(), true
        return false
    end
    if Elapsed() - r.at > FLAG_RELOAD_STEP then
        LogError("藏寶圖工具小幫手重新啟用 " .. FLAG_RELOAD_STEP .. " 秒還沒載入好，請到 /xlplugins 確認")
        State.flagReload, State.flagReloads, State.flagReloadDoneAt = nil, FLAG_RELOAD_MAX, Elapsed()
        return false
    end
    return true
end

function Handlers.LOCATE()
    if ReloadFlagPlugin() then return nil end
    local zoneOk = Api.IsFlagSet() and G14_ZONES[Api.FlagTerritory()]
    -- 插件重新載入後會打開地圖打旗標：地圖又開了就算新旗標（又抽到同一個藏寶點時，位置跟上一張一樣）
    if zoneOk and (FlagIsNew() or State.flagReloaded and Api.AddonReady("AreaMap")) then
        Api.CloseAddon("AreaMap")
        return "TRAVEL"
    end
    if not State.sent then
        Log("等待藏寶點旗標（曉月 5 區之一）：XivTreasureParty 會自動打，或請手動插旗")
        State.sent = true
    end
    -- 還沒有新旗標：藏寶圖工具小幫手有載入就重新載入它，讓它再打一次
    local plugin = Api.PluginLoaded(FLAG_PLUGIN)
    local reloads = State.flagReloads or 0
    local since = Elapsed() - (State.flagReloadDoneAt or 0)
    if plugin == true and reloads < FLAG_RELOAD_MAX and since > FLAG_RELOAD_WAIT then
        State.flagReloads = reloads + 1
        local now = not Api.IsFlagSet() and "沒有旗標" or zoneOk and "旗標還在上一張圖的位置" or "旗標不在這張圖的地區"
        Log(string.format("%.0f 秒還沒有新的藏寶點旗標（%s），重新載入藏寶圖工具小幫手（第 %d/%d 次）",
            since, now, State.flagReloads, FLAG_RELOAD_MAX))
        Api.CloseAddon("AreaMap")   -- 先關地圖：重新載入後地圖再打開，就知道插件打了旗標
        yield("/xldisableplugin " .. FLAG_PLUGIN)
        State.flagReload = { phase = "disable", at = Elapsed() }
        return nil
    end
    -- 重新載入都試過（或沒有這個插件）之後：
    --   旗標還在上一張圖的位置 → 這張圖剛好又抽到同一個藏寶點，照走
    --   等滿 FlagWait 秒（重新載入完之後至少再等 FLAG_RELOAD_WAIT 秒）還是沒有 → 報錯
    if plugin == true and reloads < FLAG_RELOAD_MAX then return nil end
    if since <= FLAG_RELOAD_WAIT and plugin ~= nil then return nil end
    if zoneOk and Elapsed() > 5 then
        Log("旗標跟上一張圖同一個位置，當成又抽到同一個藏寶點")
        Api.CloseAddon("AreaMap")
        return "TRAVEL"
    end
    if Elapsed() > Cfg.FlagWait then
        local ok, info = pcall(function()
            return string.format("有旗標：%s，旗標地區：%s，目前地區：%s",
                tostring(Api.IsFlagSet()), tostring(Api.FlagTerritory()), tostring(Api.Territory()))
        end)
        LogError("等不到藏寶點旗標（" .. (ok and info or tostring(info)) .. "）")
        return "ERROR"
    end
end

-- 旗標只有平面座標（X、Z），沒有高度。在 TREASURE_SPOTS 裡找跟旗標同地區、平面距離最近（30 以內）的藏寶點，
-- 用它的真正座標（含高度）導航；找不到才退回用 vnavmesh 從旗標往下找地面
local function MatchSpot()
    local f, territory = Api.FlagPos(), Api.FlagTerritory()
    local best, bestDist = nil, 30 * 30
    for _, s in ipairs(TREASURE_SPOTS) do
        if s[1] == territory then
            local dx, dz = s[2] - f.X, s[4] - f.Z
            local d = dx * dx + dz * dz
            if d < bestDist then best, bestDist = s, d end
        end
    end
    if best == nil then return nil end
    return Vector3(best[2], best[3], best[4])
end

local function FlagTarget()
    local spot = MatchSpot()
    if spot ~= nil then return Vector3(spot.X, spot.Y + 0.5, spot.Z) end
    local f = Api.FlagPos()
    local floor = Api.PointOnFloor(f.X, f.Z)
    if floor ~= nil then return Vector3(floor.X, floor.Y + 1, floor.Z) end
    return Vector3(f.X, Api.PlayerPos().Y, f.Z)
end

local function FlyToFlag()
    local target = FlagTarget()
    if not State.spotLogged then
        Log(MatchSpot() ~= nil and string.format("藏寶點座標 (%.1f, %.1f, %.1f)", target.X, target.Y, target.Z)
            or "對不到內建的藏寶點座標，改用旗標位置")
        State.spotLogged = true
    end
    Api.NavMoveTo(target, true)
end

function Handlers.TRAVEL()
    if Busy() then return nil end

    -- 旗標在哪個地區就傳送到那個地區的大水晶（名稱從遊戲資料取）
    local target = Api.FlagTerritory()
    if Api.Territory() ~= target then
        if not State.teleportSent then
            local dest = Api.ResolveAetheryte("", target)
            if dest == nil then return "ERROR" end
            Api.Teleport(dest)
            State.teleportSent = true
        end
        return nil
    end
    State.teleportSent = false

    -- 已在藏寶地區：開啟 Wrath（買圖、傳送期間是關的）
    if not State.wrathOn then
        Api.WrathOn()
        State.wrathOn = true
        Log("已到藏寶地區，開啟自動輸出")
    end

    -- 到達判斷用藏寶點真正座標（對不到才用旗標）
    local flag = MatchSpot() or Api.FlagPos()
    if Distance2D(Api.PlayerPos(), flag) < Cfg.DigRadius and not Api.NavRunning() then
        State.digOffsetIdx = 0
        return "DIG"
    end

    if not Api.NavReady() then return nil end

    -- 接近旗標（WalkRadius 以內）就下坐騎改走路：飛行停點不準，會在旗標附近一直繞。
    -- 走路最多重試 3 次，還到不了正中心就原地開挖（挖不到時 DIG 會繞旗標換位置）
    if Distance2D(Api.PlayerPos(), flag) < Cfg.WalkRadius then
        if State.travelPhase ~= "walk" then
            Api.NavStop()
            if not Dismount() then return nil end
            State.travelPhase, State.walkTries = "walk", 0
            Log("接近藏寶點，下坐騎走過去")
        end
        if not Api.NavRunning() then
            State.walkTries = State.walkTries + 1
            if State.walkTries > 3 then
                Log("走不到旗標正中心，就在這裡挖")
                State.digOffsetIdx = 0
                return "DIG"
            end
            local f = Api.FlagPos()
            Api.NavMoveTo(MatchSpot() or Api.PointOnFloor(f.X, f.Z) or Vector3(f.X, Api.PlayerPos().Y, f.Z), false)
            yield("/wait 0.5")
        end
        if TimedOut("TRAVEL") then return "ERROR" end
        return nil
    end

    if not Api.NavRunning() then
        -- 傳送後先確認角色可操作、已上坐騎，才開始飛（沒上坐騎時飛行路線不會動）
        if not Api.PlayerReady() then return nil end
        if not Mount() then return nil end
        FlyToFlag()
        return nil
    end

    if CheckStuck(FlyToFlag) == "stuck" then return "ERROR" end
    if TimedOut("TRAVEL") then return "ERROR" end
end

local DIG_OFFSETS = { { 0, 0 }, { DIG_OFFSET, 0 }, { 0, DIG_OFFSET }, { -DIG_OFFSET, 0 } }

function Handlers.DIG()
    if Api.GetEntity(Cfg.ChestName) ~= nil then return "OPEN_COFFER" end
    if Busy() or Api.NavRunning() then return nil end

    if not State.digSent then
        Dismount()
        Api.GeneralAction(GA.dig)
        State.digSent = true
        return nil
    end

    if TimedOut("DIG") then
        State.digSent = false
        State.digOffsetIdx = State.digOffsetIdx + 1
        if State.digOffsetIdx > DIG_RETRIES then return "ERROR" end
        local f, o = Api.FlagPos(), DIG_OFFSETS[State.digOffsetIdx + 1]
        Log("沒挖到，偏移再挖 " .. State.digOffsetIdx)
        local x, z = f.X + o[1], f.Z + o[2]
        local floor = Api.PointOnFloor(x, z)
        Api.NavMoveTo(floor or Vector3(x, Api.PlayerPos().Y, z), false)
        return "DIG"
    end
end

function Handlers.OPEN_COFFER()
    if Api.Condition(Cond.inCombat) then
        State.deciphered = false   -- 觸發陷阱時地圖已消耗
        State.lastFlag = Api.FlagPos()
        State.cofferPos = Api.PlayerPos()
        return "FIELD_COMBAT"
    end
    if Api.Condition(Cond.occupiedInEvent) then return nil end
    ApproachAndInteract(Cfg.ChestName)
    Api.ConfirmYes()
    if TimedOut("OPEN_COFFER") then return "ERROR" end
end

-- 戰鬥中：解除對寶箱的選取（選著寶箱 Wrath 不會自動選怪），交給 Wrath 打；
-- 戰鬥結束後由 LOOT / DUNGEON_LOOT 重新選寶箱互動
-- 野外戰鬥不要離寶箱太遠（太遠陷阱戰鬥會被重置）：離觸發陷阱的位置超過 LeashRadius 就走回去
local function StayNearCoffer()
    local anchor = State.cofferPos
    if anchor == nil or InDuty() then return end
    if Distance2D(Api.PlayerPos(), anchor) <= Cfg.LeashRadius then
        if State.leashing then
            Api.NavStop()
            State.leashing = false
        end
        return
    end
    if not Api.NavRunning() then
        if not State.leashing and os.clock() - (State.leashLogAt or -100) > 10 then
            Log("離寶箱太遠，走回去")
            State.leashLogAt = os.clock()
        end
        Api.NavMoveTo(Api.PointOnFloor(anchor.X, anchor.Z) or anchor, false)
        State.leashing = true
    end
end

local function CombatTick()
    local t = Entity.Target
    if t ~= nil and (t.Name == Cfg.ChestName or t.Name == Cfg.DungeonChestName) then
        Api.ClearTarget()
    end
    Api.ResumeAi()   -- 走路時暫時關掉的閃避 AI，進入戰鬥就打開
    -- 不主動選目標：選目標全部交給 RSR / Wrath（腳本先鎖定會跟 RSR 衝突）
    if not State.wrathOn then
        Api.NavStop()
        Api.WrathOn()
    end
    -- 喝藥交給 RSR（它有自動吃藥），腳本不處理
end

local function LeaveCombat()
    Api.WrathOff()
end

-- 寶物庫開戰：選取最近的敵人，用飛斧（戰士的遠程技能，射程 20）先打一下開怪，之後交給自動輸出打完。
-- 敵人比 TOMAHAWK_RANGE 遠就先走近。用遊戲原生的 /ac 技能名（名稱從遊戲資料取），不經過 SND 的列舉參數。
-- 打中（進入戰鬥）、丟滿 TOMAHAWK_TRIES 次、或試了 TOMAHAWK_GIVE_UP 秒，就回傳 true（開怪結束）
local TOMAHAWK_ACTION_ID = 46   -- 飛斧（Action 表，取自 XIVAPI）
local TOMAHAWK_RANGE     = 5    -- G14：先走到怪物旁再選取、丟飛斧（使用者指定；飛斧射程 20）
local TOMAHAWK_TRIES     = 3
local TOMAHAWK_GIVE_UP   = 25   -- 含走到怪物旁的時間
local PULL_STALL         = 3    -- 走向怪物時幾秒沒前進就改成直線走過去
local TOMAHAWK_NAME      = nil

local function PullWithTomahawk(enemy)
    State.pullStart = State.pullStart or Elapsed()
    if Elapsed() - State.pullStart > TOMAHAWK_GIVE_UP then return true end
    if State.pullAt ~= nil then
        if Elapsed() - State.pullAt < 2.5 then return false end   -- 等技能放出去（GCD）
        if Api.Condition(Cond.inCombat) or State.pullTries >= TOMAHAWK_TRIES then return true end
    end
    local me = Api.PlayerPos()
    local dist = Distance2D(me, enemy.Position)
    State.pullLastDist, State.pullLastName = dist, tostring(enemy.Name.TextValue)
    if dist > TOMAHAWK_RANGE then
        -- 先走到怪物附近：導航走過去；PULL_STALL 秒沒前進（被擋住、路徑算不出來）就改成直線走過去
        if not State.pullApproachLogged then
            Log(string.format("走向「%s」（距離 %.0f）", State.pullLastName, dist))
            State.pullApproachLogged = true
        end
        if State.pullMoveAt == nil or Distance2D(me, State.pullMovePos) > 0.3 then
            State.pullMovePos, State.pullMoveAt = me, Elapsed()
        end
        if Elapsed() - State.pullMoveAt >= PULL_STALL then
            if not State.pullStallLogged then
                Log(string.format("走向「%s」卡在 %.0f 外（導航%s），改成直線走過去", State.pullLastName, dist,
                    Api.NavRunning() and "中" or "已停"))
                State.pullStallLogged = true
            end
            Api.NavStop()
            Api.MoveStraight(enemy.Position)
            State.pullMoveAt = Elapsed()
        elseif not Api.NavRunning() then
            Api.VaultMoveTo(enemy.Position.X, enemy.Position.Y, enemy.Position.Z)
        end
        return false
    end
    Api.NavStop()
    if not pcall(function() Svc.Targets.Target = enemy end) then return true end   -- 選不到就交給自動輸出
    if TOMAHAWK_NAME == nil then
        local ok, name = pcall(function() return tostring(Excel.GetRow("Action", TOMAHAWK_ACTION_ID).Name) end)
        TOMAHAWK_NAME = (ok and name ~= nil and name ~= "" and name ~= "nil") and name or "飛斧"
    end
    yield("/ac " .. TOMAHAWK_NAME)
    State.pullAt, State.pullTries = Elapsed(), State.pullTries + 1
    Log(string.format("選取「%s」，丟%s（距離 %.0f）", tostring(enemy.Name.TextValue), TOMAHAWK_NAME, dist))
    return false
end

-- 寶物庫裡的敵人（掃描，不選取）
local function FindVaultEnemy()
    return Api.NearestEnemyObject(Cfg.EnemySearchRange)
end

-- 離開用的傳送門：先找設定的 ExitPortalName，找不到再找「退出點」（實測第 5 層的名稱）。
-- SND 把新內容貼進舊腳本時會保留舊設定值（以前預設「傳送魔紋」），所以兩個都找
local EXIT_POINT_NAME = "退出點"
local function FindExitPortal()
    for _, name in ipairs({ Cfg.ExitPortalName, EXIT_POINT_NAME }) do
        if name ~= nil and name ~= "" and Api.GetEntity(name) ~= nil then return name end
    end
    return nil
end

-- 野外戰鬥結束：聊天出現「將陷阱引來的魔物全部打倒了！」（OnChatMessage 標記）就去開寶箱。
-- 野外不主動找敵人，選目標交給 RSR / Wrath。打完又被旁邊的怪纏上，由 FIELD_FIGHT 先打完再回來。
-- 保險：萬一沒收到訊息，脫離戰鬥滿 10 秒也算結束（同樣不索敵）
local function FieldCombatDone(reason)
    State.fieldCleared = false
    Log(reason .. "（等 " .. Cfg.FieldLootDelay .. " 秒）")
    LeaveCombat()
    Api.ClearTarget()
    yield("/wait " .. Cfg.FieldLootDelay)
    if Api.GetEntity(Cfg.ChestName) == nil and Api.GetEntity(Cfg.PortalName) == nil then
        Log("寶箱已消失（可能超過戰鬥時限）")
        return "CHECK_MAP"
    end
    return "LOOT"
end

function Handlers.FIELD_COMBAT()
    if Api.Condition(Cond.dead) then LeaveCombat(); return "DEAD" end
    if State.fieldCleared then return FieldCombatDone("陷阱魔物全部打倒，去開寶箱") end
    if Api.Condition(Cond.inCombat) then
        State.lastInCombat = Elapsed()
        StayNearCoffer()
        CombatTick()
        return nil
    end
    if Elapsed() - (State.lastInCombat or 0) < 10 then return nil end
    return FieldCombatDone("脫離戰鬥 10 秒（沒收到打倒訊息），去開寶箱")
end

-- 領獎：可能有多個寶箱，還有可互動的寶箱就一個一個開，全部開完才看有沒有傳送魔紋。
-- 開寶箱前就先出怪的情況，打完後互動寶箱會跳確認框，要按「是」才會打開
function Handlers.LOOT()
    local chest = Api.GetEntity(Cfg.ChestName)
    local portal = Api.GetEntity(Cfg.PortalName)
    if chest == nil then
        State.mapsDone = State.mapsDone + 1
        State.errors = 0
        Log("完成第 " .. State.mapsDone .. " 張")
        return "PORTAL_CHECK"
    end
    -- 按「是」之後等 3 秒讓寶箱打開，不要馬上又互動（會再跳確認框、打斷開箱）
    if Api.ConfirmYes() then
        State.lastClick = Elapsed()
        return nil
    end
    if State.lastClick ~= nil and Elapsed() - State.lastClick < 3 then return nil end
    if Api.Condition(Cond.occupiedInEvent) then return nil end
    ApproachAndInteract(Cfg.ChestName)
    if TimedOut("LOOT") then
        if portal ~= nil then return "PORTAL_CHECK" end
        return "ERROR"
    end
end

function Handlers.PORTAL_CHECK()
    if Api.GetEntity(Cfg.PortalName) ~= nil then
        if Cfg.EnterDungeon then
            Log("出現傳送魔紋，前往互動")
            return "ENTER_DUNGEON"
        end
        Log("出現傳送門，但 EnterDungeon = false")
        return "CHECK_MAP"
    end
    if TimedOut("PORTAL_CHECK") then return "CHECK_MAP" end
end

function Handlers.ENTER_DUNGEON()
    if InDuty() then
        State.dungeonRuns = State.dungeonRuns + 1
        return "DUNGEON_INIT"
    end
    if Busy() then return nil end
    if Api.ConfirmYes() then return nil end
    if not Api.Condition(Cond.occupiedInEvent) then
        ApproachAndInteract(Cfg.PortalName)
    end
    if TimedOut("ENTER_DUNGEON") then return "ERROR" end
end

function Handlers.DEAD()
    Api.WrathOff()
    if not Api.Condition(Cond.dead) and not Busy() then
        Log("已復活")
        return "CHECK_MAP"
    end
    -- 接受復活或返回：返回對話框也是 SelectYesno
    Api.ConfirmYes()
    if TimedOut("DEAD") then return "ERROR" end
end

---------------------------------------------------------------- 野外被怪物纏上時

-- 這些步驟本來不該有戰鬥；野外被攻擊（陷阱打完後引到旁邊的怪、挖寶途中被攻擊）時先切到 FIELD_FIGHT 打完再回來
local INTERRUPTIBLE = {
    CHECK_MAP = true, DECIPHER = true, LOCATE = true, TRAVEL = true, DIG = true,
    LOOT = true, PORTAL_CHECK = true, ENTER_DUNGEON = true,
}

-- 先打完周圍的怪：下坐騎、開自動輸出（選目標交給 RSR / Wrath）；脫離戰鬥滿 3 秒就回到被打斷的步驟
function Handlers.FIELD_FIGHT()
    if Api.Condition(Cond.dead) then LeaveCombat(); return "DEAD" end
    if Api.Condition(Cond.inCombat) then
        State.lastInCombat = Elapsed()
        if Api.Condition(Cond.mounted) then Dismount() end
        StayNearCoffer()
        CombatTick()
        return nil
    end
    if Elapsed() - (State.lastInCombat or 0) < 3 then return nil end
    LeaveCombat()
    Api.ClearTarget()
    local resume = State.resumeState or "CHECK_MAP"
    State.resumeState = nil
    Log("周圍的怪物打完了，回到 " .. resume)
    return resume
end

---------------------------------------------------------------- 跨伺服器（每次買圖前）

-- 查 Universalis 選最便宜的伺服器；已經在那裡就直接買，查不到就留在目前伺服器
function Handlers.PICK_WORLD()
    EnsureWrathOff()
    State.worldChosen = true
    local ok, best, reason = pcall(Api.CheapestWorld, Cfg.MapItemId, State.badWorlds or {})
    if not ok then
        LogError("查價失敗：" .. tostring(best) .. "，留在目前伺服器買")
        return "CHECK_MAP"
    end
    if best == nil then
        Log(tostring(reason) .. "，留在目前伺服器買")
        return "CHECK_MAP"
    end
    local name = Api.WorldName(best.world) or tostring(best.world)
    Log(string.format("目前最便宜：%s，%d gil（Universalis）", name, best.price))
    if best.world == Api.CurrentWorldId() then return "CHECK_MAP" end
    State.targetWorld, State.targetWorldName = best.world, name
    return "WORLD_TRAVEL"
end

-- 換伺服器：Lifestream 要在大水晶旁才能換。一律先傳送到買圖城市的大水晶（落地就在旁邊），
-- 傳送完成後直接換伺服器，不走路（大水晶底座有實體，往中心走會卡住）
function Handlers.WORLD_TRAVEL()
    EnsureWrathOff()
    if Api.CurrentWorldId() == State.targetWorld and Api.PlayerReady() and not Api.LifestreamBusy() then
        Log("已到達 " .. State.targetWorldName)
        State.worldTrips = (State.worldTrips or 0) + 1
        return "CHECK_MAP"
    end
    if Busy() then return nil end

    if not State.sent then
        if not State.cityTeleportSent then
            if not Api.PlayerReady() then return nil end
            Api.NavStop()
            Dismount()
            local aetheryteId = Api.TerritoryAetheryteId(Cfg.MarketTerritoryId)
            local ok = aetheryteId ~= nil and Api.TeleportToAetheryte(aetheryteId)
            if not ok then
                local dest = Api.ResolveAetheryte(Cfg.MarketAetheryte, Cfg.MarketTerritoryId)
                if dest == nil then return "ERROR" end
                Api.Teleport(dest)
            end
            Log("傳送到買圖城市的大水晶")
            State.cityTeleportSent = true
            yield("/wait 3")
            return nil
        end
        if Api.Territory() ~= Cfg.MarketTerritoryId or not Api.PlayerReady() or Api.LifestreamBusy() then
            if TimedOut("WORLD_TRAVEL") then return "ERROR" end
            return nil
        end
        Log("在大水晶旁，換伺服器到 " .. State.targetWorldName)
        Api.Teleport(State.targetWorldName)
        State.sent = true
    end
    if TimedOut("WORLD_TRAVEL") then return "ERROR" end
end

---------------------------------------------------------------- 買圖子流程（市場板）
-- 【事前準備，必做】記得先在市場板把要買的地圖加入「我的最愛」，
-- 腳本會在我的最愛清單裡依名稱找到它並點開；沒加入的話買圖會卡在 MB_SEARCH。
-- 目標庫存：1 張已解讀 + 1 張未解讀（獨特物品，未解讀的不能疊）。
-- 流程：買 1 張 → 關市場板（MB_CLOSE）→ 解讀 → 再買 1 張 → 關市場板 → 出發挖寶

-- 到市場板：傳送到城市大水晶 → vnavmesh 走到 MarketX/Y/Z → 開市場板
function Handlers.MB_TRAVEL()
    EnsureWrathOff()
    if Busy() then return nil end

    if Api.Territory() ~= Cfg.MarketTerritoryId then
        if not State.sent then
            local dest = Api.ResolveAetheryte(Cfg.MarketAetheryte, Cfg.MarketTerritoryId)
            if dest == nil then
                LogError("查不到地區 " .. Cfg.MarketTerritoryId .. " 的以太之光，請填 MarketAetheryte")
                return "ERROR"
            end
            Api.NavStop()
            Api.Teleport(dest)
            State.sent = true
        end
        if TimedOut("MB_TRAVEL") then return "ERROR" end
        return nil
    end

    local spot = Vector3(Cfg.MarketX, Cfg.MarketY, Cfg.MarketZ)
    local moveToSpot = function() Api.NavMoveTo(spot, false) end
    if Distance2D(Api.PlayerPos(), spot) > 2 then
        if not Api.NavRunning() then
            Dismount()
            moveToSpot()
        end
        if CheckStuck(moveToSpot) == "stuck" then return "ERROR" end
        if TimedOut("MB_TRAVEL") then return "ERROR" end
        return nil
    end

    Api.NavStop()
    if Api.GetEntity(Cfg.MarketBoardName) == nil then
        LogError("已到市場板位置，但附近找不到「" .. Cfg.MarketBoardName .. "」")
        return "ERROR"
    end
    return "MB_OPEN"
end

function Handlers.MB_OPEN()
    if Api.AddonReady("ItemSearch") then return "MB_SEARCH" end
    -- 市場板離站位太遠時，ApproachAndInteract 會先走近再互動
    if not State.sent and not Api.Condition(Cond.occupiedInEvent) then
        State.sent = ApproachAndInteract(Cfg.MarketBoardName)
    end
    if TimedOut("MB_OPEN") then return "ERROR" end
end

-- 找地圖（每 4 秒一輪）：按「顯示我的最愛」→ 等清單出現 → 依名稱找到這張圖 → 點開上架清單（與 tools/MarketSearchTest.lua v1.0 實測成功的做法相同）。
-- 連續 FAVORITES_TRIES 次都不行才改用剪貼簿搜尋（最多 SEARCH_AUTO_TRIES 次），最後請使用者手動
local FAVORITES_TRIES = 3
local SEARCH_AUTO_TRIES = 2

function Handlers.MB_SEARCH()
    if Api.AddonReady("ItemSearchResult") then return "MB_LIST" end
    if Elapsed() - (State.lastSearch or -10) < 4 then return nil end
    State.lastSearch = Elapsed()

    local favTries = State.favTries or 0
    if Cfg.FavoritesCallback ~= "" and favTries < FAVORITES_TRIES then
        State.favTries = favTries + 1
        if Api.ShowFavorites() then
            local idx = Api.FindInResults(Cfg.MapItemName)
            if idx ~= nil then
                Log("我的最愛：點開「" .. Cfg.MapItemName .. "」（第 " .. idx .. " 項）")
                Api.MarketOpenResult(idx)
                return nil
            end
            Log("我的最愛清單裡找不到「" .. Cfg.MapItemName .. "」（第 " .. State.favTries .. " 次）")
        else
            Log("按「顯示我的最愛」後清單沒有出現（第 " .. State.favTries .. " 次）")
        end
        return nil
    end

    local tries = State.searchTries or 0
    if tries < SEARCH_AUTO_TRIES then
        local method = Api.TypeIntoSearch(Cfg.MapItemName)
        if method == nil then
            State.searchTries = SEARCH_AUTO_TRIES
        else
            State.searchTries = tries + 1
            Log("自動搜尋第 " .. State.searchTries .. " 次（剪貼簿：" .. method .. "）")
        end
        local idx = Api.FindInResults(Cfg.MapItemName)
        if idx ~= nil then Api.MarketOpenResult(idx) end
        return nil
    end

    if not State.manualPrompted then
        Log("找不到「" .. Cfg.MapItemName .. "」，請確認已加入市場板的我的最愛，並手動點開它，腳本會接著自動購買")
        State.manualPrompted = true
    end
    if TimedOut("MB_SEARCH") then return "ERROR" end
end

function Handlers.MB_LIST()
    local price, count = Api.MarketFirstListing()
    if price == nil then
        if TimedOut("MB_LIST") then return "ERROR" end
        return nil
    end
    if price == false then
        LogError("市場板上沒有這張地圖")
        return "MB_FAIL"
    end
    if count > 1 then
        LogError("最便宜一筆是 " .. count .. " 張一起賣，地圖是獨特物品無法一次買多張")
        return "MB_FAIL"
    end
    if price > Cfg.MaxMapPrice then
        LogError(string.format("最便宜一張 %d gil，超過 MaxMapPrice %d", price, Cfg.MaxMapPrice))
        return "MB_FAIL"
    end
    if Api.Gil() - price * count < Cfg.GilFloor then
        LogError("gil 不足（會低於 GilFloor）")
        return "MB_FAIL"
    end
    State.mapCountBefore = Api.ItemCount(Cfg.MapItemId)
    State.gilBefore = Api.Gil()
    State.buyPrice = price * count
    Log(string.format("購買 %d 張，單價 %d gil", count, price))
    Api.MarketBuyFirstListing()
    return "MB_BUY"
end

function Handlers.MB_BUY()
    if Api.ItemCount(Cfg.MapItemId) > State.mapCountBefore then
        State.mapsBought = (State.mapsBought or 0) + Api.ItemCount(Cfg.MapItemId) - State.mapCountBefore
        State.gilSpent = (State.gilSpent or 0) + State.buyPrice
        -- 下一張圖要重新比價
        State.worldChosen = false
        State.badWorlds = {}
        -- 每次只買 1 張：買完一定先關市場板，解讀需要在市場板關閉後才能進行
        return "MB_CLOSE"
    end
    -- 付了錢但這張圖沒增加 = 買到別的東西，立刻停止，避免繼續亂買
    if Api.Gil() < State.gilBefore and Elapsed() > 3 then
        LogError("付了 gil 但 " .. Cfg.MapItemName .. " 沒有增加，可能買錯物品，停止腳本")
        CloseMarket()
        return "END"
    end
    if Api.ConfirmYes() then return nil end
    if TimedOut("MB_BUY") then return "ERROR" end
end

-- 關掉市場視窗後才能解讀；確認全部關閉再回 CHECK_MAP
function Handlers.MB_CLOSE()
    if MarketOpen() then
        CloseMarket()
        if TimedOut("MB_CLOSE") then return "ERROR" end
        return nil
    end
    if Api.Condition(Cond.occupiedInEvent) then return nil end
    yield("/wait 1")
    return "CHECK_MAP"
end

-- 買不到（沒貨、太貴、gil 不足）：身上還有可用的圖就先去挖，否則結束
function Handlers.MB_FAIL()
    CloseMarket()
    -- 跨伺服器時：這個伺服器買不到（Universalis 資料過期、被買走），排除後換下一個最便宜的伺服器
    local here = Api.CurrentWorldId()
    if Cfg.CrossWorld and State.roundBuying and here ~= nil then
        State.badWorlds = State.badWorlds or {}
        if not State.badWorlds[here] then
            State.badWorlds[here] = true
            State.worldChosen = false
            Log("這個伺服器買不到，改找下一個最便宜的伺服器")
            return "CHECK_MAP"
        end
    end
    State.buyBlocked = true
    State.roundBuying = false
    if Api.HasDecipheredMap() or Api.ItemCount(Cfg.MapItemId) > 0 then return "CHECK_MAP" end
    return "END"
end

---------------------------------------------------------------- 寶物庫：驚奇百寶城（選門型，流程同 G12 的選門型）
-- 每一層：
--   DUNGEON_CHEST     跑到寶箱（入口離寶箱有一段距離）並互動，看反應：出怪 → 戰鬥；強欲陷阱或直接打開 → DUNGEON_LOOT
--   DUNGEON_COMBAT    不選取目標，交給 RSR / Wrath 打，BossMod AI 閃避
--   DUNGEON_LOOT      等寶箱自動打開（寶物庫的寶箱不用互動）、處理強欲陷阱
--   第 1～4 層：
--     DUNGEON_DOOR      兩扇「寶物庫的門」選一扇：有「右側／左側的門發光了！」時只剩一扇可互動，選那扇；沒有就隨機
--     DUNGEON_DOOR_WAIT 等開門（或關門）動畫結束
--     DUNGEON_PASSAGE   走進打開的門，踩上門後的傳送法陣（不能互動）到下一層
--   第 5 層：DUNGEON_EXIT 找離開用的傳送門（退出點）
-- 選錯門被移出寶物庫時，任何一步發現不在寶物庫就轉 DUNGEON_EXIT

-- 場上所有「名稱相符且可選取」的物件（Dalamud 物件）
function Api.TargetableObjects(name)
    local list = {}
    if name == nil or name == "" then return list end
    pcall(function()
        local objs = Svc.Objects
        for i = 0, objs.Length - 1 do
            local o = objs[i]
            if o ~= nil and o.IsTargetable and o.Name.TextValue == name then table.insert(list, o) end
        end
    end)
    return list
end

-- 選取指定物件，太遠就先走過去，到了再互動（同 ApproachAndInteract，但對象是已經挑好的物件）
local function ApproachAndInteractObject(obj)
    if obj == nil or not pcall(function() Svc.Targets.Target = obj end) then return false end
    local t = Entity.Target
    if t == nil then return false end
    if t.DistanceTo ~= nil and t.DistanceTo > 3 then
        if not Api.NavRunning() then yield("/vnav movetarget") end
        return false
    end
    Api.NavStop()
    Api.WrathOff()   -- 互動保護
    if not Dismount() then return false end
    Api.InteractTarget()
    return true
end

function Handlers.DUNGEON_INIT()
    if Api.Condition(Cond.betweenAreas) then
        if TimedOut("DUNGEON_INIT") then return "ERROR" end
        return nil
    end
    State.stage = 1
    State.floorChestPos = nil
    -- 上一趟寶物庫可能在選完門、還沒到下一層前就結束（報錯、被移出），選門記錄會留著：新的寶物庫一定要清掉
    State.doorPos, State.doorObj, State.doorFrom, State.doorHint = nil, nil, nil, nil
    State.doorTries, State.doorOpened, State.doorMoveAt = 0, false, nil
    State.passAnim, State.passAnimEnd, State.passAnimAt, State.passMovePos, State.passMoveAt = false, nil, nil, nil, nil
    -- 進寶物庫就開自動輸出和閃避，一直開到離開寶物庫（寶物庫內一般的關閉呼叫都會跳過，見 Api.WrathOff）
    Api.WrathOn()
    Log("進入寶物庫，開啟自動輸出與閃避")
    Log("驚奇百寶城（The Excitatron 6000）")
    State.entryCircleDone = false
    return "DUNGEON_ENTRY"
end

-- 跑到這一層的寶箱並互動（ApproachAndInteract 會先用 vnavmesh 走過去），再看寶箱的反應：
--   出怪（進入戰鬥或掃到敵人）→ DUNGEON_COMBAT；強欲陷阱 → DUNGEON_LOOT；寶箱直接打開 → DUNGEON_LOOT
--   沒反應 → 再互動，最多 CHEST_INTERACT_TRIES 次；這層找不到寶箱超過 CHEST_SEARCH_WAIT 秒 → 跳過，交給 DUNGEON_LOOT 收尾
-- 強欲陷阱要不要暫停：Big / Small 以外（Pause、舊設定值 Ignore、空白）都暫停
local function GamblePauses()
    return Cfg.GambleMode ~= "Big" and Cfg.GambleMode ~= "Small"
end

-- 強欲陷阱的視窗（「挑戰解除陷阱／不挑戰解除陷阱」）。名稱取自 FFXIVClientStructs（AgentId.TreasureHighLow，
-- 註解 Gambler's Lure）與 ECommons 的 AddonMaster.TreasureHighLow（按鈕 46 挑戰、47 不挑戰直接開箱）
local GAMBLE_WINDOW = "TreasureHighLow"

-- 強欲陷阱出現了沒：聊天「強欲陷阱發動了」，或強欲陷阱視窗開著
local function GambleDetected()
    if State.gambleActive then return true end
    if Api.AddonReady(GAMBLE_WINDOW) then
        State.gambleActive = true
        return true
    end
    return false
end

local VAULT_ENTRY_WAIT     = 10   -- 剛進寶物庫（第 1 層）可以操作後，先等幾秒才往寶箱走（實測要等）
local FLOOR_SETTLE         = 1.5  -- 第 2 層以後：進入這一層的動畫結束、可以操作後，再等幾秒才開始動
local CHEST_SEARCH_WAIT    = 15   -- 開始動之後找不到寶箱再等幾秒（樓層可能還在載入），之後跳過
local CHEST_FAR_RANGE      = 60   -- 還不能互動的寶箱在這個距離內，就先走到它旁邊
local CHEST_REACT_WAIT     = 8    -- 互動後等寶箱反應幾秒，還能互動就再互動一次
local CHEST_SETTLE         = 3    -- 寶箱不能互動後至少再等幾秒才轉去等怪（怪物出現可能有動畫）
local CHEST_INTERACT_TRIES = 3
local CHEST_INTERACT_RANGE = 2    -- 離寶箱中心多近才互動（原本 3 碼、/vnav movetarget 會停在互動距離外）
local CHEST_STALL          = 3    -- 走向寶箱時幾秒沒前進（被寶箱擋住）就直接互動
local CHEST_INTERACT_FAR   = 5    -- 卡住時離寶箱還超過這個距離：不互動（隔空互動不到），改用別的方法走近
local CHEST_STALLS_MAX     = 4

-- 名稱相符的物件裡最近的一個（不管能不能互動），回傳物件和平面距離。
-- 寶箱離入口有一段距離、還不能互動時（Api.GetEntity 只找可互動的），用它的位置先走過去
local function NearestNamedObject(name)
    local me = Api.PlayerPos()
    local best, bestDist = nil, math.huge
    local objs = Svc.Objects
    for i = 0, objs.Length - 1 do
        local o = objs[i]
        if o ~= nil and o.Name.TextValue == name then
            local dx, dz = o.Position.X - me.X, o.Position.Z - me.Z
            local d = dx * dx + dz * dz
            if d < bestDist then best, bestDist = o, d end
        end
    end
    if best == nil then return nil, nil end
    return best, math.sqrt(bestDist)
end

-- 一直走到寶箱旁邊，夠近了才互動：直接以寶箱座標為目的地（不用 /vnav movetarget，它會停在互動距離外）。
-- 走到 CHEST_INTERACT_RANGE 以內，或 CHEST_STALL 秒沒前進（被寶箱擋住）就選取並互動。回傳 true 表示已送出互動
-- 正在播不能操作的動畫（過場、事件）：用狀態旗標判斷。
-- 不用 Player.IsBusy：ECommons 的 IsBusy 在移動中、戰鬥中也是 true，舊的導航還在跑時會一直等不到
local CUTSCENE_FLAGS = { 31, 32, 33, 35, 58, 78 }   -- OccupiedInEvent / QuestEvent / Occupied33 / CutSceneEvent / WatchingCutscene(78)

local function InCutscene()
    for _, id in ipairs(CUTSCENE_FLAGS) do
        if Api.Condition(id) then return true end
    end
    return false
end

-- 角色面向的水平方向（Svc.Objects[0] 是自己；Rotation 0 = 面向 +Z，前方 = (sin, cos)）。讀不到回 nil
local function FacingDir()
    local ok, rot = pcall(function() return Svc.Objects[0].Rotation end)
    if ok and type(rot) == "number" then return { math.sin(rot), math.cos(rot) } end
    return nil
end

-- 看不到目標時，沿這一層進來時的面向往前找：每次多走 FORWARD_STEP，最多 FORWARD_MAX。走滿了回傳 false
local FORWARD_STEP = 8
local FORWARD_MAX  = 60
local function SearchForward(label)
    local from, dir = State.floorEntryPos, State.floorFacing
    if from == nil or dir == nil then return false end
    State.forwardDist = (State.forwardDist or 0) + FORWARD_STEP
    if State.forwardDist > FORWARD_MAX then return false end
    local x, z = from.X + dir[1] * State.forwardDist, from.Z + dir[2] * State.forwardDist
    Log("看不到" .. label .. "，往前走 " .. State.forwardDist .. " 碼找")
    Api.VaultMoveTo(x, from.Y, z)
    return true
end

local function ApproachChest(chest)
    local me, pos = Api.PlayerPos(), chest.Position
    local dist = Distance2D(me, pos)
    if State.chestMoveAt == nil or Distance2D(me, State.chestMovePos) > 0.3 then
        State.chestMovePos, State.chestMoveAt = me, Elapsed()
    end
    if dist > CHEST_INTERACT_RANGE and Elapsed() - State.chestMoveAt < CHEST_STALL then
        if not Api.NavRunning() then
            -- 重下導航指令不重設「沒前進」的計時：vnavmesh 一直停在同一點時，CHEST_STALL 秒後就換方法或互動
            Api.VaultMoveTo(pos.X, pos.Y, pos.Z)
        end
        return false
    end
    if dist > CHEST_INTERACT_FAR then
        -- 卡住了而且還很遠：依序換方法走近（直線走 → 暫時關閃避 AI → 從其他方向靠近），不隔空互動
        State.chestStalls = (State.chestStalls or 0) + 1
        local nav = Api.NavRunning() and "導航中" or "導航已停"
        Api.NavStop()
        if State.chestStalls == 1 then
            Log(string.format("走向寶箱卡在 %.1f 外（%s），改成直線走過去", dist, nav))
            Api.MoveStraight(pos)
        elseif State.chestStalls == 2 and State.vbmAiOn then
            Log(string.format("走向寶箱還是卡在 %.1f 外（%s），暫時關閉閃避 AI 再走（進入戰鬥時會打開）", dist, nav))
            Api.SuspendAi()
            Api.VaultMoveTo(pos.X, pos.Y, pos.Z)
        elseif State.chestStalls <= CHEST_STALLS_MAX then
            local a = State.chestStalls * math.pi / 2
            Log(string.format("走向寶箱卡在 %.1f 外（%s），改從寶箱的另一側靠近", dist, nav))
            Api.VaultMoveTo(pos.X + math.sin(a) * 3, pos.Y, pos.Z + math.cos(a) * 3)
        end
        State.chestMovePos, State.chestMoveAt = me, Elapsed()
        return false
    end
    Api.NavStop()
    if not Api.Target(Cfg.DungeonChestName) then return false end
    Api.WrathOff()   -- 互動保護
    if not Dismount() then return false end
    Log(string.format("到寶箱旁（距離 %.1f），互動", dist))
    Api.InteractTarget()
    return true
end

-- 驚奇百寶城第 1 層入口（使用者指定的流程）：
--   進入寶物庫後等 ENTRY_WAIT 秒 → 沿進來時的面向直線往前走（Path.MoveTo，不做路徑規劃）→ 一進入動畫就停下
--   → 動畫結束後才交給 DUNGEON_CHEST 找寶箱位置並導航
-- 「進入動畫」：過場／事件／讀取類的狀態旗標亮起，或往前走時角色 ENTRY_STALL 秒沒移動（被動畫鎖住）
-- 「動畫結束」：那些旗標都沒亮、而且角色可以操作（這時已經停止移動），維持 FLOOR_SETTLE 秒
local ENTRY_WAIT       = 20
local ENTRY_DISTANCE   = 80
local ENTRY_STALL      = 2
local ENTRY_LOCK_FLAGS = { 25, 31, 32, 33, 35, 45, 51, 58, 78 }   -- Occupied、事件、過場、BetweenAreas(51)、WatchingCutscene(78)

local function EntryLockFlags()
    local on = {}
    for _, id in ipairs(ENTRY_LOCK_FLAGS) do
        if Api.Condition(id) then table.insert(on, id) end
    end
    return on
end

function Handlers.DUNGEON_ENTRY()
    if not InDuty() then return "DUNGEON_EXIT" end

    -- 1. 進去後先等 ENTRY_WAIT 秒，再沿面向直線往前走
    if State.entryStart == nil then
        if Elapsed() < ENTRY_WAIT then
            if not State.entryWaitLogged then
                Log("進入驚奇百寶城，等 " .. ENTRY_WAIT .. " 秒後直線往前走")
                State.entryWaitLogged = true
            end
            return nil
        end
        local p, dir = Api.PlayerPos(), FacingDir()
        State.entryStart = { X = p.X, Y = p.Y, Z = p.Z }
        State.entryMovePos, State.entryMoveAt = p, Elapsed()
        if dir == nil then
            LogError("讀不到角色面向，請手動往前走到傳送法陣上")
        else
            Log(string.format("往前直走，直到進入動畫（面向 %.2f, %.2f）", dir[1], dir[2]))
            Api.MoveStraight({ X = p.X + dir[1] * ENTRY_DISTANCE, Y = p.Y, Z = p.Z + dir[2] * ENTRY_DISTANCE })
        end
        return nil
    end

    -- 2. 一進入動畫就停下
    if not State.entryCutscene then
        local flags, me = EntryLockFlags(), Api.PlayerPos()
        if Distance2D(me, State.entryMovePos) > 0.3 then State.entryMovePos, State.entryMoveAt = me, Elapsed() end
        local stalled = Elapsed() - State.entryMoveAt >= ENTRY_STALL
        if #flags > 0 or stalled then
            Api.NavStop()
            State.entryCutscene = true
            Log("進入動畫（" .. (#flags > 0 and ("狀態旗標 " .. table.concat(flags, ","))
                or ("角色 " .. ENTRY_STALL .. " 秒沒移動")) .. string.format("，往前走了 %.0f 碼），等動畫結束",
                Distance2D(me, State.entryStart)))
            return nil
        end
        if TimedOut("DUNGEON_ENTRY") then return "ERROR" end
        return nil
    end

    -- 3. 動畫結束（旗標都沒亮、角色可以操作，維持 FLOOR_SETTLE 秒）後才去找寶箱
    if #EntryLockFlags() > 0 or not Api.PlayerReady() then
        State.entryEndAt = nil
        if TimedOut("DUNGEON_ENTRY") then return "ERROR" end
        return nil
    end
    State.entryEndAt = State.entryEndAt or Elapsed()
    if Elapsed() - State.entryEndAt < FLOOR_SETTLE then return nil end
    State.entryCircleDone = true
    Log("動畫結束，找寶箱位置並導航")
    return "DUNGEON_CHEST"
end

function Handlers.DUNGEON_CHEST()
    if not InDuty() then return "DUNGEON_EXIT" end
    if Api.Condition(Cond.inCombat) then return "DUNGEON_COMBAT" end
    if GambleDetected() then
        Log("開寶箱觸發強欲陷阱")
        return GamblePauses() and "DUNGEON_GAMBLE" or "DUNGEON_LOOT"
    end

    -- 進入這一層會有一段不能操作的動畫：等動畫結束才開始（只等這一次），先停掉動畫前的導航、從新位置重新規劃路徑
    if State.floorReadyAt == nil then
        if InCutscene() or Api.Condition(Cond.betweenAreas) then return nil end
        Api.NavStop()   -- 動畫前的導航（往法陣、往門後走）作廢：傳送後位置變了，到了這裡重新規劃路徑
        State.floorReadyAt = Elapsed()
        local entry = Api.PlayerPos()
        State.floorEntryPos = { X = entry.X, Y = entry.Y, Z = entry.Z }   -- 這一層的入口（找不到門時用來估方向）
        State.floorFacing = FacingDir()                                     -- 這一層進來時的面向（看不到寶箱時往前找）
        if State.stage == 1 and not State.entryCircleDone then
            Log("進入寶物庫，等 " .. VAULT_ENTRY_WAIT .. " 秒再走去寶箱")
        else
            Log("第 " .. State.stage .. " 層：可以操作了，去找寶箱")
        end
    end
    local settle = (State.stage == 1 and not State.entryCircleDone) and VAULT_ENTRY_WAIT or FLOOR_SETTLE
    if Elapsed() - State.floorReadyAt < settle then return nil end
    if Api.ConfirmYes() then return nil end

    local chest = Api.GetEntity(Cfg.DungeonChestName)

    -- 還沒互動：寶箱離入口有一段距離，先走到寶箱旁邊再互動（可互動的用 ApproachChest；
    -- 還不能互動的就用它的位置走過去，到了旁邊變成可互動再互動）。
    -- 完全看不到寶箱：每層一定有寶箱和一場戰鬥，不能跳過；沿這一層進來時的面向往前找，找不到才報錯
    if State.chestInteractAt == nil then
        if chest == nil then
            local far, dist = NearestNamedObject(Cfg.DungeonChestName)
            if far ~= nil and dist > 3 and dist <= CHEST_FAR_RANGE then
                if not State.chestLogged then
                    Log(string.format("寶箱在 %.0f 外（還不能互動），先走到旁邊", dist))
                    State.chestLogged = true
                end
                if not Api.NavRunning() then
                    Api.VaultMoveTo(far.Position.X, far.Position.Y, far.Position.Z)
                end
                if TimedOut("DUNGEON_CHEST") then return "ERROR" end
                return nil
            end
            if not Api.NavRunning() and not SearchForward("「" .. Cfg.DungeonChestName .. "」") then
                LogError("往前找了 " .. FORWARD_MAX .. " 碼還是看不到「" .. Cfg.DungeonChestName .. "」（請確認 DungeonChestName）")
                return "ERROR"
            end
            if TimedOut("DUNGEON_CHEST") then return "ERROR" end
            return nil
        end
        if not State.chestLogged then
            Log(string.format("寶箱在 %.0f 外，走過去", Distance2D(Api.PlayerPos(), chest.Position)))
            State.chestLogged = true
        end
        if (State.chestStalls or 0) > CHEST_STALLS_MAX then
            LogError("走不到寶箱旁（換了 " .. CHEST_STALLS_MAX .. " 種方法都卡住）")
            return "ERROR"
        end
        if not Api.Condition(Cond.occupiedInEvent) and ApproachChest(chest) then
            -- 記下這一層寶箱的位置：走進門時用來分辨「看到的是下一層的寶箱」（不在 Transition 重置）
            State.floorChestPos = { X = chest.Position.X, Z = chest.Position.Z }
            State.chestInteractAt, State.chestTries = Elapsed(), State.chestTries + 1
        end
        if TimedOut("DUNGEON_CHEST") then return "ERROR" end
        return nil
    end

    -- 已互動：等寶箱的反應。怪物不一定會主動攻擊，每秒掃描一次（不選取目標）
    if Elapsed() - (State.lastEnemyScan or -10) > 1 then
        State.lastEnemyScan = Elapsed()
        if Api.NearestEnemyObject(Cfg.EnemySearchRange) ~= nil then
            Log("寶箱出怪，開打")
            Api.WrathOn()
            return "DUNGEON_COMBAT"
        end
    end
    if Api.Condition(Cond.occupiedInEvent) then return nil end
    local since = Elapsed() - State.chestInteractAt
    if chest == nil then
        if since < CHEST_SETTLE then return nil end
        -- 每層一定有一場戰鬥：寶箱已經觸發，怪物可能還在出現的動畫中，交給 DUNGEON_COMBAT 等怪
        Log("寶箱已觸發，等怪物出現")
        return "DUNGEON_COMBAT"
    end
    if since < CHEST_REACT_WAIT then return nil end
    if State.chestTries >= CHEST_INTERACT_TRIES then
        LogError("互動寶箱 " .. State.chestTries .. " 次都沒有反應")
        return "ERROR"
    end
    Log("寶箱沒有反應，再走近一點互動")
    State.chestInteractAt, State.chestMoveAt = nil, nil
end

-- 寶物庫戰鬥：等怪物出現（可能有動畫，最多 EnemyWait 秒），只掃描不選取，選目標交給 RSR / Wrath；
-- 脫離戰鬥滿 3 秒、EnemySearchRange 內掃描不到敵人才算打完；一次都沒看過敵人就等到 EnemyWait + 15 秒
function Handlers.DUNGEON_COMBAT()
    if Api.Condition(Cond.dead) then
        LeaveCombat()
        Log("寶物庫內陣亡，副本結束")
        return "DUNGEON_EXIT"
    end
    if not InDuty() then LeaveCombat(); return "DUNGEON_EXIT" end
    -- 等怪物出現（可能有動畫，G15 輪盤要 30 秒以上）：只掃描有沒有敵人、不選取目標，選目標交給 RSR；
    -- 進入戰鬥或看到敵人就開始，最多等 EnemyWait 秒
    if not State.combatTargeted then
        -- 開戰：看到可選取的敵人就選取、丟飛斧開怪，之後交給自動輸出打完
        local enemy = Api.NearestEnemyObject(Cfg.EnemySearchRange)
        if enemy ~= nil then
            State.enemySeen = true
            if PullWithTomahawk(enemy) then
                State.combatTargeted = true
                Log("開怪完成，交給自動輸出打")
            end
        elseif Api.Condition(Cond.inCombat) then
            -- 已經在打、但掃描不到敵人（例如頭目還不能選取）：直接交給自動輸出
            State.combatTargeted, State.enemySeen = true, true
            Log("已進入戰鬥，交給自動輸出打")
        elseif Elapsed() > Cfg.EnemyWait then
            State.combatTargeted = true
        end
        if not State.wrathOn then Api.WrathOn() end
        return nil
    end
    if Api.Condition(Cond.inCombat) then
        State.lastInCombat = Elapsed()
        CombatTick()
        return nil
    end
    if Elapsed() - (State.lastInCombat or 0) < 3 then return nil end
    if Api.AnyEnemyLeft(Cfg.EnemySearchRange) then
        State.enemySeen = true
        State.lastInCombat = Elapsed()
        if not State.wrathOn then Api.WrathOn() end
        return nil
    end
    if not State.enemySeen and Elapsed() < Cfg.EnemyWait + 15 then return nil end
    LeaveCombat()
    Api.ClearTarget()
    return "DUNGEON_LOOT"
end

-- 強欲陷阱：出現大／小兩顆魔法球。GambleMode = Big / Small 時互動那一顆（每一輪一次），Ignore 時不互動。
-- 魔法球消失滿 5 秒（或整體超過 120 秒）就算結束。回傳 true 表示還在進行中
local function HandleGamble()
    if not State.gambleActive then return false end
    State.gambleSince = State.gambleSince or Elapsed()
    local big, small = Api.GetEntity(Cfg.GambleBigName), Api.GetEntity(Cfg.GambleSmallName)
    if big ~= nil or small ~= nil then
        State.gambleGoneAt = nil
        if Cfg.GambleMode == "Big" or Cfg.GambleMode == "Small" then
            local name = Cfg.GambleMode == "Big" and Cfg.GambleBigName or Cfg.GambleSmallName
            if not State.gambleChosen and not Api.Condition(Cond.occupiedInEvent) then
                if ApproachAndInteract(name) then
                    State.gambleChosen = true
                    Log("強欲陷阱：選「" .. name .. "」")
                end
            end
            Api.ConfirmYes()
        elseif not State.gambleLogged then
            Log("強欲陷阱：GambleMode = Ignore，不互動，等它結束")
            State.gambleLogged = true
        end
    else
        State.gambleChosen = false   -- 魔法球消失：下一輪出現時可以再選
        State.gambleGoneAt = State.gambleGoneAt or Elapsed()
        if Elapsed() - State.gambleGoneAt >= 5 then
            State.gambleActive, State.gambleSince, State.gambleGoneAt, State.gambleLogged = false, nil, nil, false
            Log("強欲陷阱結束")
            return false
        end
    end
    if Elapsed() - State.gambleSince > 120 then
        State.gambleActive, State.gambleSince, State.gambleGoneAt, State.gambleLogged = false, nil, nil, false
        Log("強欲陷阱超過 120 秒，不再等")
        return false
    end
    return true
end

-- 寶物庫的寶箱打完怪會自動打開，不用互動：等寶箱打開（最多 VAULT_CHEST_WAIT 秒）、強欲陷阱（有的話）結束，
-- 之後 10 秒沒有新的寶箱才去選門（第 5 層則離開）
function Handlers.DUNGEON_LOOT()
    if not InDuty() then return "DUNGEON_EXIT" end
    if Api.Condition(Cond.inCombat) then return "DUNGEON_COMBAT" end   -- 開箱又觸發額外的怪
    if State.lastChestAt == nil then State.lastChestAt = Elapsed() end
    if GambleDetected() and GamblePauses() then return "DUNGEON_GAMBLE" end
    if HandleGamble() then
        State.lastChestAt = Elapsed()
        if TimedOut("DUNGEON_LOOT") then return "ERROR" end
        return nil
    end

    -- 第 5 層（最終區）：先打完怪，寶箱要自己走過去開（不會自動打開）。開了之後可能出現強欲陷阱（上面會處理）
    if State.stage >= MAX_STAGES then
        local chest = Api.GetEntity(Cfg.DungeonChestName)
        if chest ~= nil then
            if not Api.Condition(Cond.occupiedInEvent) and Elapsed() - (State.finalChestAt or -10) > CHEST_REACT_WAIT then
                if ApproachChest(chest) then
                    State.finalChestAt = Elapsed()
                    Log("第 5 層：打完怪，開寶箱")
                end
            end
            State.lastChestAt = Elapsed()
            if TimedOut("DUNGEON_LOOT") then return "ERROR" end
            return nil
        end
    end

    -- 第 1～4 層的寶箱打完怪會自動打開，不用互動：最多等 VAULT_CHEST_WAIT 秒讓它打開（變成不能互動），之後就算還能互動也不管
    if Api.GetEntity(Cfg.DungeonChestName) ~= nil and Elapsed() < VAULT_CHEST_WAIT then
        State.lastChestAt = Elapsed()
        return nil
    end
    if Api.Condition(Cond.occupiedInEvent) or Elapsed() - State.lastChestAt < 10 then return nil end

    Log("第 " .. State.stage .. " 層完成")
    if State.stage >= MAX_STAGES then return "DUNGEON_EXIT" end
    return "DUNGEON_DOOR"
end

-- 強欲陷阱診斷（GambleDiag = true 時，暫停期間自動跑；做法同 tools/GambleTest.lua v0.5）：找出寶箱上方立體卡牌的數字存在哪裡。
-- 每 GAMBLE_DIAG_INTERVAL 秒讀寶箱周圍物件的記憶體：EventState 0x70、BaseId 0x84、Visibility 0x97、TargetableStatus 0x9A，
-- EventObj 另讀 SharedTimelineState 0x1B2、Arg 0x1B4、Flags 0x1B8（FFXIVClientStructs EventObject，0x1C0），
-- 並比對整個結構的原始 bytes（略過距離、目標狀態等一直跳動的欄位），只印有變化的部分，1～9 標 ★。
-- 也印強欲陷阱視窗、確認框的變化和暫停期間的聊天訊息。不會按任何按鈕、不互動。
-- 讀記憶體用 Marshal.ReadByte(IntPtr.Add(位址, 位移))（NLua 1.7.9 實測；兩個參數的多載會讀到 .NET 物件本身）。
-- 只讀物件結構範圍內，第一次讀記憶體、第一次讀某個視窗前先印一行：萬一 SND 停掉，看最後一行就知道是哪一步
local GAMBLE_DIAG_INTERVAL = 1
local GAMBLE_DIAG_RANGE    = 15
local GAMBLE_DIAG_ADDONS   = { GAMBLE_WINDOW, "SelectYesno" }
local DIAG_SKIP = { [0x93] = true, [0x94] = true, [0x95] = true, [0x96] = true, [0x9B] = true }

local function DiagMark(s)
    s = tostring(s)
    if s:match("^%s*[1-9]%s*$") or s:match("[^%d][1-9][^%d]") or s:match("^[1-9][^%d]") or s:match("[^%d][1-9]$") then
        return "★" .. s
    end
    return s
end

local function DiagStar(v)
    if type(v) == "number" and v >= 1 and v <= 9 then return "★" .. v end
    return tostring(v)
end

-- /echo 走遊戲聊天框，一則最多 500 bytes（中文一字 3 bytes）：超過 400 bytes 就依 UTF-8 字元邊界切成多則
local function DiagEcho(msg)
    msg = "[G14][強欲] " .. msg
    while #msg > 0 do
        local cut = #msg
        if cut > 400 then
            cut = 400
            while cut > 0 and (msg:byte(cut + 1) or 0) >= 0x80 and (msg:byte(cut + 1) or 0) < 0xC0 do cut = cut - 1 end
        end
        yield("/echo " .. msg:sub(1, cut))
        msg = msg:sub(cut + 1)
        if #msg > 0 then msg = "[G14][強欲] …" .. msg end
    end
end

local function DiagAddon(name)
    local a = Addons.GetAddon(name)
    local values, texts = {}, {}
    local valueList, nodeList = Api.ToLuaList(a.AtkValues), Api.ToLuaList(a.Nodes)
    if valueList == nil and nodeList == nil then return "（讀不到這個視窗的數值和節點）" end
    for idx, v in ipairs(valueList or {}) do
        if idx > 300 then break end
        local ok, s = pcall(function() return tostring(v.ValueString) end)
        if ok and s ~= "" and s ~= "0" and s ~= "nil" and #values < 40 then table.insert(values, (idx - 1) .. "=" .. DiagMark(s)) end
    end
    for n, node in ipairs(nodeList or {}) do
        if n > 600 or #texts >= 40 then break end
        if EnumName(node.NodeType) == "Text" and node.IsVisible then
            local t = tostring(node.Text)
            if t ~= "" and t ~= "nil" then table.insert(texts, node.Id .. "=" .. DiagMark(t)) end
        end
    end
    return "數值：" .. (#values > 0 and table.concat(values, " ") or "無") .. " ｜文字：" .. (#texts > 0 and table.concat(texts, " ") or "無")
end

local DiagMarshal, DiagIntPtr = nil, nil
local function DiagRead(addr, ofs, size)
    DiagMarshal = DiagMarshal or luanet.import_type("System.Runtime.InteropServices.Marshal")
    DiagIntPtr = DiagIntPtr or luanet.import_type("System.IntPtr")
    local p = DiagIntPtr.Add(addr, ofs)
    if size == 1 then return DiagMarshal.ReadByte(p) end
    if size == 2 then
        local v = DiagMarshal.ReadInt16(p)
        return v < 0 and v + 65536 or v
    end
    local v = DiagMarshal.ReadInt32(p)
    return v < 0 and v + 4294967296 or v
end

-- 回傳 (欄位描述, 原始 bytes 表)
local function DiagReadObject(o)
    local addr = o.Address
    if addr == nil then return "（讀不到位址）", {} end
    if not State.diagMemNoted then
        DiagEcho("（第一次讀物件記憶體…）")
        State.diagMemNoted = true
    end
    local isEventObj = EnumName(o.ObjectKind) == "EventObj"
    local fields = string.format("EventState=%s BaseId=%d Visibility=%s Targetable=%s",
        DiagStar(DiagRead(addr, 0x70, 1)), DiagRead(addr, 0x84, 4), DiagStar(DiagRead(addr, 0x97, 1)), DiagStar(DiagRead(addr, 0x9A, 1)))
    if isEventObj then
        fields = fields .. string.format(" Timeline=%s Arg=%s Flags=%s",
            DiagStar(DiagRead(addr, 0x1B2, 2)), DiagStar(DiagRead(addr, 0x1B4, 4)), DiagStar(DiagRead(addr, 0x1B8, 1)))
    end
    local raw = {}
    for ofs = 0, (isEventObj and 0x1BF or 0x19F) do
        if not DIAG_SKIP[ofs] then raw[ofs] = DiagRead(addr, ofs, 1) end
    end
    return fields, raw
end

-- 寶箱周圍的物件（場景物件、寶箱）：{ [物件索引] = { label, fields, raw } }
local function DiagObjects()
    local objs = Svc.Objects
    local center = nil
    for i = 0, objs.Length - 1 do
        local o = objs[i]
        if o ~= nil and o.Name.TextValue == Cfg.DungeonChestName then center = o.Position; break end
    end
    center = center or Api.PlayerPos()
    local snap = {}
    for i = 0, objs.Length - 1 do
        local o = objs[i]
        if o ~= nil then
            local kind = EnumName(o.ObjectKind)
            if kind == "EventObj" or kind == "Treasure" then
                local dx, dz = o.Position.X - center.X, o.Position.Z - center.Z
                if math.sqrt(dx * dx + dz * dz) <= GAMBLE_DIAG_RANGE then
                    local ok, fields, raw = pcall(DiagReadObject, o)
                    if not ok then fields, raw = "（讀取失敗：" .. tostring(fields) .. "）", {} end
                    snap[i] = {
                        label = string.format("#%d「%s」%s (%.1f, %.1f)", i, o.Name.TextValue, kind, o.Position.X, o.Position.Z),
                        fields = fields, raw = raw,
                    }
                end
            end
        end
    end
    return snap
end

local function DiagRawDiff(old, new)
    local parts = {}
    for ofs, v in pairs(new) do
        if old[ofs] ~= nil and old[ofs] ~= v then
            table.insert(parts, { ofs, string.format("0x%X:%d→%s", ofs, old[ofs], DiagStar(v)) })
        end
    end
    table.sort(parts, function(a, b) return a[1] < b[1] end)
    local out = {}
    for k = 1, math.min(#parts, 16) do out[k] = parts[k][2] end
    if #parts > 16 then table.insert(out, "…共 " .. #parts .. " 處") end
    return table.concat(out, " ")
end

local function GambleDiagTick()
    if not Cfg.GambleDiag then return end
    if Elapsed() - (State.diagAt or -10) < GAMBLE_DIAG_INTERVAL then return end
    State.diagAt = Elapsed()
    -- 視窗：強欲陷阱視窗、確認框
    local win = {}
    for _, name in ipairs(GAMBLE_DIAG_ADDONS) do
        local a = Addons.GetAddon(name)
        if a.Exists and a.Ready then
            if not State.diagSeen[name] then
                DiagEcho("（讀取視窗 " .. name .. "…）")
                State.diagSeen[name] = true
            end
            win[name] = DiagAddon(name)
        end
    end
    local oldWin = State.diagWin or {}
    for k, v in pairs(win) do
        if oldWin[k] ~= v then DiagEcho(string.format("%.0f秒 視窗 %s %s", Elapsed(), k, v)) end
    end
    for k in pairs(oldWin) do
        if win[k] == nil then DiagEcho(string.format("%.0f秒 視窗 %s 關閉", Elapsed(), k)) end
    end
    State.diagWin = win
    -- 寶箱周圍物件的記憶體
    local cur, prev = DiagObjects(), State.diagSnap
    for k, v in pairs(cur) do
        local p = prev[k]
        if p == nil then
            DiagEcho(string.format("%.0f秒 + %s %s", Elapsed(), v.label, v.fields))
        else
            if p.fields ~= v.fields then DiagEcho(string.format("%.0f秒 ~ %s %s", Elapsed(), v.label, v.fields)) end
            local diff = DiagRawDiff(p.raw, v.raw)
            if diff ~= "" then DiagEcho(string.format("%.0f秒   %s 原始變化：%s", Elapsed(), v.label, diff)) end
        end
    end
    for k, p in pairs(prev) do
        if cur[k] == nil then DiagEcho(string.format("%.0f秒 - %s", Elapsed(), p.label)) end
    end
    State.diagSnap = cur
    -- 暫停期間收到的聊天訊息（OnChatMessage 只收集）
    while State.diagChatShown < #State.gambleChat do
        State.diagChatShown = State.diagChatShown + 1
        DiagEcho("聊天：" .. DiagMark(State.gambleChat[State.diagChatShown]))
    end
end

-- 強欲陷阱暫停（GambleMode = Pause；舊設定值 Ignore 也算）：停止移動（自動輸出和閃避在寶物庫內維持開著），不互動、不計逾時，讓你自己選大／小或做測試。
-- 繼續：強欲陷阱視窗或大／小魔法球出現過、之後都消失滿 5 秒；或在聊天框輸入 /echo #繼續。之後回到 DUNGEON_LOOT（開殘留寶箱 → 選門）
-- G14：遇到強欲陷阱一律放棄（看不到卡牌數字，猜不了）＝按「不挑戰解除陷阱」直接開箱，不管 GambleMode。
-- callback 參數取自 McVaxius/LootGoblin（國際版插件實際觀察；繁中版尚未驗證）：不挑戰／收手 = TreasureHighLow true 1，
-- 點「不挑戰」時遊戲送出的是 false -2 → true 1。依序試：true 1 → (false -2, true 1) → true 1，每次間隔 GAMBLE_DECLINE_GAP 秒。
-- 保險（改回暫停讓你手動處理）：試完視窗還在；大／小魔法球變成可互動（表示按成挑戰了）；只有聊天訊息、視窗 GAMBLE_WINDOW_WAIT 秒都沒出現
local GAMBLE_DECLINE_GAP  = 2
local GAMBLE_WINDOW_WAIT  = 10
local GAMBLE_DECLINE_STEPS = {
    { "true 1" },
    { "false -2", "true 1" },
    { "true 1" },
}

local GAMBLE_NAME_HINT = 15   -- 進入暫停幾秒後還看不到魔法球，就提示可能名稱不對

function Handlers.DUNGEON_GAMBLE()
    if not InDuty() then return "DUNGEON_EXIT" end

    -- 一律放棄：按「不挑戰解除陷阱」。放棄不了才往下走到暫停（手動處理）
    if not State.gambleManual then
        local orbs = Api.GetEntity(Cfg.GambleBigName) ~= nil or Api.GetEntity(Cfg.GambleSmallName) ~= nil
        if orbs then
            LogError("大／小魔法球變成可以互動了（可能按成「挑戰」），改成暫停，請手動處理")
            State.gambleManual = true
        elseif Api.AddonReady(GAMBLE_WINDOW) then
            Api.NavStop()
            if Elapsed() - (State.declineAt or -10) >= GAMBLE_DECLINE_GAP then
                State.declineTries = (State.declineTries or 0) + 1
                local step = GAMBLE_DECLINE_STEPS[State.declineTries]
                if step == nil then
                    LogError("按了 " .. #GAMBLE_DECLINE_STEPS .. " 次「不挑戰」，強欲陷阱視窗還在，改成暫停，請手動處理")
                    State.gambleManual = true
                else
                    Log("強欲陷阱：放棄，按「不挑戰解除陷阱」（第 " .. State.declineTries .. " 次：" .. table.concat(step, " → ") .. "）")
                    for k, args in ipairs(step) do
                        if k > 1 then yield("/wait 0.3") end
                        yield("/callback " .. GAMBLE_WINDOW .. " " .. args)
                    end
                    State.declineAt = Elapsed()
                end
            end
            if not State.gambleManual then return nil end
        elseif (State.declineTries or 0) > 0 then
            -- 視窗關了：放棄成功，等寶箱打開再回去收尾、選門
            State.declineDoneAt = State.declineDoneAt or Elapsed()
            if Elapsed() - State.declineDoneAt < 3 then return nil end
            State.gambleActive, State.gambleDiagOn = false, false
            Log("已放棄強欲陷阱，繼續")
            return "DUNGEON_LOOT"
        elseif Elapsed() > GAMBLE_WINDOW_WAIT then
            LogError("收到強欲陷阱的訊息，但 " .. GAMBLE_WINDOW_WAIT .. " 秒都沒看到強欲陷阱視窗，改成暫停，請手動處理")
            State.gambleManual = true
        else
            return nil   -- 等強欲陷阱視窗出現
        end
    end

    if not State.gamblePauseLogged then
        Api.NavStop()   -- 寶物庫內自動輸出和閃避維持開著，只停止移動
        Log("強欲陷阱出現，腳本暫停：請自己操作（挑戰／不挑戰、選大／小）。強欲陷阱結束後自動繼續，或輸入 /echo #繼續")
        if Cfg.GambleDiag then Log("強欲陷阱診斷開始（同 GambleTest v0.5）：每 " .. GAMBLE_DIAG_INTERVAL .. " 秒讀寶箱周圍物件的記憶體，印出變化（[G14][強欲] 開頭）；請記下每一輪卡牌的數字") end
        State.gamblePauseLogged = true
    end
    GambleDiagTick()
    local function Resume(reason)
        State.gambleActive, State.resumeRequested, State.gambleDiagOn = false, false, false
        Log(reason .. "，腳本繼續")
        return "DUNGEON_LOOT"
    end
    if State.resumeRequested then return Resume("收到 #繼續") end
    if Api.AddonReady(GAMBLE_WINDOW) or Api.GetEntity(Cfg.GambleBigName) ~= nil or Api.GetEntity(Cfg.GambleSmallName) ~= nil then
        State.gambleSeen, State.gambleGoneAt = true, nil
        return nil
    end
    -- 還沒看到強欲陷阱視窗或魔法球：一直等，不會自己繼續
    if not State.gambleSeen then
        if not State.gambleNameHinted and Elapsed() > GAMBLE_NAME_HINT then
            Log("看不到強欲陷阱視窗或「" .. Cfg.GambleBigName .. "」「" .. Cfg.GambleSmallName .. "」魔法球，處理完請輸入 /echo #繼續")
            State.gambleNameHinted = true
        end
        return nil
    end
    State.gambleGoneAt = State.gambleGoneAt or Elapsed()
    if Elapsed() - State.gambleGoneAt >= 5 then return Resume("強欲陷阱結束") end
end

-- 門還不能互動（離太遠，Api.TargetableObjects 找不到）時，先走到門附近：
--   1. 看得到門物件（還不能互動）：走到這些門的中間；到了還不能互動，改走到最近的一扇
--   2. 看不到門物件：從這一層的入口往寶箱的方向，越過寶箱繼續往前走（每次多 DOOR_SEARCH_STEP，最多 DOOR_SEARCH_MAX）
local DOOR_NEAR        = 5
local DOOR_SEARCH_STEP = 8
local DOOR_SEARCH_MAX  = 40

-- 名稱相符的所有物件（不管能不能互動）
local function NamedObjects(name)
    local list = {}
    if name == nil or name == "" then return list end
    local objs = Svc.Objects
    for i = 0, objs.Length - 1 do
        local o = objs[i]
        if o ~= nil and o.Name.TextValue == name then table.insert(list, o) end
    end
    return list
end

local function ApproachDoors()
    if Api.NavRunning() then return end
    local me = Api.PlayerPos()
    local all = NamedObjects(Cfg.DoorName)
    local target, how = nil, nil
    if #all > 0 then
        local x, y, z = 0, 0, 0
        for _, d in ipairs(all) do x, y, z = x + d.Position.X, y + d.Position.Y, z + d.Position.Z end
        local mid = { X = x / #all, Y = y / #all, Z = z / #all }
        if Distance2D(me, mid) > DOOR_NEAR and not State.doorMidReached then
            target, how = mid, "門的中間"
        else
            State.doorMidReached = true   -- 到了中間還不能互動：改走到最近的一扇門
            local best, bestDist = nil, math.huge
            for _, d in ipairs(all) do
                local dd = Distance2D(me, d.Position)
                if dd < bestDist then best, bestDist = d, dd end
            end
            if bestDist <= 2 then return end   -- 已經在門旁邊：等它變成可互動
            target, how = { X = best.Position.X, Y = best.Position.Y, Z = best.Position.Z }, "最近的門"
        end
    else
        -- 看不到門：從入口往寶箱方向，越過寶箱往前找
        local from, to = State.floorEntryPos, State.floorChestPos
        if from == nil or to == nil then return end
        local dx, dz = to.X - from.X, to.Z - from.Z
        local len = math.max(math.sqrt(dx * dx + dz * dz), 0.01)
        State.doorSearchDist = (State.doorSearchDist or 0) + DOOR_SEARCH_STEP
        if State.doorSearchDist > DOOR_SEARCH_MAX then return end
        target = { X = to.X + dx / len * State.doorSearchDist, Y = me.Y, Z = to.Z + dz / len * State.doorSearchDist }
        how = "越過寶箱往前 " .. State.doorSearchDist .. " 碼找門"
    end
    if how ~= State.doorApproachLog then
        Log(string.format("門還不能互動，先走到%s（%.0f 外）", how, Distance2D(me, target)))
        State.doorApproachLog = how
    end
    Api.VaultMoveTo(target.X, target.Y, target.Z)
end

-- 互動門沒反應時的重試：直接走到門的最近可走點，DOOR_INTERACT_RANGE 以內、或 DOOR_STALL 秒沒前進（被門擋住）才互動
local DOOR_INTERACT_RANGE = 2.5
local DOOR_STALL          = 2
local DOOR_TRIES          = 3

local function ApproachDoorCloser()
    local me, pos = Api.PlayerPos(), State.doorPos
    local dist = Distance2D(me, pos)
    if State.doorMoveAt == nil or Distance2D(me, State.doorMovePos) > 0.3 then
        State.doorMovePos, State.doorMoveAt = me, Elapsed()
    end
    if dist > DOOR_INTERACT_RANGE and Elapsed() - State.doorMoveAt < DOOR_STALL then
        if not Api.NavRunning() then Api.VaultMoveTo(pos.X, pos.Y, pos.Z) end
        return false
    end
    Api.NavStop()
    if Api.Condition(Cond.occupiedInEvent) then return false end
    if not pcall(function() Svc.Targets.Target = State.doorObj end) then return false end
    Log(string.format("走近門（距離 %.1f），再互動一次（第 %d 次）", dist, State.doorTries + 1))
    Api.InteractTarget()
    return true
end

-- 選門：場上可互動的「寶物庫的門」。有發光提示時只會剩一扇，選那扇（提示後最多再等 5 秒讓另一扇消失）；
-- 沒有提示就先等 DoorHintWait 秒，之後依 DoorChoice 選（Random 隨機 / First 第一個）
function Handlers.DUNGEON_DOOR()
    if not InDuty() then return "DUNGEON_EXIT" end
    if GambleDetected() and GamblePauses() then return "DUNGEON_GAMBLE" end   -- 寶箱打開後比較晚才出現強欲陷阱
    if Api.ConfirmYes() then return nil end
    -- 剛進選門步驟：停掉戰鬥、走向寶箱時留下的導航（導航一直在跑，ApproachDoors 會一直等它結束）
    if not State.doorNavCleared then
        Api.NavStop()
        State.doorNavCleared = true
    end

    -- 已經選了門：用記下的位置在場上找回那扇門（物件參照可能已失效）；附近找不到門就清掉重選
    if State.doorPos ~= nil then
        local current, bestDist = nil, 3
        for _, d in ipairs(NamedObjects(Cfg.DoorName)) do
            local dd = Distance2D(d.Position, State.doorPos)
            if dd <= bestDist then current, bestDist = d, dd end
        end
        if current == nil then
            Log("之前選的門已經不在附近，重新選門")
            State.doorPos, State.doorObj, State.doorFrom = nil, nil, nil
        else
            State.doorObj = current
        end
    end

    if State.doorPos == nil then
        local doors = Api.TargetableObjects(Cfg.DoorName)
        if #doors == 0 then
            ApproachDoors()   -- 門離太遠還不能互動：先走過去
            if TimedOut("DUNGEON_DOOR") then
                LogError(string.format("找不到可以互動的「%s」（看得到的門物件 %d 個，導航%s）",
                    Cfg.DoorName, #NamedObjects(Cfg.DoorName), Api.NavRunning() and "還在跑" or "沒在跑"))
                return "ERROR"
            end
            return nil
        end
        if State.doorApproachLog ~= nil then
            Api.NavStop()   -- 走到門附近、門可以互動了：停下來選門（之後由 ApproachAndInteractObject 走到門旁邊）
            State.doorApproachLog = nil
        end
        if #doors > 1 then
            if State.doorHint == nil and Elapsed() < Cfg.DoorHintWait then return nil end
            if State.doorHint ~= nil and Elapsed() < Cfg.DoorHintWait + 5 then return nil end
        end
        local idx = 1
        if #doors > 1 and Cfg.DoorChoice == "Random" then idx = math.random(#doors) end
        local door = doors[idx]
        if #doors == 1 then
            Log("第 " .. State.stage .. " 層選門：" .. (State.doorHint and (State.doorHint .. "的門發光，只剩一扇") or "只有這一扇能互動"))
        else
            Log("第 " .. State.stage .. " 層選門：沒有提示，" .. (Cfg.DoorChoice == "Random" and "隨機" or "第一個") .. "（" .. idx .. "/" .. #doors .. "）")
        end
        -- 記下門和選門前站的位置（門開了之後物件可能消失，之後只用座標）
        State.doorTries = 0
        State.doorObj = door
        State.doorPos = Vector3(door.Position.X, door.Position.Y, door.Position.Z)
        -- 走進門的方向用「這層寶箱 → 門」（寶箱在房間中間；角色可能已經走到門邊，用站的位置算方向會偏）
        local me = Api.PlayerPos()
        State.doorFrom = State.floorChestPos and { X = State.floorChestPos.X, Y = me.Y, Z = State.floorChestPos.Z } or me
    end

    -- 互動前清掉「門有反應」的證據，DUNGEON_DOOR_WAIT 用來確認這次互動真的有效
    if (State.doorTries or 0) == 0 then
        if not Api.Condition(Cond.occupiedInEvent) and ApproachAndInteractObject(State.doorObj) then
            State.doorOpened, State.doorTries = false, 1
            return "DUNGEON_DOOR_WAIT"
        end
    elseif ApproachDoorCloser() then
        State.doorOpened, State.doorTries = false, State.doorTries + 1
        return "DUNGEON_DOOR_WAIT"
    end
    if TimedOut("DUNGEON_DOOR") then
        local me = Api.PlayerPos()
        LogError(string.format("走到選好的門旁互動失敗（門在 %.0f 外，導航%s）",
            Distance2D(me, State.doorPos), Api.NavRunning() and "還在跑" or "沒在跑"))
        return "ERROR"
    end
end

-- 到了下一層沒：不看位移，看有沒有下一層的寶箱或怪物（傳送後會有一段不能移動的過場動畫，
-- 之後的 DUNGEON_CHEST / DUNGEON_PULL 都會等動畫結束才動）：
--   * 寶箱：可互動，而且離這一層互動過的寶箱（State.floorChestPos）超過 FLOOR_CHEST_APART → DUNGEON_CHEST（第 1～4 層）
--   （第 4 層 → 第 5 層不在這裡判斷：第 5 層沒有寶箱，由 DUNGEON_PASSAGE 等進入下一層的動畫結束才算到）
-- 有就把層數 +1、清掉門的資料，回傳下一個步驟；都沒有回傳 nil
local FLOOR_CHEST_APART = 20

local function NextFloorStep()
    local nextStep, how = nil, nil
    local chest = Api.NearestTargetable(Cfg.DungeonChestName)
    if chest ~= nil and (State.floorChestPos == nil
        or Distance2D(chest.Position, State.floorChestPos) > FLOOR_CHEST_APART) then
        nextStep, how = "DUNGEON_CHEST", "看到寶箱"
    end
    if nextStep == nil then return nil end
    State.stage = State.stage + 1
    State.doorPos, State.doorObj, State.doorFrom = nil, nil, nil
    Api.NavStop()
    Log("到達第 " .. State.stage .. " 層（" .. how .. "）")
    return nextStep
end

-- 等開門（或關門）動畫：門可能直接開、關一下再開、警報後彩虹光再開，或警報後把人移出寶物庫。
-- 至少等 DoorAnimWait 秒，而且等到角色能移動；這時就看到下一層的寶箱或怪物也算到了
function Handlers.DUNGEON_DOOR_WAIT()
    if not InDuty() then
        Log("選錯門，被移出寶物庫")
        return "DUNGEON_EXIT"
    end
    local nextStep = NextFloorStep()   -- 開門動畫中就被傳到下一層
    if nextStep ~= nil then return nextStep end
    if Api.ConfirmYes() then return nil end
    -- 門有反應的證據：聊天「打開了…大門」、等待中出現動畫旗標、選的門變成不能互動
    if #EntryLockFlags() > 0 then State.doorOpened = true end
    if not State.doorOpened then
        local stillTargetable = false
        for _, d in ipairs(Api.TargetableObjects(Cfg.DoorName)) do
            if Distance2D(d.Position, State.doorPos) <= 3 then stillTargetable = true end
        end
        if not stillTargetable then State.doorOpened = true end
    end
    if Elapsed() < Cfg.DoorAnimWait or Api.Condition(Cond.occupiedInEvent) or not Api.PlayerReady() then return nil end
    if not State.doorOpened then
        if (State.doorTries or 0) >= DOOR_TRIES then
            LogError("互動門 " .. DOOR_TRIES .. " 次都沒有反應（沒有開門訊息、門也還能互動）")
            return "ERROR"
        end
        Log("門沒有反應（互動沒成功），走近一點再互動")
        State.doorMoveAt = nil
        return "DUNGEON_DOOR"
    end
    return "DUNGEON_PASSAGE"
end

local PASS_STALL    = 2   -- 第 4 層走進門時，導航在跑、角色幾秒沒移動就算進入動畫
local PASS_ANIM_MIN = 3   -- 進入動畫後至少等幾秒才判斷動畫結束

-- 走進門：門後有傳送法陣（不能互動、沒有名稱），踩上去會被傳到下一層。
-- 從選門前站的位置往門的方向，穿過門再往前 PassageDistance（每次沒傳送成功就再往前 4）。
-- 看到下一層的寶箱或怪物（NextFloorStep）就算到了；DUNGEON_PASSAGE 秒內都沒看到才報錯
function Handlers.DUNGEON_PASSAGE()
    if not InDuty() then
        Log("選錯門，被移出寶物庫")
        return "DUNGEON_EXIT"
    end
    -- 第 4 層 → 第 5 層（使用者指定）：先走進門 → 等過場動畫結束 → 才去找怪（DUNGEON_PULL）。
    -- 動畫開始：狀態旗標亮起，或導航還在跑、角色卻 PASS_STALL 秒沒移動（被動畫鎖住；這段動畫可能不亮任何旗標，同入口的判斷）
    -- 動畫結束：至少過了 PASS_ANIM_MIN 秒，旗標都沒亮、角色可以操作，維持 FLOOR_SETTLE 秒
    if State.stage == MAX_STAGES - 1 then
        local flags = EntryLockFlags()
        if not State.passAnim then
            local me = Api.PlayerPos()
            if State.passMovePos == nil or Distance2D(me, State.passMovePos) > 0.3 or not Api.NavRunning() then
                State.passMovePos, State.passMoveAt = me, Elapsed()
            end
            local stalled = Api.NavRunning() and Elapsed() - State.passMoveAt >= PASS_STALL
            if #flags > 0 or stalled then
                Api.NavStop()
                State.passAnim, State.passAnimAt, State.passAnimEnd = true, Elapsed(), nil
                Log("進入下一層的動畫（" .. (#flags > 0 and ("狀態旗標 " .. table.concat(flags, ","))
                    or ("角色 " .. PASS_STALL .. " 秒沒移動")) .. "），等動畫結束")
                return nil
            end
        else
            if #flags > 0 or not Api.PlayerReady() or Elapsed() - State.passAnimAt < PASS_ANIM_MIN then
                State.passAnimEnd = nil
                return nil
            end
            State.passAnimEnd = State.passAnimEnd or Elapsed()
            if Elapsed() - State.passAnimEnd < FLOOR_SETTLE then return nil end
            State.stage = State.stage + 1
            State.doorPos, State.doorObj, State.doorFrom = nil, nil, nil
            Log("到達第 " .. State.stage .. " 層（動畫結束），去找怪物")
            return "DUNGEON_PULL"
        end
    end
    if Busy() then return nil end
    if State.stage ~= MAX_STAGES - 1 then
        local nextStep = NextFloorStep()
        if nextStep ~= nil then return nextStep end
    end

    -- 踩上法陣後有一段不能操作的動畫：動畫中不要再下移動指令（不然每次都會再往前 4，越走越遠）
    if not Api.NavRunning() and Api.PlayerReady() and not Api.Condition(Cond.occupiedInEvent) then
        State.passTries = (State.passTries or 0) + 1
        local d, f = State.doorPos, State.doorFrom
        local dx, dz = d.X - f.X, d.Z - f.Z
        local len = math.max(math.sqrt(dx * dx + dz * dz), 0.01)
        local dist = Cfg.PassageDistance + (State.passTries - 1) * 4
        local x, z = d.X + dx / len * dist, d.Z + dz / len * dist
        local target = Api.NearestMeshPoint(x, d.Y, z) or Vector3(x, d.Y, z)
        if State.passTries == 1 then Log("走進門，前往傳送法陣") end
        Api.NavMoveTo(target, false)
    end
    if TimedOut("DUNGEON_PASSAGE") then return "ERROR" end
end

-- 一進新的一層就是怪物、沒有寶箱（第 5 層）：等過場動畫結束 → 找怪 → 走到怪物附近、選取、丟飛斧
-- （PullWithTomahawk：最多丟 3 次、試 15 秒）→ 進入戰鬥就交給 DUNGEON_COMBAT，之後照舊（打完 → 等寶箱自動打開 → 退出點）。
-- 一次找怪沒進入戰鬥（或 PULL_FIND_WAIT 秒都看不到怪）就重來，重來 PULL_ATTEMPTS 次都不行才報錯
local PULL_ATTEMPTS  = 3
local PULL_FIND_WAIT = 10

function Handlers.DUNGEON_PULL()
    if not InDuty() then return "DUNGEON_EXIT" end
    if Api.Condition(Cond.inCombat) then return "DUNGEON_COMBAT" end
    -- 等過場動畫結束、角色能移動（只等這一次）
    if State.floorReadyAt == nil then
        if InCutscene() or Api.Condition(Cond.betweenAreas) then return nil end
        Api.NavStop()   -- 動畫前的導航（往法陣、往門後走）作廢：傳送後位置變了，到了這裡重新規劃路徑
        State.floorReadyAt = Elapsed()
        Log("第 " .. State.stage .. " 層：可以操作了，去找怪物")
    end
    if Elapsed() - State.floorReadyAt < FLOOR_SETTLE then return nil end

    State.pullAttempt = State.pullAttempt or 1
    State.attemptStart = State.attemptStart or Elapsed()
    local failed = false
    local enemy = FindVaultEnemy()
    if enemy ~= nil then
        if PullWithTomahawk(enemy) then
            if Api.Condition(Cond.inCombat) then return "DUNGEON_COMBAT" end
            failed = true
        end
    elseif Elapsed() - State.attemptStart > PULL_FIND_WAIT then
        failed = true
    end
    if not failed then return nil end
    if State.pullAttempt >= PULL_ATTEMPTS then
        LogError(string.format("找怪 %d 次都沒有進入戰鬥（最後離「%s」%.0f 碼）", PULL_ATTEMPTS, tostring(State.pullLastName), State.pullLastDist or -1))
        return "ERROR"
    end
    State.pullAttempt = State.pullAttempt + 1
    Log(string.format("沒有進入戰鬥（離「%s」%.0f 碼，導航%s），重新找怪（第 %d 次）", tostring(State.pullLastName),
        State.pullLastDist or -1, Api.NavRunning() and "中" or "已停", State.pullAttempt))
    State.attemptStart, State.pullStart, State.pullAt, State.pullTries = Elapsed(), nil, nil, 0
    State.pullMovePos, State.pullMoveAt, State.pullApproachLogged, State.pullStallLogged = nil, nil, false, false
end

-- 離開寶物庫：還在寶物庫內就找離開用的傳送門（退出點）互動並確認；被移出或陣亡結束時直接等回到野外
function Handlers.DUNGEON_EXIT()
    if not InDuty() and not Busy() then
        Api.WrathOff()   -- 已回到野外：關掉自動輸出和閃避（閃避 AI 不能開到野外）
        local reached = math.min(State.stage, MAX_STAGES)
        table.insert(State.stageLog, reached)
        Log("寶物庫結束，到達第 " .. reached .. " 層")
        return "CHECK_MAP"
    end
    if InDuty() and not Busy() and not Api.Condition(Cond.dead) then
        if Api.ConfirmYes() then return nil end
        local exitName = FindExitPortal()
        if exitName ~= nil then
            if not Api.Condition(Cond.occupiedInEvent) then ApproachAndInteract(exitName) end
        elseif not State.manualPrompted and Elapsed() > 20 then
            Log("找不到離開用的「" .. Cfg.ExitPortalName .. "」或「" .. EXIT_POINT_NAME .. "」，請確認 ExitPortalName 或手動離開")
            State.manualPrompted = true
        end
    end
    if TimedOut("DUNGEON_EXIT") then return "ERROR" end
end

---------------------------------------------------------------- 錯誤與結束

function Handlers.ERROR()
    StopAutomation()
    State.errors = State.errors + 1
    State.errorCount = State.errorCount + 1
    LogError(string.format("狀態 %s 失敗（在該步驟第 %.0f 秒，連續 %d/%d）",
        tostring(State.errorFrom), State.errorAfter or 0, State.errors, Cfg.MaxErrors))
    -- 清掉各狀態的暫存旗標
    State.tmapSent, State.teleportSent = false, false, false
    State.digSent, State.chestOpened, State.rouletteStarted = false, false, false
    pcall(CloseMarket)
    if State.errors >= Cfg.MaxErrors then return "END" end
    if InDuty() then return "DUNGEON_EXIT" end
    return "CHECK_MAP"
end

function Handlers.END()
    StopAutomation()
    local stages = #State.stageLog > 0 and table.concat(State.stageLog, ",") or "無"
    yield(string.format("/echo [G14] 結束：完成 %d 張，寶物庫 %d 次（到達關數 %s），錯誤 %d 次，買圖 %d 張共 %d gil，換伺服器 %d 次，完成 %d 輪",
        State.mapsDone, State.dungeonRuns, stages, State.errorCount, State.mapsBought or 0, State.gilSpent or 0, State.worldTrips or 0, State.roundsDone or 0))
    return nil
end

-------------------------------------------------------------------------------
-- 5. 主迴圈
-------------------------------------------------------------------------------

local function Transition(next)
    if next == nil or next == State.current and next ~= "DECIPHER" and next ~= "DIG" then
        return
    end
    if next == "ERROR" then State.errorFrom, State.errorAfter = State.current, Elapsed() end
    if next == "TRAVEL" then State.cofferPos, State.leashing = nil, false end
    if next == "OPEN_COFFER" then State.fieldCleared = false end
    if State.current == "LOCATE" and next ~= "FIELD_FIGHT" then
        -- 離開等旗標的步驟時藏寶圖工具小幫手還在重新載入（停用中）：把它開回來
        if State.flagReload ~= nil then yield("/xlenableplugin " .. FLAG_PLUGIN) end
        State.flagReload, State.flagReloads, State.flagReloadDoneAt, State.flagReloaded = nil, 0, nil, nil
    end
    if next == "LOCATE" and State.flagReload ~= nil then State.flagReload.at = 0 end   -- 打完怪回來：步驟計時重新算
    Log(State.current .. " → " .. next)
    State.current = next
    State.enteredAt = os.clock()
    State.lastPos, State.rePathed = nil, false
    State.sent, State.lastClick, State.travelPhase, State.decipherAt = false, nil, nil, nil
    State.cityTeleportSent = false
    State.combatTargeted, State.lastEnemyScan, State.lastInCombat, State.enemySeen = false, nil, nil, false
    State.pullStart, State.pullAt, State.pullTries = nil, nil, 0
    State.pullMovePos, State.pullMoveAt, State.pullApproachLogged, State.pullStallLogged = nil, nil, false, false
    State.fought, State.pullExhausted, State.stageEndCheckAt = false, false, nil
    State.favTries = 0
    State.lastChestAt = nil
    State.chestInteractAt, State.chestTries, State.floorReadyAt, State.chestLogged = nil, 0, nil, false
    State.pullAttempt, State.attemptStart = nil, nil
    State.doorMidReached, State.doorSearchDist, State.doorApproachLog, State.doorNavCleared = false, nil, nil, false
    State.forwardDist = nil
    State.entryStart, State.entryCutscene, State.entryEndAt, State.entryWaitLogged = nil, false, nil, false
    State.entryMovePos, State.entryMoveAt = nil, nil
    State.chestMovePos, State.chestMoveAt, State.chestStalls, State.finalChestAt = nil, nil, 0, nil
    State.passLastPos, State.passTries = nil, 0
    State.passAnim, State.passAnimEnd, State.passAnimAt, State.passMovePos, State.passMoveAt = false, nil, nil, nil, nil
    if next == "DUNGEON_CHEST" then State.doorHint, State.gambleActive = nil, false end
    if next == "DUNGEON_GAMBLE" then
        State.resumeRequested, State.gambleSeen, State.gambleGoneAt = false, false, nil
        State.gamblePauseLogged, State.gambleNameHinted = false, false
        State.gambleDiagOn, State.gambleChat, State.diagChatShown = true, {}, 0
        State.diagAt, State.diagSnap, State.diagSeen = nil, {}, {}
        State.diagWin, State.diagMemNoted = nil, false
        State.gambleManual, State.declineTries, State.declineAt, State.declineDoneAt = false, nil, nil, nil
    end
    State.spotLogged = nil
    State.searchTries, State.lastSearch, State.manualPrompted = 0, nil, false
end

while true do
    if Api.StopRequested() and State.current ~= "END" then
        Transition("END")
    end

    if State.current == "END" then
        Handlers.END()
        break
    end

    -- 讀取中保護：只等待（DUNGEON_INIT / TRAVEL / ENTER_DUNGEON 自己處理讀取）
    local waitsOnLoading = State.current == "DUNGEON_INIT" or State.current == "TRAVEL"
        or State.current == "ENTER_DUNGEON" or State.current == "DUNGEON_EXIT"
        or State.current == "MB_TRAVEL" or State.current == "WORLD_TRAVEL"
        or State.current == "DUNGEON_PASSAGE"
    if Api.Condition(Cond.betweenAreas) and not waitsOnLoading then
        yield("/wait 0.5")
    else
        -- 野外被怪物纏上：騎著坐騎時直接飛走，不然先切到 FIELD_FIGHT 打完再回來
        if INTERRUPTIBLE[State.current] and Api.Condition(Cond.inCombat) and not Api.Condition(Cond.dead)
            and not Api.Condition(Cond.mounted) and not InDuty() then
            State.resumeState = State.current
            Log("被怪物攻擊，先打完再繼續")
            Transition("FIELD_FIGHT")
        end
        local handler = Handlers[State.current]
        local ok, result = pcall(handler)
        if not ok then
            LogError("例外：" .. tostring(result))
            result = "ERROR"
        elseif result == nil and Timeout[State.current] ~= nil
            and Elapsed() > Timeout[State.current] + 5 then
            -- 保底：處理函式沒自行判斷逾時時強制轉 ERROR
            result = "ERROR"
        end
        Transition(result)
        yield("/wait 0.3")
    end
end
