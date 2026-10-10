--[=====[
[[SND Metadata]]
author: forgefk
version: 0.1.0
description: 市場板搜尋診斷。先打開市場板（出現搜尋視窗），再執行這支腳本，把聊天框的 [MBTest] 訊息貼回來。
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
    return tostring(t)
end

-- 印出視窗的 AtkValues（字串與數字），用來看搜尋條件和結果有沒有寫進去
local function DumpValues(addon, limit)
    local ok, err = pcall(function()
        local i = 0
        for v in luanet.each(Addons.GetAddon(addon).AtkValues) do
            local s = tostring(v.ValueString)
            if s ~= "" and s ~= "0" then Echo(addon .. "[" .. i .. "] = " .. s) end
            i = i + 1
            if i >= limit then break end
        end
        Echo(addon .. " 共讀了 " .. i .. " 個 AtkValue")
    end)
    if not ok then Echo(addon .. " AtkValues 讀取失敗：" .. tostring(err)) end
end

local itemId = Config.Get("ItemId")
local name = tostring(Excel.GetRow("Item", itemId).Name)
Echo("物品：" .. name .. "（" .. itemId .. "）")

-- 1. 搜尋視窗是否開著
if not Ready("ItemSearch") then
    Echo("1. ItemSearch 沒開，請先打開市場板再執行")
    return
end
Echo("1. ItemSearch 已開啟")

-- 2. 清空搜尋條件
yield("/callback ItemSearch true 7 -1 0 -1 -1 -1 -1 -1")
yield("/wait 1")
Echo("2. 已送出清空條件")

-- 3. 送出搜尋（社群腳本的參數）
yield(string.format('/callback ItemSearch true 0 -1 0 "%s" "%s" 100 100 34', name, name))
yield("/wait 3")
Echo("3. 已送出搜尋，3 秒後節點文字：")
Echo("   node 1,140 = " .. NodeText("ItemSearch", 1, 140))
Echo("   node 1,142,148 = " .. NodeText("ItemSearch", 1, 142, 148))
DumpValues("ItemSearch", 60)

-- 4. 點第一筆結果，看上架清單會不會打開
yield("/callback ItemSearch true 5 0")
yield("/wait 3")
if Ready("ItemSearchResult") then
    Echo("4. ItemSearchResult 已打開")
    Echo("   第一筆單價 node 1,26,4,5 = " .. NodeText("ItemSearchResult", 1, 26, 4, 5))
    Echo("   第一筆數量 node 1,26,4,6 = " .. NodeText("ItemSearchResult", 1, 26, 4, 6))
    Echo("   訊息 node 1,5 = " .. NodeText("ItemSearchResult", 1, 5))
    DumpValues("ItemSearchResult", 40)
else
    Echo("4. 點第一筆結果後，ItemSearchResult 沒有打開")
end
Echo("測試結束")
