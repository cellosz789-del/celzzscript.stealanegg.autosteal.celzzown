-- ═══════════════════════════════════════════════════════════════
--  CELZZ NIGHT | Auto Steal + Auto Night Detect
--  Powered by EGX AI | ENDXZ
--  Monochrome Ultra Edition
-- ═══════════════════════════════════════════════════════════════

local CONFIG = {
    AutoSteal = false,
    NightPause = true,
    IdleWhenNoEgg = true,

    -- Detection mode
    DetectMode = "auto", -- "auto", "clocktime", "attribute", "custom"

    -- ClockTime fallback
    DayStartHour = 6,
    NightStartHour = 18,

    -- Speed
    MinDelay = 1.5,
    MaxDelay = 4.0,
    EggCooldown = 3.5,
    RemoteCooldown = 1.0,

    -- Anti-Detect
    Layer1_RandomDelay = true,
    Layer2_RandomBreak = true,
    Layer3_SessionLimit = true,
    Layer4_AntiReport = true,
    Layer5_RandomMovement = true,
    Layer6_AntiAFK = true,
    Layer7_StealthMode = true,
    Layer8_WalkNatural = true,
    Layer9_RemoteThrottle = true,
    Layer10_HumanBehavior = true,

    BreakInterval = 480,
    BreakDuration = 45,
    SessionLimit = 5400,
    SessionRest = 600,
    AntiReportRange = 60,
    StealthRange = 80,
    MaxRemotesPerMinute = 20,

    MaxDistance = 800,

    SelectedRarities = {"divine", "secret", "eternal", "lunar"},
}

local RUNNING = true
local START_TIME = tick()
local LAST_BREAK = tick()
local DETECTED = false
local REMOTE_COUNTER = 0
local NIGHT_MODE = "unknown"
local NIGHT_SOURCE = nil

local STATS = {
    eggsStolen = 0, breaks = 0, detectPauses = 0,
    sessionRests = 0, remotesFired = 0,
}

local RARITY_ORDER = {
    "divine","secret","eternal","lunar","mythic",
    "legendary","epic","rare","uncommon","common","normal"
}

local HIGH_PRIORITY_EGGS = {
    ["unicorn"]="divine", ["kitsune"]="divine",
    ["eternal lunar dragon"]="eternal", ["gorilla king"]="eternal",
    ["oni tiger"]="eternal", ["mosasaurus"]="eternal",
    ["el maja"]="eternal", ["ice dragon"]="eternal", ["lava dragon"]="eternal",
    ["mutant shark"]="secret", ["stag"]="secret", ["t-rex"]="secret",
    ["tralaledon"]="secret", ["cosmic skeleton boss"]="secret",
    ["cosmic dragon"]="secret", ["king snake"]="secret",
    ["cerberus"]="secret", ["kraken"]="secret", ["phoenix"]="secret",
}

local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService      = game:GetService("TweenService")
local VirtualUser       = game:GetService("VirtualUser")
local Lighting          = game:GetService("Lighting")
local LocalPlayer       = Players.LocalPlayer
local PlayerGui         = LocalPlayer:WaitForChild("PlayerGui")

local THEME = {
    Bg=Color3.fromRGB(0,0,0), Panel=Color3.fromRGB(12,12,12), Card=Color3.fromRGB(22,22,22),
    Border=Color3.fromRGB(50,50,50), Text=Color3.fromRGB(255,255,255),
    TextDim=Color3.fromRGB(150,150,150), TextMuted=Color3.fromRGB(90,90,90),
    Accent=Color3.fromRGB(255,255,255),
}

local old = PlayerGui:FindFirstChild("CELZZ_UI")
if old then old:Destroy() end

local gui = Instance.new("ScreenGui")
gui.Name = "CELZZ_UI"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.IgnoreGuiInset = true
gui.DisplayOrder = 999
gui.Parent = PlayerGui

-- CIRCLE
local circle = Instance.new("TextButton")
circle.Size = UDim2.new(0, 58, 0, 58)
circle.Position = UDim2.new(0.5, -29, 0.5, -29)
circle.BackgroundColor3 = THEME.Bg
circle.BorderSizePixel = 0
circle.Text = "CELZZ"
circle.TextColor3 = THEME.Text
circle.TextSize = 10
circle.Font = Enum.Font.GothamBlack
circle.AutoButtonColor = false
circle.Active = true
circle.Parent = gui
Instance.new("UICorner", circle).CornerRadius = UDim.new(1, 0)

