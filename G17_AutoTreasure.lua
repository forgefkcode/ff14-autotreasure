--[=====[
[[SND Metadata]]
author: forgefk
version: 0.1.0
description: FF14 G17 自動挖寶（古舊的布拉克斯革地圖，Timeworn Br'aaxskin Map）+ 寶物庫 Cenote Ja Ja Gural（選門型）。由 G15 版改寫。
plugin_dependencies:
- vnavmesh
- WrathCombo
- BossModReborn
configs:
  MapItemId:
    default: 0
    description: 未解讀 G17 地圖的物品 ID（待填，0 = 未設定，INIT 會停止）
  MapItemName:
    default: "Timeworn Br'aaxskin Map"
    description: 未解讀 G17 地圖的物品名稱（依客戶端語系）
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
  MarketAetheryte:
    default: "Tuliyollal"
    description: 買圖要傳送去的城市（/tp 參數）
  MarketBoardName:
    default: "Market Board"
    description: 市場板物件名稱（依客戶端語系）
  EnterDungeon:
    default: true
    description: 出現傳送門時是否進入寶物庫
  DoorChoice:
    default: "Random"
    description: 寶物庫選門方式 Random / First（第一個找到的門）
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
  ChestName:
    default: ""
    description: 野外寶箱物件名稱（待填）
  DungeonChestName:
    default: ""
    description: 寶物庫寶箱物件名稱（空白 = 同 ChestName）
  DoorName:
    default: ""
    description: 寶物庫門的物件名稱（待填，兩扇門通常同名）
  PortalName:
    default: ""
    description: 傳送門物件名稱（待填）
  AetheryteUrqopacha:
    default: "Wachunpelo"
    description: Urqopacha 的傳送目的地
  AetheryteKozamauka:
    default: "Ok'hanu"
    description: Kozama'uka 的傳送目的地
  AetheryteYakTel:
    default: "Iq Br'aax"
    description: Yak T'el 的傳送目的地
  AetheryteShaaloani:
    default: "Hhusatahwi"
    description: Shaaloani 的傳送目的地
  AetheryteHeritageFound:
    default: "Yyasulani Station"
    description: Heritage Found 的傳送目的地
  DecipherCommand:
    default: "/ac Decipher"
    description: 解讀指令（中文客戶端可能是 /ac 解讀）
  DigCommand:
    default: "/ac Dig"
    description: 挖寶指令（中文客戶端可能是 /ac 挖掘）
  EchoLogs:
    default: "All"
    description: 日誌層級 All / Errors / None
[[End Metadata]]
--]=====]

--[[
與 G15 版的差異
  - 藏寶點分布在黃金版 5 個地區（Living Memory 除外），TRAVEL 依旗標所在地區傳送
  - 寶物庫 Cenote Ja Ja Gural 是選門型：每關開寶箱 → 打怪 → 領獎拿鑰匙 → 兩扇門選一扇，
    選錯會被移出副本；最多 5 關，第 5 關是 Boss（Bull Apollyon 或 Golden Molter）
  - G17 是 8 人圖，單刷野外陷阱與寶物庫的難度沒有實測來源

結構
  1. 常數與設定
  2. Api 轉接層：所有待確認的遊戲／插件呼叫都集中在這裡，實測後只改這一層
  3. 工具函式
  4. 狀態處理函式（主流程 + 寶物庫子流程）
  5. 主迴圈
]]

-------------------------------------------------------------------------------
-- 1. 常數與設定
-------------------------------------------------------------------------------

local WARRIOR_JOB_ID = 21

