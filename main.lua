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
    Name = "ens Hub", 
    HidePremium = false, 
    SaveConfig = true, 
    ConfigFolder = "ens Hub",
    IntroEnabled = true,
    IntroText = "ens Hub 起動中..."
})

--==============================
-- タブ：HOME（統合）
--==============================
local HomeTab = Window:MakeTab({ 
    Name = "HOME", 
    Icon = "rbxassetid://4483345998" 
})

--==============================
-- セクション：基本ステータス
--==============================
HomeTab:AddSection({ Name = "基本ステータス" })

HomeTab:AddSlider({
    Name = "歩行速度", Min = 16, Max = 500, Default = 16, Increment = 1,
    Callback = function(v) 
        if game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") then
            game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = v 
        end
    end    
})

HomeTab:AddSlider({
    Name = "ジャンプ力", Min = 50, Max = 1000, Default = 50, Increment = 1,
    Callback = function(v) 
        if game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") then
            game.Players.LocalPlayer.Character.Humanoid.JumpPower = v 
        end
    end    
})

HomeTab:AddToggle({ 
    Name = "無限ジャンプ", 
    Default = false, 
    Callback = function(v) 
        _G.InfJump = v 
    end 
})

game:GetService("UserInputService").JumpRequest:Connect(function()
    if _G.InfJump then
        local hum = game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then 
            hum:ChangeState("Jumping") 
        end
    end
end)

--==============================
-- セクション：ビジュアル・カメラ
--==============================
HomeTab:AddSection({ Name = "ビジュアル・カメラ" })

