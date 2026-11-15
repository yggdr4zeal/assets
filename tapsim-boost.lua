-- ====================================================================
--                  ZEALIST - TAP SIMULATOR AFK & MONITOR
--        (UNIVERSAL: PC POTASSIUM + ANDROID DELTA EXECUTOR)
-- ====================================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local SoundService = game:GetService("SoundService")
local Stats = game:GetService("Stats")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- Pemuat Otomatis Gambar Icon Zealist 1 (Universal: PC Potassium & Android Delta)
local function getZealistIcon()
    local asset = "rbxassetid://0"
    pcall(function()
        local filename = "zealist_1.png"
        local url = "https://raw.githubusercontent.com/yggdr4zeal/assets/main/Zealist%201.jpg"

        -- Jika file belum ada di storage executor (seperti saat awal run di Delta Android)
        -- Script akan otomatis mendownload gambar via HttpGet dan menyimpannya via writefile
        if isfile and not isfile(filename) then
            if writefile and (game.HttpGet or HttpGet) then
                local fetch = game.HttpGet and function(u) return game:HttpGet(u) end or HttpGet
                local ok, imgData = pcall(function() return fetch(url) end)
                if ok and imgData and #imgData > 100 then
                    writefile(filename, imgData)
                end
            end
        end

        -- Ambil custom asset lokal
        local customAssetFn = getcustomasset or getsynasset
        if customAssetFn then
            if isfile and isfile(filename) then
                asset = customAssetFn(filename)
            elseif isfile and isfile("zealist_left.png") then
                asset = customAssetFn("zealist_left.png")
            else
                local ok, res = pcall(function() return customAssetFn(filename) end)
                if ok and res then asset = res end
            end
        end
    end)
    return asset
end

local TOGGLE_ICON = getZealistIcon()

-- 1. HARD ENGINE LOCK KE 15 FPS
local function lockFPS15()
    pcall(function()
        if setfpscap then setfpscap(15) end
        if set_fps_cap then set_fps_cap(15) end
    end)
end
lockFPS15()

-- PENGUKUR REAL RENDER FPS (Akurat & Bukan Physics Solver)
local realRenderFps = 15
local frameCount = 0
local lastFpsTime = os.clock()

RunService.RenderStepped:Connect(function()
    frameCount = frameCount + 1
    local now = os.clock()
    local delta = now - lastFpsTime
    if delta >= 0.5 then
        realRenderFps = math.floor((frameCount / delta) + 0.5)
        frameCount = 0
        lastFpsTime = now
    end
end)

-- 2. ENGINE GRAPHICS & QUALITY SETTINGS (Paling Ringan)
pcall(function()
    local renderingSettings = settings():GetService("Rendering")
    renderingSettings.QualityLevel = Enum.QualityLevel.Level01
    renderingSettings.MeshPartDetailLevel = Enum.MeshPartDetailLevel.DistanceLowest
    UserSettings():GetService("UserGameSettings").SavedQualityLevel = Enum.SavedQualitySetting.QualityLevel1
    settings().Physics.PhysicsEnvironmentalThrottle = Enum.EnviromentalPhysicsThrottle.DefaultAuto
    workspace.InterpolationThrottling = Enum.InterpolationThrottlingMode.Enabled
end)

-- 3. GLOBAL LIGHTING OPTIMIZATION
pcall(function()
    Lighting.GlobalShadows = false
    Lighting.FogEnd = 9e9
    Lighting.Brightness = 1
    for _, child in ipairs(Lighting:GetChildren()) do
        if child:IsA("PostProcessEffect") or child:IsA("Atmosphere") or child:IsA("Sky") or child:IsA("Clouds") then
            child.Enabled = false
        end
    end
end)

-- 4. MUTE AUDIO GAMEPLAY
pcall(function()
    SoundService.AmbientReverb = Enum.ReverbType.NoReverb
    for _, sound in ipairs(SoundService:GetDescendants()) do
        if sound:IsA("Sound") then
            sound.Volume = 0
            sound:Stop()
        end
    end
    SoundService.DescendantAdded:Connect(function(desc)
        if desc:IsA("Sound") then
            desc.Volume = 0
            desc:Stop()
        end
    end)
end)

-- 5. ANTI-AFK ENGINE DISCONNECT PREVENTION
pcall(function()
    LocalPlayer.Idled:Connect(function()
        local VirtualUser = game:GetService("VirtualUser")
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new(0, 0))
    end)
end)

-- 6. PEMBERSIH SAMPAH MEMORI (SAFE GARBAGE COLLECTION)
task.spawn(function()
    while task.wait(30) do
        lockFPS15()
        pcall(function()
            collectgarbage("collect")
        end)
    end
end)

-- ====================================================================
--            7. ANTARMUKA MONITOR ZEALIST (CLEAN & MINIMALIST)
-- ====================================================================

local CoreGui = game:GetService("CoreGui")
local parentGui = CoreGui
if not pcall(function() local _ = parentGui.Name end) then
    parentGui = LocalPlayer:WaitForChild("PlayerGui")