local cStroke = Instance.new("UIStroke")
cStroke.Color = THEME.Border
cStroke.Thickness = 1.5
cStroke.Parent = circle

-- PANEL
local panel = Instance.new("Frame")
panel.Size = UDim2.new(0, 260, 0, 360)
panel.Position = UDim2.new(0.5, -130, 0.5, -180)
panel.BackgroundColor3 = THEME.Panel
panel.BorderSizePixel = 0
panel.Visible = false
panel.ZIndex = 1000
panel.Parent = gui
Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 12)

local pStroke = Instance.new("UIStroke")
pStroke.Color = THEME.Border
pStroke.Thickness = 1
pStroke.Parent = panel

-- HEADER
local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 38)
header.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
header.BorderSizePixel = 0
header.Parent = panel
Instance.new("UICorner", header).CornerRadius = UDim.new(0, 12)

local hFix = Instance.new("Frame")
hFix.Size = UDim2.new(1, 0, 0, 12)
hFix.Position = UDim2.new(0, 0, 1, -12)
hFix.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
hFix.BorderSizePixel = 0
hFix.Parent = header

local logo = Instance.new("TextLabel")
logo.Size = UDim2.new(1, -40, 1, 0)
logo.Position = UDim2.new(0, 14, 0, 0)
logo.BackgroundTransparency = 1
logo.Text = "CELZZ NIGHT"
logo.TextColor3 = THEME.Text
logo.TextSize = 13
logo.Font = Enum.Font.GothamBlack
logo.TextXAlignment = Enum.TextXAlignment.Left
logo.Parent = header

local minBtn = Instance.new("TextButton")
minBtn.Size = UDim2.new(0, 24, 0, 24)
minBtn.Position = UDim2.new(1, -32, 0.5, -12)
minBtn.BackgroundColor3 = THEME.Card
minBtn.BorderSizePixel = 0
minBtn.Text = "−"
minBtn.TextColor3 = THEME.Text
minBtn.TextSize = 16
minBtn.Font = Enum.Font.GothamBold
minBtn.AutoButtonColor = false
minBtn.Parent = header
Instance.new("UICorner", minBtn).CornerRadius = UDim.new(1, 0)

-- CONTENT
local content = Instance.new("ScrollingFrame")
content.Size = UDim2.new(1, -16, 1, -48)
content.Position = UDim2.new(0, 8, 0, 42)
content.BackgroundTransparency = 1
content.BorderSizePixel = 0
content.ScrollBarThickness = 2
content.ScrollBarImageColor3 = THEME.TextMuted
content.CanvasSize = UDim2.new(0, 0, 0, 800)
content.Parent = panel

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 6)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Parent = content

-- STATUS
local statusFrame = Instance.new("Frame")
statusFrame.Size = UDim2.new(1, -4, 0, 48)
statusFrame.BackgroundColor3 = THEME.Card
statusFrame.BorderSizePixel = 0
statusFrame.Parent = content
Instance.new("UICorner", statusFrame).CornerRadius = UDim.new(0, 6)

local statusLbl = Instance.new("TextLabel")
statusLbl.Size = UDim2.new(1, -12, 1, 0)
statusLbl.Position = UDim2.new(0, 8, 0, 0)
statusLbl.BackgroundTransparency = 1
statusLbl.Text = "● Idle"
statusLbl.TextColor3 = THEME.TextDim
statusLbl.TextSize = 10
statusLbl.Font = Enum.Font.GothamMedium
statusLbl.TextXAlignment = Enum.TextXAlignment.Left
statusLbl.TextWrapped = true
statusLbl.Parent = statusFrame

local function updateStatus(txt, color)
    statusLbl.Text = "● " .. txt
    statusLbl.TextColor3 = color or THEME.TextDim
end

