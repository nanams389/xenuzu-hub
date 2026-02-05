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
-- タブ：ビジュアル・カメラ
--==============================
local VisualTab = Window:MakeTab({ Name = "ビジュアル・カメラ", Icon = "rbxassetid://4483345998" })

-- 自由視点 (Freecam) の設定
VisualTab:AddToggle({
    Name = "自由視点 (Freecam)",
    Default = false,
    Callback = function(v)
        _G.Freecam = v
        local cam = workspace.CurrentCamera
        if v then
            cam.CameraType = Enum.CameraType.Scriptable
        else
            cam.CameraType = Enum.CameraType.Custom
        end
    end
})

-- 自由視点の移動制御 (WASDで移動)
game:GetService("RunService").RenderStepped:Connect(function()
    if _G.Freecam then
        local cam = workspace.CurrentCamera
        local uis = game:GetService("UserInputService")
        local speed = 1.0 -- 移動速度
        if uis:IsKeyDown(Enum.KeyCode.W) then cam.CFrame = cam.CFrame * CFrame.new(0, 0, -speed) end
        if uis:IsKeyDown(Enum.KeyCode.S) then cam.CFrame = cam.CFrame * CFrame.new(0, 0, speed) end
        if uis:IsKeyDown(Enum.KeyCode.A) then cam.CFrame = cam.CFrame * CFrame.new(-speed, 0, 0) end
        if uis:IsKeyDown(Enum.KeyCode.D) then cam.CFrame = cam.CFrame * CFrame.new(speed, 0, 0) end
        if uis:IsKeyDown(Enum.KeyCode.E) then cam.CFrame = cam.CFrame * CFrame.new(0, speed, 0) end
        if uis:IsKeyDown(Enum.KeyCode.Q) then cam.CFrame = cam.CFrame * CFrame.new(0, -speed, 0) end
    end
end)

-- 詳細ESPの設定
VisualTab:AddToggle({
    Name = "プレイヤー詳細ESP",
    Default = false,
    Callback = function(v)
        _G.ESPEnabled = v
        if not v then
            -- OFFにした時に表示を消す処理
            for _, player in pairs(game.Players:GetPlayers()) do
                if player.Character and player.Character:FindFirstChild("ESP_UI") then
                    player.Character.ESP_UI:Destroy()
                end
            end
        end
    end
})

