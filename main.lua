getgenv().gethui = function() return game.CoreGui end

-- Orion Lib 読み込み
local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/jensonhirst/Orion/main/source')))()

-- [[ ウィンドウ設定 ]]
local Window = OrionLib:MakeWindow({
    Name = "Xenouzu Hub | Blitz Edition", 
    HidePremium = false, 
    SaveConfig = true, 
    ConfigFolder = "XenouzuHub",
    IntroEnabled = true,
    IntroText = "Xenouzu Hub 起動中..."
})

--==============================
-- タブ：プレイヤー設定
--==============================
local MainTab = Window:MakeTab({ Name = "プレイヤー設定", Icon = "rbxassetid://4483345998" })
MainTab:AddSection({ Name = "基本ステータス" })

MainTab:AddSlider({
    Name = "歩行速度", Min = 16, Max = 500, Default = 16, Increment = 1,
    Callback = function(v) 
        if game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") then
            game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = v 
        end
    end    
})

MainTab:AddSlider({
    Name = "ジャンプ力", Min = 50, Max = 1000, Default = 50, Increment = 1,
    Callback = function(v) 
        if game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") then
            game.Players.LocalPlayer.Character.Humanoid.JumpPower = v 
        end
    end    
})

MainTab:AddToggle({ Name = "無限ジャンプ", Default = false, Callback = function(v) _G.InfJump = v end })
game:GetService("UserInputService").JumpRequest:Connect(function()
    if _G.InfJump then
        local hum = game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum:ChangeState("Jumping") end
    end
end)

--==============================
-- タブ：移動ハック
--==============================
local StealthTab = Window:MakeTab({ Name = "移動ハック", Icon = "rbxassetid://4483345998" })
StealthTab:AddToggle({ Name = "壁抜け (Noclip)", Default = false, Callback = function(v) _G.Noclip = v end })
game:GetService("RunService").Stepped:Connect(function()
    if _G.Noclip and game.Players.LocalPlayer.Character then
        for _, v in pairs(game.Players.LocalPlayer.Character:GetDescendants()) do
            if v:IsA("BasePart") then v.CanCollide = false end
        end
    end
end)

--==============================
-- タブ：攻撃オーラ (Aura)
--==============================
local AuraTab = Window:MakeTab({ Name = "攻撃オーラ", Icon = "rbxassetid://6031064398" })
_G.isConstantAuraEnabled = false
local kickAuraEnabled = false

AuraTab:AddToggle({
    Name = "Flingオーラを有効化", Default = false,
    Callback = function(Value)
        _G.isConstantAuraEnabled = Value
        if Value then
            task.spawn(function()
                while _G.isConstantAuraEnabled do
                    task.wait(0.05)
                    local lp = game.Players.LocalPlayer
                    local rs = game:GetService("ReplicatedStorage")
                    local SetNetworkOwner = rs:FindFirstChild("GrabEvents") and rs.GrabEvents:FindFirstChild("SetNetworkOwner")
                    if lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then
                        for _, player in ipairs(game.Players:GetPlayers()) do
                            if player ~= lp and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                                local targetHRP = player.Character.HumanoidRootPart
                                if (targetHRP.Position - lp.Character.HumanoidRootPart.Position).Magnitude <= 25 then
                                    if SetNetworkOwner then SetNetworkOwner:FireServer(targetHRP, targetHRP.CFrame) end
                                    local bv = Instance.new("BodyVelocity", targetHRP)
                                    bv.MaxForce = Vector3.new(1e9, 1e9, 1e9)
                                    bv.Velocity = Vector3.new(0, 50, 0)
                                    game:GetService("Debris"):AddItem(bv, 0.15)
                                end
                            end
                        end
                    end
                end
            end)
        end
    end    
})

