getgenv().gethui = function() return game.CoreGui end

local rs = game:GetService("ReplicatedStorage")
local lp = game.Players.LocalPlayer

local function getBlobman()
    for _, v in ipairs(workspace.PlotItems:GetChildren()) do
        if v.Name == "Blobman" and v:FindFirstChild("Owner") and v.Owner.Value == lp.Name then return v end
    end
end

-- Obsidian UI 読み込み
local repo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()

-- 通知ヘルパー（OrionLib:MakeNotification の代替）
local function Notify(Name, Content, Time)
    Library:Notify({
        Title = Name,
        Description = Content,
        Time = Time or 3,
    })
end

-- [[ ウィンドウ設定 ]]
local Window = Library:CreateWindow({
    Title = "ens Hub",
    Footer = "ens Hub 起動中...",
    Center = true,
    AutoShow = true,
})

--==============================
-- タブ：HOME（統合）
--==============================
local HomeTab = Window:AddTab("HOME-ホーム", "home")

--==============================
-- セクション：基本ステータス
--==============================
local HomeBasicBox = HomeTab:AddLeftGroupbox("基本ステータス")

HomeBasicBox:AddSlider("WalkSpeed", {
    Text = "歩行速度", Min = 16, Max = 500, Default = 16, Rounding = 0,
    Callback = function(v)
        if game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") then
            game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = v
        end
    end
})

HomeBasicBox:AddSlider("JumpPower", {
    Text = "ジャンプ力", Min = 50, Max = 1000, Default = 50, Rounding = 0,
    Callback = function(v)
        if game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") then
            game.Players.LocalPlayer.Character.Humanoid.JumpPower = v
        end
    end
})

