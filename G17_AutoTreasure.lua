--[=====[
[[SND Metadata]]
author: forgefk
version: 0.1.0
description: FF14 G17 自動挖寶（古舊的布拉克斯革地圖，Timeworn Br'aaxskin Map）+ 寶物庫 Cenote Ja Ja Gural（選門型）。由 G15 版改寫。
plugin_dependencies:
- vnavmesh
- WrathCombo
- BossModReborn
- Lifestream
configs:
  MapItemId:
    default: 43557
    description: 未解讀 G17 地圖的物品 ID（已查好，取自 XIVAPI；0 = 未設定，INIT 會停止）
  MaxMaps:
    default: 0
    description: 本次最多跑幾張，0 = 跑到沒圖
  AutoBuy:
    default: true
    description: 圖不夠時自動到市場板買圖（維持身上 1 張已解讀 + 1 張未解讀）。事前須在市場板把地圖加入「我的最愛」和「期望清單」
  BmrPreset:
    default: "VBM Default"
    description: 啟動時套用的 BossMod Reborn 自動預設（/bmr ar set）；名稱打錯 BMR 會強制停用，留空 = 不切換
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
    default: ""
    description: Urqopacha 的以太之光名稱（留空 = 自動從遊戲資料取）
  AetheryteKozamauka:
    default: ""
    description: Kozama'uka 的以太之光名稱（留空 = 自動從遊戲資料取）
  AetheryteYakTel:
    default: ""
    description: Yak T'el 的以太之光名稱（留空 = 自動從遊戲資料取）
  AetheryteShaaloani:
    default: ""
    description: Shaaloani 的以太之光名稱（留空 = 自動從遊戲資料取）
  AetheryteHeritageFound:
    default: ""
    description: Heritage Found 的以太之光名稱（留空 = 自動從遊戲資料取）
  EchoLogs:
    default: "All"
    description: 日誌層級 All / Errors / None
[[End Metadata]]
--]=====]

import("System.Numerics")

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

