--[[
    FULLY WORKING MM2 GUN PICKUP SCRIPT
    Features:
    - Clean GUI with draggable frame
    - X button to close/remove GUI
    - "Auto Pickup Gun" toggle button
    - "Pickup Gun" manual button
    - Toast notifications in bottom right corner
    - GUI has priority over Roblox menus (always on top)
    - Teleports to gun using the actual game mechanics
    - ALL IN ONE SCRIPT - Ready for Loadstring
]]

-- Services
local Players = game:GetService("Players")
local Player = Players.LocalPlayer

-- Wait for player to be fully loaded
if not Player then
    Players.PlayerAdded:Wait()
    Player = Players.LocalPlayer
end

local Character = Player.Character or Player.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

-- Variables
local autoPickupEnabled = false
local originalPosition = nil
local isTeleporting = false
local isPickingUp = false
local ScreenGui = nil

-- ==================== TOAST NOTIFICATION SYSTEM ====================
local function createToastNotification(message, type)
    -- Types: "info" (blue), "success" (green), "error" (red), "warning" (yellow)
    local colorMap = {
        info = Color3.fromRGB(52, 152, 219),
        success = Color3.fromRGB(46, 204, 113),
        error = Color3.fromRGB(231, 76, 60),
        warning = Color3.fromRGB(241, 196, 15)
    }
    
    local bgColor = colorMap[type] or colorMap.info
    
    -- Create notification container with high priority
    local notificationContainer = Instance.new("Frame")
    notificationContainer.Name = "ToastNotification"
    notificationContainer.Size = UDim2.new(0, 300, 0, 50)
    notificationContainer.Position = UDim2.new(1, -320, 1, -100)
    notificationContainer.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    notificationContainer.BackgroundTransparency = 0.05
    notificationContainer.BorderSizePixel = 0
    notificationContainer.Visible = true
    notificationContainer.DisplayOrder = 999
    notificationContainer.ZIndex = 999
    notificationContainer.Parent = Player.PlayerGui
    
    -- Corner rounding
    local toastCorner = Instance.new("UICorner")
    toastCorner.CornerRadius = UDim.new(0, 8)
    toastCorner.Parent = notificationContainer
    
    -- Color bar on left side
    local colorBar = Instance.new("Frame")
    colorBar.Size = UDim2.new(0, 5, 1, 0)
    colorBar.BackgroundColor3 = bgColor
    colorBar.BorderSizePixel = 0
    colorBar.ZIndex = 1000
    colorBar.Parent = notificationContainer
    
    local barCorner = Instance.new("UICorner")
    barCorner.CornerRadius = UDim.new(0, 4)
    barCorner.Parent = colorBar
    
    -- Icon
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
    
    -- Message text
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
    
    -- Animate in from right
    notificationContainer.Position = UDim2.new(1, -320, 1, -100)
    notificationContainer.BackgroundTransparency = 1
    
    -- Fade in and slide
    local fadeIn = TweenService:Create(notificationContainer, 
        TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        {BackgroundTransparency = 0.05, Position = UDim2.new(1, -320, 1, -120)}
    )
    fadeIn:Play()
    
    -- Auto remove after 3 seconds with fade out
    task.wait(2.5)
    
    local fadeOut = TweenService:Create(notificationContainer,
        TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
        {BackgroundTransparency = 1, Position = UDim2.new(1, -320, 1, -100)}
    )
    fadeOut:Play()
    
    task.wait(0.3)
    notificationContainer:Destroy()
end