HomeBasicBox:AddToggle("InfJump", {
    Text = "無限ジャンプ",
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
local HomeVisualBox = HomeTab:AddRightGroupbox("ビジュアル・カメラ")

-- 自由視点
HomeVisualBox:AddToggle("Freecam", {
    Text = "自由視点 (Freecam)",
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
HomeVisualBox:AddToggle("ESPEnabled", {
    Text = "プレイヤー詳細ESP",
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
HomeVisualBox:AddToggle("ThirdPerson", {
    Text = "三人称視点を強制許可",
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
HomeVisualBox:AddButton({
    Text = "自分をキャラリセ (Reset)",
    Func = function()
        local char = game.Players.LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.Health = 0
            Notify("System", "キャラクターをリセットしました", 2)
        end
    end
})

--==============================
-- タブ：ターゲット
--==============================
local TargetTab = Window:AddTab("ターゲット", "target")

-- ターゲット用変数
local TargetTabSelected = ""
_G.TargetLoopKick = false
_G.TargetGrabKickLoop = false

local function getMyBlobman()
    local lp = game.Players.LocalPlayer
    if not lp.Character then return nil end
    local hum = lp.Character:FindFirstChildOfClass("Humanoid")

    if hum and hum.SeatPart then
        local parent = hum.SeatPart.Parent
        if parent and (parent.Name == "CreatureBlobman" or parent.Name == "Blobman") then
            return parent
        end
    end

    local inv = workspace:FindFirstChild(lp.Name .. "SpawnedInToys")
    if inv then
        local blob = inv:FindFirstChild("CreatureBlobman") or inv:FindFirstChild("Blobman")
        if blob then return blob end
    end

    pcall(function()
        for _, folder in ipairs(workspace.PlotItems:GetChildren()) do
            for _, item in ipairs(folder:GetChildren()) do
                if (item.Name == "CreatureBlobman" or item.Name == "Blobman") then
                    if item:FindFirstChild("PlayerValue") and item.PlayerValue.Value == lp.Name then
                        return item
                    end
                    if item:FindFirstChild("Owner") and item.Owner.Value == lp.Name then
                        return item
                    end
                end
            end
        end
    end)

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

local function doBlobGrab(blob, targetPart, side)
    if not blob or not targetPart then return end
    pcall(function()
        local detector = blob:FindFirstChild(side .. "Detector")
        if not detector then return end
        local weld = detector:FindFirstChild(side .. "Weld") or detector:FindFirstChildWhichIsA("Weld")
        if not weld then return end

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

local function kickSuccess(targetName)
    playKickSound()
    Notify("キック完了", targetName .. " のボットが抜けました！", 3)
end

local function monitorBotRemoval(targetName, wasOnBot)
    if wasOnBot then
        task.spawn(function()
            for i = 1, 20 do
                task.wait(0.1)
                if not isTargetOnBot(targetName) then
                    kickSuccess(targetName)
                    return
                end
            end
        end)
    end
end

local function GetTargetPlayerList()
    local plist = {}
    for _, p in ipairs(game.Players:GetPlayers()) do
        if p ~= game.Players.LocalPlayer then
            table.insert(plist, p.Name)
        end
    end
    return plist
end

local TargetSelectBox = TargetTab:AddLeftGroupbox("ターゲット選択")

local TargetTabDropdown = TargetSelectBox:AddDropdown("TargetPlayer", {
    Text = "プレイヤーを選択",
    Default = "",
    Values = GetTargetPlayerList(),
    Callback = function(Value)
        TargetTabSelected = Value
        Notify("ターゲット設定", Value .. " をターゲットに設定しました", 2)
    end
})

TargetSelectBox:AddButton({
    Text = "🔄 プレイヤーリスト更新",
    Func = function()
        TargetTabDropdown:SetValues(GetTargetPlayerList())
        Notify("更新完了", "プレイヤーリストを更新しました", 2)
    end
})

--==============================
-- セクション：攻撃機能
--==============================
local TargetAttackBox = TargetTab:AddRightGroupbox("攻撃機能")

-- 1. ブロブマンキック（ボタン）
TargetAttackBox:AddButton({
    Text = "ブロブマンキック",
    Func = function()
        if TargetTabSelected == "" then
            Notify("エラー", "先にターゲットを選択してください", 3)
            return
        end

        local blob = getMyBlobman()
        if not blob then
            Notify("エラー", "Blobmanが見つかりません (乗ってるか確認)", 3)
            return
        end

        local targetPlayer = game.Players:FindFirstChild(TargetTabSelected)
        if not targetPlayer or not targetPlayer.Character or not targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
            Notify("エラー", "ターゲットが見つかりません", 3)
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

        local wasOnBot = isTargetOnBot(TargetTabSelected)

        task.spawn(function()
            pcall(function()
                myRoot.CFrame = targetHRP.CFrame * CFrame.new(3, 0, 0)
                task.wait(0.15)
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
                myRoot.CFrame = savedPos
            end)
            monitorBotRemoval(TargetTabSelected, wasOnBot)
        end)
    end
})

-- 2. ブロブマンループキック（トグル）
TargetAttackBox:AddToggle("TargetLoopKick", {
    Text = "ブロブマンループキック",
    Default = false,
    Callback = function(Value)
        _G.TargetLoopKick = Value
        if Value then
            if TargetTabSelected == "" then
                Notify("エラー", "先にターゲットを選択してください", 3)
                _G.TargetLoopKick = false
                return
            end

            Notify("ループキック", TargetTabSelected .. " へのループキック開始", 2)

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
                    local wasOnBot = isTargetOnBot(TargetTabSelected)

                    pcall(function()
                        myRoot.CFrame = targetHRP.CFrame * CFrame.new(3, 0, 0)
                        task.wait(0.15)
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
                        myRoot.CFrame = savedPos
                    end)

                    monitorBotRemoval(TargetTabSelected, wasOnBot)
                end
            end)
        else
            Notify("ループキック", "ループキックを停止しました", 2)
        end
    end
})

-- 3. グラブキック（トグル）
TargetAttackBox:AddToggle("TargetGrabKick", {
    Text = "グラブキック",
    Default = false,
    Callback = function(Value)
        _G.TargetGrabKickLoop = Value
        if Value then
            if TargetTabSelected == "" then
                Notify("エラー", "先にターゲットを選択してください", 3)
                _G.TargetGrabKickLoop = false
                return
            end

            Notify("グラブキック", TargetTabSelected .. " へのグラブキックON", 2)

            task.spawn(function()
                local GrabEventsFolder = game:GetService("ReplicatedStorage"):FindFirstChild("GrabEvents")
                local RunService = game:GetService("RunService")
                if not GrabEventsFolder then
                    Notify("エラー", "GrabEventsが見つかりません", 3)
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
                        tRoot.AssemblyLinearVelocity = Vector3.zero
                        tRoot.AssemblyAngularVelocity = Vector3.zero

                        if not dragging then
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

                if myRoot then
                    myRoot.CFrame = savedPos
                    myRoot.AssemblyLinearVelocity = Vector3.zero
                end

                Notify("グラブキック", "グラブキックOFF", 2)
            end)
        end
    end
})

-- 4. ブロブマンBRING（ボタン）
TargetAttackBox:AddButton({
    Text = "ブロブマンBRING",
    Func = function()
        if TargetTabSelected == "" then
            Notify("エラー", "先にターゲットを選択してください", 3)
            return
        end

        local blob = getMyBlobman()
        if not blob then
            Notify("エラー", "Blobmanが見つかりません (乗ってるか確認)", 3)
            return
        end

        local targetPlayer = game.Players:FindFirstChild(TargetTabSelected)
        if not targetPlayer or not targetPlayer.Character or not targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
            Notify("エラー", "ターゲットが見つかりません", 3)
            return
        end

        local lp = game.Players.LocalPlayer
        local myRoot = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
        if not myRoot then return end

        local savedPos = myRoot.CFrame
        local targetHRP = targetPlayer.Character.HumanoidRootPart

        task.spawn(function()
            pcall(function()
                myRoot.CFrame = targetHRP.CFrame * CFrame.new(3, 0, 0)
                task.wait(0.2)
                doBlobGrab(blob, targetHRP, "Left")
                task.wait(0.05)
                doBlobGrab(blob, targetHRP, "Right")
                task.wait(0.2)
                myRoot.CFrame = savedPos
                task.wait(0.2)
                local rs = game:GetService("ReplicatedStorage")
                local destroyLine = rs:FindFirstChild("GrabEvents") and rs.GrabEvents:FindFirstChild("DestroyGrabLine")
                if destroyLine then
                    destroyLine:FireServer(targetHRP)
                end
            end)

            Notify("ブロブマンBRING", TargetTabSelected .. " を引き寄せました", 2)
        end)
    end
})

-- 5. グッチ破壊（ボタン）
TargetAttackBox:AddButton({
    Text = "グッチ破壊",
    Func = function()
        if TargetTabSelected == "" then
            Notify("エラー", "先にターゲットを選択してください", 3)
            return
        end

        local targetPlayer = game.Players:FindFirstChild(TargetTabSelected)
        if not targetPlayer then
            Notify("エラー", "ターゲットが見つかりません", 3)
            return
        end

        local lp = game.Players.LocalPlayer
        local myRoot = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
        local myHum = lp.Character and lp.Character:FindFirstChildOfClass("Humanoid")
        if not myRoot or not myHum then return end

        local savedPos = myRoot.CFrame
        local targetBlob = nil

        local inv = workspace:FindFirstChild(targetPlayer.Name .. "SpawnedInToys")
        if inv then
            targetBlob = inv:FindFirstChild("CreatureBlobman") or inv:FindFirstChild("Blobman")
        end

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
            Notify("エラー", "相手のBlobmanが見つかりません", 3)
            return
        end

        local seat = targetBlob:FindFirstChild("VehicleSeat")
        if not seat then
            Notify("エラー", "シートが見つかりません", 3)
            return
        end

        task.spawn(function()
            pcall(function()
                myRoot.CFrame = seat.CFrame + Vector3.new(0, 2, 0)
                task.wait(0.1)
                seat:Sit(myHum)
                task.wait(0.25)
                myHum:ChangeState(Enum.HumanoidStateType.Jumping)
                task.wait(0.15)
                myRoot.CFrame = savedPos
            end)

            Notify("グッチ破壊", TargetTabSelected .. " のグッチを破壊しました", 2)
        end)
    end
})

-- 6. スノーボールキック（トグル）
TargetAttackBox:AddToggle("SnowballKick", {
    Text = "スノーボールキック",
    Default = false,
    Callback = function(Value)
        _G.TargetSnowballKick = Value
        if Value then
            if TargetTabSelected == "" then
                Notify("エラー", "先にターゲットを選択してください", 3)
                _G.TargetSnowballKick = false
                return
            end

            Notify("スノーボール", TargetTabSelected .. " へ雪玉攻撃開始", 2)

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

                    pcall(function()
                        local offset = Vector3.new(
                            math.random(-30, 30) / 100,
                            math.random(-30, 30) / 100,
                            math.random(-30, 30) / 100
                        )
                        spawnRemote:InvokeServer("BallSnowball", torso.CFrame * CFrame.new(offset), Vector3.zero)
                    end)

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

-- 7. 2本手ループキック（トグル）
TargetAttackBox:AddToggle("DualHandKick", {
    Text = "2本手ループキック",
    Default = false,
    Callback = function(Value)
        _G.TargetDualHandKick = Value
        if Value then
            if TargetTabSelected == "" then
                Notify("エラー", "先にターゲットを選択してください", 3)
                _G.TargetDualHandKick = false
                return
            end

            local blob = getMyBlobman()
            if not blob then
                Notify("エラー", "Blobmanが見つかりません (乗ってるか確認)", 3)
                _G.TargetDualHandKick = false
                return
            end

            Notify("2本手キック", TargetTabSelected .. " への両手攻撃開始", 2)

            task.spawn(function()
                local scriptObj = blob:FindFirstChild("BlobmanSeatAndOwnerScript")
                local grab = scriptObj and scriptObj:FindFirstChild("CreatureGrab")
                local drop = scriptObj and scriptObj:FindFirstChild("CreatureDrop")

                local leftDet = blob:FindFirstChild("LeftDetector")
                local rightDet = blob:FindFirstChild("RightDetector")
                local leftWeld = leftDet and (leftDet:FindFirstChild("LeftWeld") or leftDet:FindFirstChildWhichIsA("Weld"))
                local rightWeld = rightDet and (rightDet:FindFirstChild("RightWeld") or rightDet:FindFirstChildWhichIsA("Weld"))

                if not grab or not drop or not leftDet or not rightDet then
                    Notify("エラー", "ブロブマンの機能が見つかりません", 3)
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
                            grab:FireServer(leftDet, tRoot, leftWeld, 2)
                            grab:FireServer(leftDet, tRoot, leftWeld, 1)
                            task.wait(0.05)
                            drop:FireServer(leftWeld, tRoot)

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
-- タブ：移動ハック
--==============================
local MoveTab = Window:AddTab("移動ハック", "move")

local MoveBasicBox = MoveTab:AddLeftGroupbox("基本移動ハック")

MoveBasicBox:AddToggle("Noclip", {
    Text = "壁抜け (Noclip)",
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
-- 各家へのダイレクトテレポート
--==============================
local MoveTeleportBox = MoveTab:AddRightGroupbox("各家へのダイレクトテレポート")

for i = 1, 12 do
    MoveTeleportBox:AddButton({
        Text = "Plot " .. i .. " (家) へテレポート",
        Func = function()
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
                    Notify("Teleport Success", "Plot " .. i .. " に移動しました", 2)
                else
                    Notify("Error", "テレポート先のパーツが見つかりません", 2)
                end
            else
                Notify("Error", "Plot " .. i .. " が存在しません", 2)
            end
        end
    })
end

--==============================
-- プレイヤー家テレポート
--==============================
local MovePlotBox = MoveTab:AddLeftGroupbox("プレイヤー家テレポート")

local selectedPlot = ""

MovePlotBox:AddButton({
    Text = "選択した家へテレポート",
    Func = function()
        if selectedPlot == "" then
            Notify("エラー", "先に家（プレイヤー名）を選んでください", 3)
            return
        end

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

                    Notify("Teleport", selectedPlot .. " の家へ移動しました", 2)
                    return
                end
            end
        end

        Notify("Error", "プロットが見つかりませんでした", 3)
    end
})

--==============================
-- タブ：aura-オーラ
--==============================
local AuraTab = Window:AddTab("aura-オーラ", "zap")

_G.isConstantAuraEnabled = false
_G.KillAuraEnabled = false
local autoVoidEnabled = false
local voidPower = 20000
local voidRange = 25

--==============================
-- Fling / Kill Aura
--==============================
local AuraFlingBox = AuraTab:AddLeftGroupbox("Fling / Kill Aura")

AuraFlingBox:AddToggle("FlingAura", {
    Text = "Flingオーラを有効化",
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

AuraFlingBox:AddToggle("KillAura", {
    Text = "Kill Aura (ダメージ特化)",
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
-- Void Aura
--==============================
local AuraVoidBox = AuraTab:AddRightGroupbox("Void Aura")

AuraVoidBox:AddToggle("AutoVoid", {
    Text = "Enable Auto-Void (Near Players)",
    Default = false,
    Callback = function(Value)
        autoVoidEnabled = Value
    end
})

AuraVoidBox:AddSlider("VoidRange", {
    Text = "Void Range",
    Min = 5, Max = 50, Default = 25, Rounding = 0,
    Callback = function(Value)
        voidRange = Value
    end
})

AuraVoidBox:AddSlider("EjectionPower", {
    Text = "Ejection Power",
    Min = 5000, Max = 100000, Default = 20000, Rounding = 0,
    Callback = function(Value)
        voidPower = Value
    end
})

-- 自動射出ロジック
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

--==============================
-- タブ：Anti-アンチ機能
--==============================
local AntiTab = Window:AddTab("Anti-アンチ機能", "shield")

_G.activeAntiGrab = _G.activeAntiGrab or false

local AntiMainBox = AntiTab:AddLeftGroupbox("Anti-Grab")

AntiMainBox:AddToggle("AntiGrab", {
    Text = "Enable Anti-Grab Mode",
    Default = _G.activeAntiGrab,
    Callback = function(Value)
        _G.activeAntiGrab = Value
    end
})

-- ループ処理
task.spawn(function()
    while true do
        task.wait(0.1)

        if _G.activeAntiGrab then
            local lp = game.Players.LocalPlayer
            local char = lp.Character
            if not char then continue end

            local hrp = char:FindFirstChild("HumanoidRootPart")
            local rs = game:GetService("ReplicatedStorage")

            pcall(function()
                if lp:FindFirstChild("IsHeld") and lp.IsHeld.Value == true then
                    lp.IsHeld.Value = false
                end
                if hrp and hrp.Anchored then
                    hrp.Anchored = false
                end
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
                if lp:FindFirstChild("Struggled") then lp.Struggled.Value = true end
                if lp:FindFirstChild("HeldTimer") then lp.HeldTimer.Value = 0 end
                local ce = rs:FindFirstChild("CharacterEvents")
                if ce and ce:FindFirstChild("Struggle") then
                    ce.Struggle:FireServer()
                end
            end)
        end
    end
end)

--==============================
-- 追加防御機能
--==============================
local AntiDefenseBox = AntiTab:AddRightGroupbox("追加防御機能")

-- Anti-Void
AntiDefenseBox:AddToggle("AntiVoid", {
    Text = "Anti-Void",
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

-- Anti Blobman
local Player = game.Players.LocalPlayer
local antiBlob1T = false

local function antiBlob1F()
    antiBlob1T = true
    workspace.DescendantAdded:Connect(function(toy)
        if toy.Name == "CreatureBlobman" and antiBlob1T then
            pcall(function()
                if toy:FindFirstChild("LeftDetector") then toy.LeftDetector:Destroy() end
                if toy:FindFirstChild("RightDetector") then toy.RightDetector:Destroy() end
            end)
        end
    end)
end

AntiDefenseBox:AddToggle("AntiBlobman", {
    Text = "Anti Blobman",
    Default = false,
    Callback = function(on)
        if on then
            antiBlob1F()
        else
            antiBlob1T = false
        end
    end
})

-- Anti Explode
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

AntiDefenseBox:AddToggle("AntiExplode", {
    Text = "Anti Explode",
    Default = false,
    Callback = function(on)
        if on then
            antiExplodeF()
        else
            antiExplodeT = false
        end
    end
})

-- Anti Kick (Shuriken)
AntiDefenseBox:AddToggle("ShurikenAntiKick", {
    Text = "Anti Kick (Shuriken)",
    Default = false,
    Callback = function(Value)
        _G.ShurikenAntiKick = Value

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
                    if not kunai or not kunai:FindFirstChild("StickyPart") then return end
                    local currentHRP = getHRP()
                    if not currentHRP then return end
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
                            obj.CanTouch = false; obj.CanCollide = false; obj.CanQuery = false; obj.Transparency = 0
                            if not obj:FindFirstChild("Highlight") then
                                local high = Instance.new("Highlight", obj)
                                high.FillColor = Color3.fromRGB(0, 0, 0)
                            end
                        elseif obj.Name == "Main" then
                            obj.CanTouch = false; obj.CanCollide = false; obj.CanQuery = false; obj.Transparency = 0
                            if not obj:FindFirstChild("Highlight") then
                                local high = Instance.new("Highlight", obj)
                                high.FillColor = Color3.fromRGB(255, 255, 255)
                            end
                        elseif obj:IsA("BasePart") then
                            obj.CanTouch = false; obj.CanCollide = false; obj.CanQuery = false; obj.Transparency = 1
                        end
                    end
                end

                local function SpawnToy(name)
                    local t = tick()
                    while not canSpawn.Value do
                        if not _G.ShurikenAntiKick or tick() - t > 5 then return nil end
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
                                if kunai == nil then continue end
                                kunai.Name = "AntiKick"
                                StickKunai(kunai)
                            end
                        end
                    end
                    if not kunai then
                        if workspace.PlotItems.PlayersInPlots:FindFirstChild(plr.Name) then continue end
                        kunai = SpawnToy("NinjaShuriken")
                        if kunai == nil then continue end
                        kunai.Name = "AntiKick"
                        if not kunai then continue end
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
            local function ClearKunai2()
                local plr = game.Players.LocalPlayer
                local inv = workspace:FindFirstChild(plr.Name .. "SpawnedInToys")
                local destroyrem = game.ReplicatedStorage:FindFirstChild("MenuToys") and game.ReplicatedStorage.MenuToys:FindFirstChild("DestroyToy")
                if inv and destroyrem then
                    for _, v in pairs(inv:GetChildren()) do
                        if v.Name == "AntiKick" or v.Name == "NinjaShuriken" then
                            pcall(function() destroyrem:FireServer(v) end)
                        end
                    end
                end
            end
            ClearKunai2()
        end
    end
})

-- Anti Lag (Grab Line)
do
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local createGrabLineCopy
    local extendGrabLineCopy

    local grabFolder = ReplicatedStorage:FindFirstChild("GrabEvents")
    if grabFolder then
        local originalCreate = grabFolder:FindFirstChild("CreateGrabLine")
        local originalExtend = grabFolder:FindFirstChild("ExtendGrabLine")
        if originalCreate then createGrabLineCopy = originalCreate:Clone() end
        if originalExtend then extendGrabLineCopy = originalExtend:Clone() end
    end

    AntiDefenseBox:AddToggle("AntiLag", {
        Text = "Anti Lag (Grab Line)",
        Default = false,
        Callback = function(Value)
            local grabFolder = ReplicatedStorage:FindFirstChild("GrabEvents")
            if not grabFolder then return end

            if Value then
                local create = grabFolder:FindFirstChild("CreateGrabLine")
                local extend = grabFolder:FindFirstChild("ExtendGrabLine")
                if create and create:IsA("RemoteEvent") then pcall(function() create:Destroy() end) end
                if extend and extend:IsA("RemoteEvent") then pcall(function() extend:Destroy() end) end
                for _, v in ipairs(workspace:GetDescendants()) do
                    if v:IsA("Beam") or v.Name:lower():find("line") then
                        pcall(function() v:Destroy() end)
                    end
                end
            else
                if createGrabLineCopy and not grabFolder:FindFirstChild("CreateGrabLine") then
                    pcall(function() createGrabLineCopy:Clone().Parent = grabFolder end)
                end
                if extendGrabLineCopy and not grabFolder:FindFirstChild("ExtendGrabLine") then
                    pcall(function() extendGrabLineCopy:Clone().Parent = grabFolder end)
                end
            end
        end
    })
end

-- Anti Burn
do
    local Player = game.Players.LocalPlayer
    local hookBurnConn

    AntiDefenseBox:AddToggle("AntiBurn", {
        Text = "Anti Burn",
        Default = false,
        Callback = function(on)
            if on then
                if Player.Character then
                    pcall(function() hookBurn(Player.Character) end)
                end
            else
                if hookBurnConn then
                    pcall(function() hookBurnConn:Disconnect() end)
                    hookBurnConn = nil
                end
            end
        end
    })
end

-- Anti Sticky
do
    local Player = game.Players.LocalPlayer
    local antiStickyT = false

    AntiDefenseBox:AddToggle("AntiSticky", {
        Text = "Anti Sticky",
        Default = false,
        Callback = function(Value)
            antiStickyT = Value
            local ps = Player:FindFirstChild("PlayerScripts")
            if ps and ps:FindFirstChild("StickyPartsTouchDetection") then
                pcall(function() ps.StickyPartsTouchDetection.Disabled = Value end)
            end
        end
    })
end

-- Anti Loop
local antiLoopActive = false
local currentTargetIndex = 1

AntiDefenseBox:AddToggle("AntiLoop", {
    Text = "Enable Anti-Loop (Plot Cycler)",
    Default = false,
    Callback = function(Value)
        antiLoopActive = Value

        if Value then
            task.spawn(function()
                local lp = game.Players.LocalPlayer

                local function GetPlotCFrameByIndex(index)
                    local plot = workspace:FindFirstChild("Plots") and workspace.Plots:FindFirstChild("Plot" .. index)
                    if plot then
                        local house = plot:FindFirstChild("House")
                        if house then
                            local primary = house:IsA("Model") and (house.PrimaryPart or house:FindFirstChildWhichIsA("BasePart", true))
                            if primary then return primary.CFrame end
                        end
                    end
                    return nil
                end

                while antiLoopActive do
                    task.wait(0.1)
                    pcall(function()
                        local char = lp.Character
                        if not char then return end
                        local hrp = char:FindFirstChild("HumanoidRootPart")
                        local hum = char:FindFirstChild("Humanoid")
                        local targetCFrame = GetPlotCFrameByIndex(currentTargetIndex)

                        if hrp and targetCFrame then
                            local dist = (hrp.Position - targetCFrame.Position).Magnitude
                            if (hum and hum.Health <= 0) or dist > 70 then
                                if hum and hum.Health > 0 then
                                    currentTargetIndex = currentTargetIndex + 1
                                    if currentTargetIndex > 5 then currentTargetIndex = 1 end
                                    targetCFrame = GetPlotCFrameByIndex(currentTargetIndex)
                                end
                                if targetCFrame then
                                    hrp.CFrame = targetCFrame + Vector3.new(0, 5, 0)
                                    Notify("Anti-Loop", "Plot " .. currentTargetIndex .. " へ移動しました", 1)
                                end
                            end
                        end
                    end)
                end
            end)
        end
    end
})

--==============================
-- タブ：究極オーラ
--==============================
local UltimateTab = Window:AddTab("究極オーラ", "zap")

_G.UltimateAuraEnabled = false
_G.LevitateKillAura = false
local ultRange = 25
local ultPower = 500000

local UltLeftBox = UltimateTab:AddLeftGroupbox("究極オーラ設定")

UltLeftBox:AddToggle("UltHybrid", {
    Text = "究極ハイブリッドオーラ有効化",
    Default = false,
    Callback = function(Value)
        _G.UltimateAuraEnabled = Value
    end
})

UltLeftBox:AddToggle("LevitateKill", {
    Text = "空中固定 Kill Aura",
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

UltLeftBox:AddSlider("UltRange", {
    Text = "オーラ射程", Min = 5, Max = 50, Default = 25, Rounding = 0,
    Callback = function(Value) ultRange = Value end
})

-- 究極ハイブリッドオーラ用ロジック
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

-- 地底貫通 Kill Aura
local UltRightBox = UltimateTab:AddRightGroupbox("特殊オーラ")

_G.AbyssKillAuraEnabled = false
local abyssDepth = -50
local fallSpeed = -5000

UltRightBox:AddToggle("AbyssKill", {
    Text = "地底貫通 Kill Aura (Noclip)",
    Default = false,
    Callback = function(Value)
        _G.AbyssKillAuraEnabled = Value
        if Value then
            task.spawn(function()
                while _G.AbyssKillAuraEnabled do
                    task.wait(0.05)
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
                                        if SetNetworkOwner then SetNetworkOwner:FireServer(targetHRP, targetHRP.CFrame) end
                                        for _, part in ipairs(player.Character:GetChildren()) do
                                            if part:IsA("BasePart") then part.CanCollide = false end
                                        end
                                        targetHRP.CFrame = targetHRP.CFrame * CFrame.new(0, abyssDepth, 0)
                                        targetHRP.Velocity = Vector3.new(0, fallSpeed, 0)
                                        if combatEvent then combatEvent:FireServer(player.Character, "Punch") end
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

-- Death Aura
local playersService = game:GetService("Players")
local destroyGrabLineEvent = game:GetService("ReplicatedStorage"):FindFirstChild("Events") and game:GetService("ReplicatedStorage").Events:FindFirstChild("DestroyGrabLine")

local CheckPlayerAuras = CheckPlayerAuras or function() return true end
local SNOWshipPlayer = SNOWshipPlayer or function() return true end
local CreateSkyVelocity = CreateSkyVelocity or function(hrp) hrp.Velocity = Vector3.new(0, 100, 0) end

UltRightBox:AddToggle("DeathAura", {
    Text = "Death Aura (抹殺オーラ)掴んだらキル",
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
                        if playerKey2 == nil then break end

                        if player2 ~= lp and CheckPlayerAuras(player2) then
                            local playerCharacter = player2.Character
                            local humanoidRootPart = playerCharacter and playerCharacter:FindFirstChild("HumanoidRootPart")
                            local humanoid = playerCharacter and playerCharacter:FindFirstChildOfClass("Humanoid")

                            if humanoidRootPart and humanoid and SNOWshipPlayer(player2) then
                                pcall(function()
                                    if destroyGrabLineEvent then
                                        destroyGrabLineEvent:FireServer(humanoidRootPart)
                                    end
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
                    task.wait(0.1)
                end
            end)
        end
    end
})

-- Auto-Warp
_G.AutoWarpEnabled = false
local warpReturnPos = nil

UltRightBox:AddToggle("AutoWarp", {
    Text = "全員自動テレポート (Auto-Warp)",
    Default = false,
    Callback = function(Value)
        _G.AutoWarpEnabled = Value
        local lp = game.Players.LocalPlayer

        if Value then
            if lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then
                warpReturnPos = lp.Character.HumanoidRootPart.CFrame
            end

            task.spawn(function()
                while _G.AutoWarpEnabled do
                    task.wait(0.2)
                    if not (lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")) then continue end

                    for _, p in ipairs(game.Players:GetPlayers()) do
                        if not _G.AutoWarpEnabled then break end
                        if p ~= lp and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 then
                            pcall(function()
                                lp.Character.HumanoidRootPart.CFrame = p.Character.HumanoidRootPart.CFrame * CFrame.new(0, 5, 0)
                                Notify("テレポート中", p.Name .. " の場所へ移動しました", 0.5)
                            end)
                            task.wait(0.5)
                        end
                    end
                end
            end)
        else
            if lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") and warpReturnPos then
                lp.Character.HumanoidRootPart.CFrame = warpReturnPos
                Notify("帰還", "元の場所に戻りました", 3)
            end
        end
    end
})

-- Turbo-Warp
_G.TurboWarpEnabled = false

UltRightBox:AddToggle("TurboWarp", {
    Text = "⚡ 爆速巡回 (Turbo-Warp)",
    Default = false,
    Callback = function(Value)
        _G.TurboWarpEnabled = Value
        local lp = game.Players.LocalPlayer

        if Value then
            task.spawn(function()
                while _G.TurboWarpEnabled do
                    task.wait(0.1)
                    if not (lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")) then continue end

                    for _, p in ipairs(game.Players:GetPlayers()) do
                        if not _G.TurboWarpEnabled then break end
                        if p ~= lp and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 then
                            pcall(function()
                                lp.Character.HumanoidRootPart.CFrame = p.Character.HumanoidRootPart.CFrame * CFrame.new(0, 3, 0)
                            end)
                            task.wait(0.3)
                        end
                    end
                end
            end)
        else
            Notify("Turbo-Warp", "爆速巡回を停止しました", 2)
        end
    end
})

-- ターゲット追跡
local SelectedTarget = ""
_G.StalkerEnabled = false
local stalkerOffset = CFrame.new(0, 5, 0)

local function GetPlayerList()
    local plist = {}
    for _, p in ipairs(game.Players:GetPlayers()) do
        if p ~= game.Players.LocalPlayer then
            table.insert(plist, p.Name)
        end
    end
    return plist
end

local UltTargetBox = UltimateTab:AddLeftGroupbox("ターゲット追跡")

local TargetDropdown = UltTargetBox:AddDropdown("UltTarget", {
    Text = "ターゲットを選択",
    Default = "",
    Values = GetPlayerList(),
    Callback = function(Value)
        SelectedTarget = Value
        Notify("ターゲットロック", Value .. " を捕捉しました", 2)
    end
})

UltTargetBox:AddButton({
    Text = "ターゲットへ即座にテレポート",
    Func = function()
        if SelectedTarget == "" then return end
        local lp = game.Players.LocalPlayer
        local targetPlayer = game.Players:FindFirstChild(SelectedTarget)
        if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
            lp.Character.HumanoidRootPart.CFrame = targetPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0, 3, 0)
        end
    end
})

UltTargetBox:AddToggle("Stalker", {
    Text = "自動ストーカー (ONで貼り付き)",
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
                        myHRP.Velocity = Vector3.new(0, 0, 0)
                        myHRP.CFrame = tHRP.CFrame * stalkerOffset
                    end
                end
            end)
        end
    end
})

UltTargetBox:AddSlider("StalkerHeight", {
    Text = "ストーカー高度 (上下距離)",
    Min = -15, Max = 30, Default = 5, Rounding = 0,
    Suffix = "Studs",
    Callback = function(Value)
        stalkerOffset = CFrame.new(0, Value, 0)
    end
})

UltTargetBox:AddButton({
    Text = "プレイヤーリストを更新",
    Func = function()
        TargetDropdown:SetValues(GetPlayerList())
    end
})

--==============================
-- タブ：ブロブマン設定
--==============================
local BlobTab = Window:AddTab("ブロブマン設定", "settings")

local players = game:GetService("Players")
local lp = players.LocalPlayer

local BlobLeftBox = BlobTab:AddLeftGroupbox("ブロブマン制御")

BlobLeftBox:AddSlider("BlobSpeed", {
    Text = "ブロブマン走行速度",
    Min = 16, Max = 500, Default = 50, Rounding = 0,
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

BlobLeftBox:AddToggle("BlobFly", {
    Text = "ブロブマン飛行モード",
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
                    local moveDir = Vector3.new(0, 0, 0)
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

--==============================
-- タブ：Wings & Orbit
--==============================
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

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

-- FireworkSparkler設定
local fwConfig = {
    enabled = false, targetPlayer = nil, targetPartName = "FireworkSparkler",
    maxSparklers = 20, spacing = 1.2, heightOffset = 1, forwardOffset = 4,
    waveSpeed = 2.5, baseAmplitude = 2, distanceMultiplier = 0.4, phaseOffset = 0.3,
    horizontalWaveAmount = 0.5, smoothness = 0.6, xRotation = -45, yRotation = 0, zRotation = 90,
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
    BP.P = 25000; BP.D = 800; BP.MaxForce = Vector3.new(1,1,1) * 1e10; BP.Parent = part
    local BG = Instance.new("BodyGyro")
    BG.P = 25000; BG.D = 800; BG.MaxTorque = Vector3.new(1,1,1) * 1e10; BG.Parent = part
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
    if isOdd then table.insert(points, { baseOffsetX = 0, part = fwCP(), index = idx }); idx += 1 end
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
                    c.Anchored = true; c.Velocity = Vector3.new(0,0,0); c.RotVelocity = Vector3.new(0,0,0)
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

fwRefresh()
workspace.DescendantAdded:Connect(function(d)
    if d:IsA("Model") and d.Name == fwConfig.targetPartName then
        task.wait(0.5); fwRefresh()
    end
end)

-- Part Orbit設定
local orbitConfig = {
    enabled = false, targetPartName = "PalletLightBrown", shape = "Circle",
    radius = 5, height = 0, speed = 1, count = 8, scale = 1, yRotation = 0,
    waveAmplitude = 2, waveFrequency = 2, helixHeight = 5, starPoints = 5,
    starInnerRadius = 2, faceCenter = false, useAllFound = true,
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
        Notify("エラー", "'" .. orbitConfig.targetPartName .. "' が見つかりません", 3)
        return
    end
    local useCount = orbitConfig.useAllFound and #found or math.min(orbitConfig.count, #found)
    for i = 1, useCount do
        local obj = _setupObj(found[i])
        if obj then table.insert(orbitParts, obj) end
    end
    Notify("Orbit開始", #orbitParts .. "個 / 形状: " .. orbitConfig.shape, 2)
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

-- BallMagicLight設定
local ballConfig = {
    mode = "Wings", enabled = false, targetPartName = "BallMagicLight",
    count = 10, useAllFound = true, speed = 2.5, height = 1, smoothness = 0.15,
    wingsSpacing = 1.2, wingsAmplitude = 2.5, wingsPhaseOffset = 0.3,
    wingsDistMultiplier = 0.4, wingsHorizontalAmount = 0.5, wingsForwardOffset = 3,
    wingsXRot = -45, wingsYRot = 0, wingsZRot = 90,
    orbitShape = "Circle", orbitRadius = 5, orbitScale = 1, orbitYRotOffset = 0,
    orbitWaveAmplitude = 2, orbitWaveFrequency = 2, orbitHelixHeight = 5,
    orbitStarPoints = 5, orbitStarInnerRadius = 2, orbitFaceCenter = false,
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
        Notify("エラー", "'" .. ballConfig.targetPartName .. "' が見つかりません", 3)
        return
    end
    local useCount = ballConfig.useAllFound and #found or math.min(ballConfig.count, #found)
    for i = 1, useCount do
        local obj = _setupObj(found[i])
        if obj then table.insert(ballParts, obj) end
    end
    if ballConfig.mode == "Wings" then ballRowPoints = ballCreateWingsPoints(#ballParts) end
    Notify("BallMagicLight 起動", "モード: " .. ballConfig.mode .. " / 数: " .. #ballParts, 2)
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

-- FireworkSparklerメインループ
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

-- Wings & Orbit タブ
local WingsTab = Window:AddTab("Wings & Orbit", "sparkles")

-- FW セクション
local WingsFWBox = WingsTab:AddLeftGroupbox("🎆 FireworkSparkler")

WingsFWBox:AddToggle("FWEnabled", {
    Text = "FW: 有効化", Default = false,
    Callback = function(v)
        fwConfig.enabled = v
        if v then fwEnable(); Notify("FW ON", "花火システム起動", 2)
        else fwDisable(); Notify("FW OFF", "花火固定", 2) end
    end
})

local fwPlayerDropdown
fwPlayerDropdown = WingsFWBox:AddDropdown("FWPlayer", {
    Text = "FW: 対象プレイヤー", Default = "自分", Values = fwGetPlayerList(),
    Callback = function(v)
        if v == "自分" then fwConfig.targetPlayer = nil
        else fwConfig.targetPlayer = Players:FindFirstChild(v) end
        fwAssigned = fwAssignToPoints()
    end
})

WingsFWBox:AddButton({ Text = "FW: プレイヤーリスト更新", Func = function()
    fwPlayerDropdown:SetValues(fwGetPlayerList())
    Notify("更新", "リスト更新完了", 2)
end })
WingsFWBox:AddButton({ Text = "FW: 花火を再検出", Func = function()
    fwRefresh(); Notify("再検出", "花火数: " .. #fwToys, 2)
end })

WingsFWBox:AddSlider("FWMax", { Text = "FW: 最大花火数", Min = 2, Max = 40, Default = 20, Rounding = 0, Suffix = "本", Callback = function(v) fwConfig.maxSparklers = v; fwRefresh() end })
WingsFWBox:AddSlider("FWSpacing", { Text = "FW: 間隔", Min = 0.5, Max = 5, Default = 1.2, Rounding = 1, Callback = function(v) fwConfig.spacing = v; fwRefresh() end })
WingsFWBox:AddSlider("FWHeight", { Text = "FW: 高さ", Min = -5, Max = 10, Default = 1, Rounding = 1, Callback = function(v) fwConfig.heightOffset = v end })
WingsFWBox:AddSlider("FWForward", { Text = "FW: 前方オフセット", Min = 0, Max = 15, Default = 4, Rounding = 1, Callback = function(v) fwConfig.forwardOffset = v end })
WingsFWBox:AddSlider("FWWaveSpeed", { Text = "FW: 波速度", Min = 0, Max = 10, Default = 2.5, Rounding = 1, Callback = function(v) fwConfig.waveSpeed = v end })
WingsFWBox:AddSlider("FWAmplitude", { Text = "FW: 振幅", Min = 0, Max = 10, Default = 2, Rounding = 1, Callback = function(v) fwConfig.baseAmplitude = v end })
WingsFWBox:AddSlider("FWPhase", { Text = "FW: 位相差", Min = 0, Max = 2, Default = 0.3, Rounding = 2, Callback = function(v) fwConfig.phaseOffset = v end })
WingsFWBox:AddSlider("FWHorizontal", { Text = "FW: 内側への寄り", Min = 0, Max = 2, Default = 0.5, Rounding = 2, Callback = function(v) fwConfig.horizontalWaveAmount = v end })
WingsFWBox:AddSlider("FWSmoothness", { Text = "FW: 滑らかさ", Min = 0.01, Max = 1, Default = 0.6, Rounding = 2, Callback = function(v) fwConfig.smoothness = v end })
WingsFWBox:AddSlider("FWXRot", { Text = "FW: X軸回転", Min = -180, Max = 180, Default = -45, Rounding = 0, Suffix = "°", Callback = function(v) fwConfig.xRotation = v end })
WingsFWBox:AddSlider("FWYRot", { Text = "FW: Y軸回転", Min = -180, Max = 180, Default = 0, Rounding = 0, Suffix = "°", Callback = function(v) fwConfig.yRotation = v end })
WingsFWBox:AddSlider("FWZRot", { Text = "FW: Z軸回転", Min = -180, Max = 180, Default = 90, Rounding = 0, Suffix = "°", Callback = function(v) fwConfig.zRotation = v end })
WingsFWBox:AddButton({ Text = "FW: 回転リセット", Func = function()
    fwConfig.xRotation = -45; fwConfig.yRotation = 0; fwConfig.zRotation = 90
    Notify("リセット", "回転をデフォルトに戻しました", 2)
end })

-- Orbit セクション
local WingsOrbitBox = WingsTab:AddRightGroupbox("🌀 Part Orbit")

WingsOrbitBox:AddToggle("OrbitEnabled", {
    Text = "Orbit: 有効化", Default = false,
    Callback = function(v)
        orbitConfig.enabled = v
        if v then orbitStart()
        else orbitStop(); Notify("Orbit停止", "オービット停止", 2) end
    end
})

WingsOrbitBox:AddInput("OrbitPartName", { Text = "Orbit: 対象Part名", Default = "PalletLightBrown", Numeric = false, Finished = false, Callback = function(v) orbitConfig.targetPartName = v end })
WingsOrbitBox:AddDropdown("OrbitShape", { Text = "Orbit: 形状", Default = "Circle", Values = {"Circle","Wings","Figure8","Helix","Star","Wave","Sphere","DNA"}, Callback = function(v) orbitConfig.shape = v; if orbitConfig.enabled then orbitStart() end end })
WingsOrbitBox:AddToggle("OrbitUseAll", { Text = "Orbit: 全Part使用", Default = true, Callback = function(v) orbitConfig.useAllFound = v end })
WingsOrbitBox:AddSlider("OrbitCount", { Text = "Orbit: 使用数", Min = 1, Max = 50, Default = 8, Rounding = 0, Suffix = "個", Callback = function(v) orbitConfig.count = v end })
WingsOrbitBox:AddSlider("OrbitRadius", { Text = "Orbit: 半径", Min = 1, Max = 30, Default = 5, Rounding = 1, Callback = function(v) orbitConfig.radius = v end })
WingsOrbitBox:AddSlider("OrbitHeight", { Text = "Orbit: 高さ", Min = -10, Max = 15, Default = 0, Rounding = 1, Callback = function(v) orbitConfig.height = v end })
WingsOrbitBox:AddSlider("OrbitSpeed", { Text = "Orbit: 速度", Min = -10, Max = 10, Default = 1, Rounding = 1, Callback = function(v) orbitConfig.speed = v end })
WingsOrbitBox:AddSlider("OrbitScale", { Text = "Orbit: スケール", Min = 0.1, Max = 5, Default = 1, Rounding = 1, Suffix = "x", Callback = function(v) orbitConfig.scale = v end })
WingsOrbitBox:AddSlider("OrbitYRot", { Text = "Orbit: Y軸オフセット", Min = -180, Max = 180, Default = 0, Rounding = 0, Suffix = "°", Callback = function(v) orbitConfig.yRotation = v end })
WingsOrbitBox:AddSlider("OrbitWaveAmp", { Text = "Orbit: 波振幅", Min = 0, Max = 10, Default = 2, Rounding = 1, Callback = function(v) orbitConfig.waveAmplitude = v end })
WingsOrbitBox:AddSlider("OrbitWaveFreq", { Text = "Orbit: 波周波数", Min = 1, Max = 10, Default = 2, Rounding = 1, Callback = function(v) orbitConfig.waveFrequency = v end })
WingsOrbitBox:AddSlider("OrbitHelix", { Text = "Orbit: 螺旋高さ", Min = 1, Max = 20, Default = 5, Rounding = 1, Callback = function(v) orbitConfig.helixHeight = v end })
WingsOrbitBox:AddSlider("OrbitStarPts", { Text = "Orbit: 星頂点数", Min = 3, Max = 12, Default = 5, Rounding = 0, Suffix = "点", Callback = function(v) orbitConfig.starPoints = v end })
WingsOrbitBox:AddSlider("OrbitStarInner", { Text = "Orbit: 星内半径", Min = 0.5, Max = 10, Default = 2, Rounding = 1, Callback = function(v) orbitConfig.starInnerRadius = v end })
WingsOrbitBox:AddToggle("OrbitFace", { Text = "Orbit: 中心を向く", Default = false, Callback = function(v) orbitConfig.faceCenter = v end })
WingsOrbitBox:AddButton({ Text = "Orbit: 再検索 & 再起動", Func = function()
    if orbitConfig.enabled then orbitStart()
    else local f = _findByName(orbitConfig.targetPartName); Notify("検索", #f .. "個発見", 3) end
end })

-- BallMagicLight セクション
local WingsBallBox = WingsTab:AddLeftGroupbox("✨ BallMagicLight")

WingsBallBox:AddToggle("BallEnabled", {
    Text = "Ball: 有効化", Default = false,
    Callback = function(v)
        ballConfig.enabled = v
        if v then ballStart()
        else ballStop(); Notify("Ball停止", "停止しました", 2) end
    end
})

WingsBallBox:AddDropdown("BallMode", { Text = "Ball: モード", Default = "Wings", Values = {"Wings","Orbit"}, Callback = function(v) ballConfig.mode = v; if ballConfig.enabled then ballStart() end end })
WingsBallBox:AddInput("BallPartName", { Text = "Ball: 対象Part名", Default = "BallMagicLight", Numeric = false, Finished = false, Callback = function(v) ballConfig.targetPartName = v end })
WingsBallBox:AddToggle("BallUseAll", { Text = "Ball: 全Part使用", Default = true, Callback = function(v) ballConfig.useAllFound = v end })
WingsBallBox:AddSlider("BallCount", { Text = "Ball: 使用数", Min = 1, Max = 60, Default = 10, Rounding = 0, Suffix = "個", Callback = function(v) ballConfig.count = v end })
WingsBallBox:AddSlider("BallSpeed", { Text = "Ball: 速度", Min = -10, Max = 10, Default = 2.5, Rounding = 1, Callback = function(v) ballConfig.speed = v end })
WingsBallBox:AddSlider("BallHeight", { Text = "Ball: 高さ", Min = -5, Max = 15, Default = 1, Rounding = 1, Callback = function(v) ballConfig.height = v end })
WingsBallBox:AddSlider("BallSmooth", { Text = "Ball: 滑らかさ", Min = 0.01, Max = 1, Default = 0.15, Rounding = 2, Callback = function(v) ballConfig.smoothness = v end })
WingsBallBox:AddSlider("BallWingsSpacing", { Text = "Ball Wings: 間隔", Min = 0.3, Max = 5, Default = 1.2, Rounding = 1, Callback = function(v) ballConfig.wingsSpacing = v; if ballConfig.enabled and ballConfig.mode == "Wings" then ballRowPoints = ballCreateWingsPoints(#ballParts) end end })
WingsBallBox:AddSlider("BallWingsAmp", { Text = "Ball Wings: 振幅", Min = 0, Max = 10, Default = 2.5, Rounding = 1, Callback = function(v) ballConfig.wingsAmplitude = v end })
WingsBallBox:AddSlider("BallWingsPhase", { Text = "Ball Wings: 位相差", Min = 0, Max = 2, Default = 0.3, Rounding = 2, Callback = function(v) ballConfig.wingsPhaseOffset = v end })
WingsBallBox:AddSlider("BallWingsDist", { Text = "Ball Wings: 距離振幅増加", Min = 0, Max = 2, Default = 0.4, Rounding = 2, Callback = function(v) ballConfig.wingsDistMultiplier = v end })
WingsBallBox:AddSlider("BallWingsHoriz", { Text = "Ball Wings: 内側寄り", Min = 0, Max = 2, Default = 0.5, Rounding = 2, Callback = function(v) ballConfig.wingsHorizontalAmount = v end })
WingsBallBox:AddSlider("BallWingsFwd", { Text = "Ball Wings: 前方オフセット", Min = 0, Max = 15, Default = 3, Rounding = 1, Callback = function(v) ballConfig.wingsForwardOffset = v end })
WingsBallBox:AddSlider("BallWingsXRot", { Text = "Ball Wings: X軸回転", Min = -180, Max = 180, Default = -45, Rounding = 0, Suffix = "°", Callback = function(v) ballConfig.wingsXRot = v end })
WingsBallBox:AddSlider("BallWingsYRot", { Text = "Ball Wings: Y軸回転", Min = -180, Max = 180, Default = 0, Rounding = 0, Suffix = "°", Callback = function(v) ballConfig.wingsYRot = v end })
WingsBallBox:AddSlider("BallWingsZRot", { Text = "Ball Wings: Z軸回転", Min = -180, Max = 180, Default = 90, Rounding = 0, Suffix = "°", Callback = function(v) ballConfig.wingsZRot = v end })
WingsBallBox:AddButton({ Text = "Ball Wings: 回転リセット", Func = function()
    ballConfig.wingsXRot = -45; ballConfig.wingsYRot = 0; ballConfig.wingsZRot = 90
    Notify("リセット", "Wings回転リセット", 2)
end })

local WingsBallOrbitBox = WingsTab:AddRightGroupbox("✨ BallMagicLight Orbit設定")
WingsBallOrbitBox:AddDropdown("BallOrbitShape", { Text = "Ball Orbit: 形状", Default = "Circle", Values = {"Circle","Figure8","Wave","Helix","Star","Sphere","DNA"}, Callback = function(v) ballConfig.orbitShape = v end })
WingsBallOrbitBox:AddSlider("BallOrbitRadius", { Text = "Ball Orbit: 半径", Min = 1, Max = 30, Default = 5, Rounding = 1, Callback = function(v) ballConfig.orbitRadius = v end })
WingsBallOrbitBox:AddSlider("BallOrbitScale", { Text = "Ball Orbit: スケール", Min = 0.1, Max = 5, Default = 1, Rounding = 1, Suffix = "x", Callback = function(v) ballConfig.orbitScale = v end })
WingsBallOrbitBox:AddSlider("BallOrbitYRot", { Text = "Ball Orbit: Y軸オフセット", Min = -180, Max = 180, Default = 0, Rounding = 0, Suffix = "°", Callback = function(v) ballConfig.orbitYRotOffset = v end })
WingsBallOrbitBox:AddSlider("BallOrbitWaveAmp", { Text = "Ball Orbit: 波振幅", Min = 0, Max = 10, Default = 2, Rounding = 1, Callback = function(v) ballConfig.orbitWaveAmplitude = v end })
WingsBallOrbitBox:AddSlider("BallOrbitWaveFreq", { Text = "Ball Orbit: 波周波数", Min = 1, Max = 10, Default = 2, Rounding = 1, Callback = function(v) ballConfig.orbitWaveFrequency = v end })
WingsBallOrbitBox:AddSlider("BallOrbitHelix", { Text = "Ball Orbit: 螺旋高さ", Min = 1, Max = 20, Default = 5, Rounding = 1, Callback = function(v) ballConfig.orbitHelixHeight = v end })
WingsBallOrbitBox:AddSlider("BallOrbitStarPts", { Text = "Ball Orbit: 星頂点数", Min = 3, Max = 12, Default = 5, Rounding = 0, Suffix = "点", Callback = function(v) ballConfig.orbitStarPoints = v end })
WingsBallOrbitBox:AddSlider("BallOrbitStarInner", { Text = "Ball Orbit: 星内半径", Min = 0.5, Max = 10, Default = 2, Rounding = 1, Callback = function(v) ballConfig.orbitStarInnerRadius = v end })
WingsBallOrbitBox:AddToggle("BallFaceCenter", { Text = "Ball Orbit: 中心を向く", Default = false, Callback = function(v) ballConfig.orbitFaceCenter = v end })
WingsBallOrbitBox:AddButton({ Text = "Ball: 再検索 & 再起動", Func = function()
    if ballConfig.enabled then ballStart()
    else local f = _findByName(ballConfig.targetPartName); Notify("検索", #f .. "個発見", 3) end
end })

-- YouDecoy
local ydBallConfig = {
    mode = "Wings", enabled = false, targetPartName = "YouDecoy",
    count = 10, useAllFound = true, speed = 2.5, height = 1, smoothness = 0.15,
    wingsSpacing = 1.2, wingsAmplitude = 2.5, wingsPhaseOffset = 0.3,
    wingsDistMultiplier = 0.4, wingsHorizontalAmount = 0.5, wingsForwardOffset = 3,
    wingsXRot = -45, wingsYRot = 0, wingsZRot = 90,
    orbitShape = "Circle", orbitRadius = 5, orbitScale = 1, orbitYRotOffset = 0,
    orbitWaveAmplitude = 2, orbitWaveFrequency = 2, orbitHelixHeight = 5,
    orbitStarPoints = 5, orbitStarInnerRadius = 2, orbitFaceCenter = false,
}
local ydBallParts = {}
local ydBallRowPoints = {}
local ydBallTime = 0
local ydBallConnection = nil

local function ydBallCreateWingsPoints(count)
    local points = {}
    if count == 0 then return points end
    local half = math.floor(count / 2)
    local isOdd = count % 2 == 1
    local idx = 1
    if isOdd then table.insert(points, { baseOffsetX = 0, index = idx }); idx += 1 end
    for i = 1, half do
        local off = i * ydBallConfig.wingsSpacing
        table.insert(points, { baseOffsetX = off, index = idx }); idx += 1
        table.insert(points, { baseOffsetX = -off, index = idx }); idx += 1
    end
    return points
end

local function ydBallGetOrbitPos(index, total, t, charPos, charCF)
    local angle = (index - 1) / total * math.pi * 2
    local r = ydBallConfig.orbitRadius * ydBallConfig.orbitScale
    local x, y, z = 0, ydBallConfig.height, 0
    local shape = ydBallConfig.orbitShape
    if shape == "Circle" then local a = angle + t * ydBallConfig.speed; x = math.cos(a) * r; z = math.sin(a) * r; y = ydBallConfig.height
    elseif shape == "Figure8" then local a = t * ydBallConfig.speed + angle; x = math.sin(a) * r; z = math.sin(a * 2) * r * 0.5; y = ydBallConfig.height
    elseif shape == "Wave" then local a = angle + t * ydBallConfig.speed; x = math.cos(a) * r; z = math.sin(a) * r; y = ydBallConfig.height + math.sin(a * ydBallConfig.orbitWaveFrequency + t * ydBallConfig.speed) * ydBallConfig.orbitWaveAmplitude
    elseif shape == "Helix" then local a = angle + t * ydBallConfig.speed; x = math.cos(a) * r; z = math.sin(a) * r; local prog = ((t * ydBallConfig.speed * 0.3) % 1); y = ydBallConfig.height + (prog * ydBallConfig.orbitHelixHeight) - (ydBallConfig.orbitHelixHeight / 2); y = y + (index / total) * ydBallConfig.orbitHelixHeight
    elseif shape == "Star" then local pts = ydBallConfig.orbitStarPoints; local innerR = ydBallConfig.orbitStarInnerRadius * ydBallConfig.orbitScale; local a = angle + t * ydBallConfig.speed; local pA = (math.pi * 2) / pts; local blend = (a % pA) / pA; local dist = innerR + (r - innerR) * math.abs(math.sin(blend * math.pi)); x = math.cos(a) * dist; z = math.sin(a) * dist; y = ydBallConfig.height
    elseif shape == "Sphere" then local theta = (index / total) * math.pi + t * ydBallConfig.speed * 0.3; x = r * math.sin(theta) * math.cos(angle + t * ydBallConfig.speed); z = r * math.sin(theta) * math.sin(angle + t * ydBallConfig.speed); y = ydBallConfig.height + r * math.cos(theta)
    elseif shape == "DNA" then local a = angle + t * ydBallConfig.speed; local strand = (index % 2 == 0) and 1 or -1; x = math.cos(a + strand * math.pi) * r; z = math.sin(a + strand * math.pi) * r * 0.3; y = ydBallConfig.height + (a / (math.pi * 2)) * ydBallConfig.orbitHelixHeight * 0.5
    end
    local yOff = math.rad(ydBallConfig.orbitYRotOffset)
    local rx = x * math.cos(yOff) - z * math.sin(yOff); local rz = x * math.sin(yOff) + z * math.cos(yOff); x, z = rx, rz
    local _, cYR, _ = charCF:ToOrientation()
    return charPos + Vector3.new(x * math.cos(cYR) - z * math.sin(cYR), y, x * math.sin(cYR) + z * math.cos(cYR))
end

local function ydBallStop()
    if ydBallConnection then ydBallConnection:Disconnect(); ydBallConnection = nil end
    for _, obj in ipairs(ydBallParts) do
        if obj.BP and obj.BP.Parent then obj.BP:Destroy() end
        if obj.BG and obj.BG.Parent then obj.BG:Destroy() end
        if obj.Part and obj.Part.Parent then obj.Part.Anchored = true end
    end
    ydBallParts = {}; ydBallRowPoints = {}
end

local function ydBallStart()
    ydBallStop()
    local found = _findByName(ydBallConfig.targetPartName)
    if #found == 0 then Notify("エラー", "'" .. ydBallConfig.targetPartName .. "' が見つかりません", 3); return end
    local useCount = ydBallConfig.useAllFound and #found or math.min(ydBallConfig.count, #found)
    for i = 1, useCount do local obj = _setupObj(found[i]); if obj then table.insert(ydBallParts, obj) end end
    if ydBallConfig.mode == "Wings" then ydBallRowPoints = ydBallCreateWingsPoints(#ydBallParts) end
    Notify("YouDecoy 起動", "モード: " .. ydBallConfig.mode .. " / 数: " .. #ydBallParts, 2)
    ydBallTime = 0
    ydBallConnection = RunService.RenderStepped:Connect(function(dt)
        if not ydBallConfig.enabled then return end
        local char = LocalPlayer.Character; if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart"); local torso = char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
        if not hrp or not torso then return end
        ydBallTime += dt * ydBallConfig.speed
        local charCF = hrp.CFrame; local total = #ydBallParts
        if ydBallConfig.mode == "Wings" then
            local basePos = torso.Position + Vector3.new(0, ydBallConfig.height, 0) + charCF.LookVector * ydBallConfig.wingsForwardOffset
            for i, obj in ipairs(ydBallParts) do
                if obj.BP and obj.BP.Parent and obj.BG and obj.BG.Parent then
                    local pt = ydBallRowPoints[i]; if not pt then continue end
                    local dist2 = math.abs(pt.baseOffsetX)
                    local amp = ydBallConfig.wingsAmplitude + dist2 * ydBallConfig.wingsDistMultiplier
                    local wave = math.sin(ydBallTime + pt.index * ydBallConfig.wingsPhaseOffset)
                    local hOff = pt.baseOffsetX
                    if pt.baseOffsetX ~= 0 then local sign = pt.baseOffsetX > 0 and 1 or -1; hOff = pt.baseOffsetX - sign * math.abs(pt.baseOffsetX) * wave * ydBallConfig.wingsHorizontalAmount end
                    local targetPos = basePos + charCF.RightVector * hOff + Vector3.new(0, wave * amp, 0)
                    obj.BP.Position = obj.BP.Position + (targetPos - obj.BP.Position) * ydBallConfig.smoothness
                    local cf = CFrame.new(targetPos); local _, pYR, _ = charCF:ToOrientation()
                    cf = cf * CFrame.Angles(0, pYR + math.rad(ydBallConfig.wingsYRot), 0) * CFrame.Angles(math.rad(ydBallConfig.wingsXRot), 0, 0) * CFrame.Angles(0, 0, math.rad(ydBallConfig.wingsZRot))
                    obj.BG.CFrame = obj.BG.CFrame:Lerp(cf, ydBallConfig.smoothness)
                end
            end
        elseif ydBallConfig.mode == "Orbit" then
            for i, obj in ipairs(ydBallParts) do
                if obj.BP and obj.BP.Parent and obj.BG and obj.BG.Parent then
                    local pos = ydBallGetOrbitPos(i, total, ydBallTime, hrp.Position, charCF)
                    obj.BP.Position = obj.BP.Position + (pos - obj.BP.Position) * ydBallConfig.smoothness
                    if ydBallConfig.orbitFaceCenter then obj.BG.CFrame = obj.BG.CFrame:Lerp(CFrame.lookAt(pos, hrp.Position), 0.2) end
                end
            end
        end
    end)
end

local WingsYDBox = WingsTab:AddLeftGroupbox("🪤 YouDecoy")
WingsYDBox:AddToggle("YDEnabled", { Text = "YD: 有効化", Default = false, Callback = function(v) ydBallConfig.enabled = v; if v then ydBallStart() else ydBallStop(); Notify("YD停止", "停止しました", 2) end end })
WingsYDBox:AddDropdown("YDMode", { Text = "YD: モード", Default = "Wings", Values = {"Wings","Orbit"}, Callback = function(v) ydBallConfig.mode = v; if ydBallConfig.enabled then ydBallStart() end end })
WingsYDBox:AddInput("YDPartName", { Text = "YD: 対象Part名", Default = "YouDecoy", Numeric = false, Finished = false, Callback = function(v) ydBallConfig.targetPartName = v end })
WingsYDBox:AddToggle("YDUseAll", { Text = "YD: 全Part使用", Default = true, Callback = function(v) ydBallConfig.useAllFound = v end })
WingsYDBox:AddSlider("YDCount", { Text = "YD: 使用数", Min = 1, Max = 60, Default = 10, Rounding = 0, Suffix = "体", Callback = function(v) ydBallConfig.count = v end })
WingsYDBox:AddSlider("YDSpeed", { Text = "YD: 速度", Min = -10, Max = 10, Default = 2.5, Rounding = 1, Callback = function(v) ydBallConfig.speed = v end })
WingsYDBox:AddSlider("YDHeight", { Text = "YD: 高さ", Min = -5, Max = 15, Default = 1, Rounding = 1, Callback = function(v) ydBallConfig.height = v end })
WingsYDBox:AddSlider("YDSmooth", { Text = "YD: 滑らかさ", Min = 0.01, Max = 1, Default = 0.15, Rounding = 2, Callback = function(v) ydBallConfig.smoothness = v end })
WingsYDBox:AddSlider("YDWingsSpacing", { Text = "YD Wings: 間隔", Min = 0.3, Max = 5, Default = 1.2, Rounding = 1, Callback = function(v) ydBallConfig.wingsSpacing = v; if ydBallConfig.enabled and ydBallConfig.mode == "Wings" then ydBallRowPoints = ydBallCreateWingsPoints(#ydBallParts) end end })
WingsYDBox:AddSlider("YDWingsAmp", { Text = "YD Wings: 振幅", Min = 0, Max = 10, Default = 2.5, Rounding = 1, Callback = function(v) ydBallConfig.wingsAmplitude = v end })
WingsYDBox:AddSlider("YDWingsPhase", { Text = "YD Wings: 位相差", Min = 0, Max = 2, Default = 0.3, Rounding = 2, Callback = function(v) ydBallConfig.wingsPhaseOffset = v end })
WingsYDBox:AddSlider("YDWingsDist", { Text = "YD Wings: 距離振幅増加", Min = 0, Max = 2, Default = 0.4, Rounding = 2, Callback = function(v) ydBallConfig.wingsDistMultiplier = v end })
WingsYDBox:AddSlider("YDWingsHoriz", { Text = "YD Wings: 内側寄り", Min = 0, Max = 2, Default = 0.5, Rounding = 2, Callback = function(v) ydBallConfig.wingsHorizontalAmount = v end })
WingsYDBox:AddSlider("YDWingsFwd", { Text = "YD Wings: 前方オフセット", Min = 0, Max = 15, Default = 3, Rounding = 1, Callback = function(v) ydBallConfig.wingsForwardOffset = v end })
WingsYDBox:AddSlider("YDWingsXRot", { Text = "YD Wings: X軸回転", Min = -180, Max = 180, Default = -45, Rounding = 0, Suffix = "°", Callback = function(v) ydBallConfig.wingsXRot = v end })
WingsYDBox:AddSlider("YDWingsYRot", { Text = "YD Wings: Y軸回転", Min = -180, Max = 180, Default = 0, Rounding = 0, Suffix = "°", Callback = function(v) ydBallConfig.wingsYRot = v end })
WingsYDBox:AddSlider("YDWingsZRot", { Text = "YD Wings: Z軸回転", Min = -180, Max = 180, Default = 90, Rounding = 0, Suffix = "°", Callback = function(v) ydBallConfig.wingsZRot = v end })
WingsYDBox:AddButton({ Text = "YD Wings: 回転リセット", Func = function() ydBallConfig.wingsXRot = -45; ydBallConfig.wingsYRot = 0; ydBallConfig.wingsZRot = 90; Notify("リセット", "Wings回転リセット", 2) end })

local WingsYDOrbitBox = WingsTab:AddRightGroupbox("🪤 YouDecoy Orbit設定")
WingsYDOrbitBox:AddDropdown("YDOrbitShape", { Text = "YD Orbit: 形状", Default = "Circle", Values = {"Circle","Figure8","Wave","Helix","Star","Sphere","DNA"}, Callback = function(v) ydBallConfig.orbitShape = v end })
WingsYDOrbitBox:AddSlider("YDOrbitRadius", { Text = "YD Orbit: 半径", Min = 1, Max = 30, Default = 5, Rounding = 1, Callback = function(v) ydBallConfig.orbitRadius = v end })
WingsYDOrbitBox:AddSlider("YDOrbitScale", { Text = "YD Orbit: スケール", Min = 0.1, Max = 5, Default = 1, Rounding = 1, Suffix = "x", Callback = function(v) ydBallConfig.orbitScale = v end })
WingsYDOrbitBox:AddSlider("YDOrbitYRot", { Text = "YD Orbit: Y軸オフセット", Min = -180, Max = 180, Default = 0, Rounding = 0, Suffix = "°", Callback = function(v) ydBallConfig.orbitYRotOffset = v end })
WingsYDOrbitBox:AddSlider("YDOrbitWaveAmp", { Text = "YD Orbit: 波振幅", Min = 0, Max = 10, Default = 2, Rounding = 1, Callback = function(v) ydBallConfig.orbitWaveAmplitude = v end })
WingsYDOrbitBox:AddSlider("YDOrbitWaveFreq", { Text = "YD Orbit: 波周波数", Min = 1, Max = 10, Default = 2, Rounding = 1, Callback = function(v) ydBallConfig.orbitWaveFrequency = v end })
WingsYDOrbitBox:AddSlider("YDOrbitHelix", { Text = "YD Orbit: 螺旋高さ", Min = 1, Max = 20, Default = 5, Rounding = 1, Callback = function(v) ydBallConfig.orbitHelixHeight = v end })
WingsYDOrbitBox:AddSlider("YDOrbitStarPts", { Text = "YD Orbit: 星頂点数", Min = 3, Max = 12, Default = 5, Rounding = 0, Suffix = "点", Callback = function(v) ydBallConfig.orbitStarPoints = v end })
WingsYDOrbitBox:AddSlider("YDOrbitStarInner", { Text = "YD Orbit: 星内半径", Min = 0.5, Max = 10, Default = 2, Rounding = 1, Callback = function(v) ydBallConfig.orbitStarInnerRadius = v end })
WingsYDOrbitBox:AddToggle("YDFaceCenter", { Text = "YD Orbit: 中心を向く", Default = false, Callback = function(v) ydBallConfig.orbitFaceCenter = v end })
WingsYDOrbitBox:AddButton({ Text = "YD: 再検索 & 再起動", Func = function()
    if ydBallConfig.enabled then ydBallStart()
    else local f = _findByName(ydBallConfig.targetPartName); Notify("検索", #f .. "体発見", 3) end
end })

-- SpotlightBlue
local sbConfig = {
    enabled = false, targetPlayer = nil, targetPartName = "SpotlightBlue",
    maxSpotlights = 20, spacing = 1.2, heightOffset = 1, forwardOffset = 4,
    waveSpeed = 2.5, baseAmplitude = 2, distanceMultiplier = 0.4, phaseOffset = 0.3,
    horizontalWaveAmount = 0.5, smoothness = 0.6, xRotation = -45, yRotation = 0, zRotation = 90,
}
local sbToys = {}
local sbRowPoints = {}
local sbAssigned = {}
local sbTime = 0

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

local function sbCP()
    local p = Instance.new("Part"); p.CanCollide = false; p.Anchored = true; p.Transparency = 1
    p.Size = Vector3.new(4, 1, 4); p.Parent = workspace; return p
end

local function sbCBM(part)
    if not part then return nil, nil end
    local eBG = part:FindFirstChildOfClass("BodyGyro"); local eBP = part:FindFirstChildOfClass("BodyPosition")
    if eBG and eBP then return eBG, eBP end
    if eBG then eBG:Destroy() end; if eBP then eBP:Destroy() end
    local BP = Instance.new("BodyPosition"); BP.P = 25000; BP.D = 800; BP.MaxForce = Vector3.new(1, 1, 1) * 1e10; BP.Parent = part
    local BG = Instance.new("BodyGyro"); BG.P = 25000; BG.D = 800; BG.MaxTorque = Vector3.new(1, 1, 1) * 1e10; BG.Parent = part
    return BG, BP
end

local function sbGetPrimary(model)
    if model.PrimaryPart then return model.PrimaryPart end
    for _, n in ipairs({"Handle", "Main", "Part", "Base", "Spotlight", "Light"}) do
        local p = model:FindFirstChild(n); if p and p:IsA("BasePart") then return p end
    end
    for _, c in ipairs(model:GetChildren()) do if c:IsA("BasePart") then return c end end
    return nil
end

local function sbCreateRowPoints(count)
    local points = {}; if count == 0 then return points end
    local half = math.floor(count / 2); local isOdd = count % 2 == 1; local idx = 1
    if isOdd then table.insert(points, { baseOffsetX = 0, part = sbCP(), index = idx }); idx += 1 end
    for i = 1, half do
        local off = i * sbConfig.spacing
        table.insert(points, { baseOffsetX = off, part = sbCP(), index = idx }); idx += 1
        table.insert(points, { baseOffsetX = -off, part = sbCP(), index = idx }); idx += 1
    end
    return points
end

local function sbDisable()
    for _, point in ipairs(sbRowPoints) do
        if point.assignedToy and point.assignedToy.Pallet then
            if point.assignedToy.BP then point.assignedToy.BP:Destroy(); point.assignedToy.BP = nil end
            if point.assignedToy.BG then point.assignedToy.BG:Destroy(); point.assignedToy.BG = nil end
            for _, c in ipairs(point.assignedToy.Model:GetChildren()) do
                if c:IsA("BasePart") then c.Anchored = true; c.Velocity = Vector3.new(0, 0, 0); c.RotVelocity = Vector3.new(0, 0, 0) end
            end
        end
    end
end

local function sbEnable()
    for _, point in ipairs(sbRowPoints) do
        if point.assignedToy and point.assignedToy.Pallet then
            for _, c in ipairs(point.assignedToy.Model:GetChildren()) do if c:IsA("BasePart") then c.Anchored = false end end
            local BG, BP = sbCBM(point.assignedToy.Pallet); point.assignedToy.BG = BG; point.assignedToy.BP = BP
        end
    end
end

local function sbAssignToPoints()
    local assigned = {}
    local character = _getTargetChar(sbConfig.targetPlayer); if not character then return assigned end
    local hrp = character:FindFirstChild("HumanoidRootPart"); local torso = character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso")
    if not hrp or not torso then return assigned end
    local charCF = hrp.CFrame
    local basePos = torso.Position + Vector3.new(0, sbConfig.heightOffset, 0) + charCF.LookVector * sbConfig.forwardOffset
    for i = 1, math.min(#sbToys, #sbRowPoints) do
        local toy = sbToys[i]
        if toy and toy:IsA("Model") and toy.Name == sbConfig.targetPartName then
            local primary = sbGetPrimary(toy)
            if primary then
                for _, c in ipairs(toy:GetChildren()) do if c:IsA("BasePart") then c.CanCollide = false; c.CanTouch = false; c.Anchored = false end end
                local BG, BP = sbCBM(primary)
                local initPos = basePos + charCF.RightVector * sbRowPoints[i].baseOffsetX
                local t = { BG = BG, BP = BP, Pallet = primary, Model = toy, offsetX = sbRowPoints[i].baseOffsetX, baseOffsetX = sbRowPoints[i].baseOffsetX, index = sbRowPoints[i].index }
                if BP then BP.Position = initPos end
                if BG then
                    local cf = CFrame.new(initPos); local _, pYR, _ = charCF:ToOrientation()
                    cf = cf * CFrame.Angles(0, pYR + math.rad(sbConfig.yRotation), 0) * CFrame.Angles(math.rad(sbConfig.xRotation), 0, 0) * CFrame.Angles(0, 0, math.rad(sbConfig.zRotation))
                    BG.CFrame = cf
                end
                sbRowPoints[i].assignedToy = t; table.insert(assigned, t)
            end
        end
    end
    return assigned
end

local function sbRefresh()
    sbToys = sbFindSpotlights()
    sbRowPoints = sbCreateRowPoints(math.min(#sbToys, sbConfig.maxSpotlights))
    sbAssigned = sbAssignToPoints()
end

sbRefresh()
workspace.DescendantAdded:Connect(function(d)
    if d:IsA("Model") and d.Name == sbConfig.targetPartName then task.wait(0.5); sbRefresh() end
end)

RunService.RenderStepped:Connect(function(dt)
    if not sbConfig.enabled then return end
    local character = _getTargetChar(sbConfig.targetPlayer); if not character then return end
    local torso = character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso")
    local hrp = character:FindFirstChild("HumanoidRootPart"); if not torso or not hrp then return end
    sbTime += dt * sbConfig.waveSpeed
    local charCF = hrp.CFrame
    local basePos = torso.Position + Vector3.new(0, sbConfig.heightOffset, 0) + charCF.LookVector * sbConfig.forwardOffset
    for _, point in ipairs(sbRowPoints) do
        if point.assignedToy and point.assignedToy.BP and point.assignedToy.BG then
            local toy = point.assignedToy; local dist = math.abs(toy.baseOffsetX)
            local amp = sbConfig.baseAmplitude + dist * sbConfig.distanceMultiplier
            local wave = math.sin(sbTime + toy.index * sbConfig.phaseOffset)
            local hOff = toy.baseOffsetX
            if toy.baseOffsetX ~= 0 then local sign = toy.baseOffsetX > 0 and 1 or -1; hOff = toy.baseOffsetX - sign * math.abs(toy.baseOffsetX) * wave * sbConfig.horizontalWaveAmount end
            local finalPos = basePos + charCF.RightVector * hOff + Vector3.new(0, wave * amp, 0)
            if point.part then point.part.Position = finalPos end
            toy.BP.Position = finalPos
            local cf = CFrame.new(finalPos); local _, pYR, _ = charCF:ToOrientation()
            cf = cf * CFrame.Angles(0, pYR + math.rad(sbConfig.yRotation), 0) * CFrame.Angles(math.rad(sbConfig.xRotation), 0, 0) * CFrame.Angles(0, 0, math.rad(sbConfig.zRotation))
            toy.BG.CFrame = toy.BG.CFrame:Lerp(cf, sbConfig.smoothness)
        end
    end
end)

local WingsSBBox = WingsTab:AddLeftGroupbox("💙 SpotlightBlue")
WingsSBBox:AddToggle("SBEnabled", { Text = "SB: 有効化", Default = false, Callback = function(v) sbConfig.enabled = v; if v then sbEnable(); Notify("SB ON", "SpotlightBlue 起動", 2) else sbDisable(); Notify("SB OFF", "SpotlightBlue 固定", 2) end end })

local sbPlayerDropdown
sbPlayerDropdown = WingsSBBox:AddDropdown("SBPlayer", { Text = "SB: 対象プレイヤー", Default = "自分", Values = fwGetPlayerList(), Callback = function(v)
    if v == "自分" then sbConfig.targetPlayer = nil else sbConfig.targetPlayer = Players:FindFirstChild(v) end
    sbAssigned = sbAssignToPoints()
end })

WingsSBBox:AddButton({ Text = "SB: プレイヤーリスト更新", Func = function() sbPlayerDropdown:SetValues(fwGetPlayerList()); Notify("更新", "リスト更新完了", 2) end })
WingsSBBox:AddButton({ Text = "SB: SpotlightBlueを再検出", Func = function() sbRefresh(); Notify("再検出", "SpotlightBlue数: " .. #sbToys, 2) end })
WingsSBBox:AddSlider("SBMax", { Text = "SB: 最大数", Min = 2, Max = 40, Default = 20, Rounding = 0, Suffix = "本", Callback = function(v) sbConfig.maxSpotlights = v; sbRefresh() end })
WingsSBBox:AddSlider("SBSpacing", { Text = "SB: 間隔", Min = 0.5, Max = 5, Default = 1.2, Rounding = 1, Callback = function(v) sbConfig.spacing = v; sbRefresh() end })
WingsSBBox:AddSlider("SBHeight", { Text = "SB: 高さ", Min = -5, Max = 10, Default = 1, Rounding = 1, Callback = function(v) sbConfig.heightOffset = v end })
WingsSBBox:AddSlider("SBForward", { Text = "SB: 前方オフセット", Min = 0, Max = 15, Default = 4, Rounding = 1, Callback = function(v) sbConfig.forwardOffset = v end })
WingsSBBox:AddSlider("SBWaveSpeed", { Text = "SB: 波速度", Min = 0, Max = 10, Default = 2.5, Rounding = 1, Callback = function(v) sbConfig.waveSpeed = v end })
WingsSBBox:AddSlider("SBAmplitude", { Text = "SB: 振幅", Min = 0, Max = 10, Default = 2, Rounding = 1, Callback = function(v) sbConfig.baseAmplitude = v end })
WingsSBBox:AddSlider("SBPhase", { Text = "SB: 位相差", Min = 0, Max = 2, Default = 0.3, Rounding = 2, Callback = function(v) sbConfig.phaseOffset = v end })
WingsSBBox:AddSlider("SBHorizontal", { Text = "SB: 内側への寄り", Min = 0, Max = 2, Default = 0.5, Rounding = 2, Callback = function(v) sbConfig.horizontalWaveAmount = v end })
WingsSBBox:AddSlider("SBSmoothness", { Text = "SB: 滑らかさ", Min = 0.01, Max = 1, Default = 0.6, Rounding = 2, Callback = function(v) sbConfig.smoothness = v end })
WingsSBBox:AddSlider("SBXRot", { Text = "SB: X軸回転", Min = -180, Max = 180, Default = -45, Rounding = 0, Suffix = "°", Callback = function(v) sbConfig.xRotation = v end })
WingsSBBox:AddSlider("SBYRot", { Text = "SB: Y軸回転", Min = -180, Max = 180, Default = 0, Rounding = 0, Suffix = "°", Callback = function(v) sbConfig.yRotation = v end })
WingsSBBox:AddSlider("SBZRot", { Text = "SB: Z軸回転", Min = -180, Max = 180, Default = 90, Rounding = 0, Suffix = "°", Callback = function(v) sbConfig.zRotation = v end })
WingsSBBox:AddButton({ Text = "SB: 回転リセット", Func = function() sbConfig.xRotation = -45; sbConfig.yRotation = 0; sbConfig.zRotation = 90; Notify("リセット", "回転をデフォルトに戻しました", 2) end })

--==============================
-- タブ：Float & Orbit
--==============================
local function cf_findByName(name)
    local found = {}
    for _, item in ipairs(workspace:GetDescendants()) do
        if (item:IsA("BasePart") or item:IsA("Model")) and item.Name == name then table.insert(found, item) end
    end
    return found
end

local function cf_getBasePart(obj)
    if obj:IsA("Model") then return obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
    elseif obj:IsA("BasePart") then return obj end
    return nil
end

local function cf_setupMovers(part)
    if not part then return nil, nil end
    for _, c in ipairs({"BodyPosition", "BodyGyro"}) do local e = part:FindFirstChildOfClass(c); if e then e:Destroy() end end
    local BP = Instance.new("BodyPosition"); BP.P = 25000; BP.D = 800; BP.MaxForce = Vector3.new(1,1,1) * 1e10; BP.Parent = part
    local BG = Instance.new("BodyGyro"); BG.P = 25000; BG.D = 800; BG.MaxTorque = Vector3.new(1,1,1) * 1e10; BG.Parent = part
    return BP, BG
end

local function cf_setupObj(obj)
    local base = cf_getBasePart(obj); if not base then return nil end
    if obj:IsA("Model") then for _, c in ipairs(obj:GetDescendants()) do if c:IsA("BasePart") then c.CanCollide = false; c.CanTouch = false; c.Anchored = false end end
    else base.CanCollide = false; base.CanTouch = false; base.Anchored = false end
    local BP, BG = cf_setupMovers(base)
    return { BP = BP, BG = BG, Part = base, Original = obj }
end

local function cf_releaseObj(obj)
    if obj.BP and obj.BP.Parent then obj.BP:Destroy() end
    if obj.BG and obj.BG.Parent then obj.BG:Destroy() end
    if obj.Part and obj.Part.Parent then obj.Part.Anchored = true end
end

-- Campfire設定
local campConfig = {
    enabled = false, partName = "Campfire", orbitCount = 6, orbitRadius = 5, orbitSpeed = 1.2,
    orbitHeight = 0, orbitShape = "Circle", waveAmp = 1.5, waveFreq = 2, starPoints = 5, starInner = 2,
    headEnabled = true, headHeight = 3.5, headBobSpeed = 1.5, headBobAmp = 0.3,
    smoothness = 0.18, faceCenter = false, useAllFound = false,
}
local campOrbitObjs = {}
local campHeadObj = nil
local campTime = 0
local campConn = nil

local function campGetOrbitPos(index, total, t, charPos, charCF)
    local angle = (index - 1) / total * math.pi * 2
    local r = campConfig.orbitRadius; local x, y, z = 0, campConfig.orbitHeight, 0; local shape = campConfig.orbitShape
    if shape == "Circle" then local a = angle + t * campConfig.orbitSpeed; x = math.cos(a) * r; z = math.sin(a) * r
    elseif shape == "Wave" then local a = angle + t * campConfig.orbitSpeed; x = math.cos(a) * r; z = math.sin(a) * r; y = campConfig.orbitHeight + math.sin(a * campConfig.waveFreq + t * campConfig.orbitSpeed) * campConfig.waveAmp
    elseif shape == "Figure8" then local a = t * campConfig.orbitSpeed + angle; x = math.sin(a) * r; z = math.sin(a * 2) * r * 0.5
    elseif shape == "Star" then
        local pts = campConfig.starPoints; local innerR = campConfig.starInner
        local a = angle + t * campConfig.orbitSpeed; local pA = (math.pi * 2) / pts
        local blend = (a % pA) / pA; local dist2 = innerR + (r - innerR) * math.abs(math.sin(blend * math.pi))
        x = math.cos(a) * dist2; z = math.sin(a) * dist2
    end
    local _, cYR, _ = charCF:ToOrientation()
    local fx = x * math.cos(cYR) - z * math.sin(cYR); local fz = x * math.sin(cYR) + z * math.cos(cYR)
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
    if #found == 0 then Notify("エラー", "'" .. campConfig.partName .. "' が見つかりません", 3); return end
    local needed = campConfig.orbitCount + (campConfig.headEnabled and 1 or 0)
    local useCount = campConfig.useAllFound and #found or math.min(needed, #found)
    local headIdx = campConfig.headEnabled and useCount or nil
    local orbitEnd = headIdx and (useCount - 1) or useCount
    for i = 1, orbitEnd do local obj = cf_setupObj(found[i]); if obj then table.insert(campOrbitObjs, obj) end end
    if headIdx and found[headIdx] then campHeadObj = cf_setupObj(found[headIdx]) end
    Notify("Campfire 起動", "周回: " .. #campOrbitObjs .. "個" .. (campHeadObj and " / 頭上: 1個" or ""), 3)
    campTime = 0
    campConn = RunService.RenderStepped:Connect(function(dt)
        if not campConfig.enabled then return end
        local char = LocalPlayer.Character; if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart"); local head = char:FindFirstChild("Head"); if not hrp then return end
        campTime += dt
        local charPos = hrp.Position; local charCF = hrp.CFrame; local total = #campOrbitObjs
        for i, obj in ipairs(campOrbitObjs) do
            if obj.BP and obj.BP.Parent then
                local pos = campGetOrbitPos(i, total, campTime, charPos, charCF)
                obj.BP.Position = obj.BP.Position + (pos - obj.BP.Position) * campConfig.smoothness
                if campConfig.faceCenter and obj.BG and obj.BG.Parent then obj.BG.CFrame = obj.BG.CFrame:Lerp(CFrame.lookAt(pos, charPos), 0.2) end
            end
        end
        if campHeadObj and campHeadObj.BP and campHeadObj.BP.Parent then
            local headPos = (head and head.Position or charPos) + Vector3.new(0, campConfig.headHeight, 0)
            headPos = headPos + Vector3.new(0, math.sin(campTime * campConfig.headBobSpeed) * campConfig.headBobAmp, 0)
            campHeadObj.BP.Position = campHeadObj.BP.Position + (headPos - campHeadObj.BP.Position) * campConfig.smoothness
        end
    end)
end

-- BallMagicLight Float設定
local ballFConfig = {
    enabled = false, partName = "BallMagicLight", orbitCount = 8, orbitRadius = 5, orbitSpeed = 1.5,
    orbitHeight = 0, orbitShape = "Circle", waveAmp = 1.5, waveFreq = 2, starPoints = 5, starInner = 2,
    headEnabled = true, headHeight = 4, headBobSpeed = 2, headBobAmp = 0.4,
    smoothness = 0.18, faceCenter = false, useAllFound = false,
}
local ballFOrbitObjs = {}
local ballFHeadObj = nil
local ballFTime = 0
local ballFConn = nil

local function ballFGetOrbitPos(index, total, t, charPos, charCF)
    local angle = (index - 1) / total * math.pi * 2
    local r = ballFConfig.orbitRadius; local x, y, z = 0, ballFConfig.orbitHeight, 0; local shape = ballFConfig.orbitShape
    if shape == "Circle" then local a = angle + t * ballFConfig.orbitSpeed; x = math.cos(a) * r; z = math.sin(a) * r
    elseif shape == "Wave" then local a = angle + t * ballFConfig.orbitSpeed; x = math.cos(a) * r; z = math.sin(a) * r; y = ballFConfig.orbitHeight + math.sin(a * ballFConfig.waveFreq + t * ballFConfig.orbitSpeed) * ballFConfig.waveAmp
    elseif shape == "Figure8" then local a = t * ballFConfig.orbitSpeed + angle; x = math.sin(a) * r; z = math.sin(a * 2) * r * 0.5
    elseif shape == "Star" then
        local pts = ballFConfig.starPoints; local innerR = ballFConfig.starInner
        local a = angle + t * ballFConfig.orbitSpeed; local pA = (math.pi * 2) / pts
        local blend = (a % pA) / pA; local dist2 = innerR + (r - innerR) * math.abs(math.sin(blend * math.pi))
        x = math.cos(a) * dist2; z = math.sin(a) * dist2
    end
    local _, cYR, _ = charCF:ToOrientation()
    local fx = x * math.cos(cYR) - z * math.sin(cYR); local fz = x * math.sin(cYR) + z * math.cos(cYR)
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
    if #found == 0 then Notify("エラー", "'" .. ballFConfig.partName .. "' が見つかりません", 3); return end
    local needed = ballFConfig.orbitCount + (ballFConfig.headEnabled and 1 or 0)
    local useCount = ballFConfig.useAllFound and #found or math.min(needed, #found)
    local headIdx = ballFConfig.headEnabled and useCount or nil
    local orbitEnd = headIdx and (useCount - 1) or useCount
    for i = 1, orbitEnd do local obj = cf_setupObj(found[i]); if obj then table.insert(ballFOrbitObjs, obj) end end
    if headIdx and found[headIdx] then ballFHeadObj = cf_setupObj(found[headIdx]) end
    Notify("BallMagicLight 起動", "周回: " .. #ballFOrbitObjs .. "個" .. (ballFHeadObj and " / 頭上: 1個" or ""), 3)
    ballFTime = 0
    ballFConn = RunService.RenderStepped:Connect(function(dt)
        if not ballFConfig.enabled then return end
        local char = LocalPlayer.Character; if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart"); local head = char:FindFirstChild("Head"); if not hrp then return end
        ballFTime += dt
        local charPos = hrp.Position; local charCF = hrp.CFrame; local total = #ballFOrbitObjs
        for i, obj in ipairs(ballFOrbitObjs) do
            if obj.BP and obj.BP.Parent then
                local pos = ballFGetOrbitPos(i, total, ballFTime, charPos, charCF)
                obj.BP.Position = obj.BP.Position + (pos - obj.BP.Position) * ballFConfig.smoothness
                if ballFConfig.faceCenter and obj.BG and obj.BG.Parent then obj.BG.CFrame = obj.BG.CFrame:Lerp(CFrame.lookAt(pos, charPos), 0.2) end
            end
        end
        if ballFHeadObj and ballFHeadObj.BP and ballFHeadObj.BP.Parent then
            local headPos = (head and head.Position or charPos) + Vector3.new(0, ballFConfig.headHeight, 0)
            headPos = headPos + Vector3.new(0, math.sin(ballFTime * ballFConfig.headBobSpeed) * ballFConfig.headBobAmp, 0)
            ballFHeadObj.BP.Position = ballFHeadObj.BP.Position + (headPos - ballFHeadObj.BP.Position) * ballFConfig.smoothness
        end
    end)
end

local FloatTab = Window:AddTab("Float & Orbit", "orbit")

local FloatCampBox = FloatTab:AddLeftGroupbox("🔥 Campfire Orbit + 頭上")
FloatCampBox:AddToggle("CampEnabled", { Text = "Campfire: 有効化", Default = false, Callback = function(v) campConfig.enabled = v; if v then campStart() else campStop(); Notify("Campfire停止", "停止しました", 2) end end })
FloatCampBox:AddInput("CampPartName", { Text = "Campfire: Part名", Default = "Campfire", Numeric = false, Finished = false, Callback = function(v) campConfig.partName = v end })
FloatCampBox:AddButton({ Text = "Campfire: 再検索 & 再起動", Func = function() if campConfig.enabled then campStart() else local f = cf_findByName(campConfig.partName); Notify("検索", #f .. "個発見", 3) end end })
FloatCampBox:AddToggle("CampUseAll", { Text = "Campfire: 全Part使用", Default = false, Callback = function(v) campConfig.useAllFound = v end })
FloatCampBox:AddSlider("CampCount", { Text = "Campfire: 周回数", Min = 1, Max = 30, Default = 6, Rounding = 0, Suffix = "個", Callback = function(v) campConfig.orbitCount = v end })
FloatCampBox:AddDropdown("CampShape", { Text = "Campfire: 形状", Default = "Circle", Values = {"Circle","Wave","Figure8","Star"}, Callback = function(v) campConfig.orbitShape = v end })
FloatCampBox:AddSlider("CampRadius", { Text = "Campfire: 半径", Min = 1, Max = 30, Default = 5, Rounding = 1, Callback = function(v) campConfig.orbitRadius = v end })
FloatCampBox:AddSlider("CampSpeed", { Text = "Campfire: 回転速度", Min = -10, Max = 10, Default = 1.2, Rounding = 1, Callback = function(v) campConfig.orbitSpeed = v end })
FloatCampBox:AddSlider("CampHeight", { Text = "Campfire: 周回高さ", Min = -5, Max = 10, Default = 0, Rounding = 1, Callback = function(v) campConfig.orbitHeight = v end })
FloatCampBox:AddSlider("CampWaveAmp", { Text = "Campfire: 波振幅", Min = 0, Max = 5, Default = 1.5, Rounding = 1, Callback = function(v) campConfig.waveAmp = v end })
FloatCampBox:AddSlider("CampWaveFreq", { Text = "Campfire: 波周波数", Min = 1, Max = 10, Default = 2, Rounding = 1, Callback = function(v) campConfig.waveFreq = v end })
FloatCampBox:AddSlider("CampStarPts", { Text = "Campfire: 星頂点数", Min = 3, Max = 12, Default = 5, Rounding = 0, Suffix = "点", Callback = function(v) campConfig.starPoints = v end })
FloatCampBox:AddSlider("CampStarInner", { Text = "Campfire: 星内半径", Min = 0.5, Max = 10, Default = 2, Rounding = 1, Callback = function(v) campConfig.starInner = v end })
FloatCampBox:AddSlider("CampSmooth", { Text = "Campfire: 滑らかさ", Min = 0.01, Max = 1, Default = 0.18, Rounding = 2, Callback = function(v) campConfig.smoothness = v end })
FloatCampBox:AddToggle("CampFace", { Text = "Campfire: 中心を向く", Default = false, Callback = function(v) campConfig.faceCenter = v end })
FloatCampBox:AddToggle("CampHead", { Text = "Campfire: 頭上1個を有効化", Default = true, Callback = function(v) campConfig.headEnabled = v end })
FloatCampBox:AddSlider("CampHeadHeight", { Text = "Campfire: 頭上の高さ", Min = 1, Max = 10, Default = 3.5, Rounding = 1, Callback = function(v) campConfig.headHeight = v end })
FloatCampBox:AddSlider("CampHeadBobSpeed", { Text = "Campfire: 頭上ふわふわ速度", Min = 0, Max = 5, Default = 1.5, Rounding = 1, Callback = function(v) campConfig.headBobSpeed = v end })
FloatCampBox:AddSlider("CampHeadBobAmp", { Text = "Campfire: 頭上ふわふわ幅", Min = 0, Max = 2, Default = 0.3, Rounding = 2, Callback = function(v) campConfig.headBobAmp = v end })

local FloatBallBox = FloatTab:AddRightGroupbox("✨ BallMagicLight Orbit + 頭上")
FloatBallBox:AddToggle("BallFEnabled", { Text = "Ball: 有効化", Default = false, Callback = function(v) ballFConfig.enabled = v; if v then ballFStart() else ballFStop(); Notify("Ball停止", "停止しました", 2) end end })
FloatBallBox:AddInput("BallFPartName", { Text = "Ball: Part名", Default = "BallMagicLight", Numeric = false, Finished = false, Callback = function(v) ballFConfig.partName = v end })
FloatBallBox:AddButton({ Text = "Ball: 再検索 & 再起動", Func = function() if ballFConfig.enabled then ballFStart() else local f = cf_findByName(ballFConfig.partName); Notify("検索", #f .. "個発見", 3) end end })
FloatBallBox:AddToggle("BallFUseAll", { Text = "Ball: 全Part使用", Default = false, Callback = function(v) ballFConfig.useAllFound = v end })
FloatBallBox:AddSlider("BallFCount", { Text = "Ball: 周回数", Min = 1, Max = 30, Default = 8, Rounding = 0, Suffix = "個", Callback = function(v) ballFConfig.orbitCount = v end })
FloatBallBox:AddDropdown("BallFShape", { Text = "Ball: 形状", Default = "Circle", Values = {"Circle","Wave","Figure8","Star"}, Callback = function(v) ballFConfig.orbitShape = v end })
FloatBallBox:AddSlider("BallFRadius", { Text = "Ball: 半径", Min = 1, Max = 30, Default = 5, Rounding = 1, Callback = function(v) ballFConfig.orbitRadius = v end })
FloatBallBox:AddSlider("BallFSpeed", { Text = "Ball: 回転速度", Min = -10, Max = 10, Default = 1.5, Rounding = 1, Callback = function(v) ballFConfig.orbitSpeed = v end })
FloatBallBox:AddSlider("BallFHeight", { Text = "Ball: 周回高さ", Min = -5, Max = 10, Default = 0, Rounding = 1, Callback = function(v) ballFConfig.orbitHeight = v end })
FloatBallBox:AddSlider("BallFWaveAmp", { Text = "Ball: 波振幅", Min = 0, Max = 5, Default = 1.5, Rounding = 1, Callback = function(v) ballFConfig.waveAmp = v end })
FloatBallBox:AddSlider("BallFWaveFreq", { Text = "Ball: 波周波数", Min = 1, Max = 10, Default = 2, Rounding = 1, Callback = function(v) ballFConfig.waveFreq = v end })
FloatBallBox:AddSlider("BallFStarPts", { Text = "Ball: 星頂点数", Min = 3, Max = 12, Default = 5, Rounding = 0, Suffix = "点", Callback = function(v) ballFConfig.starPoints = v end })
FloatBallBox:AddSlider("BallFStarInner", { Text = "Ball: 星内半径", Min = 0.5, Max = 10, Default = 2, Rounding = 1, Callback = function(v) ballFConfig.starInner = v end })
FloatBallBox:AddSlider("BallFSmooth", { Text = "Ball: 滑らかさ", Min = 0.01, Max = 1, Default = 0.18, Rounding = 2, Callback = function(v) ballFConfig.smoothness = v end })
FloatBallBox:AddToggle("BallFFace", { Text = "Ball: 中心を向く", Default = false, Callback = function(v) ballFConfig.faceCenter = v end })
FloatBallBox:AddToggle("BallFHead", { Text = "Ball: 頭上1個を有効化", Default = true, Callback = function(v) ballFConfig.headEnabled = v end })
FloatBallBox:AddSlider("BallFHeadHeight", { Text = "Ball: 頭上の高さ", Min = 1, Max = 10, Default = 4, Rounding = 1, Callback = function(v) ballFConfig.headHeight = v end })
FloatBallBox:AddSlider("BallFHeadBobSpeed", { Text = "Ball: 頭上ふわふわ速度", Min = 0, Max = 5, Default = 2, Rounding = 1, Callback = function(v) ballFConfig.headBobSpeed = v end })
FloatBallBox:AddSlider("BallFHeadBobAmp", { Text = "Ball: 頭上ふわふわ幅", Min = 0, Max = 2, Default = 0.4, Rounding = 2, Callback = function(v) ballFConfig.headBobAmp = v end })

--==============================
-- タブ：アンチグッチ
--==============================
local Players2 = game:GetService("Players")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local Workspace2 = game:GetService("Workspace")
local RunService2 = game:GetService("RunService")
local AG_LocalPlayer = Players2.LocalPlayer

local function ag_getLocalChar() return AG_LocalPlayer.Character end
local function ag_getLocalRoot()
    local char = ag_getLocalChar(); if not char then return nil end
    return char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso")
end
local function ag_getLocalHum()
    local char = ag_getLocalChar(); if not char then return nil end
    return char:FindFirstChildOfClass("Humanoid")
end
local function ag_getInv() return Workspace2:FindFirstChild(AG_LocalPlayer.Name .. "SpawnedInToys") end

local function ag_spawntoy(name, cframe)
    local toy = ReplicatedStorage2.MenuToys.SpawnToyRemoteFunction:InvokeServer(name, cframe, Vector3.zero)
    if toy and ag_getInv() then return ag_getInv():FindFirstChild(name) end
    return nil
end

local function ag_destroyToy(model) ReplicatedStorage2.MenuToys.DestroyToy:FireServer(model) end

local function ag_ragdoll()
    local root = ag_getLocalRoot()
    if root then ReplicatedStorage2.CharacterEvents.RagdollRemote:FireServer(root, 0) end
end

local AG_Enabled = false
local AG_Blob = nil
local AG_Conn = nil
local AG_lastCheck = 0

local function ag_turnOn()
    AG_Enabled = true
    task.spawn(function()
        repeat task.wait() until ag_getLocalChar() and ag_getLocalRoot() and ag_getLocalHum()
        local pos = ag_getLocalRoot().CFrame
        local blob = ag_spawntoy("CreatureBlobman", ag_getLocalRoot().CFrame)
        AG_Blob = blob
        if blob then
            local head = blob:FindFirstChild("Head")
            if head then head.CFrame = CFrame.new(1e5, 1e5, 1e5); head.Anchored = true end
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

local function ag_turnOff()
    AG_Enabled = false
    if AG_Blob then ag_destroyToy(AG_Blob); AG_Blob = nil end
end

AG_Conn = RunService2.Heartbeat:Connect(function(deltaTime)
    if AG_Enabled then
        local hum = ag_getLocalHum()
        if hum then ag_ragdoll() end
        if AG_Blob then
            if not AG_Blob.Parent then
                AG_Blob = nil
                task.spawn(function()
                    task.wait(0.5)
                    if AG_Enabled then
                        ag_turnOff(); task.wait(0.5); ag_turnOn()
                        Notify("アンチグッチ", "ブロブが消えたため再起動しました", 2)
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
                        if head then head.CFrame = CFrame.new(1e5, 1e5, 1e5); head.Anchored = true end
                    else
                        task.spawn(function()
                            ag_turnOff(); task.wait(0.5)
                            if AG_Enabled then ag_turnOn(); Notify("アンチグッチ", "ブロブを再生成しました", 2) end
                        end)
                    end
                end
            end
        end
    end
end)

AG_LocalPlayer.CharacterRemoving:Connect(function()
    if AG_Blob then ag_destroyToy(AG_Blob); AG_Blob = nil end
    AG_Enabled = false
end)

AG_LocalPlayer.CharacterAdded:Connect(function()
    task.wait(2)
    if AG_Enabled then
        AG_Blob = nil
        task.spawn(function()
            task.wait(1)
            if AG_Enabled then ag_turnOn() end
        end)
    end
end)

local AntiGucciTab = Window:AddTab("アンチグッチ", "shield")
local AntiGucciBox = AntiGucciTab:AddLeftGroupbox("アンチグッチ制御")

AntiGucciBox:AddToggle("AntiGucciEnabled", {
    Text = "アンチグッチ 有効化",
    Default = false,
    Callback = function(Value)
        if Value then
            ag_turnOn()
            Notify("アンチグッチ", "有効化しました", 2)
        else
            ag_turnOff()
            Notify("アンチグッチ", "無効化しました", 2)
        end
    end
})

AntiGucciBox:AddButton({
    Text = "手動でブロブを再起動",
    Func = function()
        ag_turnOff(); task.wait(0.5)
        if AG_Enabled then
            ag_turnOn(); Notify("アンチグッチ", "ブロブを再起動しました", 2)
        else
            Notify("アンチグッチ", "先にトグルをONにしてください", 2)
        end
    end
})

AntiGucciBox:AddButton({
    Text = "強制停止 & ブロブ削除",
    Func = function()
        ag_turnOff(); AG_Enabled = false
        Notify("アンチグッチ", "強制停止しました", 2)
    end
})

local AntiGucciInfoBox = AntiGucciTab:AddRightGroupbox("説明")
AntiGucciInfoBox:AddLabel("ONにするとCreatureBlobmanを自動生成し")
AntiGucciInfoBox:AddLabel("グッチキックを防御します。")
AntiGucciInfoBox:AddLabel("ブロブが消えた場合は自動で再生成されます。")


-- 初期化
Library:ShowUI()
