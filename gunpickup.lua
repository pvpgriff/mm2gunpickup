--[[
    FIXED MM2 GUN PICKUP SCRIPT - WORKS WITH LOADSTRING
]]

-- Get the player safely
local Players = game:GetService("Players")
local Player = Players.LocalPlayer

-- Wait for player
repeat task.wait() until Player and Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")

local Character = Player.Character
local HumanoidRootPart = Character.HumanoidRootPart
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

-- Variables
local autoPickupEnabled = false
local originalPosition = nil
local isPickingUp = false
local ScreenGui = nil

-- ==================== TOAST NOTIFICATION SYSTEM ====================
local function createToastNotification(message, type)
    local colorMap = {
        info = Color3.fromRGB(52, 152, 219),
        success = Color3.fromRGB(46, 204, 113),
        error = Color3.fromRGB(231, 76, 60),
        warning = Color3.fromRGB(241, 196, 15)
    }
    local bgColor = colorMap[type] or colorMap.info
    
    local notificationContainer = Instance.new("Frame")
    notificationContainer.Size = UDim2.new(0, 300, 0, 50)
    notificationContainer.Position = UDim2.new(1, -320, 1, -100)
    notificationContainer.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    notificationContainer.BackgroundTransparency = 0.05
    notificationContainer.BorderSizePixel = 0
    notificationContainer.DisplayOrder = 999
    notificationContainer.ZIndex = 999
    notificationContainer.Parent = Player.PlayerGui
    
    local toastCorner = Instance.new("UICorner")
    toastCorner.CornerRadius = UDim.new(0, 8)
    toastCorner.Parent = notificationContainer
    
    local colorBar = Instance.new("Frame")
    colorBar.Size = UDim2.new(0, 5, 1, 0)
    colorBar.BackgroundColor3 = bgColor
    colorBar.BorderSizePixel = 0
    colorBar.ZIndex = 1000
    colorBar.Parent = notificationContainer
    
    local barCorner = Instance.new("UICorner")
    barCorner.CornerRadius = UDim.new(0, 4)
    barCorner.Parent = colorBar
    
    local iconLabel = Instance.new("TextLabel")
    iconLabel.Size = UDim2.new(0, 30, 1, 0)
    iconLabel.Position = UDim2.new(0, 10, 0, 0)
    iconLabel.BackgroundTransparency = 1
    iconLabel.TextColor3 = bgColor
    iconLabel.TextSize = 20
    iconLabel.Text = type == "success" and "✓" or type == "error" and "✕" or type == "warning" and "⚠" or "ℹ"
    iconLabel.Font = Enum.Font.SourceSansBold
    iconLabel.TextXAlignment = Enum.TextXAlignment.Center
    iconLabel.ZIndex = 1000
    iconLabel.Parent = notificationContainer
    
    local messageLabel = Instance.new("TextLabel")
    messageLabel.Size = UDim2.new(1, -50, 1, 0)
    messageLabel.Position = UDim2.new(0, 45, 0, 0)
    messageLabel.BackgroundTransparency = 1
    messageLabel.Text = message
    messageLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    messageLabel.TextSize = 14
    messageLabel.TextXAlignment = Enum.TextXAlignment.Left
    messageLabel.TextYAlignment = Enum.TextYAlignment.Center
    messageLabel.Font = Enum.Font.SourceSansSemibold
    messageLabel.ZIndex = 1000
    messageLabel.Parent = notificationContainer
    
    notificationContainer.Position = UDim2.new(1, -320, 1, -100)
    notificationContainer.BackgroundTransparency = 1
    
    local fadeIn = TweenService:Create(notificationContainer, 
        TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        {BackgroundTransparency = 0.05, Position = UDim2.new(1, -320, 1, -120)}
    )
    fadeIn:Play()
    
    task.wait(2.5)
    
    local fadeOut = TweenService:Create(notificationContainer,
        TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
        {BackgroundTransparency = 1, Position = UDim2.new(1, -320, 1, -100)}
    )
    fadeOut:Play()
    
    task.wait(0.3)
    notificationContainer:Destroy()
end