-- TOGGLE
local function makeToggle(name, default, callback)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, -4, 0, 40)
    row.BackgroundColor3 = THEME.Card
    row.BorderSizePixel = 0
    row.Parent = content
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 8)

    local rStroke = Instance.new("UIStroke")
    rStroke.Color = THEME.Border
    rStroke.Thickness = 1
    rStroke.Parent = row

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -90, 1, 0)
    lbl.Position = UDim2.new(0, 12, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = name
    lbl.TextColor3 = THEME.Text
    lbl.TextSize = 11
    lbl.Font = Enum.Font.GothamBold
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = row

    local stateLbl = Instance.new("TextLabel")
    stateLbl.Size = UDim2.new(0, 26, 1, 0)
    stateLbl.Position = UDim2.new(1, -78, 0, 0)
    stateLbl.BackgroundTransparency = 1
    stateLbl.Text = default and "ON" or "OFF"
    stateLbl.TextColor3 = default and THEME.Accent or THEME.TextMuted
    stateLbl.TextSize = 9
    stateLbl.Font = Enum.Font.GothamBold
    stateLbl.Parent = row

    local tgBg = Instance.new("Frame")
    tgBg.Size = UDim2.new(0, 34, 0, 18)
    tgBg.Position = UDim2.new(1, -46, 0.5, -9)
    tgBg.BackgroundColor3 = default and THEME.Accent or Color3.fromRGB(40, 40, 40)
    tgBg.BorderSizePixel = 0
    tgBg.Parent = row
    Instance.new("UICorner", tgBg).CornerRadius = UDim.new(1, 0)

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 12, 0, 12)
    knob.Position = default and UDim2.new(1, -14, 0.5, -6) or UDim2.new(0, 3, 0.5, -6)
    knob.BackgroundColor3 = default and THEME.Bg or THEME.TextDim
    knob.BorderSizePixel = 0
    knob.Parent = tgBg
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

    local click = Instance.new("TextButton")
    click.Size = UDim2.new(1, 0, 1, 0)
    click.BackgroundTransparency = 1
    click.Text = ""
    click.Parent = row

    local state = default
    click.MouseButton1Click:Connect(function()
        state = not state
        TweenService:Create(tgBg, TweenInfo.new(0.2), {
            BackgroundColor3 = state and THEME.Accent or Color3.fromRGB(40, 40, 40)
        }):Play()
        TweenService:Create(knob, TweenInfo.new(0.2), {
            Position = state and UDim2.new(1, -14, 0.5, -6) or UDim2.new(0, 3, 0.5, -6),
            BackgroundColor3 = state and THEME.Bg or THEME.TextDim
        }):Play()
        stateLbl.Text = state and "ON" or "OFF"
        stateLbl.TextColor3 = state and THEME.Accent or THEME.TextMuted
        if callback then callback(state) end
    end)
end

makeToggle("Auto Steal", CONFIG.AutoSteal, function(v)
    CONFIG.AutoSteal = v
    updateStatus(v and "Auto Steal ON" or "Auto Steal OFF", v and THEME.Text or THEME.TextDim)
end)

makeToggle("Night Pause", CONFIG.NightPause, function(v) CONFIG.NightPause = v end)
makeToggle("Idle When No Egg", CONFIG.IdleWhenNoEgg, function(v) CONFIG.IdleWhenNoEgg = v end)
makeToggle("Anti Detect (10 Layer)", true, function(v)
    CONFIG.Layer1_RandomDelay = v
    CONFIG.Layer2_RandomBreak = v
    CONFIG.Layer3_SessionLimit = v
    CONFIG.Layer4_AntiReport = v
    CONFIG.Layer5_RandomMovement = v
    CONFIG.Layer6_AntiAFK = v
    CONFIG.Layer7_StealthMode = v
    CONFIG.Layer8_WalkNatural = v
    CONFIG.Layer9_RemoteThrottle = v
    CONFIG.Layer10_HumanBehavior = v
end)

-- INFO
local infoLbl = Instance.new("TextLabel")
infoLbl.Size = UDim2.new(1, -4, 0, 44)
infoLbl.BackgroundColor3 = THEME.Card
infoLbl.BackgroundTransparency = 0.5
infoLbl.BorderSizePixel = 0
infoLbl.Text = "  Priority: Divine → Secret → Eternal → Lunar\n  Night: Pause | Day: Auto | No Egg: Idle"
infoLbl.TextColor3 = THEME.TextMuted
infoLbl.TextSize = 9
infoLbl.Font = Enum.Font.Gotham
infoLbl.TextXAlignment = Enum.TextXAlignment.Left
infoLbl.TextYAlignment = Enum.TextYAlignment.Center
infoLbl.Parent = content
Instance.new("UICorner", infoLbl).CornerRadius = UDim.new(0, 6)

