--[=====[
[[SND Metadata]]
author: forgefk
version: 0.1.0
description: 喝藥測試（與正式腳本相同的做法）。在背包放好藥水後執行，把聊天框的 [PotionTest] 訊息貼回來。會實際喝掉一瓶。
configs:
  PotionItemName:
    default: "聖級治療劑"
    description: 要測試的藥水名稱（與遊戲內一字不差）
[[End Metadata]]
--]=====]

local function Echo(msg) yield("/echo [PotionTest] " .. msg) end

local name = Config.Get("PotionItemName")
Echo("藥水：" .. tostring(name))

-- 1. 在背包 4 頁找這瓶藥（與正式腳本 Api.FindInventoryItem 相同）
local foundId, hasHq = nil, false
local ok, err = pcall(function()
    for _, container in ipairs({ InventoryType.Inventory1, InventoryType.Inventory2,
                                 InventoryType.Inventory3, InventoryType.Inventory4 }) do
        local items = Inventory.GetInventoryContainer(container).Items
        for i = 0, items.Count - 1 do
            local it = items[i]
            if it ~= nil and not it.IsEmpty then
                local id = it.BaseItemId
                if id == foundId or tostring(Excel.GetRow("Item", id).Name) == name then
                    foundId = id
                    if it.IsHighQuality then hasHq = true end
                end
            end
        end
    end
end)
if not ok then
    Echo("1. 掃背包失敗：" .. tostring(err))
    return
end
if foundId == nil then
    Echo("1. 背包裡找不到「" .. tostring(name) .. "」（只找背包 4 頁，鞍囊、兵裝庫不算）")
    return
end

local function Counts()
    return Inventory.GetItemCount(foundId), Inventory.GetHqItemCount(foundId)
end
local nq, hq = Counts()
Echo(string.format("1. 找到了：物品 ID %d，NQ %d 瓶、HQ %d 瓶（%s）", foundId, nq, hq, hasHq and "會用 HQ" or "會用 NQ"))

-- 2. 遊戲回報能不能用（0 = 可用；2 = 道具類型；HQ 的 ID 加 1000000）
local actionId = hasHq and (foundId + 1000000) or foundId
local sok, status = pcall(function() return Actions.GetActionStatus(2, actionId) end)
Echo("2. 使用狀態（0 = 可用）：" .. (sok and tostring(status) or ("查詢失敗：" .. tostring(status))))
Echo("   ActionType 這個名稱" .. (ActionType ~= nil and "存在" or "不存在（nil）"))

-- 3. 依序試三種寫法，喝到就停
local methods = {
    { "數字 2", function() Actions.ExecuteAction(actionId, 2) end },
    { "ActionType.Item", function() Actions.ExecuteAction(actionId, ActionType.Item) end },
    { "文字 \"Item\"", function() Actions.ExecuteAction(actionId, "Item") end },
}
local total = nq + hq
for i, m in ipairs(methods) do
    local cok, cerr = pcall(m[2])
    yield("/wait 2")
    local n2, h2 = Counts()
    local after = n2 + h2
    if after < total then
        Echo(string.format("3-%d. 「%s」成功：藥水 %d → %d 瓶", i, m[1], total, after))
        Echo("測試結束：這種寫法可以用")
        return
    end
    Echo(string.format("3-%d. 「%s」沒有喝到%s", i, m[1], cok and "（沒有錯誤訊息）" or ("：" .. tostring(cerr))))
end
Echo("測試結束：三種寫法都沒有喝到。如果第 2 步狀態不是 0，可能是藥水冷卻中，等一下再試")
