--[=====[
[[SND Metadata]]
author: forgefk
version: 0.4.0
description: 市場板搜尋診斷（剪貼簿貼上版）。先打開市場板（出現搜尋視窗），再執行這支腳本，把聊天框的 [MBTest] 訊息貼回來。不會購買。會覆蓋剪貼簿內容。
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

-- 與正式腳本相同的剪貼簿寫法
local function SetClipboard(text)
    local ok, err = pcall(function()
        luanet.load_assembly("System.Diagnostics.Process")
        local script = "Set-Clipboard -Value '" .. text:gsub("'", "''") .. "'"
        local bytes = luanet.import_type("System.Text.Encoding").Unicode:GetBytes(script)
        local b64 = luanet.import_type("System.Convert").ToBase64String(bytes)
        local psi = luanet.import_type("System.Diagnostics.ProcessStartInfo")()
        psi.FileName = "powershell.exe"
        psi.Arguments = "-NoProfile -NonInteractive -WindowStyle Hidden -EncodedCommand " .. b64
        psi.CreateNoWindow = true
        psi.UseShellExecute = false
        local p = luanet.import_type("System.Diagnostics.Process").Start(psi)
        if not p:WaitForExit(5000) or p.ExitCode ~= 0 then error("powershell failed") end
    end)
    if ok then return "PowerShell" end
    Echo("   PowerShell 失敗：" .. tostring(err))
    ok, err = pcall(function()
        luanet.load_assembly("Dalamud.Bindings.ImGui")
        luanet.import_type("Dalamud.Bindings.ImGui.ImGui").SetClipboardText(text)
    end)
    if ok then return "ImGui" end
    Echo("   ImGui 失敗：" .. tostring(err))
    return nil
end

local itemId = Config.Get("ItemId")
local name = tostring(Excel.GetRow("Item", itemId).Name)
Echo("物品：" .. name .. "（" .. itemId .. "）")

if not Ready("ItemSearch") then
    Echo("1. ItemSearch 沒開，請先打開市場板再執行")
    return
end
Echo("1. ItemSearch 已開啟")

-- 2. 寫入剪貼簿
local method = SetClipboard(name)
if method == nil then
    Echo("2. 剪貼簿寫入失敗，停止")
    return
end
Echo("2. 剪貼簿寫入成功（" .. method .. "）。可以在別處 Ctrl+V 確認內容")

-- 3. Ctrl+A、Ctrl+V、Enter
yield("/send CONTROL+A")
yield("/wait 0.2")
yield("/send CONTROL+V")
yield("/wait 0.5")
Echo("3. 已送出 Ctrl+A、Ctrl+V，請看搜尋框有沒有出現名稱")
yield("/wait 1")
yield("/send RETURN")
yield("/wait 2")
Echo("   按 Enter 2 秒後：node 1,140 = " .. NodeText("ItemSearch", 1, 140))
Echo("   node 1,142,148 = " .. NodeText("ItemSearch", 1, 142, 148))

-- 4. 點第一筆結果
yield("/callback ItemSearch true 5 0")
local opened = false
for _ = 1, 10 do
    yield("/wait 0.5")
    if Ready("ItemSearchResult") then opened = true break end
end
if not opened then
    Echo("4. 點第一筆結果後，ItemSearchResult 沒有打開")
    return
end
Echo("4. ItemSearchResult 已打開，等 3 秒讓上架資料載入")
yield("/wait 3")

-- 5. 找價格放在哪
Echo("5. 候選節點：")
for _, p in ipairs({ { 1, 26, 4, 5 }, { 1, 26, 4, 6 }, { 1, 5 }, { 1, 29 }, { 5, 1, 10 }, { 2 }, { 26 } }) do
    Echo("   node " .. table.concat(p, ",") .. " = " .. NodeText("ItemSearchResult", table.unpack(p)))
end
Echo("   ItemSearchResult 的 AtkValues：")
DumpValues("ItemSearchResult", 120)

yield("/callback ItemSearchResult true -1")
Echo("測試結束（已關閉上架清單，沒有購買）")