-- STATS
local statsBox = Instance.new("Frame")
statsBox.Size = UDim2.new(1, -4, 0, 110)
statsBox.BackgroundColor3 = THEME.Card
statsBox.BorderSizePixel = 0
statsBox.Parent = content
Instance.new("UICorner", statsBox).CornerRadius = UDim.new(0, 6)

local statsTitle = Instance.new("TextLabel")
statsTitle.Size = UDim2.new(1, -12, 0, 16)
statsTitle.Position = UDim2.new(0, 8, 0, 4)
statsTitle.BackgroundTransparency = 1
statsTitle.Text = "STATISTIK"
statsTitle.TextColor3 = THEME.TextMuted
statsTitle.TextSize = 9
statsTitle.Font = Enum.Font.GothamBold
statsTitle.TextXAlignment = Enum.TextXAlignment.Left
statsTitle.Parent = statsBox

local eggsLbl = Instance.new("TextLabel")
eggsLbl.Size = UDim2.new(0.5, -12, 0, 14)
eggsLbl.Position = UDim2.new(0, 8, 0, 22)
eggsLbl.BackgroundTransparency = 1
eggsLbl.Text = "🥚 Eggs: 0"
eggsLbl.TextColor3 = THEME.Text
eggsLbl.TextSize = 10
eggsLbl.Font = Enum.Font.GothamMedium
eggsLbl.TextXAlignment = Enum.TextXAlignment.Left
eggsLbl.Parent = statsBox

local breaksLbl = Instance.new("TextLabel")
breaksLbl.Size = UDim2.new(0.5, -12, 0, 14)
breaksLbl.Position = UDim2.new(0.5, 8, 0, 22)
breaksLbl.BackgroundTransparency = 1
breaksLbl.Text = "☕ Breaks: 0"
breaksLbl.TextColor3 = THEME.Text
breaksLbl.TextSize = 10
breaksLbl.Font = Enum.Font.GothamMedium
breaksLbl.TextXAlignment = Enum.TextXAlignment.Left
breaksLbl.Parent = statsBox

local detectLbl = Instance.new("TextLabel")
detectLbl.Size = UDim2.new(0.5, -12, 0, 14)
detectLbl.Position = UDim2.new(0, 8, 0, 38)
detectLbl.BackgroundTransparency = 1
detectLbl.Text = "🚨 Detects: 0"
detectLbl.TextColor3 = THEME.Text
detectLbl.TextSize = 10
detectLbl.Font = Enum.Font.GothamMedium
detectLbl.TextXAlignment = Enum.TextXAlignment.Left
detectLbl.Parent = statsBox

local sessionLbl = Instance.new("TextLabel")
sessionLbl.Size = UDim2.new(0.5, -12, 0, 14)
sessionLbl.Position = UDim2.new(0.5, 8, 0, 38)
sessionLbl.BackgroundTransparency = 1
sessionLbl.Text = "⏱ Session: 0s"
sessionLbl.TextColor3 = THEME.Text
sessionLbl.TextSize = 10
sessionLbl.Font = Enum.Font.GothamMedium
sessionLbl.TextXAlignment = Enum.TextXAlignment.Left
sessionLbl.Parent = statsBox

local remotesLbl = Instance.new("TextLabel")
remotesLbl.Size = UDim2.new(1, -12, 0, 14)
remotesLbl.Position = UDim2.new(0, 8, 0, 54)
remotesLbl.BackgroundTransparency = 1
remotesLbl.Text = "📡 Remotes: 0 / 20 per menit"
remotesLbl.TextColor3 = THEME.Text
remotesLbl.TextSize = 10
remotesLbl.Font = Enum.Font.GothamMedium
remotesLbl.TextXAlignment = Enum.TextXAlignment.Left
remotesLbl.Parent = statsBox

