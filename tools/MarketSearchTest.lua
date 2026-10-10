--[=====[
[[SND Metadata]]
author: forgefk
version: 0.5.0
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

-- 2. 試切到我的最愛（SearchMode.Favorites = 6）的候選 callback
local candidates = { "1 6", "2 6", "3 6", "4 6", "6 6", "8 6", "10 6", "11 6", "12 6", "13 6", "14 6", "15 6", "16 6" }
Echo("2. 試候選參數（每組 1.5 秒）")
local found = nil
for _, c in ipairs(candidates) do
    local before = ListSummary()
    yield("/callback ItemSearch true " .. c)
    yield("/wait 1.5")
    if Ready("ItemSearchResult") then CloseResult() end
    if not Ready("ItemSearch") then
        Echo("   「" .. c .. "」把搜尋視窗關掉了，停止測試")
        break
    end
    local after = ListSummary()
    if after ~= before then Echo("   「" .. c .. "」清單變成：" .. after) end
    if FindIndex(name) ~= nil then
        found = c
        break
    end
end

if found then
    Echo("找到了：切到我的最愛的參數是「" .. found .. "」")
else
    Echo("候選參數都沒有讓清單出現地圖")
end
Echo("測試結束（沒有購買）")
