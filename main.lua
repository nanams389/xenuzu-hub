-- Orion Lib 読み込み (ミラーサイトを使用して安定性を向上)
local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/jensonhirst/Orion/main/source')))()
local Window = OrionLib:MakeWindow({Name = "Xenouzu Hub | FTAP", HidePremium = false, SaveConfig = true, ConfigFolder = "XenouzuHub"})

-- [[ MAIN TAB ]]
local MainTab = Window:MakeTab({
    Name = "Movement",
    Icon = "rbxassetid://4483345998"
})

-- 歩き調整
MainTab:AddSlider({
    Name = "Walk Speed",
    Min = 16, Max = 500, Default = 16, Increment = 1,
    Callback = function(v) game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = v end    
})

-- ジャンプ力調整
MainTab:AddSlider({
    Name = "Jump Power",
    Min = 50, Max = 1000, Default = 50, Increment = 1,
    Callback = function(v) game.Players.LocalPlayer.Character.Humanoid.JumpPower = v end    
})

-- 無限ジャンプ
_G.InfJump = false
game:GetService("UserInputService").JumpRequest:Connect(function()
    if _G.InfJump then
        game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
    end
end)

MainTab:AddToggle({
    Name = "Infinite Jump",
    Default = false,
    Callback = function(v) _G.InfJump = v end    
})

-- [[ STEALTH TAB ]]
local StealthTab = Window:MakeTab({
    Name = "Stealth & Clip",
    Icon = "rbxassetid://4483345998"
})

-- Noclip (壁抜け)
_G.Noclip = false
game:GetService("RunService").Stepped:Connect(function()
    if _G.Noclip then
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

-- Fly (Eキーでトグル)
_G.Fly = false
StealthTab:AddToggle({
    Name = "Fly (Press E to Toggle)",
    Default = false,
    Callback = function(v)
        _G.Fly = v
        local lp = game.Players.LocalPlayer
        local mouse = lp:GetMouse()
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
                    lp.Character.Humanoid.PlatformStand = true
                    bv.velocity = (workspace.CurrentCamera.CFrame.LookVector * (lp.Character.Humanoid.WalkSpeed * 1.5))
                    bg.cframe = workspace.CurrentCamera.CFrame
                end
                bg:Destroy()
                bv:Destroy()
                lp.Character.Humanoid.PlatformStand = false
            end)
        end
    end    
})

-- [[ VISUAL TAB ]]
local VisualTab = Window:MakeTab({
    Name = "Visuals",
    Icon = "rbxassetid://4483345998"
})

-- ESP
VisualTab:AddButton({
    Name = "Enable Player ESP",
    Callback = function()
        for _, p in pairs(game.Players:GetPlayers()) do
            if p ~= game.Players.LocalPlayer and p.Character then
                local h = p.Character:FindFirstChild("Highlight") or Instance.new("Highlight", p.Character)
                h.FillColor = Color3.fromRGB(255, 0, 0)
                h.OutlineColor = Color3.fromRGB(255, 255, 255)
            end
        end
    end    
})

OrionLib:Init()

-- [[ 既存の変数の下に追加してくれ ]]
local blobalter = 1

-- 反撃用のループ管理変数
_G.AntiFling = false
_G.AutoBlobGrab = false

-- [[ ANTI-GRAB TAB ]]
local GrabTab = Window:MakeTab({
    Name = "Anti-Grab / Blob",
    Icon = "rbxassetid://4483345998"
})

-- 1. Anti Fling (掴まれたら相手を吹き飛ばす)
GrabTab:AddToggle({
    Name = "Anti Fling (掴み即反撃)",
    Default = false,
    Callback = function(v)
        _G.AntiFling = v
        if v then
            task.spawn(function()
                while _G.AntiFling do
                    task.wait(0.01)
                    local char = game.Players.LocalPlayer.Character
                    if char and char:FindFirstChild("Head") then
                        -- Headの中にあるPartOwnerで自分を掴んでいる奴を特定
                        local partOwner = char.Head:FindFirstChild("PartOwner")
                        if partOwner and partOwner.Value ~= "" then
                            local attacker = game.Players:FindFirstChild(partOwner.Value)
                            if attacker and attacker.Character and attacker.Character:FindFirstChild("HumanoidRootPart") then
                                -- 抵抗イベントを送信
                                pcall(function() game:GetService("ReplicatedStorage").CharacterEvents.Struggle:FireServer() end)
                                
                                local targetHRP = attacker.Character.HumanoidRootPart
                                -- ネットワークオーナーを奪取して吹き飛ばす
                                pcall(function() game:GetService("ReplicatedStorage").GrabEvents.SetNetworkOwner:FireServer(targetHRP, targetHRP.CFrame) end)
                                
                                local bv = Instance.new("BodyVelocity")
                                bv.Parent = targetHRP
                                bv.MaxForce = Vector3.new(1e9, 1e9, 1e9)
                                bv.Velocity = Vector3.new(100000000, 0, 0) -- 右方向に1億
                                game:GetService("Debris"):AddItem(bv, 0.3)
                            end
                        end
                    end
                end
            end)
        end
    end    
})

-- 2. Blobman 掴み (近くのBlobmanに全員を掴ませる)
GrabTab:AddButton({
    Name = "Blobman: Grab All Players",
    Callback = function()
        -- サーバー内のBlobmanを検索
        for _, blob in pairs(workspace:GetChildren()) do
            if blob.Name == "Blobman" then
                for _, player in pairs(game.Players:GetPlayers()) do
                    if player ~= game.Players.LocalPlayer and player.Character then
                        -- BlobmanのGrabイベントを叩く
                        local detector = (blobalter == 1) and blob:FindFirstChild("LeftDetector") or blob:FindFirstChild("RightDetector")
                        local weld = (blobalter == 1) and detector:FindFirstChild("LeftWeld") or detector:FindFirstChild("RightWeld")
                        
                        local args = {
                            [1] = detector,
                            [2] = player.Character.HumanoidRootPart,
                            [3] = weld
                        }
                        blob:WaitForChild("BlobmanSeatAndOwnerScript"):WaitForChild("CreatureGrab"):FireServer(unpack(args))
                        blobalter = (blobalter == 1) and 2 or 1
                    end
                end
            end
        end
    end    
})

-- 3. 自動抵抗 (Struggle連打)
GrabTab:AddToggle({
    Name = "Auto Struggle (自動抵抗)",
    Default = false,
    Callback = function(v)
        _G.AutoStruggle = v
        task.spawn(function()
            while _G.AutoStruggle do
                game:GetService("ReplicatedStorage").CharacterEvents.Struggle:FireServer()
                task.wait(0.05)
            end
        end)
    end
})