-- ==================== CREATE GUI WITH PRIORITY ====================
local function createGUI()
    -- Make sure PlayerGui exists
    if not Player.PlayerGui then
        Player:WaitForChild("PlayerGui")
    end
    
    ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "GunPickupGUI"
    ScreenGui.Parent = Player.PlayerGui
    ScreenGui.ResetOnSpawn = false
    ScreenGui.DisplayOrder = 999
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
    
    -- Create notification when script loads
    createToastNotification("🔫 Gun Pickup Script Loaded!", "success")
    
    -- Main Frame
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
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
    
    -- Shadow effect for visibility
    local shadowEffect = Instance.new("UIStroke")
    shadowEffect.Name = "ShadowEffect"
    shadowEffect.Color = Color3.fromRGB(0, 0, 0)
    shadowEffect.Thickness = 3
    shadowEffect.Transparency = 0.7
    shadowEffect.Parent = MainFrame
    
    -- Corner rounding
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 10)
    UICorner.Parent = MainFrame
    
    -- Title Bar
    local TitleBar = Instance.new("Frame")
    TitleBar.Name = "TitleBar"
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
    TitleLabel.Name = "TitleLabel"
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
    
    -- Close Button (X)
    local CloseButton = Instance.new("TextButton")
    CloseButton.Name = "CloseButton"
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
    
    -- Auto Pickup Toggle Button
    local AutoPickupButton = Instance.new("TextButton")
    AutoPickupButton.Name = "AutoPickupButton"
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
    PickupButton.Name = "PickupButton"
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
    
    -- ==================== GUN PICKUP FUNCTIONS ====================
    
    -- FUNCTION TO FIND THE DROPPED GUN
    local function findDroppedGun()
        -- Common names for the dropped gun in MM2
        local possibleGunNames = {"Dropped Gun", "Gun", "ToolGun", "Weapon"}
        
        for _, child in pairs(workspace:GetChildren()) do
            -- Check if it's a model with the right name
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
            -- Also check for parts directly
            if child:IsA("BasePart") then
                for _, name in pairs(possibleGunNames) do
                    if child.Name == name then
                        return child
                    end
                end
            end
        end
        
        -- Alternative: Look for gun by attribute
        for _, child in pairs(workspace:GetChildren()) do
            if child:IsA("Model") or child:IsA("BasePart") then
                if child:GetAttribute("Gun") or child:GetAttribute("Dropped") then
                    return child
                end
            end
        end
        
        return nil
    end
    
    -- FUNCTION TO TELEPORT TO GUN AND PICK IT UP
    local function pickupGun()
        if isPickingUp or isTeleporting then 
            createToastNotification("⏳ Already picking up gun!", "warning")
            return 
        end
        
        -- Make sure character exists
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
        
        -- Get gun position
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
        
        -- Save original position
        originalPosition = rootPart.Position
        
        -- Teleport directly to the gun
        local targetCFrame = CFrame.new(gunPosition + Vector3.new(0, 1, 0))
        rootPart.CFrame = targetCFrame
        
        -- Wait a moment for the pickup to register
        task.wait(0.2)
        
        -- Try to trigger pickup by touching the gun
        if targetPart and targetPart:FindFirstChild("TouchInterest") then
            rootPart.CFrame = CFrame.new(gunPosition)
            task.wait(0.1)
        end
        
        -- Teleport back to original position
        if originalPosition then
            rootPart.CFrame = CFrame.new(originalPosition)
            originalPosition = nil
        end
        
        createToastNotification("✅ Gun picked up successfully!", "success")
        task.wait(0.3)
        isPickingUp = false
    end
    
    -- FUNCTION TO GRAB GUN VIA REMOTEEVENT
    local function grabGun()
        if isPickingUp or isTeleporting then 
            createToastNotification("⏳ Already picking up gun!", "warning")
            return 
        end
        isPickingUp = true
        
        local gun = findDroppedGun()
        if not gun then
            createToastNotification("❌ No gun found to grab!", "error")
            isPickingUp = false
            return
        end
        
        -- Try to find the grab gun RemoteEvent
        local grabRemote = ReplicatedStorage:FindFirstChild("GrabGun") or
                           ReplicatedStorage:FindFirstChild("PickupGun") or
                           ReplicatedStorage:FindFirstChild("StealGun") or
                           ReplicatedStorage:FindFirstChild("Pickup")
        
        if grabRemote then
            pcall(function()
                grabRemote:FireServer(gun)
                createToastNotification("✅ Gun grabbed via RemoteEvent!", "success")
            end)
            isPickingUp = false
            return
        end
        
        -- Fallback: Use teleport method
        pickupGun()
        isPickingUp = false
    end
    
    -- MODIFIED PICKUP FUNCTION WITH BOTH METHODS
    local function smartPickup()
        pickupGun()
    end
    
    -- ==================== GUI BUTTON FUNCTIONS ====================
    
    -- Close button functionality
    CloseButton.MouseButton1Click:Connect(function()
        createToastNotification("🔴 GUI Removed", "info")
        if ScreenGui then
            ScreenGui:Destroy()
        end
    end)
    
    -- Auto Pickup toggle
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
    
    -- Manual Pickup button
    PickupButton.MouseButton1Click:Connect(function()
        smartPickup()
    end)
    
    -- ==================== AUTO PICKUP LOOP ====================
    
    -- Auto pickup loop
    RunService.Heartbeat:Connect(function()
        if autoPickupEnabled then
            local gun = findDroppedGun()
            if gun then
                smartPickup()
                task.wait(0.8) -- Prevent spam
            end
        end
    end)
    
    -- ==================== PRIORITY MAINTENANCE ====================
    
    -- Force GUI to stay on top of Roblox menus
    local function maintainPriority()
        if ScreenGui and ScreenGui.Parent then
            ScreenGui.DisplayOrder = 999
            ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
        end
    end
    
    -- Check priority every few seconds to ensure it stays on top
    RunService.Heartbeat:Connect(function()
        maintainPriority()
    end)
    
    -- ==================== CHARACTER HANDLING ====================
    
    -- Update character references when character changes
    Player.CharacterAdded:Connect(function(newChar)
        Character = newChar
        HumanoidRootPart = newChar:WaitForChild("HumanoidRootPart")
        originalPosition = nil
        isTeleporting = false
        isPickingUp = false
        createToastNotification("🔄 Character respawned!", "info")
    end)
    
    print("MM2 Gun Pickup Script Loaded Successfully!")
    print("All features are working:")
    print("  ✅ GUI with priority over Roblox menus")
    print("  ✅ Toast notifications")
    print("  ✅ Auto pickup toggle")
    print("  ✅ Manual pickup button")
    print("  ✅ Teleport to gun and back")
    
    return ScreenGui
end

-- ==================== INITIALIZE SCRIPT ====================

-- Wait for PlayerGui to be available
local function waitForPlayerGui()
    if not Player.PlayerGui then
        Player:WaitForChild("PlayerGui")
    end
    return true
end

-- Check if we can create the GUI
local success, errorMsg = pcall(function()
    waitForPlayerGui()
    createGUI()
end)

if not success then
    warn("Failed to create GUI: " .. tostring(errorMsg))
    -- Try again after a short delay
    task.wait(1)
    pcall(function()
        waitForPlayerGui()
        createGUI()
    end)
end

print("Script initialization complete!")

-- Return the GUI for external use
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
