--[=====[
[[SND Metadata]]
author: forgefk
version: 0.2.0
description: 強欲陷阱診斷：找出腳本讀得到牌面數字的地方。強欲陷阱出現（大／小魔法球出現）時執行，約 45 秒，期間可以照平常選大／小或不動。只讀資料、不會互動任何東西。結束後把聊天框的 [GambleTest] 訊息全部貼回來，並告訴我當時畫面上的牌是幾、你選了什麼、結果如何。
function_chat_filters:
  OnChatMessage:
    message_regex: "^(?!\\[GambleTest\\])"
[[End Metadata]]
--]=====]

-- 牌面數字可能在四個地方：場上物件（名稱、ID、狀態效果）、介面視窗（文字或數值）、角色的狀態效果、聊天訊息。
-- 開始時把四種都印一次，之後每 3 秒比對一次，只印「有變化」的部分；牌換了或揭曉時，數字所在的地方就會出現在變化裡。
-- 看起來像 1～9 的數字會標 ★。
--
-- 安全注意（SND 的介面 API 在 Lua 外讀記憶體，出錯 pcall 攔不到，可能讓遊戲崩潰）：
--   * 只讀 Exists 而且顯示中的視窗；數值用 AtkValues 逐一讀（有界），不用 GetAtkValue(索引)
--   * 節點只讀類型是 Text 的文字

local DURATION = 45     -- 總秒數
local INTERVAL = 3      -- 每幾秒比對一次
local RANGE    = 40     -- 物件掃描範圍

-- /echo 走遊戲聊天框，一則最多 500 bytes（中文一字 3 bytes）：超過 400 bytes 就依 UTF-8 字元邊界切成多則
local function Echo(msg)
    msg = "[GambleTest] " .. msg
    while #msg > 0 do
        local cut = #msg
        if cut > 400 then
            cut = 400
            while cut > 0 and (msg:byte(cut + 1) or 0) >= 0x80 and (msg:byte(cut + 1) or 0) < 0xC0 do cut = cut - 1 end
        end
        yield("/echo " .. msg:sub(1, cut))
        msg = msg:sub(cut + 1)
        if #msg > 0 then msg = "[GambleTest] …" .. msg end
    end
end

local function Mark(s)
    s = tostring(s)
    if s:match("^%s*[1-9]%s*$") or s:match("[^%d][1-9][^%d]") or s:match("^[1-9][^%d]") or s:match("[^%d][1-9]$") then
        return "★" .. s
    end
    return s
end

-- 聊天訊息：排除自己印的，結束時一起印出（OnChatMessage 只收集，不做別的事）
Captured = {}
function OnChatMessage()
    local ok, msg = pcall(function() return tostring(TriggerData.message) end)
    if not ok or msg == nil or msg:find("[GambleTest]", 1, true) then return end
    local tok, typ = pcall(function() return tostring(TriggerData.type) end)
    if #Captured < 60 then
        table.insert(Captured, string.format("%.0f秒 %s%s", os.clock() - (StartedAt or os.clock()), tok and ("[" .. typ .. "] ") or "", msg))
    end
end

---------------------------------------------------------------- 1. 場上物件

local function ObjectStatuses(o)
    local parts = {}
    pcall(function()
        for s in luanet.each(o.StatusList) do
            if s.StatusId ~= 0 then table.insert(parts, s.StatusId .. ":" .. s.Param) end
        end
    end)
    return table.concat(parts, ",")
end

-- 回傳 { [物件索引] = 描述文字 }
local function SnapshotObjects()
    local snap = {}
    local ok, me = pcall(function() return Entity.Player.Position end)
    if not ok or me == nil then return snap end
    local okLen, len = pcall(function() return Svc.Objects.Length end)
    if not okLen then return snap end
    for i = 0, len - 1 do
        -- 每個物件各自 pcall：一個物件讀失敗不影響其他物件
        pcall(function()
            local o = Svc.Objects[i]
            if o ~= nil and tostring(o.ObjectKind) ~= "Player" then
                local dx, dz = o.Position.X - me.X, o.Position.Z - me.Z
                local d = math.sqrt(dx * dx + dz * dz)
                if d <= RANGE then
                    local _, baseId = pcall(function() return o.BaseId end)
                    local _, dataId = pcall(function() return o.DataId end)
                    local _, subKind = pcall(function() return o.SubKind end)
                    local _, nameId = pcall(function() return o.NameId end)
                    local statuses = ObjectStatuses(o)
                    snap[i] = string.format("「%s」%s/%s 可選取:%s 距離%.0f ID:%s/%s 名稱ID:%s%s",
                        Mark(o.Name.TextValue), tostring(o.ObjectKind), tostring(subKind), tostring(o.IsTargetable), d,
                        tostring(baseId), tostring(dataId), tostring(nameId),
                        statuses ~= "" and (" 狀態:" .. Mark(statuses)) or "")
                end
            end
        end)
    end
    return snap
end

---------------------------------------------------------------- 2. 介面視窗

