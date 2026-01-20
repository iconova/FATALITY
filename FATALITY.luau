local repo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()
local ThemeManager = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()

local Window = Library:CreateWindow({
    Title = "FATALITY",
    Footer = "fatality.win rrxagg",
    Icon = 4483362458,
    ShowCustomCursor = true,
    NotifySide = "Right",
    Center = true,
    AutoShow = true,
})

local Tabs = {
    Main = Window:AddTab("Main", "user"),
    Visuals = Window:AddTab("Visuals", "eye"),
    Player = Window:AddTab("Player", "user"),
    Rivals = Window:AddTab("Rivals", "swords"),
    Settings = Window:AddTab("UI Settings", "settings"),
}

local crosshairGui = nil
local crosshairConn = nil

local function getLocalPlayer()
    local success, player = pcall(function()
        return game:GetService("Players").LocalPlayer
    end)
    return success and player or nil
end

local function destroyCrosshair()
    if crosshairConn then
        pcall(function()
            crosshairConn:Disconnect()
        end)
        crosshairConn = nil
    end
    
    local player = getLocalPlayer()
    if player then
        local pg = player:FindFirstChild("PlayerGui")
        if pg then
            pcall(function()
                local cross = pg:FindFirstChild("PlusCrosshair")
                if cross then
                    cross:Destroy()
                end
            end)
        end
    end
    
    crosshairGui = nil
end

local function createCrosshair()
    destroyCrosshair()
    
    if not Library.Toggles.CrosshairToggle.Value then return end
    
    local crosshairText = Library.Options.CrosshairText.Value or "FATALITY"
    
    local success, errorMsg = pcall(function()
        local player = getLocalPlayer()
        if not player then
            error("Local player not found")
            return
        end
        
        local pg = player:WaitForChild("PlayerGui", 2)
        if not pg then
            error("PlayerGui not found")
            return
        end
        
        pcall(function()
            local existing = pg:FindFirstChild("PlusCrosshair")
            if existing then
                existing:Destroy()
            end
        end)
        
        local THICK = 2
        local BASE = 22
        local AMP = 10
        local ROT_SPEED = 120
        local RAINBOW_SPEED = 0.25
        local GAP = 10
        
        local gui = Instance.new("ScreenGui")
        gui.Name = "PlusCrosshair"
        gui.IgnoreGuiInset = true
        gui.ResetOnSpawn = false
        gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        gui.Parent = pg
        
        local center = Instance.new("Frame")
        center.Size = UDim2.fromOffset(0, 0)
        center.Position = UDim2.fromScale(0.5, 0.5)
        center.AnchorPoint = Vector2.new(0.5, 0.5)
        center.BackgroundTransparency = 1
        center.Parent = gui
        
        local rotator = Instance.new("Frame")
        rotator.AnchorPoint = Vector2.new(0.5, 0.5)
        rotator.Size = UDim2.fromOffset(0, 0)
        rotator.BackgroundTransparency = 1
        rotator.Parent = center
        
        local function newLine(size, pos)
            local f = Instance.new("Frame")
            f.AnchorPoint = Vector2.new(0.5, 0.5)
            f.Size = size
            f.Position = pos
            f.BorderSizePixel = 0
            f.BackgroundColor3 = Color3.new(0, 0, 0)
            f.Parent = rotator

            local inner = Instance.new("Frame")
            inner.AnchorPoint = Vector2.new(0.5, 0.5)
            inner.Size = UDim2.fromScale(0.8, 0.8)
            inner.Position = UDim2.fromScale(0.5, 0.5)
            inner.BackgroundColor3 = Color3.new(1, 1, 1)
            inner.BorderSizePixel = 0
            inner.Name = "InnerColor"
            inner.Parent = f

            return f, inner
        end
        
        local lines = {}
        local inners = {}
        
        lines[1], inners[1] = newLine(UDim2.fromOffset(THICK, BASE), UDim2.fromOffset(0, -(BASE/2 + GAP)))
        lines[2], inners[2] = newLine(UDim2.fromOffset(THICK, BASE), UDim2.fromOffset(0,  (BASE/2 + GAP)))
        lines[3], inners[3] = newLine(UDim2.fromOffset(BASE, THICK), UDim2.fromOffset(-(BASE/2 + GAP), 0))
        lines[4], inners[4] = newLine(UDim2.fromOffset(BASE, THICK), UDim2.fromOffset( (BASE/2 + GAP), 0))
        
        local label = Instance.new("TextLabel")
        label.Text = crosshairText
        label.AnchorPoint = Vector2.new(0.5, 0)
        label.Position = UDim2.fromOffset(0, 36)
        label.Size = UDim2.fromOffset(150, 21)
        label.BackgroundTransparency = 1
        label.TextScaled = true
        label.Font = Enum.Font.Arcade
        label.TextStrokeColor3 = Color3.new(0, 0, 0)
        label.TextStrokeTransparency = 0
        label.TextColor3 = Color3.new(1, 1, 1)
        label.Parent = center
        
        crosshairGui = gui
        
        local t = 0
        crosshairConn = game:GetService("RunService").RenderStepped:Connect(function(dt)
            if not Library.Toggles.CrosshairToggle.Value or not crosshairGui or not crosshairGui.Parent then
                destroyCrosshair()
                return
            end
            
            t += dt * 4

            local hue = (tick() * RAINBOW_SPEED) % 1
            local color = Color3.fromHSV(hue, 1, 1)

            rotator.Rotation += ROT_SPEED * dt

            local len = BASE + math.sin(t) * AMP

            lines[1].Size = UDim2.fromOffset(THICK, len)
            lines[1].Position = UDim2.fromOffset(0, -(len/2 + GAP))
            lines[2].Size = UDim2.fromOffset(THICK, len)
            lines[2].Position = UDim2.fromOffset(0,  (len/2 + GAP))
            lines[3].Size = UDim2.fromOffset(len, THICK)
            lines[3].Position = UDim2.fromOffset(-(len/2 + GAP), 0)
            lines[4].Size = UDim2.fromOffset(len, THICK)
            lines[4].Position = UDim2.fromOffset( (len/2 + GAP), 0)
            
            for i = 1, 4 do
                if inners[i] then
                    inners[i].Position = UDim2.fromScale(0.5, 0.5)
                end
            end

            for i = 1, 4 do
                if inners[i] then
                    inners[i].BackgroundColor3 = color
                end
            end

            label.TextColor3 = color
        end)
    end)
    
    if not success then
        warn("Failed to create crosshair:", errorMsg)
        destroyCrosshair()
        
        task.spawn(function()
            wait(0.5)
            if Library.Toggles.CrosshairToggle.Value then
                createCrosshair()
            end
        end)
    end