local modeLbl = Instance.new("TextLabel")
modeLbl.Size = UDim2.new(1, -12, 0, 14)
modeLbl.Position = UDim2.new(0, 8, 0, 70)
modeLbl.BackgroundTransparency = 1
modeLbl.Text = "🌍 Mode: ..."
modeLbl.TextColor3 = THEME.Text
modeLbl.TextSize = 10
modeLbl.Font = Enum.Font.GothamMedium
modeLbl.TextXAlignment = Enum.TextXAlignment.Left
modeLbl.Parent = statsBox

local sourceLbl = Instance.new("TextLabel")
sourceLbl.Size = UDim2.new(1, -12, 0, 14)
sourceLbl.Position = UDim2.new(0, 8, 0, 86)
sourceLbl.BackgroundTransparency = 1
sourceLbl.Text = "🔍 Source: ..."
sourceLbl.TextColor3 = THEME.TextMuted
sourceLbl.TextSize = 9
sourceLbl.Font = Enum.Font.Gotham
sourceLbl.TextXAlignment = Enum.TextXAlignment.Left
sourceLbl.Parent = statsBox

-- ═══════════════════════════════════════════════════════════════
--  NIGHT DETECTION (AUTO)
-- ═══════════════════════════════════════════════════════════════

-- Cek berbagai kemungkinan sistem malam
local function detectNightSystem()
    -- 1. Cek ClockTime
    local ct = Lighting.ClockTime
    if ct < 6 or ct >= 18 then
        return "night", "ClockTime"
    end

    -- 2. Cek Attribute di Workspace
    local ok, attr = pcall(function()
        return workspace:GetAttribute("IsNight")
            or workspace:GetAttribute("Night")
            or workspace:GetAttribute("IsDay")
    end)
    if ok and attr ~= nil then
        if attr == true or attr == "Night" or attr == "night" then
            return "night", "Workspace.Attribute"
        end
    end

    -- 3. Cek Attribute di Lighting
    local ok2, attr2 = pcall(function()
        return Lighting:GetAttribute("IsNight") or Lighting:GetAttribute("Night")
    end)
    if ok2 and attr2 ~= nil then
        if attr2 == true or attr2 == "Night" then
            return "night", "Lighting.Attribute"
        end
    end

    -- 4. Cek Attribute di ReplicatedStorage
    local ok3, attr3 = pcall(function()
        return ReplicatedStorage:GetAttribute("IsNight")
            or ReplicatedStorage:GetAttribute("Night")
    end)
    if ok3 and attr3 ~= nil then
        if attr3 == true or attr3 == "Night" then
            return "night", "ReplicatedStorage.Attribute"
        end
    end

    -- 5. Cek value di ReplicatedStorage
    for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
        if obj:IsA("BoolValue") then
            local n = obj.Name:lower()
            if n == "isnight" or n == "night" or n == "is_night" then
                if obj.Value == true then
                    return "night", "ReplicatedStorage." .. obj.Name
                end
            end
            if n == "isday" or n == "day" then
                if obj.Value == false then
                    return "night", "ReplicatedStorage." .. obj.Name
                end
            end
        end
        if obj:IsA("StringValue") then
            local n = obj.Name:lower()
            local v = tostring(obj.Value):lower()
            if n:find("time") or n:find("phase") or n:find("cycle") then
                if v == "night" or v == "malam" then
                    return "night", "ReplicatedStorage." .. obj.Name
                end
            end
        end
    end

    -- 6. Cek value di Workspace
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BoolValue") then
            local n = obj.Name:lower()
            if n == "isnight" or n == "night" then
                if obj.Value == true then
                    return "night", "Workspace." .. obj.Name
                end
            end
            if n == "isday" or n == "day" then
                if obj.Value == false then
                    return "night", "Workspace." .. obj.Name
                end
            end
        end
    end

    -- 7. Cek attribute di Players.LocalPlayer
    local ok4, attr4 = pcall(function()
        return LocalPlayer:GetAttribute("IsNight") or LocalPlayer:GetAttribute("Night")
    end)
    if ok4 and attr4 ~= nil then
        if attr4 == true or attr4 == "Night" then
            return "night", "Player.Attribute"
        end
    end

    return "day", "None"
end