AuraTab:AddToggle({
    Name = "Kill Aura (ダメージ特化)",
    Default = false,
    Callback = function(Value)
        _G.KillAuraEnabled = Value
        if Value then
            task.spawn(function()
                while _G.KillAuraEnabled do
                    task.wait(0.1) -- 攻撃の間隔
                    local lp = game.Players.LocalPlayer
                    -- ゲームごとに異なるリモートイベントを探す（例：Combat, Hit, Damage）
                    local replicatedStorage = game:GetService("ReplicatedStorage")
                    local combatEvent = replicatedStorage:FindFirstChild("Events") and replicatedStorage.Events:FindFirstChild("Combat") 
                                     or replicatedStorage:FindFirstChild("HitEvent")

                    if lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then
                        for _, player in ipairs(game.Players:GetPlayers()) do
                            if player ~= lp and player.Character and player.Character:FindFirstChild("Humanoid") and player.Character:FindFirstChild("HumanoidRootPart") then
                                local targetHRP = player.Character.HumanoidRootPart
                                local distance = (targetHRP.Position - lp.Character.HumanoidRootPart.Position).Magnitude
                                
                                -- 射程範囲内（例：20スタッド）なら攻撃
                                if distance <= 20 and player.Character.Humanoid.Health > 0 then
                                    pcall(function()
                                        -- 1. ダメージイベントを連打（イベント名や引数はゲームによって要調整）
                                        if combatEvent then
                                            -- 引数はゲームによって [相手のキャラ, 攻撃種類] などが一般的
                                            combatEvent:FireServer(player.Character, "Punch") 
                                        end

                                        -- 2. 強制的に相手の所有権をバグらせる（Flingオーラのロジック流用）
                                        local rs = game:GetService("ReplicatedStorage")
                                        local SetNetworkOwner = rs:FindFirstChild("GrabEvents") and rs.GrabEvents:FindFirstChild("SetNetworkOwner")
                                        if SetNetworkOwner then
                                            SetNetworkOwner:FireServer(targetHRP, targetHRP.CFrame)
                                        end
                                        
                                        -- 3. 相手を少し浮かせて反撃を防ぐ
                                        local bv = Instance.new("BodyVelocity", targetHRP)
                                        bv.MaxForce = Vector3.new(1e9, 1e9, 1e9)
                                        bv.Velocity = Vector3.new(0, -10, 0) -- 地面に叩きつける
                                        game:GetService("Debris"):AddItem(bv, 0.1)
                                    end)
                                end
                            end
                        end
                    end
                end
            end)
        end
    end    
})