end

local MainGroup = Tabs.Main:AddLeftGroupbox("Main")

MainGroup:AddButton({
    Text = "FPS Boost",
    Func = function()
        settings().Rendering.QualityLevel = 1
        for _, v in pairs(game:GetDescendants()) do
            if v:IsA("BasePart") then 
                v.Material = Enum.Material.Plastic
                v.Reflectance = 0
            elseif v:IsA("Decal") or v:IsA("Texture") then 
                v.Transparency = 1 
            end
        end
    end,
})

MainGroup:AddButton({
    Text = "Unload FATALITY",
    Func = function()
        Library:Unload()
        
        local player = getLocalPlayer()
        local Lighting = game:GetService("Lighting")
        local Camera = workspace.CurrentCamera
        
        destroyCrosshair()
        
        Lighting.Brightness = 2
        Lighting.ExposureCompensation = 0
        Lighting.Ambient = Color3.fromRGB(128,128,128)
        Lighting.OutdoorAmbient = Color3.fromRGB(128,128,128)
        Lighting.GlobalShadows = true
        if Lighting:FindFirstChild("ExecutorBloom") then
            Lighting.ExecutorBloom:Destroy()
        end
        
        if getgenv().gg_scripters then
            getgenv().gg_scripters = nil
        end
        if Camera then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position)
        end
    end,
})

local VisualsGroup = Tabs.Visuals:AddLeftGroupbox("Visuals")

VisualsGroup:AddToggle("CrosshairToggle", {
    Text = "Enable Crosshair",
    Default = false,
    Callback = function(value)
        if value then
            createCrosshair()
        else
            destroyCrosshair()
        end
    end,
})

VisualsGroup:AddInput("CrosshairText", {
    Text = "Crosshair Text",
    Default = "FATALITY",
    Placeholder = "FATALITY",
    ClearTextOnFocus = false,
})

VisualsGroup:AddDivider()

VisualsGroup:AddToggle("LightingToggle", {
    Text = "Lighting Boost",
    Default = false,
    Callback = function(value)
        local Lighting = game:GetService("Lighting")
        if value then
            Lighting.Brightness = 3
            Lighting.ExposureCompensation = 0.5
            Lighting.Ambient = Color3.fromRGB(255,255,255)
            Lighting.OutdoorAmbient = Color3.fromRGB(255,255,255)
            Lighting.GlobalShadows = false
            if not Lighting:FindFirstChild("ExecutorBloom") then
                local bloom = Instance.new("BloomEffect")
                bloom.Name = "ExecutorBloom"
                bloom.Intensity = 0.3
                bloom.Threshold = 0.9
                bloom.Size = 56
                bloom.Parent = Lighting
            end
        else
            Lighting.Brightness = 2
            Lighting.ExposureCompensation = 0
            Lighting.Ambient = Color3.fromRGB(128,128,128)
            Lighting.OutdoorAmbient = Color3.fromRGB(128,128,128)
            Lighting.GlobalShadows = true
            if Lighting:FindFirstChild("ExecutorBloom") then
                Lighting.ExecutorBloom:Destroy()
            end
        end
    end,
})