-- ═══════════════════════════════════════════════════════════════
--  CORE LOGIC
-- ═══════════════════════════════════════════════════════════════

local function isNight()
    local mode, source = detectNightSystem()
    NIGHT_MODE = mode
    NIGHT_SOURCE = source
    return mode == "night"
end

local function getEggRarity(egg)
    local name = egg.Name:lower()
    local attr = ""
    pcall(function()
        attr = (egg:GetAttribute("Rarity") or egg:GetAttribute("Type") or egg:GetAttribute("Tier") or ""):lower()
    end)
    for key, rarity in pairs(HIGH_PRIORITY_EGGS) do
        if name:find(key, 1, true) then return rarity end
    end
    for _, rarity in ipairs(RARITY_ORDER) do
        if attr:find(rarity) then return rarity end
    end
    for _, rarity in ipairs(RARITY_ORDER) do
        if name:find(rarity) then return rarity end
    end
    return "normal"
end

local function getEggPrice(egg)
    local price = 0
    pcall(function()
        price = tonumber(egg:GetAttribute("Price")) or tonumber(egg:GetAttribute("Value"))
            or tonumber(egg:GetAttribute("Worth")) or tonumber(egg:GetAttribute("Cost")) or 0
    end)
    return price
end

local function getRarityPriority(rarity)
    for i, r in ipairs(RARITY_ORDER) do
        if r == rarity then return i end
    end
    return 99
end

local function isSelectedRarity(rarity)
    for _, r in ipairs(CONFIG.SelectedRarities) do
        if r == rarity then return true end
    end
    return false
end

local function scanAllEggs()
    local eggs = {}
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local myPos = hrp and hrp.Position or Vector3.new(0, 0, 0)

    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") or obj:IsA("Model") then
            local name = obj.Name:lower()
            if name:find("egg") then
                local ok, pos = pcall(function()
                    return obj.Position or obj:GetPivot().Position
                end)
                if ok and pos then
                    local dist = (pos - myPos).Magnitude
                    if dist <= CONFIG.MaxDistance then
                        table.insert(eggs, {
                            obj = obj, name = obj.Name,
                            rarity = getEggRarity(obj),
                            price = getEggPrice(obj),
                            dist = dist, pos = pos,
                        })
                    end
                end
            end
        end
    end

    table.sort(eggs, function(a, b)
        local pa = getRarityPriority(a.rarity)
        local pb = getRarityPriority(b.rarity)
        if pa ~= pb then return pa < pb end
        if a.price ~= b.price then return a.price > b.price end
        return a.dist < b.dist
    end)

    return eggs
end

local function findRemotes()
    local remotes = {}
    for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
            local n = obj.Name:lower()
            if n:find("steal") or n:find("egg") or n:find("collect")
            or n:find("grab") or n:find("pick") then
                table.insert(remotes, obj)
            end
        end
    end
    return remotes
end

local function walkTo(targetPos, timeout)
    local char = LocalPlayer.Character
    if not char then return false end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then return false end

    timeout = timeout or 15
    local startTime = tick()
    hum:MoveTo(targetPos)

    while tick() - startTime < timeout do
        if not RUNNING or not CONFIG.AutoSteal then return false end
        local dist = (hrp.Position - targetPos).Magnitude
        if dist < 6 then
            hum:MoveTo(hrp.Position)
            return true
        end
        hum:MoveTo(targetPos)
        task.wait(0.1)
    end
    return false
end

local function stealEgg(eggData)
    if not eggData or not eggData.obj then return false end
    local egg = eggData.obj
    local remotes = findRemotes()

    if CONFIG.Layer8_WalkNatural then
        local pos
        pcall(function() pos = egg.Position or egg:GetPivot().Position end)
        if pos then
            walkTo(pos, 15)
        end
    end

    if CONFIG.Layer9_RemoteThrottle then
        if REMOTE_COUNTER >= CONFIG.MaxRemotesPerMinute then return false end
    end

    if CONFIG.Layer1_RandomDelay then
        task.wait(CONFIG.MinDelay + math.random() * (CONFIG.MaxDelay - CONFIG.MinDelay))
    end

    for _, r in ipairs(remotes) do
        pcall(function()
            if r:IsA("RemoteEvent") then
                r:FireServer(egg)
            elseif r:IsA("RemoteFunction") then
                r:InvokeServer(egg)
            end
        end)
        REMOTE_COUNTER = REMOTE_COUNTER + 1
        STATS.remotesFired = STATS.remotesFired + 1
        if CONFIG.Layer9_RemoteThrottle then
            task.wait(CONFIG.RemoteCooldown + math.random() * 0.5)
        end
    end

    STATS.eggsStolen = STATS.eggsStolen + 1
    return true
