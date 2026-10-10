--[=====[
[[SND Metadata]]
author: forgefk
version: 0.1.0
description: FF14 G15 自動挖寶（古舊的蛇牛革地圖）+ 寶物庫 The Shifting Gymnasion Agonon。戰士單刷，依「FF14 G15 自動挖寶 SND 架構規格」實作。
plugin_dependencies:
- vnavmesh
- WrathCombo
- BossModReborn
- Lifestream
configs:
  MapItemId:
    default: 39591
    description: 未解讀 G15 地圖的物品 ID（已查好，取自 XIVAPI；0 = 未設定，INIT 會停止）
  MaxMaps:
    default: 0
    description: 本次最多跑幾張，0 = 跑到沒圖
  AutoBuy:
    default: true
    description: 圖不夠時自動到市場板買圖（維持身上 1 張已解讀 + SpareMaps 張未解讀）
  SpareMaps:
    default: 1
    description: 身上要保留幾張未解讀的備用圖
  MaxMapPrice:
    default: 0
    description: 每張圖最多付多少 gil（AutoBuy 開啟時必填，0 = 未設定，INIT 會停止）
  GilFloor:
    default: 0
    description: 買完後身上至少保留多少 gil
  MarketTerritoryId:
    default: 129
    description: 買圖的城市地區 ID（129 = 利姆薩·羅敏薩下層甲板，傳送到該區大水晶）
  MarketAetheryte:
    default: ""
    description: 買圖城市的以太之光名稱（留空 = 依 MarketTerritoryId 自動從遊戲資料取）
  MarketX:
    default: -121
    description: 傳送到大水晶後要走去的市場板位置 X
  MarketY:
    default: 18
    description: 市場板位置 Y（高度）
  MarketZ:
    default: 12
    description: 市場板位置 Z
  MarketBoardName:
    default: ""
    description: 市場板物件名稱（留空 = 自動從遊戲資料取）
  StartWithDeciphered:
    default: false
    description: 啟動時身上已經有解讀過的圖就設成 true（遊戲沒辦法自動偵測）
  FlagWait:
    default: 120
    description: 解讀後等藏寶點旗標的秒數（XivTreasureParty 自動打，或你手動插）
  EnterDungeon:
    default: true
    description: 出現傳送門時是否進入寶物庫
  DigRadius:
    default: 3
    description: 距離旗標多近開始挖寶
  PortalWait:
    default: 5
    description: 開箱後等待傳送門出現的秒數
  PotionHpPercent:
    default: 40
    description: HP 低於此百分比時喝藥（0 = 不喝）
  PotionItemName:
    default: ""
    description: 回復藥物品名稱（空白 = 不喝）
  UseSprint:
    default: false
    description: 移動時是否使用衝刺
  MaxErrors:
    default: 3
    description: 連續錯誤幾次後停止腳本
  SphereName:
    default: ""
    description: 寶物庫魔法球物件名稱（待填）
  ChestName:
    default: ""
    description: 野外寶箱物件名稱（待填）
  DungeonChestName:
    default: ""
    description: 寶物庫寶箱物件名稱（空白 = 同 ChestName）
  PortalName:
    default: ""
    description: 傳送門物件名稱（待填）
  AetheryteName:
    default: ""
    description: 厄爾庇斯的以太之光名稱（留空 = 自動從遊戲資料取）
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
local ELPIS_TERRITORY  = 961

-- 一般動作 ID（GeneralAction 表，取自 XIVAPI），用 ID 執行不受客戶端語系影響
local GA = {
    sprint        = 4,
    mountRoulette = 9,
    decipher      = 19,
    dig           = 20,
    dismount      = 23,
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
    MapItemId        = Config.Get("MapItemId"),
    MaxMaps          = Config.Get("MaxMaps"),
    EnterDungeon     = Config.Get("EnterDungeon"),
    StartWithDeciphered = Config.Get("StartWithDeciphered"),
    FlagWait   = Config.Get("FlagWait"),
    AutoBuy          = Config.Get("AutoBuy"),
    SpareMaps        = Config.Get("SpareMaps"),
    MaxMapPrice      = Config.Get("MaxMapPrice"),
    GilFloor         = Config.Get("GilFloor"),
    MarketTerritoryId = Config.Get("MarketTerritoryId"),
    MarketAetheryte  = Config.Get("MarketAetheryte"),
    MarketX          = Config.Get("MarketX"),
    MarketY          = Config.Get("MarketY"),
    MarketZ          = Config.Get("MarketZ"),
    MarketBoardName  = Config.Get("MarketBoardName"),
    DigRadius        = Config.Get("DigRadius"),
    PortalWait       = Config.Get("PortalWait"),
    PotionHpPercent  = Config.Get("PotionHpPercent"),
    PotionItemName   = Config.Get("PotionItemName"),
    UseSprint        = Config.Get("UseSprint"),
    MaxErrors        = Config.Get("MaxErrors"),
    SphereName       = Config.Get("SphereName"),
    ChestName        = Config.Get("ChestName"),
    DungeonChestName = Config.Get("DungeonChestName"),
    PortalName       = Config.Get("PortalName"),
    AetheryteName    = Config.Get("AetheryteName"),
    EchoLogs         = Config.Get("EchoLogs"),
}
if Cfg.DungeonChestName == nil or Cfg.DungeonChestName == "" then
    Cfg.DungeonChestName = Cfg.ChestName
end

-- 各狀態逾時（秒），建議初值，實測後調整
local Timeout = {
    CHECK_MAP        = 3,
    DECIPHER         = 10,
    LOCATE           = Cfg.FlagWait,
    TRAVEL           = 180,
    DIG              = 8,
    OPEN_COFFER      = 15,
    FIELD_COMBAT     = 600,   -- 遊戲戰鬥時限未知，先給寬鬆上限
    LOOT             = 10,
    PORTAL_CHECK     = Cfg.PortalWait,
    ENTER_DUNGEON    = 60,
    DEAD             = 120,
    MB_TRAVEL        = 120,
    MB_OPEN          = 15,
    MB_SEARCH        = 20,
    MB_LIST          = 15,
    MB_BUY           = 15,
    MB_CLOSE        = 10,
    DUNGEON_INIT     = 30,
    DUNGEON_SPHERE   = 15,
    DUNGEON_ROULETTE = 30,
    DUNGEON_COMBAT   = 3600,  -- 副本限時 60 分鐘
    DUNGEON_CHEST    = 15,
    DUNGEON_EXIT     = 60,
}

local DECIPHER_RETRIES = 2
local DIG_RETRIES      = 3
local DIG_OFFSET       = 5
local STUCK_INTERVAL   = 10
local STUCK_DISTANCE   = 1
local MAX_STAGES       = 5

-- 方案 (a)：內建 G15 八個藏寶點座標（Game8 地圖座標）。待填；目前未使用，藏寶點旗標由 XivTreasureParty 自動打或手動插。
-- 格式：{ x = 11.8, y = 33.1 }
local TREASURE_SPOTS = {
}

-------------------------------------------------------------------------------
-- 2. Api 轉接層（SND v2 API；標 TODO 者為「待確認事項」，實測後修正）
-------------------------------------------------------------------------------

local Api = {}

function Api.Condition(id)
    return Svc.Condition[id] == true
end

-- 直接查 Dalamud 已載入的插件，用 InternalName 比對。
-- 不用 IPC.IsInstalled：它只認 SND 內建的 IPC 包裝（沒有 BossModReborn），
-- 而且比對的是顯示名稱（Wrath 顯示為 "Wrath Combo"），兩個都會誤判成沒裝
function Api.PluginInstalled(internalName)
    for plugin in luanet.each(Svc.PluginInterface.InstalledPlugins) do
        if plugin.InternalName == internalName and plugin.IsLoaded then
            return true
        end
    end
    return false
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

-- TODO 待確認：已解讀地圖不在一般背包，如何直接查詢未查到。
-- 目前以「腳本自己記錄已解讀」+「旗標已在厄爾庇斯」兩者判斷。
function Api.HasDecipheredMap()
    return State.deciphered
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

function Api.GetEntity(name)
    if name == nil or name == "" then return nil end
    return Entity.GetEntityByName(name)
end

function Api.Target(name)
    local e = Api.GetEntity(name)
    if e == nil then return false end
    e:SetAsTarget()
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

function Api.NavMoveTo(pos, fly)
    IPC.vnavmesh.PathfindAndMoveTo(pos, fly)
end

function Api.NavStop()
    if Api.NavRunning() then IPC.vnavmesh.Stop() end
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

-- 物品名稱（客戶端語系），用來在市場板搜尋，避免手填名稱打錯而搜到別張圖
function Api.ItemName(itemId)
    local ok, name = pcall(function() return tostring(Excel.GetRow("Item", itemId).Name) end)
    if ok and name ~= nil and name ~= "" and name ~= "nil" then return name end
    return nil
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

function Api.WrathOn()  yield("/wrath auto on")  end
function Api.WrathOff() yield("/wrath auto off") end

-- TODO 待確認：解讀視窗的 addon 名稱與 callback 參數
function Api.SelectMapInDecipherWindow()
    if Api.AddonReady("SelectIconString") then
        yield("/callback SelectIconString true 0")
        return true
    end
    return false
end

function Api.ConfirmYes()
    if Api.AddonReady("SelectYesno") then
        yield("/callback SelectYesno true 0")
        return true
    end
    return false
end

-- 強欲之罠（高低猜）：一律放棄。TODO 待確認 addon 名稱與「放棄」的 callback 參數
local GAMBLE_ADDON = "SelectYesno"
function Api.DeclineGamble()
    if Api.AddonReady(GAMBLE_ADDON) then
        yield("/callback " .. GAMBLE_ADDON .. " true 1")
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

function Api.MarketSearch(itemName)
    yield("/callback ItemSearch true 7 -1 0 -1 -1 -1 -1 -1")   -- 清空搜尋條件
    yield("/wait 0.5")
    yield(string.format('/callback ItemSearch true 0 -1 0 "%s" "%s" 100 100 34', itemName, itemName))
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

function Api.MarketBuyFirstListing()
    yield("/callback ItemSearchResult true 2 0")
end

-- 開機時判斷身上是否已有解讀過的圖：遊戲沒有原生指令可查，只看設定 StartWithDeciphered。
-- 不用「地圖上有旗標」判斷：之前留下的舊旗標會造成誤判
function Api.ProbeDecipheredMap()
    return Cfg.StartWithDeciphered == true
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

local function Log(msg)
    if Cfg.EchoLogs == "All" then yield("/echo [G15] " .. msg) end
end

local function LogError(msg)
    if Cfg.EchoLogs ~= "None" then yield("/echo [G15][錯誤] " .. msg) end
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

local function InDuty()
    return Api.Condition(Cond.boundByDuty) or Api.Condition(Cond.boundByDuty56)
end

local function Busy()
    return Api.Condition(Cond.betweenAreas) or Api.Condition(Cond.casting) or Api.LifestreamBusy()
end

local function StopAutomation()
    Api.WrathOff()
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

local function Mount()
    if Api.Condition(Cond.mounted) then return end
    Api.GeneralAction(GA.mountRoulette)
    yield("/wait 3")
end

local function Dismount()
    if not Api.Condition(Cond.mounted) then return end
    Api.GeneralAction(GA.dismount)
    yield("/wait 1.5")
    if Api.Condition(Cond.flying) or Api.Condition(Cond.mounted) then
        Api.GeneralAction(GA.dismount)   -- 飛行中第一次只會降落
        yield("/wait 1.5")
    end
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
    Api.InteractTarget()
    return true
end

-- 還要買幾張未解讀圖才達到目標庫存
local function MapsToBuy()
    local target = Cfg.SpareMaps + (Api.HasDecipheredMap() and 0 or 1)
    return target - Api.ItemCount(Cfg.MapItemId)
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

local function MaybeDrinkPotion()
    if Cfg.PotionHpPercent <= 0 or Cfg.PotionItemName == "" then return end
    if Api.HpPercent() < Cfg.PotionHpPercent then
        yield('/item "' .. Cfg.PotionItemName .. '"')
    end
end

-------------------------------------------------------------------------------
-- 4. 狀態處理函式
-------------------------------------------------------------------------------

local Handlers = {}

function Handlers.INIT()
    local missing = {}
    for _, p in ipairs({ "vnavmesh", "WrathCombo", "BossModReborn", "Lifestream" }) do
        if not Api.PluginInstalled(p) then table.insert(missing, p) end
    end
    if #missing > 0 then
        LogError("缺少或未啟用的插件：" .. table.concat(missing, "、") .. "（請確認已在 /xlplugins 啟用）")
        return "END"
    end
    if Api.JobId() ~= WARRIOR_JOB_ID then
        LogError("目前職業不是戰士")
        return "END"
    end
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
    for _, k in ipairs({ "ChestName", "PortalName", "SphereName" }) do
        if Cfg[k] == "" then Log("提醒：" .. k .. " 未填，相關步驟會逾時") end
    end
    Cfg.MapItemName = Api.ItemName(Cfg.MapItemId)
    if Cfg.MapItemName == nil then
        LogError("從遊戲資料查不到物品 " .. Cfg.MapItemId .. " 的名稱")
        return "END"
    end
    Log("要買的地圖：" .. Cfg.MapItemName .. "（" .. Cfg.MapItemId .. "）")
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
    -- 補圖：維持 1 張已解讀 + SpareMaps 張未解讀；買不到時本輪不再嘗試，用身上的圖繼續
    if Cfg.AutoBuy and not State.buyBlocked and MapsToBuy() > 0 then
        if not Api.HasDecipheredMap() and Api.ItemCount(Cfg.MapItemId) > 0 then
            State.retries = 0
            return "DECIPHER"   -- 先解讀手上的圖，再回來補備用圖
        end
        return "MB_TRAVEL"
    end
    if Api.HasDecipheredMap() then return "LOCATE" end
    if Api.ItemCount(Cfg.MapItemId) > 0 then
        State.retries = 0
        return "DECIPHER"
    end
    Log("沒有 G15 地圖了")
    return "END"
end

function Handlers.DECIPHER()
    if not State.decipherSent then
        Api.GeneralAction(GA.decipher)
        State.decipherSent = true
        return nil
    end
    if Api.SelectMapInDecipherWindow() then return nil end
    if Api.ConfirmYes() then
        yield("/wait 2")
        State.deciphered = true
        State.decipherSent = false
        Log("解讀完成")
        return "CHECK_MAP"
    end
    if TimedOut("DECIPHER") then
        State.decipherSent = false
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
local function FlagIsFresh()
    if not Api.IsFlagSet() then return false end
    local last = State.lastFlag
    return last == nil or Distance2D(Api.FlagPos(), last) > 1
end

function Handlers.LOCATE()
    if FlagIsFresh() and Api.FlagTerritory() == ELPIS_TERRITORY then
        Api.CloseAddon("AreaMap")
        return "TRAVEL"
    end
    if not State.sent then
        Log("等待藏寶點旗標（厄爾庇斯）：XivTreasureParty 會自動打，或請手動插旗")
        State.sent = true
    end
    if Elapsed() > Cfg.FlagWait then
        LogError("等不到藏寶點旗標")
        return "ERROR"
    end
end

local function FlyToFlag()
    Api.NavMoveTo(Api.FlagPos(), true)
end

function Handlers.TRAVEL()
    if Busy() then return nil end

    if Api.Territory() ~= ELPIS_TERRITORY then
        if not State.teleportSent then
            Api.Teleport(Api.ResolveAetheryte(Cfg.AetheryteName, ELPIS_TERRITORY))
            State.teleportSent = true
        end
        return nil
    end
    State.teleportSent = false

    local flag = Api.FlagPos()
    if Distance2D(Api.PlayerPos(), flag) < Cfg.DigRadius and not Api.NavRunning() then
        State.digOffsetIdx = 0
        return "DIG"
    end

    if not Api.NavReady() then return nil end
    if not Api.NavRunning() then
        Mount()
        if Cfg.UseSprint and not Api.Condition(Cond.mounted) then Api.GeneralAction(GA.sprint) end
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
        Api.NavMoveTo(Vector3(f.X + o[1], f.Y, f.Z + o[2]), false)
        return "DIG"
    end
end

function Handlers.OPEN_COFFER()
    if Api.Condition(Cond.inCombat) then
        State.deciphered = false   -- 觸發陷阱時地圖已消耗
        State.lastFlag = Api.FlagPos()
        return "FIELD_COMBAT"
    end
    if Api.Condition(Cond.occupiedInEvent) then return nil end
    ApproachAndInteract(Cfg.ChestName)
    Api.ConfirmYes()
    if TimedOut("OPEN_COFFER") then return "ERROR" end
end

local function CombatTick()
    if not State.wrathOn then
        Api.WrathOn()
        State.wrathOn = true
    end
    MaybeDrinkPotion()
end

local function LeaveCombat()
    Api.WrathOff()
    State.wrathOn = false
end

function Handlers.FIELD_COMBAT()
    if Api.Condition(Cond.dead) then LeaveCombat(); return "DEAD" end
    if Api.Condition(Cond.inCombat) then
        CombatTick()
        return nil
    end
    if Api.HasHostileNearby(30) then return nil end
    LeaveCombat()
    if Api.GetEntity(Cfg.ChestName) == nil then
        Log("寶箱已消失（可能超過戰鬥時限）")
        return "CHECK_MAP"
    end
    return "LOOT"
end

function Handlers.LOOT()
    if Api.GetEntity(Cfg.ChestName) == nil then
        State.mapsDone = State.mapsDone + 1
        State.errors = 0
        Log("完成第 " .. State.mapsDone .. " 張")
        return "PORTAL_CHECK"
    end
    if Api.Condition(Cond.occupiedInEvent) then return nil end
    ApproachAndInteract(Cfg.ChestName)
    if TimedOut("LOOT") then return "ERROR" end
end

function Handlers.PORTAL_CHECK()
    if Api.GetEntity(Cfg.PortalName) ~= nil then
        if Cfg.EnterDungeon then return "ENTER_DUNGEON" end
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

---------------------------------------------------------------- 買圖子流程（市場板）
-- 目標庫存：1 張已解讀 + SpareMaps 張未解讀。流程：買圖 → 解讀 → 買圖 → 出發挖寶

-- 到市場板：傳送到城市大水晶 → vnavmesh 走到 MarketX/Y/Z → 開市場板
function Handlers.MB_TRAVEL()
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
    if Api.AddonReady("ItemSearch") then
        Api.MarketSearch(Cfg.MapItemName)
        return "MB_SEARCH"
    end
    -- 市場板離站位太遠時，ApproachAndInteract 會先走近再互動
    if not State.sent and not Api.Condition(Cond.occupiedInEvent) then
        State.sent = ApproachAndInteract(Cfg.MarketBoardName)
    end
    if TimedOut("MB_OPEN") then return "ERROR" end
end

function Handlers.MB_SEARCH()
    if Api.AddonReady("ItemSearchResult") then return "MB_LIST" end
    -- 搜尋結果需要時間載入；每 3 秒點一次第 1 個結果，直到清單打開
    if Elapsed() - (State.lastClick or -10) > 3 and Elapsed() > 1.5 then
        Api.MarketOpenFirstResult()
        State.lastClick = Elapsed()
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
        if MapsToBuy() > 0 then
            Api.CloseAddon("ItemSearchResult")   -- 回到搜尋結果，重新打開清單取得最新價格
            return "MB_SEARCH"
        end
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
    State.buyBlocked = true
    if Api.HasDecipheredMap() or Api.ItemCount(Cfg.MapItemId) > 0 then return "CHECK_MAP" end
    return "END"
end

---------------------------------------------------------------- 寶物庫子流程

function Handlers.DUNGEON_INIT()
    if Api.Condition(Cond.betweenAreas) then
        if TimedOut("DUNGEON_INIT") then return "ERROR" end
        return nil
    end
    State.stage = 1
    return "DUNGEON_SPHERE"
end

function Handlers.DUNGEON_SPHERE()
    if not InDuty() then return "DUNGEON_EXIT" end
    if Api.ConfirmYes() then
        State.rouletteStarted = true
        return nil
    end
    if State.rouletteStarted and Api.Condition(Cond.occupiedInEvent) == false then
        State.rouletteStarted = false
        return "DUNGEON_ROULETTE"
    end
    if not Api.Condition(Cond.occupiedInEvent) then
        ApproachAndInteract(Cfg.SphereName)
    end
    if TimedOut("DUNGEON_SPHERE") then return "ERROR" end
end

function Handlers.DUNGEON_ROULETTE()
    if not InDuty() then return "DUNGEON_EXIT" end
    if Api.Condition(Cond.inCombat) then return "DUNGEON_COMBAT" end
    if TimedOut("DUNGEON_ROULETTE") then return "ERROR" end
end

function Handlers.DUNGEON_COMBAT()
    if Api.Condition(Cond.dead) then
        LeaveCombat()
        Log("寶物庫內陣亡，副本結束")
        return "DUNGEON_EXIT"
    end
    if not InDuty() then LeaveCombat(); return "DUNGEON_EXIT" end
    if Api.Condition(Cond.inCombat) then
        CombatTick()
        return nil
    end
    if Api.HasHostileNearby(40) then return nil end
    LeaveCombat()
    return "DUNGEON_CHEST"
end

function Handlers.DUNGEON_CHEST()
    if not InDuty() then return "DUNGEON_EXIT" end
    if Api.DeclineGamble() then return nil end

    if Api.GetEntity(Cfg.DungeonChestName) == nil and State.chestOpened then
        State.chestOpened = false
        Log("第 " .. State.stage .. " 關完成")
        State.stage = State.stage + 1
        if State.stage <= MAX_STAGES then return "DUNGEON_SPHERE" end
        return "DUNGEON_EXIT"
    end
    if not Api.Condition(Cond.occupiedInEvent) then
        if ApproachAndInteract(Cfg.DungeonChestName) then State.chestOpened = true end
    end
    if TimedOut("DUNGEON_CHEST") then return "ERROR" end
end

function Handlers.DUNGEON_EXIT()
    if not InDuty() and not Busy() then
        local reached = math.min(State.stage, MAX_STAGES)
        table.insert(State.stageLog, reached)
        Log("寶物庫結束，到達第 " .. reached .. " 關")
        return "CHECK_MAP"
    end
    if TimedOut("DUNGEON_EXIT") then return "ERROR" end
end

---------------------------------------------------------------- 錯誤與結束

function Handlers.ERROR()
    StopAutomation()
    State.errors = State.errors + 1
    State.errorCount = State.errorCount + 1
    LogError("狀態 " .. tostring(State.errorFrom) .. " 失敗（連續 " .. State.errors .. "/" .. Cfg.MaxErrors .. "）")
    -- 清掉各狀態的暫存旗標
    State.decipherSent, State.tmapSent, State.teleportSent = false, false, false
    State.digSent, State.chestOpened, State.rouletteStarted = false, false, false
    pcall(CloseMarket)
    if State.errors >= Cfg.MaxErrors then return "END" end
    if InDuty() then return "DUNGEON_EXIT" end
    return "CHECK_MAP"
end

function Handlers.END()
    StopAutomation()
    local stages = #State.stageLog > 0 and table.concat(State.stageLog, ",") or "無"
    yield(string.format("/echo [G15] 結束：完成 %d 張，寶物庫 %d 次（到達關數 %s），錯誤 %d 次，買圖 %d 張共 %d gil",
        State.mapsDone, State.dungeonRuns, stages, State.errorCount, State.mapsBought or 0, State.gilSpent or 0))
    return nil
end

-------------------------------------------------------------------------------
-- 5. 主迴圈
-------------------------------------------------------------------------------

local function Transition(next)
    if next == nil or next == State.current and next ~= "DECIPHER" and next ~= "DIG" then
        return
    end
    if next == "ERROR" then State.errorFrom = State.current end
    Log(State.current .. " → " .. next)
    State.current = next
    State.enteredAt = os.clock()
    State.lastPos, State.rePathed = nil, false
    State.sent, State.lastClick = false, nil
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
        or State.current == "MB_TRAVEL"
    if Api.Condition(Cond.betweenAreas) and not waitsOnLoading then
        yield("/wait 0.5")
    else
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
