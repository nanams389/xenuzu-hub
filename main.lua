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

-- ここが超重要！これがないと表示されないぜ！
OrionLib:Init()
