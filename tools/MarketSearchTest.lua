--[=====[
[[SND Metadata]]
author: forgefk
version: 0.8.0
description: 測試市場板搜尋視窗 callback「12 1」～「12 6」，並實際點開地圖的上架清單、讀價格（與正式腳本相同的方法），但不購買。站在市場板旁執行，把聊天框的 [MBTest] 訊息貼回來。
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

local function FindIndex(name)
    for i = 0, 99 do
        local t = ListText(i)
        if t == "" or t == "nil" then return nil end
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

-- 讀上架清單第一筆的單價、數量（與正式腳本 Api.MarketFirstListing 相同）
local function FirstListing()
    local priceText = NodeText("ItemSearchResult", 1, 26, 4, 5)
    local countText = NodeText("ItemSearchResult", 1, 26, 4, 6)
    local price = tonumber((priceText:gsub("%D", "")))
    local count = tonumber((countText:gsub("%D", "")))
    return price, count, priceText, countText, NodeText("ItemSearchResult", 1, 5)
end

local name = tostring(Excel.GetRow("Item", Config.Get("ItemId")).Name)
Echo("要找的地圖：" .. name)

-- 0. 沒開就自動打開市場板（名稱從遊戲資料取，與正式腳本相同）
if not Ready("ItemSearch") then
    local boardName = tostring(Excel.GetRow("EObjName", 2000073).Singular)
    local board = Entity.GetEntityByName(boardName)
    if board == nil then
        Echo("附近找不到「" .. boardName .. "」，請站到市場板旁再執行")
        return
    end
    Echo("打開市場板「" .. boardName .. "」（距離 " .. string.format("%.1f", board.DistanceTo or -1) .. "）")
    board:SetAsTarget()
    board:Interact()
    for _ = 1, 20 do
        yield("/wait 0.5")
        if Ready("ItemSearch") then break end
    end
    if not Ready("ItemSearch") then
        Echo("10 秒內搜尋視窗沒有打開（可能太遠，請走近一點）")
        return
    end
end
Echo("搜尋視窗已開，打開時清單：" .. ListSummary())

for i = 1, 6 do
    local c = "12 " .. i
    yield("/callback ItemSearch true " .. c)
    yield("/wait 1")
    if Ready("ItemSearchResult") then CloseResult() end
    if not Ready("ItemSearch") then
        Echo("「" .. c .. "」把搜尋視窗關掉了，停止測試")
        break
    end
    Echo("「" .. c .. "」清單：" .. ListSummary())

    local idx = FindIndex(name)
    if idx == nil then
        Echo("   清單上沒有地圖，不點開")
    else
        -- 點開地圖的上架清單，等最多 5 秒載入，讀第一筆價格；不購買，讀完就關掉
        yield("/callback ItemSearch true 5 " .. idx)
        local opened = false
        for _ = 1, 10 do
            yield("/wait 0.5")
            if Ready("ItemSearchResult") then opened = true break end
        end
        if not opened then
            Echo("   點開地圖（第 " .. idx .. " 項）後，上架清單沒有打開")
        else
            local price, count, pt, ct, msg
            for _ = 1, 10 do
                yield("/wait 0.5")
                price, count, pt, ct, msg = FirstListing()
                if price ~= nil and price > 0 then break end
            end
            if price ~= nil and price > 0 then
                Echo(string.format("   上架清單第一筆：單價 %d、數量 %s（原文：「%s」「%s」）", price, tostring(count), pt, ct))
            else
                Echo("   讀不到價格（原文：「" .. tostring(pt) .. "」「" .. tostring(ct) .. "」，訊息：「" .. tostring(msg) .. "」）")
            end
            CloseResult()
        end
    end
    yield("/wait 2")
end
Echo("測試結束（沒有購買）。請告訴我每一組畫面上是哪個分頁")