local Cfg = {}
for _, k in ipairs({
    "MapItemId", "MaxMaps", "EnterDungeon", "StartWithDeciphered", "FlagWait", "AutoBuy",
    "BmrPreset", "CrossWorld", "DataCenter", "MaxMapPrice", "GilFloor", "MarketTerritoryId", "MarketAetheryte", "MarketX", "MarketY", "MarketZ",
    "MarketBoardName", "DoorChoice", "DigRadius", "PortalWait",
    "PotionHpPercent", "PotionItemName", "UseSprint", "MaxErrors", "ChestName", "DungeonChestName",
    "DoorName", "PortalName", "AetheryteUrqopacha", "AetheryteKozamauka", "AetheryteYakTel",
    "AetheryteShaaloani", "AetheryteHeritageFound", "EchoLogs",
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
    LOCATE          = Cfg.FlagWait,
    TRAVEL          = 240,
    DIG             = 8,
    OPEN_COFFER     = 15,
    FIELD_COMBAT    = 600,
    LOOT            = 10,
    PORTAL_CHECK    = Cfg.PortalWait,
    ENTER_DUNGEON   = 60,
    DEAD            = 120,
    WORLD_TRAVEL     = 300,
    MB_TRAVEL       = 120,
    MB_OPEN         = 15,
    MB_SEARCH       = 180,   -- 含等待手動搜尋的時間
    MB_LIST         = 15,
    MB_BUY          = 15,
    MB_CLOSE        = 10,
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

-- HTTP GET：先用 .NET HttpClient，失敗改用 PowerShell。回傳內容字串或 nil
function Api.HttpGet(url)
    local ok, body = pcall(function()
        luanet.load_assembly("System.Net.Http")
        local client = luanet.import_type("System.Net.Http.HttpClient")()
        client.Timeout = luanet.import_type("System.TimeSpan").FromSeconds(15)
        local result = client:GetStringAsync(url).Result
        client:Dispose()
        return tostring(result)
    end)
    if ok and body ~= nil and body ~= "" then return body end
    ok, body = pcall(function()
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
    if ok and body ~= nil and body ~= "" then return body end
    return nil
end

-- 查 Universalis：資料中心內這張地圖最便宜的上架（只算單張、不超過 MaxMapPrice、不在 excluded 裡的伺服器）。
-- 回傳 { world = 伺服器ID, price = 單價 }；查不到回 nil。Universalis 的資料是玩家上傳的，可能有幾小時延遲
function Api.CheapestWorld(itemId, excluded)
    local dc = luanet.import_type("System.Uri").EscapeDataString(Cfg.DataCenter)
    local url = string.format(
        "https://universalis.app/api/v2/%s/%d?listings=50&entries=0&fields=listings.worldID%%2Clistings.pricePerUnit%%2Clistings.quantity",
        dc, itemId)
    local body = Api.HttpGet(url)
    if body == nil then return nil end
    local best = nil
    for obj in body:gmatch("{[^{}]*}") do
        local price = tonumber(obj:match('"pricePerUnit":(%d+)'))
        local qty = tonumber(obj:match('"quantity":(%d+)'))
        local world = tonumber(obj:match('"worldID":(%d+)'))
        if price and qty == 1 and world and not excluded[world] and price <= Cfg.MaxMapPrice then
            if best == nil or price < best.price then best = { world = world, price = price } end
        end
    end
    return best
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

-- 開關 Wrath 時同步記錄狀態，CombatTick / TRAVEL 依 State.wrathOn 判斷要不要再開
function Api.WrathOn()
    yield("/wrath auto on")
    State.wrathOn = true
end

function Api.WrathOff()
    yield("/wrath auto off")
    State.wrathOn = false
end

-- 每個地區傳到設定的以太之光（不一定是離藏寶點最近的那個）
function Api.TeleportToZone(territory)
    local zone = G17_ZONES[territory]
    if zone == nil then return false end
    local dest = Api.ResolveAetheryte(Cfg[zone.aetheryteKey], territory)
    if dest == nil then return false end
    Api.Teleport(dest)
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
    Api.MarketOpenFirstResult()
    return method
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
    return Api.Condition(Cond.betweenAreas) or Api.Condition(Cond.casting) or Api.LifestreamBusy()
end

local function StopAutomation()
    Api.WrathOff()
    State.wrathOn = false
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
    for _ = 1, 8 do
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
    State.wrathOn = false
    if not Dismount() then return false end   -- 騎著坐騎不能互動
    Api.InteractTarget()
    return true
end

local function ApproachAndInteract(name)
    if not Api.Target(name) then return false end
    return ApproachAndInteractTarget()
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

-- 戰鬥中：解除對寶箱的選取（選著寶箱 Wrath 不會自動選怪），交給 Wrath 打；
-- 戰鬥結束後由 LOOT / DUNGEON_LOOT 重新選寶箱互動
local function CombatTick()
    local t = Entity.Target
    if t ~= nil and (t.Name == Cfg.ChestName or t.Name == Cfg.DungeonChestName) then
        Api.ClearTarget()
    end
    if not State.wrathOn then
        Api.NavStop()
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

-- 買圖、換伺服器、解讀期間 Wrath 一律關閉（傳送到藏寶地區後才在 TRAVEL 開啟）
local function EnsureWrathOff()
    if State.wrathOn ~= false then
        Api.WrathOff()
        State.wrathOn = false
    end
end

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
    if Cfg.BmrPreset ~= nil and Cfg.BmrPreset ~= "" then
        yield("/bmr ar set " .. Cfg.BmrPreset)
        Log("BossMod Reborn 預設：" .. Cfg.BmrPreset)
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
    Cfg.MapItemName = Api.ItemName(Cfg.MapItemId)
    if Cfg.MapItemName == nil then
        LogError("從遊戲資料查不到物品 " .. Cfg.MapItemId .. " 的名稱")
        return "END"
    end
    Log("要買的地圖：" .. Cfg.MapItemName .. "（" .. Cfg.MapItemId .. "）")
    if Cfg.AutoBuy then
        Log("提醒：自動買圖前，請確認已在市場板把「" .. Cfg.MapItemName .. "」加入我的最愛和期望清單")
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
        if not hasDeciphered and not hasUndeciphered and not State.roundBuying then
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
    Log("沒有 G17 地圖了")
    return "END"
end

function Handlers.DECIPHER()
    EnsureWrathOff()
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
    if FlagIsFresh() and G17_ZONES[Api.FlagTerritory()] ~= nil then
        Api.CloseAddon("AreaMap")
        Log("藏寶點在 " .. G17_ZONES[Api.FlagTerritory()].name)
        return "TRAVEL"
    end
    if not State.sent then
        Log("等待藏寶點旗標（黃金版 5 區之一）：XivTreasureParty 會自動打，或請手動插旗")
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

    local target = Api.FlagTerritory()
    if Api.Territory() ~= target then
        if not State.teleportSent then
            if not Api.TeleportToZone(target) then return "ERROR" end
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

    local flag = Api.FlagPos()
    if Distance2D(Api.PlayerPos(), flag) < Cfg.DigRadius and not Api.NavRunning() then
        State.digOffsetIdx = 0
        return "DIG"
    end

    if not Api.NavReady() then return nil end
    if not Api.NavRunning() then
        -- 傳送後先確認角色可操作、已上坐騎，才開始飛（沒上坐騎時飛行路線不會動）
        if not Api.PlayerReady() then return nil end
        if not Mount() then return nil end
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

---------------------------------------------------------------- 跨伺服器（每輪開始時）

-- 查 Universalis 選最便宜的伺服器；已經在那裡就直接買，查不到就留在目前伺服器
function Handlers.PICK_WORLD()
    EnsureWrathOff()
    State.worldChosen = true
    local best = Api.CheapestWorld(Cfg.MapItemId, State.badWorlds or {})
    if best == nil then
        Log("Universalis 查不到 MaxMapPrice 以內的單張上架，留在目前伺服器買")
        return "CHECK_MAP"
    end
    local name = Api.WorldName(best.world) or tostring(best.world)
    Log(string.format("目前最便宜：%s，%d gil（Universalis）", name, best.price))
    if best.world == Api.CurrentWorldId() then return "CHECK_MAP" end
    State.targetWorld, State.targetWorldName = best.world, name
    return "WORLD_TRAVEL"
end

-- 用 Lifestream 傳送到目標伺服器，等到達且角色可操作
function Handlers.WORLD_TRAVEL()
    EnsureWrathOff()
    if Api.CurrentWorldId() == State.targetWorld and Api.PlayerReady() and not Api.LifestreamBusy() then
        Log("已到達 " .. State.targetWorldName)
        State.worldTrips = (State.worldTrips or 0) + 1
        return "CHECK_MAP"
    end
    if not State.sent and Api.PlayerReady() and not Api.LifestreamBusy() then
        Api.NavStop()
        Log("傳送到 " .. State.targetWorldName)
        Api.Teleport(State.targetWorldName)
        State.sent = true
    end
    if TimedOut("WORLD_TRAVEL") then return "ERROR" end
end

---------------------------------------------------------------- 買圖子流程（市場板）
-- 【事前準備，必做】要買的地圖必須先在市場板手動加入「我的最愛」和「期望清單」，
-- 否則搜尋後點不開上架清單（ItemSearchResult），買圖會卡在 MB_SEARCH。
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

-- 自動貼上搜尋 SEARCH_AUTO_TRIES 次都沒打開上架清單，就請使用者手動搜尋；腳本繼續等，並定時點第一筆結果
local SEARCH_AUTO_TRIES = 2

function Handlers.MB_SEARCH()
    if Api.AddonReady("ItemSearchResult") then return "MB_LIST" end
    local tries = State.searchTries or 0
    if tries < SEARCH_AUTO_TRIES then
        if Elapsed() - (State.lastSearch or -10) > 6 then
            local method = Api.TypeIntoSearch(Cfg.MapItemName)
            if method == nil then
                State.searchTries = SEARCH_AUTO_TRIES   -- 剪貼簿寫不進去，直接改手動
            else
                State.searchTries = tries + 1
                Log("自動搜尋第 " .. State.searchTries .. " 次（剪貼簿：" .. method .. "）")
            end
            State.lastSearch = Elapsed()
            State.lastClick = Elapsed()
        end
    else
        if not State.manualPrompted then
            Log("自動搜尋沒有結果，請確認「" .. Cfg.MapItemName .. "」已加入市場板的我的最愛和期望清單，或手動搜尋，腳本會接著自動購買")
            State.manualPrompted = true
        end
        if Elapsed() - (State.lastClick or -10) > 3 then
            Api.MarketOpenFirstResult()
            State.lastClick = Elapsed()
        end
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
    yield(string.format("/echo [G17] 結束：完成 %d 張，寶物庫 %d 次（到達關數 %s），錯誤 %d 次，買圖 %d 張共 %d gil，換伺服器 %d 次",
        State.mapsDone, State.dungeonRuns, stages, State.errorCount, State.mapsBought or 0, State.gilSpent or 0, State.worldTrips or 0))
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
    State.searchTries, State.lastSearch, State.manualPrompted = 0, nil, false
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
        or State.current == "MB_TRAVEL" or State.current == "WORLD_TRAVEL"
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
