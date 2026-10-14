--[=====[
[[SND Metadata]]
author: forgefk
version: 0.3.2
description: 強欲陷阱診斷：找出腳本讀得到牌面數字的地方。強欲陷阱出現（大／小魔法球出現）時執行，約 45 秒，期間可以照平常選大／小或不動。只讀資料、不會互動任何東西。結束後把聊天框的 [GambleTest] 訊息全部貼回來，並告訴我當時畫面上的牌是幾、你選了什麼、結果如何。
function_chat_filters:
  OnChatMessage:
    message_regex: "^(?!\\[GambleTest\\])"
[[End Metadata]]
--]=====]

-- 牌面數字可能在幾個地方：場上物件（名稱）、介面視窗（文字或數值）、角色的狀態效果、聊天訊息。
-- 開始時全部印一次，之後每 3 秒比對一次，只印「有變化」的部分；牌換了或揭曉時，數字所在的地方就會出現在變化裡。
-- 看起來像 1～9 的數字會標 ★。
--
-- 安全注意：讀 .NET 物件時，欄位不存在或 C# 那邊出錯，SND 會直接停掉腳本（Unknown error），pcall 攔不到。
-- v0.2 就是讀了這個版本沒有的物件欄位（DataId / NameId / StatusList）而停掉。所以：
--   * 物件只讀正式腳本實測可用的欄位：Name、ObjectKind、SubKind、IsTargetable、Position
--   * 角色狀態效果用 SND 自己的 Player.Status
--   * 介面只讀 Exists 而且顯示中的視窗；數值用 AtkValues 逐一讀（有界），節點只讀類型是 Text 的文字
--   * 每個階段開始前先印一行：萬一又停掉，看最後一行就知道是哪一步
--   * 物件 ID（BaseId / DataId，不同 Dalamud 版本名稱不同）放到最後才試讀，前面的結果都已經印出來了

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

-- .NET 列舉轉成名稱：NLua 的 tostring(列舉) 是「Text: 3」這種格式，只取冒號前的名稱再比
local function EnumName(v)
    local s = tostring(v)
    return s:match("^([%w_]+)") or s
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

---------------------------------------------------------------- 1. 場上物件（只讀實測可用的欄位）

-- 回傳 { [物件索引] = 描述文字 }
local function SnapshotObjects()
    local snap = {}
    local me = Entity.Player.Position
    local objs = Svc.Objects
    for i = 0, objs.Length - 1 do
        local o = objs[i]
        if o ~= nil and EnumName(o.ObjectKind) ~= "Player" then
            local dx, dz = o.Position.X - me.X, o.Position.Z - me.Z
            local d = math.sqrt(dx * dx + dz * dz)
            if d <= RANGE then
                snap[i] = string.format("#%d「%s」%s/%s 可選取:%s 位置(%.1f, %.1f, %.1f) 距離%.0f",
                    i, Mark(o.Name.TextValue), tostring(o.ObjectKind), tostring(o.SubKind), tostring(o.IsTargetable),
                    o.Position.X, o.Position.Y, o.Position.Z, d)
            end
        end
    end
    return snap
end

---------------------------------------------------------------- 2. 介面視窗

-- 候選視窗：名稱不存在也沒關係（Exists 會是 false，不會讀它）
local ADDONS = {
    "TreasureHighLow",   -- 強欲陷阱視窗（FFXIVClientStructs AgentId.TreasureHighLow / ECommons AddonMaster）
    "SelectYesno", "SelectString", "SelectIconString", "SelectOk", "Talk", "_BattleTalk", "_MiniTalk",
    "_ScreenText", "_TextError", "_WideText", "_PopUpText", "_TextChain", "_AreaText", "_LocationTitle",
    "_LocationTitleShort", "ScreenInfo", "ScreenInfoFrontBack", "ScreenFrameSystem", "_TextClassChange",
    "_ToDoList", "ContentsInfo", "ContentsInfoDetail", "_NotificationTimer", "_TargetInfo",
    "_TargetInfoMainTarget", "_TargetInfoCastBar", "_FocusTargetInfo", "_EnemyList", "Request",
    "_Image", "_Image3", "_ImageFlash", "JournalResult", "ContentGauge", "_ContentGauge",
    "EventCountdown", "_EventCountdown", "MiniGame", "Tooltip", "GoldSaucerReward",
}

-- AddonWrapper.AtkValues / Nodes 是 C# 編譯器產生的 iterator，NLua 叫不到 GetEnumerator（luanet.each 會出錯），
-- 所以先轉成 .NET 的 List<object> 再用索引讀。失敗回傳 nil
local function ToLuaList(enumerable)
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

local function AddonVisible(name)
    local a = Addons.GetAddon(name)
    return a.Exists and a.Ready
end