VisualsGroup:AddSlider("CameraSlider", {
    Text = "Camera Resolution",
    Default = 0.5,
    Min = 0.1,
    Max = 1,
    Rounding = 2,
    Callback = function(value)
        local Camera = workspace.CurrentCamera
        getgenv().Resolution = {[".gg/scripters"] = value}
        if not getgenv().gg_scripters then
            game:GetService("RunService").RenderStepped:Connect(function()
                Camera.CFrame *= CFrame.new(
                    0,0,0,
                    1,0,0,
                    0,getgenv().Resolution[".gg/scripters"],0,
                    0,0,1
                )
            end)
            getgenv().gg_scripters = true
        end
    end,
})

local PlayerGroup = Tabs.Player:AddLeftGroupbox("Player")

PlayerGroup:AddButton({
    Text = "Korblox / Headless",
    Func = function()
        getgenv().Setting = {
            ["Body"] = {Korblox = true, Headless = true}
        }
        pcall(function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/khen791/script-khen/refs/heads/main/KorbloxAndHeadless.txt", true))()
        end)
    end,
})

local RivalsGroup = Tabs.Rivals:AddLeftGroupbox("Rivals")

RivalsGroup:AddLabel("⚠️ WARNING", true)
RivalsGroup:AddLabel("Beta Features\nVolt & Seliware only", true)

RivalsGroup:AddDivider()

RivalsGroup:AddButton({
    Text = "Unlock All Cosmetics",
    Func = function()
        local success, err = pcall(function()
            local script = [[
                local Players = game:GetService("Players")
                local player = Players.LocalPlayer
                
                game:GetService("StarterGui"):SetCore("SendNotification", {
                    Title = "Rivals Unlock All",
                    Text = "Attempting to unlock cosmetics...",
                    Duration = 3
                })
                
                local success, msg = pcall(function()
                    local DataController
                    local controllers = player.PlayerScripts:FindFirstChild("Controllers")
                    if controllers then
                        DataController = require(controllers:WaitForChild("PlayerDataController", 3))
                    end
                    
                    if DataController then
                        local originalGet = DataController.Get
                        DataController.Get = function(self, key)
                            local data = originalGet(self, key)
                            if key == "CosmeticInventory" then
                                local proxy = {}
                                if data then
                                    for k, v in pairs(data) do
                                        proxy[k] = v
                                    end
                                end
                                return setmetatable(proxy, {
                                    __index = function()
                                        return true
                                    end
                                })
                            end
                            return data
                        end
                        
                        game:GetService("StarterGui"):SetCore("SendNotification", {
                            Title = "Success!",
                            Text = "All cosmetics should now appear unlocked",
                            Duration = 5
                        })
                    else
                        error("DataController not found")
                    end
                end)
                
                if not success then
                    game:GetService("StarterGui"):SetCore("SendNotification", {
                        Title = "Error",
                        Text = "Failed: " .. tostring(msg),
                        Duration = 5
                    })
                end
            ]]
            
            loadstring(script)()
        end)
        
        if success then
            Library:Notify({
                Title = "Rivals Unlock All",
                Content = "Attempting to unlock cosmetics...",
                Time = 5,
            })
        else
            Library:Notify({
                Title = "Rivals Unlock All",
                Content = "Error: " .. tostring(err),
                Time = 5,
            })
        end
    end,
})

RivalsGroup:AddDivider()

RivalsGroup:AddLabel("Stat Spoofing", true)

local statInputs = {}

RivalsGroup:AddToggle("StatSpoofingToggle", {
    Text = "Enable Stat Spoofing",
    Default = false,
    Callback = function(value)
        for _, input in pairs(statInputs) do
            if input and input.SetVisible then
                input:SetVisible(value)
            end
        end
    end,
})

statInputs.id = RivalsGroup:AddInput("VictimID", {
    Text = "Victim ID",
    Default = "0",
    Placeholder = "0",
    ClearTextOnFocus = false,
    Visible = false,
})

statInputs.level = RivalsGroup:AddInput("DesiredLevel", {
    Text = "Desired Level",
    Default = "0",
    Placeholder = "0",
    ClearTextOnFocus = false,
    Visible = false,
})

