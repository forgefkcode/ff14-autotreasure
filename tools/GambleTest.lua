--[=====[
[[SND Metadata]]
author: forgefk
version: 0.5.0
description: 強欲陷阱卡牌診斷：找出寶箱上方立體卡牌的數字存在哪裡。強欲陷阱視窗出現時（或按挑戰前）執行，照平常挑戰、選大／小；腳本只讀資料、不會按任何按鈕。強欲陷阱結束後可以直接停。把聊天框的 [GambleTest] 訊息全部貼回來，並寫下每一輪畫面上卡牌的數字（例如：第1張 5、選大、第2張 8 ...）。
function_chat_filters:
  OnChatMessage:
    message_regex: "^(?!\\[GambleTest\\])"
[[End Metadata]]
--]=====]

-- 立體卡牌是場景物件（EventObj），數字不是文字。v0.4 看到寶箱周圍有幾個沒有名稱的 EventObj，名稱和位置整場都沒變，
-- 所以數字應該在物件的記憶體裡。FFXIVClientStructs 的 EventObject（0x1C0 bytes）：
--   0x70 EventState、0x84 BaseId、0x97 Visibility、0x9A TargetableStatus（GameObject 共通）
--   0x1B2 SharedTimelineState（伺服器切換物件動畫／外觀狀態用，最可能是卡牌數字）、0x1B4 Arg、0x1B8 Flags
-- 每 INTERVAL 秒讀一次寶箱周圍物件的這些欄位，再比對整個結構的原始 bytes，只印有變化的部分（像 1～9 的值標 ★）。
--
-- 讀記憶體的方法（NLua 1.7.9 實測）：Marshal.ReadByte(IntPtr.Add(位址, 位移))。
-- 不能用 Marshal.ReadByte(位址, 位移)：NLua 會選到讀 .NET 物件本身的那個多載，讀出錯的值。
-- 安全：只讀物件結構範圍內（EventObj 0x1C0、其他 0x1A0），第一次讀記憶體前先印一行。

local DURATION   = 240   -- 最多幾秒（強欲陷阱結束就可以停）
local INTERVAL   = 1     -- 每幾秒讀一次
local NEAR_CHEST = 15    -- 寶箱周圍多遠內的物件算候選
local CHEST_NAME = "寶箱"

-- /echo 走遊戲聊天框，一則最多 500 bytes（中文一字 3 bytes）：超過 400 bytes 就依 UTF-8 字元邊界切成多則
local function Echo(msg)
    msg = "[GambleTest] " .. msg
    while #msg > 0 do
        local cut = #msg
        if cut > 400 then
            cut = 400
            while cut > 0 and (msg:byte(cut + 1) or 0) >= 0x80 and (msg:byte(cut + 1) or 0) < 0xC0 do cut = cut - 1 end
        end
        yield("/echo " .. msg:sub(1, cut))
        msg = msg:sub(cut + 1)
        if #msg > 0 then msg = "[GambleTest] …" .. msg end
    end
end

-- .NET 列舉轉成名稱：NLua 的 tostring(列舉) 是「EventObj: 7」這種格式，只取冒號前的名稱
local function EnumName(v)
    local s = tostring(v)
    return s:match("^([%w_]+)") or s
end

local function Star(v)
    if type(v) == "number" and v >= 1 and v <= 9 then return "★" .. v end
    return tostring(v)
end

-- 聊天訊息：收到就記下，主迴圈每次立刻印出（中途停掉也不會漏）
Captured = {}
function OnChatMessage()
    local ok, msg = pcall(function() return tostring(TriggerData.message) end)
    if not ok or msg == nil or msg:find("[GambleTest]", 1, true) then return end
    table.insert(Captured, string.format("%.0f秒 %s", os.clock() - (StartedAt or os.clock()), msg))
end

---------------------------------------------------------------- 讀物件記憶體

local Marshal = luanet.import_type("System.Runtime.InteropServices.Marshal")
local IntPtr  = luanet.import_type("System.IntPtr")

local function U8(addr, ofs) return Marshal.ReadByte(IntPtr.Add(addr, ofs)) end
local function U16(addr, ofs)
    local v = Marshal.ReadInt16(IntPtr.Add(addr, ofs))
    if v < 0 then v = v + 65536 end
    return v
end
local function U32(addr, ofs)
    local v = Marshal.ReadInt32(IntPtr.Add(addr, ofs))
    if v < 0 then v = v + 4294967296 end
    return v
end

-- 原始 bytes 比對時略過：會一直跳動、跟卡牌無關的欄位（目標狀態、距離、更新旗標）
local SKIP = { [0x93] = true, [0x94] = true, [0x95] = true, [0x96] = true, [0x9B] = true }

local memoryNoted = false
-- 回傳 (欄位描述, 原始 bytes 表)
local function ReadObject(o)
    local addr = o.Address
    if addr == nil then return "（讀不到位址）", {} end
    if not memoryNoted then
        Echo("（第一次讀物件記憶體…）")
        memoryNoted = true
    end
    local isEventObj = EnumName(o.ObjectKind) == "EventObj"
    local fields = string.format("EventState=%s BaseId=%d Visibility=%s Targetable=%s",
        Star(U8(addr, 0x70)), U32(addr, 0x84), Star(U8(addr, 0x97)), Star(U8(addr, 0x9A)))
    if isEventObj then
        fields = fields .. string.format(" Timeline=%s Arg=%s Flags=%s",
            Star(U16(addr, 0x1B2)), Star(U32(addr, 0x1B4)), Star(U8(addr, 0x1B8)))
    end
    local raw = {}
    for ofs = 0, (isEventObj and 0x1BF or 0x19F) do
        if not SKIP[ofs] then raw[ofs] = U8(addr, ofs) end
    end
    return fields, raw