-- ESPの描画処理
game:GetService("RunService").RenderStepped:Connect(function()
    if _G.ESPEnabled then
        for _, player in pairs(game.Players:GetPlayers()) do
            if player ~= game.Players.LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
                local head = player.Character.Head
                local billboard = head:FindFirstChild("ESP_UI")
                
                if not billboard then
                    billboard = Instance.new("BillboardGui", head)
                    billboard.Name = "ESP_UI"
                    billboard.Size = UDim2.new(0, 200, 0, 100)
                    billboard.AlwaysOnTop = true
                    billboard.ExtentsOffset = Vector3.new(0, 3, 0)

                    local frame = Instance.new("Frame", billboard)
                    frame.Size = UDim2.new(1, 0, 1, 0)
                    frame.BackgroundTransparency = 1

                    local textLabel = Instance.new("TextLabel", frame)
                    textLabel.Size = UDim2.new(1, 0, 0.7, 0)
                    textLabel.BackgroundTransparency = 1
                    textLabel.TextColor3 = Color3.new(1, 1, 1)
                    textLabel.TextStrokeTransparency = 0
                    textLabel.TextScaled = true

                    local img = Instance.new("ImageLabel", frame)
                    img.Size = UDim2.new(0, 40, 0, 40)
                    img.Position = UDim2.new(0.5, -20, 0, -45)
                    img.Image = game.Players:GetUserThumbnailAsync(player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
                end

                local dist = math.floor((game.Players.LocalPlayer.Character.HumanoidRootPart.Position - head.Position).Magnitude)
                billboard.Frame.TextLabel.Text = string.format("Display: %s\nID: %d\nDist: %dm", player.DisplayName, player.UserId, dist)
            end
        end
    end
end)

-- 一人称解除 (Force Third Person)
VisualTab:AddToggle({
    Name = "三人称視点を強制許可",
    Default = false,
    Callback = function(v)
        local lp = game.Players.LocalPlayer
        if v then
            -- ズーム距離の制限を解除して、三人称にできるようにする
            lp.CameraMaxZoomDistance = 100 -- 好きな距離まで引けるように設定
            lp.CameraMinZoomDistance = 0.5
            lp.CameraMode = Enum.CameraMode.Classic -- 一人称固定(LockFirstPerson)を解除
        else
            -- ゲームデフォルトの設定に戻す（必要に応じて数値を調整してくれ）
            lp.CameraMaxZoomDistance = 12.8 
            lp.CameraMode = Enum.CameraMode.Classic
        end
    end
})

-- 自分をキャラリセ (Kill) ボタン
VisualTab:AddButton({
    Name = "自分をキャラリセ (Reset)",
    Callback = function()
        local char = game.Players.LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        
        if hum then
            hum.Health = 0
            -- 通知を表示
            OrionLib:MakeNotification({
                Name = "System",
                Content = "キャラクターをリセットしました",
                Image = "rbxassetid://4483345998",
                Time = 2
            })
        end
    end
})

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
-- 家（プロット）テレポート
--==============================
StealthTab:AddSection({ Name = "家・セーフゾーン テレポート" })

local selectedPlot = ""

-- 1. テレポート先を選択するドロップダウン
StealthTab:AddDropdown({
    Name = "テレポート先の家を選択",
    Default = "",
    Options = {}, -- 最初は空
    Callback = function(Value)
        selectedPlot = Value
    end    
})

-- 2. プレイヤーリストを更新するボタン（Orionのリフレッシュ用）
StealthTab:AddButton({
    Name = "プレイヤーリストを更新",
    Callback = function()
        local playerNames = {}
        for _, p in pairs(game.Players:GetPlayers()) do
            table.insert(playerNames, p.Name)
        end
        -- ドロップダウンのリストを最新にする（※Orionの仕様により手動更新が必要な場合がある）
        -- もし自動更新したい場合はこのボタンを押してリストを確認してくれ
    end
})

-- 3. 実行ボタン
StealthTab:AddButton({
    Name = "選択した家へテレポート",
    Callback = function()
        if selectedPlot == "" then
            OrionLib:MakeNotification({Name = "エラー", Content = "先に家（プレイヤー名）を選んでください", Time = 3})
            return
        end

        local targetPlayer = game.Players:FindFirstChild(selectedPlot)
        local plots = workspace:FindFirstChild("Plots")
        
        if plots then
            for _, plot in pairs(plots:GetChildren()) do
                local owner = plot:FindFirstChild("Owner")
                if owner and tostring(owner.Value) == selectedPlot then
                    -- プロットの基点（中心）へテレポート
                    local targetPos = plot.PrimaryPart and plot.PrimaryPart.CFrame or plot:FindFirstChildWhichIsA("BasePart").CFrame
                    lp.Character.HumanoidRootPart.CFrame = targetPos + Vector3.new(0, 3, 0)
                    
                    OrionLib:MakeNotification({
                        Name = "Teleport",
                        Content = selectedPlot .. " の家へ移動しました",
                        Time = 2
                    })
                    return
                end
            end
        end
        OrionLib:MakeNotification({Name = "Error", Content = "プロットが見つかりませんでした", Time = 3})
    end
})
--==============================
-- タブ：ビジュアル・カメラ
--==============================
local VisualTab = Window:MakeTab({ Name = "ビジュアル・カメラ", Icon = "rbxassetid://4483345998" })

-- 自由視点 (Freecam) の設定
VisualTab:AddToggle({
    Name = "自由視点 (Freecam)",
    Default = false,
    Callback = function(v)
        _G.Freecam = v
        local cam = workspace.CurrentCamera
        if v then
            cam.CameraType = Enum.CameraType.Scriptable
        else
            cam.CameraType = Enum.CameraType.Custom
        end
    end
})

-- 自由視点の移動制御 (WASDで移動)
game:GetService("RunService").RenderStepped:Connect(function()
    if _G.Freecam then
        local cam = workspace.CurrentCamera
        local uis = game:GetService("UserInputService")
        local speed = 1.0 -- 移動速度
        if uis:IsKeyDown(Enum.KeyCode.W) then cam.CFrame = cam.CFrame * CFrame.new(0, 0, -speed) end
        if uis:IsKeyDown(Enum.KeyCode.S) then cam.CFrame = cam.CFrame * CFrame.new(0, 0, speed) end
        if uis:IsKeyDown(Enum.KeyCode.A) then cam.CFrame = cam.CFrame * CFrame.new(-speed, 0, 0) end
        if uis:IsKeyDown(Enum.KeyCode.D) then cam.CFrame = cam.CFrame * CFrame.new(speed, 0, 0) end
        if uis:IsKeyDown(Enum.KeyCode.E) then cam.CFrame = cam.CFrame * CFrame.new(0, speed, 0) end
        if uis:IsKeyDown(Enum.KeyCode.Q) then cam.CFrame = cam.CFrame * CFrame.new(0, -speed, 0) end
    end
end)

-- 詳細ESPの設定
VisualTab:AddToggle({
    Name = "プレイヤー詳細ESP",
    Default = false,
    Callback = function(v)
        _G.ESPEnabled = v
        if not v then
            -- OFFにした時に表示を消す処理
            for _, player in pairs(game.Players:GetPlayers()) do
                if player.Character and player.Character:FindFirstChild("ESP_UI") then
                    player.Character.ESP_UI:Destroy()
                end
            end
        end
    end
})

-- ESPの描画処理
game:GetService("RunService").RenderStepped:Connect(function()
    if _G.ESPEnabled then
        for _, player in pairs(game.Players:GetPlayers()) do
            if player ~= game.Players.LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
                local head = player.Character.Head
                local billboard = head:FindFirstChild("ESP_UI")
                
                if not billboard then
                    billboard = Instance.new("BillboardGui", head)
                    billboard.Name = "ESP_UI"
                    billboard.Size = UDim2.new(0, 200, 0, 100)
                    billboard.AlwaysOnTop = true
                    billboard.ExtentsOffset = Vector3.new(0, 3, 0)

                    local frame = Instance.new("Frame", billboard)
                    frame.Size = UDim2.new(1, 0, 1, 0)
                    frame.BackgroundTransparency = 1

                    local textLabel = Instance.new("TextLabel", frame)
                    textLabel.Size = UDim2.new(1, 0, 0.7, 0)
                    textLabel.BackgroundTransparency = 1
                    textLabel.TextColor3 = Color3.new(1, 1, 1)
                    textLabel.TextStrokeTransparency = 0
                    textLabel.TextScaled = true

                    local img = Instance.new("ImageLabel", frame)
                    img.Size = UDim2.new(0, 40, 0, 40)
                    img.Position = UDim2.new(0.5, -20, 0, -45)
                    img.Image = game.Players:GetUserThumbnailAsync(player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
                end

                local dist = math.floor((game.Players.LocalPlayer.Character.HumanoidRootPart.Position - head.Position).Magnitude)
                billboard.Frame.TextLabel.Text = string.format("Display: %s\nID: %d\nDist: %dm", player.DisplayName, player.UserId, dist)
            end
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
-- 抹殺オーラ (Death Aura)
--==============================
local playersService = game:GetService("Players")
local destroyGrabLineEvent = game:GetService("ReplicatedStorage"):FindFirstChild("Events") and game:GetService("ReplicatedStorage").Events:FindFirstChild("DestroyGrabLine") -- 必要に応じてパス調整

-- 外部関数のチェック（エラー防止用：未定義なら常に実行するように設定）
local CheckPlayerAuras = CheckPlayerAuras or function() return true end
local SNOWshipPlayer = SNOWshipPlayer or function() return true end
local CreateSkyVelocity = CreateSkyVelocity or function(hrp) hrp.Velocity = Vector3.new(0, 100, 0) end

UltimateTab:AddToggle({
    Name = "Death Aura (抹殺オーラ)掴んだらキル",
    Default = false,
    Callback = function(deathAuraEnabled)
        _G.DeathAura = deathAuraEnabled
        if deathAuraEnabled then
            task.spawn(function()
                while _G.DeathAura do
                    local gamePlayers2 = playersService
                    local playerPairsIterator2, iteratorValue4, playerKey2 = pairs(gamePlayers2:GetPlayers())
                    
                    while true do
                        local player2
                        playerKey2, player2 = playerPairsIterator2(iteratorValue4, playerKey2)
                        
                        if playerKey2 == nil then
                            break
                        end
                        
                        -- 自分のキャラ以外を対象にする
                        if player2 ~= lp and CheckPlayerAuras(player2) then
                            local playerCharacter = player2.Character
                            local humanoidRootPart = playerCharacter and playerCharacter:FindFirstChild("HumanoidRootPart")
                            local humanoid = playerCharacter and playerCharacter:FindFirstChildOfClass("Humanoid")
                            
                            if humanoidRootPart and humanoid and SNOWshipPlayer(player2) then
                                pcall(function()
                                    -- サーバーイベントへ送信
                                    if destroyGrabLineEvent then
                                        destroyGrabLineEvent:FireServer(humanoidRootPart)
                                    end
                                    
                                    -- 状態操作
                                    CreateSkyVelocity(humanoidRootPart)
                                    humanoid.BreakJointsOnDeath = false
                                    humanoid:ChangeState(Enum.HumanoidStateType.Dead)
                                    humanoid.Jump = true
                                    humanoid.Sit = false
                                    
                                    if humanoid:GetStateEnabled(Enum.HumanoidStateType.Dead) then
                                        if destroyGrabLineEvent then
                                            destroyGrabLineEvent:FireServer(humanoidRootPart)
                                        end
                                    end
                                end)
                            end
                        end
                    end
                    task.wait(0.1) -- ループの負荷調整
                end
            end)
        end
    end,
    Save = true,
    Flag = "deathaura_toggle"
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

-- [[ 2. 掴み & 高度固定キック ロジック (安定版) ]]
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
                local detector = blobman:WaitForChild(side .. "Detector", 1)
                local weld = detector and detector:WaitForChild(side .. "Weld", 1)

                if detector and weld then
                    -- 【安定版・全距離対応】
                    -- 物理的にDetectorを動かすとバグるので、一瞬だけ透明な偽のパーツを相手の座標に置くか、
                    -- 座標データを直接書き換えてFireServerする
                    local originalCFrame = detector.CFrame
                    detector.CFrame = targetHRP.CFrame -- 瞬間移動
                    
                    -- 掴み実行 (Mode 3: Kick)
                    remote:FireServer(detector, targetHRP, weld, 3)
                    
                    -- すぐに戻す (ここをtask.waitなしで実行して安定させる)
                    detector.CFrame = originalCFrame
                end
                
                -- 【高度固定ロジック】
                if not lp.Character.HumanoidRootPart:FindFirstChild("TsunamiFloat") then
                    local bv = Instance.new("BodyVelocity")
                    bv.Name = "TsunamiFloat"
                    bv.MaxForce = Vector3.new(0, 1e9, 0)
                    bv.Velocity = Vector3.new(0, 20, 0) -- 少し控えめにして安定
                    bv.Parent = lp.Character.HumanoidRootPart
                    
                    task.delay(0.6, function()
                        if bv.Parent then bv.Velocity = Vector3.new(0, 0, 0) end
                    end)
                    game:GetService("Debris"):AddItem(bv, 1.2)
                end
            end
        end
    end)
end

-- [[ 3. UI構築 ]]
local BlobmanTab = Window:MakeTab({ Name = "Blobman 1", Icon = "rbxassetid://6031064398" })

local PlayerSelector = BlobmanTab:AddDropdown({
    Name = "Select Player",
    Default = "",
    Options = getPlayerNames(),
    Callback = function(t) _G.PlayerToLongGrab = t end
})

BlobmanTab:AddButton({
    Name = "Refresh Player List",
    Callback = function()
        pcall(function() PlayerSelector:Refresh(getPlayerNames(), true) end)
    end
})

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

BlobmanTab:AddToggle({
    Name = "Destroy Server (Fast Dual Grab)",
    Default = false,
    Callback = function(Value)
        _G.BringAllLongReach = Value
        if Value then
            task.spawn(function()
                local useLeft = true
                while _G.BringAllLongReach do
                    local playerList = players:GetPlayers()
                    for _, p in pairs(playerList) do
                        if not _G.BringAllLongReach then break end
                        if p ~= lp and p.Character and not (_G.WhitelistFriends2 and lp:IsFriendsWith(p.UserId)) then
                            local arm = useLeft and "Left" or "Right"
                            doBlobmanFastGrab(p, arm)
                            useLeft = not useLeft
                            task.wait(0.12) -- わずかに待機を増やしてサーバー負荷を逃がす
                        end
                    end
                    task.wait(0.5)
                end
            end)
        else
            local float = lp.Character.HumanoidRootPart:FindFirstChild("TsunamiFloat")
            if float then float:Destroy() end
        end
    end
})

BlobmanTab:AddToggle({ Name = "Whitelist Friends", Default = false, Callback = function(v) _G.WhitelistFriends2 = v end })

-- --- テレポート系セクション (Blobman搭乗対応版) ---

-- 1. 特定プレイヤーへBlobmanごと瞬間移動
BlobmanTab:AddButton({
    Name = "TP to Selected (Blobman移動)",
    Callback = function()
        pcall(function()
            local target = players:FindFirstChild(_G.PlayerToLongGrab)
            local char = lp.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            local seat = hum and hum.SeatPart
            
            if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
                local targetPos = target.Character.HumanoidRootPart.CFrame * CFrame.new(0, 8, 0)
                
                if seat and seat.Parent then
                    -- Blobmanに乗っている場合、BlobmanのPrimaryPart（または外枠）を移動させる
                    local model = seat.Parent
                    if model:IsA("Model") and model.PrimaryPart then
                        model:SetPrimaryPartCFrame(targetPos)
                    else
                        -- PrimaryPartがない場合はSeat自体を動かして物理移動させる
                        seat.CFrame = targetPos
                    end
                else
                    -- 乗っていない場合は自分だけ飛ぶ
                    char:SetPrimaryPartCFrame(targetPos)
                end
            end
        end)
    end
})

-- 2. 全プレイヤーをBlobmanごとゆっくり巡回
_G.AutoTPAll = false
BlobmanTab:AddToggle({
    Name = "Auto TP All (Blobman巡回)",
    Default = false,
    Callback = function(Value)
        _G.AutoTPAll = Value
        if Value then
            task.spawn(function()
                while _G.AutoTPAll do
                    for _, p in pairs(players:GetPlayers()) do
                        if not _G.AutoTPAll then break end
                        if p ~= lp and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                            pcall(function()
                                local targetPos = p.Character.HumanoidRootPart.CFrame * CFrame.new(0, 12, 0)
                                local seat = lp.Character.Humanoid:GetState() == Enum.HumanoidStateType.Seated and lp.Character.Humanoid.SeatPart
                                
                                if seat and seat.Parent then
                                    -- Blobmanごと巡回
                                    local model = seat.Parent
                                    if model.PrimaryPart then
                                        model:SetPrimaryPartCFrame(targetPos)
                                    else
                                        seat.CFrame = targetPos
                                    end
                                else
                                    -- 自分だけで巡回
                                    lp.Character:SetPrimaryPartCFrame(targetPos)
                                end
                            end)
                            task.wait(0.5) -- 3秒ごとに次のプレイヤーへ
                        end
                    end
                    task.wait(0.3)
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

-- [[ 2. 掴み & 上昇 & キック の中身 ]]
local function doBlobmanGrab(targetPlayer)
    pcall(function()
        local char = lp.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        local seat = hum and hum.SeatPart
        if seat and seat.Parent and targetPlayer.Character then
            local blobman = seat.Parent
            local targetHRP = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
            local remote = blobman:FindFirstChild("BlobmanSeatAndOwnerScript") and blobman.BlobmanSeatAndOwnerScript:FindFirstChild("CreatureGrab")
            if remote and targetHRP then
                -- 掴み実行 (Mode 3: Kick)
                remote:FireServer(
                    blobman:WaitForChild("LeftDetector"),
                    targetHRP,
                    blobman:WaitForChild("LeftDetector"):WaitForChild("LeftWeld"),
                    3
                )
                -- 上昇エフェクト
                local bv = Instance.new("BodyVelocity")
                bv.MaxForce = Vector3.new(1e9, 1e9, 1e9)
                bv.Velocity = Vector3.new(0, 50, 0)
                bv.Parent = lp.Character.HumanoidRootPart
                game:GetService("Debris"):AddItem(bv, 0.5)
            end
        end
    end)
end

-- [[ 3. UI構築 ]]
local BlobmanTab = Window:MakeTab({ Name = "Blobman 2", Icon = "rbxassetid://6031064398" })

-- 公式エラー誘発キック (blobman 引き寄せ)
BlobmanTab:AddButton({
    Name = "blobmanで相手を掴む(グッチ、家貫通)",
    Callback = function()
        pcall(function()
            local target = players:FindFirstChild(_G.PlayerToLongGrab)
            local char = lp.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            local hrp = char:FindFirstChild("HumanoidRootPart")
            local seat = hum and hum.SeatPart
            if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") and seat and seat.Parent then
                local blobman = seat.Parent
                local targetHRP = target.Character.HumanoidRootPart
                local remote = blobman.BlobmanSeatAndOwnerScript:FindFirstChild("CreatureGrab")
                -- 1. 相手の場所にテレポート
                local targetPos = targetHRP.CFrame * CFrame.new(0, 5, 0)
                if blobman.PrimaryPart then
                    blobman:SetPrimaryPartCFrame(targetPos)
                else
                    seat.CFrame = targetPos
                end
                task.wait(0.1)
                -- 2. 両手で掴む
                local arms = {"Left", "Right"}
                for _, side in ipairs(arms) do
                    local detector = blobman:WaitForChild(side .. "Detector")
                    local weld = detector:WaitForChild(side .. "Weld")
                    remote:FireServer(detector, targetHRP, weld, 3)
                end
                -- 3. 公式エラー誘発
                task.spawn(function()
                    local leftDetector = blobman:FindFirstChild("LeftDetector")
                    local rightDetector = blobman:FindFirstChild("RightDetector")
                    local originalCF = leftDetector.CFrame
                    for i = 1, 15 do
                        local shakePos = targetHRP.CFrame * CFrame.new(0, -20, 0)
                        if leftDetector then leftDetector.CFrame = shakePos end
                        if rightDetector then rightDetector.CFrame = shakePos end
                        task.wait(0.02)
                        local shakePosUp = targetHRP.CFrame * CFrame.new(0, 20, 0)
                        if leftDetector then leftDetector.CFrame = shakePosUp end
                        if rightDetector then rightDetector.CFrame = shakePosUp end
                        task.wait(0.02)
                    end
                    if leftDetector then leftDetector.CFrame = originalCF end
                end)
                -- 4. 浮上固定
                if not hrp:FindFirstChild("ErrorFloat") then
                    local bv = Instance.new("BodyVelocity")
                    bv.Name = "ErrorFloat"
                    bv.MaxForce = Vector3.new(0, 1e9, 0)
                    bv.Velocity = Vector3.new(0, 35, 0)
                    bv.Parent = hrp
                    task.delay(0.6, function() if bv.Parent then bv.Velocity = Vector3.new(0, 0, 0) end end)
                    game:GetService("Debris"):AddItem(bv, 2.0)
                end
            end
        end)
    end
})

-- プレイヤー選択ドロップダウン
local PlayerSelector = BlobmanTab:AddDropdown({
    Name = "Select Player",
    Default = "",
    Options = getPlayerNames(),
    Callback = function(t) _G.PlayerToLongGrab = t end
})

-- リスト更新ボタン
BlobmanTab:AddButton({
    Name = "Refresh Player List (リスト更新)",
    Callback = function()
        PlayerSelector:Refresh(getPlayerNames(), true)
    end
})

-- 単体実行ボタン
BlobmanTab:AddButton({
    Name = "Grab & Kick (単体実行)",
    Callback = function()
        local target = players:FindFirstChild(_G.PlayerToLongGrab)
        if target then doBlobmanGrab(target) end
    end
})

-- デストロイサーバー (Rapid Grab/Release)
BlobmanTab:AddToggle({
    Name = "Destroy Server (Rapid Grab/Release)",
    Default = false,
    Callback = function(Value)
        _G.BringAllLongReach = Value
        if Value then
            task.spawn(function()
                while _G.BringAllLongReach do
                    local char = lp.Character
                    local seat = char.Humanoid.SeatPart
                    if seat and seat.Parent then
                        local blobman = seat.Parent
                        local remote = blobman.BlobmanSeatAndOwnerScript:FindFirstChild("CreatureGrab")
                        if remote then
                            for _, p in pairs(players:GetPlayers()) do
                                if not _G.BringAllLongReach then break end
                                if p ~= lp and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and not (_G.WhitelistFriends2 and lp:IsFriendsWith(p.UserId)) then
                                    local targetHRP = p.Character.HumanoidRootPart
                                    local detector = blobman:FindFirstChild("LeftDetector")
                                    local weld = detector and detector:FindFirstChild("LeftWeld")
                                    if detector and weld then
                                        remote:FireServer(detector, targetHRP, weld, 2) -- 掴む
                                        task.wait(0.05)
                                        remote:FireServer(detector, targetHRP, weld, 1) -- 即離す
                                    end
                                end
                            end
                        end
                    end
                    task.wait(0.2)
                end
            end)
        end
    end
})
-- デストロイサーバー (極限・即掴み即離し)
BlobmanTab:AddToggle({
    Name = "Destroy Server (Instant Release)",
    Default = false,
    Callback = function(Value)
        _G.BringAllLongReach = Value
        if Value then
            task.spawn(function()
                while _G.BringAllLongReach do
                    local char = lp.Character
                    local seat = char and char.Humanoid.SeatPart
                    
                    if seat and seat.Parent then
                        local blobman = seat.Parent
                        local remote = blobman.BlobmanSeatAndOwnerScript:FindFirstChild("CreatureGrab")
                        
                        if remote then
                            for _, p in pairs(players:GetPlayers()) do
                                if not _G.BringAllLongReach then break end
                                if p ~= lp and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and not (_G.WhitelistFriends2 and lp:IsFriendsWith(p.UserId)) then
                                    
                                    local targetHRP = p.Character.HumanoidRootPart
                                    
                                    -- 左右の手で実行
                                    for _, armSide in ipairs({"Left", "Right"}) do
                                        local detector = blobman:FindFirstChild(armSide .. "Detector")
                                        local weld = detector and detector:FindFirstChild(armSide .. "Weld")
                                        
                                        if detector and weld then
                                            -- 1. 掴む (Mode 2)
                                            remote:FireServer(detector, targetHRP, weld, 2)
                                            
                                            -- 2. 即座に（待ち時間なしで）離す (Mode 1)
                                            -- 念のため2回送ってサーバーに「離せ」と強制する
                                            remote:FireServer(detector, targetHRP, weld, 1)
                                            remote:FireServer(detector, targetHRP, weld, 1)
                                        end
                                    end
                                end
                            end
                        end
                    end
                    -- ループの間隔を極限まで短く（0.1秒）
                    task.wait(0.1) 
                end
            end)
        end
    end
})
BlobmanTab:AddToggle({ Name = "Whitelist Friends", Default = false, Callback = function(v) _G.WhitelistFriends2 = v end })

--==============================
-- タブ：ブロブマン設定 (変数名を統一)
--==============================
local BlobmanTab = Window:MakeTab({ Name = "ブロブマン設定", Icon = "rbxassetid://4483345998" })

local SelectedPlayer = ""
local players = game:GetService("Players")
local lp = players.LocalPlayer

-- 1. スピード調整
BlobmanTab:AddSlider({
    Name = "ブロブマン走行速度", 
    Min = 16, Max = 500, Default = 50, Increment = 1,
    Callback = function(v)
        _G.BlobSpeed = v
    end
})

-- 走行スピード適用ループ
task.spawn(function()
    while true do
        task.wait(0.1)
        local char = lp.Character
        if char and char:FindFirstChild("Humanoid") then
            -- 座っているパーツの親がBlobmanかチェック
            if char.Humanoid.SeatPart and char.Humanoid.SeatPart.Parent.Name == "Blobman" then
                char.Humanoid.WalkSpeed = _G.BlobSpeed or 16
            end
        end
    end
end)

-- 2. 飛行モード
BlobmanTab:AddToggle({
    Name = "ブロブマン飛行モード",
    Default = false,
    Callback = function(v)
        _G.BlobFly = v
        if v then
            local char = lp.Character
            local bg = Instance.new("BodyGyro", char.HumanoidRootPart)
            bg.Name = "FlyGyro"
            bg.maxTorque = Vector3.new(9e9, 9e9, 9e9)
            local bv = Instance.new("BodyVelocity", char.HumanoidRootPart)
            bv.Name = "FlyVel"
            bv.maxForce = Vector3.new(9e9, 9e9, 9e9)
            
            task.spawn(function()
                while _G.BlobFly do
                    task.wait()
                    local cam = workspace.CurrentCamera
                    local moveDir = Vector3.new(0,0,0)
                    local uis = game:GetService("UserInputService")
                    if uis:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + cam.CFrame.LookVector end
                    if uis:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - cam.CFrame.LookVector end
                    if uis:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - cam.CFrame.RightVector end
                    if uis:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + cam.CFrame.RightVector end
                    bv.velocity = moveDir * (_G.BlobSpeed or 50)
                    bg.cframe = cam.CFrame
                end
                bg:Destroy()
                bv:Destroy()
            end)
        end
    end
})


--==============================
-- 初期化
--==============================
OrionLib:Init()
