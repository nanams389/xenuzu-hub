getgenv().gethui = function() return game.CoreGui end

local rs = game:GetService("ReplicatedStorage")
local lp = game.Players.LocalPlayer

local function getBlobman()
    for _, v in ipairs(workspace.PlotItems:GetChildren()) do
        if v.Name == "Blobman" and v:FindFirstChild("Owner") and v.Owner.Value == lp.Name then return v end
    end
end

-- Orion Lib 読み込み
local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/jensonhirst/Orion/main/source')))()

-- [[ ウィンドウ設定 ]]
local Window = OrionLib:MakeWindow({
    Name = "nazer Hub", 
    HidePremium = false, 
    SaveConfig = true, 
    ConfigFolder = "nazer Hub",
    IntroEnabled = true,
    IntroText = "nazer Hub 起動中..."
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

-- グローバル変数として定義（値を確実に保持）
_G.activeAntiGrab = _G.activeAntiGrab or false

AntiTab:AddToggle({
    Name = "Enable Anti-Grab Mode",
    Default = _G.activeAntiGrab,
    Callback = function(Value)
        _G.activeAntiGrab = Value
    end    
})

-- [[ ループ処理：死んでも・リセットしても止まらない設計 ]]
task.spawn(function()
    while true do 
        task.wait(0.1)
        
        if _G.activeAntiGrab then
            local lp = game.Players.LocalPlayer
            
            -- 【重要】現在の最新のキャラクターを取得（存在しない場合は飛ばす）
            local char = lp.Character
            if not char then continue end
            
            local hrp = char:FindFirstChild("HumanoidRootPart")
            local rs = game:GetService("ReplicatedStorage")
            
            pcall(function()
                -- 1. Dexで見た「IsHeld」のチェックを強制的に外す
                if lp:FindFirstChild("IsHeld") and lp.IsHeld.Value == true then
                    lp.IsHeld.Value = false
                end

                -- 2. 物理的な固まり（Anchored）を即時解除
                if hrp and hrp.Anchored then
                    hrp.Anchored = false
                end

                -- 3. 周囲のプレイヤーへの自動カウンター
                if hrp then
                    for _, p in pairs(game.Players:GetPlayers()) do
                        if p ~= lp and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character:FindFirstChild("Humanoid") then
                            if p.Character.Humanoid.Health > 0 then
                                local enemyHrp = p.Character.HumanoidRootPart
                                local dist = (enemyHrp.Position - hrp.Position).Magnitude
                                
                                if dist < 25 then 
                                    local re = rs:FindFirstChild("PlayerEvents")
                                    if re and re:FindFirstChild("RagdollPlayer") then
                                        re.RagdollPlayer:FireServer(p.Character)
                                    end
                                end
                            end
                        end
                    end
                end
                
                -- 4. ステータス正常化
                if lp:FindFirstChild("Struggled") then lp.Struggled.Value = true end
                if lp:FindFirstChild("HeldTimer") then lp.HeldTimer.Value = 0 end
                
                -- 5. サーバーへの脱出信号
                local ce = rs:FindFirstChild("CharacterEvents")
                if ce and ce:FindFirstChild("Struggle") then
                    ce.Struggle:FireServer()
                end
            end)
        end
    end
end)

-- [[ Anti-Grab Pro タブ内のセクション ]]
local invulnerabilitySection = AntiTab:AddSection({ Name = "追加防御機能" })

-- 1. Anti-Void (落下防止：これで奈落ダイブして戻れるかチェック)
invulnerabilitySection:AddToggle({
    Name = "Anti-Void",
    Default = false,
    Callback = function(state)
        _G.AntiVoid = state
        if state then
            game:GetService("Workspace").FallenPartsDestroyHeight = -2000
            task.spawn(function()
                while _G.AntiVoid do
                    pcall(function()
                        local char = game.Players.LocalPlayer.Character
                        local hrp = char and char:FindFirstChild("HumanoidRootPart")
                        if hrp and hrp.Position.Y < -800 then
                            -- 強制的に上空（初期位置付近）へ戻す
                            hrp.CFrame = CFrame.new(0, 50, 0)
                        end
                    end)
                    task.wait(0.1)
                end
            end)
        else
            game:GetService("Workspace").FallenPartsDestroyHeight = -100
        end
    end
})

-- 2. Anti-Lag (ゲーム内の「Line」という名前のスクリプトを全部止める)
invulnerabilitySection:AddToggle({
    Name = "Anti-Lag",
    Default = false,
    Callback = function(state)
        for _, v in pairs(game:GetDescendants()) do
            if v:IsA("LocalScript") and (v.Name:lower():find("line") or v.Name:lower():find("lag")) then
                v.Disabled = state
            end
        end
    end
})

--============================================================
-- 強化版 Anti-Kick (既存の Anti-Lag の下に追加してくれ)
--============================================================
antikicktoggle = invulnerabilitySection:AddToggle({
    Name = "Anti-Kick",
    Default = false,
    Callback = function(antiKickEnabled)
        _G.AntiKick = antiKickEnabled
        if antiKickEnabled then
            while _G.AntiKick do
                GetKunai()
                task.wait()
            end
        end
    end,
    Save = true,
    Flag = "antikick_toggle"
})

--==============================
-- タブ：究極オーラ (Ultimate)
--==============================
local UltimateTab = Window:MakeTab({ Name = "究極オーラ", Icon = "rbxassetid://6031064398" })

_G.UltimateAuraEnabled = false
_G.LevitateKillAura = false
local ultRange = 25
local ultPower = 500000

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
-- 地底貫通・抹殺オーラ (Noclip Abyss)
--==============================
_G.AbyssKillAuraEnabled = false
local abyssDepth = -50 -- 1回で引きずり込む深さ
local fallSpeed = -5000 -- 落下加速

UltimateTab:AddToggle({
    Name = "地底貫通 Kill Aura (Noclip)",
    Default = false,
    Callback = function(Value)
        _G.AbyssKillAuraEnabled = Value
        if Value then
            task.spawn(function()
                while _G.AbyssKillAuraEnabled do
                    task.wait(0.05) -- 貫通を維持するため高速に回す
                    local lp = game.Players.LocalPlayer
                    local rs = game:GetService("ReplicatedStorage")
                    
                    local combatEvent = rs:FindFirstChild("Events") and rs.Events:FindFirstChild("Combat") or rs:FindFirstChild("HitEvent")
                    local SetNetworkOwner = rs:FindFirstChild("GrabEvents") and rs.GrabEvents:FindFirstChild("SetNetworkOwner")

                    if lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then
                        for _, player in ipairs(game.Players:GetPlayers()) do
                            if player ~= lp and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                                local targetHRP = player.Character.HumanoidRootPart
                                local dist = (targetHRP.Position - lp.Character.HumanoidRootPart.Position).Magnitude

                                if dist <= ultRange and player.Character.Humanoid.Health > 0 then
                                    pcall(function()
                                        -- 1. 所有権奪取（これをしないとCFrame操作が弾かれる）
                                        if SetNetworkOwner then 
                                            SetNetworkOwner:FireServer(targetHRP, targetHRP.CFrame) 
                                        end

                                        -- 2. 相手のすべてのパーツの衝突判定を「一瞬だけ」オフにする (Noclip効果)
                                        for _, part in ipairs(player.Character:GetChildren()) do
                                            if part:IsA("BasePart") then
                                                part.CanCollide = false
                                            end
                                        end

                                        -- 3. 【重要】地面の下へ強制移動 (Noclip貫通)
                                        -- 元の場所から垂直に abyssDepth 分だけ下に瞬間移動
                                        targetHRP.CFrame = targetHRP.CFrame * CFrame.new(0, abyssDepth, 0)

                                        -- 4. 速度も下向きに固定して復帰を阻止
                                        targetHRP.Velocity = Vector3.new(0, fallSpeed, 0)

                                        -- 5. ダメージ (Kill Aura)
                                        if combatEvent then
                                            combatEvent:FireServer(player.Character, "Punch")
                                        end
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
-- 全員自動巡回テレポート (Auto-Warp)
--==============================
_G.AutoWarpEnabled = false
local warpReturnPos = nil

UltimateTab:AddToggle({
    Name = "全員自動テレポート (Auto-Warp)",
    Default = false,
    Callback = function(Value)
        _G.AutoWarpEnabled = Value
        local lp = game.Players.LocalPlayer
        
        if Value then
            -- 1. 開始時の場所を記憶
            if lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then
                warpReturnPos = lp.Character.HumanoidRootPart.CFrame
            end

            task.spawn(function()
                while _G.AutoWarpEnabled do
                    task.wait(0.2) -- ワープの間隔（早すぎるとキック対策）
                    
                    if not (lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")) then continue end

                    for _, p in ipairs(game.Players:GetPlayers()) do
                        if not _G.AutoWarpEnabled then break end
                        
                        -- 自分以外で、生存しているプレイヤーを探す
                        if p ~= lp and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 then
                            
                            pcall(function()
                                -- 2. ターゲットの場所へワープ（頭上5スタッド）
                                lp.Character.HumanoidRootPart.CFrame = p.Character.HumanoidRootPart.CFrame * CFrame.new(0, 5, 0)
                                
                                -- 通知を表示
                                OrionLib:MakeNotification({
                                    Name = "テレポート中",
                                    Content = p.Name .. " の場所へ移動しました",
                                    Time = 0.5
                                })
                            end)
                            
                            task.wait(0.5) -- その場にとどまる時間（秒）
                        end
                    end
                end
            end)
        else
            -- 3. オフにした時に元の場所へ戻る
            if lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") and warpReturnPos then
                lp.Character.HumanoidRootPart.CFrame = warpReturnPos
                OrionLib:MakeNotification({
                    Name = "帰還",
                    Content = "元の場所に戻りました",
                    Time = 3
                })
            end
        end
    end    
})

--==============================
-- 爆速・全員テレポート (Turbo-Warp)
--==============================
_G.TurboWarpEnabled = false

UltimateTab:AddToggle({
    Name = "⚡ 爆速巡回 (Turbo-Warp)",
    Default = false,
    Callback = function(Value)
        _G.TurboWarpEnabled = Value
        local lp = game.Players.LocalPlayer
        
        if Value then
            task.spawn(function()
                while _G.TurboWarpEnabled do
                    -- 巡回の間隔を極限まで短縮 (0.1秒)
                    task.wait(0.1) 
                    
                    if not (lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")) then continue end

                    for _, p in ipairs(game.Players:GetPlayers()) do
                        if not _G.TurboWarpEnabled then break end
                        
                        -- 生存チェック
                        if p ~= lp and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 then
                            
                            pcall(function()
                                -- 通知を出すとラグくなるので、爆速モードでは通知をカット
                                -- 頭上3スタッドにワープ (より密着)
                                lp.Character.HumanoidRootPart.CFrame = p.Character.HumanoidRootPart.CFrame * CFrame.new(0, 3, 0)
                            end)
                            
                            -- 滞在時間を0.3秒（元の1/3以下）に変更
                            task.wait(0.3) 
                        end
                    end
                end
            end)
        else
            OrionLib:MakeNotification({
                Name = "Turbo-Warp",
                Content = "爆速巡回を停止しました",
                Time = 2
            })
        end
    end    
})

--==============================
-- 特定プレイヤー：追跡・転送システム
--==============================
local SelectedTarget = "" 
_G.StalkerEnabled = false
local stalkerOffset = CFrame.new(0, 5, 0)

-- プレイヤーリスト取得関数
local function GetPlayerList()
    local plist = {}
    for _, p in ipairs(game.Players:GetPlayers()) do
        if p ~= game.Players.LocalPlayer then
            table.insert(plist, p.Name)
        end
    end
    return plist
end

-- 1. ターゲット選択ドロップダウン
local TargetDropdown = UltimateTab:AddDropdown({
    Name = "ターゲットを選択",
    Default = "",
    Options = GetPlayerList(),
    Callback = function(Value)
        SelectedTarget = Value
        OrionLib:MakeNotification({
            Name = "ターゲットロック",
            Content = Value .. " を捕捉しました",
            Image = "rbxassetid://4483345998",
            Time = 2
        })
    end    
})

-- 2. 【テレポート】ボタン
UltimateTab:AddButton({
    Name = "ターゲットへ即座にテレポート",
    Callback = function()
        if SelectedTarget == "" then return end
        local lp = game.Players.LocalPlayer
        local targetPlayer = game.Players:FindFirstChild(SelectedTarget)
        
        if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
            lp.Character.HumanoidRootPart.CFrame = targetPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0, 3, 0)
        end
    end    
})

-- 3. 【ストーカー】トグル
UltimateTab:AddToggle({
    Name = "自動ストーカー (ONで貼り付き)",
    Default = false,
    Callback = function(Value)
        _G.StalkerEnabled = Value
        if Value then
            task.spawn(function()
                while _G.StalkerEnabled do
                    task.wait()
                    local lp = game.Players.LocalPlayer
                    local targetPlayer = game.Players:FindFirstChild(SelectedTarget)
                    
                    if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") and lp.Character:FindFirstChild("HumanoidRootPart") then
                        local myHRP = lp.Character.HumanoidRootPart
                        local tHRP = targetPlayer.Character.HumanoidRootPart
                        
                        -- 物理的な衝突や吹っ飛びを防止
                        myHRP.Velocity = Vector3.new(0,0,0)
                        myHRP.CFrame = tHRP.CFrame * stalkerOffset
                    end
                end
            end)
        end
    end    
})

-- 4. 追従高度調整スライダー
UltimateTab:AddSlider({
    Name = "ストーカー高度 (上下距離)",
    Min = -15, Max = 30, Default = 5,
    Color = Color3.fromRGB(255,255,255),
    Increment = 1,
    ValueName = "Studs",
    Callback = function(Value)
        stalkerOffset = CFrame.new(0, Value, 0)
    end    
})

-- 5. プレイヤーリスト更新ボタン
UltimateTab:AddButton({
    Name = "プレイヤーリストを更新",
    Callback = function()
        TargetDropdown:Refresh(GetPlayerList(), true)
    end    
})

-- [[ サービスと変数の定義 (コードが動くために必要) ]]
local playersService = game:GetService("Players")
local localPlayer = playersService.LocalPlayer

-- アイコン作成用関数 (これがないとエラーで動かない)
local function CreateIconOnPlayer(player)
    if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then return end
    local head = player.Character:FindFirstChild("Head")
    if not head then return end
    
    -- 既存のESPを削除
    if head:FindFirstChild("ESPIcon") then head.ESPIcon:Destroy() end
    
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "ESPIcon"
    billboard.Adornee = head
    billboard.Size = UDim2.new(2, 0, 2, 0)
    billboard.AlwaysOnTop = true
    billboard.ExtentsOffset = Vector3.new(0, 3, 0)
    billboard.Parent = head

    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(1, 0, 1, 0)
    label.Text = "👤" -- アイコン
    label.TextScaled = true
    label.TextColor3 = Color3.fromRGB(255, 0, 0)
    label.Parent = billboard
end

--==============================
-- タブ：ESP設定
--==============================
local ESPTab = Window:MakeTab({ Name = "ESP設定", Icon = "rbxassetid://4483345998" })
local ESP_Section2 = ESPTab:AddSection({ Name = "ビジュアル" })

_G.ESP_Icon = false

ESP_Section2:AddToggle({
    Name = "ESP (Icon)",
    Default = false,
    Callback = function(espIconEnabled)
        _G.ESP_Icon = espIconEnabled
        if espIconEnabled then
            local characterAddedConnections = {}
            
            local function disconnectCharacterAddedConnections()
                for _, conn in pairs(characterAddedConnections) do
                    if typeof(conn) == "RBXScriptConnection" then
                        conn:Disconnect()
                    end
                end
                table.clear(characterAddedConnections)
            end

            local function setupPlayerESP(player)
                if player ~= localPlayer then
                    if player.Character then CreateIconOnPlayer(player) end
                    local conn = player.CharacterAdded:Connect(function()
                        task.wait(0.5)
                        CreateIconOnPlayer(player)
                    end)
                    table.insert(characterAddedConnections, conn)
                end
            end

            -- 既存のプレイヤーに適用
            for _, p in pairs(playersService:GetPlayers()) do
                setupPlayerESP(p)
            end

            -- 新規プレイヤーに適用
            local playerAddedConn = playersService.PlayerAdded:Connect(setupPlayerESP)

            -- オフになるまで待機
            task.spawn(function()
                while _G.ESP_Icon do task.wait(0.5) end
                playerAddedConn:Disconnect()
                disconnectCharacterAddedConnections()
                -- アイコン全削除
                for _, p in pairs(playersService:GetPlayers()) do
                    if p.Character and p.Character:FindFirstChild("Head") and p.Character.Head:FindFirstChild("ESPIcon") then
                        p.Character.Head.ESPIcon:Destroy()
                    end
                end
            end)
        end
    end
})

-- 変数とサービス
local players = game:GetService("Players")
local lp = players.LocalPlayer
_G.BringAllLongReach = false
_G.WhitelistFriends2 = false
_G.PlayerToLongGrab = ""

-- [[ 1. プレイヤーリストを更新する関数 ]]
local function getPlayerNames()
    local names = {}
    for _, p in pairs(players:GetPlayers()) do
        if p ~= lp then
            table.insert(names, p.Name)
        end
    end
    return names
end

-- [[ 2. 掴み & 高度固定キック ロジック (全距離対応版) ]]
local function doBlobmanFastGrab(targetPlayer, side)
    side = side or "Left"
    pcall(function()
        local char = lp.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        local seat = hum and hum.SeatPart
        
        if seat and seat.Parent and targetPlayer.Character then
            local blobman = seat.Parent
            local targetHRP = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
            local remote = blobman:FindFirstChild("BlobmanSeatAndOwnerScript") and blobman.BlobmanSeatAndOwnerScript:FindFirstChild("CreatureGrab")
            
            if remote and targetHRP then
                local detector = blobman:WaitForChild(side .. "Detector")
                local weld = detector:WaitForChild(side .. "Weld")

                -- 【全距離対応の裏技】
                -- 掴む瞬間にだけ、自分の「手の当たり判定」を相手の目の前に瞬間移動させる
                local oldCFrame = detector.CFrame
                detector.CFrame = targetHRP.CFrame
                
                -- 掴み実行 (Mode 3: Kick)
                remote:FireServer(detector, targetHRP, weld, 3)
                
                -- 0.05秒だけ待って判定を元の場所に戻す（これで見かけ上の不自然さを減らす）
                task.delay(0.05, function()
                    detector.CFrame = oldCFrame
                end)
                
                -- 【高度固定ロジック】(維持)
                if not lp.Character.HumanoidRootPart:FindFirstChild("TsunamiFloat") then
                    local bv = Instance.new("BodyVelocity")
                    bv.Name = "TsunamiFloat"
                    bv.MaxForce = Vector3.new(0, 1e9, 0)
                    bv.Velocity = Vector3.new(0, 25, 0)
                    bv.Parent = lp.Character.HumanoidRootPart
                    
                    task.delay(0.8, function()
                        if bv.Parent then
                            bv.Velocity = Vector3.new(0, 0, 0)
                        end
                    end)
                    game:GetService("Debris"):AddItem(bv, 1.5)
                end
            end
        end
    end)
end

-- [[ 3. UI構築 ]]
local BlobmanTab = Window:MakeTab({ Name = "Blobman 究極改", Icon = "rbxassetid://6031064398" })

-- プレイヤー選択
local PlayerSelector = BlobmanTab:AddDropdown({
    Name = "Select Player",
    Default = "",
    Options = getPlayerNames(),
    Callback = function(t)
        _G.PlayerToLongGrab = t
    end
})

-- リスト更新
BlobmanTab:AddButton({
    Name = "Refresh Player List",
    Callback = function()
        pcall(function()
            PlayerSelector:Refresh(getPlayerNames(), true)
        end)
    end
})

-- 単体実行（両手で一瞬で仕留める）
BlobmanTab:AddButton({
    Name = "Giga Grab & Kick",
    Callback = function()
        local target = players:FindFirstChild(_G.PlayerToLongGrab)
        if target then 
            doBlobmanFastGrab(target, "Left")
            task.wait(0.05)
            doBlobmanFastGrab(target, "Right")
        end
    end
})

-- デストロイサーバー（両手・高速掴み離し・高度固定）
BlobmanTab:AddToggle({
    Name = "Destroy Server (Fast Dual Grab)",
    Default = false,
    Callback = function(Value)
        _G.BringAllLongReach = Value
        if Value then
            task.spawn(function()
                local useLeft = true
                while _G.BringAllLongReach do
                    for _, p in pairs(players:GetPlayers()) do
                        if not _G.BringAllLongReach then break end
                        if p ~= lp and p.Character and not (_G.WhitelistFriends2 and lp:IsFriendsWith(p.UserId)) then
                            
                            -- 左手と右手を交互に超速で回す
                            local arm = useLeft and "Left" or "Right"
                            doBlobmanFastGrab(p, arm)
                            useLeft = not useLeft
                            
                            -- Blitz Hub風の「即掴み・即離し」感を作るための短い待機
                            task.wait(0.1) 
                        end
                    end
                    task.wait(0.3)
                end
            end)
        else
            -- オフにしたら高度固定を消す
            local float = lp.Character.HumanoidRootPart:FindFirstChild("TsunamiFloat")
            if float then float:Destroy() end
        end
    end
})

BlobmanTab:AddToggle({
    Name = "Whitelist Friends",
    Default = false,
    Callback = function(v) _G.WhitelistFriends2 = v end
})

--==============================
-- 初期化
--==============================
OrionLib:Init()
