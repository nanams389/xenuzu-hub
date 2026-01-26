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

-- [[ Blobman Kick タブ生成 ]]
local BlobTab = Window:MakeTab({
    Name = "Blobman Kick",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

-- Blobman専用のドロップダウン用プレイヤーリスト作成
local function getPlayerList()
    local list = {}
    for _, p in pairs(game.Players:GetPlayers()) do
        table.insert(list, p.Name)
    end
    return list
end

-- ターゲット選択
BlobTab:AddDropdown({
    Name = "Target Player",
    Default = game.Players.LocalPlayer.Name,
    Options = getPlayerList(),
    Callback = function(Value)
        config.Blobman.Target.Value = Value
    end
})

-- 腕の左右選択
BlobTab:AddDropdown({
    Name = "Arm Side",
    Default = "Left",
    Options = {"Left", "Right"},
    Callback = function(Value)
        config.Blobman.ArmSide.Value = Value
    end
})

-- 召喚ボタン
BlobTab:AddButton({
    Name = "Spawn Blobman",
    Callback = function()
        spawnBlobman()
    end
})

-- Kickボタン（単体攻撃）
BlobTab:AddButton({
    Name = "Kick Target",
    Callback = function()
        local t = getPlayerFromName(config.Blobman.Target.Value)
        if t then
            task.spawn(function()
                local root = get(t.Character, "HumanoidRootPart")
                local b = getBlobman()
                local pos = getLocalRoot().CFrame
                task.wait(.5)
                getLocalRoot().CFrame = root.CFrame
                task.wait()
                blobKick(b, root, config.Blobman.ArmSide.Value)
                task.wait(.5)
                getLocalRoot().CFrame = pos
            end)
        end
    end
})

-- Kick All（全員飛ばし）
BlobTab:AddButton({
    Name = "Kick All Players",
    Callback = function()
        local blob = getBlobman()
        if (not blob) then blob = spawnBlobman() end
        if (not getLocalHum().Sit) then
            blob.VehicleSeat:Sit(getLocalHum())
        end
        task.wait()
        local pos = getLocalRoot().CFrame
        if (blob and getLocalHum().Sit) then
            blobGrab(blob, getLocalRoot(), config.Blobman.ArmSide.Value)
            for _, v in ipairs(game.Players:GetPlayers()) do
                if (v == game.Players.LocalPlayer) then continue end
                local character = v.Character
                if (not character) then continue end
                local root = get(character, "HumanoidRootPart")
                if (not root) then continue end
                getLocalRoot().CFrame = root.CFrame
                task.wait(.25)
                blobKick(blob, root, config.Blobman.ArmSide.Value)
            end
            task.wait(.1)
            getLocalRoot().CFrame = pos
            destroyToy(blob)
        end
    end
})

-- Void（奈落送り）
BlobTab:AddButton({
    Name = "Void Target",
    Callback = function()
        local t = getPlayerFromName(config.Blobman.Target.Value)
        if t then
            task.spawn(function()
                local root = get(t.Character, "HumanoidRootPart")
                local b = getBlobman()
                local pos = getLocalRoot().CFrame
                blobGrab(b, getLocalRoot(), config.Blobman.ArmSide.Value)
                task.wait()
                blobBring(b, root, config.Blobman.ArmSide.Value)
                task.wait()
                getLocalRoot().CFrame = CFrame.new(1e32, -16, 1e32)
                task.wait(1)
                getLocalHum().Sit = false
                task.wait(.1)
                getLocalRoot().CFrame = pos
                task.wait()
                destroyToy(b)
            end)
        end
    end
})

-- オーラ系のトグル
BlobTab:AddToggle({
    Name = "Kick Aura",
    Default = false,
    Callback = function(Value)
        config.Blobman.KickAura.Value = Value
    end
})

-- ========== タブ作成 ==========
-- Blobman関連タブ
local BlobmanBasicTab = window:MakeTab({
    Name = "Blobman Basic",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

local BlobmanAdvancedTab = window:MakeTab({
    Name = "Blobman Advanced",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

local BlobmanAurasTab = window:MakeTab({
    Name = "Blobman Auras",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

-- Snipes関連タブ
local SnipesBasicTab = window:MakeTab({
    Name = "Snipes Basic",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

local SnipesLoopsTab = window:MakeTab({
    Name = "Snipes Loops",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

-- 設定タブ
local SettingsTab = window:MakeTab({
    Name = "Settings",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

-- ========== Blobman Basic Tab ==========
BlobmanBasicTab:AddDropdown({
    Name = "Target",
    Default = getLocalPlayer().Name,
    Options = playerList,
    Callback = function(Value)
        config.Blobman.Target.Value = Value
    end
})

BlobmanBasicTab:AddDropdown({
    Name = "Arm Side",
    Default = "Left",
    Options = {"Left", "Right"},
    Callback = function(Value)
        config.Blobman.ArmSide.Value = Value
    end
})

BlobmanBasicTab:AddButton({
    Name = "Spawn Blobman",
    Callback = function()
        spawnBlobman()
    end
})

BlobmanBasicTab:AddButton({
    Name = "Kick",
    Callback = function()
        local t=getPlayerFromName(config.Blobman.Target.Value)
        if(t)then
            task.spawn(function()
                local root=get(t.Character,"HumanoidRootPart")
                local b=getBlobman()
                local pos=getLocalRoot().CFrame
                task.wait(.5)
                getLocalRoot().CFrame=root.CFrame
                task.wait()
                blobKick(b,root,config.Blobman.ArmSide.Value)
                task.wait(.5)
                getLocalRoot().CFrame=pos
            end)
        end
    end
})

BlobmanBasicTab:AddButton({
    Name = "Bring",
    Callback = function()
        local t=getPlayerFromName(config.Blobman.Target.Value)
        if(t)then
            task.spawn(function()
                local root=get(t.Character,"HumanoidRootPart")
                local b=getBlobman()
                if(not root or not b)then return end
                local pos=getLocalRoot().CFrame
                getLocalRoot().CFrame=root.CFrame
                blobBring(b,root,config.Blobman.ArmSide.Value)
                task.wait()
                getLocalRoot().CFrame=pos
            end)
        end
    end
})

BlobmanBasicTab:AddButton({
    Name = "Void",
    Callback = function()
        local t=getPlayerFromName(config.Blobman.Target.Value)
        if(t)then
            task.spawn(function()
                local root=get(t.Character,"HumanoidRootPart")
                local b=getBlobman()
                local pos=getLocalRoot().CFrame
                blobGrab(b,getLocalRoot(),config.Blobman.ArmSide.Value)
                task.wait()
                blobBring(b,root,config.Blobman.ArmSide.Value)
                task.wait()
                getLocalRoot().CFrame=CFrame.new(1e32,-16,1e32)
                task.wait(1)
                getLocalHum().Sit=false
                task.wait(.1)
                getLocalRoot().CFrame=pos
                task.wait()
                destroyToy(b)
            end)
        end
    end
})

BlobmanBasicTab:AddButton({
    Name = "Slide",
    Callback = function()
        local t=getPlayerFromName(config.Blobman.Target.Value)
        if(t)then
            task.spawn(function()
                local root=get(t.Character,"HumanoidRootPart")
                local b=getBlobman()
                local pos=getLocalRoot().CFrame
                blobGrab(b,getLocalRoot(),config.Blobman.ArmSide.Value)
                task.wait()
                blobBring(b,root,config.Blobman.ArmSide.Value)
                task.wait()
                getLocalRoot().CFrame=pos
                task.wait(.5)
                destroyToy(b)
            end)
        end
    end
})

BlobmanBasicTab:AddToggle({
    Name = "Noclip",
    Default = false,
    Callback = function(Value)
        config.Blobman.Noclip.Value = Value
    end
})

-- ========== Blobman Advanced Tab ==========
BlobmanAdvancedTab:AddButton({
    Name = "OP-Blobman",
    Callback = function()
        local blob=getBlobman()
        if(not blob)then
            blob=spawnBlobman()
        end
        if(not getLocalHum().Sit)then
            blob.VehicleSeat:Sit(getLocalHum())
        end
        local pos=getLocalRoot().CFrame
        task.wait()
        if(blob and getLocalHum())then
            --// RIGHT
            if(blob:IsDescendantOf(workspace.PlotItems))then
                getLocalRoot().CFrame=CFrame.new(0,0,0)
                task.wait(.5)
            end
            local Toy=spawntoy("YouDecoy",getLocalRoot().CFrame)
            SetNetworkOwner(Toy.HumanoidRootPart)
            Toy.HumanoidRootPart.CFrame=blob.RightDetector.CFrame
            task.wait()
            blobGrab(blob,Toy.HumanoidRootPart,"Right")
            task.wait(1.25)
            destroyToy(Toy)
            task.wait(.1)

            --// LEFT
            local Toy=spawntoy("YouDecoy",getLocalRoot().CFrame)
            SetNetworkOwner(Toy.HumanoidRootPart)
            Toy.HumanoidRootPart.CFrame=blob.LeftDetector.CFrame
            task.wait()
            blobGrab(blob,Toy.HumanoidRootPart,"Left")
            task.wait(1.25)
            destroyToy(Toy)
            task.wait(.1)
        end
        getLocalRoot().CFrame=pos
    end
})

BlobmanAdvancedTab:AddButton({
    Name = "Kick All",
    Callback = function()
        local blob=getBlobman()
        if(not blob)then
            blob=spawnBlobman()
        end
        if(not getLocalHum().Sit)then
            blob.VehicleSeat:Sit(getLocalHum())
        end
        task.wait()
        local pos=getLocalRoot().CFrame
        if(blob and getLocalHum().Sit)then
            blobGrab(blob,getLocalRoot(),config.Blobman.ArmSide.Value)
            for _,v in ipairs(service.Players:GetPlayers())do
                if(v==getLocalPlayer())then continue end
                if(not config.Settings.IgnoreIsInPlot.Value and IsInPlot(v))then continue end
                if(config.Settings.IgnoreFriend.Value and IsFriend(v))then continue end
                local character=v.Character
                if(not character)then continue end
                local root=get(character,"HumanoidRootPart")
                if(not root)then continue end
                getLocalRoot().CFrame=root.CFrame
                task.wait(.25)
                blobKick(blob,root,config.Blobman.ArmSide.Value)
            end
            task.wait(.1)
            getLocalRoot().CFrame=pos
            destroyToy(blob)
        end
    end
})

BlobmanAdvancedTab:AddButton({
    Name = "Slide All",
    Callback = function()
        local blob=getBlobman()
        if(not blob)then
            blob=spawnBlobman()
        end
        if(not getLocalHum().Sit)then
            blob.VehicleSeat:Sit(getLocalHum())
        end
        task.wait()
        local pos=getLocalRoot().CFrame
        if(blob and getLocalHum().Sit)then
            blobGrab(blob,getLocalRoot(),config.Blobman.ArmSide.Value)
            for _,v in ipairs(service.Players:GetPlayers())do
                if(v==getLocalPlayer())then continue end
                if(not config.Settings.IgnoreIsInPlot.Value and IsInPlot(v))then continue end
                if(config.Settings.IgnoreFriend.Value and IsFriend(v))then continue end
                local character=v.Character
                if(not character)then continue end
                local root=get(character,"HumanoidRootPart")
                if(not root)then continue end
                getLocalRoot().CFrame=root.CFrame
                task.wait(.2)
                blobGrab(blob,root,config.Blobman.ArmSide.Value)
            end
            task.wait(.1)
            getLocalRoot().CFrame=pos
            destroyToy(blob)
        end
    end
})

BlobmanAdvancedTab:AddToggle({
    Name = "Loop Kick All",
    Default = false,
    Callback = function(Value)
        config.Blobman.LoopKickAll.Value = Value
    end
})

-- ========== Blobman Auras Tab ==========
BlobmanAurasTab:AddToggle({
    Name = "Kick Aura",
    Default = false,
    Callback = function(Value)
        config.Blobman.KickAura.Value = Value
    end
})

BlobmanAurasTab:AddToggle({
    Name = "Grab Aura",
    Default = false,
    Callback = function(Value)
        config.Blobman.GrabAura.Value = Value
    end
})

-- ========== Snipes Basic Tab ==========
SnipesBasicTab:AddDropdown({
    Name = "Target",
    Default = getLocalPlayer().Name,
    Options = playerList,
    Callback = function(Value)
        config.Snipes.Target.Value = Value
    end
})

SnipesBasicTab:AddButton({
    Name = "Bring",
    Callback = function()
        local pos=getLocalRoot().CFrame
        local t=getPlayerFromName(config.Snipes.Target.Value)
        if(not t)then return end
        local root=get(t.Character,"HumanoidRootPart")
        if(not root)then return end
        task.spawn(function()
            Snipefunc(root,function()
                task.wait(.01)
                root.CFrame=pos
                task.wait(.5)
                ungrab(root)
                getLocalRoot().CFrame=pos
            end)
        end)
    end
})

SnipesBasicTab:AddButton({
    Name = "Void",
    Callback = function()
        task.spawn(function()
            local pos=getLocalRoot().CFrame
            local t=getPlayerFromName(config.Snipes.Target.Value)
            if(not t)then return end
            local root=get(t.Character,"HumanoidRootPart")
            if(not root)then return end
            Snipefunc(root,function()
                Velocity(root,Vector3.new(0,1e4,0))
                getLocalRoot().CFrame=pos
            end)
        end)
    end
})

SnipesBasicTab:AddButton({
    Name = "Kill",
    Callback = function()
        task.spawn(function()
            local pos=getLocalRoot().CFrame
            local t=getPlayerFromName(config.Snipes.Target.Value)
            if(not t)then return end
            local root=get(t.Character,"HumanoidRootPart")
            if(not root)then return end
            Snipefunc(root,function()
                MoveTo(root,CFrame.new(4096,-75,4096))
                Velocity(root,Vector3.new(0,-1e3,0))
                getLocalRoot().CFrame=pos
            end)
        end)
    end
})

SnipesBasicTab:AddButton({
    Name = "Poison",
    Callback = function()
        task.spawn(function()
            local pos=getLocalRoot().CFrame
            local t=getPlayerFromName(config.Snipes.Target.Value)
            if(not t)then return end
            local root=get(t.Character,"HumanoidRootPart")
            if(not root)then return end
            Snipefunc(root,function()
                MoveTo(root,CFrame.new(58,-70,271))
                getLocalRoot().CFrame=pos
            end)
        end)
    end
})

SnipesBasicTab:AddButton({
    Name = "Ragdoll",
    Callback = function()
        task.spawn(function()
            local pos=getLocalRoot().CFrame
            local t=getPlayerFromName(config.Snipes.Target.Value)
            if(not t)then return end
            local root=get(t.Character,"HumanoidRootPart")
            if(not root)then return end
            Snipefunc(root,function()
                local rpos=root.CFrame
                Velocity(root,Vector3.new(0,-64,0))
                task.wait(.1)
                getLocalRoot().CFrame=rpos
                Velocity(root,Vector3.zero)
                getLocalRoot().CFrame=pos
            end)
        end)
    end
})

SnipesBasicTab:AddButton({
    Name = "Death",
    Callback = function()
        task.spawn(function()
            local pos=getLocalRoot().CFrame
            local t=getPlayerFromName(config.Snipes.Target.Value)
            if(not t)then return end
            local root=get(t.Character,"HumanoidRootPart")
            if(not root)then return end
            Snipefunc(root,function()
                local hum = cget(root.Parent,"Humanoid")
                if hum then
                    hum:ChangeState(Enum.HumanoidStateType.Dead)
                end
                task.wait(.5)
                ungrab(root)
                getLocalRoot().CFrame=pos
            end)
        end)
    end
})

SnipesBasicTab:AddButton({
    Name = "Fling",
    Callback = function()
        local pos=getLocalRoot().CFrame
        local t=getPlayerFromName(config.Snipes.Target.Value)
        if(not t)then return end
        local root=get(t.Character,"HumanoidRootPart")
        if(not root)then return end
        local toy=spawntoy("YouDecoy",getLocalRoot().CFrame)
        task.wait(.3)
        getLocalRoot().CFrame=toy.PrimaryPart.CFrame
        task.wait(.1)
        SetNetworkOwner(toy.PrimaryPart)
        for _=1,256 do
            SetNetworkOwner(toy.PrimaryPart)
            task.wait()
            local rx=math.rad(math.random(0,360*32768))
            local ry=math.rad(math.random(0,360*32768))
            local rz=math.rad(math.random(0,360*32768))
            local rr=1.5
            toy.PrimaryPart.CFrame=CFrame.new(root.Position+Vector3.one*math.random(-rr,rr))*CFrame.Angles(rx,ry,rz)
            Velocity(toy.PrimaryPart,Vector3.one*1e16)
        end
        task.wait(.5)
        getLocalRoot().CFrame=pos
        task.wait(.5)
        destroyToy(toy)
    end
})

-- ========== Snipes Loops Tab ==========
SnipesLoopsTab:AddToggle({
    Name = "Loop Void",
    Default = false,
    Callback = function(Value)
        config.Snipes.LoopVoid.Value = Value
    end
})

SnipesLoopsTab:AddToggle({
    Name = "Loop Kill",
    Default = false,
    Callback = function(Value)
        config.Snipes.LoopKill.Value = Value
    end
})

SnipesLoopsTab:AddToggle({
    Name = "Loop Poison",
    Default = false,
    Callback = function(Value)
        config.Snipes.LoopPoison.Value = Value
    end
})

SnipesLoopsTab:AddToggle({
    Name = "Loop Ragdoll",
    Default = false,
    Callback = function(Value)
        config.Snipes.LoopRagdoll.Value = Value
    end
})

SnipesLoopsTab:AddToggle({
    Name = "Loop Death",
    Default = false,
    Callback = function(Value)
        config.Snipes.LoopDeath.Value = Value
    end
})

-- ========== Settings Tab ==========
SettingsTab:AddSlider({
    Name = "Aura Radius",
    Min = 0,
    Max = 128,
    Default = 32,
    Color = Color3.fromRGB(255,255,255),
    Increment = 1,
    ValueName = "studs",
    Callback = function(Value)
        config.Settings.AuraRadius.Value = Value
    end
})

SettingsTab:AddButton({
    Name = "Infinite Aura Radius (NetworkOwner)",
    Callback = function()
        config.Settings.AuraRadius.Value = 10000
    end
})

SettingsTab:AddToggle({
    Name = "Ignore Friend",
    Default = false,
    Callback = function(Value)
        config.Settings.IgnoreFriend.Value = Value
    end
})

SettingsTab:AddToggle({
    Name = "Ignore IsInPlot",
    Default = false,
    Callback = function(Value)
        config.Settings.IgnoreIsInPlot.Value = Value
    end
})

SettingsTab:AddTextbox({
    Name = "Toggle Keybind",
    Default = "C",
    TextDisappear = false,
    Callback = function(Value)
        ToggleKeybind = Enum.KeyCode[Value]
    end
})


--==============================
-- 初期化
--==============================
OrionLib:Init()
