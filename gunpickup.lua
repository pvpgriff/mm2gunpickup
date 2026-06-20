--[[
    SIMPLIFIED MM2 GUN PICKUP SCRIPT - WORKS WITH ANY EXECUTOR
]]

-- Get player
local Players = game:GetService("Players")
local Player = Players.LocalPlayer

-- Wait for everything to load
repeat task.wait() until Player and Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
repeat task.wait() until Player.PlayerGui

print("✅ Player loaded! Creating GUI...")

-- Variables
local autoPickup = false
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "GunPickupGUI"
ScreenGui.Parent = Player.PlayerGui
ScreenGui.ResetOnSpawn = false

print("✅ GUI created!")

-- Main Frame
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 220, 0, 120)
MainFrame.Position = UDim2.new(0.5, -110, 0.5, -60)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

-- Corner
local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 8)
Corner.Parent = MainFrame

-- Title
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -40, 0, 30)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "🔫 Gun Pickup"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 16
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Font = Enum.Font.SourceSansBold
Title.Parent = MainFrame

-- Close Button
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -30, 0, 0)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CloseBtn.BorderSizePixel = 0
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.TextSize = 16
CloseBtn.Font = Enum.Font.SourceSansBold
CloseBtn.Parent = MainFrame

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 4)
CloseCorner.Parent = CloseBtn

-- Auto Pickup Button
local AutoBtn = Instance.new("TextButton")
AutoBtn.Size = UDim2.new(0, 200, 0, 30)
AutoBtn.Position = UDim2.new(0.5, -100, 0, 40)
AutoBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
AutoBtn.BorderSizePixel = 0
AutoBtn.Text = "Auto Pickup: OFF"
AutoBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
AutoBtn.TextSize = 14
AutoBtn.Font = Enum.Font.SourceSansSemibold
AutoBtn.Parent = MainFrame

local AutoCorner = Instance.new("UICorner")
AutoCorner.CornerRadius = UDim.new(0, 4)
AutoCorner.Parent = AutoBtn

-- Pickup Button
local PickupBtn = Instance.new("TextButton")
PickupBtn.Size = UDim2.new(0, 200, 0, 30)
PickupBtn.Position = UDim2.new(0.5, -100, 0, 75)
PickupBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
PickupBtn.BorderSizePixel = 0
PickupBtn.Text = "Pickup Gun"
PickupBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
PickupBtn.TextSize = 14
PickupBtn.Font = Enum.Font.SourceSansSemibold
PickupBtn.Parent = MainFrame

local PickupCorner = Instance.new("UICorner")
PickupCorner.CornerRadius = UDim.new(0, 4)
PickupCorner.Parent = PickupBtn

print("✅ GUI elements created!")

-- ==================== GUN FINDING ====================
local function findGun()
    for _, child in pairs(workspace:GetChildren()) do
        if child:IsA("Model") and child.Name == "Gun" then
            local part = child.PrimaryPart or child:FindFirstChildWhichIsA("BasePart")
            if part then return child, part end
        end
    end
    return nil, nil
end

-- ==================== PICKUP FUNCTION ====================
local function pickupGun()
    print("🔍 Looking for gun...")
    local gun, part = findGun()
    
    if not gun then
        print("❌ No gun found!")
        return
    end
    
    print("✅ Gun found! Teleporting...")
    
    local char = Player.Character
    if not char then return end
    
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    
    -- Save position
    local originalPos = root.Position
    
    -- Teleport to gun
    root.CFrame = CFrame.new(part.Position + Vector3.new(0, 2, 0))
    task.wait(0.1)
    
    -- Touch gun
    root.CFrame = CFrame.new(part.Position)
    task.wait(0.1)
    
    -- Teleport back
    root.CFrame = CFrame.new(originalPos)
    
    print("✅ Gun pickup attempted!")
end

-- ==================== BUTTON FUNCTIONS ====================
CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
    print("✅ GUI closed")
end)

PickupBtn.MouseButton1Click:Connect(function()
    pickupGun()
end)

AutoBtn.MouseButton1Click:Connect(function()
    autoPickup = not autoPickup
    AutoBtn.Text = "Auto Pickup: " .. (autoPickup and "ON" or "OFF")
    AutoBtn.BackgroundColor3 = autoPickup and Color3.fromRGB(50, 150, 50) or Color3.fromRGB(50, 50, 60)
    print("🔄 Auto pickup:", autoPickup and "ON" or "OFF")
end)

-- ==================== AUTO PICKUP LOOP ====================
game:GetService("RunService").Heartbeat:Connect(function()
    if autoPickup then
        local gun, _ = findGun()
        if gun then
            pickupGun()
            task.wait(1) -- Prevent spam
        end
    end
end)

print("✅ MM2 Gun Pickup Script Loaded!")
print("🎯 Click 'Pickup Gun' to grab the gun")
print("🔄 Toggle 'Auto Pickup' for automatic grabbing")
