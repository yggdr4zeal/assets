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

-- Fitur Drag Tombol Floating (Bisa Dipindah ke Mana Saja)
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

local hudVisible = true

toggleBtn.MouseButton1Click:Connect(function()
    hudVisible = not hudVisible
    mainContent.Visible = hudVisible
    blackCover.Visible = hudVisible
    
    pcall(function()
        RunService:Set3dRenderingEnabled(not hudVisible)
    end)
    
    toggleBtn.ImageTransparency = hudVisible and 0 or 0.35
    btnStroke.Color = hudVisible and Color3.fromRGB(0, 200, 255) or Color3.fromRGB(150, 150, 150)
end)

-- (D) Header Simetris ZEALIST
local headerFrame = Instance.new("Frame")
headerFrame.Name = "HeaderFrame"
headerFrame.AnchorPoint = Vector2.new(0.5, 0)
headerFrame.Size = UDim2.new(0, 660, 0, 50)
headerFrame.Position = UDim2.new(0.5, 0, 0, 65)
headerFrame.BackgroundTransparency = 1
headerFrame.ZIndex = 3
headerFrame.Parent = mainContent

local titleLabel = Instance.new("TextLabel")
titleLabel.Name = "TitleZEALIST"
titleLabel.AnchorPoint = Vector2.new(0.5, 0.5)
titleLabel.Size = UDim2.new(0, 280, 1, 0)
titleLabel.Position = UDim2.new(0.5, 0, 0.5, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "ZEALIST"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.Font = Enum.Font.FredokaOne
titleLabel.TextSize = 42
titleLabel.ZIndex = 4
titleLabel.Parent = headerFrame

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
statsLabel.TextSize = 12
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
    card.Size = UDim2.new(1, 0, 0, 80)
    card.Position = UDim2.new(0, 0, 0, 0)
    card.BackgroundColor3 = Color3.fromRGB(25, 28, 38)
    card.BorderSizePixel = 0
    card.ZIndex = 6
    card.Parent = slotContainer

    local cardCorner = Instance.new("UICorner")
    cardCorner.CornerRadius = UDim.new(0, 8)
    cardCorner.Parent = card

    local cardStroke = Instance.new("UIStroke")
    cardStroke.Color = Color3.fromRGB(50, 60, 80)
    cardStroke.Thickness = 1.5
    cardStroke.Parent = card

    local cardGradient = Instance.new("UIGradient")
    cardGradient.Enabled = false
    cardGradient.Parent = card

    local vpClone = nil
    local lastVpRef = nil

    local imgLabel = Instance.new("ImageLabel")
    imgLabel.Name = "PetImage"
    imgLabel.Size = UDim2.new(0.85, 0, 0.85, 0)
    imgLabel.AnchorPoint = Vector2.new(0.5, 0.5)
    imgLabel.Position = UDim2.new(0.5, 0, 0.5, 0)
    imgLabel.BackgroundTransparency = 1
    imgLabel.ScaleType = Enum.ScaleType.Fit
    imgLabel.ZIndex = 7
    imgLabel.Visible = false
    imgLabel.Parent = card

    local countPill = Instance.new("TextLabel")
    countPill.Name = "CountPill"
    countPill.Size = UDim2.new(0, 28, 0, 14)
    countPill.Position = UDim2.new(1, -30, 0, 2)
    countPill.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    countPill.BackgroundTransparency = 0.4
    countPill.TextColor3 = Color3.fromRGB(255, 255, 255)
    countPill.Font = Enum.Font.GothamBold
    countPill.TextSize = 9
    countPill.ZIndex = 8
    countPill.Visible = false
    countPill.Parent = card

    local countCorner = Instance.new("UICorner")
    countCorner.CornerRadius = UDim.new(0, 4)
    countCorner.Parent = countPill

    local multLabel = Instance.new("TextLabel")
    multLabel.Name = "Multiplier"
    multLabel.Size = UDim2.new(1, 0, 0, 16)
    multLabel.Position = UDim2.new(0, 0, 0, 84)
    multLabel.BackgroundTransparency = 1
    multLabel.TextColor3 = Color3.fromRGB(255, 220, 50)
    multLabel.Font = Enum.Font.GothamBold
    multLabel.TextSize = 11
    multLabel.ZIndex = 6
    multLabel.Text = "x..."
    multLabel.Parent = slotContainer

    local oddsLabel = Instance.new("TextLabel")
    oddsLabel.Name = "Odds"
    oddsLabel.Size = UDim2.new(1, 0, 0, 14)
    oddsLabel.Position = UDim2.new(0, 0, 0, 102)
    oddsLabel.BackgroundTransparency = 1
    oddsLabel.TextColor3 = Color3.fromRGB(180, 190, 210)
    oddsLabel.Font = Enum.Font.Gotham
    oddsLabel.TextSize = 9
    oddsLabel.ZIndex = 6
    oddsLabel.Text = "1 in ..."
    oddsLabel.Parent = slotContainer

    petSlots[i] = {
        container = slotContainer,
        card = card,
        cardStroke = cardStroke,
        cardGradient = cardGradient,
        clonedVp = vpClone,
        lastVpRef = lastVpRef,
        imgLabel = imgLabel,
        countPill = countPill,
        multLabel = multLabel,
        oddsLabel = oddsLabel
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
--          10. SCANNER DATA GAME YANG CRASH-PROOF & INSTAN
-- ====================================================================

local function parseNumber(str)
    if not str then return 0 end
    str = string.gsub(str, "[,%s]", "")
    local mult = 1
    if string.find(str, "[Kk]") then mult = 1e3; str = string.gsub(str, "[Kk]", "") end
    if string.find(str, "[Mm]") then mult = 1e6; str = string.gsub(str, "[Mm]", "") end
    if string.find(str, "[Bb]") then mult = 1e9; str = string.gsub(str, "[Bb]", "") end
    if string.find(str, "[Tt]") then mult = 1e12; str = string.gsub(str, "[Tt]", "") end
    if string.find(str, "[Qq]") then mult = 1e15; str = string.gsub(str, "[Qq]", "") end
    local val = tonumber(str)
    return (val and (val * mult)) or 0
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
        return Color3.fromRGB(40, 10, 50), Color3.fromRGB(255, 0, 128), ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 128)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(180, 0, 255)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 200, 255))
        }, 45
    elseif num >= 1e6 then
        return Color3.fromRGB(20, 35, 60), Color3.fromRGB(0, 220, 255), ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 180, 255)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(150, 0, 255))
        }, 45
    elseif num >= 1e4 then
        return Color3.fromRGB(50, 42, 10), Color3.fromRGB(255, 215, 0), ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 215, 0)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 140, 0))
        }, 45
    elseif num >= 200 then
        return Color3.fromRGB(45, 28, 8), Color3.fromRGB(255, 150, 20), ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 160, 30)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(200, 70, 0))
        }, 45
    elseif num >= 50 then
        return Color3.fromRGB(35, 15, 45), Color3.fromRGB(180, 70, 255), ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.fromRGB(170, 50, 255)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(100, 20, 180))
        }, 45
    else
        return Color3.fromRGB(20, 35, 30), Color3.fromRGB(50, 200, 100), nil, 0
    end
