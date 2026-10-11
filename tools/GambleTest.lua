--[=====[
[[SND Metadata]]
author: forgefk
version: 0.1.0
description: 強欲陷阱診斷：找出腳本讀得到牌面數字的地方。在強欲陷阱進行中（大／小魔法球出現時）執行，約 25 秒，把聊天框的 [GambleTest] 訊息貼回來。不會互動任何東西。
function_chat_filters:
  OnChatMessage:
    message_regex: "^(?!\\[GambleTest\\])"
[[End Metadata]]
--]=====]

local function Echo(msg) yield("/echo [GambleTest] " .. msg) end

-- 收集測試期間的聊天訊息（排除自己印的 [GambleTest]），結束時一起印出
Captured = {}
function OnChatMessage()
    local ok, msg = pcall(function() return tostring(TriggerData.message) end)
    if not ok or msg == nil or msg:find("[GambleTest]", 1, true) then return end
    local tok, typ = pcall(function() return tostring(TriggerData.type) end)
    if #Captured < 40 then table.insert(Captured, (tok and ("[" .. typ .. "] ") or "") .. msg) end
end

local function Ready(name)
    local ok, r = pcall(function() return Addons.GetAddon(name).Ready end)
    return ok and r == true
end

-- 1. 附近 30 內的物件：名稱、種類、能不能選取、ID（牌可能是一個物件，名稱或 ID 會隨數字變）
Echo("1. 附近物件（30 內）：")
local okObj, errObj = pcall(function()
    local me = Entity.Player.Position
    local objs = Svc.Objects
    local shown = 0
    for i = 0, objs.Length - 1 do
        local o = objs[i]
        if o ~= nil then
            local dx, dz = o.Position.X - me.X, o.Position.Z - me.Z
            local d = math.sqrt(dx * dx + dz * dz)
            if d <= 30 then
                local name = tostring(o.Name.TextValue)
                local kind = tostring(o.ObjectKind)
                if kind ~= "Player" then
                    local _, baseId = pcall(function() return o.BaseId end)
                    local _, dataId = pcall(function() return o.DataId end)
                    Echo(string.format("   「%s」 種類 %s，可選取 %s，距離 %.1f，ID %s / %s",
                        name, kind, tostring(o.IsTargetable), d, tostring(baseId), tostring(dataId)))
                    shown = shown + 1
                    if shown >= 25 then break end
                end
            end
        end
    end
end)
if not okObj then Echo("   讀取失敗：" .. tostring(errObj)) end

-- 2. 可能顯示數字或選項的介面視窗：有開著的就印出裡面的文字資料
Echo("2. 開著的介面視窗：")
local addons = { "SelectYesno", "SelectString", "SelectIconString", "Talk", "_BattleTalk", "_ScreenText",
                 "_TextError", "_WideText", "_PopUpText", "ScreenInfo", "ScreenInfoFrontBack", "_TextClassChange",
                 "JournalResult", "_NotificationTimer", "ContentsInfo", "_TargetInfoMainTarget" }
local anyOpen = false
for _, name in ipairs(addons) do
    if Ready(name) then
        anyOpen = true
        local texts = {}
        for i = 0, 30 do
            local ok, v = pcall(function() return tostring(Addons.GetAddon(name):GetAtkValue(i).ValueString) end)
            if not ok then break end
            if v ~= "" and v ~= "0" and v ~= "nil" then table.insert(texts, i .. "=" .. v) end
            if #texts >= 8 then break end
        end
        Echo("   " .. name .. "：" .. (#texts > 0 and table.concat(texts, "｜") or "（沒有文字資料）"))
    end
end
if not anyOpen then Echo("   （候選視窗都沒有開）") end

-- 3. 收集 20 秒聊天訊息：請在這段時間內照平常操作（可以選大／小，或什麼都不做）
Echo("3. 收集 20 秒聊天訊息，期間可以照平常操作…")
yield("/wait 20")
Echo("   收到 " .. #Captured .. " 則：")
for _, m in ipairs(Captured) do Echo("   " .. m) end
Echo("測試結束")