end

-- 寶箱周圍的候選物件：{ [物件索引] = { label, fields, raw } }
local function Snapshot()
    local objs = Svc.Objects
    local center = nil
    for i = 0, objs.Length - 1 do
        local o = objs[i]
        if o ~= nil and o.Name.TextValue == CHEST_NAME then center = o.Position; break end
    end
    center = center or Entity.Player.Position
    local snap = {}
    for i = 0, objs.Length - 1 do
        local o = objs[i]
        if o ~= nil then
            local kind = EnumName(o.ObjectKind)
            if kind == "EventObj" or kind == "Treasure" then
                local dx, dz = o.Position.X - center.X, o.Position.Z - center.Z
                if math.sqrt(dx * dx + dz * dz) <= NEAR_CHEST then
                    local ok, fields, raw = pcall(ReadObject, o)
                    if not ok then fields, raw = "（讀取失敗：" .. tostring(fields) .. "）", {} end
                    snap[i] = {
                        label = string.format("#%d「%s」%s (%.1f, %.1f)", i, o.Name.TextValue, kind, o.Position.X, o.Position.Z),
                        fields = fields, raw = raw,
                    }
                end
            end
        end
    end
    return snap
end

---------------------------------------------------------------- 視窗（強欲陷阱視窗、確認框）

local WINDOWS = { "TreasureHighLow", "SelectYesno" }

-- AddonWrapper.AtkValues 是 C# 編譯器產生的 iterator，NLua 叫不到 GetEnumerator：先轉成 List<object> 再用索引讀
local function ToLuaList(enumerable)
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

local function WindowTexts()
    local snap = {}
    for _, name in ipairs(WINDOWS) do
        local a = Addons.GetAddon(name)
        if a.Exists and a.Ready then
            local values = {}
            for idx, v in ipairs(ToLuaList(a.AtkValues) or {}) do
                if idx > 60 then break end
                local ok, s = pcall(function() return tostring(v.ValueString) end)
                if ok and s ~= "" and s ~= "nil" then table.insert(values, (idx - 1) .. "=" .. s) end
            end
            snap[name] = table.concat(values, " ")
        end
    end
    return snap
end

---------------------------------------------------------------- 主程式

local function RawDiff(old, new)
    local parts = {}
    for ofs, v in pairs(new) do
        if old[ofs] ~= nil and old[ofs] ~= v then
            table.insert(parts, { ofs, string.format("0x%X:%d→%s", ofs, old[ofs], Star(v)) })
        end
    end
    table.sort(parts, function(a, b) return a[1] < b[1] end)
    local out = {}
    for k = 1, math.min(#parts, 16) do out[k] = parts[k][2] end
    if #parts > 16 then table.insert(out, "…共 " .. #parts .. " 處") end
    return table.concat(out, " ")
end

StartedAt = os.clock()
Echo("v0.5 開始（最多 " .. DURATION .. " 秒，只讀資料、不按按鈕；強欲陷阱結束就可以停）。目前地區 " .. tostring(Svc.ClientState.TerritoryType))
Echo("請寫下每一輪畫面上卡牌的數字，貼回來時一起附上")

local prev = Snapshot()
Echo("1. 寶箱周圍 " .. NEAR_CHEST .. " 碼內的物件：")
for _, v in pairs(prev) do Echo("   " .. v.label .. " " .. v.fields) end
local prevWin = WindowTexts()
for name, v in pairs(prevWin) do Echo("   視窗 " .. name .. "：" .. v) end
local shownChat = 0

local elapsed = 0
while elapsed < DURATION do
    yield("/wait " .. INTERVAL)
    elapsed = elapsed + INTERVAL
    local cur = Snapshot()
    for k, v in pairs(cur) do
        local p = prev[k]
        if p == nil then
            Echo(string.format("%d秒 + %s %s", elapsed, v.label, v.fields))
        else
            if p.fields ~= v.fields then Echo(string.format("%d秒 ~ %s %s", elapsed, v.label, v.fields)) end
            local diff = RawDiff(p.raw, v.raw)
            if diff ~= "" then Echo(string.format("%d秒   %s 原始變化：%s", elapsed, v.label, diff)) end
        end
    end
    for k, p in pairs(prev) do
        if cur[k] == nil then Echo(string.format("%d秒 - %s", elapsed, p.label)) end
    end
    prev = cur
    local win = WindowTexts()
    for name, v in pairs(win) do
        if prevWin[name] ~= v then Echo(string.format("%d秒 視窗 %s：%s", elapsed, name, v)) end
    end
    for name in pairs(prevWin) do
        if win[name] == nil then Echo(string.format("%d秒 視窗 %s 關閉", elapsed, name)) end
    end
    prevWin = win
    while shownChat < #Captured do
        shownChat = shownChat + 1
        Echo("聊天：" .. Captured[shownChat])
    end
end
Echo("測試結束")