-- [[ Void Aura タブ ]]
local VoidTab = Window:MakeTab({
    Name = "Void Aura",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

local autoVoidEnabled = false
local voidPower = 20000 -- 消し去るための超高速設定
local voidRange = 25

VoidTab:AddSection({
    Name = "Auto-Fling Settings"
})

VoidTab:AddToggle({
    Name = "Enable Auto-Void (Near Players)",
    Default = false,
    Callback = function(Value)
        autoVoidEnabled = Value
    end    
})

VoidTab:AddSlider({
    Name = "Void Range",
    Min = 5,
    Max = 50,
    Default = 25,
    Callback = function(Value)
        voidRange = Value
    end    
})

VoidTab:AddSlider({
    Name = "Ejection Power",
    Min = 5000,
    Max = 100000,
    Default = 20000,
    Callback = function(Value)
        voidPower = Value
    end    
})

-- [[ 自動射出ロジック ]]
task.spawn(function()
    while task.wait(0.1) do
        if autoVoidEnabled then
            local lp = game.Players.LocalPlayer
            if not lp.Character or not lp.Character:FindFirstChild("HumanoidRootPart") then continue end
            
            local myRoot = lp.Character.HumanoidRootPart

            for _, p in pairs(game.Players:GetPlayers()) do
                if p ~= lp and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                    local targetRoot = p.Character.HumanoidRootPart
                    local dist = (targetRoot.Position - myRoot.Position).Magnitude

                    if dist <= voidRange then
                        -- 1. 相手を強制ラグドール化（物理演算を有効にする）
                        game.ReplicatedStorage.PlayerEvents.RagdollPlayer:FireServer(p.Character)
                        
                        -- 2. 掴みイベントを「掴まずに」サーバーへ送り、所有権に干渉
                        game.ReplicatedStorage.GrabEvents.CreateGrabLine:FireServer(targetRoot)
                        
                        -- 3. 速度ベクトルを全方向に異常な値で上書き（Blackhole効果）
                        -- これで近くに来たプレイヤーが自動的に射出されます
                        targetRoot.Velocity = Vector3.new(voidPower, voidPower, voidPower)
                        targetRoot.RotVelocity = Vector3.new(voidPower, voidPower, voidPower)
                        
                        -- 4. サーバー側へのダメ押し
                        game.ReplicatedStorage.CharacterEvents.Struggle:FireServer()
                    end
                end
            end
        end
    end
end)

-- [[ Anti-Grab Pro タブ ]]
local AntiTab = Window:MakeTab({
    Name = "Anti-Grab Pro",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

local activeAntiGrab = false

AntiTab:AddToggle({
    Name = "Enable Anti-Grab Mode",
    Default = false,
    Callback = function(Value)
        activeAntiGrab = Value
    end    
})

-- [[ Dexで見た仕組みを直接叩くロジック ]]
task.spawn(function()
    while task.wait() do 
        if activeAntiGrab then
            local lp = game.Players.LocalPlayer
            local char = lp.Character
            
            -- 1. Dexで見た「IsHeld」のチェックを強制的に外す
            if lp:FindFirstChild("IsHeld") and lp.IsHeld.Value == true then
                lp.IsHeld.Value = false
            end

            -- 2. 物理的な固まり（Anchored）を即時解除
            if char and char:FindFirstChild("HumanoidRootPart") then
                if char.HumanoidRootPart.Anchored then
                    char.HumanoidRootPart.Anchored = false
                end
            end

            -- 3. 周囲のプレイヤーへの自動カウンター（Blobman対策）
            -- 掴まれている判定の時だけ、周囲の奴を転ばせて強制ドロップさせる
            if lp:FindFirstChild("IsHeld") and lp.IsHeld.Value == false then
                for _, p in pairs(game.Players:GetPlayers()) do
                    if p ~= lp and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                        local dist = (p.Character.HumanoidRootPart.Position - char.HumanoidRootPart.Position).Magnitude
                        if dist < 25 then 
                            -- 相手をラグドール化（Dexで見たPlayerEventsを利用）
                            game.ReplicatedStorage.PlayerEvents.RagdollPlayer:FireServer(p.Character)
                        end
                    end
                end
            end
            
            -- 4. ステータス正常化（あがき・タイマー）
            if lp:FindFirstChild("Struggled") then lp.Struggled.Value = true end
            if lp:FindFirstChild("HeldTimer") then lp.HeldTimer.Value = 0 end
            
            -- 5. サーバーへの脱出信号
            game.ReplicatedStorage.CharacterEvents.Struggle:FireServer()
        end
    end
end)

-- [[ Kill All 設定 ]]
local Players = game:GetService("Players")
local lp = Players.LocalPlayer
local killAllRunning = false

-- [[ Kill All タブ生成 ]]
local KillTab = Window:MakeTab({
    Name = "Kill All Pro",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

KillTab:AddToggle({
    Name = "Ultimate Kill All (TP Mode)",
    Default = false,
    Callback = function(Value)
        killAllRunning = Value
    end    
})

-- [[ 最強奈落送りロジック ]]
task.spawn(function()
    while task.wait(0.1) do
        if killAllRunning then
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= lp and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                    local tRoot = p.Character.HumanoidRootPart
                    local tChar = p.Character
                    
                    -- 1. 自分の座標を相手の真上にテレポート（同期を強める）
                    lp.Character.HumanoidRootPart.CFrame = tRoot.CFrame * CFrame.new(0, 5, 0)
                    
                    -- 2. アンチチート(StopVelocity等)を無効化するコンボ
                    pcall(function()
                        -- 所有権を奪い、ラグドール化して抵抗不能にする
                        game.ReplicatedStorage.GrabEvents.SetNetworkOwner:FireServer(tRoot)
                        game.ReplicatedStorage.PlayerEvents.RagdollPlayer:FireServer(tChar)
                    end)

                    -- 3. 相手をマップ外（奈落）に直接テレポート上書き
                    -- これを連打することで、相手のクライアントが戻そうとする力を封じます
                    for i = 1, 5 do
                        tRoot.CFrame = CFrame.new(0, -50000, 0)
                        tRoot.Velocity = Vector3.new(0, -100000, 0) -- 超高速で奈落へ
                        task.wait()
                    end
                    
                    -- 4. 最後にStruggleを送って判定を確定させる
                    game.ReplicatedStorage.CharacterEvents.Struggle:FireServer()
                end
            end
        end
    end
end)
--==============================
-- 初期化
--==============================
OrionLib:Init()