end

local function playerNearby(range)
    local char = LocalPlayer.Character
    if not char then return false, nil end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return false, nil end
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local phrp = p.Character:FindFirstChild("HumanoidRootPart")
            if phrp and (phrp.Position - hrp.Position).Magnitude < range then
                return true, p
            end
        end
    end
    return false, nil
end

-- ═══════════════════════════════════════════════════════════════
--  ANTI-DETECT LAYERS
-- ═══════════════════════════════════════════════════════════════

task.spawn(function()
    while RUNNING and gui.Parent do
        task.wait(2)
        if not CONFIG.Layer4_AntiReport then continue end
        local near, who = playerNearby(CONFIG.AntiReportRange)
        if near then
            if not DETECTED then
                DETECTED = true
                STATS.detectPauses = STATS.detectPauses + 1
                updateStatus("⚠ Player: " .. (who and who.Name or "?"), THEME.TextDim)
            end
            task.wait(3)
        else
            DETECTED = false
        end
    end
end)

task.spawn(function()
    while RUNNING and gui.Parent do
        task.wait(1)
        if not CONFIG.Layer2_RandomBreak then continue end
        if (tick() - LAST_BREAK) > CONFIG.BreakInterval then
            STATS.breaks = STATS.breaks + 1
            LAST_BREAK = tick()
            local wasAuto = CONFIG.AutoSteal
            CONFIG.AutoSteal = false
            updateStatus("☕ Break " .. CONFIG.BreakDuration .. "s", THEME.TextMuted)
            task.wait(CONFIG.BreakDuration)
            CONFIG.AutoSteal = wasAuto
        end
    end
end)

task.spawn(function()
    while RUNNING and gui.Parent do
        task.wait(5)
        if not CONFIG.Layer3_SessionLimit then continue end
        if (tick() - START_TIME) > CONFIG.SessionLimit then
            STATS.sessionRests = STATS.sessionRests + 1
            local wasAuto = CONFIG.AutoSteal
            CONFIG.AutoSteal = false
            updateStatus("💤 Session rest " .. CONFIG.SessionRest .. "s", THEME.TextMuted)
            task.wait(CONFIG.SessionRest)
            CONFIG.AutoSteal = wasAuto
            START_TIME = tick()
        end
    end
end)

task.spawn(function()
    while RUNNING and gui.Parent do
        task.wait(15 + math.random() * 15)
        if not CONFIG.Layer5_RandomMovement or not CONFIG.AutoSteal then continue end
        local char = LocalPlayer.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hum and hrp then
                hum:MoveTo(hrp.Position + Vector3.new(math.random(-3,3), 0, math.random(-3,3)))
            end
        end
    end
end)

if CONFIG.Layer6_AntiAFK then
    LocalPlayer.Idled:Connect(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end)
end

task.spawn(function()
    while RUNNING and gui.Parent do
        task.wait(2)
        if not CONFIG.Layer7_StealthMode then continue end
        local near = playerNearby(CONFIG.StealthRange)
        if near then
            circle.Visible = false
            panel.Visible = false
        else
            if not circle.Visible and not panel.Visible then
                circle.Visible = true
            end
        end
    end
end)

task.spawn(function()
    while RUNNING and gui.Parent do
        task.wait(60)
        REMOTE_COUNTER = 0
    end
end)

task.spawn(function()
    while RUNNING and gui.Parent do
        task.wait(math.random(20, 60))
        if not CONFIG.Layer10_HumanBehavior or not CONFIG.AutoSteal then continue end
        task.wait(math.random(1, 3))
    end
end)

-- ═══════════════════════════════════════════════════════════════
--  MAIN LOOP
-- ═══════════════════════════════════════════════════════════════