-- 黃金版地區 territory ID（TODO 待確認）→ 對應的傳送設定
local G17_ZONES = {
    [1187] = { name = "Urqopacha",      aetheryteKey = "AetheryteUrqopacha" },
    [1188] = { name = "Kozama'uka",     aetheryteKey = "AetheryteKozamauka" },
    [1189] = { name = "Yak T'el",       aetheryteKey = "AetheryteYakTel" },
    [1190] = { name = "Shaaloani",      aetheryteKey = "AetheryteShaaloani" },
    [1191] = { name = "Heritage Found", aetheryteKey = "AetheryteHeritageFound" },
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

local Cfg = {}
for _, k in ipairs({
    "MapItemId", "MapItemName", "MaxMaps", "EnterDungeon", "AutoBuy", "SpareMaps",
    "MaxMapPrice", "GilFloor", "MarketAetheryte", "MarketBoardName", "DoorChoice", "DigRadius", "PortalWait",
    "PotionHpPercent", "PotionItemName", "UseSprint", "MaxErrors", "ChestName", "DungeonChestName",
    "DoorName", "PortalName", "AetheryteUrqopacha", "AetheryteKozamauka", "AetheryteYakTel",
    "AetheryteShaaloani", "AetheryteHeritageFound", "DecipherCommand", "DigCommand", "EchoLogs",
}) do
    Cfg[k] = Config.Get(k)
end
if Cfg.DungeonChestName == nil or Cfg.DungeonChestName == "" then
    Cfg.DungeonChestName = Cfg.ChestName
end

-- 各狀態逾時（秒），建議初值，實測後調整
local Timeout = {
    CHECK_MAP       = 3,
    DECIPHER        = 10,
    LOCATE          = 10,
    TRAVEL          = 240,
    DIG             = 8,
    OPEN_COFFER     = 15,
    FIELD_COMBAT    = 600,
    LOOT            = 10,
    PORTAL_CHECK    = Cfg.PortalWait,
    ENTER_DUNGEON   = 60,
    DEAD            = 120,
    MB_TRAVEL       = 120,
    MB_OPEN         = 15,
    MB_SEARCH       = 20,
    MB_LIST         = 15,
    MB_BUY          = 15,
    DUNGEON_INIT    = 30,
    DUNGEON_CHEST   = 20,
    DUNGEON_COMBAT  = 3600,  -- 副本限時 60 分鐘
    DUNGEON_LOOT    = 15,
    DUNGEON_DOOR    = 30,
    DUNGEON_PASSAGE = 30,
    DUNGEON_EXIT    = 90,
}

local DECIPHER_RETRIES = 2
local DIG_RETRIES      = 3
local DIG_OFFSET       = 5
local STUCK_INTERVAL   = 10
local STUCK_DISTANCE   = 1
local MAX_STAGES       = 5

-------------------------------------------------------------------------------
-- 2. Api 轉接層（SND v2 API；標 TODO 者待實測修正）
-------------------------------------------------------------------------------

local Api = {}

function Api.Condition(id)
    return Svc.Condition[id] == true
end

function Api.PluginInstalled(name)
    return IPC.IsInstalled(name)
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

-- TODO 待確認：已解讀地圖如何直接查詢未查到，目前以腳本自己的紀錄判斷
function Api.HasDecipheredMap()
    return State.deciphered
end

function Api.IsFlagSet()
    return Instances.Map.IsFlagMarkerSet
end

function Api.FlagTerritory()
    return Instances.Map.Flag.TerritoryId
end

function Api.FlagPos()
    return Instances.Map.Flag.Vector3
end

function Api.GetEntity(name)
    if name == nil or name == "" then return nil end
    return Entity.GetEntityByName(name)
end

-- TODO 待確認：列舉同名物件的方式（門有兩扇且同名）
function Api.GetEntities(name)
    local list = {}
    if name == nil or name == "" then return list end
    for i = 0, Svc.Objects.Length - 1 do
        local o = Svc.Objects[i]
        if o ~= nil and o.Name ~= nil and o.Name.TextValue == name then
            table.insert(list, o)
        end
    end
    return list
end

function Api.Target(name)
    local e = Api.GetEntity(name)
    if e == nil then return false end
    e:SetAsTarget()
    return true
end

-- TODO 待確認：以 Dalamud 物件設為目標的方式
function Api.TargetObject(obj)
    Svc.Targets.Target = obj
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

-- TODO 待確認：停止指令名稱
function Api.NavStop()
    yield("/vnav stop")
end

function Api.WrathOn()  yield("/wrath auto on")  end
function Api.WrathOff() yield("/wrath auto off") end

-- TODO 待確認：用原生 /tp 還是 Lifestream；目前每個地區傳到固定的以太之光，不是最近的那個
function Api.TeleportToZone(territory)
    local zone = G17_ZONES[territory]
    if zone == nil then return false end
    yield("/tp " .. Cfg[zone.aetheryteKey])
    return true
end

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

-- 強欲之罠（Gambler's Lure，高低猜）：一律放棄。TODO 待確認 addon 名稱與「放棄」的 callback 參數
local GAMBLE_ADDON = "SelectYesno"
function Api.DeclineGamble()
    if Api.AddonReady(GAMBLE_ADDON) then
        yield("/callback " .. GAMBLE_ADDON .. " true 1")
        return true
    end
    return false
end

-- TODO 待確認：通關第 5 關後離開副本的方式
function Api.LeaveDuty()
    InstancedContent.LeaveCurrentContent()
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

-- TODO 待確認：開機時偵測身上是否已有解讀過的圖。有的話 /tmap 會打開地圖視窗，沒有則只跳錯誤訊息
function Api.ProbeDecipheredMap()
    Api.CloseAddon("AreaMap")
    yield("/wait 0.5")
    yield("/tmap")
    yield("/wait 1.5")
    local has = Api.AddonReady("AreaMap")
    Api.CloseAddon("AreaMap")
    return has
end

-- 手動中止：目前在 SND 介面按停止即可（直接終止，不跑 END 統計）
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
    if Cfg.EchoLogs == "All" then yield("/echo [G17] " .. msg) end
end

local function LogError(msg)
    if Cfg.EchoLogs ~= "None" then yield("/echo [G17][錯誤] " .. msg) end
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
    return Api.Condition(Cond.betweenAreas) or Api.Condition(Cond.casting)
end

local function StopAutomation()
    Api.WrathOff()
    Api.NavStop()
end

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
    yield('/gaction "Mount Roulette"')
    yield("/wait 3")
end

local function Dismount()
    if not Api.Condition(Cond.mounted) then return end
    yield('/gaction "Dismount"')
    yield("/wait 1.5")
    if Api.Condition(Cond.flying) or Api.Condition(Cond.mounted) then
        yield('/gaction "Dismount"')
        yield("/wait 1.5")
    end
end

-- 已選好目標時走過去並互動；回傳 true 表示已送出互動
local function ApproachAndInteractTarget()
    local t = Entity.Target
    if t == nil then return false end
    if t.DistanceTo ~= nil and t.DistanceTo > 3 then
        if not Api.NavRunning() then yield("/vnav movetarget") end
        return false
    end
    Api.NavStop()
    Api.WrathOff()   -- 互動保護
    Api.InteractTarget()
    return true
end

local function ApproachAndInteract(name)
    if not Api.Target(name) then return false end
    return ApproachAndInteractTarget()
end

-- 還要買幾張未解讀圖才達到目標庫存
local function MapsToBuy()
    local target = Cfg.SpareMaps + (Api.HasDecipheredMap() and 0 or 1)
    return target - Api.ItemCount(Cfg.MapItemId)
end

local function CloseMarket()
    Api.CloseAddon("ItemSearchResult")
    yield("/wait 0.5")
    Api.CloseAddon("ItemSearch")
end

local function MaybeDrinkPotion()
    if Cfg.PotionHpPercent <= 0 or Cfg.PotionItemName == "" then return end
    if Api.HpPercent() < Cfg.PotionHpPercent then
        yield('/item "' .. Cfg.PotionItemName .. '"')
    end
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

-------------------------------------------------------------------------------
-- 4. 狀態處理函式
-------------------------------------------------------------------------------

local Handlers = {}

function Handlers.INIT()
    local missing = {}
    for _, p in ipairs({ "vnavmesh", "WrathCombo", "BossModReborn" }) do
        if not Api.PluginInstalled(p) then table.insert(missing, p) end
    end
    if #missing > 0 then
        LogError("缺少插件：" .. table.concat(missing, "、"))
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
    for _, k in ipairs({ "ChestName", "PortalName", "DoorName" }) do
        if Cfg[k] == "" then Log("提醒：" .. k .. " 未填，相關步驟會逾時") end
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
    Log("沒有 G17 地圖了")
    return "END"
end

function Handlers.DECIPHER()
    if not State.decipherSent then
        yield(Cfg.DecipherCommand)
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

-- LOCATE：/tmap 後由 Globetrotter 在精確藏寶點插旗，或使用者手動插旗；旗標須在 G17 的 5 個地區之一
function Handlers.LOCATE()
    if Api.IsFlagSet() and G17_ZONES[Api.FlagTerritory()] ~= nil then
        Log("藏寶點在 " .. G17_ZONES[Api.FlagTerritory()].name)
        return "TRAVEL"
    end
    if not State.tmapSent then
        yield("/tmap")
        State.tmapSent = true
        return nil
    end
    if TimedOut("LOCATE") then
        State.tmapSent = false
        LogError("無法取得藏寶點：請安裝 Globetrotter 或手動插旗後重新啟動")
        return "ERROR"
    end
end

local function FlyToFlag()
    Api.NavMoveTo(Api.FlagPos(), true)
end

function Handlers.TRAVEL()
    if Busy() then return nil end

    local target = Api.FlagTerritory()
    if Api.Territory() ~= target then
        if not State.teleportSent then
            if not Api.TeleportToZone(target) then return "ERROR" end
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
        if Cfg.UseSprint and not Api.Condition(Cond.mounted) then yield('/gaction "Sprint"') end
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
        yield(Cfg.DigCommand)
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
        return "FIELD_COMBAT"
    end
    if Api.Condition(Cond.occupiedInEvent) then return nil end
    ApproachAndInteract(Cfg.ChestName)
    Api.ConfirmYes()
    if TimedOut("OPEN_COFFER") then return "ERROR" end
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
    Api.ConfirmYes()
    if TimedOut("DEAD") then return "ERROR" end
end

---------------------------------------------------------------- 買圖子流程（市場板）
-- 目標庫存：1 張已解讀 + SpareMaps 張未解讀。流程：買圖 → 解讀 → 買圖 → 出發挖寶

function Handlers.MB_TRAVEL()
    if Busy() then return nil end
    if Api.GetEntity(Cfg.MarketBoardName) == nil then
        if not State.sent then
            Api.NavStop()
            yield("/tp " .. Cfg.MarketAetheryte)
            State.sent = true
        end
        if TimedOut("MB_TRAVEL") then return "ERROR" end
        return nil
    end
    Api.Target(Cfg.MarketBoardName)
    local t = Entity.Target
    if t ~= nil and t.DistanceTo ~= nil and t.DistanceTo <= 3 then
        Api.NavStop()
        Dismount()
        return "MB_OPEN"
    end
    if not Api.NavRunning() then yield("/vnav movetarget") end
    if CheckStuck(function() yield("/vnav movetarget") end) == "stuck" then return "ERROR" end
    if TimedOut("MB_TRAVEL") then return "ERROR" end
end

function Handlers.MB_OPEN()
    if Api.AddonReady("ItemSearch") then
        Api.MarketSearch(Cfg.MapItemName)
        return "MB_SEARCH"
    end
    if not State.sent then
        Api.Target(Cfg.MarketBoardName)
        Api.InteractTarget()
        State.sent = true
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
        CloseMarket()
        return "CHECK_MAP"
    end
    if Api.ConfirmYes() then return nil end
    if TimedOut("MB_BUY") then return "ERROR" end
end

-- 買不到（沒貨、太貴、gil 不足）：身上還有可用的圖就先去挖，否則結束
function Handlers.MB_FAIL()
    CloseMarket()
    State.buyBlocked = true
    if Api.HasDecipheredMap() or Api.ItemCount(Cfg.MapItemId) > 0 then return "CHECK_MAP" end
    return "END"
end

---------------------------------------------------------------- 寶物庫子流程（選門型）
-- 每關：DUNGEON_CHEST（開箱觸發陷阱）→ DUNGEON_COMBAT → DUNGEON_LOOT（領獎、拿鑰匙）
--       → 第 1–4 關：DUNGEON_DOOR（選門）→ DUNGEON_PASSAGE（判斷過門或被踢）→ 下一關
--       → 第 5 關：DUNGEON_EXIT

function Handlers.DUNGEON_INIT()
    if Api.Condition(Cond.betweenAreas) then
        if TimedOut("DUNGEON_INIT") then return "ERROR" end
        return nil
    end
    State.stage = 1
    return "DUNGEON_CHEST"
end

function Handlers.DUNGEON_CHEST()
    if not InDuty() then return "DUNGEON_EXIT" end
    if Api.Condition(Cond.inCombat) then return "DUNGEON_COMBAT" end
    if Api.ConfirmYes() then return nil end
    if not Api.Condition(Cond.occupiedInEvent) then
        ApproachAndInteract(Cfg.DungeonChestName)
    end
    if TimedOut("DUNGEON_CHEST") then return "ERROR" end
end

-- 機運怪（Alpaca/Uolon of Fortune、Turali 蔬菜、Tuligora Queen）一律交給 Wrath 自動選目標；
-- 蔬菜需依號碼由小到大擊殺，Wrath 不會照順序打，會損失額外獎勵
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
    return "DUNGEON_LOOT"
end

function Handlers.DUNGEON_LOOT()
    if not InDuty() then return "DUNGEON_EXIT" end
    if Api.Condition(Cond.inCombat) then return "DUNGEON_COMBAT" end   -- 開箱又觸發額外怪
    if Api.DeclineGamble() then return nil end

    if Api.GetEntity(Cfg.DungeonChestName) == nil and State.chestOpened then
        State.chestOpened = false
        Log("第 " .. State.stage .. " 關完成")
        if State.stage >= MAX_STAGES then return "DUNGEON_EXIT" end
        return "DUNGEON_DOOR"
    end
    if not Api.Condition(Cond.occupiedInEvent) then
        if ApproachAndInteract(Cfg.DungeonChestName) then State.chestOpened = true end
    end
    if TimedOut("DUNGEON_LOOT") then return "ERROR" end
end

-- 選門：兩扇門同名，Random = 隨機挑一扇，First = 永遠挑第一個找到的
-- TODO 彩虹箭頭與門的閃光有時會提示正確的門，偵測方式未知，目前不使用
function Handlers.DUNGEON_DOOR()
    if not InDuty() then return "DUNGEON_EXIT" end
    if Api.ConfirmYes() then return nil end

    if State.chosenDoor == nil then
        local doors = Api.GetEntities(Cfg.DoorName)
        if #doors == 0 then
            if TimedOut("DUNGEON_DOOR") then return "ERROR" end
            return nil
        end
        local idx = Cfg.DoorChoice == "Random" and math.random(#doors) or 1
        State.chosenDoor = doors[idx]
        Log("第 " .. State.stage .. " 關選門：" .. idx .. "/" .. #doors)
    end

    Api.TargetObject(State.chosenDoor)
    if not Api.Condition(Cond.occupiedInEvent) and ApproachAndInteractTarget() then
        State.doorOpenedAt = os.clock()
        return "DUNGEON_PASSAGE"
    end
    if TimedOut("DUNGEON_DOOR") then return "ERROR" end
end

-- 開門結果有四種：直接開、短暫關閉後開、警報後彩虹光開、警報後移出副本
function Handlers.DUNGEON_PASSAGE()
    if not InDuty() then
        State.chosenDoor = nil
        Log("選錯門，被移出副本")
        return "DUNGEON_EXIT"
    end
    if Busy() or Api.Condition(Cond.occupiedInEvent) then return nil end

    -- 門開了：往前走到下一關的寶箱
    if Api.GetEntity(Cfg.DungeonChestName) ~= nil then
        State.chosenDoor = nil
        State.stage = State.stage + 1
        Log("進入第 " .. State.stage .. " 關")
        return "DUNGEON_CHEST"
    end
    if not Api.NavRunning() and State.chosenDoor ~= nil then
        -- TODO 門後的通道方向未知；先朝門的位置再往前移動，實測後改成下一關中心座標
        local d, p = State.chosenDoor.Position, Api.PlayerPos()
        Api.NavMoveTo(Vector3(d.X + (d.X - p.X), d.Y, d.Z + (d.Z - p.Z)), false)
    end
    if TimedOut("DUNGEON_PASSAGE") then return "ERROR" end
end

function Handlers.DUNGEON_EXIT()
    if not InDuty() and not Busy() then
        local reached = math.min(State.stage, MAX_STAGES)
        table.insert(State.stageLog, reached)
        Log("寶物庫結束，到達第 " .. reached .. " 關")
        return "CHECK_MAP"
    end
    if InDuty() and not State.leaveSent and not Api.Condition(Cond.dead) then
        Api.LeaveDuty()
        State.leaveSent = true
    end
    Api.ConfirmYes()
    if TimedOut("DUNGEON_EXIT") then return "ERROR" end
end

---------------------------------------------------------------- 錯誤與結束

function Handlers.ERROR()
    StopAutomation()
    State.errors = State.errors + 1
    State.errorCount = State.errorCount + 1
    LogError("狀態 " .. tostring(State.errorFrom) .. " 失敗（連續 " .. State.errors .. "/" .. Cfg.MaxErrors .. "）")
    State.decipherSent, State.tmapSent, State.teleportSent = false, false, false
    State.digSent, State.chestOpened, State.leaveSent = false, false, false
    pcall(CloseMarket)
    State.chosenDoor = nil
    if State.errors >= Cfg.MaxErrors then return "END" end
    if InDuty() then return "DUNGEON_EXIT" end
    return "CHECK_MAP"
end

function Handlers.END()
    StopAutomation()
    local stages = #State.stageLog > 0 and table.concat(State.stageLog, ",") or "無"
    yield(string.format("/echo [G17] 結束：完成 %d 張，寶物庫 %d 次（到達關數 %s），錯誤 %d 次，買圖 %d 張共 %d gil",
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
    if next == "CHECK_MAP" then State.leaveSent = false end
    Log(State.current .. " → " .. next)
    State.current = next
    State.enteredAt = os.clock()
    State.lastPos, State.rePathed = nil, false
    State.sent, State.lastClick = false, nil
end

math.randomseed(os.time())

while true do
    if Api.StopRequested() and State.current ~= "END" then
        Transition("END")
    end

    if State.current == "END" then
        Handlers.END()
        break
    end

    local waitsOnLoading = State.current == "DUNGEON_INIT" or State.current == "TRAVEL"
        or State.current == "ENTER_DUNGEON" or State.current == "DUNGEON_EXIT"
        or State.current == "MB_TRAVEL"
        or State.current == "DUNGEON_PASSAGE"
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
            result = "ERROR"
        end
        Transition(result)
        yield("/wait 0.3")
    end
end
