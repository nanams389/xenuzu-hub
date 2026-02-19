tgenv().gethui = function() return game.CoreGui end

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

--==================================================
-- [D] SpotlightBlue 設定
-- ※ fwConfig, fwToys などと同じ構造で独立して動作
--==================================================

local sbConfig = {
    enabled = false,
    targetPlayer = nil,
    targetPartName = "SpotlightBlue",  -- ← ここだけ変更
    maxSpotlights = 20,
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
local sbToys = {}
local sbRowPoints = {}
local sbAssigned = {}
local sbTime = 0

-- SpotlightBlue を workspace から検索
local function sbFindSpotlights()
    local toys = {}
    for _, item in ipairs(workspace:GetDescendants()) do
        if item:IsA("Model") and item.Name == sbConfig.targetPartName then
            local dup = false
            for _, e in ipairs(toys) do if e == item then dup = true break end end
            if not dup then table.insert(toys, item) end
        end
    end
    table.sort(toys, function(a, b) return a.Name < b.Name end)
    return toys
end

-- ダミー制御用パーツ生成
local function sbCP()
    local p = Instance.new("Part")
    p.CanCollide = false; p.Anchored = true; p.Transparency = 1
    p.Size = Vector3.new(4, 1, 4); p.Parent = workspace
    return p
end

-- BodyMover セットアップ
local function sbCBM(part)
    if not part then return nil, nil end
    local eBG = part:FindFirstChildOfClass("BodyGyro")
    local eBP = part:FindFirstChildOfClass("BodyPosition")
    if eBG and eBP then return eBG, eBP end
    if eBG then eBG:Destroy() end
    if eBP then eBP:Destroy() end
    local BP = Instance.new("BodyPosition")
    BP.P = 25000; BP.D = 800
    BP.MaxForce = Vector3.new(1, 1, 1) * 1e10; BP.Parent = part
    local BG = Instance.new("BodyGyro")
    BG.P = 25000; BG.D = 800
    BG.MaxTorque = Vector3.new(1, 1, 1) * 1e10; BG.Parent = part
    return BG, BP
end

-- モデルからプライマリパーツを取得
local function sbGetPrimary(model)
    if model.PrimaryPart then return model.PrimaryPart end
    for _, n in ipairs({"Handle", "Main", "Part", "Base", "Spotlight", "Light"}) do
        local p = model:FindFirstChild(n)
        if p and p:IsA("BasePart") then return p end
    end
    for _, c in ipairs(model:GetChildren()) do
        if c:IsA("BasePart") then return c end
    end
    return nil
end

-- 行配置ポイントを生成（左右対称）
local function sbCreateRowPoints(count)
    local points = {}
    if count == 0 then return points end
    local half = math.floor(count / 2)
    local isOdd = count % 2 == 1
    local idx = 1
    if isOdd then
        table.insert(points, { baseOffsetX = 0, part = sbCP(), index = idx }); idx += 1
    end
    for i = 1, half do
        local off = i * sbConfig.spacing
        table.insert(points, { baseOffsetX = off,  part = sbCP(), index = idx }); idx += 1
        table.insert(points, { baseOffsetX = -off, part = sbCP(), index = idx }); idx += 1
    end
    return points
end

-- 無効化（固定）
local function sbDisable()
    for _, point in ipairs(sbRowPoints) do
        if point.assignedToy and point.assignedToy.Pallet then
            if point.assignedToy.BP then point.assignedToy.BP:Destroy(); point.assignedToy.BP = nil end
            if point.assignedToy.BG then point.assignedToy.BG:Destroy(); point.assignedToy.BG = nil end
            for _, c in ipairs(point.assignedToy.Model:GetChildren()) do
                if c:IsA("BasePart") then
                    c.Anchored = true
                    c.Velocity = Vector3.new(0, 0, 0)
                    c.RotVelocity = Vector3.new(0, 0, 0)
                end
            end
        end
    end
end

-- 有効化（BodyMover再生成）
local function sbEnable()
    for _, point in ipairs(sbRowPoints) do
        if point.assignedToy and point.assignedToy.Pallet then
            for _, c in ipairs(point.assignedToy.Model:GetChildren()) do
                if c:IsA("BasePart") then c.Anchored = false end
            end
            local BG, BP = sbCBM(point.assignedToy.Pallet)
            point.assignedToy.BG = BG; point.assignedToy.BP = BP
        end
    end
end

-- ポイントにSpotlightBlueを割り当て
local function sbAssignToPoints()
    local assigned = {}
    local character = _getTargetChar(sbConfig.targetPlayer)
    if not character then return assigned end
    local hrp = character:FindFirstChild("HumanoidRootPart")
    local torso = character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso")
    if not hrp or not torso then return assigned end
    local charCF = hrp.CFrame
    local basePos = torso.Position + Vector3.new(0, sbConfig.heightOffset, 0) + charCF.LookVector * sbConfig.forwardOffset
    for i = 1, math.min(#sbToys, #sbRowPoints) do
        local toy = sbToys[i]
        if toy and toy:IsA("Model") and toy.Name == sbConfig.targetPartName then
            local primary = sbGetPrimary(toy)
            if primary then
                for _, c in ipairs(toy:GetChildren()) do
                    if c:IsA("BasePart") then c.CanCollide = false; c.CanTouch = false; c.Anchored = false end
                end
                local BG, BP = sbCBM(primary)
                local initPos = basePos + charCF.RightVector * sbRowPoints[i].baseOffsetX
                local t = {
                    BG = BG, BP = BP, Pallet = primary, Model = toy,
                    offsetX = sbRowPoints[i].baseOffsetX,
                    baseOffsetX = sbRowPoints[i].baseOffsetX,
                    index = sbRowPoints[i].index,
                }
                if BP then BP.Position = initPos end
                if BG then
                    local cf = CFrame.new(initPos)
                    local _, pYR, _ = charCF:ToOrientation()
                    cf = cf * CFrame.Angles(0, pYR + math.rad(sbConfig.yRotation), 0)
                    cf = cf * CFrame.Angles(math.rad(sbConfig.xRotation), 0, 0)
                    cf = cf * CFrame.Angles(0, 0, math.rad(sbConfig.zRotation))
                    BG.CFrame = cf
                end
                sbRowPoints[i].assignedToy = t
                table.insert(assigned, t)
            end
        end
    end
    return assigned
end

-- 再検出 & 再割り当て
local function sbRefresh()
    sbToys = sbFindSpotlights()
    sbRowPoints = sbCreateRowPoints(math.min(#sbToys, sbConfig.maxSpotlights))
    sbAssigned = sbAssignToPoints()
end

-- プレイヤーリスト（FWと共通関数 fwGetPlayerList を再利用）
-- ※ fwGetPlayerList() がすでに定義されていれば省略可

-- 初期化
sbRefresh()
workspace.DescendantAdded:Connect(function(d)
    if d:IsA("Model") and d.Name == sbConfig.targetPartName then
        task.wait(0.5); sbRefresh()
    end
end)

-- メインループ（RenderStepped で毎フレーム更新）
RunService.RenderStepped:Connect(function(dt)
    if not sbConfig.enabled then return end
    local character = _getTargetChar(sbConfig.targetPlayer)
    if not character then return end
    local torso = character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso")
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not torso or not hrp then return end
    sbTime += dt * sbConfig.waveSpeed
    local charCF = hrp.CFrame
    local basePos = torso.Position + Vector3.new(0, sbConfig.heightOffset, 0) + charCF.LookVector * sbConfig.forwardOffset
    for _, point in ipairs(sbRowPoints) do
        if point.assignedToy and point.assignedToy.BP and point.assignedToy.BG then
            local toy = point.assignedToy
            local dist = math.abs(toy.baseOffsetX)
            local amp = sbConfig.baseAmplitude + dist * sbConfig.distanceMultiplier
            local wave = math.sin(sbTime + toy.index * sbConfig.phaseOffset)
            local hOff = toy.baseOffsetX
            if toy.baseOffsetX ~= 0 then
                local sign = toy.baseOffsetX > 0 and 1 or -1
                hOff = toy.baseOffsetX - sign * math.abs(toy.baseOffsetX) * wave * sbConfig.horizontalWaveAmount
            end
            local finalPos = basePos + charCF.RightVector * hOff + Vector3.new(0, wave * amp, 0)
            if point.part then point.part.Position = finalPos end
            toy.BP.Position = finalPos
            local cf = CFrame.new(finalPos)
            local _, pYR, _ = charCF:ToOrientation()
            cf = cf * CFrame.Angles(0, pYR + math.rad(sbConfig.yRotation), 0)
            cf = cf * CFrame.Angles(math.rad(sbConfig.xRotation), 0, 0)
            cf = cf * CFrame.Angles(0, 0, math.rad(sbConfig.zRotation))
            toy.BG.CFrame = toy.BG.CFrame:Lerp(cf, sbConfig.smoothness)
        end
    end
end)

--==================================================
-- ORION UI: Wings & Orbit タブに追加するセクション
-- ※ WingsTab が定義された後、OrionLib:Init() の前に挿入
--==================================================

-- ============================================
-- セクション4: SpotlightBlue
-- ============================================
WingsTab:AddSection({ Name = "💙 SpotlightBlue" })

WingsTab:AddToggle({
    Name = "SB: 有効化",
    Default = false,
    Flag = "SBEnabled",
    Callback = function(v)
        sbConfig.enabled = v
        if v then sbEnable(); OrionLib:MakeNotification({ Name = "SB ON", Content = "SpotlightBlue 起動", Time = 2 })
        else sbDisable(); OrionLib:MakeNotification({ Name = "SB OFF", Content = "SpotlightBlue 固定", Time = 2 }) end
    end,
})

local sbPlayerDropdown
sbPlayerDropdown = WingsTab:AddDropdown({
    Name = "SB: 対象プレイヤー",
    Default = "自分",
    Options = fwGetPlayerList(),  -- fwGetPlayerList を再利用
    Callback = function(v)
        if v == "自分" then sbConfig.targetPlayer = nil
        else sbConfig.targetPlayer = Players:FindFirstChild(v) end
        sbAssigned = sbAssignToPoints()
    end,
})

WingsTab:AddButton({
    Name = "SB: プレイヤーリスト更新",
    Callback = function()
        sbPlayerDropdown:Refresh(fwGetPlayerList(), true)
        OrionLib:MakeNotification({ Name = "更新", Content = "リスト更新完了", Time = 2 })
    end,
})

WingsTab:AddButton({
    Name = "SB: SpotlightBlueを再検出",
    Callback = function()
        sbRefresh()
        OrionLib:MakeNotification({ Name = "再検出", Content = "SpotlightBlue数: " .. #sbToys, Time = 2 })
    end,
})

WingsTab:AddSlider({ Name = "SB: 最大数", Min = 2, Max = 40, Default = 20, Increment = 1, ValueName = "本",
    Callback = function(v) sbConfig.maxSpotlights = v; sbRefresh() end })
WingsTab:AddSlider({ Name = "SB: 間隔", Min = 0.5, Max = 5, Default = 1.2, Increment = 0.1, ValueName = "",
    Callback = function(v) sbConfig.spacing = v; sbRefresh() end })
WingsTab:AddSlider({ Name = "SB: 高さ", Min = -5, Max = 10, Default = 1, Increment = 0.5, ValueName = "",
    Callback = function(v) sbConfig.heightOffset = v end })
WingsTab:AddSlider({ Name = "SB: 前方オフセット", Min = 0, Max = 15, Default = 4, Increment = 0.5, ValueName = "",
    Callback = function(v) sbConfig.forwardOffset = v end })
WingsTab:AddSlider({ Name = "SB: 波速度", Min = 0, Max = 10, Default = 2.5, Increment = 0.1, ValueName = "",
    Callback = function(v) sbConfig.waveSpeed = v end })
WingsTab:AddSlider({ Name = "SB: 振幅", Min = 0, Max = 10, Default = 2, Increment = 0.1, ValueName = "",
    Callback = function(v) sbConfig.baseAmplitude = v end })
WingsTab:AddSlider({ Name = "SB: 位相差", Min = 0, Max = 2, Default = 0.3, Increment = 0.05, ValueName = "",
    Callback = function(v) sbConfig.phaseOffset = v end })
WingsTab:AddSlider({ Name = "SB: 内側への寄り", Min = 0, Max = 2, Default = 0.5, Increment = 0.05, ValueName = "",
    Callback = function(v) sbConfig.horizontalWaveAmount = v end })
WingsTab:AddSlider({ Name = "SB: 滑らかさ", Min = 0.01, Max = 1, Default = 0.6, Increment = 0.01, ValueName = "",
    Callback = function(v) sbConfig.smoothness = v end })
WingsTab:AddSlider({ Name = "SB: X軸回転", Min = -180, Max = 180, Default = -45, Increment = 1, ValueName = "°",
    Callback = function(v) sbConfig.xRotation = v end })
WingsTab:AddSlider({ Name = "SB: Y軸回転", Min = -180, Max = 180, Default = 0, Increment = 1, ValueName = "°",
    Callback = function(v) sbConfig.yRotation = v end })
WingsTab:AddSlider({ Name = "SB: Z軸回転", Min = -180, Max = 180, Default = 90, Increment = 1, ValueName = "°",
    Callback = function(v) sbConfig.zRotation = v end })
WingsTab:AddButton({ Name = "SB: 回転リセット", Callback = function()
    sbConfig.xRotation = -45; sbConfig.yRotation = 0; sbConfig.zRotation = 90
    OrionLib:MakeNotification({ Name = "リセット", Content = "回転をデフォルトに戻しました", Time = 2 })
end })

--==================================================
-- ↑ ここまでを Wings & Orbit タブの
--   「Ball Orbit: 星内半径」スライダーの後ろ、
--   「Ball: 再検索 & 再起動」ボタンの後ろに挿入する
--==================================================

--==================================================
-- [E] YouDecoy 設定
-- ※ fwConfig, sbConfig などと同じ構造で独立して動作
--==================================================

local ydConfig = {
    enabled = false,
    targetPlayer = nil,
    targetPartName = "YouDecoy",  -- ← ここだけ変更
    maxDecoys = 20,
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
local ydToys = {}
local ydRowPoints = {}
local ydAssigned = {}
local ydTime = 0

-- YouDecoy を workspace から検索
local function ydFindDecoys()
    local toys = {}
    for _, item in ipairs(workspace:GetDescendants()) do
        if item:IsA("Model") and item.Name == ydConfig.targetPartName then
            local dup = false
            for _, e in ipairs(toys) do if e == item then dup = true break end end
            if not dup then table.insert(toys, item) end
        end
    end
    table.sort(toys, function(a, b) return a.Name < b.Name end)
    return toys
end

-- ダミー制御用パーツ生成
local function ydCP()
    local p = Instance.new("Part")
    p.CanCollide = false; p.Anchored = true; p.Transparency = 1
    p.Size = Vector3.new(4, 1, 4); p.Parent = workspace
    return p
end

-- BodyMover セットアップ
local function ydCBM(part)
    if not part then return nil, nil end
    local eBG = part:FindFirstChildOfClass("BodyGyro")
    local eBP = part:FindFirstChildOfClass("BodyPosition")
    if eBG and eBP then return eBG, eBP end
    if eBG then eBG:Destroy() end
    if eBP then eBP:Destroy() end
    local BP = Instance.new("BodyPosition")
    BP.P = 25000; BP.D = 800
    BP.MaxForce = Vector3.new(1, 1, 1) * 1e10; BP.Parent = part
    local BG = Instance.new("BodyGyro")
    BG.P = 25000; BG.D = 800
    BG.MaxTorque = Vector3.new(1, 1, 1) * 1e10; BG.Parent = part
    return BG, BP
end

-- モデルからプライマリパーツを取得
local function ydGetPrimary(model)
    if model.PrimaryPart then return model.PrimaryPart end
    for _, n in ipairs({"Handle", "Main", "Part", "Base", "Decoy", "Body"}) do
        local p = model:FindFirstChild(n)
        if p and p:IsA("BasePart") then return p end
    end
    for _, c in ipairs(model:GetChildren()) do
        if c:IsA("BasePart") then return c end
    end
    return nil
end

-- 行配置ポイントを生成（左右対称）
local function ydCreateRowPoints(count)
    local points = {}
    if count == 0 then return points end
    local half = math.floor(count / 2)
    local isOdd = count % 2 == 1
    local idx = 1
    if isOdd then
        table.insert(points, { baseOffsetX = 0, part = ydCP(), index = idx }); idx += 1
    end
    for i = 1, half do
        local off = i * ydConfig.spacing
        table.insert(points, { baseOffsetX = off,  part = ydCP(), index = idx }); idx += 1
        table.insert(points, { baseOffsetX = -off, part = ydCP(), index = idx }); idx += 1
    end
    return points
end

-- 無効化（固定）
local function ydDisable()
    for _, point in ipairs(ydRowPoints) do
        if point.assignedToy and point.assignedToy.Pallet then
            if point.assignedToy.BP then point.assignedToy.BP:Destroy(); point.assignedToy.BP = nil end
            if point.assignedToy.BG then point.assignedToy.BG:Destroy(); point.assignedToy.BG = nil end
            for _, c in ipairs(point.assignedToy.Model:GetChildren()) do
                if c:IsA("BasePart") then
                    c.Anchored = true
                    c.Velocity = Vector3.new(0, 0, 0)
                    c.RotVelocity = Vector3.new(0, 0, 0)
                end
            end
        end
    end
end

-- 有効化（BodyMover再生成）
local function ydEnable()
    for _, point in ipairs(ydRowPoints) do
        if point.assignedToy and point.assignedToy.Pallet then
            for _, c in ipairs(point.assignedToy.Model:GetChildren()) do
                if c:IsA("BasePart") then c.Anchored = false end
            end
            local BG, BP = ydCBM(point.assignedToy.Pallet)
            point.assignedToy.BG = BG; point.assignedToy.BP = BP
        end
    end
end

-- ポイントにYouDecoyを割り当て
local function ydAssignToPoints()
    local assigned = {}
    local character = _getTargetChar(ydConfig.targetPlayer)
    if not character then return assigned end
    local hrp = character:FindFirstChild("HumanoidRootPart")
    local torso = character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso")
    if not hrp or not torso then return assigned end
    local charCF = hrp.CFrame
    local basePos = torso.Position + Vector3.new(0, ydConfig.heightOffset, 0) + charCF.LookVector * ydConfig.forwardOffset
    for i = 1, math.min(#ydToys, #ydRowPoints) do
        local toy = ydToys[i]
        if toy and toy:IsA("Model") and toy.Name == ydConfig.targetPartName then
            local primary = ydGetPrimary(toy)
            if primary then
                for _, c in ipairs(toy:GetChildren()) do
                    if c:IsA("BasePart") then c.CanCollide = false; c.CanTouch = false; c.Anchored = false end
                end
                local BG, BP = ydCBM(primary)
                local initPos = basePos + charCF.RightVector * ydRowPoints[i].baseOffsetX
                local t = {
                    BG = BG, BP = BP, Pallet = primary, Model = toy,
                    offsetX = ydRowPoints[i].baseOffsetX,
                    baseOffsetX = ydRowPoints[i].baseOffsetX,
                    index = ydRowPoints[i].index,
                }
                if BP then BP.Position = initPos end
                if BG then
                    local cf = CFrame.new(initPos)
                    local _, pYR, _ = charCF:ToOrientation()
                    cf = cf * CFrame.Angles(0, pYR + math.rad(ydConfig.yRotation), 0)
                    cf = cf * CFrame.Angles(math.rad(ydConfig.xRotation), 0, 0)
                    cf = cf * CFrame.Angles(0, 0, math.rad(ydConfig.zRotation))
                    BG.CFrame = cf
                end
                ydRowPoints[i].assignedToy = t
                table.insert(assigned, t)
            end
        end
    end
    return assigned
end

-- 再検出 & 再割り当て
local function ydRefresh()
    ydToys = ydFindDecoys()
    ydRowPoints = ydCreateRowPoints(math.min(#ydToys, ydConfig.maxDecoys))
    ydAssigned = ydAssignToPoints()
end

-- 初期化
ydRefresh()
workspace.DescendantAdded:Connect(function(d)
    if d:IsA("Model") and d.Name == ydConfig.targetPartName then
        task.wait(0.5); ydRefresh()
    end
end)

-- メインループ（RenderStepped で毎フレーム更新）
RunService.RenderStepped:Connect(function(dt)
    if not ydConfig.enabled then return end
    local character = _getTargetChar(ydConfig.targetPlayer)
    if not character then return end
    local torso = character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso")
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not torso or not hrp then return end
    ydTime += dt * ydConfig.waveSpeed
    local charCF = hrp.CFrame
    local basePos = torso.Position + Vector3.new(0, ydConfig.heightOffset, 0) + charCF.LookVector * ydConfig.forwardOffset
    for _, point in ipairs(ydRowPoints) do
        if point.assignedToy and point.assignedToy.BP and point.assignedToy.BG then
            local toy = point.assignedToy
            local dist = math.abs(toy.baseOffsetX)
            local amp = ydConfig.baseAmplitude + dist * ydConfig.distanceMultiplier
            local wave = math.sin(ydTime + toy.index * ydConfig.phaseOffset)
            local hOff = toy.baseOffsetX
            if toy.baseOffsetX ~= 0 then
                local sign = toy.baseOffsetX > 0 and 1 or -1
                hOff = toy.baseOffsetX - sign * math.abs(toy.baseOffsetX) * wave * ydConfig.horizontalWaveAmount
            end
            local finalPos = basePos + charCF.RightVector * hOff + Vector3.new(0, wave * amp, 0)
            if point.part then point.part.Position = finalPos end
            toy.BP.Position = finalPos
            local cf = CFrame.new(finalPos)
            local _, pYR, _ = charCF:ToOrientation()
            cf = cf * CFrame.Angles(0, pYR + math.rad(ydConfig.yRotation), 0)
            cf = cf * CFrame.Angles(math.rad(ydConfig.xRotation), 0, 0)
            cf = cf * CFrame.Angles(0, 0, math.rad(ydConfig.zRotation))
            toy.BG.CFrame = toy.BG.CFrame:Lerp(cf, ydConfig.smoothness)
        end
    end
end)

--==================================================
-- ORION UI: Wings & Orbit タブに追加するセクション
-- ※ WingsTab が定義された後、OrionLib:Init() の前に挿入
-- ※ SpotlightBlue セクションの後ろに続けて挿入する
--==================================================

-- ============================================
-- セクション5: YouDecoy
-- ============================================
WingsTab:AddSection({ Name = "🪤 YouDecoy" })

WingsTab:AddToggle({
    Name = "YD: 有効化",
    Default = false,
    Flag = "YDEnabled",
    Callback = function(v)
        ydConfig.enabled = v
        if v then ydEnable(); OrionLib:MakeNotification({ Name = "YD ON", Content = "YouDecoy 起動", Time = 2 })
        else ydDisable(); OrionLib:MakeNotification({ Name = "YD OFF", Content = "YouDecoy 固定", Time = 2 }) end
    end,
})

local ydPlayerDropdown
ydPlayerDropdown = WingsTab:AddDropdown({
    Name = "YD: 対象プレイヤー",
    Default = "自分",
    Options = fwGetPlayerList(),
    Callback = function(v)
        if v == "自分" then ydConfig.targetPlayer = nil
        else ydConfig.targetPlayer = Players:FindFirstChild(v) end
        ydAssigned = ydAssignToPoints()
    end,
})

WingsTab:AddButton({
    Name = "YD: プレイヤーリスト更新",
    Callback = function()
        ydPlayerDropdown:Refresh(fwGetPlayerList(), true)
        OrionLib:MakeNotification({ Name = "更新", Content = "リスト更新完了", Time = 2 })
    end,
})

WingsTab:AddButton({
    Name = "YD: YouDecoyを再検出",
    Callback = function()
        ydRefresh()
        OrionLib:MakeNotification({ Name = "再検出", Content = "YouDecoy数: " .. #ydToys, Time = 2 })
    end,
})

WingsTab:AddSlider({ Name = "YD: 最大数", Min = 2, Max = 40, Default = 20, Increment = 1, ValueName = "体",
    Callback = function(v) ydConfig.maxDecoys = v; ydRefresh() end })
WingsTab:AddSlider({ Name = "YD: 間隔", Min = 0.5, Max = 5, Default = 1.2, Increment = 0.1, ValueName = "",
    Callback = function(v) ydConfig.spacing = v; ydRefresh() end })
WingsTab:AddSlider({ Name = "YD: 高さ", Min = -5, Max = 10, Default = 1, Increment = 0.5, ValueName = "",
    Callback = function(v) ydConfig.heightOffset = v end })
WingsTab:AddSlider({ Name = "YD: 前方オフセット", Min = 0, Max = 15, Default = 4, Increment = 0.5, ValueName = "",
    Callback = function(v) ydConfig.forwardOffset = v end })
WingsTab:AddSlider({ Name = "YD: 波速度", Min = 0, Max = 10, Default = 2.5, Increment = 0.1, ValueName = "",
    Callback = function(v) ydConfig.waveSpeed = v end })
WingsTab:AddSlider({ Name = "YD: 振幅", Min = 0, Max = 10, Default = 2, Increment = 0.1, ValueName = "",
    Callback = function(v) ydConfig.baseAmplitude = v end })
WingsTab:AddSlider({ Name = "YD: 位相差", Min = 0, Max = 2, Default = 0.3, Increment = 0.05, ValueName = "",
    Callback = function(v) ydConfig.phaseOffset = v end })
WingsTab:AddSlider({ Name = "YD: 内側への寄り", Min = 0, Max = 2, Default = 0.5, Increment = 0.05, ValueName = "",
    Callback = function(v) ydConfig.horizontalWaveAmount = v end })
WingsTab:AddSlider({ Name = "YD: 滑らかさ", Min = 0.01, Max = 1, Default = 0.6, Increment = 0.01, ValueName = "",
    Callback = function(v) ydConfig.smoothness = v end })
WingsTab:AddSlider({ Name = "YD: X軸回転", Min = -180, Max = 180, Default = -45, Increment = 1, ValueName = "°",
    Callback = function(v) ydConfig.xRotation = v end })
WingsTab:AddSlider({ Name = "YD: Y軸回転", Min = -180, Max = 180, Default = 0, Increment = 1, ValueName = "°",
    Callback = function(v) ydConfig.yRotation = v end })
WingsTab:AddSlider({ Name = "YD: Z軸回転", Min = -180, Max = 180, Default = 90, Increment = 1, ValueName = "°",
    Callback = function(v) ydConfig.zRotation = v end })
WingsTab:AddButton({ Name = "YD: 回転リセット", Callback = function()
    ydConfig.xRotation = -45; ydConfig.yRotation = 0; ydConfig.zRotation = 90
    OrionLib:MakeNotification({ Name = "リセット", Content = "回転をデフォルトに戻しました", Time = 2 })
end })

--==================================================
-- ↑ ここまでを Wings & Orbit タブの
--   SpotlightBlue セクションの後ろ（または
--   「Ball: 再検索 & 再起動」ボタンの後ろ）、
--   OrionLib:Init() の前に挿入する
--==================================================

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

--==============================
-- タブ：Formation Hub (GlassBoxGray拡張)
-- 既存コードのOrionLib:Init()の前に挿入
-- 既存タブは一切変更しない・新規タブのみ
--==============================

--==================================================
-- 共通ユーティリティ（fmプレフィックスで独立）
--==================================================
local fm_RunService  = game:GetService("RunService")
local fm_Players     = game:GetService("Players")
local fm_LocalPlayer = fm_Players.LocalPlayer

local function fm_findByName(name)
    local found = {}
    for _, item in ipairs(workspace:GetDescendants()) do
        if (item:IsA("BasePart") or item:IsA("Model")) and item.Name == name then
            table.insert(found, item)
        end
    end
    return found
end

local function fm_getBase(obj)
    if obj:IsA("Model") then
        return obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
    elseif obj:IsA("BasePart") then
        return obj
    end
    return nil
end

local function fm_setupMovers(part)
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

local function fm_setupObj(obj)
    local base = fm_getBase(obj)
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
    local BP, BG = fm_setupMovers(base)
    return { BP = BP, BG = BG, Part = base, Original = obj }
end

local function fm_release(obj)
    if obj.BP and obj.BP.Parent then obj.BP:Destroy() end
    if obj.BG and obj.BG.Parent then obj.BG:Destroy() end
    if obj.Part and obj.Part.Parent then obj.Part.Anchored = true end
end

--==================================================
-- 設定テーブル
--==================================================
local fmConfig = {
    enabled     = false,
    partName    = "GlassBoxGray",
    mode        = "Robot",
    count       = 20,
    useAllFound = false,
    speed       = 1.0,
    smoothness  = 0.12,

    -----------------------------------------------
    -- Robot（完全人体型）
    -- アイデア：頭・首・胸・腹・腰・肩L/R・上腕L/R・前腕L/R・
    --           手L/R・太ももL/R・すねL/R・足L/R の18部位に対応
    -----------------------------------------------
    robotScale      = 1.2,  -- 全体スケール（自分の体より一回り大きく）
    robotBobAmp     = 0.15, -- 呼吸のような上下揺れ幅
    robotBobSpeed   = 1.0,  -- 揺れ速度
    robotArmSwing   = 25,   -- 腕の振り角度（度）
    robotLegSwing   = 20,   -- 脚の振り角度（度）

    -----------------------------------------------
    -- Sphere（球状に囲まれる）
    -----------------------------------------------
    sphereRadius    = 5,
    sphereRotSpeed  = 1.2,  -- 球全体の回転速度
    sphereLayers    = 3,    -- 球の層数
    sphereAltSpin   = true, -- 層ごとに逆回転

    -----------------------------------------------
    -- Monster（化け物型：巨大な爪・牙・背びれ・尾）
    -----------------------------------------------
    monsterScale    = 1.5,
    monsterClawFlare= 30,   -- 爪の広がり角度
    monsterSpineAmp = 0.8,  -- 背びれの波打ち振幅
    monsterTailLen  = 6,    -- 尾のパーツ数（総数から割り当て）

    -----------------------------------------------
    -- Giant（巨人体型：自分がその胴体の中に入る）
    -- 自分のHRPを中心として、そこに大きな体が構成される
    -----------------------------------------------
    giantScale      = 2.5,  -- 巨人のスケール（自分の2.5倍）
    giantBobAmp     = 0.2,
    giantBobSpeed   = 0.8,
    giantArmSwing   = 30,
    giantLegSwing   = 25,
}

local fmObjs   = {}
local fmTime   = 0
local fmConn   = nil

--==================================================
-- 位置計算：Robot（完全18部位人体型）
-- キャラの向きに完全追従・歩行アニメ付き
--==================================================
local function fm_robotPos(i, total, t, cPos, cCF, scale, bobAmp, bobSpeed, armSwing, legSwing)
    local s = scale
    local bob = math.sin(t * bobSpeed) * bobAmp

    -- Y回転（キャラ向き）
    local _, cYR, _ = cCF:ToOrientation()
    local cosY = math.cos(cYR)
    local sinY = math.sin(cYR)
    local function rotXZ(x, z)
        return x * cosY - z * sinY, x * sinY + z * cosY
    end

    -- 歩行サイクル
    local walkCycle = math.sin(t * 3)
    local armR  =  math.rad(armSwing) * walkCycle   -- 右腕は前
    local armL  = -math.rad(armSwing) * walkCycle   -- 左腕は後ろ
    local legR  = -math.rad(legSwing) * walkCycle   -- 右脚は後ろ
    local legL  =  math.rad(legSwing) * walkCycle   -- 左脚は前

    -- 18部位の定義（x=左右、y=高さ、z=前後）
    -- キャラ中心をHRPとして相対的に配置
    -- HRPは腰あたりなので、頭は+3程度
    local parts = {
        -- 頭部・首
        { 0,      3.2*s+bob,  0    },  -- 1: 頭
        { 0,      2.5*s+bob,  0    },  -- 2: 首

        -- 胴体
        { 0,      1.8*s+bob,  0    },  -- 3: 胸（上）
        { 0,      1.2*s+bob,  0    },  -- 4: 胸（下）
        { 0,      0.6*s+bob,  0    },  -- 5: 腹
        { 0,      0.0*s+bob,  0    },  -- 6: 腰

        -- 肩
        { -1.0*s, 1.9*s+bob,  0    },  -- 7: 左肩
        {  1.0*s, 1.9*s+bob,  0    },  -- 8: 右肩

        -- 腕（振り：肩を支点にZ方向へ回転）
        { -1.3*s, 1.2*s+bob + math.sin(armL)*0.8*s, math.cos(armL)*0.4*s - 0.4*s }, -- 9: 左上腕
        {  1.3*s, 1.2*s+bob + math.sin(armR)*0.8*s, math.cos(armR)*0.4*s - 0.4*s }, -- 10: 右上腕
        { -1.4*s, 0.4*s+bob + math.sin(armL)*1.4*s, math.cos(armL)*0.7*s - 0.7*s }, -- 11: 左前腕
        {  1.4*s, 0.4*s+bob + math.sin(armR)*1.4*s, math.cos(armR)*0.7*s - 0.7*s }, -- 12: 右前腕
        { -1.4*s,-0.3*s+bob + math.sin(armL)*1.8*s, math.cos(armL)*1.0*s - 1.0*s }, -- 13: 左手
        {  1.4*s,-0.3*s+bob + math.sin(armR)*1.8*s, math.cos(armR)*1.0*s - 1.0*s }, -- 14: 右手

        -- 脚（振り：腰を支点にZ方向へ回転）
        { -0.5*s,-0.6*s + math.sin(legL)*0.6*s, math.cos(legL)*0.5*s - 0.5*s }, -- 15: 左太もも
        {  0.5*s,-0.6*s + math.sin(legR)*0.6*s, math.cos(legR)*0.5*s - 0.5*s }, -- 16: 右太もも
        { -0.55*s,-1.5*s + math.sin(legL)*1.2*s, math.cos(legL)*1.0*s - 1.0*s}, -- 17: 左すね
        {  0.55*s,-1.5*s + math.sin(legR)*1.2*s, math.cos(legR)*1.0*s - 1.0*s}, -- 18: 右すね
    }

    -- 19個以上は頭上にアクセサリとして浮かせる
    if i > #parts then
        local extra = i - #parts
        local a = (extra-1) / math.max(1, total-#parts) * math.pi * 2 + t * fmConfig.speed
        local rx_e, rz_e = rotXZ(math.cos(a)*0.6*s, math.sin(a)*0.6*s)
        return cPos + Vector3.new(rx_e, 4.0*s + extra*0.3*s + bob, rz_e)
    end

    local p  = parts[i]
    local rx, rz = rotXZ(p[1], p[3])
    return cPos + Vector3.new(rx, p[2], rz)
end

-- Robot用向き計算（部位ごとに向きを変える）
local function fm_robotCF(i, pos, cCF, t, scale, armSwing, legSwing)
    local walkCycle = math.sin(t * 3)
    local _, cYR, _ = cCF:ToOrientation()
    local base = CFrame.new(pos) * CFrame.Angles(0, cYR, 0)

    -- 腕（9-14）は振り角度を加える
    local armL_r = -math.rad(armSwing) * walkCycle
    local armR_r =  math.rad(armSwing) * walkCycle
    local legL_r =  math.rad(legSwing) * walkCycle
    local legR_r = -math.rad(legSwing) * walkCycle

    if i == 9  or i == 11 or i == 13 then -- 左腕系
        return base * CFrame.Angles(armL_r, 0, 0)
    elseif i == 10 or i == 12 or i == 14 then -- 右腕系
        return base * CFrame.Angles(armR_r, 0, 0)
    elseif i == 15 or i == 17 then -- 左脚系
        return base * CFrame.Angles(legL_r, 0, 0)
    elseif i == 16 or i == 18 then -- 右脚系
        return base * CFrame.Angles(legR_r, 0, 0)
    end

    return base
end

--==================================================
-- 位置計算：Sphere（球状に全周を囲む）
-- フィボナッチ球面分布で均等に配置し全体回転
--==================================================
local function fm_spherePos(i, total, t, cPos, cCF)
    local r   = fmConfig.sphereRadius
    local phi = math.acos(1 - 2*i/total)  -- フィボナッチ球面
    local theta = math.pi * (1 + math.sqrt(5)) * i  -- 黄金角

    -- 球面上の基本座標
    local x = r * math.sin(phi) * math.cos(theta)
    local y = r * math.cos(phi)
    local z = r * math.sin(phi) * math.sin(theta)

    -- 層を判定して逆回転をつける
    local layer = math.floor(i / (total / fmConfig.sphereLayers))
    local spinDir = (fmConfig.sphereAltSpin and layer % 2 == 0) and 1 or -1
    local spin = t * fmConfig.sphereRotSpeed * spinDir

    -- Y軸周りに時間回転
    local rx = x * math.cos(spin) - z * math.sin(spin)
    local rz = x * math.sin(spin) + z * math.cos(spin)

    -- キャラの向きに追従
    local _, cYR, _ = cCF:ToOrientation()
    local fx = rx * math.cos(cYR) - rz * math.sin(cYR)
    local fz = rx * math.sin(cYR) + rz * math.cos(cYR)

    return cPos + Vector3.new(fx, y, fz)
end

--==================================================
-- 位置計算：Monster（化け物型）
-- 爪×4、牙×2、背びれ×N、尾×N、角×2 で構成
--==================================================
local function fm_monsterPos(i, total, t, cPos, cCF)
    local s   = fmConfig.monsterScale
    local _, cYR, _ = cCF:ToOrientation()
    local cosY = math.cos(cYR)
    local sinY = math.sin(cYR)
    local function rotXZ(x, z)
        return x * cosY - z * sinY, x * sinY + z * cosY
    end

    -- 総数に応じて部位を割り振る
    -- 前爪 4個、牙 2個、角 2個、背びれ (total//3)個、尾 残り
    local clawCount  = 4
    local fangCount  = 2
    local hornCount  = 2
    local spineCount = math.floor((total - clawCount - fangCount - hornCount) * 0.4)
    local tailCount  = total - clawCount - fangCount - hornCount - spineCount

    local function clampedSpine(k, count)
        return count > 0 and k or 1
    end

    local x, y, z = 0, 0, 0

    -- 前爪（1-4）：前方左右に大きく広がる
    if i <= clawCount then
        local side  = (i <= 2) and -1 or 1
        local upIdx = (i % 2 == 1) and 0 or 1
        local flare = math.rad(fmConfig.monsterClawFlare)
        local clawT = t * fmConfig.speed
        -- ハサミのように開閉
        local openAng = math.sin(clawT) * 0.3 + flare
        local baseX   = side * (1.8 + upIdx * 0.6) * s
        local baseZ   = -(0.5 + upIdx * 0.5) * s
        x = baseX + side * math.cos(openAng) * 1.2 * s
        y = (0.5 - upIdx * 0.8) * s + math.sin(clawT + i) * 0.2 * s
        z = baseZ + math.sin(openAng) * (-0.8) * s

    -- 牙（5-6）：口元の下側に鋭く伸びる
    elseif i <= clawCount + fangCount then
        local fIdx = i - clawCount
        local side = fIdx == 1 and -0.4 or 0.4
        y = 2.5 * s + math.sin(t * fmConfig.speed * 0.5) * 0.1 * s
        x = side * s
        z = -1.0 * s + math.sin(t * fmConfig.speed) * 0.05 * s

    -- 角（7-8）：頭頂から斜め上に伸びる
    elseif i <= clawCount + fangCount + hornCount then
        local hIdx = i - clawCount - fangCount
        local side  = hIdx == 1 and -0.5 or 0.5
        y = 3.8 * s + (hIdx - 1) * 0.6 * s
        x = side * (0.4 + (hIdx-1) * 0.2) * s
        z = -0.2 * s

    -- 背びれ（spine）：背中に波打ちながら並ぶ
    elseif i <= clawCount + fangCount + hornCount + spineCount then
        local sIdx = i - clawCount - fangCount - hornCount
        local prog  = (sIdx - 1) / math.max(spineCount - 1, 1)
        -- 背中の中央ラインに沿って並ぶ（前→後）
        z = (-1.0 + prog * 2.0) * s
        y = (2.5 - prog * 1.5) * s + math.sin(t * fmConfig.speed * 2 + prog * math.pi * 3) * fmConfig.monsterSpineAmp * s
        x = math.sin(t * fmConfig.speed + prog * 1.5) * 0.15 * s  -- わずかに左右に揺れる

    -- 尾（残り）：後方から弧を描いて伸びる
    else
        local tIdx  = i - clawCount - fangCount - hornCount - spineCount
        local prog  = tIdx / math.max(tailCount, 1)
        -- 尾は後方＋下方向に蛇行
        z = (0.8 + prog * fmConfig.monsterTailLen * 0.5) * s
        y = (-0.2 - prog * 1.5) * s + math.sin(t * fmConfig.speed * 1.5 + prog * math.pi * 4) * (0.5 + prog) * s
        x = math.sin(t * fmConfig.speed * 0.8 + prog * math.pi * 2) * (0.3 + prog * 0.4) * s
    end

    local rx, rz = rotXZ(x, z)
    return cPos + Vector3.new(rx, y, rz)
end

--==================================================
-- 位置計算：Giant（巨人体型）
-- 自分がその胴体の「中」に入る巨大な人型
-- giantScaleで全体を大きくし、自分（HRP）は胴体中央に位置
-- → 胴体パーツは自分を囲むように配置
--==================================================
local function fm_giantPos(i, total, t, cPos, cCF, head)
    local s = fmConfig.giantScale
    local bob = math.sin(t * fmConfig.giantBobSpeed) * fmConfig.giantBobAmp

    local _, cYR, _ = cCF:ToOrientation()
    local cosY = math.cos(cYR)
    local sinY = math.sin(cYR)
    local function rotXZ(x, z)
        return x * cosY - z * sinY, x * sinY + z * cosY
    end

    local walkCycle = math.sin(t * 2)
    local armR =  math.rad(fmConfig.giantArmSwing) * walkCycle
    local armL = -math.rad(fmConfig.giantArmSwing) * walkCycle
    local legR = -math.rad(fmConfig.giantLegSwing) * walkCycle
    local legL =  math.rad(fmConfig.giantLegSwing) * walkCycle

    -- 自分のHRPが巨人の「腰」にあたる位置
    -- 巨人の胴体中央 = HRP位置
    -- 頭は 4*s 上、脚は 3*s 下
    local parts = {
        -- 頭・首
        { 0,      4.5*s+bob,   0   },  -- 1: 頭
        { 0,      3.5*s+bob,   0   },  -- 2: 首

        -- 胴体（自分を囲む＝x方向に厚み、正面と背面に2枚）
        { 0,      2.5*s+bob,   0.9*s },  -- 3: 胸前
        { 0,      2.5*s+bob,  -0.9*s },  -- 4: 背中
        { 1.5*s,  2.0*s+bob,   0   },  -- 5: 右脇
        {-1.5*s,  2.0*s+bob,   0   },  -- 6: 左脇
        { 0,      1.5*s+bob,   0.9*s },  -- 7: 腹前
        { 0,      1.5*s+bob,  -0.9*s },  -- 8: 腹後
        { 0,      0.6*s+bob,   0.9*s },  -- 9: 腰前
        { 0,      0.6*s+bob,  -0.9*s },  -- 10: 腰後

        -- 肩
        {-2.2*s,  3.0*s+bob,   0   },  -- 11: 左肩
        { 2.2*s,  3.0*s+bob,   0   },  -- 12: 右肩

        -- 腕
        {-2.5*s, 2.2*s+bob + math.sin(armL)*0.9*s, math.cos(armL)*0.5*s-0.5*s }, -- 13: 左上腕
        { 2.5*s, 2.2*s+bob + math.sin(armR)*0.9*s, math.cos(armR)*0.5*s-0.5*s }, -- 14: 右上腕
        {-2.7*s, 1.2*s+bob + math.sin(armL)*1.8*s, math.cos(armL)*1.0*s-1.0*s }, -- 15: 左前腕
        { 2.7*s, 1.2*s+bob + math.sin(armR)*1.8*s, math.cos(armR)*1.0*s-1.0*s }, -- 16: 右前腕
        {-2.7*s, 0.2*s+bob + math.sin(armL)*2.5*s, math.cos(armL)*1.4*s-1.4*s }, -- 17: 左手
        { 2.7*s, 0.2*s+bob + math.sin(armR)*2.5*s, math.cos(armR)*1.4*s-1.4*s }, -- 18: 右手

        -- 脚（膝まで）
        {-0.9*s,-0.5*s + math.sin(legL)*0.8*s, math.cos(legL)*0.6*s-0.6*s }, -- 19: 左太もも
        { 0.9*s,-0.5*s + math.sin(legR)*0.8*s, math.cos(legR)*0.6*s-0.6*s }, -- 20: 右太もも
        {-1.0*s,-2.0*s + math.sin(legL)*1.5*s, math.cos(legL)*1.2*s-1.2*s }, -- 21: 左すね
        { 1.0*s,-2.0*s + math.sin(legR)*1.5*s, math.cos(legR)*1.2*s-1.2*s }, -- 22: 右すね
        {-1.0*s,-3.2*s + math.sin(legL)*1.8*s, math.cos(legL)*1.5*s-1.5*s }, -- 23: 左足
        { 1.0*s,-3.2*s + math.sin(legR)*1.8*s, math.cos(legR)*1.5*s-1.5*s }, -- 24: 右足
    }

    if i > #parts then
        -- 余りは頭上にアクセサリ
        local extra = i - #parts
        local a = (extra-1) / math.max(1, total-#parts) * math.pi * 2 + t * fmConfig.speed
        local rx_e, rz_e = rotXZ(math.cos(a)*0.8*s, math.sin(a)*0.8*s)
        return cPos + Vector3.new(rx_e, 5.5*s + extra*0.4*s + bob, rz_e)
    end

    local p = parts[i]
    local rx, rz = rotXZ(p[1], p[3])
    return cPos + Vector3.new(rx, p[2], rz)
end

-- Giant用向きCF
local function fm_giantCF(i, pos, cCF, t)
    local _, cYR, _ = cCF:ToOrientation()
    local base = CFrame.new(pos) * CFrame.Angles(0, cYR, 0)
    local walkCycle = math.sin(t * 2)
    local armL_r = -math.rad(fmConfig.giantArmSwing) * walkCycle
    local armR_r =  math.rad(fmConfig.giantArmSwing) * walkCycle
    local legL_r =  math.rad(fmConfig.giantLegSwing) * walkCycle
    local legR_r = -math.rad(fmConfig.giantLegSwing) * walkCycle
    if i == 13 or i == 15 or i == 17 then return base * CFrame.Angles(armL_r, 0, 0)
    elseif i == 14 or i == 16 or i == 18 then return base * CFrame.Angles(armR_r, 0, 0)
    elseif i == 19 or i == 21 or i == 23 then return base * CFrame.Angles(legL_r, 0, 0)
    elseif i == 20 or i == 22 or i == 24 then return base * CFrame.Angles(legR_r, 0, 0)
    end
    return base
end

--==================================================
-- 起動/停止
--==================================================
local function fm_stop()
    if fmConn then fmConn:Disconnect(); fmConn = nil end
    for _, obj in ipairs(fmObjs) do fm_release(obj) end
    fmObjs = {}
end

local function fm_start()
    fm_stop()
    local found = fm_findByName(fmConfig.partName)
    if #found == 0 then
        OrionLib:MakeNotification({ Name = "エラー", Content = "'" .. fmConfig.partName .. "' が見つかりません", Time = 3 })
        return
    end
    local useCount = fmConfig.useAllFound and #found or math.min(fmConfig.count, #found)
    for i = 1, useCount do
        local obj = fm_setupObj(found[i])
        if obj then table.insert(fmObjs, obj) end
    end
    OrionLib:MakeNotification({
        Name = "Formation 起動",
        Content = "モード: " .. fmConfig.mode .. " / 数: " .. #fmObjs,
        Time = 2,
    })
    fmTime = 0

    fmConn = fm_RunService.RenderStepped:Connect(function(dt)
        if not fmConfig.enabled then return end
        local char = fm_LocalPlayer.Character
        if not char then return end
        local hrp  = char:FindFirstChild("HumanoidRootPart")
        local head = char:FindFirstChild("Head")
        if not hrp then return end

        fmTime += dt
        local cPos  = hrp.Position
        local cCF   = hrp.CFrame
        local total = #fmObjs
        local sm    = fmConfig.smoothness
        local mode  = fmConfig.mode

        -- ===== Robot =====
        if mode == "Robot" then
            for i, obj in ipairs(fmObjs) do
                if obj.BP and obj.BP.Parent then
                    local pos = fm_robotPos(i, total, fmTime, cPos, cCF,
                        fmConfig.robotScale, fmConfig.robotBobAmp, fmConfig.robotBobSpeed,
                        fmConfig.robotArmSwing, fmConfig.robotLegSwing)
                    obj.BP.Position = obj.BP.Position + (pos - obj.BP.Position) * sm
                    if obj.BG and obj.BG.Parent then
                        local cf = fm_robotCF(i, pos, cCF, fmTime,
                            fmConfig.robotScale, fmConfig.robotArmSwing, fmConfig.robotLegSwing)
                        obj.BG.CFrame = obj.BG.CFrame:Lerp(cf, sm)
                    end
                end
            end

        -- ===== Sphere =====
        elseif mode == "Sphere" then
            for i, obj in ipairs(fmObjs) do
                if obj.BP and obj.BP.Parent then
                    local pos = fm_spherePos(i, total, fmTime, cPos, cCF)
                    obj.BP.Position = obj.BP.Position + (pos - obj.BP.Position) * sm
                    if obj.BG and obj.BG.Parent then
                        -- 球体は常に中心を向く
                        local lookCF = CFrame.lookAt(pos, cPos)
                        obj.BG.CFrame = obj.BG.CFrame:Lerp(lookCF, 0.15)
                    end
                end
            end

        -- ===== Monster =====
        elseif mode == "Monster" then
            for i, obj in ipairs(fmObjs) do
                if obj.BP and obj.BP.Parent then
                    local pos = fm_monsterPos(i, total, fmTime, cPos, cCF)
                    obj.BP.Position = obj.BP.Position + (pos - obj.BP.Position) * sm
                    if obj.BG and obj.BG.Parent then
                        local _, cYR, _ = cCF:ToOrientation()
                        local cf = CFrame.new(pos) * CFrame.Angles(0, cYR, 0)
                        obj.BG.CFrame = obj.BG.CFrame:Lerp(cf, sm)
                    end
                end
            end

        -- ===== Giant =====
        elseif mode == "Giant" then
            for i, obj in ipairs(fmObjs) do
                if obj.BP and obj.BP.Parent then
                    local pos = fm_giantPos(i, total, fmTime, cPos, cCF, head)
                    obj.BP.Position = obj.BP.Position + (pos - obj.BP.Position) * sm
                    if obj.BG and obj.BG.Parent then
                        local cf = fm_giantCF(i, pos, cCF, fmTime)
                        obj.BG.CFrame = obj.BG.CFrame:Lerp(cf, sm)
                    end
                end
            end
        end
    end)
end

--==================================================
-- ORION UI タブ
--==================================================
local FmTab = Window:MakeTab({
    Name = "Formation",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false,
})

-- ============================================
-- 制御セクション
-- ============================================
FmTab:AddSection({ Name = "⚙️ Formation 制御" })

FmTab:AddToggle({
    Name = "有効化",
    Default = false,
    Flag = "FmEnabled",
    Callback = function(v)
        fmConfig.enabled = v
        if v then fm_start()
        else fm_stop(); OrionLib:MakeNotification({ Name = "停止", Content = "停止しました", Time = 2 }) end
    end,
})

FmTab:AddTextbox({
    Name = "対象Part名",
    Default = "GlassBoxGray",
    TextDisappear = false,
    Callback = function(v) fmConfig.partName = v end,
})

FmTab:AddDropdown({
    Name = "モード",
    Default = "Robot",
    Options = { "Robot", "Sphere", "Monster", "Giant" },
    Callback = function(v)
        fmConfig.mode = v
        if fmConfig.enabled then fm_start() end
    end,
})

FmTab:AddToggle({ Name = "全Part使用", Default = false, Flag = "FmUseAll",
    Callback = function(v) fmConfig.useAllFound = v end })

FmTab:AddSlider({ Name = "使用数", Min = 1, Max = 60, Default = 20, Increment = 1, ValueName = "個",
    Callback = function(v) fmConfig.count = v end })

FmTab:AddSlider({ Name = "速度 (アニメ)", Min = 0, Max = 5, Default = 1.0, Increment = 0.1, ValueName = "",
    Callback = function(v) fmConfig.speed = v end })

FmTab:AddSlider({ Name = "滑らかさ", Min = 0.01, Max = 1, Default = 0.12, Increment = 0.01, ValueName = "",
    Callback = function(v) fmConfig.smoothness = v end })

FmTab:AddButton({
    Name = "再検索 & 再起動",
    Callback = function()
        if fmConfig.enabled then fm_start()
        else
            local f = fm_findByName(fmConfig.partName)
            OrionLib:MakeNotification({ Name = "検索", Content = #f .. "個発見", Time = 3 })
        end
    end,
})

-- ============================================
-- 🤖 Robot 設定
-- ============================================
FmTab:AddSection({ Name = "🤖 Robot 設定（完全人体型・18部位）" })
FmTab:AddLabel("頭・首・胸×2・腹・腰・肩×2・上腕×2")
FmTab:AddLabel("前腕×2・手×2・太もも×2・すね×2")
FmTab:AddLabel("19個以上は頭上にアクセサリとして追加")

FmTab:AddSlider({ Name = "Robot: スケール", Min = 0.3, Max = 4, Default = 1.2, Increment = 0.1, ValueName = "x",
    Callback = function(v) fmConfig.robotScale = v end })
FmTab:AddSlider({ Name = "Robot: 呼吸の揺れ幅", Min = 0, Max = 1, Default = 0.15, Increment = 0.05, ValueName = "",
    Callback = function(v) fmConfig.robotBobAmp = v end })
FmTab:AddSlider({ Name = "Robot: 呼吸の速度", Min = 0, Max = 5, Default = 1.0, Increment = 0.1, ValueName = "",
    Callback = function(v) fmConfig.robotBobSpeed = v end })
FmTab:AddSlider({ Name = "Robot: 腕の振り角度", Min = 0, Max = 90, Default = 25, Increment = 1, ValueName = "°",
    Callback = function(v) fmConfig.robotArmSwing = v end })
FmTab:AddSlider({ Name = "Robot: 脚の振り角度", Min = 0, Max = 60, Default = 20, Increment = 1, ValueName = "°",
    Callback = function(v) fmConfig.robotLegSwing = v end })

-- ============================================
-- 🔮 Sphere 設定
-- ============================================
FmTab:AddSection({ Name = "🔮 Sphere 設定（球状に囲まれる）" })
FmTab:AddLabel("フィボナッチ球面分布で均等配置")
FmTab:AddLabel("層ごとに逆回転して複雑な動きに")

FmTab:AddSlider({ Name = "Sphere: 半径", Min = 1, Max = 20, Default = 5, Increment = 0.5, ValueName = "",
    Callback = function(v) fmConfig.sphereRadius = v end })
FmTab:AddSlider({ Name = "Sphere: 回転速度", Min = -5, Max = 5, Default = 1.2, Increment = 0.1, ValueName = "",
    Callback = function(v) fmConfig.sphereRotSpeed = v end })
FmTab:AddSlider({ Name = "Sphere: 層数", Min = 1, Max = 5, Default = 3, Increment = 1, ValueName = "層",
    Callback = function(v) fmConfig.sphereLayers = v end })
FmTab:AddToggle({ Name = "Sphere: 層ごとに逆回転", Default = true, Flag = "FmSphereAlt",
    Callback = function(v) fmConfig.sphereAltSpin = v end })

-- ============================================
-- 👹 Monster 設定
-- ============================================
FmTab:AddSection({ Name = "👹 Monster 設定（化け物型）" })
FmTab:AddLabel("前爪×4・牙×2・角×2・背びれ・尾")
FmTab:AddLabel("爪は開閉アニメ、尾は蛇行アニメ付き")

FmTab:AddSlider({ Name = "Monster: スケール", Min = 0.3, Max = 4, Default = 1.5, Increment = 0.1, ValueName = "x",
    Callback = function(v) fmConfig.monsterScale = v end })
FmTab:AddSlider({ Name = "Monster: 爪の広がり角度", Min = 5, Max = 80, Default = 30, Increment = 1, ValueName = "°",
    Callback = function(v) fmConfig.monsterClawFlare = v end })
FmTab:AddSlider({ Name = "Monster: 背びれの波打ち幅", Min = 0, Max = 3, Default = 0.8, Increment = 0.1, ValueName = "",
    Callback = function(v) fmConfig.monsterSpineAmp = v end })
FmTab:AddSlider({ Name = "Monster: 尾の長さ係数", Min = 1, Max = 15, Default = 6, Increment = 0.5, ValueName = "",
    Callback = function(v) fmConfig.monsterTailLen = v end })

-- ============================================
-- 🏔️ Giant 設定
-- ============================================
FmTab:AddSection({ Name = "🏔️ Giant 設定（自分が胴体の中に入る巨人）" })
FmTab:AddLabel("胴体の正面・背面・左右にPartが配置")
FmTab:AddLabel("自分はその胴体の中央にいる状態になる")
FmTab:AddLabel("頭4.5s上・脚3.2s下の巨大人型（24部位）")

FmTab:AddSlider({ Name = "Giant: スケール", Min = 0.5, Max = 6, Default = 2.5, Increment = 0.1, ValueName = "x",
    Callback = function(v) fmConfig.giantScale = v end })
FmTab:AddSlider({ Name = "Giant: 呼吸の揺れ幅", Min = 0, Max = 1, Default = 0.2, Increment = 0.05, ValueName = "",
    Callback = function(v) fmConfig.giantBobAmp = v end })
FmTab:AddSlider({ Name = "Giant: 呼吸の速度", Min = 0, Max = 5, Default = 0.8, Increment = 0.1, ValueName = "",
    Callback = function(v) fmConfig.giantBobSpeed = v end })
FmTab:AddSlider({ Name = "Giant: 腕の振り角度", Min = 0, Max = 90, Default = 30, Increment = 1, ValueName = "°",
    Callback = function(v) fmConfig.giantArmSwing = v end })
FmTab:AddSlider({ Name = "Giant: 脚の振り角度", Min = 0, Max = 60, Default = 25, Increment = 1, ValueName = "°",
    Callback = function(v) fmConfig.giantLegSwing = v end })

--==============================
-- 初期化
--==============================
OrionLib:Init()