task.spawn(function()
    while RUNNING and gui.Parent do
        task.wait(1)

        if not CONFIG.AutoSteal then
            updateStatus("Idle - Toggle ON", THEME.TextMuted)
            continue
        end

        -- NIGHT CHECK
        if CONFIG.NightPause and isNight() then
            updateStatus("🌙 Night - Sleeping", THEME.TextMuted)
            task.wait(5)
            continue
        end

        pcall(function()
            if DETECTED then
                task.wait(2)
                return
            end

            local eggs = scanAllEggs()
            local targetEggs = {}
            for _, egg in ipairs(eggs) do
                if isSelectedRarity(egg.rarity) then
                    table.insert(targetEggs, egg)
                end
            end

            if #targetEggs == 0 then
                if CONFIG.IdleWhenNoEgg then
                    updateStatus("No target egg - Idle", THEME.TextMuted)
                    task.wait(5)
                    return
                elseif #eggs > 0 then
                    targetEggs = {eggs[1]}
                else
                    updateStatus("No egg found", THEME.TextMuted)
                    task.wait(5)
                    return
                end
            end

            local best = targetEggs[1]
            updateStatus("🎯 " .. best.rarity:upper() .. " ($" .. best.price .. ")", THEME.Text)
            stealEgg(best)
            task.wait(CONFIG.EggCooldown + math.random() * 1.0)
        end)
    end
end)

-- ═══════════════════════════════════════════════════════════════
--  STATS UPDATER
-- ═══════════════════════════════════════════════════════════════

task.spawn(function()
    while RUNNING and gui.Parent do
        task.wait(1)
        local elapsed = math.floor(tick() - START_TIME)
        eggsLbl.Text = "🥚 Eggs: " .. STATS.eggsStolen
        breaksLbl.Text = "☕ Breaks: " .. STATS.breaks
        detectLbl.Text = "🚨 Detects: " .. STATS.detectPauses
        sessionLbl.Text = "⏱ Session: " .. elapsed .. "s"
        remotesLbl.Text = "📡 Remotes: " .. REMOTE_COUNTER .. " / " .. CONFIG.MaxRemotesPerMinute
        modeLbl.Text = "🌍 Mode: " .. (NIGHT_MODE == "night" and "🌙 Night" or "☀️ Day")
        sourceLbl.Text = "🔍 Source: " .. (NIGHT_SOURCE or "...")
    end
end)

-- ═══════════════════════════════════════════════════════════════
--  UI LOGIC
-- ═══════════════════════════════════════════════════════════════

local dragging, dragStart, startPos, hasDragged = false, nil, nil, false

circle.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        hasDragged = false
        dragStart = input.Position
        startPos = circle.Position
    end
end)

circle.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
    or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        if math.abs(delta.X) > 5 or math.abs(delta.Y) > 5 then
            hasDragged = true
        end
        circle.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end
end)

circle.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

circle.MouseButton1Click:Connect(function()
    if not hasDragged then
        panel.Visible = not panel.Visible
        if panel.Visible then
            panel.Position = UDim2.new(0.5, -130, 0.5, -180)
        end
    end
end)

minBtn.MouseButton1Click:Connect(function()
    panel.Visible = false
end)

circle.MouseEnter:Connect(function()
    TweenService:Create(circle, TweenInfo.new(0.2), { BackgroundColor3 = Color3.fromRGB(30, 30, 30) }):Play()
    TweenService:Create(cStroke, TweenInfo.new(0.2), { Color = THEME.Text }):Play()
end)
circle.MouseLeave:Connect(function()
    TweenService:Create(circle, TweenInfo.new(0.2), { BackgroundColor3 = THEME.Bg }):Play()
    TweenService:Create(cStroke, TweenInfo.new(0.2), { Color = THEME.Border }):Play()
end)

minBtn.MouseEnter:Connect(function()
    TweenService:Create(minBtn, TweenInfo.new(0.15), { BackgroundColor3 = Color3.fromRGB(40, 40, 40) }):Play()
end)
minBtn.MouseLeave:Connect(function()
    TweenService:Create(minBtn, TweenInfo.new(0.15), { BackgroundColor3 = THEME.Card }):Play()
end)

print("[CELZZ NIGHT] Loaded | Auto Night Detect | Tuan ENDXZ 😹")