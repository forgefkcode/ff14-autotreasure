--[=====[
[[SND Metadata]]
author: forgefk
version: 0.1.0
description: 小隊邀請拒絕測試：只跑自動腳本裡「拒絕小隊邀請」這一段。執行後請別人邀請你，會在聊天框印出確認框文字、判定結果和隊伍人數變化。只會拒絕小隊邀請，其他確認框不會按。
[[End Metadata]]
--]=====]

-- 下面的 EnumName、Api.ToLuaList、Api.AddonReady、Api.AddonText、Api.DeclinePartyInvite 和 G17_AutoTreasure.lua 完全相同，
-- 測到的就是腳本實際的判斷。自動腳本還會在 Api.ConfirmYes 裡先呼叫 DeclinePartyInvite，不是邀請才按「是」；這裡不測按「是」。
-- 測試時不要同時跑自動腳本。

local DURATION = 300   -- 最多跑幾秒

local Api = {}

local function Echo(msg)
    yield("/echo [InviteTest] " .. msg)
end

function Log(msg)
    Echo(msg)
end

local function EnumName(v)
    local s = tostring(v)
    return s:match("^([%w_]+)") or s
end

function Api.AddonReady(name)
    local a = Addons.GetAddon(name)
    return a ~= nil and a.Ready
end

function Api.ToLuaList(enumerable)
    local ok, items = pcall(function()
        local ListType = luanet.import_type("System.Collections.Generic.List`1[System.Object]")
        local list = ListType(enumerable)
        local out = {}
        for i = 0, list.Count - 1 do
            local item = list[i]
            if item == nil then item = list:get_Item(i) end
            out[#out + 1] = item
        end
        return out
    end)
    if ok then return items end
    return nil
end

function Api.AddonText(name)
    local parts = {}
    pcall(function()
        local a = Addons.GetAddon(name)
        for _, node in ipairs(Api.ToLuaList(a.Nodes) or {}) do
            if EnumName(node.NodeType) == "Text" and node.IsVisible then
                local t = tostring(node.Text)
                if t ~= "" and t ~= "nil" then parts[#parts + 1] = t end
            end
        end
    end)
    if #parts == 0 then
        pcall(function()
            local a = Addons.GetAddon(name)
            for _, v in ipairs(Api.ToLuaList(a.AtkValues) or {}) do
                local s = tostring(v.ValueString)
                if s ~= "" and s ~= "nil" and s ~= "0" then parts[#parts + 1] = s end
            end
        end)
    end
    return table.concat(parts, " ")
end

function Api.DeclinePartyInvite()
    if not Api.AddonReady("SelectYesno") then return false end
    local q = Api.AddonText("SelectYesno")
    if q:find("確定要加入", 1, true) and q:find("的小隊嗎", 1, true) then
        Log("拒絕小隊邀請")
        yield("/callback SelectYesno true 1")
        return true
    end
    if q:find("確定要拒絕", 1, true) and q:find("組隊邀請", 1, true) then
        yield("/callback SelectYesno true 0")
        return true
    end
    return false
end

-- 隊伍人數；讀不到回傳 nil（不影響拒絕，只是少一項佐證）
local function PartySize()
    local ok, n = pcall(function() return Svc.Party.Length end)
    if ok then return n end
    return nil
end

local function PartyLabel(n)
    return n == nil and "讀不到" or tostring(n)
end

local partyStart = PartySize()
local partyLast = partyStart
local lastText = nil       -- 目前開著的確認框文字
local presses, others = 0, 0
local started = os.clock()

Echo("開始（最多 " .. DURATION .. " 秒），目前隊伍人數 " .. PartyLabel(partyStart) .. "。請別人邀請你；收到邀請時不要自己按")

while os.clock() - started < DURATION do
    if Api.AddonReady("SelectYesno") then
        local q = Api.AddonText("SelectYesno")
        local isNew = q ~= lastText
        if isNew then Echo("確認框：" .. (q == "" and "（讀不到文字）" or q)) end
        lastText = q
        if Api.DeclinePartyInvite() then
            presses = presses + 1
        elseif isNew then
            others = others + 1
            Echo("判定：不是小隊邀請，不按。如果它其實是邀請，把上面那行文字貼回來")
        end
    elseif lastText ~= nil then
        Echo("確認框關閉")
        lastText = nil
    end

    local n = PartySize()
    if n ~= partyLast then
        Echo("隊伍人數 " .. PartyLabel(partyLast) .. " → " .. PartyLabel(n))
        partyLast = n
    end
    yield("/wait 0.3")
end

Echo(string.format("測試結束：按了 %d 次拒絕，%d 個其他確認框沒按；隊伍人數 %s → %s",
    presses, others, PartyLabel(partyStart), PartyLabel(partyLast)))