end

local function scanAllGameDataSafe()
    local result = {
        islandName = "Memuat...",
        eggName = "Memuat...",
        w1Rebirths = "0",
        w2Rebirths = "0",
        eggsVal = "0",
        eggBox = {
            inventory = "0/0",
            eggsOpened = "0",
            hatchSpeed = "0/s",
            petsKept = "0",
            autoDeleted = "0",
            rarestOdds = "Belum Ada"
        },
        bestPets = {}
    }

    pcall(function()
        local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
        if not playerGui then return end

        local camera = workspace.CurrentCamera
        local screenW = camera and camera.ViewportSize.X or 1920
        local screenH = camera and camera.ViewportSize.Y or 1080

        local oddsFound = {}
        local allVisibleLabels = {}

        for _, desc in ipairs(playerGui:GetDescendants()) do
            if desc:IsA("GuiObject") and desc.Visible and desc.AbsoluteSize.X > 0 and desc.AbsoluteSize.Y > 0 then
                if desc:IsA("TextLabel") and desc.Text ~= "" then
                    local text = desc.Text
                    local low = string.lower(text)
                    local posX = desc.AbsolutePosition.X
                    local posY = desc.AbsolutePosition.Y

                    table.insert(allVisibleLabels, {obj = desc, text = text, low = low, x = posX, y = posY})

                    -- (1) Island Name
                    if string.find(low, "island") and not string.find(low, "mastery") and not string.find(low, "quest") and not string.find(low, "portal") and not string.find(low, "%d") then
                        if #text < 35 and result.islandName == "Memuat..." then
                            result.islandName = text
                        end
                    end

                    -- (2) Egg Name
                    if string.find(low, "%f[%a]egg%f[%A]") and not string.find(low, "eggs") and not string.find(low, "opened") and not string.find(low, "hatch") and not string.find(low, "mastery") and not string.find(low, "auto") then
                        local eggMatch = string.match(text, "^([%w%s]+%s+[Ee]gg)$")
                        if eggMatch and #eggMatch < 30 and result.eggName == "Memuat..." then
                            result.eggName = eggMatch
                        end
                    end

                    -- (3) Rebirths W1 vs W2 & Total Eggs
                    if posX < 260 and posY > (screenH * 0.45) and posY < (screenH * 0.95) then
                        local numVal = string.match(text, "^[%d,%.]+[KkMmBbTtQq]?$")
                        if numVal then
                            if posY < (screenH * 0.65) then
                                result.eggsVal = numVal
                            elseif posY < (screenH * 0.78) then
                                result.w1Rebirths = numVal
                            else
                                result.w2Rebirths = numVal
                            end
                        end
                    end

                    -- (4) Box Egg Hatching Stats
                    if string.find(low, "inventory") and string.find(text, "/") then
                        result.eggBox.inventory = text
                    elseif (string.find(low, "opened") or string.find(low, "hatched")) and string.find(text, "%d") then
                        result.eggBox.eggsOpened = text
                    elseif (string.find(low, "speed") or string.find(low, "/s")) and string.find(text, "%d") then
                        result.eggBox.hatchSpeed = text
                    elseif string.find(low, "kept") and string.find(text, "%d") then
                        result.eggBox.petsKept = text
                    elseif (string.find(low, "delete") or string.find(low, "deleted")) and string.find(text, "%d") then
                        result.eggBox.autoDeleted = text
                    elseif string.find(low, "rarest") and string.find(low, "1 in") then
                        result.eggBox.rarestOdds = text
                    end

                    -- (5) Odds Deteksi Rarity (1 in ...)
                    if string.find(low, "1 in ") and string.find(text, "%d") and #text <= 20 then
                        if not string.find(low, "power") and not string.find(low, "from eggs") and not string.find(low, "only") and not string.find(low, "when") then
                            table.insert(oddsFound, {label = desc, text = text, x = posX, y = posY})
                        end
                    end
                end
            end
        end

        -- Filter Odds Pet Egg Sidebar
        local xGroups = {}
        for _, item in ipairs(oddsFound) do
            local bucket = math.floor(item.x / 40) * 40
            xGroups[bucket] = (xGroups[bucket] or 0) + 1
        end

        local bestX = nil
        local maxCount = 0
        for bx, count in pairs(xGroups) do
            if count > maxCount then
                maxCount = count
                bestX = bx
            end
        end

        local finalOdds = {}
        for _, item in ipairs(oddsFound) do
            if not bestX or (item.x >= bestX - 40 and item.x <= bestX + 350) then
                table.insert(finalOdds, item)
            end
        end

        table.sort(finalOdds, function(a, b)
            return formatOddsNum(a.text) > formatOddsNum(b.text)
        end)

        -- Kumpulkan 3 Best Pet
        for idx = 1, math.min(3, #finalOdds) do
            local oData = finalOdds[idx]
            local oLabel = oData.label
            local multVal = ""
            local countVal = ""
            local vpVal = nil
            local imgVal = nil
            local detectedBg = nil
            local detectedStroke = nil
            local detectedGrad = nil
            local detectedRot = nil

            local cardContainer = oLabel.Parent
            if cardContainer and cardContainer:IsA("GuiObject") then
                for _, elem in ipairs(cardContainer:GetDescendants()) do
                    if elem:IsA("GuiObject") and elem.Visible then
                        local elemY = elem.AbsolutePosition.Y

                        if elem:IsA("Frame") or elem:IsA("ImageLabel") then
                            if elem.BackgroundColor3 and elem.BackgroundTransparency < 0.8 then
                                if elem.BackgroundColor3 ~= Color3.fromRGB(0,0,0) and elem.BackgroundColor3 ~= Color3.fromRGB(255,255,255) then
                                    detectedBg = elem.BackgroundColor3
                                end
                            end
                            local strk = elem:FindFirstChildOfClass("UIStroke")
                            if strk and strk.Enabled then
                                detectedStroke = strk.Color
                            end
                            local grad = elem:FindFirstChildOfClass("UIGradient")
                            if grad and grad.Enabled then
                                detectedGrad = grad.Color
                                detectedRot = grad.Rotation
                            end
                        end

                        if elem:IsA("TextLabel") and elem ~= oLabel and elem.Text ~= "" then
                            local t = elem.Text
                            local lowElem = string.lower(t)
                            if not string.find(lowElem, "power") and not string.find(lowElem, "only") and not string.find(lowElem, "exist") and not string.find(lowElem, "when") then
                                if string.find(t, "x") and string.find(t, "%d") then
                                    if elemY < (oLabel.AbsolutePosition.Y - 50) then
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

        local data = scanAllGameDataSafe()

        -- Update 3 Kartu Best Hatches
        for i = 1, 3 do
            local slotData = data.bestPets[i]
            local slotUI = petSlots[i]

            if slotData then
                slotUI.container.Visible = true
                slotUI.multLabel.Text = slotData.mult
                slotUI.oddsLabel.Text = slotData.odds

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
                            clone.Parent = slotUI.card
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

        -- Update Kolom Kiri
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

[EGG HATCHING STATS]
  • Inventory    : %s
  • Eggs Opened  : %s
  • Hatch Speed  : %s
  • Pets Kept    : %s
  • Auto-Deleted : %s
  • Rarest Odds  : %s
]], uptimeStr, fps, ping, memMb, data.islandName, data.eggName, data.w1Rebirths, data.w2Rebirths, data.eggsVal,
        data.eggBox.inventory, data.eggBox.eggsOpened, data.eggBox.hatchSpeed, data.eggBox.petsKept, data.eggBox.autoDeleted, data.eggBox.rarestOdds)
    end)
end

-- EKSEKUSI SEGERA PADA FRAME 0
task.spawn(function()
    updateHUD()
    while task.wait(0.5) do
        updateHUD()
    end
end)
