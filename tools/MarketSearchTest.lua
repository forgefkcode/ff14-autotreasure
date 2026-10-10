--[=====[
[[SND Metadata]]
author: forgefk
version: 0.6.0
description: 找出切到市場板「我的最愛」分頁的 callback 參數。先把地圖加入我的最愛、打開市場板（停在搜尋視窗），再執行，把聊天框的 [MBTest] 訊息貼回來。不會購買。
configs:
  ItemId:
    default: 39591
    description: 要找的物品 ID（39591 = G15，43557 = G17）
[[End Metadata]]
--]=====]

local function Echo(msg) yield("/echo [MBTest] " .. msg) end

local function Ready(name)
    local ok, r = pcall(function() return Addons.GetAddon(name).Ready end)
    return ok and r == true
end

-- 讀左側清單第 i 項的名稱（與正式腳本 Api.FindInResults 相同的節點路徑）
local function ListText(i)
    local nodeId = i == 0 and 5 or (51000 + i)
    local ok, t = pcall(function() return tostring(Addons.GetAddon("ItemSearch"):GetNode(1, 139, nodeId, 13).Text) end)
    if not ok or t == nil or t == "nil" then return "" end
    return t
end

local function ListSummary()
    local names = {}
    for i = 0, 4 do
        local t = ListText(i)
        if t == "" then break end
        table.insert(names, t)
    end
    if #names == 0 then return "（空）" end
    return table.concat(names, "、")
end

local function FindIndex(name)
    for i = 0, 99 do
        local t = ListText(i)
        if t == "" then return nil end
        if t == name or (t:sub(-3) == "..." and name:find(t:sub(1, -4), 1, true) == 1) then return i end
    end
    return nil
end

local function CloseResult()
    for _ = 1, 10 do
        if not Ready("ItemSearchResult") then return end
        yield("/callback ItemSearchResult true -1")
        yield("/wait 0.3")
    end
end

local itemId = Config.Get("ItemId")
local name = tostring(Excel.GetRow("Item", itemId).Name)
Echo("物品：" .. name .. "（" .. itemId .. "）")

if not Ready("ItemSearch") then
    Echo("ItemSearch 沒開，請先打開市場板再執行")
    return
end

-- 1. 打開時清單上有什麼
Echo("1. 打開時清單：" .. ListSummary())
local idx = FindIndex(name)
if idx ~= nil then
    Echo("   清單上已經有地圖（第 " .. idx .. " 項），測試點開")
    yield("/callback ItemSearch true 5 " .. idx)
    yield("/wait 2")
    Echo("   上架清單" .. (Ready("ItemSearchResult") and "已打開，點開成功" or "沒有打開"))
    CloseResult()
end

-- 2. 事件 12 是切換分頁（「12 6」切到期望清單）。逐一試 12 + 不同數字，每組停 3 秒，
--    請看畫面上目前是哪個分頁，記下哪一組是「我的最愛」
local candidates = { "12 7", "12 5", "12 8", "12 4", "12 3", "12 6" }
Echo("2. 逐一切換分頁，每組停 3 秒，請看畫面是哪個分頁")
for _, c in ipairs(candidates) do
    yield("/callback ItemSearch true " .. c)
    yield("/wait 0.5")
    if Ready("ItemSearchResult") then CloseResult() end
    if not Ready("ItemSearch") then
        Echo("   「" .. c .. "」把搜尋視窗關掉了，停止測試")
        break
    end
    Echo("   現在是「" .. c .. "」，清單：" .. ListSummary() .. (FindIndex(name) and "（有地圖）" or ""))
    yield("/wait 2.5")
end
Echo("測試結束（沒有購買）。請告訴我哪一組畫面是「我的最愛」")