-- ==================== CREATE GUI ====================
local function createGUI()
    if not Player.PlayerGui then
        Player:WaitForChild("PlayerGui")
    end
    
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
    
    createToastNotification("🔫 Gun Pickup Script Loaded!", "success")
    
    -- Main Frame
    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 250, 0, 150)
    MainFrame.Position = UDim2.new(0.5, -125, 0.5, -75)
    MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    MainFrame.BackgroundTransparency = 0.1
    MainFrame.BorderSizePixel = 0
    MainFrame.ClipsDescendants = true
    MainFrame.Active = true
    MainFrame.Draggable = true
    MainFrame.DisplayOrder = 999
    MainFrame.ZIndex = 999
    MainFrame.Parent = ScreenGui
    
    local shadowEffect = Instance.new("UIStroke")
    shadowEffect.Color = Color3.fromRGB(0, 0, 0)
    shadowEffect.Thickness = 3
    shadowEffect.Transparency = 0.7
    shadowEffect.Parent = MainFrame
    
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 10)
    UICorner.Parent = MainFrame
    
    -- Title Bar
    local TitleBar = Instance.new("Frame")
    TitleBar.Size = UDim2.new(1, 0, 0, 35)
    TitleBar.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
    TitleBar.BackgroundTransparency = 0.1
    TitleBar.BorderSizePixel = 0
    TitleBar.DisplayOrder = 999
    TitleBar.ZIndex = 1000
    TitleBar.Parent = MainFrame
    
    local TitleCorner = Instance.new("UICorner")
    TitleCorner.CornerRadius = UDim.new(0, 10)
    TitleCorner.Parent = TitleBar
    
    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Size = UDim2.new(1, -40, 1, 0)
    TitleLabel.Position = UDim2.new(0, 10, 0, 0)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = "🔫 Gun Pickup"
    TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    TitleLabel.TextSize = 16
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.Font = Enum.Font.SourceSansSemibold
    TitleLabel.DisplayOrder = 1000
    TitleLabel.ZIndex = 1000
    TitleLabel.Parent = TitleBar
    
    -- Close Button
    local CloseButton = Instance.new("TextButton")
    CloseButton.Size = UDim2.new(0, 30, 1, 0)
    CloseButton.Position = UDim2.new(1, -30, 0, 0)
    CloseButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    CloseButton.BackgroundTransparency = 0.3
    CloseButton.BorderSizePixel = 0
    CloseButton.Text = "✕"
    CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseButton.TextSize = 18
    CloseButton.Font = Enum.Font.SourceSansBold
    CloseButton.DisplayOrder = 1000
    CloseButton.ZIndex = 1000
    CloseButton.Parent = TitleBar
    
    local CloseCorner = Instance.new("UICorner")
    CloseCorner.CornerRadius = UDim.new(0, 8)
    CloseCorner.Parent = CloseButton
    
    -- Auto Pickup Button
    local AutoPickupButton = Instance.new("TextButton")
    AutoPickupButton.Size = UDim2.new(0, 220, 0, 40)
    AutoPickupButton.Position = UDim2.new(0.5, -110, 0, 50)
    AutoPickupButton.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    AutoPickupButton.BackgroundTransparency = 0.2
    AutoPickupButton.BorderSizePixel = 0
    AutoPickupButton.Text = "Auto Pickup Gun: OFF"
    AutoPickupButton.TextColor3 = Color3.fromRGB(200, 200, 200)
    AutoPickupButton.TextSize = 14
    AutoPickupButton.Font = Enum.Font.SourceSansSemibold
    AutoPickupButton.DisplayOrder = 1000
    AutoPickupButton.ZIndex = 1000
    AutoPickupButton.Parent = MainFrame
    
    local AutoCorner = Instance.new("UICorner")
    AutoCorner.CornerRadius = UDim.new(0, 6)
    AutoCorner.Parent = AutoPickupButton
    
    -- Manual Pickup Button
    local PickupButton = Instance.new("TextButton")
    PickupButton.Size = UDim2.new(0, 220, 0, 40)
    PickupButton.Position = UDim2.new(0.5, -110, 0, 100)
    PickupButton.BackgroundColor3 = Color3.fromRGB(70, 70, 80)
    PickupButton.BackgroundTransparency = 0.2
    PickupButton.BorderSizePixel = 0
    PickupButton.Text = "Pickup Gun"
    PickupButton.TextColor3 = Color3.fromRGB(200, 200, 200)
    PickupButton.TextSize = 14
    PickupButton.Font = Enum.Font.SourceSansSemibold
    PickupButton.DisplayOrder = 1000
    PickupButton.ZIndex = 1000
    PickupButton.Parent = MainFrame
    
    local PickupCorner = Instance.new("UICorner")
    PickupCorner.CornerRadius = UDim.new(0, 6)
    PickupCorner.Parent = PickupButton
    
    -- ==================== GUN FUNCTIONS ====================
    local function findDroppedGun()
        local possibleGunNames = {"Dropped Gun", "Gun", "ToolGun", "Weapon"}
        
        for _, child in pairs(workspace:GetChildren()) do
            if child:IsA("Model") then
                for _, name in pairs(possibleGunNames) do
                    if child.Name == name then
                        local primaryPart = child.PrimaryPart or child:FindFirstChildWhichIsA("BasePart")
                        if primaryPart then
                            return child
                        end
                    end
                end
            end
            if child:IsA("BasePart") then
                for _, name in pairs(possibleGunNames) do
                    if child.Name == name then
                        return child
                    end
                end
            end
        end
        
        for _, child in pairs(workspace:GetChildren()) do
            if child:IsA("Model") or child:IsA("BasePart") then
                if child:GetAttribute("Gun") or child:GetAttribute("Dropped") then
                    return child
                end
            end
        end
        return nil
    end
    
    local function pickupGun()
        if isPickingUp then 
            createToastNotification("⏳ Already picking up gun!", "warning")
            return 
        end
        
        local char = Player.Character
        if not char then
            createToastNotification("❌ Character not found!", "error")
            return
        end
        
        local rootPart = char:FindFirstChild("HumanoidRootPart")
        if not rootPart then
            createToastNotification("❌ HumanoidRootPart not found!", "error")
            return
        end
        
        local gun = findDroppedGun()
        if not gun then
            createToastNotification("❌ No dropped gun found!", "error")
            return
        end
        
        local gunPosition = nil
        local targetPart = nil
        
        if gun:IsA("Model") then
            targetPart = gun.PrimaryPart or gun:FindFirstChildWhichIsA("BasePart")
            if targetPart then
                gunPosition = targetPart.Position
            end
        elseif gun:IsA("BasePart") then
            targetPart = gun
            gunPosition = gun.Position
        end
        
        if not gunPosition then
            createToastNotification("❌ Could not find gun position!", "error")
            return
        end
        
        isPickingUp = true
        createToastNotification("🎯 Teleporting to gun...", "info")
        
        originalPosition = rootPart.Position
        rootPart.CFrame = CFrame.new(gunPosition + Vector3.new(0, 1, 0))
        
        task.wait(0.2)
        
        if targetPart and targetPart:FindFirstChild("TouchInterest") then
            rootPart.CFrame = CFrame.new(gunPosition)
            task.wait(0.1)
        end
        
        if originalPosition then
            rootPart.CFrame = CFrame.new(originalPosition)
            originalPosition = nil
        end
        
        createToastNotification("✅ Gun picked up successfully!", "success")
        task.wait(0.3)
        isPickingUp = false
    end
    
    local function smartPickup()
        pickupGun()
    end
    
    -- ==================== BUTTON CONNECTIONS ====================
    CloseButton.MouseButton1Click:Connect(function()
        createToastNotification("🔴 GUI Removed", "info")
        if ScreenGui then
            ScreenGui:Destroy()
        end
    end)
    
    AutoPickupButton.MouseButton1Click:Connect(function()
        autoPickupEnabled = not autoPickupEnabled
        AutoPickupButton.Text = "Auto Pickup Gun: " .. (autoPickupEnabled and "ON" or "OFF")
        AutoPickupButton.BackgroundColor3 = autoPickupEnabled and Color3.fromRGB(50, 150, 50) or Color3.fromRGB(60, 60, 70)
        
        if autoPickupEnabled then
            createToastNotification("🔄 Auto Pickup: ON", "success")
        else
            createToastNotification("⏹ Auto Pickup: OFF", "info")
        end
    end)
    
    PickupButton.MouseButton1Click:Connect(function()
        smartPickup()
    end)
    
    -- ==================== AUTO PICKUP LOOP ====================
    RunService.Heartbeat:Connect(function()
        if autoPickupEnabled then
            local gun = findDroppedGun()
            if gun then
                smartPickup()
                task.wait(0.8)
            end
        end
    end)
    
    -- ==================== CHARACTER HANDLING ====================
    Player.CharacterAdded:Connect(function(newChar)
        Character = newChar
        HumanoidRootPart = newChar:WaitForChild("HumanoidRootPart")
        originalPosition = nil
        isPickingUp = false
        createToastNotification("🔄 Character respawned!", "info")
    end)
    
    print("✅ MM2 Gun Pickup Script Loaded Successfully!")
    return ScreenGui
end

-- ==================== INITIALIZE ====================
local success, err = pcall(function()
    if Player and Player.PlayerGui then
        createGUI()
    else
        -- Wait for PlayerGui
        Player:WaitForChild("PlayerGui")
        createGUI()
    end
end)

if not success then
    warn("❌ Failed to create GUI: " .. tostring(err))
    task.wait(1)
    pcall(function()
        if Player and Player.PlayerGui then
            createGUI()
        end
    end)
end

print("✅ Script initialization complete!")

-- Return controls
return {
    ScreenGui = ScreenGui,
    ToggleAuto = function()
        autoPickupEnabled = not autoPickupEnabled
        return autoPickupEnabled
    end,
    Pickup = function()
        smartPickup()
    end,
    Close = function()
        if ScreenGui then
            ScreenGui:Destroy()
        end
    end
}
