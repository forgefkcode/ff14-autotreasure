--[=====[
[[SND Metadata]]
author: forgefk
version: 0.2.0
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

-- 2. 確認 SND 有提供 ActionType 列舉。只能傳 ActionType.Item：
--    傳數字或字串給列舉參數會在 Lua 外丟出例外，pcall 攔不到，SND 會直接停掉腳本（v0.1 就是死在這裡）
if ActionType == nil or ActionType.Item == nil then
    Echo("2. 讀不到 ActionType.Item，無法測試")
    return
end
Echo("2. ActionType.Item = " .. tostring(ActionType.Item))
local actionId = hasHq and (foundId + 1000000) or foundId
local status = Actions.GetActionStatus(ActionType.Item, actionId)
Echo("   使用狀態（0 = 可用）：" .. tostring(status))

-- 3. 使用，2 秒後看數量
local total = nq + hq
Actions.ExecuteAction(actionId, ActionType.Item)
yield("/wait 2")
local n2, h2 = Counts()
local after = n2 + h2
if after < total then
    Echo(string.format("3. 成功：藥水 %d → %d 瓶", total, after))
else
    Echo("3. 沒有喝到（藥水數量沒變）。如果第 2 步狀態不是 0，可能是藥水冷卻中，等一下再試")
end
Echo("測試結束")
