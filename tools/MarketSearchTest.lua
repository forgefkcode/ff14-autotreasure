--[=====[
[[SND Metadata]]
author: forgefk
version: 1.2.0
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

-- 左側清單各列的名稱，依畫面由上到下：第 0 列在節點 51001、第 1 列 51002…，最後一列在節點 5
-- （v1.1 照「5 → 51001 → 51002」讀，結果整個錯開一格：點 G12 開到 G15…）
local function RawNode(id) return NodeText("ItemSearch", 1, 139, id, 13) end

local function Rows()
    local rows = {}
    for j = 0, 98 do
        local t = RawNode(51001 + j)
        if t == "" or t == "nil" then break end
        table.insert(rows, t)
    end
    local last = RawNode(5)
    if last ~= "" and last ~= "nil" then table.insert(rows, last) end
    return rows
end

local function ListText(i) return Rows()[i + 1] or "" end

local function ListSummary()
    local parts = {}
    for i, t in ipairs(Rows()) do table.insert(parts, "第" .. (i - 1) .. "列:" .. t) end
    if #parts == 0 then return "（空）" end
    return table.concat(parts, "、")
end

local function FindIndex(name)
    for i, t in ipairs(Rows()) do
        if t == name or (t:sub(-3) == "..." and name:find(t:sub(1, -4), 1, true) == 1) then return i - 1 end
    end
    return nil
end

-- 購買介面裡有沒有這個物品名稱（找 AtkValues 的文字），順便列出前幾個文字讓我知道名稱放在哪
local function ResultMentions(name)
    local found, texts = false, {}
    for i = 0, 80 do
        local ok, v = pcall(function() return tostring(Addons.GetAddon("ItemSearchResult"):GetAtkValue(i).ValueString) end)
        if not ok then break end
        if v ~= nil and v ~= "" and v ~= "0" and v ~= "nil" and not v:match("^%d+$") then
            if v:find(name, 1, true) then found = true; table.insert(texts, i .. "=" .. v) end
            if #texts < 6 and not v:find(name, 1, true) then table.insert(texts, i .. "=" .. v) end
        end
    end
    return found, texts
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
        Echo("   原始節點：5=「" .. RawNode(5) .. "」 51001=「" .. RawNode(51001) .. "」 51002=「" .. RawNode(51002) .. "」 51003=「" .. RawNode(51003) .. "」")
        Echo("   清單（新順序）：" .. ListSummary())
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
                local mentioned, texts = ResultMentions(name)
                Echo("   點第 " .. idx .. " 列；購買介面" .. (mentioned and "有" or "沒有") .. "提到「" .. name .. "」，文字：" .. table.concat(texts, "｜"))
                if price ~= nil and price > 0 then
                    Echo(string.format("   第一筆：單價 %d、數量 %s（請看畫面上實際打開的是哪張圖）", price, tostring(count)))
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
