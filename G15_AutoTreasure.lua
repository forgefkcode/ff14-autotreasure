--[=====[
[[SND Metadata]]
author: forgefk
version: 0.1.0
description: FF14 G15 自動挖寶（古舊的蛇牛革地圖）+ 寶物庫 The Shifting Gymnasion Agonon。戰士單刷，依「FF14 G15 自動挖寶 SND 架構規格」實作。
plugin_dependencies:
- vnavmesh
- WrathCombo
- Lifestream
chat_message_filter:
  message_contains: "將陷阱引來的魔物全部打倒了"
configs:
  MapItemId:
    default: 39591
    description: 未解讀 G15 地圖的物品 ID（已查好，取自 XIVAPI；0 = 未設定，INIT 會停止）
  MaxRounds:
    default: 0
    description: 要刷幾輪（一輪 = 買齊 1 張已解讀 + 1 張未解讀並兩張都挖完），0 = 無限循環
  MaxMaps:
    default: 0
    description: 本次最多跑幾張，0 = 不限
  AutoBuy:
    default: true
    description: 圖不夠時自動到市場板買圖（維持身上 1 張已解讀 + 1 張未解讀）。事前記得在市場板把要買的地圖加入「我的最愛」
  BossModPlugin:
    default: "Auto"
    description: 閃避用的插件：Auto（有 BossMod 用 BossMod，否則用 BossMod Reborn）/ BossMod / BossModReborn
  BossModPreset:
    default: "VBM Default"
    description: 只用於 BossMod Reborn：啟動時 /bmr ar set 這個預設（打錯名稱 BMR 會強制停用，留空 = 不切換）；BossMod 改用 AI 模式，跟著 Wrath 一起開關
  CrossWorld:
    default: true
    description: 每輪開始前查 Universalis，傳送到資料中心內地圖最便宜的伺服器買圖並挖寶（需要 Lifestream）
  DataCenter:
    default: "陸行鳥"
    description: 要比價的資料中心（Universalis 上的名稱，繁中服是「陸行鳥」）
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
  FavoritesCallback:
    default: "12 6"
    description: 打開市場板「我的最愛」清單的 callback 參數（實測事件 12 會顯示我的最愛，後面的數字不影響；空白 = 不切換）
  MarketBoardName:
    default: ""
    description: 市場板物件名稱（留空 = 自動從遊戲資料取）
  DecipheredItemId:
    default: 2003457
    description: 解讀後的地圖（重要物品）ID，用來判斷身上有沒有已解讀的圖（取自 XIVAPI TreasureHuntRank）
  FlagWait:
    default: 120
    description: 解讀後等藏寶點旗標的秒數（XivTreasureParty 自動打，或你手動插）
  EnterDungeon:
    default: true
    description: 出現傳送門時是否進入寶物庫
  WalkRadius:
    default: 15
    description: 飛到離旗標多近就下坐騎改走路（飛行停點不準，近距離走路比較準）
  DigRadius:
    default: 3
    description: 距離旗標多近開始挖寶
  FieldClearMessage:
    default: "將陷阱引來的魔物全部打倒了！"
    description: 野外陷阱魔物全部打倒時的系統訊息；出現就結束戰鬥去開寶箱
  LeashRadius:
    default: 15
    description: 野外戰鬥時離寶箱（觸發陷阱的位置）多遠就走回去，太遠陷阱戰鬥會被重置
  PortalWait:
    default: 10
    description: 開箱後等待傳送門出現的秒數
  RouletteWait:
    default: 45
    description: 寶物庫戰鬥開始後最多等幾秒找敵人（G15 會先播 30 秒以上的輪盤動畫，怪物之後才出現）
  EnemySearchRange:
    default: 100
    description: 寶物庫內找敵人的範圍（選最近的敵人、確認是否打完都用這個）
  PullActionId:
    default: 46
    description: 選到最近的敵人後施放的起手技能 ID（46 = 飛斧，射程 20）；0 = 不施放
  PotionHpPercent:
    default: 40
    description: HP 低於此百分比時喝藥（0 = 不喝）
  PotionItemName:
    default: ""
    description: 回復藥物品名稱，要與遊戲內一字不差（空白 = 不喝）；背包有 HQ 會優先用 HQ
  PotionCooldown:
    default: 60
    description: 喝藥冷卻秒數（喝過之後至少隔這麼久才會再喝）
  UseSprint:
    default: false
    description: 移動時是否使用衝刺
  MaxErrors:
    default: 3
    description: 連續錯誤幾次後停止腳本
  SphereName:
    default: "召喚魔法陣"
    description: 寶物庫魔法球物件名稱（繁中客戶端）
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
    default: "傳送魔紋"
    description: 寶物庫第 5 關後離開用的傳送門物件名稱
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

-- G15 的 8 個藏寶點的真正座標（含高度），取自 XIVAPI TreasureSpot（TreasureHuntRank 24）→ Level。
-- 格式：{ 地區 ID, X, Y（高度）, Z }
local TREASURE_SPOTS = {
    { 961, 286.73, 6.97, 142.84 },
    { 961, 53.96, 7.30, 158.08 },
    { 961, -230.29, -44.65, 478.54 },
    { 961, 378.37, 147.73, -196.19 },
    { 961, 422.32, 150.71, -598.17 },
    { 961, -423.94, 312.19, -635.18 },
    { 961, -480.29, -33.78, 584.59 },
    { 961, 784.15, 152.14, -145.09 },
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
    MaxRounds        = Config.Get("MaxRounds"),
    MaxMaps          = Config.Get("MaxMaps"),
    EnterDungeon     = Config.Get("EnterDungeon"),
    DecipheredItemId = Config.Get("DecipheredItemId"),
    FlagWait   = Config.Get("FlagWait"),
    AutoBuy          = Config.Get("AutoBuy"),
    BossModPlugin    = Config.Get("BossModPlugin"),
    BossModPreset    = Config.Get("BossModPreset"),
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
    FieldClearMessage = Config.Get("FieldClearMessage"),
    LeashRadius      = Config.Get("LeashRadius"),
    PortalWait       = Config.Get("PortalWait"),
    RouletteWait     = Config.Get("RouletteWait"),
    EnemySearchRange = Config.Get("EnemySearchRange"),
    PullActionId     = Config.Get("PullActionId"),
    PotionHpPercent  = Config.Get("PotionHpPercent"),
    PotionItemName   = Config.Get("PotionItemName"),
    PotionCooldown   = Config.Get("PotionCooldown"),
    UseSprint        = Config.Get("UseSprint"),
    MaxErrors        = Config.Get("MaxErrors"),
    SphereName       = Config.Get("SphereName"),
    ChestName        = Config.Get("ChestName"),
    DungeonChestName = Config.Get("DungeonChestName"),
    PortalName       = Config.Get("PortalName"),
    ExitPortalName   = Config.Get("ExitPortalName"),
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
    FIELD_FIGHT      = 600,
    LOOT             = 10,
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
    DUNGEON_SPHERE   = 15,
    DUNGEON_ROULETTE = 90,   -- 輪盤動畫 30 秒以上
    DUNGEON_COMBAT   = 3600,  -- 副本限時 60 分鐘
    DUNGEON_CHEST    = 120,
    DUNGEON_EXIT     = 180,
}

local DECIPHER_RETRIES = 2
local DIG_RETRIES      = 3
local DIG_OFFSET       = 5
local STUCK_INTERVAL   = 10
local STUCK_DISTANCE   = 1
local MAX_STAGES       = 5

-------------------------------------------------------------------------------
-- 2. Api 轉接層（SND v2 API；標 TODO 者為「待確認事項」，實測後修正）
-------------------------------------------------------------------------------

-- 先宣告 Log / LogError（定義在第 3 段），Api 的函式也要用得到
local Log, LogError

local Api = {}

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

-- 選取最近的敵人（SND 內建 /targetenemy：最近、可選取、還活著的敵對目標），只選一次不鎖定
-- 掃描全場物件，找 maxDistance 內最近的敵人：戰鬥 NPC、敵人類（SubKind 5 = Enemy）、可選取、還活著。
-- 回傳 Dalamud 物件或 nil
function Api.NearestEnemyObject(maxDistance)
    local ok, obj = pcall(function()
        local me = Api.PlayerPos()
        local objs = Svc.Objects
        local best, bestDist = nil, maxDistance * maxDistance
        for i = 0, objs.Length - 1 do
            local o = objs[i]
            if o ~= nil and o.IsTargetable and not o.IsDead
                and tostring(o.ObjectKind) == "BattleNpc" and tonumber(o.SubKind) == 5 then
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

-- 選最近的敵人一次（不鎖定）：先用自己的掃描（maxDistance 內），找不到再用 SND 的 /targetenemy
function Api.TargetNearestEnemy(maxDistance)
    Api.ClearTarget()   -- 先解除舊選取（例如召喚魔法陣、寶箱），選不到敵人時才不會誤判成已選到
    yield("/wait 0.1")
    local o = Api.NearestEnemyObject(maxDistance or 100)
    if o ~= nil and pcall(function() Svc.Targets.Target = o end) then
        yield("/wait 0.1")
        if Entity.Target ~= nil then return true end
    end
    yield("/targetenemy")
    yield("/wait 0.1")
    return Entity.Target ~= nil
end

-- 選最近的敵人後施放起手技能（預設飛斧 46，射程 20）：Wrath 自動循環有時不會自己起手，用它帶動開打。
-- 用技能 ID 直接施放，不按鍵盤，不受熱鍵列配置影響；太遠就先往敵人走（最多 5 秒）
function Api.EngageNearestEnemy(maxDistance)
    if not Api.TargetNearestEnemy(maxDistance) then return false end
    if Cfg.PullActionId == nil or Cfg.PullActionId <= 0 then return true end
    local t = Entity.Target
    if t ~= nil and t.DistanceTo ~= nil and t.DistanceTo > 18 then
        yield("/vnav movetarget")
        for _ = 1, 10 do
            yield("/wait 0.5")
            t = Entity.Target
            if t == nil or t.DistanceTo == nil or t.DistanceTo <= 18 then break end
        end
        Api.NavStop()
    end
    -- 用遊戲原生的 /ac 技能名稱（等同玩家按巨集，對目前目標施放）；技能名稱從遊戲資料取，自動是客戶端語言。
    -- 取不到名稱才退回 Actions.ExecuteAction
    local ok, name = pcall(function() return tostring(Excel.GetRow("Action", Cfg.PullActionId).Name) end)
    t = Entity.Target
    local dist = (t ~= nil and t.DistanceTo ~= nil) and string.format("%.1f", t.DistanceTo) or "?"
    if ok and name ~= nil and name ~= "" and name ~= "nil" then
        Log("施放 " .. name .. "（距離 " .. dist .. "）")
        yield('/ac "' .. name .. '"')
    else
        Log("施放技能 " .. Cfg.PullActionId .. "（距離 " .. dist .. "）")
        pcall(function() Actions.ExecuteAction(Cfg.PullActionId, ActionType.Action) end)
    end
    return true
end

-- maxDistance 內還有沒有敵人：先解除選取再 /targetenemy，選到且夠近才算（太遠的野外怪不算，並取消選取）
function Api.AnyEnemyLeft(maxDistance)
    if not Api.TargetNearestEnemy(maxDistance) then return false end
    local t = Entity.Target
    if t ~= nil and t.DistanceTo ~= nil and t.DistanceTo <= maxDistance then return true end
    Api.ClearTarget()
    return false
end

-- 在背包 4 頁裡找名稱相符的物品，回傳 (物品 ID, 是否有 HQ)；找不到回 nil
function Api.FindInventoryItem(name)
    local foundId, hasHq = nil, false
    local ok = pcall(function()
        for _, container in ipairs({ InventoryType.Inventory1, InventoryType.Inventory2,
                                     InventoryType.Inventory3, InventoryType.Inventory4 }) do
            local items = Inventory.GetInventoryContainer(container).Items
            for i = 0, items.Count - 1 do
                local it = items[i]
                if it ~= nil and not it.IsEmpty then
                    local id = it.BaseItemId
                    if id == foundId or tostring(Excel.GetRow("Item", id).Name) == name then
                        foundId = id
                        if it.IsHighQuality then hasHq = true end
                    end
                end
            end
        end
    end)
    if not ok then return nil end
    return foundId, hasHq
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

-- 開關 Wrath 時同步記錄狀態，CombatTick / TRAVEL 依 State.wrathOn 判斷要不要再開。
-- 用 BossMod（/vbm）時，AI 模式跟著 Wrath 一起開關
function Api.WrathOn()
    yield("/wrath auto on")
    if State.bossCmd == "/vbm" then yield("/vbm ai on") end
    State.wrathOn = true
end

function Api.WrathOff()
    yield("/wrath auto off")
    if State.bossCmd == "/vbm" then yield("/vbm ai off") end
    State.wrathOn = false
end

-- 解讀視窗是 SelectIconString（標題「解讀」）。依名稱在清單裡找這張地圖的位置，
-- 節點路徑取自社群腳本 Narrr13/snd OpenMap.lua。讀不到清單文字時退回第 1 項
function Api.FindDecipherIndex(name)
    for i = 0, 21 do
        local nodeId = i == 0 and 5 or (51000 + i)
        local ok, text = pcall(function() return tostring(Addons.GetAddon("SelectIconString"):GetNode(1, 3, nodeId, 2).Text) end)
        if not ok or text == nil or text == "" or text == "nil" then
            if i == 0 then return 0 end
            break
        end
        if text == name or text:find(name, 1, true) then return i end
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

-- 在市場板左側清單（我的最愛或搜尋結果）依名稱找出這個物品是第幾項（從 0 起算），找不到回 nil。
-- 節點路徑取自社群腳本 ShamelessEnd/SomethingNeedScripts（第 i 項：i = 0 為 5，其後 51000 + i）；
-- 名稱太長時清單會截斷成「...」，比對前半段
function Api.FindInResults(name)
    for i = 0, 99 do
        local nodeId = i == 0 and 5 or (51000 + i)
        local ok, text = pcall(function() return tostring(Addons.GetAddon("ItemSearch"):GetNode(1, 139, nodeId, 13).Text) end)
        if not ok or text == nil or text == "" or text == "nil" then return nil end
        if text == name then return i end
        if text:sub(-3) == "..." and name:find(text:sub(1, -4), 1, true) == 1 then return i end
    end
    return nil
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
    if Cfg.EchoLogs == "All" then yield("/echo [G15] " .. msg) end
end

function LogError(msg)
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

-- 寶物庫（The Shifting Gymnasion Agonon）的地區 ID，取自 XIVAPI ContentFinderCondition
local VAULT_TERRITORY = 1123

-- 是否在寶物庫內：看所在地區。不用角色狀態 34 / 56（被副本綁定），
-- 野外觸發陷阱後那個狀態也會亮，會誤判成已進副本而跳過傳送魔紋
local function InDuty()
    return Api.Territory() == VAULT_TERRITORY
end

local function Busy()
    return Api.Condition(Cond.betweenAreas) or Api.Condition(Cond.casting) or Api.LifestreamBusy()
end

local function StopAutomation()
    Api.WrathOff()
    State.wrathOn = false
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
    State.wrathOn = false
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

-- 喝藥：HP 低於 PotionHpPercent 且距離上次超過 PotionCooldown 秒時，從背包找藥水直接使用（有 HQ 優先用 HQ）。
-- 先掃背包確認有這瓶藥，再直接呼叫遊戲的使用道具（有 HQ 優先用 HQ）
local function MaybeDrinkPotion()
    if Cfg.PotionHpPercent <= 0 or Cfg.PotionItemName == "" then return end
    if Api.HpPercent() >= Cfg.PotionHpPercent then return end
    if os.clock() - (State.lastPotionAt or -1e9) < Cfg.PotionCooldown then return end
    State.lastPotionAt = os.clock()   -- 不管成功與否都等冷卻，避免一直重試
    local id, hq = Api.FindInventoryItem(Cfg.PotionItemName)
    if id == nil then
        if not State.potionWarned then
            Log("背包裡找不到「" .. Cfg.PotionItemName .. "」，無法喝藥")
            State.potionWarned = true
        end
        return
    end
    -- 直接呼叫遊戲的使用道具（ActionType.Item，數字代號 2；HQ 的 ID 要加 1000000）。
    -- 不用 /item：在 Lua 腳本裡它會被當成遊戲聊天指令送出，繁中版沒有這個指令。
    -- 依序試三種寫法，喝完用背包數量確認有沒有成功
    local actionId = hq and (id + 1000000) or id
    local before = Inventory.GetItemCount(id) + Inventory.GetHqItemCount(id)
    local errors = {}
    for _, call in ipairs({
        function() Actions.ExecuteAction(actionId, 2) end,
        function() Actions.ExecuteAction(actionId, ActionType.Item) end,
        function() Actions.ExecuteAction(actionId, "Item") end,
    }) do
        local ok, err = pcall(call)
        if ok then break end
        table.insert(errors, tostring(err))
    end
    yield("/wait 1.5")
    local after = Inventory.GetItemCount(id) + Inventory.GetHqItemCount(id)
    if after < before then
        Log("喝藥：" .. Cfg.PotionItemName .. (hq and "（HQ）" or ""))
    else
        Log("喝藥失敗（藥水數量沒有減少）" .. (#errors > 0 and ("：" .. table.concat(errors, "；")) or ""))
    end
end

-------------------------------------------------------------------------------
-- 4. 狀態處理函式
-------------------------------------------------------------------------------

-- 買圖、換伺服器、解讀期間 Wrath 一律關閉（傳送到藏寶地區後才在 TRAVEL 開啟）
local function EnsureWrathOff()
    if State.wrathOn ~= false then
        Api.WrathOff()
        State.wrathOn = false
    end
end

-- SND 聊天訊息觸發：函式名稱固定為 OnChatMessage，訊息內容在 TriggerData.message（寫法同 pot0to 腳本）。
-- 開頭設定區的 chat_message_filter 限制只有含「將陷阱引來的魔物全部打倒了」的訊息才會觸發，
-- 否則腳本自己印的 /echo 和其他系統訊息每一行都會觸發，可能讓 SND 出現 Unknown error。
-- 改了 FieldClearMessage 的話，開頭的 message_contains 也要一起改
function OnChatMessage()
    local ok, message = pcall(function() return tostring(TriggerData.message) end)
    if ok and message ~= nil and Cfg.FieldClearMessage ~= "" and message:find(Cfg.FieldClearMessage, 1, true) then
        State.fieldCleared = true
    end
end

local Handlers = {}

function Handlers.INIT()
    local missing = {}
    for _, p in ipairs({ "vnavmesh", "WrathCombo", "Lifestream" }) do
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
    -- 閃避插件：BossMod（/vbm）或 BossMod Reborn（/bmr），兩個指令格式相同
    local hasVbm, hasBmr = Api.PluginInstalled("BossMod"), Api.PluginInstalled("BossModReborn")
    local choice = Cfg.BossModPlugin or "Auto"
    local bossCmd = nil
    if choice == "BossMod" or (choice == "Auto" and hasVbm) then
        bossCmd = hasVbm and "/vbm" or nil
    elseif choice == "BossModReborn" or (choice == "Auto" and hasBmr) then
        bossCmd = hasBmr and "/bmr" or nil
    end
    if bossCmd == nil then
        LogError("沒有偵測到啟用中的 BossMod / BossMod Reborn（設定：" .. choice .. "）")
        return "END"
    end
    if hasVbm and hasBmr then Log("提醒：BossMod 和 BossMod Reborn 同時啟用，兩個會搶著閃避，建議只開一個") end
    State.bossCmd = bossCmd
    if bossCmd == "/vbm" then
        -- BossMod（繁中版）沒有內建「VBM Default」預設，改用 AI 模式閃避，跟著 Wrath 一起開關
        Log("BossMod AI 模式會跟著 Wrath 一起開關")
    elseif Cfg.BossModPreset ~= nil and Cfg.BossModPreset ~= "" then
        yield(bossCmd .. " ar set " .. Cfg.BossModPreset)
        Log("BossMod Reborn 預設：" .. Cfg.BossModPreset)
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
    State.wrathOn = false
    return "CHECK_MAP"
end

function Handlers.CHECK_MAP()
    if Cfg.MaxMaps > 0 and State.mapsDone >= Cfg.MaxMaps then
        Log("已達 MaxMaps")
        return "END"
    end
    -- 一輪 = 買齊 1 張已解讀 + 1 張未解讀，兩張都挖完（身上完全沒圖）才開始下一輪。
    -- 每輪開始：CrossWorld 時先查最便宜的伺服器並傳送過去（PICK_WORLD → WORLD_TRAVEL），
    -- 再依序：買 1 張 → 關市場板 → 解讀 → 再買 1 張 → 關市場板 → 出發挖寶。買不到時本輪不再嘗試，用身上的圖繼續
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
            if Cfg.CrossWorld and not State.worldChosen then return "PICK_WORLD" end
            if not hasUndeciphered then return "MB_TRAVEL" end
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
    Log("沒有 G15 地圖了")
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
local function FlagIsFresh()
    if not Api.IsFlagSet() then return false end
    local last = State.lastFlag
    if last == nil or Distance2D(Api.FlagPos(), last) > 1 then return true end
    return Elapsed() > 5
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

    if Api.Territory() ~= ELPIS_TERRITORY then
        if not State.teleportSent then
            Api.Teleport(Api.ResolveAetheryte(Cfg.AetheryteName, ELPIS_TERRITORY))
            State.teleportSent = true
        end
        return nil
    end
    State.teleportSent = false

    -- 已在藏寶地區：開啟 Wrath（買圖、傳送期間是關的）
    if not State.wrathOn then
        Api.WrathOn()
        State.wrathOn = true
        Log("已到藏寶地區，開啟 Wrath")
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
    -- 戰鬥開始時選一次最近的敵人，之後交給 Wrath，不保持鎖定
    if not State.combatTargeted then
        Api.EngageNearestEnemy(InDuty() and Cfg.EnemySearchRange or 30)
        State.combatTargeted = true
    end
    if not State.wrathOn then
        Api.NavStop()
        Api.WrathOn()
    end
    MaybeDrinkPotion()
end

local function LeaveCombat()
    Api.WrathOff()
    State.wrathOn = false
end

-- 野外戰鬥結束：聊天出現 FieldClearMessage（「將陷阱引來的魔物全部打倒了！」）就算打完，
-- 去開寶箱並接著找傳送魔紋。保險：沒收到訊息時，脫離戰鬥滿 10 秒且附近找不到敵人也算結束
function Handlers.FIELD_COMBAT()
    if Api.Condition(Cond.dead) then LeaveCombat(); return "DEAD" end
    local cleared = State.fieldCleared
    if not cleared and Api.Condition(Cond.inCombat) then
        State.lastInCombat = Elapsed()
        StayNearCoffer()
        CombatTick()
        return nil
    end
    if not cleared then
        if Elapsed() - (State.lastInCombat or 0) < 10 then return nil end
        if Api.AnyEnemyLeft(30) then
            State.lastInCombat = Elapsed()
            CombatTick()
            return nil
        end
    end
    State.fieldCleared = false
    Log(cleared and "陷阱魔物全部打倒，去開寶箱" or "附近沒有敵人了，去開寶箱")
    LeaveCombat()
    Api.ClearTarget()
    yield("/wait 3")
    if Api.GetEntity(Cfg.ChestName) == nil and Api.GetEntity(Cfg.PortalName) == nil then
        Log("寶箱已消失（可能超過戰鬥時限）")
        return "CHECK_MAP"
    end
    return "LOOT"
end

-- 領獎：可能有多個寶箱，還有可互動的寶箱就一個一個開，全部開完才看有沒有傳送魔紋
function Handlers.LOOT()
    local chest = Api.GetEntity(Cfg.ChestName)
    local portal = Api.GetEntity(Cfg.PortalName)
    if chest == nil then
        State.mapsDone = State.mapsDone + 1
        State.errors = 0
        Log("完成第 " .. State.mapsDone .. " 張")
        return "PORTAL_CHECK"
    end
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

-- 先打完周圍的怪：下坐騎、選最近的敵人並按 1、開 Wrath；脫離戰鬥滿 3 秒就回到被打斷的步驟
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

---------------------------------------------------------------- 跨伺服器（每輪開始時）

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

-- 找地圖的順序（每 4 秒一輪）：
--   1. 清單上已經有這張地圖（我的最愛分頁、或上次的搜尋結果）→ 依名稱找到那一項並點開
--   2. 有填 FavoritesCallback → 切到我的最愛分頁
--   3. 剪貼簿貼上搜尋（最多 SEARCH_AUTO_TRIES 次）
--   4. 都不行就請使用者手動切到我的最愛或搜尋，腳本繼續找、找到就自動點開
local SEARCH_AUTO_TRIES = 2

function Handlers.MB_SEARCH()
    if Api.AddonReady("ItemSearchResult") then return "MB_LIST" end
    if Elapsed() - (State.lastSearch or -10) < 4 then return nil end
    State.lastSearch = Elapsed()

    local idx = Api.FindInResults(Cfg.MapItemName)
    if idx ~= nil then
        Api.MarketOpenResult(idx)
        return nil
    end

    if Cfg.FavoritesCallback ~= "" and not State.favoritesTried then
        yield("/callback ItemSearch true " .. Cfg.FavoritesCallback)
        State.favoritesTried = true
        Log("切到我的最愛")
        yield("/wait 1")
        idx = Api.FindInResults(Cfg.MapItemName)
        if idx ~= nil then Api.MarketOpenResult(idx) end
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
        return nil
    end

    if not State.manualPrompted then
        Log("找不到「" .. Cfg.MapItemName .. "」，請確認已加入市場板的我的最愛，並手動切到我的最愛分頁，腳本會接著自動購買")
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
    if Api.Condition(Cond.inCombat) then return "DUNGEON_COMBAT" end
    -- SphereName 沒填或找不到魔法球：請使用者手動點，腳本等最多 180 秒，之後的流程照常自動
    if Cfg.SphereName == "" or Api.GetEntity(Cfg.SphereName) == nil then
        if not State.manualPrompted then
            Log(Cfg.SphereName == "" and "SphereName 未填，請手動點魔法球（腳本會接著自動處理）"
                or ("找不到「" .. Cfg.SphereName .. "」，請確認 SphereName 或手動點魔法球"))
            State.manualPrompted = true
        end
        if Elapsed() > 180 then return "ERROR" end
        return nil
    end
    if not Api.Condition(Cond.occupiedInEvent) then
        ApproachAndInteract(Cfg.SphereName)
    end
    if TimedOut("DUNGEON_SPHERE") then return "ERROR" end
end

-- 輪盤停下、怪物出現後，選最近的敵人開打（怪物不一定會主動攻擊），每 2 秒找一次
function Handlers.DUNGEON_ROULETTE()
    if not InDuty() then return "DUNGEON_EXIT" end
    if Api.Condition(Cond.inCombat) then return "DUNGEON_COMBAT" end
    if Elapsed() > 2 and Elapsed() - (State.lastEnemyScan or -10) > 2 then
        State.lastEnemyScan = Elapsed()
        if Api.EngageNearestEnemy(Cfg.EnemySearchRange) then
            State.combatTargeted = true
            Api.WrathOn()
            return "DUNGEON_COMBAT"
        end
    end
    if TimedOut("DUNGEON_ROULETTE") then return "ERROR" end
end

function Handlers.DUNGEON_COMBAT()
    if Api.Condition(Cond.dead) then
        LeaveCombat()
        Log("寶物庫內陣亡，副本結束")
        return "DUNGEON_EXIT"
    end
    if not InDuty() then LeaveCombat(); return "DUNGEON_EXIT" end
    -- 一進入就選最近的敵人。G15 進入時會先播輪盤動畫（30 秒以上），怪物動畫結束才出現：
    -- 每秒重試，最多等 RouletteWait 秒；選到後交給 Wrath，不保持鎖定
    if not State.combatTargeted then
        if Elapsed() - (State.lastEnemyScan or -10) >= 1 then
            State.lastEnemyScan = Elapsed()
            if Api.EngageNearestEnemy(Cfg.EnemySearchRange) then
                State.combatTargeted, State.enemySeen = true, true
                Log("選取最近的敵人")
            elseif Elapsed() > Cfg.RouletteWait then
                State.combatTargeted = true
            end
        end
        if not State.wrathOn then Api.WrathOn() end
        return nil
    end
    if Api.Condition(Cond.inCombat) then
        State.lastInCombat = Elapsed()
        CombatTick()
        return nil
    end
    -- 脫離戰鬥滿 3 秒才確認還有沒有敵人（戰鬥中不解除、不重選）
    if Elapsed() - (State.lastInCombat or 0) < 3 then return nil end
    if Api.AnyEnemyLeft(Cfg.EnemySearchRange) then
        State.enemySeen = true
        State.lastInCombat = Elapsed()
        if not State.wrathOn then Api.WrathOn() end
        return nil
    end
    -- 一次都沒看過敵人：可能還在播動畫，等到 RouletteWait + 15 秒才放棄
    if not State.enemySeen and Elapsed() < Cfg.RouletteWait + 15 then return nil end
    LeaveCombat()
    Api.ClearTarget()
    return "DUNGEON_CHEST"
end

-- 開寶箱：可能有多個（自動開箱插件通常會先開完，這裡只處理殘留的），一個一個開；最後一次互動（或一開始就沒寶箱）後等 10 秒，
-- 確定沒有新的寶箱才進下一關（點召喚魔法陣），最多 5 關，第 5 關後去找離開用的傳送魔紋
function Handlers.DUNGEON_CHEST()
    if not InDuty() then return "DUNGEON_EXIT" end
    if Api.DeclineGamble() then return nil end
    if State.lastChestAt == nil then State.lastChestAt = Elapsed() end

    if Api.GetEntity(Cfg.DungeonChestName) ~= nil then
        -- 前 3 秒先讓自動開箱插件開，之後還有殘留的寶箱才由腳本接手
        if Elapsed() > 3 and not Api.Condition(Cond.occupiedInEvent) and ApproachAndInteract(Cfg.DungeonChestName) then
            State.lastChestAt = Elapsed()
        end
        if TimedOut("DUNGEON_CHEST") then return "ERROR" end
        return nil
    end
    if Api.Condition(Cond.occupiedInEvent) or Elapsed() - State.lastChestAt < 10 then return nil end

    Log("第 " .. State.stage .. " 關完成")
    State.stage = State.stage + 1
    if State.stage <= MAX_STAGES then return "DUNGEON_SPHERE" end
    return "DUNGEON_EXIT"
end

-- 離開寶物庫：還在寶物庫內就找離開用的傳送魔紋（ExitPortalName）互動並確認；
-- 被移出或陣亡結束時直接等回到野外
function Handlers.DUNGEON_EXIT()
    if not InDuty() and not Busy() then
        local reached = math.min(State.stage, MAX_STAGES)
        table.insert(State.stageLog, reached)
        Log("寶物庫結束，到達第 " .. reached .. " 關")
        return "CHECK_MAP"
    end
    if InDuty() and not Busy() and not Api.Condition(Cond.dead) then
        if Api.ConfirmYes() then return nil end
        if Api.GetEntity(Cfg.ExitPortalName) ~= nil then
            if not Api.Condition(Cond.occupiedInEvent) then ApproachAndInteract(Cfg.ExitPortalName) end
        elseif not State.manualPrompted and Elapsed() > 20 then
            Log("找不到離開用的「" .. Cfg.ExitPortalName .. "」，請確認 ExitPortalName 或手動離開")
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
    LogError("狀態 " .. tostring(State.errorFrom) .. " 失敗（連續 " .. State.errors .. "/" .. Cfg.MaxErrors .. "）")
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
    yield(string.format("/echo [G15] 結束：完成 %d 張，寶物庫 %d 次（到達關數 %s），錯誤 %d 次，買圖 %d 張共 %d gil，換伺服器 %d 次，完成 %d 輪",
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
    if next == "ERROR" then State.errorFrom = State.current end
    if next == "OPEN_COFFER" then State.fieldCleared = false end
    if next == "TRAVEL" then State.cofferPos, State.leashing = nil, false end
    Log(State.current .. " → " .. next)
    State.current = next
    State.enteredAt = os.clock()
    State.lastPos, State.rePathed = nil, false
    State.sent, State.lastClick, State.travelPhase, State.decipherAt = false, nil, nil, nil
    State.cityTeleportSent = false
    State.combatTargeted, State.lastEnemyScan, State.lastInCombat, State.enemySeen = false, nil, nil, false
    State.favoritesTried = false
    State.lastChestAt = nil
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
