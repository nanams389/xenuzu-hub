getgenv().gethui = function() return game.CoreGui end

-- Orion Lib 読み込み
local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/jensonhirst/Orion/main/source')))()
local Window = OrionLib:MakeWindow({Name = "Xenouzu Hub | FTAP", HidePremium = false, SaveConfig = true, ConfigFolder = "XenouzuHub"})

-- [[ MAIN TAB ]]
local MainTab = Window:MakeTab({
    Name = "ホーム",
    Icon = "rbxassetid://4483345998"
})

MainTab:AddSlider({
    Name = "Walk Speed",
    Min = 16, Max = 500, Default = 16, Increment = 1,
    Callback = function(v) 
        if game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") then
            game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = v 
        end
    end    
})

MainTab:AddSlider({
    Name = "Jump Power",
    Min = 50, Max = 1000, Default = 50, Increment = 1,
    Callback = function(v) 
        if game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") then
            game.Players.LocalPlayer.Character.Humanoid.JumpPower = v 
        end
    end    
})

_G.InfJump = false
game:GetService("UserInputService").JumpRequest:Connect(function()
    if _G.InfJump then
        local hum = game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum:ChangeState("Jumping") end
    end
end)

MainTab:AddToggle({
    Name = "Infinite Jump",
    Default = false,
    Callback = function(v) _G.InfJump = v end    
})

-- [[ STEALTH TAB ]]
local StealthTab = Window:MakeTab({
    Name = "空飛び＆壁貫通",
    Icon = "rbxassetid://4483345998"
})

_G.Noclip = false
game:GetService("RunService").Stepped:Connect(function()
    if _G.Noclip and game.Players.LocalPlayer.Character then
        for _, v in pairs(game.Players.LocalPlayer.Character:GetDescendants()) do
            if v:IsA("BasePart") then v.CanCollide = false end
        end
    end
end)

StealthTab:AddToggle({
    Name = "Noclip",
    Default = false,
    Callback = function(v) _G.Noclip = v end    
})

_G.Fly = false
StealthTab:AddToggle({
    Name = "Fly (Speed set by WalkSpeed)",
    Default = false,
    Callback = function(v)
        _G.Fly = v
        local lp = game.Players.LocalPlayer
        local char = lp.Character or lp.CharacterAdded:Wait()
        local root = char:WaitForChild("HumanoidRootPart")
        
        if _G.Fly then
            local bg = Instance.new("BodyGyro", root)
            bg.P = 9e4
            bg.maxTorque = Vector3.new(9e9, 9e9, 9e9)
            bg.cframe = root.CFrame
            local bv = Instance.new("BodyVelocity", root)
            bv.velocity = Vector3.new(0,0.1,0)
            bv.maxForce = Vector3.new(9e9, 9e9, 9e9)
            
            task.spawn(function()
                while _G.Fly do
                    task.wait()
                    if char:FindFirstChild("Humanoid") then
                        char.Humanoid.PlatformStand = true
                        bv.velocity = (workspace.CurrentCamera.CFrame.LookVector * (char.Humanoid.WalkSpeed * 1.5))
                        bg.cframe = workspace.CurrentCamera.CFrame
                    end
                end
                bg:Destroy()
                bv:Destroy()
                if char:FindFirstChild("Humanoid") then char.Humanoid.PlatformStand = false end
            end)
        end
    end    
})

-- [[ VISUAL TAB ]]
local VisualTab = Window:MakeTab({
    Name = "Visuals",
    Icon = "rbxassetid://4483345998"
})

VisualTab:AddButton({
    Name = "Enable Player ESP",
    Callback = function()
        for _, p in pairs(game.Players:GetPlayers()) do
            if p ~= game.Players.LocalPlayer and p.Character then
                local h = p.Character:FindFirstChild("Highlight") or Instance.new("Highlight", p.Character)
                h.FillColor = Color3.fromRGB(255, 0, 0)
            end
        end
    end    
})

-- [[ AURA TAB ]]
local AuraTab = Window:MakeTab({
    Name = "Aura",
    Icon = "rbxassetid://4483345998"
})

AuraTab:AddSection({
    Name = "常時発動 Fling 機能"
})

-- オーラ用の設定変数
local FLING_VELOCITY = 50 
local AURA_RANGE = 25 
_G.isConstantAuraEnabled = false

-- Fling実行関数
local function doUpFling(targetHRP)
    local SetNetworkOwner = game:GetService("ReplicatedStorage"):WaitForChild("GrabEvents"):WaitForChild("SetNetworkOwner")
    if not targetHRP or not SetNetworkOwner then return end
    pcall(function() SetNetworkOwner:FireServer(targetHRP, targetHRP.CFrame) end)
    
    local bv = Instance.new("BodyVelocity")
    bv.Name = "ConstantAuraFling"
    bv.Parent = targetHRP
    bv.MaxForce = Vector3.new(1e9, 1e9, 1e9)
    bv.Velocity = Vector3.new(0, FLING_VELOCITY, 0)
    game:GetService("Debris"):AddItem(bv, 0.15) 
end

AuraTab:AddToggle({
    Name = "Fling Aura (上50威力)",
    Default = false,
    Callback = function(Value)
        _G.isConstantAuraEnabled = Value
        if Value then
            task.spawn(function()
                while _G.isConstantAuraEnabled do
                    task.wait(0.05)
                    local lp = game.Players.LocalPlayer
                    local char = lp.Character
                    if char and char:FindFirstChild("HumanoidRootPart") then
                        for _, player in ipairs(game.Players:GetPlayers()) do
                            if player ~= lp and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                                local targetHRP = player.Character.HumanoidRootPart
                                if (targetHRP.Position - char.HumanoidRootPart.Position).Magnitude <= AURA_RANGE then
                                    doUpFling(targetHRP)
                                end
                            end
                        end
                    end
                end
            end)
        end
    end    
})

-- ここが超重要！これがないと表示されないぜ！
OrionLib:Init()
