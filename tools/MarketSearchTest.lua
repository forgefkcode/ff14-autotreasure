--[=====[
[[SND Metadata]]
author: forgefk
version: 0.3.0
description: 市場板搜尋診斷。先打開市場板（出現搜尋視窗），再執行這支腳本，把聊天框的 [MBTest] 訊息貼回來。不會購買。
configs:
  ItemId:
    default: 39591
    description: 要搜尋的物品 ID（39591 = G15，43557 = G17）
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
    if not ok then return "(讀取失敗)" end
    return "「" .. tostring(t) .. "」"
end

-- 逐一讀 AtkValue（用索引，不用列舉），只印非空的
local function DumpValues(addon, limit)
    local shown = 0
    for i = 0, limit - 1 do
        local ok, s = pcall(function() return tostring(Addons.GetAddon(addon):GetAtkValue(i).ValueString) end)
        if not ok then break end
        if s ~= "" and s ~= "0" and s ~= "nil" then
            Echo("   " .. addon .. "[" .. i .. "] = " .. s)
            shown = shown + 1
            if shown >= 25 then break end
        end
    end
end

local itemId = Config.Get("ItemId")
local name = tostring(Excel.GetRow("Item", itemId).Name)
Echo("物品：" .. name .. "（" .. itemId .. "）")

if not Ready("ItemSearch") then
    Echo("1. ItemSearch 沒開，請先打開市場板再執行")
    return
end
Echo("1. ItemSearch 已開啟")

-- 2. 搜尋（新參數，取自 extrahase/SND_repo）。名稱不加引號，避開 SND /callback 解析引號的 bug
yield(string.format("/callback ItemSearch true 9 1 2 %s %s 5 6 7", name, name))
yield("/wait 2")
Echo("2. 已送出搜尋，2 秒後：")
Echo("   node 1,140 = " .. NodeText("ItemSearch", 1, 140))
Echo("   node 1,142,148 = " .. NodeText("ItemSearch", 1, 142, 148))

-- 3. 點第一筆結果
yield("/callback ItemSearch true 5 0")
local opened = false
for _ = 1, 10 do
    yield("/wait 0.5")
    if Ready("ItemSearchResult") then opened = true break end
end
if not opened then
    Echo("3. 點第一筆結果後，ItemSearchResult 沒有打開")
    return
end
Echo("3. ItemSearchResult 已打開，等 3 秒讓上架資料載入")
yield("/wait 3")

-- 4. 找價格放在哪：舊腳本用過的幾種節點位置都讀一次
Echo("4. 候選節點：")
for _, p in ipairs({ { 1, 26, 4, 5 }, { 1, 26, 4, 6 }, { 1, 5 }, { 1, 29 }, { 5, 1, 10 }, { 2 }, { 26 } }) do
    Echo("   node " .. table.concat(p, ",") .. " = " .. NodeText("ItemSearchResult", table.unpack(p)))
end
Echo("   ItemSearchResult 的 AtkValues：")
DumpValues("ItemSearchResult", 120)

yield("/callback ItemSearchResult true -1")
Echo("測試結束（已關閉上架清單，沒有購買）")
