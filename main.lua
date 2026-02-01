getgenv().gethui = function() return game.CoreGui end

-- Orion Lib 読み込み
local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/jensonhirst/Orion/main/source')))()

-- [[ ウィンドウ設定 ]]
local Window = OrionLib:MakeWindow({
    Name = "Xenouzu Hub", 
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

-- グローバル変数として定義（死んでも値を保持するため）
_G.activeAntiGrab = _G.activeAntiGrab or false

AntiTab:AddToggle({
    Name = "Enable Anti-Grab Mode",
    Default = _G.activeAntiGrab,
    Callback = function(Value)
        _G.activeAntiGrab = Value
    end    
})

-- [[ ループ処理：死んでも止まらないように設計 ]]
task.spawn(function()
    while true do 
        task.wait(0.1) -- 負荷を少し抑えるために 0.1秒待機
        
        if _G.activeAntiGrab then
            local lp = game.Players.LocalPlayer
            -- キャラクターが読み込まれるのを待つ
            local char = lp.Character or lp.CharacterAdded:Wait()
            local hrp = char:FindFirstChild("HumanoidRootPart")
            
            -- 1. Dexで見た「IsHeld」のチェックを強制的に外す
            if lp:FindFirstChild("IsHeld") and lp.IsHeld.Value == true then
                lp.IsHeld.Value = false
            end

            -- 2. 物理的な固まり（Anchored）を即時解除
            if hrp and hrp.Anchored then
                hrp.Anchored = false
            end

            -- 3. 周囲のプレイヤーへの自動カウンター（Blobman対策）
            -- ここは自分のキャラが生きている時だけ実行
            if hrp then
                for _, p in pairs(game.Players:GetPlayers()) do
                    if p ~= lp and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                        local enemyHrp = p.Character.HumanoidRootPart
                        local dist = (enemyHrp.Position - hrp.Position).Magnitude
                        
                        if dist < 25 then 
                            -- 相手をラグドール化
                            local re = game.ReplicatedStorage:FindFirstChild("PlayerEvents")
                            if re and re:FindFirstChild("RagdollPlayer") then
                                re.RagdollPlayer:FireServer(p.Character)
                            end
                        end
                    end
                end
            end
            
            -- 4. ステータス正常化（あがき・タイマー）
            if lp:FindFirstChild("Struggled") then lp.Struggled.Value = true end
            if lp:FindFirstChild("HeldTimer") then lp.HeldTimer.Value = 0 end
            
            -- 5. サーバーへの脱出信号（イベントが存在するか確認してから）
            local ce = game.ReplicatedStorage:FindFirstChild("CharacterEvents")
            if ce and ce:FindFirstChild("Struggle") then
                ce.Struggle:FireServer()
            end
        end
    end
end)

--==============================
-- タブ：究極オーラ (Ultimate)
--==============================
local UltimateTab = Window:MakeTab({ Name = "究極オーラ", Icon = "rbxassetid://6031064398" })

_G.UltimateAuraEnabled = false
_G.LevitateKillAura = false
local ultRange = 25
local ultPower = 50000

-- [[ 1. 究極ハイブリッドオーラ（元のコード維持） ]]
UltimateTab:AddToggle({
    Name = "究極ハイブリッドオーラ有効化",
    Default = false,
    Callback = function(Value)
        _G.UltimateAuraEnabled = Value
    end    
})

-- [[ 2. 空中固定 Kill Aura（新しく追加） ]]
UltimateTab:AddToggle({
    Name = "空中固定 Kill Aura",
    Default = false,
    Callback = function(Value)
        _G.LevitateKillAura = Value
        if Value then
            task.spawn(function()
                while _G.LevitateKillAura do
                    task.wait(0.1)
                    local lp = game.Players.LocalPlayer
                    local rs = game:GetService("ReplicatedStorage")
                    local combatEvent = rs:FindFirstChild("Events") and rs.Events:FindFirstChild("Combat") or rs:FindFirstChild("HitEvent")
                    local SetNetworkOwner = rs:FindFirstChild("GrabEvents") and rs.GrabEvents:FindFirstChild("SetNetworkOwner")

                    if lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then
                        for _, player in ipairs(game.Players:GetPlayers()) do
                            if player ~= lp and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                                local targetHRP = player.Character.HumanoidRootPart
                                local distance = (targetHRP.Position - lp.Character.HumanoidRootPart.Position).Magnitude

                                if distance <= 25 and player.Character.Humanoid.Health > 0 then
                                    pcall(function()
                                        if SetNetworkOwner then SetNetworkOwner:FireServer(targetHRP, targetHRP.CFrame) end
                                        local bv = Instance.new("BodyVelocity")
                                        bv.MaxForce = Vector3.new(1e9, 1e9, 1e9)
                                        bv.Velocity = Vector3.new(0, 0, 0)
                                        bv.Parent = targetHRP
                                        targetHRP.CFrame = targetHRP.CFrame * CFrame.new(0, 0.5, 0)
                                        if combatEvent then combatEvent:FireServer(player.Character, "Punch") end
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

-- [[ 3. 設定用スライダー ]]
UltimateTab:AddSlider({
    Name = "オーラ射程", Min = 5, Max = 50, Default = 25,
    Callback = function(Value) ultRange = Value end
})

-- [[ 究極ハイブリッドオーラ用ロジック（いじってません） ]]
task.spawn(function()
    while true do
        task.wait(0.1)
        if _G.UltimateAuraEnabled then
            local lp = game.Players.LocalPlayer
            if not lp.Character or not lp.Character:FindFirstChild("HumanoidRootPart") then continue end
            local myRoot = lp.Character.HumanoidRootPart
            local rs = game:GetService("ReplicatedStorage")
            local events = {
                SetNetworkOwner = rs:FindFirstChild("GrabEvents") and rs.GrabEvents:FindFirstChild("SetNetworkOwner"),
                Combat = (rs:FindFirstChild("Events") and rs.Events:FindFirstChild("Combat")) or rs:FindFirstChild("HitEvent"),
                Ragdoll = rs:FindFirstChild("PlayerEvents") and rs.PlayerEvents:FindFirstChild("RagdollPlayer"),
                GrabLine = rs:FindFirstChild("GrabEvents") and rs.GrabEvents:FindFirstChild("CreateGrabLine")
            }
            for _, p in ipairs(game.Players:GetPlayers()) do
                if p ~= lp and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character:FindFirstChild("Humanoid") then
                    local targetRoot = p.Character.HumanoidRootPart
                    local targetHum = p.Character.Humanoid
                    local dist = (targetRoot.Position - myRoot.Position).Magnitude
                    if dist <= ultRange and targetHum.Health > 0 then
                        pcall(function()
                            if events.Combat then events.Combat:FireServer(p.Character, "Punch") end
                            if events.SetNetworkOwner then events.SetNetworkOwner:FireServer(targetRoot, targetRoot.CFrame) end
                            if events.GrabLine then events.GrabLine:FireServer(targetRoot) end
                            if events.Ragdoll then events.Ragdoll:FireServer(p.Character) end
                            targetRoot.Velocity = Vector3.new(ultPower, ultPower, ultPower)
                            targetRoot.RotVelocity = Vector3.new(ultPower, ultPower, ultPower)
                            local bv = Instance.new("BodyVelocity")
                            bv.MaxForce = Vector3.new(1e9, 1e9, 1e9)
                            bv.Velocity = Vector3.new(0, ultPower/2, 0)
                            bv.Parent = targetRoot
                            game:GetService("Debris"):AddItem(bv, 0.1)
                        end)
                    end
                end
            end
        end
    end
end)

--==============================
-- 完全キル特化：地底奈落オーラ
--==============================
_G.AbyssKillAuraEnabled = false
local abyssPower = -100000 -- 地面の下へ叩き落とす負の力

UltimateTab:AddToggle({
    Name = "地底奈落 Kill Aura (完全抹殺)",
    Default = false,
    Callback = function(Value)
        _G.AbyssKillAuraEnabled = Value
        if Value then
            task.spawn(function()
                while _G.AbyssKillAuraEnabled do
                    task.wait(0.1)
                    local lp = game.Players.LocalPlayer
                    local rs = game:GetService("ReplicatedStorage")
                    
                    -- 攻撃イベントと所有権イベント
                    local combatEvent = rs:FindFirstChild("Events") and rs.Events:FindFirstChild("Combat") or rs:FindFirstChild("HitEvent")
                    local SetNetworkOwner = rs:FindFirstChild("GrabEvents") and rs.GrabEvents:FindFirstChild("SetNetworkOwner")

                    if lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then
                        for _, player in ipairs(game.Players:GetPlayers()) do
                            if player ~= lp and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                                local targetHRP = player.Character.HumanoidRootPart
                                local distance = (targetHRP.Position - lp.Character.HumanoidRootPart.Position).Magnitude

                                -- 射程内（前のスライダーの値 ultRange を流用）かつ生存している場合
                                if distance <= ultRange and player.Character.Humanoid.Health > 0 then
                                    pcall(function()
                                        -- 1. 相手の物理演算を奪う
                                        if SetNetworkOwner then 
                                            SetNetworkOwner:FireServer(targetHRP, targetHRP.CFrame) 
                                        end

                                        -- 2. ダメージを入れつつ、ラグドール化があれば実行
                                        if combatEvent then
                                            combatEvent:FireServer(player.Character, "Punch")
                                        end
                                        if rs:FindFirstChild("PlayerEvents") and rs.PlayerEvents:FindFirstChild("RagdollPlayer") then
                                            rs.PlayerEvents.RagdollPlayer:FireServer(player.Character)
                                        end

                                        -- 3. 地面の下（Y軸マイナス方向）へ超高速射出
                                        -- VelocityとCFrameの両方で地面の下へ押し込みます
                                        targetHRP.Velocity = Vector3.new(0, abyssPower, 0)
                                        targetHRP.CFrame = targetHRP.CFrame * CFrame.new(0, -10, 0)

                                        -- 4. 浮き上がりを防止する強力な下向きの力
                                        local bv = Instance.new("BodyVelocity")
                                        bv.MaxForce = Vector3.new(1e9, 1e9, 1e9)
                                        bv.Velocity = Vector3.new(0, abyssPower, 0)
                                        bv.Parent = targetHRP
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

--==============================
-- 初期化
--==============================
OrionLib:Init()