-- 自由視点
HomeTab:AddToggle({
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

-- Freecam移動
game:GetService("RunService").RenderStepped:Connect(function()
    if _G.Freecam then
        local cam = workspace.CurrentCamera
        local uis = game:GetService("UserInputService")
        local speed = 1.0
        if uis:IsKeyDown(Enum.KeyCode.W) then cam.CFrame = cam.CFrame * CFrame.new(0, 0, -speed) end
        if uis:IsKeyDown(Enum.KeyCode.S) then cam.CFrame = cam.CFrame * CFrame.new(0, 0, speed) end
        if uis:IsKeyDown(Enum.KeyCode.A) then cam.CFrame = cam.CFrame * CFrame.new(-speed, 0, 0) end
        if uis:IsKeyDown(Enum.KeyCode.D) then cam.CFrame = cam.CFrame * CFrame.new(speed, 0, 0) end
        if uis:IsKeyDown(Enum.KeyCode.E) then cam.CFrame = cam.CFrame * CFrame.new(0, speed, 0) end
        if uis:IsKeyDown(Enum.KeyCode.Q) then cam.CFrame = cam.CFrame * CFrame.new(0, -speed, 0) end
    end
end)

-- ESP
HomeTab:AddToggle({
    Name = "プレイヤー詳細ESP",
    Default = false,
    Callback = function(v)
        _G.ESPEnabled = v
        if not v then
            for _, player in pairs(game.Players:GetPlayers()) do
                if player.Character and player.Character:FindFirstChild("ESP_UI") then
                    player.Character.ESP_UI:Destroy()
                end
            end
        end
    end
})

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
                    frame.Name = "Frame"

                    local textLabel = Instance.new("TextLabel", frame)
                    textLabel.Size = UDim2.new(1, 0, 0.7, 0)
                    textLabel.BackgroundTransparency = 1
                    textLabel.TextColor3 = Color3.new(1, 1, 1)
                    textLabel.TextStrokeTransparency = 0
                    textLabel.TextScaled = true
                    textLabel.Name = "TextLabel"

                    local img = Instance.new("ImageLabel", frame)
                    img.Size = UDim2.new(0, 40, 0, 40)
                    img.Position = UDim2.new(0.5, -20, 0, -45)
                    img.Image = game.Players:GetUserThumbnailAsync(player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
                end

                local dist = math.floor((game.Players.LocalPlayer.Character.HumanoidRootPart.Position - head.Position).Magnitude)
                billboard.Frame.TextLabel.Text = 
                    string.format("Display: %s\nID: %d\nDist: %dm", 
                    player.DisplayName, player.UserId, dist)
            end
        end
    end
end)

-- 三人称強制
HomeTab:AddToggle({
    Name = "三人称視点を強制許可",
    Default = false,
    Callback = function(v)
        local lp = game.Players.LocalPlayer
        if v then
            lp.CameraMaxZoomDistance = 100
            lp.CameraMinZoomDistance = 0.5
            lp.CameraMode = Enum.CameraMode.Classic
        else
            lp.CameraMaxZoomDistance = 12.8 
            lp.CameraMode = Enum.CameraMode.Classic
        end
    end
})

-- リセットボタン
HomeTab:AddButton({
    Name = "自分をキャラリセ (Reset)",
    Callback = function()
        local char = game.Players.LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        
        if hum then
            hum.Health = 0
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
-- タブ：ターゲット（新規追加）
--==============================
local TargetTab = Window:MakeTab({
    Name = "ターゲット",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

-- ターゲット用変数
local TargetTabSelected = ""
_G.TargetLoopKick = false
_G.TargetGrabKickLoop = false

-- ★修正★ ブロブマン取得を強化 (乗ってるブロブマンも検出)
local function getMyBlobman()
    local lp = game.Players.LocalPlayer
    if not lp.Character then return nil end
    local hum = lp.Character:FindFirstChildOfClass("Humanoid")
    
    -- 1. 今座っているシートの親がブロブマンならそれを返す
    if hum and hum.SeatPart then
        local parent = hum.SeatPart.Parent
        if parent and (parent.Name == "CreatureBlobman" or parent.Name == "Blobman") then
            return parent
        end
    end
    
    -- 2. SpawnedInToys内を検索
    local inv = workspace:FindFirstChild(lp.Name .. "SpawnedInToys")
    if inv then
        local blob = inv:FindFirstChild("CreatureBlobman") or inv:FindFirstChild("Blobman")
        if blob then return blob end
    end
    
    -- 3. PlotItems内を検索
    pcall(function()
        for _, folder in ipairs(workspace.PlotItems:GetChildren()) do
            for _, item in ipairs(folder:GetChildren()) do
                if (item.Name == "CreatureBlobman" or item.Name == "Blobman") then
                    -- PlayerValueで自分のか確認
                    if item:FindFirstChild("PlayerValue") and item.PlayerValue.Value == lp.Name then
                        return item
                    end
                    -- Ownerで確認
                    if item:FindFirstChild("Owner") and item.Owner.Value == lp.Name then
                        return item
                    end
                end
            end
        end
    end)
    
    -- 4. workspace全体から自分のブロブマンを探す（最後の手段）
    for _, v in ipairs(workspace:GetDescendants()) do
        if (v.Name == "CreatureBlobman" or v.Name == "Blobman") and v:IsA("Model") then
            if v:FindFirstChild("VehicleSeat") then
                local seat = v.VehicleSeat
                if seat.Occupant and seat.Occupant.Parent == lp.Character then
                    return v
                end
            end
        end
    end
    
    return nil
end

-- ★修正★ ブロブマンのグラブを実行 (remoteの取得方法を複数対応)
local function doBlobGrab(blob, targetPart, side)
    if not blob or not targetPart then return end
    pcall(function()
        local detector = blob:FindFirstChild(side .. "Detector")
        if not detector then return end
        local weld = detector:FindFirstChild(side .. "Weld") or detector:FindFirstChildWhichIsA("Weld")
        if not weld then return end
        
        -- リモート取得: BlobmanSeatAndOwnerScript内のCreatureGrab
        local remote = nil
        local script = blob:FindFirstChild("BlobmanSeatAndOwnerScript")
        if script then
            remote = script:FindFirstChild("CreatureGrab")
        end
        
        if remote then
            remote:FireServer(detector, targetPart, weld, 2)
            remote:FireServer(detector, targetPart, weld, 1)
        end
    end)
end

-- ★ キック成功時のサウンド再生 + 通知
local KICK_SOUND_ID = "rbxassetid://79150789336480"
local function playKickSound()
    pcall(function()
        local sound = Instance.new("Sound")
        sound.SoundId = KICK_SOUND_ID
        sound.Volume = 1
        sound.Parent = game:GetService("SoundService")
        sound:Play()
        game:GetService("Debris"):AddItem(sound, 3)
    end)
end

-- ターゲットのボットが抜けたか確認（ブロブマンから降ろされたか）
local function isTargetOnBot(playerName)
    local targetP = game.Players:FindFirstChild(playerName)
    if not targetP or not targetP.Character then return false end
    local hum = targetP.Character:FindFirstChildOfClass("Humanoid")
    if hum and hum.SeatPart then
        local parent = hum.SeatPart.Parent
        if parent and (parent.Name == "CreatureBlobman" or parent.Name == "Blobman") then
            return true
        end
    end
    return false
end

-- ボットが抜けたらサウンド + 通知
local function kickSuccess(targetName)
    playKickSound()
    OrionLib:MakeNotification({
        Name = "キック完了",
        Content = targetName .. " のボットが抜けました！",
        Image = "rbxassetid://4483345998",
        Time = 3
    })
end

-- ボット抜け監視（キック後にターゲットがブロブマンから降りたか検知）
local function monitorBotRemoval(targetName, wasOnBot)
    if wasOnBot then
        task.spawn(function()
            for i = 1, 20 do -- 最大2秒間監視
                task.wait(0.1)
                if not isTargetOnBot(targetName) then
                    kickSuccess(targetName)
                    return
                end
            end
        end)
    end
end

-- プレイヤーリスト取得
local function GetTargetPlayerList()
    local plist = {}
    for _, p in ipairs(game.Players:GetPlayers()) do
        if p ~= game.Players.LocalPlayer then
            table.insert(plist, p.Name)
        end
    end
    return plist
end

TargetTab:AddSection({ Name = "ターゲット選択" })

-- ターゲット選択ドロップダウン
local TargetTabDropdown = TargetTab:AddDropdown({
    Name = "プレイヤーを選択",
    Default = "",
    Options = GetTargetPlayerList(),
    Callback = function(Value)
        TargetTabSelected = Value
        OrionLib:MakeNotification({
            Name = "ターゲット設定",
            Content = Value .. " をターゲットに設定しました",
            Image = "rbxassetid://4483345998",
            Time = 2
        })
    end
})

-- プレイヤーリスト更新ボタン
TargetTab:AddButton({
    Name = "🔄 プレイヤーリスト更新",
    Callback = function()
        TargetTabDropdown:Refresh(GetTargetPlayerList(), true)
        OrionLib:MakeNotification({
            Name = "更新完了",
            Content = "プレイヤーリストを更新しました",
            Time = 2
        })
    end
})

--==============================
-- セクション：攻撃機能
--==============================
TargetTab:AddSection({ Name = "攻撃機能" })

-- ============================================================
-- 1. ブロブマンキック（ボタン）
--    Kick Auraと同じGrabEventsパターンを使用:
--    TP → blobGrab(自分) → SetNetworkOwner → CFrame上移動 → ungrab → blobGrab(ターゲット)
-- ============================================================
TargetTab:AddButton({
    Name = "ブロブマンキック",
    Callback = function()
        if TargetTabSelected == "" then
            OrionLib:MakeNotification({Name = "エラー", Content = "先にターゲットを選択してください", Time = 3})
            return
        end

        local blob = getMyBlobman()
        if not blob then
            OrionLib:MakeNotification({Name = "エラー", Content = "Blobmanが見つかりません (乗ってるか確認)", Time = 3})
            return
        end

        local targetPlayer = game.Players:FindFirstChild(TargetTabSelected)
        if not targetPlayer or not targetPlayer.Character or not targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
            OrionLib:MakeNotification({Name = "エラー", Content = "ターゲットが見つかりません", Time = 3})
            return
        end

        local lp = game.Players.LocalPlayer
        local myRoot = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
        if not myRoot then return end

        local savedPos = myRoot.CFrame
        local targetHRP = targetPlayer.Character.HumanoidRootPart
        local rs = game:GetService("ReplicatedStorage")
        local grabEvents = rs:FindFirstChild("GrabEvents")
        if not grabEvents then return end

        -- キック前にボットに乗ってるか確認
        local wasOnBot = isTargetOnBot(TargetTabSelected)

        task.spawn(function()
            pcall(function()
                -- Step 1: ターゲットの右にテレポート
                myRoot.CFrame = targetHRP.CFrame * CFrame.new(3, 0, 0)
                task.wait(0.15)

                -- Step 2: まず自分のrootをブロブマンで掴む（Kick Auraパターン）
                doBlobGrab(blob, myRoot, "Right")
                task.wait(0.05)

                -- Step 3: ターゲットの所有権奪取
                grabEvents.SetNetworkOwner:FireServer(targetHRP, targetHRP.CFrame)
                task.wait(0.05)

                -- Step 4: ターゲットを上に移動（GrabEventsで）
                targetHRP.CFrame = targetHRP.CFrame + Vector3.new(0, 20, 0)
                task.wait(0.05)

                -- Step 5: 自分のグラブを解除
                grabEvents.DestroyGrabLine:FireServer(targetHRP)
                task.wait(0.05)

                -- Step 6: ブロブマンでターゲットを掴む
                doBlobGrab(blob, targetHRP, "Left")
                task.wait(0.05)
                doBlobGrab(blob, targetHRP, "Right")
                task.wait(0.1)

                -- 元の位置に戻る
                myRoot.CFrame = savedPos
            end)

            -- ボットが抜けたら音を出す
            monitorBotRemoval(TargetTabSelected, wasOnBot)
        end)
    end
})

-- ============================================================
-- 2. ブロブマンループキック（トグル）
--    Kick Auraと同じGrabEventsパターン、リセットしても続行
-- ============================================================
TargetTab:AddToggle({
    Name = "ブロブマンループキック",
    Default = false,
    Callback = function(Value)
        _G.TargetLoopKick = Value
        if Value then
            if TargetTabSelected == "" then
                OrionLib:MakeNotification({Name = "エラー", Content = "先にターゲットを選択してください", Time = 3})
                _G.TargetLoopKick = false
                return
            end

            OrionLib:MakeNotification({
                Name = "ループキック",
                Content = TargetTabSelected .. " へのループキック開始",
                Time = 2
            })

            task.spawn(function()
                local rs = game:GetService("ReplicatedStorage")
                local grabEvents = rs:FindFirstChild("GrabEvents")
                if not grabEvents then return end

                while _G.TargetLoopKick do
                    task.wait(0.3)

                    local blob = getMyBlobman()
                    local lp = game.Players.LocalPlayer
                    local myRoot = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
                    if not blob or not myRoot then continue end

                    local targetPlayer = game.Players:FindFirstChild(TargetTabSelected)
                    if not targetPlayer then continue end
                    if not targetPlayer.Character or not targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
                        continue
                    end

                    local savedPos = myRoot.CFrame
                    local targetHRP = targetPlayer.Character.HumanoidRootPart

                    -- キック前にボットに乗ってるか確認
                    local wasOnBot = isTargetOnBot(TargetTabSelected)

                    pcall(function()
                        -- ターゲットの右にTP
                        myRoot.CFrame = targetHRP.CFrame * CFrame.new(3, 0, 0)
                        task.wait(0.15)

                        -- Kick Auraパターン: blobGrab(自分) → SetNetworkOwner → CFrame上 → ungrab → blobGrab(ターゲット)
                        doBlobGrab(blob, myRoot, "Right")
                        task.wait(0.05)

                        grabEvents.SetNetworkOwner:FireServer(targetHRP, targetHRP.CFrame)
                        task.wait(0.05)

                        targetHRP.CFrame = targetHRP.CFrame + Vector3.new(0, 20, 0)
                        task.wait(0.05)

                        grabEvents.DestroyGrabLine:FireServer(targetHRP)
                        task.wait(0.05)

                        doBlobGrab(blob, targetHRP, "Left")
                        task.wait(0.05)
                        doBlobGrab(blob, targetHRP, "Right")
                        task.wait(0.1)

                        -- 元の位置に戻る
                        myRoot.CFrame = savedPos
                    end)

                    -- ボットが抜けたら音を出す
                    monitorBotRemoval(TargetTabSelected, wasOnBot)
                end
            end)
        else
            OrionLib:MakeNotification({
                Name = "ループキック",
                Content = "ループキックを停止しました",
                Time = 2
            })
        end
    end
})

-- ============================================================
-- 3. グラブキック（トグル）
--    ONにしたら選択したターゲットに対してグラブキックが使える
--    元のグラブキックソースをそのまま使用
-- ============================================================
TargetTab:AddToggle({
    Name = "グラブキック",
    Default = false,
    Callback = function(Value)
        _G.TargetGrabKickLoop = Value
        if Value then
            if TargetTabSelected == "" then
                OrionLib:MakeNotification({Name = "エラー", Content = "先にターゲットを選択してください", Time = 3})
                _G.TargetGrabKickLoop = false
                return
            end

            OrionLib:MakeNotification({
                Name = "グラブキック",
                Content = TargetTabSelected .. " へのグラブキックON",
                Time = 2
            })

            task.spawn(function()
                local GrabEventsFolder = game:GetService("ReplicatedStorage"):FindFirstChild("GrabEvents")
                local RunService = game:GetService("RunService")
                if not GrabEventsFolder then
                    OrionLib:MakeNotification({Name = "エラー", Content = "GrabEventsが見つかりません", Time = 3})
                    _G.TargetGrabKickLoop = false
                    return
                end

                local lp = game.Players.LocalPlayer
                local myChar = lp.Character
                local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
                if not myRoot then
                    _G.TargetGrabKickLoop = false
                    return
                end

                local savedPos = myRoot.CFrame
                local dragging = false
                local grabStartTime = 0

                while _G.TargetGrabKickLoop do
                    myChar = lp.Character
                    myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
                    if not myRoot then break end

                    local targetP = game.Players:FindFirstChild(TargetTabSelected)
                    if not targetP or not targetP.Character or not targetP.Character:FindFirstChild("HumanoidRootPart") then
                        dragging = false
                        grabStartTime = 0
                        RunService.Heartbeat:Wait()
                        continue
                    end

                    local tRoot = targetP.Character.HumanoidRootPart
                    local tHum = targetP.Character:FindFirstChild("Humanoid")
                    if not tHum then RunService.Heartbeat:Wait() continue end

                    if tHum.Health > 0 then
                        -- 物理安定化
                        tRoot.AssemblyLinearVelocity = Vector3.zero
                        tRoot.AssemblyAngularVelocity = Vector3.zero
                        
                        if not dragging then
                            -- Phase 1: 接近してグラブ
                            pcall(function()
                                myRoot.CFrame = tRoot.CFrame
                                myRoot.AssemblyLinearVelocity = Vector3.zero
                                tHum.PlatformStand = true
                                tHum.Sit = true
                                GrabEventsFolder.SetNetworkOwner:FireServer(tRoot, myRoot.CFrame)
                                GrabEventsFolder.CreateGrabLine:FireServer(tRoot, Vector3.zero, tRoot.Position, false)
                            end)

                            if grabStartTime == 0 then grabStartTime = tick() end
                            if tick() - grabStartTime > 0.35 then
                                dragging = true
                                grabStartTime = 0
                            end
                        else
                            -- Phase 2: キック (元の位置に戻ってターゲットを上空固定)
                            pcall(function()
                                myRoot.CFrame = savedPos
                                myRoot.AssemblyLinearVelocity = Vector3.zero
                                
                                local lockPos = savedPos * CFrame.new(0, 20, 0)
                                tRoot.CFrame = lockPos
                                tRoot.AssemblyLinearVelocity = Vector3.zero

                                tHum.PlatformStand = true
                                tHum.Sit = false
                                GrabEventsFolder.SetNetworkOwner:FireServer(tRoot, lockPos)
                                GrabEventsFolder.DestroyGrabLine:FireServer(tRoot)
                                GrabEventsFolder.CreateGrabLine:FireServer(tRoot, Vector3.zero, tRoot.Position, false)
                            end)
                        end
                    else
                        dragging = false
                        grabStartTime = 0
                    end

                    RunService.Heartbeat:Wait()
                end

                -- 終了時に元の位置に戻る
                if myRoot then
                    myRoot.CFrame = savedPos
                    myRoot.AssemblyLinearVelocity = Vector3.zero
                end

                OrionLib:MakeNotification({
                    Name = "グラブキック",
                    Content = "グラブキックOFF",
                    Time = 2
                })
            end)
        end
    end
})

-- ============================================================
-- 4. ブロブマンBRING（ボタン）
--    ★修正★ getMyBlobman() + doBlobGrab() 使用
-- ============================================================
TargetTab:AddButton({
    Name = "ブロブマンBRING",
    Callback = function()
        if TargetTabSelected == "" then
            OrionLib:MakeNotification({Name = "エラー", Content = "先にターゲットを選択してください", Time = 3})
            return
        end

        local blob = getMyBlobman()
        if not blob then
            OrionLib:MakeNotification({Name = "エラー", Content = "Blobmanが見つかりません (乗ってるか確認)", Time = 3})
            return
        end

        local targetPlayer = game.Players:FindFirstChild(TargetTabSelected)
        if not targetPlayer or not targetPlayer.Character or not targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
            OrionLib:MakeNotification({Name = "エラー", Content = "ターゲットが見つかりません", Time = 3})
            return
        end

        local lp = game.Players.LocalPlayer
        local myRoot = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
        if not myRoot then return end

        local savedPos = myRoot.CFrame
        local targetHRP = targetPlayer.Character.HumanoidRootPart

        task.spawn(function()
            pcall(function()
                -- Step 1: ターゲットの右にテレポート
                myRoot.CFrame = targetHRP.CFrame * CFrame.new(3, 0, 0)
                task.wait(0.2)

                -- Step 2: ブロブマンのグラブで掴む
                doBlobGrab(blob, targetHRP, "Left")
                task.wait(0.05)
                doBlobGrab(blob, targetHRP, "Right")
                task.wait(0.2)

                -- Step 3: 元の位置に戻る
                myRoot.CFrame = savedPos
                task.wait(0.2)

                -- Step 4: グラブをドロップ
                local rs = game:GetService("ReplicatedStorage")
                local destroyLine = rs:FindFirstChild("GrabEvents") and rs.GrabEvents:FindFirstChild("DestroyGrabLine")
                if destroyLine then
                    destroyLine:FireServer(targetHRP)
                end
            end)

            OrionLib:MakeNotification({
                Name = "ブロブマンBRING",
                Content = TargetTabSelected .. " を引き寄せました",
                Time = 2
            })
        end)
    end
})

-- ============================================================
-- 5. グッチ破壊（ボタン）
--    相手のブロブマンに高速で一回座って元の位置に戻る
-- ============================================================
TargetTab:AddButton({
    Name = "グッチ破壊",
    Callback = function()
        if TargetTabSelected == "" then
            OrionLib:MakeNotification({Name = "エラー", Content = "先にターゲットを選択してください", Time = 3})
            return
        end

        local targetPlayer = game.Players:FindFirstChild(TargetTabSelected)
        if not targetPlayer then
            OrionLib:MakeNotification({Name = "エラー", Content = "ターゲットが見つかりません", Time = 3})
            return
        end

        local lp = game.Players.LocalPlayer
        local myRoot = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
        local myHum = lp.Character and lp.Character:FindFirstChildOfClass("Humanoid")
        if not myRoot or not myHum then return end

        local savedPos = myRoot.CFrame

        -- 相手のブロブマンを探す (複数箇所を検索)
        local targetBlob = nil

        -- SpawnedInToys内
        local inv = workspace:FindFirstChild(targetPlayer.Name .. "SpawnedInToys")
        if inv then
            targetBlob = inv:FindFirstChild("CreatureBlobman") or inv:FindFirstChild("Blobman")
        end

        -- PlotItems内
        if not targetBlob then
            pcall(function()
                for _, folder in ipairs(workspace.PlotItems:GetChildren()) do
                    for _, item in ipairs(folder:GetChildren()) do
                        if (item.Name == "CreatureBlobman" or item.Name == "Blobman") and item:IsA("Model") then
                            if item:FindFirstChild("PlayerValue") and item.PlayerValue.Value == targetPlayer.Name then
                                targetBlob = item
                            elseif item:FindFirstChild("Owner") and item.Owner.Value == targetPlayer.Name then
                                targetBlob = item
                            end
                        end
                    end
                end
            end)
        end

        -- workspace直下も検索
        if not targetBlob then
            for _, v in ipairs(workspace:GetChildren()) do
                if (v.Name == "CreatureBlobman" or v.Name == "Blobman") and v:IsA("Model") then
                    if v:FindFirstChild("VehicleSeat") and v.VehicleSeat.Occupant then
                        local occupantChar = v.VehicleSeat.Occupant.Parent
                        if occupantChar == targetPlayer.Character then
                            targetBlob = v
                            break
                        end
                    end
                end
            end
        end

        if not targetBlob then
            OrionLib:MakeNotification({Name = "エラー", Content = "相手のBlobmanが見つかりません", Time = 3})
            return
        end

        local seat = targetBlob:FindFirstChild("VehicleSeat")
        if not seat then
            OrionLib:MakeNotification({Name = "エラー", Content = "シートが見つかりません", Time = 3})
            return
        end

        task.spawn(function()
            pcall(function()
                -- 高速で座る
                myRoot.CFrame = seat.CFrame + Vector3.new(0, 2, 0)
                task.wait(0.1)
                seat:Sit(myHum)
                task.wait(0.25)

                -- すぐにジャンプして降りる
                myHum:ChangeState(Enum.HumanoidStateType.Jumping)
                task.wait(0.15)

                -- 元の位置に戻る
                myRoot.CFrame = savedPos
            end)

            OrionLib:MakeNotification({
                Name = "グッチ破壊",
                Content = TargetTabSelected .. " のグッチを破壊しました",
                Time = 2
            })
        end)
    end
})

-- ============================================================
-- 6. スノーボールキック（トグル）
--    ターゲットの中に雪玉を大量生成してラグを発生させる・吹き飛ばす
-- ============================================================
TargetTab:AddToggle({
    Name = "スノーボールキック",
    Default = false,
    Callback = function(Value)
        _G.TargetSnowballKick = Value
        if Value then
            if TargetTabSelected == "" then
                OrionLib:MakeNotification({Name = "エラー", Content = "先にターゲットを選択してください", Time = 3})
                _G.TargetSnowballKick = false
                return
            end

            OrionLib:MakeNotification({
                Name = "スノーボール",
                Content = TargetTabSelected .. " へ雪玉攻撃開始",
                Time = 2
            })

            task.spawn(function()
                local rs = game:GetService("ReplicatedStorage")
                local spawnRemote = rs:WaitForChild("MenuToys"):WaitForChild("SpawnToyRemoteFunction")
                local runService = game:GetService("RunService")
                local lp = game.Players.LocalPlayer

                while _G.TargetSnowballKick do
                    local target = game.Players:FindFirstChild(TargetTabSelected)
                    if not target or not target.Character then
                        runService.Heartbeat:Wait()
                        continue
                    end

                    local torso = target.Character:FindFirstChild("UpperTorso") or target.Character:FindFirstChild("Torso")
                    if not torso then
                        runService.Heartbeat:Wait()
                        continue
                    end

                    -- 雪玉を生成
                    pcall(function()
                        local offset = Vector3.new(
                            math.random(-30, 30) / 100,
                            math.random(-30, 30) / 100,
                            math.random(-30, 30) / 100
                        )
                        spawnRemote:InvokeServer("BallSnowball", torso.CFrame * CFrame.new(offset), Vector3.zero)
                    end)

                    -- 生成された自分の雪玉をターゲットに追従させる (オプショナルな物理効果)
                    local folder = workspace:FindFirstChild(lp.Name .. "SpawnedInToys")
                    if folder then
                        for _, toy in pairs(folder:GetChildren()) do
                            if toy.Name == "BallSnowball" then
                                local part = toy:IsA("BasePart") and toy or toy:FindFirstChildWhichIsA("BasePart")
                                if part then
                                    part.CFrame = torso.CFrame
                                    part.AssemblyLinearVelocity = Vector3.zero
                                end
                            end
                        end
                    end
                    runService.Heartbeat:Wait()
                end
            end)
        end
    end
})

-- ============================================================
-- 7. 2本手ループキック（トグル）
--    ブロブマンの両手を使って高速で掴む・離すを繰り返す
-- ============================================================
TargetTab:AddToggle({
    Name = "2本手ループキック",
    Default = false,
    Callback = function(Value)
        _G.TargetDualHandKick = Value
        if Value then
            if TargetTabSelected == "" then
                OrionLib:MakeNotification({Name = "エラー", Content = "先にターゲットを選択してください", Time = 3})
                _G.TargetDualHandKick = false
                return
            end

            local blob = getMyBlobman()
            if not blob then
                OrionLib:MakeNotification({Name = "エラー", Content = "Blobmanが見つかりません (乗ってるか確認)", Time = 3})
                _G.TargetDualHandKick = false
                return
            end

            OrionLib:MakeNotification({
                Name = "2本手キック",
                Content = TargetTabSelected .. " への両手攻撃開始",
                Time = 2
            })

            task.spawn(function()
                local scriptObj = blob:FindFirstChild("BlobmanSeatAndOwnerScript")
                local grab = scriptObj and scriptObj:FindFirstChild("CreatureGrab")
                local drop = scriptObj and scriptObj:FindFirstChild("CreatureDrop")
                
                local leftDet = blob:FindFirstChild("LeftDetector")
                local rightDet = blob:FindFirstChild("RightDetector")
                local leftWeld = leftDet and (leftDet:FindFirstChild("LeftWeld") or leftDet:FindFirstChildWhichIsA("Weld"))
                local rightWeld = rightDet and (rightDet:FindFirstChild("RightWeld") or rightDet:FindFirstChildWhichIsA("Weld"))

                if not grab or not drop or not leftDet or not rightDet then
                    OrionLib:MakeNotification({Name = "エラー", Content = "ブロブマンの機能が見つかりません", Time = 3})
                    _G.TargetDualHandKick = false
                    return
                end

                while _G.TargetDualHandKick do
                    local target = game.Players:FindFirstChild(TargetTabSelected)
                    if not target or not target.Character or not target.Character:FindFirstChild("HumanoidRootPart") then
                        task.wait(0.5)
                        continue
                    end

                    local tRoot = target.Character.HumanoidRootPart
                    local tHum = target.Character:FindFirstChild("Humanoid")
                    if tHum and tHum.Health > 0 then
                        pcall(function()
                            -- 左手で掴む・離す
                            grab:FireServer(leftDet, tRoot, leftWeld, 2)
                            grab:FireServer(leftDet, tRoot, leftWeld, 1)
                            task.wait(0.05)
                            drop:FireServer(leftWeld, tRoot)
                            
                            -- 右手で掴む・離す
                            grab:FireServer(rightDet, tRoot, rightWeld, 2)
                            grab:FireServer(rightDet, tRoot, rightWeld, 1)
                            task.wait(0.05)
                            drop:FireServer(rightWeld, tRoot)
                        end)
                    else
                        task.wait(0.5)
                    end
                    task.wait(0.1)
                end
            end)
        end
    end
})



--==============================
-- タブ：移動ハック（統合版）
--==============================
local MoveTab = Window:MakeTab({ 
    Name = "移動ハック", 
    Icon = "rbxassetid://4483345998" 
})

--==============================
-- セクション：基本移動ハック
--==============================
MoveTab:AddSection({ Name = "基本移動ハック" })

MoveTab:AddToggle({ 
    Name = "壁抜け (Noclip)", 
    Default = false, 
    Callback = function(v) 
        _G.Noclip = v 
    end 
})

game:GetService("RunService").Stepped:Connect(function()
    if _G.Noclip and game.Players.LocalPlayer.Character then
        for _, v in pairs(game.Players.LocalPlayer.Character:GetDescendants()) do
            if v:IsA("BasePart") then 
                v.CanCollide = false 
            end
        end
    end
end)

--==============================
-- セクション：各家へのダイレクトテレポート
--==============================
MoveTab:AddSection({ Name = "各家へのダイレクトテレポート" })

-- 1〜12 Plotボタン生成
for i = 1, 12 do
    MoveTab:AddButton({
        Name = "Plot " .. i .. " (家) へテレポート",
        Callback = function()
            local plotPath = workspace:FindFirstChild("Plots") 
                and workspace.Plots:FindFirstChild("Plot" .. i)
            
            if plotPath then
                local house = plotPath:FindFirstChild("House")
                local targetCFrame = nil
                
                if house and house:IsA("Model") then
                    local primary = house.PrimaryPart 
                        or house:FindFirstChildWhichIsA("BasePart", true)
                    if primary then 
                        targetCFrame = primary.CFrame 
                    end
                else
                    local base = plotPath:FindFirstChildWhichIsA("BasePart", true)
                    if base then 
                        targetCFrame = base.CFrame 
                    end
                end

                if targetCFrame then
                    game.Players.LocalPlayer.Character
                        .HumanoidRootPart.CFrame = targetCFrame + Vector3.new(0, 5, 0)

                    OrionLib:MakeNotification({
                        Name = "Teleport Success",
                        Content = "Plot " .. i .. " に移動しました",
                        Time = 2
                    })
                else
                    OrionLib:MakeNotification({
                        Name = "Error",
                        Content = "テレポート先のパーツが見つかりません",
                        Time = 2
                    })
                end
            else
                OrionLib:MakeNotification({
                    Name = "Error",
                    Content = "Plot " .. i .. " が存在しません",
                    Time = 2
                })
            end
        end
    })
end

--==============================
-- セクション：オーナー家テレポート
--==============================
MoveTab:AddSection({ Name = "プレイヤー家テレポート" })

MoveTab:AddButton({
    Name = "選択した家へテレポート",
    Callback = function()
        if selectedPlot == "" then
            OrionLib:MakeNotification({
                Name = "エラー", 
                Content = "先に家（プレイヤー名）を選んでください", 
                Time = 3
            })
            return
        end

        local targetPlayer = game.Players:FindFirstChild(selectedPlot)
        local plots = workspace:FindFirstChild("Plots")
        
        if plots then
            for _, plot in pairs(plots:GetChildren()) do
                local owner = plot:FindFirstChild("Owner")
                if owner and tostring(owner.Value) == selectedPlot then
                    local targetPos = plot.PrimaryPart 
                        and plot.PrimaryPart.CFrame 
                        or plot:FindFirstChildWhichIsA("BasePart").CFrame
                    
                    game.Players.LocalPlayer.Character
                        .HumanoidRootPart.CFrame = targetPos + Vector3.new(0, 3, 0)
                    
                    OrionLib:MakeNotification({
                        Name = "Teleport",
                        Content = selectedPlot .. " の家へ移動しました",
                        Time = 2
                    })
                    return
                end
            end
        end

        OrionLib:MakeNotification({
            Name = "Error", 
            Content = "プロットが見つかりませんでした", 
            Time = 3
        })
    end
})



--==============================
-- タブ：aura（統合版）
--==============================
local AuraTab = Window:MakeTab({ 
    Name = "aura", 
    Icon = "rbxassetid://6031064398" 
})

_G.isConstantAuraEnabled = false
_G.KillAuraEnabled = false
local autoVoidEnabled = false
local voidPower = 20000
local voidRange = 25

--==============================
-- セクション：Fling / Kill Aura
--==============================
AuraTab:AddSection({
    Name = "Fling / Kill Aura"
})

AuraTab:AddToggle({
    Name = "Flingオーラを有効化", 
    Default = false,
    Callback = function(Value)
        _G.isConstantAuraEnabled = Value
        if Value then
            task.spawn(function()
                while _G.isConstantAuraEnabled do
                    task.wait(0.05)
                    local lp = game.Players.LocalPlayer
                    local rs = game:GetService("ReplicatedStorage")
                    local SetNetworkOwner = rs:FindFirstChild("GrabEvents") 
                        and rs.GrabEvents:FindFirstChild("SetNetworkOwner")

                    if lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then
                        for _, player in ipairs(game.Players:GetPlayers()) do
                            if player ~= lp and player.Character 
                            and player.Character:FindFirstChild("HumanoidRootPart") then

                                local targetHRP = player.Character.HumanoidRootPart
                                if (targetHRP.Position - lp.Character.HumanoidRootPart.Position).Magnitude <= 25 then
                                    
                                    if SetNetworkOwner then 
                                        SetNetworkOwner:FireServer(targetHRP, targetHRP.CFrame) 
                                    end

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
                    task.wait(0.1)

                    local lp = game.Players.LocalPlayer
                    local replicatedStorage = game:GetService("ReplicatedStorage")
                    local combatEvent = replicatedStorage:FindFirstChild("Events") 
                        and replicatedStorage.Events:FindFirstChild("Combat") 
                        or replicatedStorage:FindFirstChild("HitEvent")

                    if lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then
                        for _, player in ipairs(game.Players:GetPlayers()) do
                            if player ~= lp and player.Character 
                            and player.Character:FindFirstChild("Humanoid") 
                            and player.Character:FindFirstChild("HumanoidRootPart") then

                                local targetHRP = player.Character.HumanoidRootPart
                                local distance = (targetHRP.Position - lp.Character.HumanoidRootPart.Position).Magnitude

                                if distance <= 20 
                                and player.Character.Humanoid.Health > 0 then

                                    pcall(function()

                                        if combatEvent then
                                            combatEvent:FireServer(player.Character, "Punch") 
                                        end

                                        local rs = game:GetService("ReplicatedStorage")
                                        local SetNetworkOwner = rs:FindFirstChild("GrabEvents") 
                                            and rs.GrabEvents:FindFirstChild("SetNetworkOwner")
                                        if SetNetworkOwner then
                                            SetNetworkOwner:FireServer(targetHRP, targetHRP.CFrame)
                                        end

                                        local bv = Instance.new("BodyVelocity", targetHRP)
                                        bv.MaxForce = Vector3.new(1e9, 1e9, 1e9)
                                        bv.Velocity = Vector3.new(0, -10, 0)
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
-- セクション：Void Aura
--==============================
AuraTab:AddSection({
    Name = "Void Aura"
})

AuraTab:AddToggle({
    Name = "Enable Auto-Void (Near Players)",
    Default = false,
    Callback = function(Value)
        autoVoidEnabled = Value
    end    
})

AuraTab:AddSlider({
    Name = "Void Range",
    Min = 5,
    Max = 50,
    Default = 25,
    Callback = function(Value)
        voidRange = Value
    end    
})

AuraTab:AddSlider({
    Name = "Ejection Power",
    Min = 5000,
    Max = 100000,
    Default = 20000,
    Callback = function(Value)
        voidPower = Value
    end    
})

--==============================
-- 自動射出ロジック（そのまま）
--==============================
task.spawn(function()
    while task.wait(0.1) do
        if autoVoidEnabled then
            local lp = game.Players.LocalPlayer
            if not lp.Character 
            or not lp.Character:FindFirstChild("HumanoidRootPart") then continue end
            
            local myRoot = lp.Character.HumanoidRootPart

            for _, p in pairs(game.Players:GetPlayers()) do
                if p ~= lp and p.Character 
                and p.Character:FindFirstChild("HumanoidRootPart") then

                    local targetRoot = p.Character.HumanoidRootPart
                    local dist = (targetRoot.Position - myRoot.Position).Magnitude

                    if dist <= voidRange then
                        game.ReplicatedStorage.PlayerEvents.RagdollPlayer:FireServer(p.Character)
                        game.ReplicatedStorage.GrabEvents.CreateGrabLine:FireServer(targetRoot)

                        targetRoot.Velocity = Vector3.new(voidPower, voidPower, voidPower)
                        targetRoot.RotVelocity = Vector3.new(voidPower, voidPower, voidPower)

                        game.ReplicatedStorage.CharacterEvents.Struggle:FireServer()
                    end
                end
            end
        end
    end
end)



-- [[ Anti-Grab Pro タブ ]]
local AntiTab = Window:MakeTab({
    Name = "Anti-",
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

-- ============================================================
-- Anti Blobman & Anti Explode (エラー修正・ボタン表示確定版)
-- ============================================================

local Player = game.Players.LocalPlayer
local antiBlob1T = false

-- パーツがなくてもエラーを出さない監視関数
local function antiBlob1F()
    antiBlob1T = true
    workspace.DescendantAdded:Connect(function(toy)
        if toy.Name == "CreatureBlobman" and antiBlob1T then
            -- pcallを使ってパーツがない時のエラーを完全に防ぐ
            pcall(function()
                if toy:FindFirstChild("LeftDetector") then toy.LeftDetector:Destroy() end
                if toy:FindFirstChild("RightDetector") then toy.RightDetector:Destroy() end
            end)
        end
    end)
end

-- ボタン1: Anti Blobman (変数名 invulnerabilitySection が正しいことを確認済み)
if invulnerabilitySection then
    invulnerabilitySection:AddToggle({
        Name = "Anti Blobman", 
        Default = false,
        Callback = function(on)
            if on then
                antiBlob1F()
            else
                antiBlob1T = false
            end
        end
    })
end

local antiExplodeT = false
local function antiExplodeF()
    antiExplodeT = true
    local char = Player.Character
    if not char then return end
    local hrp = char:WaitForChild("HumanoidRootPart")
    
    workspace.ChildAdded:Connect(function(model)
        if model.Name == "Part" and antiExplodeT then
            pcall(function()
                local mag = (model.Position - hrp.Position).Magnitude
                if mag <= 20 then
                    hrp.Anchored = true
                    task.wait(0.01)
                    -- 腕のパーツが存在するかチェックしながらループ
                    while antiExplodeT and char:FindFirstChild("Right Arm") and 
                          char["Right Arm"]:FindFirstChild("RagdollLimbPart") and 
                          char["Right Arm"].RagdollLimbPart.CanCollide do
                        task.wait(0.01)
                    end
                    hrp.Anchored = false
                end
            end)
        end
    end)
end

-- ボタン2: Anti Explode
if invulnerabilitySection then
    invulnerabilitySection:AddToggle({
        Name = "Anti Explode",
        Default = false,
        Callback = function(on)
            if on then
                antiExplodeF()
            else
                antiExplodeT = false
            end
        end
    })
end

-- ============================================================
-- Shuriken Anti Kick (ロジック完全維持版)
-- ============================================================

local tpActive = false -- 変数の定義

invulnerabilitySection:AddToggle({
    Name = "Anti Kick (Shuriken)",
    Default = false,
    Callback = function(Value)
        _G.ShurikenAntiKick = Value
        
        -- ローカル関数の定義
        local function ClearKunai()
            local plr = game.Players.LocalPlayer
            local inv = workspace:FindFirstChild(plr.Name .. "SpawnedInToys")
            local destroyrem = game.ReplicatedStorage:FindFirstChild("MenuToys") and game.ReplicatedStorage.MenuToys:FindFirstChild("DestroyToy")
            if inv and destroyrem then
                for _, v in pairs(inv:GetChildren()) do
                    if v.Name == "AntiKick" or v.Name == "NinjaShuriken" then
                        pcall(function()
                            destroyrem:FireServer(v)
                        end)
                    end
                end
            end
        end

        if Value then
            task.spawn(function()
                local plr = game.Players.LocalPlayer
                local ReplicatedStorage = game:GetService("ReplicatedStorage")
                local setOwner = ReplicatedStorage:WaitForChild("GrabEvents"):WaitForChild("SetNetworkOwner")
                local stickyEvent = ReplicatedStorage:WaitForChild("PlayerEvents"):WaitForChild("StickyPartEvent")
                local spawnRemote = ReplicatedStorage.MenuToys.SpawnToyRemoteFunction
                local destroyrem = ReplicatedStorage:WaitForChild("MenuToys"):WaitForChild("DestroyToy")
                local canSpawn = plr:WaitForChild("CanSpawnToy")

                local function getHRP()
                    if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                        return plr.Character.HumanoidRootPart
                    else
                        local character = plr.CharacterAdded:Wait()
                        return character:WaitForChild("HumanoidRootPart")
                    end
                end

                local function CheckForHome()
                    if not workspace.PlotItems.PlayersInPlots:FindFirstChild(plr.Name) then
                        return false
                    end
                    for _, v in pairs(workspace.Plots:GetChildren()) do
                        local sign = v:FindFirstChild("PlotSign")
                        local owners = sign and sign:FindFirstChild("ThisPlotsOwners")
                        if owners then
                            for _, b in pairs(owners:GetChildren()) do
                                if b.Value == plr.Name then
                                    local folder = workspace.PlotItems:FindFirstChild(v.Name)
                                    if folder then
                                        return true, folder
                                    end
                                end
                            end
                        end
                    end
                    return false
                end

                local function StickKunai(kunai)
                    if not kunai or not kunai:FindFirstChild("StickyPart") then
                        return
                    end
                    local currentHRP = getHRP()
                    if not currentHRP then
                        return
                    end
                    if kunai:FindFirstChild("SoundPart") then
                        if not kunai.SoundPart:FindFirstChild("PartOwner") or kunai.SoundPart.PartOwner.Value ~= plr.Name then
                            setOwner:FireServer(kunai.SoundPart, kunai.SoundPart.CFrame)
                        end
                    end
                    local firePart = currentHRP:FindFirstChild("FirePlayerPart") or currentHRP:WaitForChild("FirePlayerPart", 5)
                    if firePart then
                        stickyEvent:FireServer(
                                kunai.StickyPart,
                                firePart,
                                CFrame.new(0, 0, 0) * CFrame.Angles(0, math.rad(90), math.rad(90))
                            )
                    end
                    for _, obj in pairs(kunai:GetChildren()) do
                        if obj.Name == "Pyramid" then
                            obj.CanTouch = false;
                            obj.CanCollide = false;
                            obj.CanQuery = false;
                            obj.Transparency = 0
                            if not obj:FindFirstChild("Highlight") then
                                local high = Instance.new("Highlight", obj)
                                high.FillColor = Color3.fromRGB(0, 0, 0)
                            end
                        elseif obj.Name == "Main" then
                            obj.CanTouch = false;
                            obj.CanCollide = false;
                            obj.CanQuery = false;
                            obj.Transparency = 0
                            if not obj:FindFirstChild("Highlight") then
                                local high = Instance.new("Highlight", obj)
                                high.FillColor = Color3.fromRGB(255, 255, 255)
                            end
                        elseif obj:IsA("BasePart") then
                            obj.CanTouch = false;
                            obj.CanCollide = false;
                            obj.CanQuery = false;
                            obj.Transparency = 1
                        end
                    end
                end

                local function SpawnToy(name)
                    local t = tick()
                    while not canSpawn.Value do
                        if not _G.ShurikenAntiKick or tick() - t > 5 then
                            return nil
                        end
                        task.wait(0.1)
                    end
                    local currentHRP = getHRP()
                    if currentHRP then
                        task.spawn(function()
                            pcall(function()
                                spawnRemote:InvokeServer(name, currentHRP.CFrame * CFrame.new(0, 12, 20), Vector3.new(0, 0, 0))
                            end)
                        end)
                    end
                    local boolik, house = CheckForHome()
                    local inv = workspace:FindFirstChild(plr.Name .. "SpawnedInToys")
                    if boolik and house then
                        return house:WaitForChild(name, 2)
                    elseif not workspace.PlotItems.PlayersInPlots:FindFirstChild(plr.Name) and inv then
                        return inv:WaitForChild(name, 2)
                    end
                    return nil
                end

                while _G.ShurikenAntiKick do
                    task.wait(0.005)
                    if not plr.Character or not plr.Character:FindFirstChild("Humanoid") or plr.Character.Humanoid.Health <= 0 then
                        continue
                    end
                    local inv = workspace:FindFirstChild(plr.Name .. "SpawnedInToys")
                    local kunai = inv and inv:FindFirstChild("NinjaShuriken")
                    if workspace.PlotItems.PlayersInPlots:FindFirstChild(plr.Name) then
                        local boolik, house = CheckForHome()
                        if boolik and house and workspace.Plots:FindFirstChild(house.Name) then
                            local sign = workspace.Plots[house.Name]:FindFirstChild("PlotSign")
                            if sign and sign.ThisPlotsOwners.Value.TimeRemainingNum.Value > 89 then
                                kunai = SpawnToy("NinjaShuriken")
                                if kunai == nil then
                                    continue
                                end
                                kunai.Name = "AntiKick"
                                StickKunai(kunai)
                            end
                        end
                    end
                    if not kunai then
                        if workspace.PlotItems.PlayersInPlots:FindFirstChild(plr.Name) then
                            continue
                        end
                        kunai = SpawnToy("NinjaShuriken")
                        if kunai == nil then
                            continue
                        end
                        kunai.Name = "AntiKick"
                        if not kunai then
                            continue
                        end
                    end
                    repeat
                        if kunai and kunai:FindFirstChild("StickyPart") and kunai.StickyPart.CanTouch == true then
                            StickKunai(kunai)
                            kunai.Name = "AntiKick"
                        end
                        task.wait(0.3)
                    until not kunai or not _G.ShurikenAntiKick
                            or not kunai:FindFirstChild("StickyPart")
                            or kunai.StickyPart.CanTouch == false 
                            or not plr.Character or not plr.Character:FindFirstChild("HumanoidRootPart") 
                            or not kunai:FindFirstChild("StickyPart") 
                            or (plr.Character.HumanoidRootPart.Position - kunai.StickyPart.Position).Magnitude >= 20
                    if not kunai or not kunai:FindFirstChild("StickyPart") or not plr.Character or not plr.Character:FindFirstChild("HumanoidRootPart") or (plr.Character.HumanoidRootPart.Position - kunai.StickyPart.Position).Magnitude >= 20 then
                        ClearKunai()
                    end
                    pcall(function()
                        repeat
                            task.wait(0.05)
                        until not _G.ShurikenAntiKick or not plr.Character or not plr.Character:FindFirstChild("Humanoid") or not kunai or not kunai:FindFirstChild("StickyPart") or not kunai.StickyPart:FindFirstChild("StickyWeld") or not kunai.StickyPart.StickyWeld.Part1
                        if not kunai or not kunai:FindFirstChild("StickyPart") or (plr.Character and plr.Character:FindFirstChild("Humanoid") and plr.Character.Humanoid.Health <= 0) or not kunai["StickyPart"]:FindFirstChild("StickyWeld").Part1 then
                            ClearKunai()
                        end
                    end)
                end
            end)
        else
            _G.ShurikenAntiKick = false
            ClearKunai()
        end
    end
})

-- ============================================================
-- Anti Lag (Grab Line Destroy)
-- ============================================================

do
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local createGrabLineCopy
    local extendGrabLineCopy

    -- 初回バックアップ
    local grabFolder = ReplicatedStorage:FindFirstChild("GrabEvents")
    if grabFolder then
        local originalCreate = grabFolder:FindFirstChild("CreateGrabLine")
        local originalExtend = grabFolder:FindFirstChild("ExtendGrabLine")

        if originalCreate then
            createGrabLineCopy = originalCreate:Clone()
        end
        if originalExtend then
            extendGrabLineCopy = originalExtend:Clone()
        end
    end

    invulnerabilitySection:AddToggle({
        Name = "Anti Lag (Grab Line)",
        Default = false,
        Callback = function(Value)
            local grabFolder = ReplicatedStorage:FindFirstChild("GrabEvents")
            if not grabFolder then return end

            if Value then
                -- Destroy
                local create = grabFolder:FindFirstChild("CreateGrabLine")
                local extend = grabFolder:FindFirstChild("ExtendGrabLine")

                if create and create:IsA("RemoteEvent") then
                    pcall(function() create:Destroy() end)
                end
                if extend and extend:IsA("RemoteEvent") then
                    pcall(function() extend:Destroy() end)
                end

                for _, v in ipairs(workspace:GetDescendants()) do
                    if v:IsA("Beam") or v.Name:lower():find("line") then
                        pcall(function() v:Destroy() end)
                    end
                end

            else
                -- Restore
                if createGrabLineCopy and not grabFolder:FindFirstChild("CreateGrabLine") then
                    pcall(function()
                        createGrabLineCopy:Clone().Parent = grabFolder
                    end)
                end

                if extendGrabLineCopy and not grabFolder:FindFirstChild("ExtendGrabLine") then
                    pcall(function()
                        extendGrabLineCopy:Clone().Parent = grabFolder
                    end)
                end
            end
        end
    })
end

-- ============================================================
-- Anti Burn
-- ============================================================

do
    local Player = game.Players.LocalPlayer
    local hookBurnConn

    invulnerabilitySection:AddToggle({
        Name = "Anti Burn",
        Default = false,
        Callback = function(on)
            if on then
                if Player.Character then
                    pcall(function()
                        hookBurn(Player.Character)
                    end)
                end
            else
                if hookBurnConn then
                    pcall(function()
                        hookBurnConn:Disconnect()
                    end)
                    hookBurnConn = nil
                end
            end
        end
    })
end

-- ============================================================
-- Anti Sticky
-- ============================================================

do
    local Player = game.Players.LocalPlayer
    local antiStickyT = false

    invulnerabilitySection:AddToggle({
        Name = "Anti Sticky",
        Default = false,
        Callback = function(Value)
            antiStickyT = Value

            local ps = Player:FindFirstChild("PlayerScripts")
            if ps and ps:FindFirstChild("StickyPartsTouchDetection") then
                pcall(function()
                    ps.StickyPartsTouchDetection.Disabled = Value
                end)
            end
        end
    })
end

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

--==============================
-- タブ：ブロブマン設定
--==============================
local BlobTab = Window:MakeTab({ Name = "ブロブマン設定", Icon = "rbxassetid://4483345998" })

local SelectedPlayer = ""
local players = game:GetService("Players")
local lp = players.LocalPlayer

-- 1. スピード調整
BlobTab:AddSlider({
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
            local hum = char.Humanoid
            if hum.SeatPart and (hum.SeatPart.Parent.Name == "Blobman" or hum.SeatPart.Parent.Name == "CreatureBlobman") then
                hum.WalkSpeed = _G.BlobSpeed or 16
            end
        end
    end
end)

-- 2. 飛行モード
BlobTab:AddToggle({
    Name = "ブロブマン飛行モード",
    Default = false,
    Callback = function(v)
        _G.BlobFly = v
        if v then
            local char = lp.Character
            if not char or not char:FindFirstChild("HumanoidRootPart") then return end
            
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
                if bg then bg:Destroy() end
                if bv then bv:Destroy() end
            end)
        end
    end
})

BlobTab:AddSection({ Name = "ループ掴み (セーフゾーン無視)" })

local PlayerDropdown = BlobTab:AddDropdown({
    Name = "ターゲット選択",
    Default = "",
    Options = {"プレイヤーを更新してください"}, 
    Callback = function(Value) 
        SelectedPlayer = Value 
    end    
})

BlobTab:AddButton({
    Name = "プレイヤーリスト更新",
    Callback = function()
        local pList = {}
        for _, p in pairs(game.Players:GetPlayers()) do
            if p ~= lp then 
                table.insert(pList, p.Name) 
            end
        end
        PlayerDropdown:Refresh(pList, true)
    end
})

BlobTab:AddToggle({
    Name = "指定プレイヤーをループ掴み",
    Default = false,
    Callback = function(Value)
        _G.LoopGrabTarget = Value
        if Value then
            task.spawn(function()
                while _G.LoopGrabTarget do
                    local target = players:FindFirstChild(SelectedPlayer)
                    local seat = lp.Character and lp.Character.Humanoid.SeatPart
                    if target and target.Character and seat and seat.Parent then
                        local blobman = seat.Parent
                        local remote = blobman.BlobmanSeatAndOwnerScript:FindFirstChild("CreatureGrab")
                        local targetHRP = target.Character:FindFirstChild("HumanoidRootPart")
                        if remote and targetHRP then
                            for _, arm in ipairs({"Left", "Right"}) do
                                local det = blobman:FindFirstChild(arm .. "Detector")
                                local weld = det and (det:FindFirstChild(arm .. "Weld") or det:FindFirstChildWhichIsA("Weld"))
                                if det and weld then
                                    remote:FireServer(det, targetHRP, weld, 2)
                                    remote:FireServer(det, targetHRP, weld, 1)
                                end
                            end
                        end
                    end
                    task.wait(0.05)
                end
            end)
        end
    end
})

BlobTab:AddToggle({
    Name = "全員を高速ループ掴み",
    Default = false,
    Callback = function(Value)
        _G.BringAllLoop = Value
        if Value then
            task.spawn(function()
                while _G.BringAllLoop do
                    local seat = lp.Character and lp.Character.Humanoid.SeatPart
                    if seat and seat.Parent then
                        local blobman = seat.Parent
                        local remote = blobman.BlobmanSeatAndOwnerScript:FindFirstChild("CreatureGrab")
                        if remote then
                            for _, p in pairs(players:GetPlayers()) do
                                if not _G.BringAllLoop then break end
                                if p ~= lp and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                                    if _G.WhitelistFriends2 and lp:IsFriendsWith(p.UserId) then continue end
                                    local targetHRP = p.Character.HumanoidRootPart
                                    for _, arm in ipairs({"Left", "Right"}) do
                                        local det = blobman:FindFirstChild(arm .. "Detector")
                                        local weld = det and (det:FindFirstChild(arm .. "Weld") or det:FindFirstChildWhichIsA("Weld"))
                                        if det and weld then
                                            remote:FireServer(det, targetHRP, weld, 2)
                                            remote:FireServer(det, targetHRP, weld, 1)
                                        end
                                    end
                                end
                            end
                        end
                    end
                    task.wait(0.1)
                end
            end)
        end
    end
})

-- [[ 3. UI構築 (WindUIロジック完全移植版) ]]

-- サービス管理メタテーブル（提供コードを維持）
local service = setmetatable({}, {
    __index = function(self, k)
        local s = game:GetService(k)
        rawset(self, k, s)
        return s
    end,
})

-- ユーティリティ関数（提供コードを維持）
local get = game.FindFirstChild
local function getLocalPlayer() return service.Players.LocalPlayer end
local function getLocalChar() return getLocalPlayer().Character end
local function getLocalRoot()
    if not getLocalChar() then return end
    return get(getLocalChar(), "HumanoidRootPart") or get(getLocalChar(), "Torso")
end

local function getInv()
    return get(workspace, getLocalPlayer().Name .. "SpawnedInToys")
end

local function SetNetworkOwner(part)
    service.ReplicatedStorage.GrabEvents.SetNetworkOwner:FireServer(part, getLocalRoot().CFrame)
end

local function ungrab(part)
    service.ReplicatedStorage.GrabEvents.DestroyGrabLine:FireServer(part)
end

-- Blobman取得ロジック（中身維持）
local function getBlobman()
    local v = get(getInv(), "CreatureBlobman", true)
    if not v then
        for _, p in ipairs(workspace.PlotItems:GetChildren()) do
            local m = get(p, "CreatureBlobman")
            if m and m.PlayerValue.Value == getLocalPlayer().Name then
                v = m
                break
            end
        end
    end
    return v
end

-- 操作ロジック（中身維持）
local function blobGrab(blob, target, side)
    local detector = get(blob, side .. "Detector")
    local args = {
        [1] = detector,
        [2] = target,
        [3] = detector and get(detector, side .. "Weld")
    }
    if blob:FindFirstChild("BlobmanSeatAndOwnerScript") then
        blob.BlobmanSeatAndOwnerScript.CreatureGrab:FireServer(unpack(args))
    end
end

local function blobBring(blob, target, side)
    local root = getLocalRoot()
    if not root or not target then return end
    local pos = root.CFrame
    root.CFrame = target.CFrame
    task.wait(0.2)
    blobGrab(blob, target, side)
    task.wait(0.2)
    root.CFrame = pos
end

local function blobKickOptimized(blob, target, side)
    blobGrab(blob, getLocalRoot(), side)
    task.wait(0.05)
    SetNetworkOwner(target)
    task.wait(0.05)
    target.CFrame += Vector3.new(0, 20, 0)
    task.wait(0.05)
    ungrab(target)
    blobGrab(blob, target, side)
end

-- --- UI構築 (Orion UI) ---
local BlobmanTab = Window:MakeTab({
    Name = "Blobman 2",
    Icon = "rbxassetid://6031064398",
    PremiumOnly = false
})

-- 変数
local kickAuraEnabled = false

-- セクション：メイン機能
local MainSection = BlobmanTab:AddSection({
    Name = "ens Hub Functions"
})

-- BRING ALL ボタン
MainSection:AddButton({
    Name = "BRING ALL (全員引き寄せ)",
    Callback = function()
        local blob = getBlobman()
        if not blob then
            OrionLib:MakeNotification({Name = "Error", Content = "Blobman not found!", Time = 5})
            return
        end

        OrionLib:MakeNotification({Name = "Success", Content = "Starting BRING ALL...", Time = 3})
        
        local playersList = service.Players:GetPlayers()
        local lp = getLocalPlayer()

        for _, player in ipairs(playersList) do
            if player ~= lp and player.Character then
                local targetRoot = get(player.Character, "HumanoidRootPart")
                if targetRoot then
                    blobBring(blob, targetRoot, "Left")
                    task.wait(0.15)
                end
            end
        end
        OrionLib:MakeNotification({Name = "Success", Content = "BRING ALL Completed!", Time = 3})
    end
})

-- Kick Aura トグル
MainSection:AddToggle({
    Name = "Kick Aura",
    Default = false,
    Callback = function(value)
        kickAuraEnabled = value
        local status = value and "Enabled" or "Disabled"
        OrionLib:MakeNotification({Name = "Aura", Content = "Kick Aura " .. status, Time = 3})
    end
})

-- Kick Aura のループ処理 (バックグラウンドで動作)
task.spawn(function()
    while true do
        if kickAuraEnabled then
            local blob = getBlobman()
            local root = getLocalRoot()
            if blob and root then
                for _, player in ipairs(service.Players:GetPlayers()) do
                    if player ~= getLocalPlayer() and player.Character then
                        local targetRoot = get(player.Character, "HumanoidRootPart")
                        if targetRoot and (targetRoot.Position - root.Position).Magnitude < 30 then
                            blobKickOptimized(blob, targetRoot, "Right")
                            task.wait(0.1)
                        end
                    end
                end
            end
        end
        task.wait(0.1)
    end
end)

--==============================
-- タブ：Wings & Orbit Hub（統合タブ）
-- ※ OrionLib:Init() の前に挿入してください
--==============================

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

--==================================================
-- 共通ユーティリティ
--==================================================
local function _getBasePart(obj)
    if obj:IsA("Model") then
        return obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
    elseif obj:IsA("BasePart") then
        return obj
    end
    return nil
end

local function _setupBodyMovers(part)
    if not part then return nil, nil end
    local existBP = part:FindFirstChildOfClass("BodyPosition")
    local existBG = part:FindFirstChildOfClass("BodyGyro")
    if existBP then existBP:Destroy() end
    if existBG then existBG:Destroy() end
    local BP = Instance.new("BodyPosition")
    BP.P = 25000; BP.D = 800
    BP.MaxForce = Vector3.new(1,1,1) * 1e10
    BP.Parent = part
    local BG = Instance.new("BodyGyro")
    BG.P = 25000; BG.D = 800
    BG.MaxTorque = Vector3.new(1,1,1) * 1e10
    BG.Parent = part
    return BP, BG
end

local function _setupObj(obj)
    local base = _getBasePart(obj)
    if not base then return nil end
    if obj:IsA("Model") then
        for _, c in ipairs(obj:GetDescendants()) do
            if c:IsA("BasePart") then
                c.CanCollide = false; c.CanTouch = false; c.Anchored = false
            end
        end
    else
        base.CanCollide = false; base.CanTouch = false; base.Anchored = false
    end
    local BP, BG = _setupBodyMovers(base)
    return { BP = BP, BG = BG, Part = base, Original = obj }
end

local function _findByName(name)
    local found = {}
    for _, item in ipairs(workspace:GetDescendants()) do
        if (item:IsA("BasePart") or item:IsA("Model")) and item.Name == name then
            table.insert(found, item)
        end
    end
    return found
end

local function _getTargetChar(targetPlayer)
    if targetPlayer and targetPlayer.Character then return targetPlayer.Character end
    return LocalPlayer.Character
end

--==================================================
-- [A] FireworkSparkler 設定
--==================================================
local fwConfig = {
    enabled = false,
    targetPlayer = nil,
    targetPartName = "FireworkSparkler",
    maxSparklers = 20,
    spacing = 1.2,
    heightOffset = 1,
    forwardOffset = 4,
    waveSpeed = 2.5,
    baseAmplitude = 2,
    distanceMultiplier = 0.4,
    phaseOffset = 0.3,
    horizontalWaveAmount = 0.5,
    smoothness = 0.6,
    xRotation = -45,
    yRotation = 0,
    zRotation = 90,
}
local fwToys = {}
local fwRowPoints = {}
local fwAssigned = {}
local fwTime = 0

local function fwFindSparklers()
    local toys = {}
    for _, item in ipairs(workspace:GetDescendants()) do
        if item:IsA("Model") and item.Name == fwConfig.targetPartName then
            local dup = false
            for _, e in ipairs(toys) do if e == item then dup = true break end end
            if not dup then table.insert(toys, item) end
        end
    end
    table.sort(toys, function(a,b) return a.Name < b.Name end)
    return toys
end

local function fwCP()
    local p = Instance.new("Part")
    p.CanCollide = false; p.Anchored = true; p.Transparency = 1
    p.Size = Vector3.new(4,1,4); p.Parent = workspace
    return p
end

local function fwCBM(part)
    if not part then return nil, nil end
    local eBG = part:FindFirstChildOfClass("BodyGyro")
    local eBP = part:FindFirstChildOfClass("BodyPosition")
    if eBG and eBP then return eBG, eBP end
    if eBG then eBG:Destroy() end
    if eBP then eBP:Destroy() end
    local BP = Instance.new("BodyPosition")
    BP.P = 25000; BP.D = 800
    BP.MaxForce = Vector3.new(1,1,1) * 1e10; BP.Parent = part
    local BG = Instance.new("BodyGyro")
    BG.P = 25000; BG.D = 800
    BG.MaxTorque = Vector3.new(1,1,1) * 1e10; BG.Parent = part
    return BG, BP
end

local function fwGetPrimary(model)
    if model.PrimaryPart then return model.PrimaryPart end
    for _, n in ipairs({"Handle","Main","Part","Base","Sparkler","Firework"}) do
        local p = model:FindFirstChild(n)
        if p and p:IsA("BasePart") then return p end
    end
    for _, c in ipairs(model:GetChildren()) do
        if c:IsA("BasePart") then return c end
    end
    return nil
end

local function fwCreateRowPoints(count)
    local points = {}
    if count == 0 then return points end
    local half = math.floor(count / 2)
    local isOdd = count % 2 == 1
    local idx = 1
    if isOdd then
        table.insert(points, { baseOffsetX = 0, part = fwCP(), index = idx }); idx += 1
    end
    for i = 1, half do
        local off = i * fwConfig.spacing
        table.insert(points, { baseOffsetX = off, part = fwCP(), index = idx }); idx += 1
        table.insert(points, { baseOffsetX = -off, part = fwCP(), index = idx }); idx += 1
    end
    return points
end

local function fwDisable()
    for _, point in ipairs(fwRowPoints) do
        if point.assignedToy and point.assignedToy.Pallet then
            if point.assignedToy.BP then point.assignedToy.BP:Destroy(); point.assignedToy.BP = nil end
            if point.assignedToy.BG then point.assignedToy.BG:Destroy(); point.assignedToy.BG = nil end
            for _, c in ipairs(point.assignedToy.Model:GetChildren()) do
                if c:IsA("BasePart") then
                    c.Anchored = true
                    c.Velocity = Vector3.new(0,0,0)
                    c.RotVelocity = Vector3.new(0,0,0)
                end
            end
        end
    end
end

local function fwEnable()
    for _, point in ipairs(fwRowPoints) do
        if point.assignedToy and point.assignedToy.Pallet then
            for _, c in ipairs(point.assignedToy.Model:GetChildren()) do
                if c:IsA("BasePart") then c.Anchored = false end
            end
            local BG, BP = fwCBM(point.assignedToy.Pallet)
            point.assignedToy.BG = BG; point.assignedToy.BP = BP
        end
    end
end

local function fwAssignToPoints()
    local assigned = {}
    local character = _getTargetChar(fwConfig.targetPlayer)
    if not character then return assigned end
    local hrp = character:FindFirstChild("HumanoidRootPart")
    local torso = character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso")
    if not hrp or not torso then return assigned end
    local charCF = hrp.CFrame
    local basePos = torso.Position + Vector3.new(0, fwConfig.heightOffset, 0) + charCF.LookVector * fwConfig.forwardOffset
    for i = 1, math.min(#fwToys, #fwRowPoints) do
        local toy = fwToys[i]
        if toy and toy:IsA("Model") and toy.Name == fwConfig.targetPartName then
            local primary = fwGetPrimary(toy)
            if primary then
                for _, c in ipairs(toy:GetChildren()) do
                    if c:IsA("BasePart") then c.CanCollide = false; c.CanTouch = false; c.Anchored = false end
                end
                local BG, BP = fwCBM(primary)
                local initPos = basePos + charCF.RightVector * fwRowPoints[i].baseOffsetX
                local t = {
                    BG = BG, BP = BP, Pallet = primary, Model = toy,
                    offsetX = fwRowPoints[i].baseOffsetX,
                    baseOffsetX = fwRowPoints[i].baseOffsetX,
                    index = fwRowPoints[i].index,
                }
                if BP then BP.Position = initPos end
                if BG then
                    local cf = CFrame.new(initPos)
                    local _, pYR, _ = charCF:ToOrientation()
                    cf = cf * CFrame.Angles(0, pYR + math.rad(fwConfig.yRotation), 0)
                    cf = cf * CFrame.Angles(math.rad(fwConfig.xRotation), 0, 0)
                    cf = cf * CFrame.Angles(0, 0, math.rad(fwConfig.zRotation))
                    BG.CFrame = cf
                end
                fwRowPoints[i].assignedToy = t
                table.insert(assigned, t)
            end
        end
    end
    return assigned
end

local function fwRefresh()
    fwToys = fwFindSparklers()
    fwRowPoints = fwCreateRowPoints(math.min(#fwToys, fwConfig.maxSparklers))
    fwAssigned = fwAssignToPoints()
end

local function fwGetPlayerList()
    local list = {"自分"}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then table.insert(list, p.Name) end
    end
    return list
end

-- 初期化
fwRefresh()
workspace.DescendantAdded:Connect(function(d)
    if d:IsA("Model") and d.Name == fwConfig.targetPartName then
        task.wait(0.5); fwRefresh()
    end
end)

--==================================================
-- [B] Part Orbit 設定
--==================================================
local orbitConfig = {
    enabled = false,
    targetPartName = "PalletLightBrown",
    shape = "Circle",
    radius = 5,
    height = 0,
    speed = 1,
    count = 8,
    scale = 1,
    yRotation = 0,
    waveAmplitude = 2,
    waveFrequency = 2,
    helixHeight = 5,
    starPoints = 5,
    starInnerRadius = 2,
    faceCenter = false,
    useAllFound = true,
}
local orbitParts = {}
local orbitTime = 0
local orbitConnection = nil

local function getOrbitPos(index, total, t, charPos, charCF)
    local angle = (index - 1) / total * math.pi * 2
    local r = orbitConfig.radius * orbitConfig.scale
    local x, y, z = 0, orbitConfig.height, 0
    local shape = orbitConfig.shape

    if shape == "Circle" then
        local a = angle + t * orbitConfig.speed
        x = math.cos(a) * r; z = math.sin(a) * r; y = orbitConfig.height
    elseif shape == "Wings" then
        local a = angle + t * orbitConfig.speed
        local wing = math.sin(a * 2)
        x = math.cos(a) * r * (1 + 0.5 * math.abs(wing))
        z = math.sin(a) * r * 0.4
        y = orbitConfig.height + math.sin(a * 2) * orbitConfig.waveAmplitude
    elseif shape == "Figure8" then
        local a = t * orbitConfig.speed + angle
        x = math.sin(a) * r; z = math.sin(a * 2) * r * 0.5; y = orbitConfig.height
    elseif shape == "Helix" then
        local a = angle + t * orbitConfig.speed
        x = math.cos(a) * r; z = math.sin(a) * r
        local prog = ((t * orbitConfig.speed * 0.3) % 1)
        y = orbitConfig.height + (prog * orbitConfig.helixHeight) - (orbitConfig.helixHeight / 2)
        y = y + (index / total) * orbitConfig.helixHeight
    elseif shape == "Star" then
        local pts = orbitConfig.starPoints
        local innerR = orbitConfig.starInnerRadius * orbitConfig.scale
        local a = angle + t * orbitConfig.speed
        local pA = (math.pi * 2) / pts
        local lA = a % pA
        local blend = lA / pA
        local dist = innerR + (r - innerR) * math.abs(math.sin(blend * math.pi))
        x = math.cos(a) * dist; z = math.sin(a) * dist; y = orbitConfig.height
    elseif shape == "Wave" then
        local a = angle + t * orbitConfig.speed
        x = math.cos(a) * r; z = math.sin(a) * r
        y = orbitConfig.height + math.sin(a * orbitConfig.waveFrequency + t * orbitConfig.speed) * orbitConfig.waveAmplitude
    elseif shape == "Sphere" then
        local phi = angle
        local theta = (index / total) * math.pi + t * orbitConfig.speed * 0.3
        x = r * math.sin(theta) * math.cos(phi + t * orbitConfig.speed)
        z = r * math.sin(theta) * math.sin(phi + t * orbitConfig.speed)
        y = orbitConfig.height + r * math.cos(theta)
    elseif shape == "DNA" then
        local a = angle + t * orbitConfig.speed
        local strand = (index % 2 == 0) and 1 or -1
        x = math.cos(a + strand * math.pi) * r
        z = math.sin(a + strand * math.pi) * r * 0.3
        y = orbitConfig.height + (a / (math.pi * 2)) * orbitConfig.helixHeight * 0.5
    end

    local yOff = math.rad(orbitConfig.yRotation)
    local rx = x * math.cos(yOff) - z * math.sin(yOff)
    local rz = x * math.sin(yOff) + z * math.cos(yOff)
    x, z = rx, rz
    local _, cYR, _ = charCF:ToOrientation()
    local fx = x * math.cos(cYR) - z * math.sin(cYR)
    local fz = x * math.sin(cYR) + z * math.cos(cYR)
    return charPos + Vector3.new(fx, y, fz)
end

local function orbitStop()
    if orbitConnection then orbitConnection:Disconnect(); orbitConnection = nil end
    for _, obj in ipairs(orbitParts) do
        if obj.BP and obj.BP.Parent then obj.BP:Destroy() end
        if obj.BG and obj.BG.Parent then obj.BG:Destroy() end
        if obj.Part and obj.Part.Parent then obj.Part.Anchored = true end
    end
    orbitParts = {}
end

local function orbitStart()
    orbitStop()
    local found = _findByName(orbitConfig.targetPartName)
    if #found == 0 then
        OrionLib:MakeNotification({ Name = "エラー", Content = "'" .. orbitConfig.targetPartName .. "' が見つかりません", Time = 3 })
        return
    end
    local useCount = orbitConfig.useAllFound and #found or math.min(orbitConfig.count, #found)
    for i = 1, useCount do
        local obj = _setupObj(found[i])
        if obj then table.insert(orbitParts, obj) end
    end
    OrionLib:MakeNotification({ Name = "Orbit開始", Content = #orbitParts .. "個 / 形状: " .. orbitConfig.shape, Time = 2 })
    orbitTime = 0
    orbitConnection = RunService.RenderStepped:Connect(function(dt)
        if not orbitConfig.enabled then return end
        local char = LocalPlayer.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        orbitTime += dt
        local total = #orbitParts
        for i, obj in ipairs(orbitParts) do
            if obj.BP and obj.BP.Parent and obj.BG and obj.BG.Parent then
                local pos = getOrbitPos(i, total, orbitTime, hrp.Position, hrp.CFrame)
                obj.BP.Position = pos
                if orbitConfig.faceCenter then
                    obj.BG.CFrame = obj.BG.CFrame:Lerp(CFrame.lookAt(pos, hrp.Position), 0.2)
                end
            end
        end
    end)
end

--==================================================
-- [C] BallMagicLight 設定
--==================================================
local ballConfig = {
    mode = "Wings",
    enabled = false,
    targetPartName = "BallMagicLight",
    count = 10,
    useAllFound = true,
    speed = 2.5,
    height = 1,
    smoothness = 0.15,
    wingsSpacing = 1.2,
    wingsAmplitude = 2.5,
    wingsPhaseOffset = 0.3,
    wingsDistMultiplier = 0.4,
    wingsHorizontalAmount = 0.5,
    wingsForwardOffset = 3,
    wingsXRot = -45,
    wingsYRot = 0,
    wingsZRot = 90,
    orbitShape = "Circle",
    orbitRadius = 5,
    orbitScale = 1,
    orbitYRotOffset = 0,
    orbitWaveAmplitude = 2,
    orbitWaveFrequency = 2,
    orbitHelixHeight = 5,
    orbitStarPoints = 5,
    orbitStarInnerRadius = 2,
    orbitFaceCenter = false,
}
local ballParts = {}
local ballRowPoints = {}
local ballTime = 0
local ballConnection = nil

local function ballCreateWingsPoints(count)
    local points = {}
    if count == 0 then return points end
    local half = math.floor(count / 2)
    local isOdd = count % 2 == 1
    local idx = 1
    if isOdd then table.insert(points, { baseOffsetX = 0, index = idx }); idx += 1 end
    for i = 1, half do
        local off = i * ballConfig.wingsSpacing
        table.insert(points, { baseOffsetX = off, index = idx }); idx += 1
        table.insert(points, { baseOffsetX = -off, index = idx }); idx += 1
    end
    return points
end

local function ballGetOrbitPos(index, total, t, charPos, charCF)
    local angle = (index - 1) / total * math.pi * 2
    local r = ballConfig.orbitRadius * ballConfig.orbitScale
    local x, y, z = 0, ballConfig.height, 0
    local shape = ballConfig.orbitShape
    if shape == "Circle" then
        local a = angle + t * ballConfig.speed
        x = math.cos(a) * r; z = math.sin(a) * r; y = ballConfig.height
    elseif shape == "Figure8" then
        local a = t * ballConfig.speed + angle
        x = math.sin(a) * r; z = math.sin(a * 2) * r * 0.5; y = ballConfig.height
    elseif shape == "Wave" then
        local a = angle + t * ballConfig.speed
        x = math.cos(a) * r; z = math.sin(a) * r
        y = ballConfig.height + math.sin(a * ballConfig.orbitWaveFrequency + t * ballConfig.speed) * ballConfig.orbitWaveAmplitude
    elseif shape == "Helix" then
        local a = angle + t * ballConfig.speed
        x = math.cos(a) * r; z = math.sin(a) * r
        local prog = ((t * ballConfig.speed * 0.3) % 1)
        y = ballConfig.height + (prog * ballConfig.orbitHelixHeight) - (ballConfig.orbitHelixHeight / 2)
        y = y + (index / total) * ballConfig.orbitHelixHeight
    elseif shape == "Star" then
        local pts = ballConfig.orbitStarPoints
        local innerR = ballConfig.orbitStarInnerRadius * ballConfig.orbitScale
        local a = angle + t * ballConfig.speed
        local pA = (math.pi * 2) / pts
        local blend = (a % pA) / pA
        local dist = innerR + (r - innerR) * math.abs(math.sin(blend * math.pi))
        x = math.cos(a) * dist; z = math.sin(a) * dist; y = ballConfig.height
    elseif shape == "Sphere" then
        local theta = (index / total) * math.pi + t * ballConfig.speed * 0.3
        x = r * math.sin(theta) * math.cos(angle + t * ballConfig.speed)
        z = r * math.sin(theta) * math.sin(angle + t * ballConfig.speed)
        y = ballConfig.height + r * math.cos(theta)
    elseif shape == "DNA" then
        local a = angle + t * ballConfig.speed
        local strand = (index % 2 == 0) and 1 or -1
        x = math.cos(a + strand * math.pi) * r
        z = math.sin(a + strand * math.pi) * r * 0.3
        y = ballConfig.height + (a / (math.pi * 2)) * ballConfig.orbitHelixHeight * 0.5
    end
    local yOff = math.rad(ballConfig.orbitYRotOffset)
    local rx = x * math.cos(yOff) - z * math.sin(yOff)
    local rz = x * math.sin(yOff) + z * math.cos(yOff)
    x, z = rx, rz
    local _, cYR, _ = charCF:ToOrientation()
    return charPos + Vector3.new(x * math.cos(cYR) - z * math.sin(cYR), y, x * math.sin(cYR) + z * math.cos(cYR))
end

local function ballStop()
    if ballConnection then ballConnection:Disconnect(); ballConnection = nil end
    for _, obj in ipairs(ballParts) do
        if obj.BP and obj.BP.Parent then obj.BP:Destroy() end
        if obj.BG and obj.BG.Parent then obj.BG:Destroy() end
        if obj.Part and obj.Part.Parent then obj.Part.Anchored = true end
    end
    ballParts = {}; ballRowPoints = {}
end

local function ballStart()
    ballStop()
    local found = _findByName(ballConfig.targetPartName)
    if #found == 0 then
        OrionLib:MakeNotification({ Name = "エラー", Content = "'" .. ballConfig.targetPartName .. "' が見つかりません", Time = 3 })
        return
    end
    local useCount = ballConfig.useAllFound and #found or math.min(ballConfig.count, #found)
    for i = 1, useCount do
        local obj = _setupObj(found[i])
        if obj then table.insert(ballParts, obj) end
    end
    if ballConfig.mode == "Wings" then ballRowPoints = ballCreateWingsPoints(#ballParts) end
    OrionLib:MakeNotification({ Name = "BallMagicLight 起動", Content = "モード: " .. ballConfig.mode .. " / 数: " .. #ballParts, Time = 2 })
    ballTime = 0
    ballConnection = RunService.RenderStepped:Connect(function(dt)
        if not ballConfig.enabled then return end
        local char = LocalPlayer.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        local torso = char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
        if not hrp or not torso then return end
        ballTime += dt * ballConfig.speed
        local charCF = hrp.CFrame
        local total = #ballParts
        if ballConfig.mode == "Wings" then
            local basePos = torso.Position + Vector3.new(0, ballConfig.height, 0) + charCF.LookVector * ballConfig.wingsForwardOffset
            for i, obj in ipairs(ballParts) do
                if obj.BP and obj.BP.Parent and obj.BG and obj.BG.Parent then
                    local pt = ballRowPoints[i]
                    if not pt then continue end
                    local dist = math.abs(pt.baseOffsetX)
                    local amp = ballConfig.wingsAmplitude + dist * ballConfig.wingsDistMultiplier
                    local wave = math.sin(ballTime + pt.index * ballConfig.wingsPhaseOffset)
                    local hOff = pt.baseOffsetX
                    if pt.baseOffsetX ~= 0 then
                        local sign = pt.baseOffsetX > 0 and 1 or -1
                        hOff = pt.baseOffsetX - sign * math.abs(pt.baseOffsetX) * wave * ballConfig.wingsHorizontalAmount
                    end
                    local targetPos = basePos + charCF.RightVector * hOff + Vector3.new(0, wave * amp, 0)
                    obj.BP.Position = obj.BP.Position + (targetPos - obj.BP.Position) * ballConfig.smoothness
                    local cf = CFrame.new(targetPos)
                    local _, pYR, _ = charCF:ToOrientation()
                    cf = cf * CFrame.Angles(0, pYR + math.rad(ballConfig.wingsYRot), 0)
                    cf = cf * CFrame.Angles(math.rad(ballConfig.wingsXRot), 0, 0)
                    cf = cf * CFrame.Angles(0, 0, math.rad(ballConfig.wingsZRot))
                    obj.BG.CFrame = obj.BG.CFrame:Lerp(cf, ballConfig.smoothness)
                end
            end
        elseif ballConfig.mode == "Orbit" then
            for i, obj in ipairs(ballParts) do
                if obj.BP and obj.BP.Parent and obj.BG and obj.BG.Parent then
                    local pos = ballGetOrbitPos(i, total, ballTime, hrp.Position, charCF)
                    obj.BP.Position = obj.BP.Position + (pos - obj.BP.Position) * ballConfig.smoothness
                    if ballConfig.orbitFaceCenter then
                        obj.BG.CFrame = obj.BG.CFrame:Lerp(CFrame.lookAt(pos, hrp.Position), 0.2)
                    end
                end
            end
        end
    end)
end

--==================================================
-- メインループ (FireworkSparkler用)
--==================================================
RunService.RenderStepped:Connect(function(dt)
    if not fwConfig.enabled then return end
    local character = _getTargetChar(fwConfig.targetPlayer)
    if not character then return end
    local torso = character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso")
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not torso or not hrp then return end
    fwTime += dt * fwConfig.waveSpeed
    local charCF = hrp.CFrame
    local basePos = torso.Position + Vector3.new(0, fwConfig.heightOffset, 0) + charCF.LookVector * fwConfig.forwardOffset
    for _, point in ipairs(fwRowPoints) do
        if point.assignedToy and point.assignedToy.BP and point.assignedToy.BG then
            local toy = point.assignedToy
            local dist = math.abs(toy.baseOffsetX)
            local amp = fwConfig.baseAmplitude + dist * fwConfig.distanceMultiplier
            local wave = math.sin(fwTime + toy.index * fwConfig.phaseOffset)
            local hOff = toy.baseOffsetX
            if toy.baseOffsetX ~= 0 then
                local sign = toy.baseOffsetX > 0 and 1 or -1
                hOff = toy.baseOffsetX - sign * math.abs(toy.baseOffsetX) * wave * fwConfig.horizontalWaveAmount
            end
            local finalPos = basePos + charCF.RightVector * hOff + Vector3.new(0, wave * amp, 0)
            if point.part then point.part.Position = finalPos end
            toy.BP.Position = finalPos
            local cf = CFrame.new(finalPos)
            local _, pYR, _ = charCF:ToOrientation()
            cf = cf * CFrame.Angles(0, pYR + math.rad(fwConfig.yRotation), 0)
            cf = cf * CFrame.Angles(math.rad(fwConfig.xRotation), 0, 0)
            cf = cf * CFrame.Angles(0, 0, math.rad(fwConfig.zRotation))
            toy.BG.CFrame = toy.BG.CFrame:Lerp(cf, fwConfig.smoothness)
        end
    end
end)

--==================================================
-- ORION UI タブ作成（1タブに全機能）
--==================================================
local WingsTab = Window:MakeTab({
    Name = "Wings & Orbit",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false,
})

-- ============================================
-- セクション1: FireworkSparkler
-- ============================================
WingsTab:AddSection({ Name = "🎆 FireworkSparkler" })

WingsTab:AddToggle({
    Name = "FW: 有効化",
    Default = false,
    Flag = "FWEnabled",
    Callback = function(v)
        fwConfig.enabled = v
        if v then fwEnable(); OrionLib:MakeNotification({ Name = "FW ON", Content = "花火システム起動", Time = 2 })
        else fwDisable(); OrionLib:MakeNotification({ Name = "FW OFF", Content = "花火固定", Time = 2 }) end
    end,
})

local fwPlayerDropdown
fwPlayerDropdown = WingsTab:AddDropdown({
    Name = "FW: 対象プレイヤー",
    Default = "自分",
    Options = fwGetPlayerList(),
    Callback = function(v)
        if v == "自分" then fwConfig.targetPlayer = nil
        else fwConfig.targetPlayer = Players:FindFirstChild(v) end
        fwAssigned = fwAssignToPoints()
    end,
})

WingsTab:AddButton({
    Name = "FW: プレイヤーリスト更新",
    Callback = function()
        fwPlayerDropdown:Refresh(fwGetPlayerList(), true)
        OrionLib:MakeNotification({ Name = "更新", Content = "リスト更新完了", Time = 2 })
    end,
})

WingsTab:AddButton({
    Name = "FW: 花火を再検出",
    Callback = function()
        fwRefresh()
        OrionLib:MakeNotification({ Name = "再検出", Content = "花火数: " .. #fwToys, Time = 2 })
    end,
})

WingsTab:AddSlider({ Name = "FW: 最大花火数", Min = 2, Max = 40, Default = 20, Increment = 1, ValueName = "本",
    Callback = function(v) fwConfig.maxSparklers = v; fwRefresh() end })
WingsTab:AddSlider({ Name = "FW: 間隔", Min = 0.5, Max = 5, Default = 1.2, Increment = 0.1, ValueName = "",
    Callback = function(v) fwConfig.spacing = v; fwRefresh() end })
WingsTab:AddSlider({ Name = "FW: 高さ", Min = -5, Max = 10, Default = 1, Increment = 0.5, ValueName = "",
    Callback = function(v) fwConfig.heightOffset = v end })
WingsTab:AddSlider({ Name = "FW: 前方オフセット", Min = 0, Max = 15, Default = 4, Increment = 0.5, ValueName = "",
    Callback = function(v) fwConfig.forwardOffset = v end })
WingsTab:AddSlider({ Name = "FW: 波速度", Min = 0, Max = 10, Default = 2.5, Increment = 0.1, ValueName = "",
    Callback = function(v) fwConfig.waveSpeed = v end })
WingsTab:AddSlider({ Name = "FW: 振幅", Min = 0, Max = 10, Default = 2, Increment = 0.1, ValueName = "",
    Callback = function(v) fwConfig.baseAmplitude = v end })
WingsTab:AddSlider({ Name = "FW: 位相差", Min = 0, Max = 2, Default = 0.3, Increment = 0.05, ValueName = "",
    Callback = function(v) fwConfig.phaseOffset = v end })
WingsTab:AddSlider({ Name = "FW: 内側への寄り", Min = 0, Max = 2, Default = 0.5, Increment = 0.05, ValueName = "",
    Callback = function(v) fwConfig.horizontalWaveAmount = v end })
WingsTab:AddSlider({ Name = "FW: 滑らかさ", Min = 0.01, Max = 1, Default = 0.6, Increment = 0.01, ValueName = "",
    Callback = function(v) fwConfig.smoothness = v end })
WingsTab:AddSlider({ Name = "FW: X軸回転", Min = -180, Max = 180, Default = -45, Increment = 1, ValueName = "°",
    Callback = function(v) fwConfig.xRotation = v end })
WingsTab:AddSlider({ Name = "FW: Y軸回転", Min = -180, Max = 180, Default = 0, Increment = 1, ValueName = "°",
    Callback = function(v) fwConfig.yRotation = v end })
WingsTab:AddSlider({ Name = "FW: Z軸回転", Min = -180, Max = 180, Default = 90, Increment = 1, ValueName = "°",
    Callback = function(v) fwConfig.zRotation = v end })
WingsTab:AddButton({ Name = "FW: 回転リセット", Callback = function()
    fwConfig.xRotation = -45; fwConfig.yRotation = 0; fwConfig.zRotation = 90
    OrionLib:MakeNotification({ Name = "リセット", Content = "回転をデフォルトに戻しました", Time = 2 })
end })

-- ============================================
-- セクション2: Part Orbit
-- ============================================
WingsTab:AddSection({ Name = "🌀 Part Orbit" })

WingsTab:AddToggle({
    Name = "Orbit: 有効化",
    Default = false,
    Flag = "OrbitEnabled",
    Callback = function(v)
        orbitConfig.enabled = v
        if v then orbitStart()
        else orbitStop(); OrionLib:MakeNotification({ Name = "Orbit停止", Content = "オービット停止", Time = 2 }) end
    end,
})

WingsTab:AddTextbox({ Name = "Orbit: 対象Part名", Default = "PalletLightBrown", TextDisappear = false,
    Callback = function(v) orbitConfig.targetPartName = v end })

WingsTab:AddDropdown({ Name = "Orbit: 形状", Default = "Circle",
    Options = { "Circle", "Wings", "Figure8", "Helix", "Star", "Wave", "Sphere", "DNA" },
    Callback = function(v) orbitConfig.shape = v; if orbitConfig.enabled then orbitStart() end end })

WingsTab:AddToggle({ Name = "Orbit: 全Part使用", Default = true, Flag = "OrbitUseAll",
    Callback = function(v) orbitConfig.useAllFound = v end })
WingsTab:AddSlider({ Name = "Orbit: 使用数", Min = 1, Max = 50, Default = 8, Increment = 1, ValueName = "個",
    Callback = function(v) orbitConfig.count = v end })
WingsTab:AddSlider({ Name = "Orbit: 半径", Min = 1, Max = 30, Default = 5, Increment = 0.5, ValueName = "",
    Callback = function(v) orbitConfig.radius = v end })
WingsTab:AddSlider({ Name = "Orbit: 高さ", Min = -10, Max = 15, Default = 0, Increment = 0.5, ValueName = "",
    Callback = function(v) orbitConfig.height = v end })
WingsTab:AddSlider({ Name = "Orbit: 速度", Min = -10, Max = 10, Default = 1, Increment = 0.1, ValueName = "",
    Callback = function(v) orbitConfig.speed = v end })
WingsTab:AddSlider({ Name = "Orbit: スケール", Min = 0.1, Max = 5, Default = 1, Increment = 0.1, ValueName = "x",
    Callback = function(v) orbitConfig.scale = v end })
WingsTab:AddSlider({ Name = "Orbit: Y軸オフセット", Min = -180, Max = 180, Default = 0, Increment = 1, ValueName = "°",
    Callback = function(v) orbitConfig.yRotation = v end })
WingsTab:AddSlider({ Name = "Orbit: 波振幅", Min = 0, Max = 10, Default = 2, Increment = 0.1, ValueName = "",
    Callback = function(v) orbitConfig.waveAmplitude = v end })
WingsTab:AddSlider({ Name = "Orbit: 波周波数", Min = 1, Max = 10, Default = 2, Increment = 0.5, ValueName = "",
    Callback = function(v) orbitConfig.waveFrequency = v end })
WingsTab:AddSlider({ Name = "Orbit: 螺旋高さ", Min = 1, Max = 20, Default = 5, Increment = 0.5, ValueName = "",
    Callback = function(v) orbitConfig.helixHeight = v end })
WingsTab:AddSlider({ Name = "Orbit: 星頂点数", Min = 3, Max = 12, Default = 5, Increment = 1, ValueName = "点",
    Callback = function(v) orbitConfig.starPoints = v end })
WingsTab:AddSlider({ Name = "Orbit: 星内半径", Min = 0.5, Max = 10, Default = 2, Increment = 0.5, ValueName = "",
    Callback = function(v) orbitConfig.starInnerRadius = v end })
WingsTab:AddToggle({ Name = "Orbit: 中心を向く", Default = false, Flag = "OrbitFace",
    Callback = function(v) orbitConfig.faceCenter = v end })
WingsTab:AddButton({ Name = "Orbit: 再検索 & 再起動", Callback = function()
    if orbitConfig.enabled then orbitStart()
    else
        local f = _findByName(orbitConfig.targetPartName)
        OrionLib:MakeNotification({ Name = "検索", Content = #f .. "個発見", Time = 3 })
    end
end })

-- ============================================
-- セクション3: BallMagicLight
-- ============================================
WingsTab:AddSection({ Name = "✨ BallMagicLight" })

WingsTab:AddToggle({
    Name = "Ball: 有効化",
    Default = false,
    Flag = "BallEnabled",
    Callback = function(v)
        ballConfig.enabled = v
        if v then ballStart()
        else ballStop(); OrionLib:MakeNotification({ Name = "Ball停止", Content = "停止しました", Time = 2 }) end
    end,
})

WingsTab:AddDropdown({ Name = "Ball: モード", Default = "Wings", Options = { "Wings", "Orbit" },
    Callback = function(v) ballConfig.mode = v; if ballConfig.enabled then ballStart() end end })

WingsTab:AddTextbox({ Name = "Ball: 対象Part名", Default = "BallMagicLight", TextDisappear = false,
    Callback = function(v) ballConfig.targetPartName = v end })

WingsTab:AddToggle({ Name = "Ball: 全Part使用", Default = true, Flag = "BallUseAll",
    Callback = function(v) ballConfig.useAllFound = v end })
WingsTab:AddSlider({ Name = "Ball: 使用数", Min = 1, Max = 60, Default = 10, Increment = 1, ValueName = "個",
    Callback = function(v) ballConfig.count = v end })
WingsTab:AddSlider({ Name = "Ball: 速度", Min = -10, Max = 10, Default = 2.5, Increment = 0.1, ValueName = "",
    Callback = function(v) ballConfig.speed = v end })
WingsTab:AddSlider({ Name = "Ball: 高さ", Min = -5, Max = 15, Default = 1, Increment = 0.5, ValueName = "",
    Callback = function(v) ballConfig.height = v end })
WingsTab:AddSlider({ Name = "Ball: 滑らかさ", Min = 0.01, Max = 1, Default = 0.15, Increment = 0.01, ValueName = "",
    Callback = function(v) ballConfig.smoothness = v end })

-- Wings専用
WingsTab:AddSlider({ Name = "Ball Wings: 間隔", Min = 0.3, Max = 5, Default = 1.2, Increment = 0.1, ValueName = "",
    Callback = function(v) ballConfig.wingsSpacing = v; if ballConfig.enabled and ballConfig.mode == "Wings" then ballRowPoints = ballCreateWingsPoints(#ballParts) end end })
WingsTab:AddSlider({ Name = "Ball Wings: 振幅", Min = 0, Max = 10, Default = 2.5, Increment = 0.1, ValueName = "",
    Callback = function(v) ballConfig.wingsAmplitude = v end })
WingsTab:AddSlider({ Name = "Ball Wings: 位相差", Min = 0, Max = 2, Default = 0.3, Increment = 0.05, ValueName = "",
    Callback = function(v) ballConfig.wingsPhaseOffset = v end })
WingsTab:AddSlider({ Name = "Ball Wings: 距離振幅増加", Min = 0, Max = 2, Default = 0.4, Increment = 0.05, ValueName = "",
    Callback = function(v) ballConfig.wingsDistMultiplier = v end })
WingsTab:AddSlider({ Name = "Ball Wings: 内側寄り", Min = 0, Max = 2, Default = 0.5, Increment = 0.05, ValueName = "",
    Callback = function(v) ballConfig.wingsHorizontalAmount = v end })
WingsTab:AddSlider({ Name = "Ball Wings: 前方オフセット", Min = 0, Max = 15, Default = 3, Increment = 0.5, ValueName = "",
    Callback = function(v) ballConfig.wingsForwardOffset = v end })
WingsTab:AddSlider({ Name = "Ball Wings: X軸回転", Min = -180, Max = 180, Default = -45, Increment = 1, ValueName = "°",
    Callback = function(v) ballConfig.wingsXRot = v end })
WingsTab:AddSlider({ Name = "Ball Wings: Y軸回転", Min = -180, Max = 180, Default = 0, Increment = 1, ValueName = "°",
    Callback = function(v) ballConfig.wingsYRot = v end })
WingsTab:AddSlider({ Name = "Ball Wings: Z軸回転", Min = -180, Max = 180, Default = 90, Increment = 1, ValueName = "°",
    Callback = function(v) ballConfig.wingsZRot = v end })
WingsTab:AddButton({ Name = "Ball Wings: 回転リセット", Callback = function()
    ballConfig.wingsXRot = -45; ballConfig.wingsYRot = 0; ballConfig.wingsZRot = 90
    OrionLib:MakeNotification({ Name = "リセット", Content = "Wings回転リセット", Time = 2 })
end })

-- Orbit専用
WingsTab:AddDropdown({ Name = "Ball Orbit: 形状", Default = "Circle",
    Options = { "Circle", "Figure8", "Wave", "Helix", "Star", "Sphere", "DNA" },
    Callback = function(v) ballConfig.orbitShape = v end })
WingsTab:AddSlider({ Name = "Ball Orbit: 半径", Min = 1, Max = 30, Default = 5, Increment = 0.5, ValueName = "",
    Callback = function(v) ballConfig.orbitRadius = v end })
WingsTab:AddSlider({ Name = "Ball Orbit: スケール", Min = 0.1, Max = 5, Default = 1, Increment = 0.1, ValueName = "x",
    Callback = function(v) ballConfig.orbitScale = v end })
WingsTab:AddSlider({ Name = "Ball Orbit: Y軸オフセット", Min = -180, Max = 180, Default = 0, Increment = 1, ValueName = "°",
    Callback = function(v) ballConfig.orbitYRotOffset = v end })
WingsTab:AddSlider({ Name = "Ball Orbit: 波振幅", Min = 0, Max = 10, Default = 2, Increment = 0.1, ValueName = "",
    Callback = function(v) ballConfig.orbitWaveAmplitude = v end })
WingsTab:AddSlider({ Name = "Ball Orbit: 波周波数", Min = 1, Max = 10, Default = 2, Increment = 0.5, ValueName = "",
    Callback = function(v) ballConfig.orbitWaveFrequency = v end })
WingsTab:AddSlider({ Name = "Ball Orbit: 螺旋高さ", Min = 1, Max = 20, Default = 5, Increment = 0.5, ValueName = "",
    Callback = function(v) ballConfig.orbitHelixHeight = v end })
WingsTab:AddSlider({ Name = "Ball Orbit: 星頂点数", Min = 3, Max = 12, Default = 5, Increment = 1, ValueName = "点",
    Callback = function(v) ballConfig.orbitStarPoints = v end })
WingsTab:AddSlider({ Name = "Ball Orbit: 星内半径", Min = 0.5, Max = 10, Default = 2, Increment = 0.5, ValueName = "",
    Callback = function(v) ballConfig.orbitStarInnerRadius = v end })
WingsTab:AddToggle({ Name = "Ball Orbit: 中心を向く", Default = false, Flag = "BallFaceCenter",
    Callback = function(v) ballConfig.orbitFaceCenter = v end })
WingsTab:AddButton({ Name = "Ball: 再検索 & 再起動", Callback = function()
    if ballConfig.enabled then ballStart()
    else
        local f = _findByName(ballConfig.targetPartName)
        OrionLib:MakeNotification({ Name = "検索", Content = #f .. "個発見", Time = 3 })
    end
end })

--==============================
-- タブ：Campfire & Ball Float
-- ※ OrionLib:Init() の前に挿入
--==============================

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

--==================================================
-- 共通ユーティリティ
--==================================================
local function cf_findByName(name)
    local found = {}
    for _, item in ipairs(workspace:GetDescendants()) do
        if (item:IsA("BasePart") or item:IsA("Model")) and item.Name == name then
            table.insert(found, item)
        end
    end
    return found
end

local function cf_getBasePart(obj)
    if obj:IsA("Model") then
        return obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
    elseif obj:IsA("BasePart") then
        return obj
    end
    return nil
end

local function cf_setupMovers(part)
    if not part then return nil, nil end
    for _, c in ipairs({"BodyPosition", "BodyGyro"}) do
        local e = part:FindFirstChildOfClass(c)
        if e then e:Destroy() end
    end
    local BP = Instance.new("BodyPosition")
    BP.P = 25000; BP.D = 800
    BP.MaxForce = Vector3.new(1,1,1) * 1e10
    BP.Parent = part
    local BG = Instance.new("BodyGyro")
    BG.P = 25000; BG.D = 800
    BG.MaxTorque = Vector3.new(1,1,1) * 1e10
    BG.Parent = part
    return BP, BG
end

local function cf_setupObj(obj)
    local base = cf_getBasePart(obj)
    if not base then return nil end
    if obj:IsA("Model") then
        for _, c in ipairs(obj:GetDescendants()) do
            if c:IsA("BasePart") then
                c.CanCollide = false; c.CanTouch = false; c.Anchored = false
            end
        end
    else
        base.CanCollide = false; base.CanTouch = false; base.Anchored = false
    end
    local BP, BG = cf_setupMovers(base)
    return { BP = BP, BG = BG, Part = base, Original = obj }
end

local function cf_releaseObj(obj)
    if obj.BP and obj.BP.Parent then obj.BP:Destroy() end
    if obj.BG and obj.BG.Parent then obj.BG:Destroy() end
    if obj.Part and obj.Part.Parent then obj.Part.Anchored = true end
end

--==================================================
-- [A] Campfire システム
--==================================================
local campConfig = {
    enabled        = false,
    partName       = "Campfire",
    -- 周回設定
    orbitCount     = 6,       -- 周回するCampfireの数
    orbitRadius    = 5,
    orbitSpeed     = 1.2,
    orbitHeight    = 0,
    orbitShape     = "Circle", -- Circle / Wave / Figure8 / Star
    waveAmp        = 1.5,
    waveFreq       = 2,
    starPoints     = 5,
    starInner      = 2,
    -- 頭上設定
    headEnabled    = true,
    headHeight     = 3.5,
    headBobSpeed   = 1.5,
    headBobAmp     = 0.3,
    -- 共通
    smoothness     = 0.18,
    faceCenter     = false,
    useAllFound    = false,    -- falseのとき orbitCount+1(頭上)個だけ使う
}

local campOrbitObjs = {}   -- 周回用
local campHeadObj   = nil  -- 頭上用
local campTime      = 0
local campConn      = nil

local function campGetOrbitPos(index, total, t, charPos, charCF)
    local angle = (index - 1) / total * math.pi * 2
    local r = campConfig.orbitRadius
    local x, y, z = 0, campConfig.orbitHeight, 0
    local shape = campConfig.orbitShape

    if shape == "Circle" then
        local a = angle + t * campConfig.orbitSpeed
        x = math.cos(a) * r; z = math.sin(a) * r

    elseif shape == "Wave" then
        local a = angle + t * campConfig.orbitSpeed
        x = math.cos(a) * r; z = math.sin(a) * r
        y = campConfig.orbitHeight + math.sin(a * campConfig.waveFreq + t * campConfig.orbitSpeed) * campConfig.waveAmp

    elseif shape == "Figure8" then
        local a = t * campConfig.orbitSpeed + angle
        x = math.sin(a) * r; z = math.sin(a * 2) * r * 0.5

    elseif shape == "Star" then
        local pts = campConfig.starPoints
        local innerR = campConfig.starInner
        local a = angle + t * campConfig.orbitSpeed
        local pA = (math.pi * 2) / pts
        local blend = (a % pA) / pA
        local dist = innerR + (r - innerR) * math.abs(math.sin(blend * math.pi))
        x = math.cos(a) * dist; z = math.sin(a) * dist
    end

    -- キャラの向きに合わせる
    local _, cYR, _ = charCF:ToOrientation()
    local fx = x * math.cos(cYR) - z * math.sin(cYR)
    local fz = x * math.sin(cYR) + z * math.cos(cYR)
    return charPos + Vector3.new(fx, y, fz)
end

local function campStop()
    if campConn then campConn:Disconnect(); campConn = nil end
    for _, obj in ipairs(campOrbitObjs) do cf_releaseObj(obj) end
    campOrbitObjs = {}
    if campHeadObj then cf_releaseObj(campHeadObj); campHeadObj = nil end
end

local function campStart()
    campStop()

    local found = cf_findByName(campConfig.partName)
    if #found == 0 then
        OrionLib:MakeNotification({ Name = "エラー", Content = "'" .. campConfig.partName .. "' が見つかりません", Time = 3 })
        return
    end

    local needed = campConfig.orbitCount + (campConfig.headEnabled and 1 or 0)
    local useCount = campConfig.useAllFound and #found or math.min(needed, #found)

    -- 頭上は最後の1個を使う
    local headIdx = campConfig.headEnabled and useCount or nil
    local orbitEnd = headIdx and (useCount - 1) or useCount

    for i = 1, orbitEnd do
        local obj = cf_setupObj(found[i])
        if obj then table.insert(campOrbitObjs, obj) end
    end

    if headIdx and found[headIdx] then
        campHeadObj = cf_setupObj(found[headIdx])
    end

    OrionLib:MakeNotification({
        Name = "Campfire 起動",
        Content = "周回: " .. #campOrbitObjs .. "個" .. (campHeadObj and " / 頭上: 1個" or ""),
        Time = 3,
    })

    campTime = 0

    campConn = RunService.RenderStepped:Connect(function(dt)
        if not campConfig.enabled then return end
        local char = LocalPlayer.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        local head = char:FindFirstChild("Head")
        if not hrp then return end

        campTime += dt

        local charPos = hrp.Position
        local charCF  = hrp.CFrame
        local total   = #campOrbitObjs

        -- 周回
        for i, obj in ipairs(campOrbitObjs) do
            if obj.BP and obj.BP.Parent then
                local pos = campGetOrbitPos(i, total, campTime, charPos, charCF)
                obj.BP.Position = obj.BP.Position + (pos - obj.BP.Position) * campConfig.smoothness
                if campConfig.faceCenter and obj.BG and obj.BG.Parent then
                    obj.BG.CFrame = obj.BG.CFrame:Lerp(CFrame.lookAt(pos, charPos), 0.2)
                end
            end
        end

        -- 頭上（ふわふわ浮く）
        if campHeadObj and campHeadObj.BP and campHeadObj.BP.Parent then
            local headPos = (head and head.Position or charPos) + Vector3.new(0, campConfig.headHeight, 0)
            headPos = headPos + Vector3.new(0, math.sin(campTime * campConfig.headBobSpeed) * campConfig.headBobAmp, 0)
            campHeadObj.BP.Position = campHeadObj.BP.Position + (headPos - campHeadObj.BP.Position) * campConfig.smoothness
        end
    end)
end

--==================================================
-- [B] BallMagicLight Float システム（同じ構造）
--==================================================
local ballFConfig = {
    enabled        = false,
    partName       = "BallMagicLight",
    orbitCount     = 8,
    orbitRadius    = 5,
    orbitSpeed     = 1.5,
    orbitHeight    = 0,
    orbitShape     = "Circle",
    waveAmp        = 1.5,
    waveFreq       = 2,
    starPoints     = 5,
    starInner      = 2,
    headEnabled    = true,
    headHeight     = 4,
    headBobSpeed   = 2,
    headBobAmp     = 0.4,
    smoothness     = 0.18,
    faceCenter     = false,
    useAllFound    = false,
}

local ballFOrbitObjs = {}
local ballFHeadObj   = nil
local ballFTime      = 0
local ballFConn      = nil

local function ballFGetOrbitPos(index, total, t, charPos, charCF)
    local angle = (index - 1) / total * math.pi * 2
    local r = ballFConfig.orbitRadius
    local x, y, z = 0, ballFConfig.orbitHeight, 0
    local shape = ballFConfig.orbitShape

    if shape == "Circle" then
        local a = angle + t * ballFConfig.orbitSpeed
        x = math.cos(a) * r; z = math.sin(a) * r

    elseif shape == "Wave" then
        local a = angle + t * ballFConfig.orbitSpeed
        x = math.cos(a) * r; z = math.sin(a) * r
        y = ballFConfig.orbitHeight + math.sin(a * ballFConfig.waveFreq + t * ballFConfig.orbitSpeed) * ballFConfig.waveAmp

    elseif shape == "Figure8" then
        local a = t * ballFConfig.orbitSpeed + angle
        x = math.sin(a) * r; z = math.sin(a * 2) * r * 0.5

    elseif shape == "Star" then
        local pts = ballFConfig.starPoints
        local innerR = ballFConfig.starInner
        local a = angle + t * ballFConfig.orbitSpeed
        local pA = (math.pi * 2) / pts
        local blend = (a % pA) / pA
        local dist = innerR + (r - innerR) * math.abs(math.sin(blend * math.pi))
        x = math.cos(a) * dist; z = math.sin(a) * dist
    end

    local _, cYR, _ = charCF:ToOrientation()
    local fx = x * math.cos(cYR) - z * math.sin(cYR)
    local fz = x * math.sin(cYR) + z * math.cos(cYR)
    return charPos + Vector3.new(fx, y, fz)
end

local function ballFStop()
    if ballFConn then ballFConn:Disconnect(); ballFConn = nil end
    for _, obj in ipairs(ballFOrbitObjs) do cf_releaseObj(obj) end
    ballFOrbitObjs = {}
    if ballFHeadObj then cf_releaseObj(ballFHeadObj); ballFHeadObj = nil end
end

local function ballFStart()
    ballFStop()

    local found = cf_findByName(ballFConfig.partName)
    if #found == 0 then
        OrionLib:MakeNotification({ Name = "エラー", Content = "'" .. ballFConfig.partName .. "' が見つかりません", Time = 3 })
        return
    end

    local needed  = ballFConfig.orbitCount + (ballFConfig.headEnabled and 1 or 0)
    local useCount = ballFConfig.useAllFound and #found or math.min(needed, #found)
    local headIdx  = ballFConfig.headEnabled and useCount or nil
    local orbitEnd = headIdx and (useCount - 1) or useCount

    for i = 1, orbitEnd do
        local obj = cf_setupObj(found[i])
        if obj then table.insert(ballFOrbitObjs, obj) end
    end
    if headIdx and found[headIdx] then
        ballFHeadObj = cf_setupObj(found[headIdx])
    end

    OrionLib:MakeNotification({
        Name = "BallMagicLight 起動",
        Content = "周回: " .. #ballFOrbitObjs .. "個" .. (ballFHeadObj and " / 頭上: 1個" or ""),
        Time = 3,
    })

    ballFTime = 0

    ballFConn = RunService.RenderStepped:Connect(function(dt)
        if not ballFConfig.enabled then return end
        local char = LocalPlayer.Character
        if not char then return end
        local hrp  = char:FindFirstChild("HumanoidRootPart")
        local head = char:FindFirstChild("Head")
        if not hrp then return end

        ballFTime += dt

        local charPos = hrp.Position
        local charCF  = hrp.CFrame
        local total   = #ballFOrbitObjs

        for i, obj in ipairs(ballFOrbitObjs) do
            if obj.BP and obj.BP.Parent then
                local pos = ballFGetOrbitPos(i, total, ballFTime, charPos, charCF)
                obj.BP.Position = obj.BP.Position + (pos - obj.BP.Position) * ballFConfig.smoothness
                if ballFConfig.faceCenter and obj.BG and obj.BG.Parent then
                    obj.BG.CFrame = obj.BG.CFrame:Lerp(CFrame.lookAt(pos, charPos), 0.2)
                end
            end
        end

        if ballFHeadObj and ballFHeadObj.BP and ballFHeadObj.BP.Parent then
            local headPos = (head and head.Position or charPos) + Vector3.new(0, ballFConfig.headHeight, 0)
            headPos = headPos + Vector3.new(0, math.sin(ballFTime * ballFConfig.headBobSpeed) * ballFConfig.headBobAmp, 0)
            ballFHeadObj.BP.Position = ballFHeadObj.BP.Position + (headPos - ballFHeadObj.BP.Position) * ballFConfig.smoothness
        end
    end)
end

--==================================================
-- ORION UI タブ
--==================================================
local FloatTab = Window:MakeTab({
    Name = "Float & Orbit",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false,
})

-- ============================================
-- セクション1: Campfire
-- ============================================
FloatTab:AddSection({ Name = "🔥 Campfire Orbit + 頭上" })

FloatTab:AddToggle({
    Name = "Campfire: 有効化",
    Default = false,
    Flag = "CampEnabled",
    Callback = function(v)
        campConfig.enabled = v
        if v then campStart()
        else campStop(); OrionLib:MakeNotification({ Name = "Campfire停止", Content = "停止しました", Time = 2 }) end
    end,
})

FloatTab:AddTextbox({
    Name = "Campfire: Part名",
    Default = "Campfire",
    TextDisappear = false,
    Callback = function(v) campConfig.partName = v end,
})

FloatTab:AddButton({
    Name = "Campfire: 再検索 & 再起動",
    Callback = function()
        if campConfig.enabled then campStart()
        else
            local f = cf_findByName(campConfig.partName)
            OrionLib:MakeNotification({ Name = "検索", Content = #f .. "個発見", Time = 3 })
        end
    end,
})

FloatTab:AddToggle({ Name = "Campfire: 全Part使用", Default = false, Flag = "CampUseAll",
    Callback = function(v) campConfig.useAllFound = v end })

FloatTab:AddSlider({ Name = "Campfire: 周回数（頭上除く）", Min = 1, Max = 30, Default = 6, Increment = 1, ValueName = "個",
    Callback = function(v) campConfig.orbitCount = v end })

FloatTab:AddDropdown({ Name = "Campfire: 形状", Default = "Circle",
    Options = { "Circle", "Wave", "Figure8", "Star" },
    Callback = function(v) campConfig.orbitShape = v end })

FloatTab:AddSlider({ Name = "Campfire: 半径", Min = 1, Max = 30, Default = 5, Increment = 0.5, ValueName = "",
    Callback = function(v) campConfig.orbitRadius = v end })

FloatTab:AddSlider({ Name = "Campfire: 回転速度", Min = -10, Max = 10, Default = 1.2, Increment = 0.1, ValueName = "",
    Callback = function(v) campConfig.orbitSpeed = v end })

FloatTab:AddSlider({ Name = "Campfire: 周回高さ", Min = -5, Max = 10, Default = 0, Increment = 0.5, ValueName = "",
    Callback = function(v) campConfig.orbitHeight = v end })

FloatTab:AddSlider({ Name = "Campfire: 波振幅 (Wave)", Min = 0, Max = 5, Default = 1.5, Increment = 0.1, ValueName = "",
    Callback = function(v) campConfig.waveAmp = v end })

FloatTab:AddSlider({ Name = "Campfire: 波周波数 (Wave)", Min = 1, Max = 10, Default = 2, Increment = 0.5, ValueName = "",
    Callback = function(v) campConfig.waveFreq = v end })

FloatTab:AddSlider({ Name = "Campfire: 星頂点数 (Star)", Min = 3, Max = 12, Default = 5, Increment = 1, ValueName = "点",
    Callback = function(v) campConfig.starPoints = v end })

FloatTab:AddSlider({ Name = "Campfire: 星内半径 (Star)", Min = 0.5, Max = 10, Default = 2, Increment = 0.5, ValueName = "",
    Callback = function(v) campConfig.starInner = v end })

FloatTab:AddSlider({ Name = "Campfire: 滑らかさ", Min = 0.01, Max = 1, Default = 0.18, Increment = 0.01, ValueName = "",
    Callback = function(v) campConfig.smoothness = v end })

FloatTab:AddToggle({ Name = "Campfire: 中心を向く", Default = false, Flag = "CampFace",
    Callback = function(v) campConfig.faceCenter = v end })

-- 頭上設定
FloatTab:AddToggle({ Name = "Campfire: 頭上1個を有効化", Default = true, Flag = "CampHead",
    Callback = function(v) campConfig.headEnabled = v end })

FloatTab:AddSlider({ Name = "Campfire: 頭上の高さ", Min = 1, Max = 10, Default = 3.5, Increment = 0.5, ValueName = "",
    Callback = function(v) campConfig.headHeight = v end })

FloatTab:AddSlider({ Name = "Campfire: 頭上ふわふわ速度", Min = 0, Max = 5, Default = 1.5, Increment = 0.1, ValueName = "",
    Callback = function(v) campConfig.headBobSpeed = v end })

FloatTab:AddSlider({ Name = "Campfire: 頭上ふわふわ幅", Min = 0, Max = 2, Default = 0.3, Increment = 0.05, ValueName = "",
    Callback = function(v) campConfig.headBobAmp = v end })

-- ============================================
-- セクション2: BallMagicLight
-- ============================================
FloatTab:AddSection({ Name = "✨ BallMagicLight Orbit + 頭上" })

FloatTab:AddToggle({
    Name = "Ball: 有効化",
    Default = false,
    Flag = "BallFEnabled",
    Callback = function(v)
        ballFConfig.enabled = v
        if v then ballFStart()
        else ballFStop(); OrionLib:MakeNotification({ Name = "Ball停止", Content = "停止しました", Time = 2 }) end
    end,
})

FloatTab:AddTextbox({
    Name = "Ball: Part名",
    Default = "BallMagicLight",
    TextDisappear = false,
    Callback = function(v) ballFConfig.partName = v end,
})

FloatTab:AddButton({
    Name = "Ball: 再検索 & 再起動",
    Callback = function()
        if ballFConfig.enabled then ballFStart()
        else
            local f = cf_findByName(ballFConfig.partName)
            OrionLib:MakeNotification({ Name = "検索", Content = #f .. "個発見", Time = 3 })
        end
    end,
})

FloatTab:AddToggle({ Name = "Ball: 全Part使用", Default = false, Flag = "BallFUseAll",
    Callback = function(v) ballFConfig.useAllFound = v end })

FloatTab:AddSlider({ Name = "Ball: 周回数（頭上除く）", Min = 1, Max = 30, Default = 8, Increment = 1, ValueName = "個",
    Callback = function(v) ballFConfig.orbitCount = v end })

FloatTab:AddDropdown({ Name = "Ball: 形状", Default = "Circle",
    Options = { "Circle", "Wave", "Figure8", "Star" },
    Callback = function(v) ballFConfig.orbitShape = v end })

FloatTab:AddSlider({ Name = "Ball: 半径", Min = 1, Max = 30, Default = 5, Increment = 0.5, ValueName = "",
    Callback = function(v) ballFConfig.orbitRadius = v end })

FloatTab:AddSlider({ Name = "Ball: 回転速度", Min = -10, Max = 10, Default = 1.5, Increment = 0.1, ValueName = "",
    Callback = function(v) ballFConfig.orbitSpeed = v end })

FloatTab:AddSlider({ Name = "Ball: 周回高さ", Min = -5, Max = 10, Default = 0, Increment = 0.5, ValueName = "",
    Callback = function(v) ballFConfig.orbitHeight = v end })

FloatTab:AddSlider({ Name = "Ball: 波振幅 (Wave)", Min = 0, Max = 5, Default = 1.5, Increment = 0.1, ValueName = "",
    Callback = function(v) ballFConfig.waveAmp = v end })

FloatTab:AddSlider({ Name = "Ball: 波周波数 (Wave)", Min = 1, Max = 10, Default = 2, Increment = 0.5, ValueName = "",
    Callback = function(v) ballFConfig.waveFreq = v end })

FloatTab:AddSlider({ Name = "Ball: 星頂点数 (Star)", Min = 3, Max = 12, Default = 5, Increment = 1, ValueName = "点",
    Callback = function(v) ballFConfig.starPoints = v end })

FloatTab:AddSlider({ Name = "Ball: 星内半径 (Star)", Min = 0.5, Max = 10, Default = 2, Increment = 0.5, ValueName = "",
    Callback = function(v) ballFConfig.starInner = v end })

FloatTab:AddSlider({ Name = "Ball: 滑らかさ", Min = 0.01, Max = 1, Default = 0.18, Increment = 0.01, ValueName = "",
    Callback = function(v) ballFConfig.smoothness = v end })

FloatTab:AddToggle({ Name = "Ball: 中心を向く", Default = false, Flag = "BallFFace",
    Callback = function(v) ballFConfig.faceCenter = v end })

-- 頭上設定
FloatTab:AddToggle({ Name = "Ball: 頭上1個を有効化", Default = true, Flag = "BallFHead",
    Callback = function(v) ballFConfig.headEnabled = v end })

FloatTab:AddSlider({ Name = "Ball: 頭上の高さ", Min = 1, Max = 10, Default = 4, Increment = 0.5, ValueName = "",
    Callback = function(v) ballFConfig.headHeight = v end })

FloatTab:AddSlider({ Name = "Ball: 頭上ふわふわ速度", Min = 0, Max = 5, Default = 2, Increment = 0.1, ValueName = "",
    Callback = function(v) ballFConfig.headBobSpeed = v end })

FloatTab:AddSlider({ Name = "Ball: 頭上ふわふわ幅", Min = 0, Max = 2, Default = 0.4, Increment = 0.05, ValueName = "",
    Callback = function(v) ballFConfig.headBobAmp = v end })

--==============================
-- タブ：アンチグッチ (ORION UI版)
-- ※ OrionLib:Init() の前に挿入
-- ※ 機能・ロジックは元スクリプトと完全同一
--==============================

local Players         = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace       = game:GetService("Workspace")
local RunService      = game:GetService("RunService")

local AG_LocalPlayer = Players.LocalPlayer

-- 便利関数（元スクリプトと同一）
local function ag_getLocalChar()
    return AG_LocalPlayer.Character
end

local function ag_getLocalRoot()
    local char = ag_getLocalChar()
    if not char then return nil end
    return char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso")
end

local function ag_getLocalHum()
    local char = ag_getLocalChar()
    if not char then return nil end
    return char:FindFirstChildOfClass("Humanoid")
end

local function ag_getInv()
    return Workspace:FindFirstChild(AG_LocalPlayer.Name .. "SpawnedInToys")
end

-- spawntoy（元スクリプトと同一）
local function ag_spawntoy(name, cframe)
    local toy = ReplicatedStorage.MenuToys.SpawnToyRemoteFunction:InvokeServer(
        name,
        cframe,
        Vector3.zero
    )
    if toy and ag_getInv() then
        return ag_getInv():FindFirstChild(name)
    end
    return nil
end

-- destroyToy（元スクリプトと同一）
local function ag_destroyToy(model)
    ReplicatedStorage.MenuToys.DestroyToy:FireServer(model)
end

-- ragdoll（元スクリプトと同一）
local function ag_ragdoll()
    local root = ag_getLocalRoot()
    if root then
        ReplicatedStorage.CharacterEvents.RagdollRemote:FireServer(root, 0)
    end
end

-- アンチグッチの状態変数
local AG_Enabled  = false
local AG_Blob     = nil
local AG_Conn     = nil
local AG_lastCheck = 0

-- オン処理（元スクリプトのAntiGucciToggle ON部分と同一）
local function ag_turnOn()
    AG_Enabled = true

    task.spawn(function()
        repeat task.wait() until ag_getLocalChar() and ag_getLocalRoot() and ag_getLocalHum()

        local pos = ag_getLocalRoot().CFrame

        local blob = ag_spawntoy("CreatureBlobman", ag_getLocalRoot().CFrame)
        AG_Blob = blob

        if blob then
            local head = blob:FindFirstChild("Head")
            if head then
                head.CFrame = CFrame.new(1e5, 1e5, 1e5)
                head.Anchored = true
            end

            task.wait(0.25)

            if blob:FindFirstChild("VehicleSeat") then
                local seat = blob.VehicleSeat
                ag_getLocalRoot().CFrame = seat.CFrame + Vector3.new(0, 2, 0)
                seat:Sit(ag_getLocalHum())
            end

            task.wait(0.25)

            ag_getLocalHum():ChangeState(Enum.HumanoidStateType.Jumping)
            task.wait(0.25)
            ag_getLocalRoot().CFrame = pos
        end
    end)
end

-- オフ処理（元スクリプトのAntiGucciToggle OFF部分と同一）
local function ag_turnOff()
    AG_Enabled = false
    if AG_Blob then
        ag_destroyToy(AG_Blob)
        AG_Blob = nil
    end
end

-- Heartbeatループ（元スクリプトのRunService.Heartbeatと同一）
AG_Conn = RunService.Heartbeat:Connect(function(deltaTime)
    if AG_Enabled then
        -- ragdollを維持（元スクリプトと同一）
        local hum = ag_getLocalHum()
        if hum then
            ag_ragdoll()
        end

        -- ブロブ状態チェック（元スクリプトと同一）
        if AG_Blob then
            if not AG_Blob.Parent then
                AG_Blob = nil
                task.spawn(function()
                    task.wait(0.5)
                    if AG_Enabled then
                        ag_turnOff()
                        task.wait(0.5)
                        ag_turnOn()
                        OrionLib:MakeNotification({ Name = "アンチグッチ", Content = "ブロブが消えたため再起動しました", Time = 2 })
                    end
                end)
            end
        else
            AG_lastCheck = AG_lastCheck + deltaTime
            if AG_lastCheck >= 1 then
                AG_lastCheck = 0
                if AG_Enabled and ag_getInv() then
                    local existingBlob = ag_getInv():FindFirstChild("CreatureBlobman")
                    if existingBlob then
                        AG_Blob = existingBlob
                        local head = existingBlob:FindFirstChild("Head")
                        if head then
                            head.CFrame = CFrame.new(1e5, 1e5, 1e5)
                            head.Anchored = true
                        end
                    else
                        task.spawn(function()
                            ag_turnOff()
                            task.wait(0.5)
                            if AG_Enabled then
                                ag_turnOn()
                                OrionLib:MakeNotification({ Name = "アンチグッチ", Content = "ブロブを再生成しました", Time = 2 })
                            end
                        end)
                    end
                end
            end
        end
    end
end)

-- キャラリセット時（元スクリプトのCharacterRemoving/CharacterAddedと同一）
AG_LocalPlayer.CharacterRemoving:Connect(function()
    if AG_Blob then
        ag_destroyToy(AG_Blob)
        AG_Blob = nil
    end
    AG_Enabled = false
end)

AG_LocalPlayer.CharacterAdded:Connect(function()
    task.wait(2)
    if AG_Enabled then
        AG_Blob = nil
        task.spawn(function()
            task.wait(1)
            if AG_Enabled then
                ag_turnOn()
            end
        end)
    end
end)

--==============================
-- ORION UI タブ
--==============================
local AntiGucciTab = Window:MakeTab({
    Name = "アンチグッチ",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false,
})

AntiGucciTab:AddSection({ Name = "アンチグッチ制御" })

-- メイントグル（ON/OFFの切り替え）
AntiGucciTab:AddToggle({
    Name = "アンチグッチ 有効化",
    Default = false,
    Flag = "AntiGucciEnabled",
    Callback = function(Value)
        if Value then
            ag_turnOn()
            OrionLib:MakeNotification({
                Name = "アンチグッチ",
                Content = "有効化しました",
                Time = 2,
            })
        else
            ag_turnOff()
            OrionLib:MakeNotification({
                Name = "アンチグッチ",
                Content = "無効化しました",
                Time = 2,
            })
        end
    end,
})

-- 手動再起動ボタン
AntiGucciTab:AddButton({
    Name = "手動でブロブを再起動",
    Callback = function()
        ag_turnOff()
        task.wait(0.5)
        if AG_Enabled then
            ag_turnOn()
            OrionLib:MakeNotification({ Name = "アンチグッチ", Content = "ブロブを再起動しました", Time = 2 })
        else
            OrionLib:MakeNotification({ Name = "アンチグッチ", Content = "先にトグルをONにしてください", Time = 2 })
        end
    end,
})

-- 強制オフ＆ブロブ削除ボタン
AntiGucciTab:AddButton({
    Name = "強制停止 & ブロブ削除",
    Callback = function()
        ag_turnOff()
        AG_Enabled = false
        OrionLib:MakeNotification({ Name = "アンチグッチ", Content = "強制停止しました", Time = 2 })
    end,
})

AntiGucciTab:AddSection({ Name = "説明" })

AntiGucciTab:AddLabel("ONにするとCreatureBlobmanを自動生成し")
AntiGucciTab:AddLabel("グッチキックを防御します。")
AntiGucciTab:AddLabel("ブロブが消えた場合は自動で再生成されます。")

--==============================
-- タブ：GlassBoxGray Hub
-- ※ OrionLib:Init() の前に挿入
--==============================

local RunService = game:GetService("RunService")
local Players    = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

--==================================================
-- 共通ユーティリティ
--==================================================
local function gbg_findByName(name)
    local found = {}
    for _, item in ipairs(workspace:GetDescendants()) do
        if (item:IsA("BasePart") or item:IsA("Model")) and item.Name == name then
            table.insert(found, item)
        end
    end
    return found
end

local function gbg_getBase(obj)
    if obj:IsA("Model") then
        return obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
    elseif obj:IsA("BasePart") then
        return obj
    end
    return nil
end

local function gbg_setupMovers(part)
    if not part then return nil, nil end
    local eP = part:FindFirstChildOfClass("BodyPosition")
    local eG = part:FindFirstChildOfClass("BodyGyro")
    if eP then eP:Destroy() end
    if eG then eG:Destroy() end
    local BP = Instance.new("BodyPosition")
    BP.P = 25000; BP.D = 800
    BP.MaxForce = Vector3.new(1,1,1) * 1e10
    BP.Parent = part
    local BG = Instance.new("BodyGyro")
    BG.P = 25000; BG.D = 800
    BG.MaxTorque = Vector3.new(1,1,1) * 1e10
    BG.Parent = part
    return BP, BG
end

local function gbg_setupObj(obj)
    local base = gbg_getBase(obj)
    if not base then return nil end
    if obj:IsA("Model") then
        for _, c in ipairs(obj:GetDescendants()) do
            if c:IsA("BasePart") then
                c.CanCollide = false; c.CanTouch = false; c.Anchored = false
            end
        end
    else
        base.CanCollide = false; base.CanTouch = false; base.Anchored = false
    end
    local BP, BG = gbg_setupMovers(base)
    return { BP = BP, BG = BG, Part = base, Original = obj }
end

local function gbg_release(obj)
    if obj.BP and obj.BP.Parent then obj.BP:Destroy() end
    if obj.BG and obj.BG.Parent then obj.BG:Destroy() end
    if obj.Part and obj.Part.Parent then obj.Part.Anchored = true end
end

--==================================================
-- GlassBoxGray 設定
--==================================================
local gbgConfig = {
    enabled      = false,
    partName     = "GlassBoxGray",
    mode         = "Orbit",   -- Wings / Orbit / Shield / Dome / Spiral / Crown / HeadFloat
    count        = 8,
    useAllFound  = false,
    speed        = 1.5,
    smoothness   = 0.15,

    -- Wings
    wingsSpacing        = 1.3,
    wingsAmplitude      = 2.5,
    wingsPhaseOffset    = 0.3,
    wingsDistMult       = 0.4,
    wingsHorizAmount    = 0.5,
    wingsForward        = 3,
    wingsHeight         = 1,
    wingsXRot           = -45,
    wingsYRot           = 0,
    wingsZRot           = 90,

    -- Orbit (円周回転)
    orbitRadius  = 5,
    orbitHeight  = 0,
    orbitShape   = "Circle", -- Circle / Wave / Figure8 / Star / DNA
    waveAmp      = 1.5,
    waveFreq     = 2,
    starPoints   = 5,
    starInner    = 2,
    helixH       = 5,
    faceCenter   = false,
    yRotOffset   = 0,

    -- Shield (自分を囲む盾状の壁)
    shieldRadius = 3.5,
    shieldHeight = 0,
    shieldLayers = 1,       -- 層数 1〜3
    shieldLayerGap = 1.2,   -- 層間距離
    shieldSpin   = true,    -- 回転するか

    -- Dome (半球状に頭上を覆う)
    domeRadius   = 4,
    domeLayers   = 3,       -- 半球の段数

    -- Spiral (螺旋状に上昇)
    spiralRadius = 3,
    spiralHeight = 6,
    spiralLoops  = 2,

    -- Crown (頭上に王冠状)
    crownRadius  = 2.5,
    crownHeight  = 3.5,
    crownBobAmp  = 0.3,
    crownBobSpeed = 1.5,

    -- HeadFloat (頭上に1個浮く)
    headHeight   = 4,
    headBobAmp   = 0.35,
    headBobSpeed = 1.8,

    -- FerrisWheel (観覧車)
    ferrisRadius     = 5,    -- 観覧車の半径
    ferrisHeight     = 5,    -- 観覧車の中心高さ（地面から）
    ferrisAxisAngle  = 0,    -- 観覧車の傾き角度（Y軸回転）
    ferrisSelfSpin   = true, -- ゴンドラ自身が自転するか

    -- Robot (ロボット隊形)
    robotFormation  = "Humanoid", -- Humanoid / Surround / March
    robotScale      = 1,
    robotHeadH      = 5,     -- 頭パーツの高さ
    robotBodyH      = 3,     -- 胴体パーツの高さ
    robotArmSpread  = 2.5,   -- 腕の広がり
    robotLegSpread  = 1.2,   -- 脚の広がり
    robotLegH       = 1,     -- 脚の高さ
    robotMarchAmp   = 1.2,   -- 行進振幅
}

local gbgObjs  = {}
local gbgTime  = 0
local gbgConn  = nil

--==================================================
-- 位置計算関数
--==================================================

-- Orbit
local function gbg_orbitPos(i, total, t, cPos, cCF)
    local angle = (i-1)/total * math.pi * 2
    local r = gbgConfig.orbitRadius
    local x, y, z = 0, gbgConfig.orbitHeight, 0
    local shape = gbgConfig.orbitShape

    if shape == "Circle" then
        local a = angle + t * gbgConfig.speed
        x = math.cos(a)*r; z = math.sin(a)*r

    elseif shape == "Wave" then
        local a = angle + t * gbgConfig.speed
        x = math.cos(a)*r; z = math.sin(a)*r
        y = gbgConfig.orbitHeight + math.sin(a * gbgConfig.waveFreq + t * gbgConfig.speed) * gbgConfig.waveAmp

    elseif shape == "Figure8" then
        local a = t * gbgConfig.speed + angle
        x = math.sin(a)*r; z = math.sin(a*2)*r*0.5

    elseif shape == "Star" then
        local pts = gbgConfig.starPoints
        local iR  = gbgConfig.starInner
        local a   = angle + t * gbgConfig.speed
        local pA  = (math.pi*2)/pts
        local blend = (a % pA)/pA
        local dist = iR + (r-iR)*math.abs(math.sin(blend*math.pi))
        x = math.cos(a)*dist; z = math.sin(a)*dist

    elseif shape == "DNA" then
        local a = angle + t * gbgConfig.speed
        local strand = (i%2==0) and 1 or -1
        x = math.cos(a + strand*math.pi)*r
        z = math.sin(a + strand*math.pi)*r*0.3
        y = gbgConfig.orbitHeight + (a/(math.pi*2))*gbgConfig.helixH*0.5
    end

    local yOff = math.rad(gbgConfig.yRotOffset)
    local rx = x*math.cos(yOff) - z*math.sin(yOff)
    local rz = x*math.sin(yOff) + z*math.cos(yOff)
    x, z = rx, rz
    local _, cYR, _ = cCF:ToOrientation()
    return cPos + Vector3.new(
        x*math.cos(cYR) - z*math.sin(cYR),
        y,
        x*math.sin(cYR) + z*math.cos(cYR)
    )
end

-- Shield (円盤状の壁・多層対応)
local function gbg_shieldPos(i, total, t, cPos, cCF)
    -- 層と位置を計算
    local perLayer = math.ceil(total / gbgConfig.shieldLayers)
    local layer    = math.floor((i-1) / perLayer)
    local idxInLayer = ((i-1) % perLayer)
    local angle = idxInLayer / perLayer * math.pi * 2
    local r = gbgConfig.shieldRadius + layer * gbgConfig.shieldLayerGap

    local spin = gbgConfig.shieldSpin and (t * gbgConfig.speed) or 0
    local a = angle + spin + (layer * math.pi / gbgConfig.shieldLayers) -- 層ごとにずらす

    local x = math.cos(a) * r
    local z = math.sin(a) * r
    local y = gbgConfig.shieldHeight

    local _, cYR, _ = cCF:ToOrientation()
    return cPos + Vector3.new(
        x*math.cos(cYR) - z*math.sin(cYR),
        y,
        x*math.sin(cYR) + z*math.cos(cYR)
    )
end

-- Dome (半球状)
local function gbg_domePos(i, total, t, cPos, cCF)
    local layers = gbgConfig.domeLayers
    local perLayer = math.ceil(total / layers)
    local layer    = math.floor((i-1) / perLayer) + 1
    local idxInLayer = ((i-1) % perLayer)
    local r = gbgConfig.domeRadius

    -- 緯度 (0=水平〜pi/2=頂点)
    local lat = (layer / layers) * (math.pi / 2)
    local layerR = r * math.cos(lat)
    local y = r * math.sin(lat)

    local countInLayer = math.min(perLayer, total - (layer-1)*perLayer)
    local angle = (idxInLayer / math.max(countInLayer,1)) * math.pi * 2
    local spin  = t * gbgConfig.speed * (layer % 2 == 0 and 1 or -1) -- 交互に逆回転
    local a = angle + spin

    local x = math.cos(a) * layerR
    local z = math.sin(a) * layerR

    local _, cYR, _ = cCF:ToOrientation()
    return cPos + Vector3.new(
        x*math.cos(cYR) - z*math.sin(cYR),
        y + 1, -- 少し上に
        x*math.sin(cYR) + z*math.cos(cYR)
    )
end

-- Spiral (螺旋)
local function gbg_spiralPos(i, total, t, cPos, cCF)
    local prog = (i-1) / math.max(total-1, 1)
    local loops = gbgConfig.spiralLoops
    local angle = prog * math.pi * 2 * loops + t * gbgConfig.speed
    local r = gbgConfig.spiralRadius
    local x = math.cos(angle) * r
    local z = math.sin(angle) * r
    local y = prog * gbgConfig.spiralHeight - gbgConfig.spiralHeight * 0.3

    local _, cYR, _ = cCF:ToOrientation()
    return cPos + Vector3.new(
        x*math.cos(cYR) - z*math.sin(cYR),
        y,
        x*math.sin(cYR) + z*math.cos(cYR)
    )
end

-- Crown (王冠)
local function gbg_crownPos(i, total, t, cPos, cCF, head)
    local angle = (i-1)/total * math.pi * 2 + t * gbgConfig.speed
    local r = gbgConfig.crownRadius
    local x = math.cos(angle) * r
    local z = math.sin(angle) * r
    -- 交互に高低をつける王冠の歯
    local yOscillate = (i % 2 == 0) and 0.6 or 0
    local headY = head and head.Position.Y or cPos.Y + 2
    local bob = math.sin(t * gbgConfig.crownBobSpeed) * gbgConfig.crownBobAmp
    local y = headY + gbgConfig.crownHeight + yOscillate + bob

    local _, cYR, _ = cCF:ToOrientation()
    return Vector3.new(cPos.X, 0, cPos.Z) + Vector3.new(
        x*math.cos(cYR) - z*math.sin(cYR),
        y,
        x*math.sin(cYR) + z*math.cos(cYR)
    )
end

-- HeadFloat (頭上1個)
local function gbg_headFloatPos(t, cPos, head)
    local headY = head and head.Position.Y or cPos.Y + 2
    local bob = math.sin(t * gbgConfig.headBobSpeed) * gbgConfig.headBobAmp
    return Vector3.new(cPos.X, headY + gbgConfig.headHeight + bob, cPos.Z)
end

-- FerrisWheel (観覧車)
-- 観覧車のイメージ：垂直に立った輪の上をゴンドラが回る
local function gbg_ferrisPos(i, total, t, cPos, cCF)
    local angle = (i-1)/total * math.pi * 2 + t * gbgConfig.speed
    local r = gbgConfig.ferrisRadius

    -- 観覧車は垂直面を回るのでXZ平面ではなくXY or ZY平面
    -- axisAngleで向きを変えられる
    local ax = math.rad(gbgConfig.ferrisAxisAngle)
    local x_raw = math.cos(angle) * r
    local y_raw = math.sin(angle) * r + gbgConfig.ferrisHeight

    -- 観覧車の向きをキャラの前方に合わせる
    local _, cYR, _ = cCF:ToOrientation()
    local totalAngle = cYR + ax
    -- 観覧車は前後方向に立つ（look方向がZ軸）
    local x = x_raw * math.cos(totalAngle)
    local z = x_raw * math.sin(totalAngle)
    local y = y_raw

    return cPos + Vector3.new(x, y, z)
end

-- Robot (ロボット隊形)
-- パーツをロボットの体の各部位に割り当てる
local function gbg_robotPos(i, total, t, cPos, cCF)
    local s  = gbgConfig.robotScale
    local mode = gbgConfig.robotFormation
    local _, cYR, _ = cCF:ToOrientation()
    local cosY = math.cos(cYR)
    local sinY = math.sin(cYR)

    local function rotXZ(x, z)
        return x*cosY - z*sinY, x*sinY + z*cosY
    end

    if mode == "Humanoid" then
        -- ロボット体型：部位ごとに位置を固定割り当て
        -- 1=頭, 2=胴, 3=左腕, 4=右腕, 5=左脚, 6=右脚, 7以降=装飾（頭上に積む）
        local parts = {
            {0,   gbgConfig.robotHeadH,              0   },  -- 1: 頭
            {0,   gbgConfig.robotBodyH,              0   },  -- 2: 胴体
            {-gbgConfig.robotArmSpread*s, gbgConfig.robotBodyH+0.5, 0}, -- 3: 左腕
            { gbgConfig.robotArmSpread*s, gbgConfig.robotBodyH+0.5, 0}, -- 4: 右腕
            {-gbgConfig.robotLegSpread*s, gbgConfig.robotLegH,      0}, -- 5: 左脚
            { gbgConfig.robotLegSpread*s, gbgConfig.robotLegH,      0}, -- 6: 右脚
        }
        if i <= #parts then
            local p = parts[i]
            local rx, rz = rotXZ(p[1], p[3])
            return cPos + Vector3.new(rx, p[2], rz)
        else
            -- 7個以上は頭上に積む
            local extra = i - #parts
            local ax = math.cos((extra-1)/(total-#parts+0.001)*math.pi*2 + t*gbgConfig.speed) * 0.5 * s
            local az = math.sin((extra-1)/(total-#parts+0.001)*math.pi*2 + t*gbgConfig.speed) * 0.5 * s
            local rx, rz = rotXZ(ax, az)
            return cPos + Vector3.new(rx, gbgConfig.robotHeadH + extra*0.6*s, rz)
        end

    elseif mode == "Surround" then
        -- 自分の周りをロボット部隊が囲む（等間隔配置＋上下の揺れ）
        local angle = (i-1)/total * math.pi*2 + t * gbgConfig.speed * 0.3
        local r = gbgConfig.robotArmSpread * 2 * s
        local x = math.cos(angle) * r
        local z = math.sin(angle) * r
        local y = gbgConfig.robotBodyH + math.sin(t * gbgConfig.speed + i) * gbgConfig.robotMarchAmp
        local rx, rz = rotXZ(x, z)
        return cPos + Vector3.new(rx, y, rz)

    elseif mode == "March" then
        -- 行進隊形：縦一列で前後に並び、足踏み動作
        local row    = math.ceil(i / 2)
        local side   = (i % 2 == 0) and 1 or -1
        local fwdOff = -(row - 1) * 2 * s  -- 後ろに並ぶ
        local sideOff = side * gbgConfig.robotLegSpread * s
        -- 足踏みのY振動（左右で逆位相）
        local marchY = math.sin(t * gbgConfig.speed * 2 + i * math.pi) * gbgConfig.robotMarchAmp
        local x = sideOff
        local z = fwdOff
        local y = gbgConfig.robotBodyH + marchY
        -- 前進方向に向けて回転
        local rx = x*cosY - z*sinY
        local rz = x*sinY + z*cosY
        return cPos + Vector3.new(rx, y, rz)
    end

    -- fallback
    return cPos + Vector3.new(0, 3, 0)
end

-- Wings用RowPoints
local function gbg_createWingsPoints(count)
    local pts = {}
    if count == 0 then return pts end
    local half = math.floor(count/2)
    local isOdd = count%2 == 1
    local idx = 1
    if isOdd then table.insert(pts, {baseOffsetX=0, index=idx}); idx+=1 end
    for i = 1, half do
        local off = i * gbgConfig.wingsSpacing
        table.insert(pts, {baseOffsetX=off,  index=idx}); idx+=1
        table.insert(pts, {baseOffsetX=-off, index=idx}); idx+=1
    end
    return pts
end

--==================================================
-- 起動/停止
--==================================================
local gbgRowPoints = {}

local function gbg_stop()
    if gbgConn then gbgConn:Disconnect(); gbgConn = nil end
    for _, obj in ipairs(gbgObjs) do gbg_release(obj) end
    gbgObjs = {}; gbgRowPoints = {}
end

local function gbg_start()
    gbg_stop()
    local found = gbg_findByName(gbgConfig.partName)
    if #found == 0 then
        OrionLib:MakeNotification({ Name = "エラー", Content = "'" .. gbgConfig.partName .. "' が見つかりません", Time = 3 })
        return
    end
    local useCount = gbgConfig.useAllFound and #found or math.min(gbgConfig.count, #found)
    for i = 1, useCount do
        local obj = gbg_setupObj(found[i])
        if obj then table.insert(gbgObjs, obj) end
    end
    if gbgConfig.mode == "Wings" then
        gbgRowPoints = gbg_createWingsPoints(#gbgObjs)
    end
    OrionLib:MakeNotification({
        Name = "GlassBoxGray 起動",
        Content = "モード: " .. gbgConfig.mode .. " / 数: " .. #gbgObjs,
        Time = 2,
    })
    gbgTime = 0

    gbgConn = RunService.RenderStepped:Connect(function(dt)
        if not gbgConfig.enabled then return end
        local char = LocalPlayer.Character
        if not char then return end
        local hrp  = char:FindFirstChild("HumanoidRootPart")
        local torso = char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
        local head  = char:FindFirstChild("Head")
        if not hrp then return end

        gbgTime += dt
        local cPos  = hrp.Position
        local cCF   = hrp.CFrame
        local total = #gbgObjs
        local mode  = gbgConfig.mode
        local sm    = gbgConfig.smoothness

        -- Wings
        if mode == "Wings" then
            local basePos = (torso and torso.Position or cPos)
                + Vector3.new(0, gbgConfig.wingsHeight, 0)
                + cCF.LookVector * gbgConfig.wingsForward
            for i, obj in ipairs(gbgObjs) do
                if obj.BP and obj.BP.Parent and obj.BG and obj.BG.Parent then
                    local pt = gbgRowPoints[i]
                    if not pt then continue end
                    local dist = math.abs(pt.baseOffsetX)
                    local amp  = gbgConfig.wingsAmplitude + dist * gbgConfig.wingsDistMult
                    local wave = math.sin(gbgTime * gbgConfig.speed + pt.index * gbgConfig.wingsPhaseOffset)
                    local hOff = pt.baseOffsetX
                    if pt.baseOffsetX ~= 0 then
                        local sign = pt.baseOffsetX > 0 and 1 or -1
                        hOff = pt.baseOffsetX - sign * math.abs(pt.baseOffsetX) * wave * gbgConfig.wingsHorizAmount
                    end
                    local pos = basePos + cCF.RightVector * hOff + Vector3.new(0, wave*amp, 0)
                    obj.BP.Position = obj.BP.Position + (pos - obj.BP.Position) * sm
                    local cf = CFrame.new(pos)
                    local _, pYR, _ = cCF:ToOrientation()
                    cf = cf * CFrame.Angles(0, pYR + math.rad(gbgConfig.wingsYRot), 0)
                       * CFrame.Angles(math.rad(gbgConfig.wingsXRot), 0, 0)
                       * CFrame.Angles(0, 0, math.rad(gbgConfig.wingsZRot))
                    obj.BG.CFrame = obj.BG.CFrame:Lerp(cf, sm)
                end
            end

        -- Orbit
        elseif mode == "Orbit" then
            for i, obj in ipairs(gbgObjs) do
                if obj.BP and obj.BP.Parent then
                    local pos = gbg_orbitPos(i, total, gbgTime, cPos, cCF)
                    obj.BP.Position = obj.BP.Position + (pos - obj.BP.Position) * sm
                    if gbgConfig.faceCenter and obj.BG and obj.BG.Parent then
                        obj.BG.CFrame = obj.BG.CFrame:Lerp(CFrame.lookAt(pos, cPos), 0.2)
                    end
                end
            end

        -- Shield
        elseif mode == "Shield" then
            for i, obj in ipairs(gbgObjs) do
                if obj.BP and obj.BP.Parent then
                    local pos = gbg_shieldPos(i, total, gbgTime, cPos, cCF)
                    obj.BP.Position = obj.BP.Position + (pos - obj.BP.Position) * sm
                    if obj.BG and obj.BG.Parent then
                        -- 盾は常に外側を向く
                        local outDir = (pos - cPos)
                        if outDir.Magnitude > 0.01 then
                            local lookCF = CFrame.lookAt(pos, cPos + outDir * 2)
                            obj.BG.CFrame = obj.BG.CFrame:Lerp(lookCF, 0.15)
                        end
                    end
                end
            end

        -- Dome
        elseif mode == "Dome" then
            for i, obj in ipairs(gbgObjs) do
                if obj.BP and obj.BP.Parent then
                    local pos = gbg_domePos(i, total, gbgTime, cPos, cCF)
                    obj.BP.Position = obj.BP.Position + (pos - obj.BP.Position) * sm
                end
            end

        -- Spiral
        elseif mode == "Spiral" then
            for i, obj in ipairs(gbgObjs) do
                if obj.BP and obj.BP.Parent then
                    local pos = gbg_spiralPos(i, total, gbgTime, cPos, cCF)
                    obj.BP.Position = obj.BP.Position + (pos - obj.BP.Position) * sm
                end
            end

        -- Crown
        elseif mode == "Crown" then
            for i, obj in ipairs(gbgObjs) do
                if obj.BP and obj.BP.Parent then
                    local pos = gbg_crownPos(i, total, gbgTime, cPos, cCF, head)
                    obj.BP.Position = obj.BP.Position + (pos - obj.BP.Position) * sm
                end
            end

        -- HeadFloat
        elseif mode == "HeadFloat" then
            -- 全部頭上に重ねて浮かべる（ランダムな微小オフセットで分散）
            for i, obj in ipairs(gbgObjs) do
                if obj.BP and obj.BP.Parent then
                    local spread = 0.3
                    local angle  = (i-1)/total * math.pi*2
                    local ox = math.cos(angle + gbgTime * gbgConfig.speed * 0.3) * spread * ((i-1) % 3)
                    local oz = math.sin(angle + gbgTime * gbgConfig.speed * 0.3) * spread * ((i-1) % 3)
                    local basePos = gbg_headFloatPos(gbgTime, cPos, head)
                    local pos = basePos + Vector3.new(ox, (i-1)*0.15, oz)
                    obj.BP.Position = obj.BP.Position + (pos - obj.BP.Position) * sm
                end
            end

        -- FerrisWheel (観覧車)
        elseif mode == "FerrisWheel" then
            for i, obj in ipairs(gbgObjs) do
                if obj.BP and obj.BP.Parent then
                    local pos = gbg_ferrisPos(i, total, gbgTime, cPos, cCF)
                    obj.BP.Position = obj.BP.Position + (pos - obj.BP.Position) * sm
                    -- ゴンドラが常に下を向くように自転
                    if gbgConfig.ferrisSelfSpin and obj.BG and obj.BG.Parent then
                        local angle = (i-1)/total * math.pi*2 + gbgTime * gbgConfig.speed
                        -- ゴンドラは重力方向を向く（垂直面で自転）
                        local spinCF = CFrame.new(pos) * CFrame.Angles(angle, 0, 0)
                        obj.BG.CFrame = obj.BG.CFrame:Lerp(spinCF, sm)
                    end
                end
            end

        -- Robot (ロボット隊形)
        elseif mode == "Robot" then
            for i, obj in ipairs(gbgObjs) do
                if obj.BP and obj.BP.Parent then
                    local pos = gbg_robotPos(i, total, gbgTime, cPos, cCF)
                    obj.BP.Position = obj.BP.Position + (pos - obj.BP.Position) * sm
                    -- ロボットはキャラと同じ方向を向く
                    if obj.BG and obj.BG.Parent then
                        local _, pYR, _ = cCF:ToOrientation()
                        local faceCF = CFrame.new(pos) * CFrame.Angles(0, pYR, 0)
                        obj.BG.CFrame = obj.BG.CFrame:Lerp(faceCF, sm)
                    end
                end
            end
        end
    end)
end

--==================================================
-- ORION UI タブ
--==================================================
local GlassTab = Window:MakeTab({
    Name = "GlassBoxGray",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false,
})

-- 制御
GlassTab:AddSection({ Name = "⬜ GlassBoxGray 制御" })

GlassTab:AddToggle({
    Name = "有効化",
    Default = false,
    Flag = "GBGEnabled",
    Callback = function(v)
        gbgConfig.enabled = v
        if v then gbg_start()
        else gbg_stop(); OrionLib:MakeNotification({ Name = "GBG停止", Content = "停止しました", Time = 2 }) end
    end,
})

GlassTab:AddTextbox({
    Name = "対象Part名",
    Default = "GlassBoxGray",
    TextDisappear = false,
    Callback = function(v) gbgConfig.partName = v end,
})

GlassTab:AddDropdown({
    Name = "モード",
    Default = "Orbit",
    Options = { "Wings", "Orbit", "Shield", "Dome", "Spiral", "Crown", "HeadFloat", "FerrisWheel", "Robot" },
    Callback = function(v)
        gbgConfig.mode = v
        if gbgConfig.enabled then gbg_start() end
    end,
})

GlassTab:AddToggle({ Name = "全Part使用", Default = false, Flag = "GBGUseAll",
    Callback = function(v) gbgConfig.useAllFound = v end })

GlassTab:AddSlider({ Name = "使用数", Min = 1, Max = 60, Default = 8, Increment = 1, ValueName = "個",
    Callback = function(v) gbgConfig.count = v end })

GlassTab:AddSlider({ Name = "速度", Min = -10, Max = 10, Default = 1.5, Increment = 0.1, ValueName = "",
    Callback = function(v) gbgConfig.speed = v end })

GlassTab:AddSlider({ Name = "滑らかさ", Min = 0.01, Max = 1, Default = 0.15, Increment = 0.01, ValueName = "",
    Callback = function(v) gbgConfig.smoothness = v end })

GlassTab:AddButton({
    Name = "再検索 & 再起動",
    Callback = function()
        if gbgConfig.enabled then gbg_start()
        else
            local f = gbg_findByName(gbgConfig.partName)
            OrionLib:MakeNotification({ Name = "検索", Content = #f .. "個発見", Time = 3 })
        end
    end,
})

-- Wings設定
GlassTab:AddSection({ Name = "🪶 Wings 設定" })
GlassTab:AddSlider({ Name = "Wings: 間隔", Min = 0.3, Max = 5, Default = 1.3, Increment = 0.1, ValueName = "",
    Callback = function(v) gbgConfig.wingsSpacing = v; if gbgConfig.enabled and gbgConfig.mode=="Wings" then gbgRowPoints = gbg_createWingsPoints(#gbgObjs) end end })
GlassTab:AddSlider({ Name = "Wings: 振幅", Min = 0, Max = 10, Default = 2.5, Increment = 0.1, ValueName = "",
    Callback = function(v) gbgConfig.wingsAmplitude = v end })
GlassTab:AddSlider({ Name = "Wings: 位相差", Min = 0, Max = 2, Default = 0.3, Increment = 0.05, ValueName = "",
    Callback = function(v) gbgConfig.wingsPhaseOffset = v end })
GlassTab:AddSlider({ Name = "Wings: 距離振幅増加", Min = 0, Max = 2, Default = 0.4, Increment = 0.05, ValueName = "",
    Callback = function(v) gbgConfig.wingsDistMult = v end })
GlassTab:AddSlider({ Name = "Wings: 内側寄り", Min = 0, Max = 2, Default = 0.5, Increment = 0.05, ValueName = "",
    Callback = function(v) gbgConfig.wingsHorizAmount = v end })
GlassTab:AddSlider({ Name = "Wings: 前方オフセット", Min = 0, Max = 15, Default = 3, Increment = 0.5, ValueName = "",
    Callback = function(v) gbgConfig.wingsForward = v end })
GlassTab:AddSlider({ Name = "Wings: 高さ", Min = -5, Max = 10, Default = 1, Increment = 0.5, ValueName = "",
    Callback = function(v) gbgConfig.wingsHeight = v end })
GlassTab:AddSlider({ Name = "Wings: X軸回転", Min = -180, Max = 180, Default = -45, Increment = 1, ValueName = "°",
    Callback = function(v) gbgConfig.wingsXRot = v end })
GlassTab:AddSlider({ Name = "Wings: Y軸回転", Min = -180, Max = 180, Default = 0, Increment = 1, ValueName = "°",
    Callback = function(v) gbgConfig.wingsYRot = v end })
GlassTab:AddSlider({ Name = "Wings: Z軸回転", Min = -180, Max = 180, Default = 90, Increment = 1, ValueName = "°",
    Callback = function(v) gbgConfig.wingsZRot = v end })
GlassTab:AddButton({ Name = "Wings: 回転リセット", Callback = function()
    gbgConfig.wingsXRot=-45; gbgConfig.wingsYRot=0; gbgConfig.wingsZRot=90
    OrionLib:MakeNotification({ Name = "リセット", Content = "Wings回転をリセット", Time = 2 })
end })

-- Orbit設定
GlassTab:AddSection({ Name = "🌀 Orbit 設定" })
GlassTab:AddDropdown({ Name = "Orbit: 形状", Default = "Circle",
    Options = { "Circle", "Wave", "Figure8", "Star", "DNA" },
    Callback = function(v) gbgConfig.orbitShape = v end })
GlassTab:AddSlider({ Name = "Orbit: 半径", Min = 1, Max = 30, Default = 5, Increment = 0.5, ValueName = "",
    Callback = function(v) gbgConfig.orbitRadius = v end })
GlassTab:AddSlider({ Name = "Orbit: 高さ", Min = -5, Max = 10, Default = 0, Increment = 0.5, ValueName = "",
    Callback = function(v) gbgConfig.orbitHeight = v end })
GlassTab:AddSlider({ Name = "Orbit: Y軸オフセット", Min = -180, Max = 180, Default = 0, Increment = 1, ValueName = "°",
    Callback = function(v) gbgConfig.yRotOffset = v end })
GlassTab:AddSlider({ Name = "Orbit: 波振幅 (Wave)", Min = 0, Max = 5, Default = 1.5, Increment = 0.1, ValueName = "",
    Callback = function(v) gbgConfig.waveAmp = v end })
GlassTab:AddSlider({ Name = "Orbit: 波周波数 (Wave)", Min = 1, Max = 10, Default = 2, Increment = 0.5, ValueName = "",
    Callback = function(v) gbgConfig.waveFreq = v end })
GlassTab:AddSlider({ Name = "Orbit: 螺旋高さ (DNA)", Min = 1, Max = 20, Default = 5, Increment = 0.5, ValueName = "",
    Callback = function(v) gbgConfig.helixH = v end })
GlassTab:AddSlider({ Name = "Orbit: 星頂点数 (Star)", Min = 3, Max = 12, Default = 5, Increment = 1, ValueName = "点",
    Callback = function(v) gbgConfig.starPoints = v end })
GlassTab:AddSlider({ Name = "Orbit: 星内半径 (Star)", Min = 0.5, Max = 10, Default = 2, Increment = 0.5, ValueName = "",
    Callback = function(v) gbgConfig.starInner = v end })
GlassTab:AddToggle({ Name = "Orbit: 中心を向く", Default = false, Flag = "GBGFace",
    Callback = function(v) gbgConfig.faceCenter = v end })

-- Shield設定
GlassTab:AddSection({ Name = "🛡️ Shield 設定" })
GlassTab:AddSlider({ Name = "Shield: 半径", Min = 1, Max = 15, Default = 3.5, Increment = 0.5, ValueName = "",
    Callback = function(v) gbgConfig.shieldRadius = v end })
GlassTab:AddSlider({ Name = "Shield: 高さ", Min = -5, Max = 8, Default = 0, Increment = 0.5, ValueName = "",
    Callback = function(v) gbgConfig.shieldHeight = v end })
GlassTab:AddSlider({ Name = "Shield: 層数", Min = 1, Max = 3, Default = 1, Increment = 1, ValueName = "層",
    Callback = function(v) gbgConfig.shieldLayers = v end })
GlassTab:AddSlider({ Name = "Shield: 層間距離", Min = 0.5, Max = 5, Default = 1.2, Increment = 0.1, ValueName = "",
    Callback = function(v) gbgConfig.shieldLayerGap = v end })
GlassTab:AddToggle({ Name = "Shield: 回転する", Default = true, Flag = "GBGShieldSpin",
    Callback = function(v) gbgConfig.shieldSpin = v end })

-- Dome設定
GlassTab:AddSection({ Name = "⛩️ Dome 設定" })
GlassTab:AddSlider({ Name = "Dome: 半径", Min = 1, Max = 15, Default = 4, Increment = 0.5, ValueName = "",
    Callback = function(v) gbgConfig.domeRadius = v end })
GlassTab:AddSlider({ Name = "Dome: 層数", Min = 1, Max = 5, Default = 3, Increment = 1, ValueName = "層",
    Callback = function(v) gbgConfig.domeLayers = v end })

-- Spiral設定
GlassTab:AddSection({ Name = "🌪️ Spiral 設定" })
GlassTab:AddSlider({ Name = "Spiral: 半径", Min = 1, Max = 15, Default = 3, Increment = 0.5, ValueName = "",
    Callback = function(v) gbgConfig.spiralRadius = v end })
GlassTab:AddSlider({ Name = "Spiral: 高さ範囲", Min = 1, Max = 20, Default = 6, Increment = 0.5, ValueName = "",
    Callback = function(v) gbgConfig.spiralHeight = v end })
GlassTab:AddSlider({ Name = "Spiral: ループ数", Min = 1, Max = 8, Default = 2, Increment = 1, ValueName = "周",
    Callback = function(v) gbgConfig.spiralLoops = v end })

-- Crown設定
GlassTab:AddSection({ Name = "👑 Crown 設定" })
GlassTab:AddSlider({ Name = "Crown: 半径", Min = 0.5, Max = 8, Default = 2.5, Increment = 0.5, ValueName = "",
    Callback = function(v) gbgConfig.crownRadius = v end })
GlassTab:AddSlider({ Name = "Crown: 高さ", Min = 1, Max = 10, Default = 3.5, Increment = 0.5, ValueName = "",
    Callback = function(v) gbgConfig.crownHeight = v end })
GlassTab:AddSlider({ Name = "Crown: ふわふわ速度", Min = 0, Max = 5, Default = 1.5, Increment = 0.1, ValueName = "",
    Callback = function(v) gbgConfig.crownBobSpeed = v end })
GlassTab:AddSlider({ Name = "Crown: ふわふわ幅", Min = 0, Max = 2, Default = 0.3, Increment = 0.05, ValueName = "",
    Callback = function(v) gbgConfig.crownBobAmp = v end })

-- HeadFloat設定
GlassTab:AddSection({ Name = "🎈 HeadFloat 設定" })
GlassTab:AddSlider({ Name = "HeadFloat: 高さ", Min = 1, Max = 10, Default = 4, Increment = 0.5, ValueName = "",
    Callback = function(v) gbgConfig.headHeight = v end })
GlassTab:AddSlider({ Name = "HeadFloat: ふわふわ速度", Min = 0, Max = 5, Default = 1.8, Increment = 0.1, ValueName = "",
    Callback = function(v) gbgConfig.headBobSpeed = v end })
GlassTab:AddSlider({ Name = "HeadFloat: ふわふわ幅", Min = 0, Max = 2, Default = 0.35, Increment = 0.05, ValueName = "",
    Callback = function(v) gbgConfig.headBobAmp = v end })

-- FerrisWheel設定
GlassTab:AddSection({ Name = "🎡 FerrisWheel 設定" })
GlassTab:AddSlider({ Name = "FerrisWheel: 半径", Min = 1, Max = 20, Default = 5, Increment = 0.5, ValueName = "",
    Callback = function(v) gbgConfig.ferrisRadius = v end })
GlassTab:AddSlider({ Name = "FerrisWheel: 中心高さ", Min = 0, Max = 15, Default = 5, Increment = 0.5, ValueName = "",
    Callback = function(v) gbgConfig.ferrisHeight = v end })
GlassTab:AddSlider({ Name = "FerrisWheel: 向き角度", Min = -180, Max = 180, Default = 0, Increment = 1, ValueName = "°",
    Callback = function(v) gbgConfig.ferrisAxisAngle = v end })
GlassTab:AddToggle({ Name = "FerrisWheel: ゴンドラ自転", Default = true, Flag = "GBGFerrisSpin",
    Callback = function(v) gbgConfig.ferrisSelfSpin = v end })

-- Robot設定
GlassTab:AddSection({ Name = "🤖 Robot 設定" })
GlassTab:AddDropdown({ Name = "Robot: 隊形", Default = "Humanoid",
    Options = { "Humanoid", "Surround", "March" },
    Callback = function(v) gbgConfig.robotFormation = v end })
GlassTab:AddSlider({ Name = "Robot: スケール", Min = 0.3, Max = 3, Default = 1, Increment = 0.1, ValueName = "x",
    Callback = function(v) gbgConfig.robotScale = v end })
GlassTab:AddSlider({ Name = "Robot: 頭の高さ (Humanoid)", Min = 2, Max = 12, Default = 5, Increment = 0.5, ValueName = "",
    Callback = function(v) gbgConfig.robotHeadH = v end })
GlassTab:AddSlider({ Name = "Robot: 胴体の高さ (Humanoid)", Min = 1, Max = 8, Default = 3, Increment = 0.5, ValueName = "",
    Callback = function(v) gbgConfig.robotBodyH = v end })
GlassTab:AddSlider({ Name = "Robot: 腕の広がり", Min = 0.5, Max = 8, Default = 2.5, Increment = 0.5, ValueName = "",
    Callback = function(v) gbgConfig.robotArmSpread = v end })
GlassTab:AddSlider({ Name = "Robot: 脚の広がり", Min = 0.3, Max = 5, Default = 1.2, Increment = 0.1, ValueName = "",
    Callback = function(v) gbgConfig.robotLegSpread = v end })
GlassTab:AddSlider({ Name = "Robot: 脚の高さ", Min = 0, Max = 5, Default = 1, Increment = 0.5, ValueName = "",
    Callback = function(v) gbgConfig.robotLegH = v end })
GlassTab:AddSlider({ Name = "Robot: 行進振幅 (March/Surround)", Min = 0, Max = 5, Default = 1.2, Increment = 0.1, ValueName = "",
    Callback = function(v) gbgConfig.robotMarchAmp = v end })



--==============================
-- 初期化
--==============================
OrionLib:Init()
