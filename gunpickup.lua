--[[
    MM2 GUN PICKUP - FULLY DRAGGABLE VERSION
    Features: Draggable GUI, Auto Pickup, Manual Pickup, Toast Notifications
    1 SINGLE FULL SCRIPT - READY TO USE
]]

local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

-- Wait for player to load
repeat task.wait() until Player and Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
repeat task.wait() until Player.PlayerGui

-- Variables
local autoPickup = false
local isPickingUp = false
local ScreenGui = nil
local dragging = false
local dragStart = nil
local startPos = nil

-- ==================== TOAST NOTIFICATION ====================
local function createToast(message, type)
    local colors = {
        success = Color3.fromRGB(46, 204, 113),
        error = Color3.fromRGB(231, 76, 60),
        info = Color3.fromRGB(52, 152, 219),
        warning = Color3.fromRGB(241, 196, 15)
    }
    
    local bgColor = colors[type] or colors.info
    
    local container = Instance.new("Frame")
    container.Size = UDim2.new(0, 280, 0, 40)
    container.Position = UDim2.new(1, -300, 1, -60)
    container.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    container.BackgroundTransparency = 0.1
    container.BorderSizePixel = 0
    container.DisplayOrder = 999
    container.ZIndex = 999
    container.Parent = Player.PlayerGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = container
    
    local colorBar = Instance.new("Frame")
    colorBar.Size = UDim2.new(0, 4, 1, 0)
    colorBar.BackgroundColor3 = bgColor
    colorBar.BorderSizePixel = 0
    colorBar.ZIndex = 1000
    colorBar.Parent = container
    
    local icon = Instance.new("TextLabel")
    icon.Size = UDim2.new(0, 25, 1, 0)
    icon.Position = UDim2.new(0, 10, 0, 0)
    icon.BackgroundTransparency = 1
    icon.TextColor3 = bgColor
    icon.TextSize = 16
    icon.Text = type == "success" and "✓" or type == "error" and "✕" or type == "warning" and "⚠" or "ℹ"
    icon.Font = Enum.Font.SourceSansBold
    icon.ZIndex = 1000
    icon.Parent = container
    
    local text = Instance.new("TextLabel")
    text.Size = UDim2.new(1, -45, 1, 0)
    text.Position = UDim2.new(0, 40, 0, 0)
    text.BackgroundTransparency = 1
    text.Text = message
    text.TextColor3 = Color3.fromRGB(255, 255, 255)
    text.TextSize = 13
    text.TextXAlignment = Enum.TextXAlignment.Left
    text.TextYAlignment = Enum.TextYAlignment.Center
    text.Font = Enum.Font.SourceSans
    text.ZIndex = 1000
    text.Parent = container
    
    -- Animate in
    container.Position = UDim2.new(1, -300, 1, -60)
    container.BackgroundTransparency = 1
    
    local tween = game:GetService("TweenService")
    local fadeIn = tween:Create(container, 
        TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        {BackgroundTransparency = 0.1, Position = UDim2.new(1, -300, 1, -80)}
    )
    fadeIn:Play()
    
    task.wait(2.5)
    
    local fadeOut = tween:Create(container,
        TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
        {BackgroundTransparency = 1, Position = UDim2.new(1, -300, 1, -60)}
    )
    fadeOut:Play()
    
    task.wait(0.3)
    container:Destroy()
end