end

-- Bersihkan instance lama jika ada
for _, oldGui in ipairs(parentGui:GetChildren()) do
    if oldGui.Name == "ZealistMonitorGui" then
        oldGui:Destroy()
    end
end

local hudGui = Instance.new("ScreenGui")
hudGui.Name = "ZealistMonitorGui"
hudGui.ResetOnSpawn = false
hudGui.IgnoreGuiInset = true
hudGui.DisplayOrder = 999999
hudGui.Parent = parentGui

-- (A) Layar Hitam Penghemat GPU / Layar Mati
local blackCover = Instance.new("Frame")
blackCover.Name = "BlackScreenCover"
blackCover.Size = UDim2.new(1, 0, 1, 0)
blackCover.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
blackCover.BorderSizePixel = 0
blackCover.ZIndex = 1
blackCover.Parent = hudGui

pcall(function()
    RunService:Set3dRenderingEnabled(false)
end)

-- (B) Tombol Floating Bulat Toggle Show / Hide (Avatar Zealist 1)
local toggleBtn = Instance.new("ImageButton")
toggleBtn.Name = "ToggleHUDButton"
toggleBtn.AnchorPoint = Vector2.new(0.5, 0)
toggleBtn.Size = UDim2.new(0, 50, 0, 50)
toggleBtn.Position = UDim2.new(0.5, 0, 0, 10)
toggleBtn.BackgroundColor3 = Color3.fromRGB(15, 20, 28)
toggleBtn.Image = TOGGLE_ICON
toggleBtn.ScaleType = Enum.ScaleType.Fit
toggleBtn.ZIndex = 50
toggleBtn.Parent = hudGui

local btnCorner = Instance.new("UICorner")
btnCorner.CornerRadius = UDim.new(1, 0)
btnCorner.Parent = toggleBtn

local btnStroke = Instance.new("UIStroke")
btnStroke.Color = Color3.fromRGB(0, 200, 255)
btnStroke.Thickness = 2.5
btnStroke.Parent = toggleBtn

if TOGGLE_ICON == "rbxassetid://0" or TOGGLE_ICON == "" then
    local fallbackLabel = Instance.new("TextLabel")
    fallbackLabel.Size = UDim2.new(1, 0, 1, 0)
    fallbackLabel.BackgroundTransparency = 1
    fallbackLabel.Text = "Z"
    fallbackLabel.TextColor3 = Color3.fromRGB(0, 220, 255)
    fallbackLabel.Font = Enum.Font.GothamBold
    fallbackLabel.TextSize = 22
    fallbackLabel.ZIndex = 51
    fallbackLabel.Parent = toggleBtn
end

-- Fitur Drag Tombol Floating
local dragging = false
local dragStart = nil
local startPos = nil

toggleBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = toggleBtn.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        toggleBtn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- (C) Konten Utama HUD
local mainContent = Instance.new("Frame")
mainContent.Name = "MainContent"
mainContent.Size = UDim2.new(1, 0, 1, 0)
mainContent.BackgroundTransparency = 1
mainContent.ZIndex = 2
mainContent.Parent = hudGui

local isHudVisible = true

local function setHudState(visible)
    isHudVisible = visible
    mainContent.Visible = visible
    blackCover.Visible = visible

    pcall(function()
        RunService:Set3dRenderingEnabled(not visible)
    end)

    if visible then
        btnStroke.Color = Color3.fromRGB(0, 200, 255)
    else
        btnStroke.Color = Color3.fromRGB(255, 200, 50)
    end
end

toggleBtn.MouseButton1Click:Connect(function()
    setHudState(not isHudVisible)
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.H then
        setHudState(not isHudVisible)
    end
end)

-- (D) Header Tengah
local header = Instance.new("Frame")
header.Name = "HeaderCenter"
header.AnchorPoint = Vector2.new(0.5, 0)
header.Size = UDim2.new(0, 400, 0, 55)
header.Position = UDim2.new(0.5, 0, 0, 65)
header.BackgroundTransparency = 1
header.ZIndex = 3
header.Parent = mainContent