local function DescribeAddon(name)
    local a = Addons.GetAddon(name)
    local values, texts = {}, {}
    local valueList, nodeList = ToLuaList(a.AtkValues), ToLuaList(a.Nodes)
    if valueList == nil and nodeList == nil then return name .. " （讀不到這個視窗的數值和節點）" end
    for idx, v in ipairs(valueList or {}) do
        if idx > 200 then break end
        local ok, s = pcall(function() return tostring(v.ValueString) end)
        if ok and s ~= "" and s ~= "0" and s ~= "nil" and #values < 25 then table.insert(values, (idx - 1) .. "=" .. Mark(s)) end
    end
    for n, node in ipairs(nodeList or {}) do
        if n > 400 or #texts >= 25 then break end
        if EnumName(node.NodeType) == "Text" and node.IsVisible then
            local t = tostring(node.Text)
            if t ~= "" and t ~= "nil" then table.insert(texts, node.Id .. "=" .. Mark(t)) end
        end
    end
    return string.format("%s 數值：%s ｜文字：%s", name,
        #values > 0 and table.concat(values, " ") or "無", #texts > 0 and table.concat(texts, " ") or "無")
end

-- seen：已經讀過的視窗。第一次讀某個視窗前先印一行，萬一讀它時停掉就知道是哪個
local seen = {}
local function SnapshotAddons()
    local snap = {}
    for _, name in ipairs(ADDONS) do
        if AddonVisible(name) then
            if not seen[name] then
                Echo("   （讀取視窗 " .. name .. "…）")
                seen[name] = true
            end
            snap[name] = DescribeAddon(name)
        end
    end
    return snap
end

---------------------------------------------------------------- 3. 角色的狀態效果（SND 的 Player.Status）

local function SnapshotPlayerStatus()
    local parts = {}
    for s in luanet.each(Player.Status) do
        if s.StatusId ~= 0 then
            local name = tostring(Excel.GetRow("Status", s.StatusId).Name)
            table.insert(parts, string.format("%s(%d) 層數:%s 剩%.0f秒", name, s.StatusId, Mark(s.Param), s.RemainingTime))
        end
    end
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

local function PrintAll(snap, empty)
    local count = 0
    for _, v in pairs(snap) do Echo("   " .. v); count = count + 1 end
    if count == 0 then Echo("   " .. empty) end
end

StartedAt = os.clock()
Echo("v0.3 開始（" .. DURATION .. " 秒，只讀資料）。目前地區 " .. tostring(Svc.ClientState.TerritoryType))

Echo("1. 附近物件（" .. RANGE .. " 內，不含玩家）：")
local objs = SnapshotObjects()
PrintAll(objs, "（沒有）")
Echo("2. 角色狀態效果：")
local status = SnapshotPlayerStatus()
Echo("   " .. (status ~= "" and status or "無"))
Echo("3. 顯示中的介面視窗：")
local addons = SnapshotAddons()
PrintAll(addons, "（候選視窗都沒有顯示）")
Echo("接下來每 " .. INTERVAL .. " 秒只印有變化的部分，可以照平常選大／小或不動")

local elapsed = 0
while elapsed < DURATION do
    yield("/wait " .. INTERVAL)
    elapsed = elapsed + INTERVAL
    local o2, s2, a2 = SnapshotObjects(), SnapshotPlayerStatus(), SnapshotAddons()
    local changed = s2 ~= status
    for k, v in pairs(o2) do if objs[k] ~= v then changed = true end end
    for k in pairs(objs) do if o2[k] == nil then changed = true end end
    for k, v in pairs(a2) do if addons[k] ~= v then changed = true end end
    for k in pairs(addons) do if a2[k] == nil then changed = true end end
    if changed then
        Echo(elapsed .. " 秒時有變化：")
        PrintDiff("物件", objs, o2)
        if s2 ~= status then Echo("   ~ 狀態效果 " .. (s2 ~= "" and s2 or "無")) end
        PrintDiff("視窗", addons, a2)
    end
    objs, status, addons = o2, s2, a2
end

Echo("4. 期間收到的聊天訊息 " .. #Captured .. " 則：")
for _, m in ipairs(Captured) do Echo("   " .. Mark(m)) end

-- 5. 最後才試讀物件 ID：Dalamud 新版叫 BaseId、舊版叫 DataId，讀到不存在的那個 SND 會停掉腳本。
--    前面的結果都已經印出來了，就算在這裡停掉也沒關係；停掉時最後一行會告訴我是哪個名稱不存在
Echo("5. 試讀物件 ID（如果在這裡停掉也沒關係，前面的結果都已經有了）：")
local probe = nil
for k in pairs(objs) do probe = k; break end
if probe == nil then
    Echo("   附近沒有物件可以試")
else
    Echo("   試 BaseId…")
    local o = Svc.Objects[probe]
    local _ = o.BaseId
    Echo("   這個版本是 BaseId，附近物件的 ID：")
    for k in pairs(objs) do
        local obj = Svc.Objects[k]
        if obj ~= nil then Echo(string.format("   #%d「%s」BaseId %s", k, Mark(obj.Name.TextValue), Mark(obj.BaseId))) end
    end
end
Echo("測試結束")