-- ==================== CREATE GUI ====================
local function createGUI()
    -- Remove old GUI if exists
    if Player.PlayerGui:FindFirstChild("GunPickupGUI") then
        Player.PlayerGui.GunPickupGUI:Destroy()
    end
    
    ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "GunPickupGUI"
    ScreenGui.Parent = Player.PlayerGui
    ScreenGui.ResetOnSpawn = false
    ScreenGui.DisplayOrder = 999
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
    
    createToast("🔫 Gun Pickup Script Loaded!", "success")
    
    -- Main Frame
    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 220, 0, 120)
    MainFrame.Position = UDim2.new(0.5, -110, 0.5, -60)
    MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    MainFrame.BackgroundTransparency = 0.1
    MainFrame.BorderSizePixel = 0
    MainFrame.DisplayOrder = 999
    MainFrame.ZIndex = 999
    MainFrame.Parent = ScreenGui
    
    -- Shadow
    local shadow = Instance.new("UIStroke")
    shadow.Color = Color3.fromRGB(0, 0, 0)
    shadow.Thickness = 2
    shadow.Transparency = 0.7
    shadow.Parent = MainFrame
    
    -- Corner
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = MainFrame
    
    -- Title Bar (THIS IS WHAT YOU DRAG)
    local TitleBar = Instance.new("Frame")
    TitleBar.Size = UDim2.new(1, 0, 0, 30)
    TitleBar.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
    TitleBar.BackgroundTransparency = 0.1
    TitleBar.BorderSizePixel = 0
    TitleBar.DisplayOrder = 999
    TitleBar.ZIndex = 1000
    TitleBar.Parent = MainFrame
    
    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 8)
    titleCorner.Parent = TitleBar
    
    -- Title Text
    local TitleText = Instance.new("TextLabel")
    TitleText.Size = UDim2.new(1, -40, 1, 0)
    TitleText.Position = UDim2.new(0, 10, 0, 0)
    TitleText.BackgroundTransparency = 1
    TitleText.Text = "🔫 Gun Pickup"
    TitleText.TextColor3 = Color3.fromRGB(255, 255, 255)
    TitleText.TextSize = 14
    TitleText.TextXAlignment = Enum.TextXAlignment.Left
    TitleText.Font = Enum.Font.SourceSansBold
    TitleText.DisplayOrder = 1000
    TitleText.ZIndex = 1000
    TitleText.Parent = TitleBar
    
    -- Close Button
    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.new(0, 30, 1, 0)
    CloseBtn.Position = UDim2.new(1, -30, 0, 0)
    CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    CloseBtn.BackgroundTransparency = 0.3
    CloseBtn.BorderSizePixel = 0
    CloseBtn.Text = "✕"
    CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseBtn.TextSize = 16
    CloseBtn.Font = Enum.Font.SourceSansBold
    CloseBtn.DisplayOrder = 1000
    CloseBtn.ZIndex = 1000
    CloseBtn.Parent = TitleBar
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 8)
    closeCorner.Parent = CloseBtn
    
    -- Manual Pickup Button
    local PickupBtn = Instance.new("TextButton")
    PickupBtn.Size = UDim2.new(0, 190, 0, 28)
    PickupBtn.Position = UDim2.new(0.5, -95, 0, 40)
    PickupBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    PickupBtn.BackgroundTransparency = 0.2
    PickupBtn.BorderSizePixel = 0
    PickupBtn.Text = "Pickup Gun"
    PickupBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
    PickupBtn.TextSize = 14
    PickupBtn.Font = Enum.Font.SourceSansSemibold
    PickupBtn.DisplayOrder = 1000
    PickupBtn.ZIndex = 1000
    PickupBtn.Parent = MainFrame
    
    local pickupCorner = Instance.new("UICorner")
    pickupCorner.CornerRadius = UDim.new(0, 6)
    pickupCorner.Parent = PickupBtn
    
    -- Auto Pickup Button
    local AutoBtn = Instance.new("TextButton")
    AutoBtn.Size = UDim2.new(0, 190, 0, 28)
    AutoBtn.Position = UDim2.new(0.5, -95, 0, 75)
    AutoBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    AutoBtn.BackgroundTransparency = 0.2
    AutoBtn.BorderSizePixel = 0
    AutoBtn.Text = "Auto Pickup: OFF"
    AutoBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
    AutoBtn.TextSize = 14
    AutoBtn.Font = Enum.Font.SourceSansSemibold
    AutoBtn.DisplayOrder = 1000
    AutoBtn.ZIndex = 1000
    AutoBtn.Parent = MainFrame
    
    local autoCorner = Instance.new("UICorner")
    autoCorner.CornerRadius = UDim.new(0, 6)
    autoCorner.Parent = AutoBtn
    
    -- ==================== DRAG SYSTEM ====================
    TitleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
        end
    end)
    
    TitleBar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
    
    -- ==================== GUN FUNCTIONS ====================
    
    local function findGun()
        for _, child in pairs(workspace:GetChildren()) do
            if child:IsA("Model") and child.Name == "Gun" then
                local part = child.PrimaryPart or child:FindFirstChildWhichIsA("BasePart")
                if part then
                    return child, part
                end
            end
        end
        return nil, nil
    end
    
    local function pickupGun()
        if isPickingUp then
            createToast("⏳ Already picking up!", "warning")
            return
        end
        
        local char = Player.Character
        if not char then
            createToast("❌ Character not found!", "error")
            return
        end
        
        local root = char:FindFirstChild("HumanoidRootPart")
        if not root then
            createToast("❌ HumanoidRootPart not found!", "error")
            return
        end
        
        local gun, part = findGun()
        
        if not gun then
            createToast("❌ No gun found!", "error")
            return
        end
        
        isPickingUp = true
        createToast("🎯 Teleporting to gun...", "info")
        
        local originalPos = root.Position
        
        root.CFrame = CFrame.new(part.Position + Vector3.new(0, 2, 0))
        task.wait(0.15)
        
        root.CFrame = CFrame.new(part.Position)
        task.wait(0.15)
        
        root.CFrame = CFrame.new(originalPos)
        
        createToast("✅ Gun picked up!", "success")
        task.wait(0.2)
        isPickingUp = false
    end
    
    -- ==================== BUTTON EVENTS ====================
    
    CloseBtn.MouseButton1Click:Connect(function()
        createToast("🔴 GUI Removed", "info")
        ScreenGui:Destroy()
    end)
    
    PickupBtn.MouseButton1Click:Connect(function()
        pickupGun()
    end)
    
    AutoBtn.MouseButton1Click:Connect(function()
        autoPickup = not autoPickup
        AutoBtn.Text = "Auto Pickup: " .. (autoPickup and "ON" or "OFF")
        AutoBtn.BackgroundColor3 = autoPickup and Color3.fromRGB(50, 150, 50) or Color3.fromRGB(60, 60, 70)
        createToast(autoPickup and "🔄 Auto Pickup: ON" or "⏹ Auto Pickup: OFF", autoPickup and "success" or "info")
    end)
    
    -- ==================== AUTO PICKUP LOOP ====================
    
    RunService.Heartbeat:Connect(function()
        if autoPickup then
            local gun, _ = findGun()
            if gun then
                pickupGun()
                task.wait(1)
            end
        end
    end)
    
    -- ==================== CHARACTER HANDLING ====================
    
    Player.CharacterAdded:Connect(function()
        createToast("🔄 Character respawned!", "info")
    end)
    
    return ScreenGui
end

-- ==================== START SCRIPT ====================

local success, err = pcall(function()
    createGUI()
end)

if not success then
    warn("❌ Failed to create GUI: " .. tostring(err))
    task.wait(1)
    pcall(function()
        createGUI()
    end)
end

print("✅ MM2 Gun Pickup Script Loaded Successfully!")
print("🎯 Drag the GUI by the title bar")
print("🎯 Click 'Pickup Gun' to grab the gun")
print("🎯 Toggle 'Auto Pickup' for automatic grabbing")

-- Return controls
return {
    ScreenGui = ScreenGui,
    ToggleAuto = function()
        autoPickup = not autoPickup
        return autoPickup
    end,
    Pickup = function()
        pickupGun()
    end,
    Close = function()
        if ScreenGui then
            ScreenGui:Destroy()
        end
    end
}