local titleLabel = Instance.new("TextLabel")
titleLabel.Name = "ZealistTitle"
titleLabel.AnchorPoint = Vector2.new(0.5, 0.5)
titleLabel.Size = UDim2.new(1, 0, 1, 0)
titleLabel.Position = UDim2.new(0.5, 0, 0.5, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "ZEALIST"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.Font = Enum.Font.FredokaOne
titleLabel.TextSize = 44
titleLabel.ZIndex = 3
titleLabel.Parent = header

local titleStroke = Instance.new("UIStroke")
titleStroke.Color = Color3.fromRGB(0, 170, 255)
titleStroke.Thickness = 2.5
titleStroke.Parent = titleLabel

-- (E) Panel Monitor Realtime
local monitorFrame = Instance.new("Frame")
monitorFrame.Name = "ProcessMonitor"
monitorFrame.AnchorPoint = Vector2.new(0.5, 0)
monitorFrame.Size = UDim2.new(0, 660, 0, 375)
monitorFrame.Position = UDim2.new(0.5, 0, 0, 125)
monitorFrame.BackgroundColor3 = Color3.fromRGB(13, 16, 22)
monitorFrame.BackgroundTransparency = 0.15
monitorFrame.BorderSizePixel = 0
monitorFrame.ZIndex = 3
monitorFrame.Parent = mainContent

local frameCorner = Instance.new("UICorner")
frameCorner.CornerRadius = UDim.new(0, 12)
frameCorner.Parent = monitorFrame

local frameStroke = Instance.new("UIStroke")
frameStroke.Color = Color3.fromRGB(0, 170, 255)
frameStroke.Thickness = 1.5
frameStroke.Parent = monitorFrame

local monitorTitle = Instance.new("TextLabel")
monitorTitle.Size = UDim2.new(1, 0, 0, 28)
monitorTitle.Position = UDim2.new(0, 0, 0, 4)
monitorTitle.BackgroundTransparency = 1
monitorTitle.Text = "⚡ REALTIME GAME MONITOR ⚡"
monitorTitle.TextColor3 = Color3.fromRGB(0, 220, 255)
monitorTitle.Font = Enum.Font.GothamBold
monitorTitle.TextSize = 13
monitorTitle.ZIndex = 4
monitorTitle.Parent = monitorFrame

-- Area Kolom Kiri
local statsLabel = Instance.new("TextLabel")
statsLabel.Size = UDim2.new(0, 360, 1, -40)
statsLabel.Position = UDim2.new(0, 16, 0, 36)
statsLabel.BackgroundTransparency = 1
statsLabel.TextColor3 = Color3.fromRGB(240, 240, 240)
statsLabel.Font = Enum.Font.Code
statsLabel.TextSize = 13
statsLabel.TextXAlignment = Enum.TextXAlignment.Left
statsLabel.TextYAlignment = Enum.TextYAlignment.Top
statsLabel.ZIndex = 4
statsLabel.Text = "Menghubungkan ke game..."
statsLabel.Parent = monitorFrame

-- ====================================================================
--            8. KARTU BEST HATCHES (3 SLOT BERJEJER)
-- ====================================================================

local bestHatchesBox = Instance.new("Frame")
bestHatchesBox.Name = "BestHatchesBox"
bestHatchesBox.Size = UDim2.new(0, 264, 0, 165)
bestHatchesBox.Position = UDim2.new(1, -276, 0, 38)
bestHatchesBox.BackgroundColor3 = Color3.fromRGB(20, 24, 35)
bestHatchesBox.BackgroundTransparency = 0.3
bestHatchesBox.ZIndex = 4
bestHatchesBox.Parent = monitorFrame

local bestBoxCorner = Instance.new("UICorner")
bestBoxCorner.CornerRadius = UDim.new(0, 8)
bestBoxCorner.Parent = bestHatchesBox

local bestBoxStroke = Instance.new("UIStroke")
bestBoxStroke.Color = Color3.fromRGB(255, 170, 0)
bestBoxStroke.Thickness = 1.5
bestBoxStroke.Parent = bestHatchesBox

local bestBoxTitle = Instance.new("TextLabel")
bestBoxTitle.Size = UDim2.new(1, 0, 0, 22)
bestBoxTitle.Position = UDim2.new(0, 0, 0, 2)
bestBoxTitle.BackgroundTransparency = 1
bestBoxTitle.Text = "⭐ BEST HATCHES ⭐"
bestBoxTitle.TextColor3 = Color3.fromRGB(255, 180, 20)
bestBoxTitle.Font = Enum.Font.GothamBold
bestBoxTitle.TextSize = 11
bestBoxTitle.ZIndex = 5
bestBoxTitle.Parent = bestHatchesBox

local petSlots = {}

for i = 1, 3 do
    local slotContainer = Instance.new("Frame")
    slotContainer.Name = "Slot_" .. i
    slotContainer.Size = UDim2.new(0, 80, 0, 130)
    slotContainer.Position = UDim2.new(0, 8 + (i - 1) * 86, 0, 26)
    slotContainer.BackgroundTransparency = 1
    slotContainer.ZIndex = 5
    slotContainer.Visible = false
    slotContainer.Parent = bestHatchesBox

    local card = Instance.new("Frame")
    card.Name = "Card"
    card.Size = UDim2.new(0, 80, 0, 80)
    card.BackgroundColor3 = (i == 1 and Color3.fromRGB(250, 195, 45)) or (i == 2 and Color3.fromRGB(235, 165, 25)) or Color3.fromRGB(80, 25, 105)
    card.ClipsDescendants = true
    card.ZIndex = 5
    card.Parent = slotContainer

    local cardCorner = Instance.new("UICorner")
    cardCorner.CornerRadius = UDim.new(0, 10)
    cardCorner.Parent = card

    local cardStroke = Instance.new("UIStroke")
    cardStroke.Color = (i == 1 and Color3.fromRGB(255, 165, 0)) or (i == 2 and Color3.fromRGB(245, 140, 10)) or Color3.fromRGB(165, 75, 220)
    cardStroke.Thickness = 2
    cardStroke.Parent = card

    local cardGradient = Instance.new("UIGradient")
    cardGradient.Name = "CardGradient"
    cardGradient.Enabled = false
    cardGradient.Parent = card

    local visualHolder = Instance.new("Frame")
    visualHolder.Name = "VisualHolder"
    visualHolder.Size = UDim2.new(1, 0, 1, 0)
    visualHolder.BackgroundTransparency = 1
    visualHolder.ZIndex = 6
    visualHolder.Parent = card

    local imgLabel = Instance.new("ImageLabel")
    imgLabel.Name = "PetImage"
    imgLabel.Size = UDim2.new(0.85, 0, 0.85, 0)
    imgLabel.Position = UDim2.new(0.075, 0, 0.05, 0)
    imgLabel.BackgroundTransparency = 1
    imgLabel.ScaleType = Enum.ScaleType.Fit
    imgLabel.ZIndex = 7
    imgLabel.Parent = visualHolder

    local countPill = Instance.new("TextLabel")
    countPill.Name = "CountPill"
    countPill.Size = UDim2.new(0, 32, 0, 16)
    countPill.Position = UDim2.new(0, 3, 0, 3)
    countPill.BackgroundColor3 = Color3.fromRGB(15, 18, 26)
    countPill.BackgroundTransparency = 0.2
    countPill.Text = ""
    countPill.TextColor3 = Color3.fromRGB(255, 255, 255)
    countPill.Font = Enum.Font.GothamBold
    countPill.TextSize = 10
    countPill.Visible = false
    countPill.ZIndex = 9
    countPill.Parent = card

    local pillCorner = Instance.new("UICorner")
    pillCorner.CornerRadius = UDim.new(0, 4)
    pillCorner.Parent = countPill

    local multLabel = Instance.new("TextLabel")
    multLabel.Name = "MultLabel"
    multLabel.Size = UDim2.new(1, 0, 0, 18)
    multLabel.Position = UDim2.new(0, 0, 0, 84)
    multLabel.BackgroundTransparency = 1
    multLabel.Text = "x..."
    multLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    multLabel.Font = Enum.Font.GothamBold
    multLabel.TextSize = 12
    multLabel.ZIndex = 6
    multLabel.Parent = slotContainer

    local oddsLabel = Instance.new("TextLabel")
    oddsLabel.Name = "OddsLabel"
    oddsLabel.Size = UDim2.new(1, 0, 0, 16)
    oddsLabel.Position = UDim2.new(0, 0, 0, 104)
    oddsLabel.BackgroundTransparency = 1
    oddsLabel.Text = "1 in ..."
    oddsLabel.TextColor3 = Color3.fromRGB(255, 220, 100)
    oddsLabel.Font = Enum.Font.GothamBold
    oddsLabel.TextSize = 10
    oddsLabel.ZIndex = 6
    oddsLabel.Parent = slotContainer

    petSlots[i] = {
        container = slotContainer,
        card = card,
        cardStroke = cardStroke,
        cardGradient = cardGradient,
        visualHolder = visualHolder,
        imgLabel = imgLabel,
        countPill = countPill,
        multLabel = multLabel,
        oddsLabel = oddsLabel,
        clonedVp = nil,
        lastVpRef = nil
    }
end

-- ====================================================================
--            9. KOTAK ACTIVE LUCK BOOSTS
-- ====================================================================

local activeBoostBox = Instance.new("Frame")
activeBoostBox.Name = "ActiveBoostBox"
activeBoostBox.Size = UDim2.new(0, 264, 0, 150)
activeBoostBox.Position = UDim2.new(1, -276, 0, 212)
activeBoostBox.BackgroundColor3 = Color3.fromRGB(20, 24, 35)
activeBoostBox.BackgroundTransparency = 0.3
activeBoostBox.ZIndex = 4
activeBoostBox.Parent = monitorFrame

local boostCorner = Instance.new("UICorner")
boostCorner.CornerRadius = UDim.new(0, 8)
boostCorner.Parent = activeBoostBox

local boostStroke = Instance.new("UIStroke")
boostStroke.Color = Color3.fromRGB(0, 220, 130)
boostStroke.Thickness = 1.5
boostStroke.Parent = activeBoostBox

local boostTitle = Instance.new("TextLabel")
boostTitle.Size = UDim2.new(1, 0, 0, 22)
boostTitle.Position = UDim2.new(0, 0, 0, 2)
boostTitle.BackgroundTransparency = 1
boostTitle.Text = "🍀 ACTIVE LUCK BOOSTS 🍀"
boostTitle.TextColor3 = Color3.fromRGB(0, 255, 150)
boostTitle.Font = Enum.Font.GothamBold
boostTitle.TextSize = 11
boostTitle.ZIndex = 5
boostTitle.Parent = activeBoostBox

local boostLabel = Instance.new("TextLabel")
boostLabel.Size = UDim2.new(1, -16, 1, -28)
boostLabel.Position = UDim2.new(0, 8, 0, 24)
boostLabel.BackgroundTransparency = 1
boostLabel.TextColor3 = Color3.fromRGB(220, 240, 230)
boostLabel.Font = Enum.Font.Code
boostLabel.TextSize = 10
boostLabel.TextXAlignment = Enum.TextXAlignment.Left
boostLabel.TextYAlignment = Enum.TextYAlignment.Top
boostLabel.ZIndex = 5
boostLabel.Text = "Mendeteksi boosts aktif..."
boostLabel.Parent = activeBoostBox

-- ====================================================================
--          10. SCANNER DATA GAME YANG CRASH-PROOF & AKURAT
-- ====================================================================

local function formatCompact(num)
    if type(num) ~= "number" then return tostring(num or "0") end
    if num >= 1e15 then return string.format("%.2fQ", num / 1e15) end
    if num >= 1e12 then return string.format("%.2fT", num / 1e12) end
    if num >= 1e9  then return string.format("%.2fB", num / 1e9) end
    if num >= 1e6  then return string.format("%.2fM", num / 1e6) end
    if num >= 1e3  then return string.format("%.2fK", num / 1e3) end
    return tostring(math.floor(num))
end

local function formatOddsNum(str)
    local num = tonumber(string.match(str, "%d+"))
    if not num then return 0 end
    local low = string.lower(str)
    if string.find(low, "b") then return num * 1e9 end
    if string.find(low, "m") then return num * 1e6 end
    if string.find(low, "k") then return num * 1e3 end
    return num
end

local function getRarityColors(oddsText)
    local num = formatOddsNum(oddsText)
    if num >= 1e9 then
        local seq = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 30, 110)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(140, 20, 240))
        })
        return Color3.fromRGB(180, 25, 140), Color3.fromRGB(255, 80, 180), seq, 45
    elseif num >= 1e6 then
        local seq = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(230, 50, 50)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(150, 20, 20))
        })
        return Color3.fromRGB(190, 30, 30), Color3.fromRGB(255, 80, 80), seq, 90
    elseif num >= 1e4 then
        local seq = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 210, 40)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(220, 130, 10))
        })
        return Color3.fromRGB(250, 195, 45), Color3.fromRGB(255, 165, 0), seq, 90
    elseif num >= 200 then
        local seq = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(245, 180, 35)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(200, 100, 10))
        })
        return Color3.fromRGB(235, 165, 25), Color3.fromRGB(245, 140, 10), seq, 90
    elseif num >= 50 then
        local seq = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(175, 80, 235)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(75, 20, 100))
        })
        return Color3.fromRGB(130, 45, 175), Color3.fromRGB(165, 75, 220), seq, 90
    elseif num >= 10 then
        local seq = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(45, 120, 235)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(25, 75, 175))
        })
        return Color3.fromRGB(35, 95, 210), Color3.fromRGB(60, 155, 255), seq, 90
    else
        local seq = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(55, 175, 85)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(35, 125, 60))
        })
        return Color3.fromRGB(45, 150, 75), Color3.fromRGB(80, 210, 110), seq, 90
    end