-- 候選視窗：名稱不存在也沒關係（Exists 會是 false，不會讀它）
local ADDONS = {
    "SelectYesno", "SelectString", "SelectIconString", "SelectOk", "Talk", "_BattleTalk", "_MiniTalk",
    "_ScreenText", "_TextError", "_WideText", "_PopUpText", "_TextChain", "_AreaText", "_LocationTitle",
    "_LocationTitleShort", "ScreenInfo", "ScreenInfoFrontBack", "ScreenFrameSystem", "_TextClassChange",
    "_ToDoList", "ContentsInfo", "ContentsInfoDetail", "_NotificationTimer", "_TargetInfo",
    "_TargetInfoMainTarget", "_TargetInfoCastBar", "_FocusTargetInfo", "_EnemyList", "Request",
    "_Image", "_Image3", "_ImageFlash", "JournalResult", "ContentGauge", "_ContentGauge",
    "EventCountdown", "_EventCountdown", "MiniGame", "MiniGameBotanist", "Tooltip",
    "GoldSaucerReward", "LotteryDaily", "_HudLayoutScreen",
}

local function AddonExists(name)
    local ok, e = pcall(function() return Addons.GetAddon(name).Exists end)
    return ok and e == true
end

-- 回傳一行描述（視窗不存在回 nil）
local function DescribeAddon(name)
    if not AddonExists(name) then return nil end
    local a = Addons.GetAddon(name)
    local _, ready = pcall(function() return a.Ready end)
    if ready ~= true then return name .. "（存在但未顯示）" end
    local values, texts = {}, {}
    pcall(function()
        local i = 0
        for v in luanet.each(a.AtkValues) do
            local s = tostring(v.ValueString)
            if s ~= "" and s ~= "0" and s ~= "nil" and #values < 25 then table.insert(values, i .. "=" .. Mark(s)) end
            i = i + 1
            if i >= 200 then break end
        end
    end)
    pcall(function()
        local n = 0
        for node in luanet.each(a.Nodes) do
            n = n + 1
            if n > 400 or #texts >= 25 then break end
            if tostring(node.NodeType) == "Text" then
                local _, vis = pcall(function() return node.IsVisible end)
                local ok, t = pcall(function() return tostring(node.Text) end)
                if ok and t ~= nil and t ~= "" and vis == true then table.insert(texts, node.Id .. "=" .. Mark(t)) end
            end
        end
    end)
    return string.format("%s（顯示中）數值：%s ｜文字：%s", name,
        #values > 0 and table.concat(values, " ") or "無", #texts > 0 and table.concat(texts, " ") or "無")
end

local function SnapshotAddons()
    local snap = {}
    for _, name in ipairs(ADDONS) do
        local d = DescribeAddon(name)
        if d ~= nil then snap[name] = d end
    end
    return snap
end

---------------------------------------------------------------- 3. 角色的狀態效果

local function SnapshotPlayerStatus()
    local parts = {}
    pcall(function()
        for s in luanet.each(Player.Status) do
            if s.StatusId ~= 0 then
                local _, name = pcall(function() return tostring(Excel.GetRow("Status", s.StatusId).Name) end)
                table.insert(parts, string.format("%s(%d) 層數:%s 剩%.0f秒", tostring(name), s.StatusId, Mark(s.Param), s.RemainingTime))
            end
        end
    end)
    return table.concat(parts, "、")
end

---------------------------------------------------------------- 比對與輸出

local function PrintDiff(label, old, new)
    for k, v in pairs(new) do
        if old[k] == nil then Echo("   + " .. label .. " " .. v)
        elseif old[k] ~= v then Echo("   ~ " .. label .. " " .. v) end
    end
    for k, v in pairs(old) do
        if new[k] == nil then Echo("   - " .. label .. " " .. v) end
    end
end

StartedAt = os.clock()
Echo("開始（" .. DURATION .. " 秒，只讀資料）。目前地區 " .. tostring(Svc.ClientState.TerritoryType))

local objs, addons, status = SnapshotObjects(), SnapshotAddons(), SnapshotPlayerStatus()
Echo("1. 附近物件（" .. RANGE .. " 內，不含玩家）：")
local count = 0
for _, v in pairs(objs) do Echo("   " .. v); count = count + 1 end
if count == 0 then Echo("   （沒有）") end
Echo("2. 存在的介面視窗：")
count = 0
for _, v in pairs(addons) do Echo("   " .. v); count = count + 1 end
if count == 0 then Echo("   （候選視窗都不存在）") end
Echo("3. 角色狀態效果：" .. (status ~= "" and status or "無"))
Echo("接下來每 " .. INTERVAL .. " 秒只印有變化的部分，可以照平常選大／小或不動")

local elapsed = 0
while elapsed < DURATION do
    yield("/wait " .. INTERVAL)
    elapsed = elapsed + INTERVAL
    local o2, a2, s2 = SnapshotObjects(), SnapshotAddons(), SnapshotPlayerStatus()
    local changed = false
    for k, v in pairs(o2) do if objs[k] ~= v then changed = true end end
    for k in pairs(objs) do if o2[k] == nil then changed = true end end
    for k, v in pairs(a2) do if addons[k] ~= v then changed = true end end
    for k in pairs(addons) do if a2[k] == nil then changed = true end end
    if s2 ~= status then changed = true end
    if changed then
        Echo(elapsed .. " 秒時有變化：")
        PrintDiff("物件", objs, o2)
        PrintDiff("視窗", addons, a2)
        if s2 ~= status then Echo("   ~ 狀態效果 " .. (s2 ~= "" and s2 or "無")) end
    end
    objs, addons, status = o2, a2, s2
end

Echo("4. 期間收到的聊天訊息 " .. #Captured .. " 則：")
for _, m in ipairs(Captured) do Echo("   " .. Mark(m)) end
Echo("測試結束")
