--[=====[
[[SND Metadata]]
author: forgefk
version: 1.1.0
description: 測試從市場板「顯示我的最愛」清單分別點開 G12、G15、G17 藏寶圖的上架清單並讀價格，但不購買。站在市場板旁執行，把聊天框的 [MBTest] 訊息貼回來。
[[End Metadata]]
--]=====]

local function Echo(msg) yield("/echo [MBTest] " .. msg) end

-- 「顯示我的最愛」按鈕：實測 ItemSearch 事件 12（後面的數字不影響）
local FAVORITES = "12 6"
local MAPS = { 26745, 39591, 43557 }   -- G12、G15、G17

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
        table.insert(names, i .. ":" .. t)
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

-- 關掉上架清單（退出），確認真的關掉才回傳 true
local function CloseResult()
    for _ = 1, 10 do
        if not Ready("ItemSearchResult") then return true end
        yield("/callback ItemSearchResult true -1")
        yield("/wait 0.3")
    end
    return not Ready("ItemSearchResult")
end

-- 讀上架清單第一筆的單價、數量（與正式腳本 Api.MarketFirstListing 相同）
local function FirstListing()
    local pt = NodeText("ItemSearchResult", 1, 26, 4, 5)
    local ct = NodeText("ItemSearchResult", 1, 26, 4, 6)
    return tonumber((pt:gsub("%D", ""))), tonumber((ct:gsub("%D", ""))), pt, ct, NodeText("ItemSearchResult", 1, 5)
end

-- 按「顯示我的最愛」，等清單出現
local function ShowFavorites()
    yield("/callback ItemSearch true " .. FAVORITES)
    for _ = 1, 6 do
        yield("/wait 0.5")
        if ListText(0) ~= "" and ListText(0) ~= "nil" then return true end
    end
    return false
end

-- 0. 沒開就自動打開市場板（名稱從遊戲資料取，與正式腳本相同）
if not Ready("ItemSearch") then
    local boardName = tostring(Excel.GetRow("EObjName", 2000073).Singular)
    local board = Entity.GetEntityByName(boardName)
    if board == nil then
        Echo("附近找不到「" .. boardName .. "」，請站到市場板旁再執行")
        return
    end
    Echo("打開市場板（距離 " .. string.format("%.1f", board.DistanceTo or -1) .. "）")
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

-- 1. 分別處理 G12、G15、G17：顯示我的最愛 → 找到這張圖 → 點開上架清單 → 讀價格 → 退出 → 下一張
for n, itemId in ipairs(MAPS) do
    local name = tostring(Excel.GetRow("Item", itemId).Name)
    Echo(n .. ". " .. name .. "（" .. itemId .. "）")
    if not ShowFavorites() then
        Echo("   按「顯示我的最愛」後清單是空的")
    else
        Echo("   我的最愛清單：" .. ListSummary())
        local idx = FindIndex(name)
        if idx == nil then
            Echo("   清單裡找不到這張圖")
        else
            yield("/callback ItemSearch true 5 " .. idx)
            local opened = false
            for _ = 1, 10 do
                yield("/wait 0.5")
                if Ready("ItemSearchResult") then opened = true break end
            end
            if not opened then
                Echo("   點第 " .. idx .. " 項後，上架清單沒有打開")
            else
                local price, count, pt, ct, msg
                for _ = 1, 10 do
                    yield("/wait 0.5")
                    price, count, pt, ct, msg = FirstListing()
                    if price ~= nil and price > 0 then break end
                end
                if price ~= nil and price > 0 then
                    Echo(string.format("   點第 %d 項成功，第一筆：單價 %d、數量 %s", idx, price, tostring(count)))
                else
                    Echo("   上架清單打開了但讀不到價格（原文：「" .. tostring(pt) .. "」「" .. tostring(ct) .. "」，訊息：「" .. tostring(msg) .. "」）")
                end
                Echo("   退出上架清單：" .. (CloseResult() and "已關閉" or "關不掉"))
            end
        end
    end
    yield("/wait 1")
end
Echo("測試結束（沒有購買）")
