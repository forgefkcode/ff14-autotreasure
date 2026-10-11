--[=====[
[[SND Metadata]]
author: forgefk
version: 0.7.0
description: 測試市場板搜尋視窗 callback「12 1」～「12 6」各是什麼。先打開市場板（停在搜尋視窗）再執行，每組停 4 秒，請看畫面切到哪個分頁，並把聊天框的 [MBTest] 訊息貼回來。不會購買。
configs:
  ItemId:
    default: 39591
    description: 要找的物品 ID（39591 = G15，43557 = G17），用來標示清單上有沒有這張圖
[[End Metadata]]
--]=====]

local function Echo(msg) yield("/echo [MBTest] " .. msg) end

local function Ready(name)
    local ok, r = pcall(function() return Addons.GetAddon(name).Ready end)
    return ok and r == true
end

local function NodeText(addon, ...)
    local path = { ... }
    local ok, t = pcall(function() return Addons.GetAddon(addon):GetNode(table.unpack(path)).Text end)
    if not ok or t == nil then return "" end
    return tostring(t)
end

-- 左側清單第 i 項的名稱（與正式腳本 Api.FindInResults 相同的節點路徑）
local function ListText(i)
    return NodeText("ItemSearch", 1, 139, i == 0 and 5 or (51000 + i), 13)
end

local function ListSummary()
    local names = {}
    for i = 0, 5 do
        local t = ListText(i)
        if t == "" or t == "nil" then break end
        table.insert(names, t)
    end
    if #names == 0 then return "（空）" end
    return table.concat(names, "、")
end

local function HasItem(name)
    for i = 0, 99 do
        local t = ListText(i)
        if t == "" or t == "nil" then return false end
        if t == name or (t:sub(-3) == "..." and name:find(t:sub(1, -4), 1, true) == 1) then return true end
    end
    return false
end

local function CloseResult()
    for _ = 1, 10 do
        if not Ready("ItemSearchResult") then return end
        yield("/callback ItemSearchResult true -1")
        yield("/wait 0.3")
    end
end

local name = tostring(Excel.GetRow("Item", Config.Get("ItemId")).Name)
Echo("要找的地圖：" .. name)

if not Ready("ItemSearch") then
    Echo("ItemSearch 沒開，請先打開市場板再執行")
    return
end

local function Report(label)
    local status = NodeText("ItemSearch", 1, 140)
    if #status > 30 then status = status:sub(1, 30) .. "…" end
    Echo(label .. " 清單：" .. ListSummary() .. (HasItem(name) and "（有地圖）" or ""))
    Echo("   結果數量：「" .. NodeText("ItemSearch", 1, 142, 148) .. "」 狀態文字：「" .. status .. "」")
end

Report("打開時")
for i = 1, 6 do
    local c = "12 " .. i
    yield("/callback ItemSearch true " .. c)
    yield("/wait 1")
    if Ready("ItemSearchResult") then
        Echo("「" .. c .. "」打開了上架清單，關掉它")
        CloseResult()
    end
    if not Ready("ItemSearch") then
        Echo("「" .. c .. "」把搜尋視窗關掉了，停止測試")
        break
    end
    Report("「" .. c .. "」")
    yield("/wait 3")
end
Echo("測試結束（沒有購買）。請告訴我每一組畫面上是哪個分頁")