statInputs.streak = RivalsGroup:AddInput("DesiredStreak", {
    Text = "Desired Streak",
    Default = "0",
    Placeholder = "0",
    ClearTextOnFocus = false,
    Visible = false,
})

statInputs.keys = RivalsGroup:AddInput("DesiredKeys", {
    Text = "Desired Keys",
    Default = "0",
    Placeholder = "0",
    ClearTextOnFocus = false,
    Visible = false,
})

statInputs.elo = RivalsGroup:AddInput("DesiredELO", {
    Text = "Desired ELO",
    Default = "0",
    Placeholder = "0",
    ClearTextOnFocus = false,
    Visible = false,
})

local function applyStatSpoofing()
    if not Library.Toggles.StatSpoofingToggle.Value then
        Library:Notify({
            Title = "Stat Spoofing",
            Content = "Please enable Stat Spoofing first!",
            Time = 3,
        })
        return
    end
    
    local victimID = tonumber(Library.Options.VictimID.Value) or 0
    local desiredLevel = tonumber(Library.Options.DesiredLevel.Value) or 0
    local desiredStreak = tonumber(Library.Options.DesiredStreak.Value) or 0
    local desiredKeys = tonumber(Library.Options.DesiredKeys.Value) or 0
    local desiredElo = tonumber(Library.Options.DesiredELO.Value) or 0
    
    local success, err = pcall(function()
        local configScript = [[
            getgenv().Config = {
                victim = ]] .. tostring(victimID) .. [[,
                helper = "",
                level = ]] .. tostring(desiredLevel) .. [[,
                streak = ]] .. tostring(desiredStreak) .. [[,
                elo = ]] .. tostring(desiredElo) .. [[,
                keys = ]] .. tostring(desiredKeys) .. [[,
                premium = true,
                verified = false,
                unlockall = false,
                platform = "desktop",
                join = "discord.gg/rivalscomp"
            }
            
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "Stat Spoofing",
                Text = "Applying stat spoofing...",
                Duration = 3
            })
            
            loadstring(game:HttpGet("https://raw.githubusercontent.com/zxrorocks/rcr/refs/heads/main/rcr"))()
        ]]
        
        loadstring(configScript)()
    end)
    
    if success then
        Library:Notify({
            Title = "Stat Spoofing",
            Content = "Stat spoofing applied successfully!",
            Time = 5,
        })
    else
        Library:Notify({
            Title = "Stat Spoofing Error",
            Content = "Failed to apply: " .. tostring(err),
            Time = 5,
        })
    end
end

RivalsGroup:AddButton({
    Text = "Apply Stat Spoofing",
    Func = applyStatSpoofing,
})

local MenuGroup = Tabs.Settings:AddLeftGroupbox("Menu")

MenuGroup:AddToggle("KeybindMenuOpen", {
    Default = Library.KeybindFrame.Visible,
    Text = "Open Keybind Menu",
    Callback = function(value)
        Library.KeybindFrame.Visible = value
    end,
})

MenuGroup:AddToggle("ShowCustomCursor", {
    Text = "Custom Cursor",
    Default = true,
    Callback = function(Value)
        Library.ShowCustomCursor = Value
    end,
})

MenuGroup:AddDropdown("NotificationSide", {
    Values = { "Left", "Right" },
    Default = "Right",
    Text = "Notification Side",
    Callback = function(Value)
        Library:SetNotifySide(Value)
    end,
})

MenuGroup:AddDropdown("DPIDropdown", {
    Values = { "50%", "75%", "100%", "125%", "150%", "175%", "200%" },
    Default = "100%",
    Text = "DPI Scale",
    Callback = function(Value)
        Value = Value:gsub("%%", "")
        local DPI = tonumber(Value)
        Library:SetDPIScale(DPI)
    end,
})

MenuGroup:AddDivider()

MenuGroup:AddLabel("Menu bind")
    :AddKeyPicker("MenuKeybind", { 
        Default = "RightShift", 
        NoUI = true, 
        Text = "Menu keybind" 
    })

MenuGroup:AddButton("Unload", function()
    Library:Unload()
end)

Library.ToggleKeybind = Library.Options.MenuKeybind

ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)

SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ "MenuKeybind" })

ThemeManager:SetFolder("FATALITY")
SaveManager:SetFolder("FATALITY")

SaveManager:BuildConfigSection(Tabs.Settings)
ThemeManager:ApplyToTab(Tabs.Settings)

SaveManager:LoadAutoloadConfig()

Library.Options.CrosshairText:OnChanged(function()
    if Library.Toggles.CrosshairToggle.Value then
        createCrosshair()
    end
end)

Library.Toggles.CrosshairToggle:SetValue(false)

Library:OnUnload(function()
    destroyCrosshair()
end)