end

local lastKnownW2 = "0"
local lastKnownEgg = "Crimson Egg"
local lastKnownIsland = "Crimson Island (World 2)"

local function scanAllGameDataSafe()
    local result = {
        eggName = lastKnownEgg,
        islandName = lastKnownIsland,
        w1Rebirths = "0",
        w2Rebirths = (lastKnownW2 ~= "0") and lastKnownW2 or "0",
        eggsVal = "0",
        bestPets = {}
    }

    -- 1. Baca Leaderstats (W1 Rebirths & Eggs)
    pcall(function()
        local leaderstats = LocalPlayer:FindFirstChild("leaderstats")
        if leaderstats then
            for _, s in ipairs(leaderstats:GetChildren()) do
                local name = string.lower(s.Name)
                if string.find(name, "rebirth") then
                    result.w1Rebirths = formatCompact(s.Value)
                elseif string.find(name, "egg") then
                    result.eggsVal = formatCompact(s.Value)
                end
            end
        end
    end)

    -- 2. Baca Floor / Island dari Attributes
    pcall(function()
        local floorId = LocalPlayer:GetAttribute("TeleportArrivalId")
        if floorId == 21 or floorId == "21" then
            result.islandName = "Rift Island (World 2)"
        elseif floorId then
            result.islandName = "Floor " .. tostring(floorId) .. " (World 2)"
        end
    end)

    -- 3. Scan PlayerGui Secara Aman Tanpa Kemungkinan Crash
    pcall(function()
        local pGui = LocalPlayer:FindFirstChild("PlayerGui")
        if not pGui then return end

        local cam = workspace.CurrentCamera
        local screenH = (cam and cam.ViewportSize.Y) or 600

        local bestLbl = nil
        local lastLbl = nil
        local potentialSlotElements = {}

        for _, desc in ipairs(pGui:GetDescendants()) do
            if desc:IsA("GuiObject") and desc.Visible then
                local pX = 0
                local pY = 0
                local okPos = pcall(function()
                    pX = desc.AbsolutePosition.X
                    pY = desc.AbsolutePosition.Y
                end)

                if okPos then
                    if desc:IsA("TextLabel") and desc.Text ~= "" then
                        local text = desc.Text
                        local low = string.lower(text)

                        -- (A) DETEKSI REBIRTHS W2 DI HUD KIRI BAWAH
                        if pX < 260 and pY > (screenH * 0.45) and pY < (screenH * 0.95) then
                            if string.find(low, "rebirth") and string.find(text, "%d") then
                                local num = text:match("[%d%.,]+%s*[A-Za-z]*")
                                if num and not string.find(string.lower(num), "rebirth") and #num >= 2 then
                                    result.w2Rebirths = num:gsub("%s+", "")
                                    lastKnownW2 = result.w2Rebirths
                                end
                            elseif low == "rebirths" or low == "rebirth" then
                                local parent = desc.Parent
                                if parent then
                                    for _, sib in ipairs(parent:GetChildren()) do
                                        if sib:IsA("TextLabel") and sib ~= desc and sib.Visible and sib.Text ~= "" then
                                            if string.find(sib.Text, "%d") and not string.find(string.lower(sib.Text), "rebirth") then
                                                result.w2Rebirths = sib.Text:gsub("%s+", "")
                                                lastKnownW2 = result.w2Rebirths
                                                break
                                            end
                                        end
                                    end
                                end
                            elseif (string.find(string.lower(desc.Name), "rebirth") or (desc.Parent and string.find(string.lower(desc.Parent.Name), "rebirth"))) and string.find(text, "%d") then
                                if not string.find(low, "price") and not string.find(low, "cost") and not string.find(low, "req") then
                                    local num = text:match("[%d%.,]+%s*[A-Za-z]*")
                                    if num and not string.find(string.lower(num), "rebirth") and #num >= 2 then
                                        result.w2Rebirths = num:gsub("%s+", "")
                                        lastKnownW2 = result.w2Rebirths
                                    end
                                end
                            end
                        end

                        -- (B) DETEKSI EGG NAME & ISLAND SECARA AKURAT
                        local matchedEgg = text:match("^([%w%s]+%s+[Ee]gg)$")
                        if matchedEgg then
                            local lowEgg = string.lower(matchedEgg)
                            if not string.find(lowEgg, "auto") and not string.find(lowEgg, "speed") and not string.find(lowEgg, "opened") and not string.find(lowEgg, "price") and not string.find(lowEgg, "total") and not string.find(lowEgg, "hatch") then
                                local islandPart = matchedEgg:gsub("%s+[Ee]gg$", ""):gsub("^%s*(.-)%s*$", "%1")
                                if #islandPart >= 2 and islandPart ~= "Egg" and islandPart ~= "Eggs" then
                                    result.eggName = matchedEgg
                                    lastKnownEgg = matchedEgg
                                    result.islandName = islandPart .. " Island (World 2)"
                                    lastKnownIsland = result.islandName
                                end
                            end
                        end

                        -- (C) DETEKSI HEADER BEST HATCHES & LAST HATCHES
                        if string.find(low, "best") and string.find(low, "hatch") then
                            bestLbl = desc
                        elseif string.find(low, "last") and string.find(low, "hatch") then
                            lastLbl = desc
                        end
                    end

                    -- Kumpulkan elemen kartu pet
                    if desc:IsA("TextLabel") or desc:IsA("ViewportFrame") or desc:IsA("ImageLabel") or desc:IsA("Frame") then
                        table.insert(potentialSlotElements, desc)
                    end
                end
            end
        end

        -- PROSES 3 KARTU BEST HATCHES BERDASARKAN GEOMETRI & ANCESTORS
        local oddsLabels = {}
        if bestLbl then
            local yStart = bestLbl.AbsolutePosition.Y
            local yEnd = lastLbl and lastLbl.AbsolutePosition.Y or (yStart + 260)
            local bestX = bestLbl.AbsolutePosition.X

            for _, elem in ipairs(potentialSlotElements) do
                if elem:IsA("TextLabel") then
                    local t = elem.Text
                    local lowT = string.lower(t)
                    if string.find(lowT, "1 in") and not string.find(lowT, "power") and not string.find(lowT, "egg") and not string.find(lowT, "only") and not string.find(lowT, "exist") and #t <= 20 then
                        local posY = elem.AbsolutePosition.Y
                        local posX = elem.AbsolutePosition.X
                        if posY > yStart and posY < yEnd and posX >= (bestX - 40) and posX <= (bestX + 350) then
                            table.insert(oddsLabels, elem)
                        end
                    end
                end
            end

            table.sort(oddsLabels, function(a, b)
                local ax, bx = 0, 0
                pcall(function() ax = a.AbsolutePosition.X end)
                pcall(function() bx = b.AbsolutePosition.X end)
                return ax < bx
            end)
        else
            for _, elem in ipairs(potentialSlotElements) do
                if elem:IsA("TextLabel") then
                    local t = elem.Text
                    local lowT = string.lower(t)
                    if string.find(lowT, "1 in") and string.find(t, "%d") and not string.find(lowT, "power") and not string.find(lowT, "egg") and not string.find(lowT, "only") and not string.find(lowT, "exist") and #t <= 20 then
                        table.insert(oddsLabels, elem)
                    end
                end
            end
            table.sort(oddsLabels, function(a, b)
                return formatOddsNum(a.Text) > formatOddsNum(b.Text)
            end)
        end

        for i = 1, math.min(#oddsLabels, 3) do
            local oLabel = oddsLabels[i]
            local slotCenterX = oLabel.AbsolutePosition.X + (oLabel.AbsoluteSize.X / 2)
            local colRadius = math.max(45, oLabel.AbsoluteSize.X / 2 + 15)

            local multVal = ""
            local countVal = ""
            local vpVal = nil
            local imgVal = nil
            local detectedBg = nil
            local detectedStroke = nil
            local detectedGrad = nil
            local detectedRot = 45

            for _, elem in ipairs(potentialSlotElements) do
                local elemX = elem.AbsolutePosition.X + (elem.AbsoluteSize.X / 2)
                local elemY = elem.AbsolutePosition.Y
                local distY = math.abs(elemY - oLabel.AbsolutePosition.Y)

                if math.abs(elemX - slotCenterX) <= colRadius and distY <= 150 then
                    if (elem:IsA("Frame") or elem:IsA("ImageLabel")) and elem.AbsoluteSize.X >= 40 and elem.AbsoluteSize.Y >= 40 then
                        if elem.BackgroundTransparency < 0.8 then
                            local c = elem.BackgroundColor3
                            if (c.R + c.G + c.B) > 0.35 then
                                detectedBg = c
                                local s = elem:FindFirstChildOfClass("UIStroke")
                                if s then detectedStroke = s.Color end
                                local g = elem:FindFirstChildOfClass("UIGradient")
                                if g then
                                    detectedGrad = g.Color
                                    detectedRot = g.Rotation
                                end
                            end
                        end
                    end

                    if elem:IsA("TextLabel") and elem ~= oLabel and elem.Text ~= "" then
                        local t = elem.Text
                        local lowElem = string.lower(t)
                        if not string.find(lowElem, "power") and not string.find(lowElem, "only") and not string.find(lowElem, "exist") and not string.find(lowElem, "when") then
                            if string.find(t, "x") and string.find(t, "%d") then
                                if elemY < (oLabel.AbsolutePosition.Y - 45) then
                                    countVal = t
                                else
                                    multVal = t
                                end
                            end
                        end
                    elseif elem:IsA("ViewportFrame") and not vpVal then
                        vpVal = elem
                    elseif elem:IsA("ImageLabel") and elem.Image ~= "" and not vpVal and not imgVal then
                        local n = string.lower(elem.Name)
                        if not string.find(n, "bg") and not string.find(n, "border") and not string.find(n, "slot") and not string.find(n, "clover") and not string.find(n, "shadow") and not string.find(elem.Image, "rbxasset://textures") then
                            imgVal = elem.Image
                        end
                    end
                end
            end

            if not vpVal or multVal == "" then
                local p = oLabel.Parent
                local depth = 0
                while p and depth < 3 do
                    for _, child in ipairs(p:GetChildren()) do
                        if child:IsA("ViewportFrame") and not vpVal then
                            vpVal = child
                        elseif child:IsA("ImageLabel") and child.Image ~= "" and not vpVal and not imgVal then
                            local n = string.lower(child.Name)
                            if not string.find(n, "bg") and not string.find(n, "border") and not string.find(child.Image, "rbxasset://textures") then
                                imgVal = child.Image
                            end
                        elseif child:IsA("TextLabel") and child ~= oLabel and child.Text ~= "" and multVal == "" then
                            if string.find(child.Text, "x") and string.find(child.Text, "%d") then
                                multVal = child.Text
                            end
                        end
                    end
                    p = p.Parent
                    depth = depth + 1
                end
            end

            local fallbackBg, fallbackStroke, fallbackGrad, fallbackRot = getRarityColors(oLabel.Text)
            local finalBg = detectedBg or fallbackBg
            local finalStroke = detectedStroke or fallbackStroke
            local finalGrad = detectedGrad or fallbackGrad
            local finalRot = detectedRot or fallbackRot

            table.insert(result.bestPets, {
                odds = oLabel.Text,
                mult = (multVal ~= "") and multVal or "x...",
                count = countVal,
                vp = vpVal,
                img = imgVal,
                cardBg = finalBg,
                cardStroke = finalStroke,
                cardGrad = finalGrad,
                cardRot = finalRot
            })
        end
    end)

    return result
end

-- ====================================================================
--            PEMBARUAN REALTIME & INSTAN PADA FRAME PERTAMA
-- ====================================================================

local startTime = os.time()

local function updateHUD()
    pcall(function()
        local elapsed = os.time() - startTime
        local hrs = math.floor(elapsed / 3600)
        local mins = math.floor((elapsed % 3600) / 60)
        local secs = elapsed % 60
        local uptimeStr = string.format("%02d:%02d:%02d", hrs, mins, secs)

        lockFPS15()
        local fps = math.max(1, realRenderFps)
        local ping = 0
        pcall(function()
            ping = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())
        end)
        local memMb = math.floor(Stats:GetTotalMemoryUsageMb())

        -- Ambil data game secara crash-proof
        local data = scanAllGameDataSafe()

        -- Update 3 Kartu Best Hatches
        for i = 1, 3 do
            local slotData = data.bestPets[i]
            local slotUI = petSlots[i]

            if slotData then
                slotUI.container.Visible = true
                slotUI.multLabel.Text = slotData.mult
                slotUI.oddsLabel.Text = slotData.odds

                -- Update Warna Rarity Background, Border, dan Gradient persis di Game
                if slotData.cardBg then
                    slotUI.card.BackgroundColor3 = slotData.cardBg
                end
                if slotData.cardStroke then
                    slotUI.cardStroke.Color = slotData.cardStroke
                end
                if slotData.cardGrad then
                    slotUI.cardGradient.Color = slotData.cardGrad
                    slotUI.cardGradient.Rotation = slotData.cardRot or 45
                    slotUI.cardGradient.Enabled = true
                else
                    slotUI.cardGradient.Enabled = false
                end

                if slotData.count ~= "" then
                    slotUI.countPill.Text = slotData.count
                    slotUI.countPill.Visible = true
                else
                    slotUI.countPill.Visible = false
                end

                if slotData.vp then
                    if slotUI.lastVpRef ~= slotData.vp then
                        slotUI.lastVpRef = slotData.vp
                        if slotUI.clonedVp then pcall(function() slotUI.clonedVp:Destroy() end) end
                        pcall(function()
                            local clone = slotData.vp:Clone()
                            clone.Size = UDim2.new(1, 0, 1, 0)
                            clone.Position = UDim2.new(0, 0, 0, 0)
                            clone.BackgroundTransparency = 1
                            clone.ZIndex = 7
                            local cam = clone:FindFirstChildOfClass("Camera") or slotData.vp.CurrentCamera
                            if cam then
                                clone.CurrentCamera = cam
                            end
                            clone.Parent = slotUI.visualHolder
                            slotUI.clonedVp = clone
                            slotUI.imgLabel.Visible = false
                        end)
                    end
                elseif slotData.img then
                    if slotUI.clonedVp then
                        pcall(function() slotUI.clonedVp:Destroy() end)
                        slotUI.clonedVp = nil
                        slotUI.lastVpRef = nil
                    end
                    slotUI.imgLabel.Visible = true
                    slotUI.imgLabel.Image = slotData.img
                end
            else
                slotUI.multLabel.Text = "Belum Ada"
                slotUI.oddsLabel.Text = "..."
                slotUI.countPill.Visible = false
                slotUI.card.BackgroundColor3 = Color3.fromRGB(25, 28, 38)
                slotUI.cardStroke.Color = Color3.fromRGB(50, 60, 80)
                slotUI.cardGradient.Enabled = false
            end
        end

        -- Update Active Luck Boosts
        local luckList = {}
        pcall(function()
            for attrName, attrVal in pairs(LocalPlayer:GetAttributes()) do
                local low = string.lower(attrName)
                local num = tonumber(attrVal)
                if num and num > 0 and string.find(low, "luck") then
                    table.insert(luckList, string.format("• %-13s: x%s", attrName:gsub("Totem", "T."):gsub("Clan", "C."), tostring(num)))
                end
            end
        end)
        boostLabel.Text = (#luckList > 0) and table.concat(luckList, "\n") or "Tidak ada boost luck aktif"

        -- Update Kolom Kiri (Bersih & Rapi)
        statsLabel.Text = string.format([[
[STATUS SISTEM]
  • Uptime Sesi  : %s
  • FPS Engine   : %d FPS  |  Ping: %d ms
  • Memori RAM   : %d MB

[GAMEPLAY UTAMA]
  • Lokasi       : %s
  • Hatching Egg : %s
  • Rebirths W1  : %s
  • Rebirths W2  : %s
  • Total Eggs   : %s
]], uptimeStr, fps, ping, memMb, data.islandName, data.eggName, data.w1Rebirths, data.w2Rebirths, data.eggsVal)
    end)
end

-- EKSEKUSI SEGERA PADA FRAME 0 (Langsung Muncul dalam 0.01 Detik!)
task.spawn(function()
    updateHUD()
    while task.wait(0.5) do
        updateHUD()
    end
end)
