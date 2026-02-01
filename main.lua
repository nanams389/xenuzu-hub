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

-- Xenouzu Hubの既存Windowに追加するタブ
local service=setmetatable({},{
    __index=function(self,k)
        local s=game:GetService(k)
        rawset(self,k,s)
        return s
    end,
})

local loop=Instance.new("BindableEvent")
service.RunService.Heartbeat:Connect(function(dt)
    loop:Fire(dt)
end)

local get=game.FindFirstChild
local cget=game.FindFirstChildOfClass
local function getLocalPlayer()
    return service.Players.LocalPlayer
end
local function getLocalChar()
    return getLocalPlayer().Character
end
local function getLocalRoot()
    if(not getLocalChar())then return end
    return get(getLocalChar(),"HumanoidRootPart")or get(getLocalChar(),"Torso")
end
local function getLocalHum()
    if(not getLocalChar())then return end
    return cget(getLocalChar(),"Humanoid")
end
local function Velocity(part,value)
    local b=Instance.new("BodyVelocity")
    b.MaxForce=Vector3.one*math.huge
    b.Velocity=value
    b.Parent=part
    task.spawn(task.delay,1,game.Destroy,b)
end
local function SetNetworkOwner(part)
    service.ReplicatedStorage.GrabEvents.SetNetworkOwner:FireServer(part,getLocalRoot().CFrame)
end
local function GetNearParts(origin,radius)
    return workspace:GetPartBoundsInRadius(origin,radius)
end
local function MoveTo(part,x)
    for _,v in ipairs(part.Parent:GetDescendants())do
        if(v:IsA("BasePart"))then
            v.CanCollide=false
        end
    end
    local pos=typeof(x)=="CFrame"and x.Position or x
    local b=Instance.new("BodyPosition")
    b.MaxForce=Vector3.one*math.huge
    b.Position=pos
    b.P=2e4
    b.D=5e3
    b.Parent=part
    task.spawn(function()
        b.ReachedTarget:Wait()
        pcall(game.Destroy,b)
        for _,v in ipairs(part.Parent:GetDescendants())do
            if(v:IsA("BasePart"))then
                v.CanCollide=true
            end
        end
    end)
end
local function ungrab(part)
    service.ReplicatedStorage.GrabEvents.DestroyGrabLine:FireServer(part)
end
local function getInv()
    return get(workspace,getLocalPlayer().Name.."SpawnedInToys")
end
local function spawntoy(name,cframe,vector3)
    local toy=service.ReplicatedStorage.MenuToys.SpawnToyRemoteFunction:InvokeServer(table.unpack({
        [1]=name,
        [2]=cframe,
        [3]=vector3 or Vector3.zero
    }))
    local r=get(getInv(),name)
    return r
end
local function destroyToy(model)
    service.ReplicatedStorage.MenuToys.DestroyToy:FireServer(model)
end

local function getBlobman()
    local v=get(getInv(),"CreatureBlobman",true)
    if(not v)then
        for _,p in ipairs(workspace.PlotItems:GetChildren())do
            if(p)then
                local m=get(p,"CreatureBlobman")
                if(not m)or(m and m.PlayerValue.Value~=getLocalPlayer().Name)then
                    return
                end
                v=m
            end
        end
    end
    if(v.ClassName~="Model")then return false end
    if(not get(v,"VehicleSeat"))then return false end
    return v
end
local function spawnBlobman()
    local blobman=spawntoy("CreatureBlobman",getLocalRoot().CFrame)
    return blobman
end
local function blobGrab(blob,target,side)
    local args={
        [1]=get(blob,side.."Detector"),
        [2]=target,
        [3]=get(get(blob,side.."Detector"),side.."Weld")
    }
    blob.BlobmanSeatAndOwnerScript.CreatureGrab:FireServer(unpack(args))
end
local function blobDrop(blob,target,side)
    local args={
        [1]=get(blob,side.."Detector"),
        [2]=target
    }
    blob.BlobmanSeatAndOwnerScript.CreatureDrop:FireServer(unpack(args))
end
local function blobBring(blob,target,side)
    local pos=getLocalRoot().CFrame
    getLocalRoot().CFrame=target.CFrame
    task.wait(.25)
    blobGrab(blob,target,side)
    task.wait(.25)
    getLocalRoot().CFrame=pos
end
local function blobKick(blob,target,side)
    blobGrab(blob,getLocalRoot(),side)
    task.wait(.1)
    SetNetworkOwner(target)
    task.wait()
    target.CFrame+=Vector3.new(0,16,0)
    task.wait(.1)
    ungrab(target)
    blobGrab(blob,target,side)
end

local function IsFriend(p)
    if(not p or not p.UserId or not getLocalPlayer())then return end
    return getLocalPlayer():IsFriendsWith(p.UserId)
end
local function IsInPlot(p)
    return p.InPlot.Value
end

local function getPlayerFromName(name)
    local tplayer=nil
    local sname=name:lower()
    for _,player in pairs(service.Players:GetPlayers())do
        if(player.DisplayName:lower():sub(1,#sname)==sname)then
            tplayer=player
            break
        elseif(player.Name:lower():sub(1,#sname)==sname)then
            if(not tplayer )then
                tplayer=player
            end
        end
    end
    return tplayer
end

local function Snipefunc(root,func,...)
    local pos=getLocalRoot().CFrame
    task.spawn(function(...)
        local parts={"Head","Torso","HumanoidRootPart"}
        for _,p in pairs(parts)do 
            local part = get(getLocalChar(),p)
            if part then part.CanCollide=false end 
        end
        getLocalRoot().CFrame=CFrame.new(root.Position-root.CFrame.LookVector*15)
        task.wait(0.1)
        workspace.CurrentCamera.CFrame=CFrame.lookAt(workspace.CurrentCamera.CFrame.Position,root.Position)
        for _=1,4 do SetNetworkOwner(root)task.wait(0.05)end
        local look=workspace.CurrentCamera.CFrame
        task.wait(0.1)
        func(...)
        workspace.CurrentCamera.CFrame=look
        task.wait(0.1)
        for _,p in pairs(parts)do 
            local part = get(getLocalChar(),p)
            if part then part.CanCollide=true end 
        end
        getLocalRoot().CFrame=pos
        Velocity(getLocalRoot(),Vector3.zero)
    end,...)
end

local config={
    Blobman={
        Target={Value=getLocalPlayer().Name},
        ArmSide={Value="Left"},
        Noclip={Value=false},
        GrabAura={Value=false},
        KickAura={Value=false},
        LoopKick={Value=false},
        LoopKickAll={Value=false}
    },
    Snipes={
        Target={Value=getLocalPlayer().Name},
        LoopVoid={Value=false},
        LoopKill={Value=false},
        LoopPoison={Value=false},
        LoopRagdoll={Value=false},
        LoopDeath={Value=false}
    },
    Settings={
        IgnoreFriend={Value=false},
        IgnoreIsInPlot={Value=false},
        AuraRadius={Value=32}
    },
}

local playerList = {}
for _, player in pairs(service.Players:GetPlayers()) do
    if player ~= getLocalPlayer() then
        table.insert(playerList, player.Name)
    end
end
table.insert(playerList, getLocalPlayer().Name)

-- WindowはXenouzu Hubの既存のものを使用
local BlobmansTab = Window:MakeTab({
    Name = "Blobmans",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

local SnipesTab = Window:MakeTab({
    Name = "Snipes",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

local SettingsTab = Window:MakeTab({
    Name = "Settings",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

BlobmansTab:AddDropdown({
    Name = "Target",
    Default = getLocalPlayer().Name,
    Options = playerList,
    Callback = function(Value)
        config.Blobman.Target.Value = Value
    end
})

BlobmansTab:AddDropdown({
    Name = "Arm Side",
    Default = "Left",
    Options = {"Left", "Right"},
    Callback = function(Value)
        config.Blobman.ArmSide.Value = Value
    end
})

BlobmansTab:AddButton({
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

BlobmansTab:AddButton({
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

BlobmansTab:AddButton({
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

BlobmansTab:AddToggle({
    Name = "Noclip",
    Default = false,
    Callback = function(Value)
        config.Blobman.Noclip.Value = Value
    end
})

BlobmansTab:AddButton({
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

BlobmansTab:AddButton({
    Name = "Spawn Blobman",
    Callback = function()
        spawnBlobman()
    end
})

BlobmansTab:AddButton({
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

BlobmansTab:AddButton({
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

BlobmansTab:AddButton({
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

BlobmansTab:AddToggle({
    Name = "Loop Kick All",
    Default = false,
    Callback = function(Value)
        config.Blobman.LoopKickAll.Value = Value
    end
})

BlobmansTab:AddToggle({
    Name = "Kick Aura",
    Default = false,
    Callback = function(Value)
        config.Blobman.KickAura.Value = Value
    end
})

BlobmansTab:AddToggle({
    Name = "Grab Aura",
    Default = false,
    Callback = function(Value)
        config.Blobman.GrabAura.Value = Value
    end
})

SnipesTab:AddDropdown({
    Name = "Target",
    Default = getLocalPlayer().Name,
    Options = playerList,
    Callback = function(Value)
        config.Snipes.Target.Value = Value
    end
})

SnipesTab:AddButton({
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

SnipesTab:AddButton({
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

SnipesTab:AddButton({
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

SnipesTab:AddButton({
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

SnipesTab:AddButton({
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

SnipesTab:AddButton({
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

SnipesTab:AddButton({
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

SnipesTab:AddToggle({
    Name = "Loop Void",
    Default = false,
    Callback = function(Value)
        config.Snipes.LoopVoid.Value = Value
    end
})

SnipesTab:AddToggle({
    Name = "Loop Kill",
    Default = false,
    Callback = function(Value)
        config.Snipes.LoopKill.Value = Value
    end
})

SnipesTab:AddToggle({
    Name = "Loop Poison",
    Default = false,
    Callback = function(Value)
        config.Snipes.LoopPoison.Value = Value
    end
})

SnipesTab:AddToggle({
    Name = "Loop Ragdoll",
    Default = false,
    Callback = function(Value)
        config.Snipes.LoopRagdoll.Value = Value
    end
})

SnipesTab:AddToggle({
    Name = "Loop Death",
    Default = false,
    Callback = function(Value)
        config.Snipes.LoopDeath.Value = Value
    end
})

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

task.wait(.1)

local LoopKickTimer=0
local SnipeLoopTimer=0

loop.Event:Connect(function(dt)
    LoopKickTimer+=dt
    SnipeLoopTimer+=dt

    if(config.Blobman.Noclip.Value)then
        local blob=getBlobman()
        if(blob)then
            for _,v in ipairs(blob:GetDescendants())do
                if(v:IsA("BasePart"))then
                    v.CanCollide=false
                end
            end
        end
    end

    if(getLocalChar()and getLocalRoot())then
        for _,v in ipairs(GetNearParts(getLocalRoot().Position,config.Settings.AuraRadius.Value))do
            if(not v.Anchored and not v:IsDescendantOf(getLocalChar()))then
                local p=service.Players:GetPlayerFromCharacter(v.Parent)
                if(IsFriend(p)and config.Settings.IgnoreFriend.Value)then continue end
                if(config.Blobman.GrabAura.Value)then
                    if(v.Name~="HumanoidRootPart"or not getBlobman())then continue end
                    if(p and config.Settings.IgnoreFriend.Value and IsFriend(p))then continue end
                    if(p and p==getLocalPlayer())then continue end
                    local blob=getBlobman()
                    local side=(math.random()>=.5)and"Left"or"Right"
                    blobGrab(blob,v,side)
                end
                if(config.Blobman.KickAura.Value)then
                    if(not p)then continue end
                    if(getLocalHum()and getLocalHum().Sit)then
                        if(v.Name~="HumanoidRootPart"or not getBlobman())then continue end
                        local blob=getBlobman()
                        local side=(math.random()>=.5)and"Left"or"Right"
                        task.spawn(function()
                            blobKick(blob,v,side)
                        end)
                    end
                end
            end
        end
    end

    if(LoopKickTimer>=1.5)then
        if(config.Blobman.LoopKick.Value)then
            local target=getPlayerFromName(config.Blobman.Target.Value)
            local blob=getBlobman()
            if(not blob)then
                blob=spawnBlobman()
            end
            if(target)then
                local character=target.Character
                if(character)then
                    local root=get(character,"HumanoidRootPart")
                    if(root)then
                        local side=(math.random()>=.5)and"Left"or"Right"
                        local b=getBlobman()
                        local pos=getLocalRoot().CFrame
                        task.wait(.5)
                        getLocalRoot().CFrame=root.CFrame
                        task.wait()
                        blobKick(b,root,side)
                        task.wait(.5)
                        getLocalRoot().CFrame=pos
                    end
                end
            end
        end
        if(config.Blobman.LoopKickAll.Value)then
            local blob=getBlobman()
            if(not blob)then
                blob=spawnBlobman()
            end
            for _,p in ipairs(service.Players:GetPlayers())do
                if(p~=getLocalPlayer()and not config.Settings.IgnoreIsInPlot.Value and not IsInPlot(p)and getLocalChar())then
                    local character=p.Character
                    if(character)then
                        local root=get(character,"HumanoidRootPart")
                        if(root)then
                            local side=(math.random()>=.5)and"Left"or"Right"
                            local b=getBlobman()
                            local pos=getLocalRoot().CFrame
                            task.wait(.25)
                            getLocalRoot().CFrame=root.CFrame
                            task.wait()
                            blobKick(b,root,side)
                            task.wait(.25)
                            getLocalRoot().CFrame=pos
                        end
                    end
                end
            end
        end
        LoopKickTimer=0
    end

    if(SnipeLoopTimer>=1)then
        SnipeLoopTimer=0
        if(config.Snipes.LoopVoid.Value)then
            task.spawn(function()
                local t = getPlayerFromName(config.Snipes.Target.Value)
                if t and t.Character then
                    local root=get(t.Character,"HumanoidRootPart")
                    if(root)then
                        Snipefunc(root,function()
                            Velocity(root,Vector3.new(0,1e4,0))
                        end)
                    end
                end
            end)
        end
        if(config.Snipes.LoopKill.Value)then
            task.spawn(function()
                local t = getPlayerFromName(config.Snipes.Target.Value)
                if t and t.Character then
                    local root=get(t.Character,"HumanoidRootPart")
                    if(root)then
                        Snipefunc(root,function()
                            MoveTo(root,CFrame.new(512,-85,512))
                            Velocity(root,Vector3.new(0,-1e3,0))
                        end)
                    end
                end
            end)
        end
        if(config.Snipes.LoopPoison.Value)then
            task.spawn(function()
                local t = getPlayerFromName(config.Snipes.Target.Value)
                if t and t.Character then
                    local root=get(t.Character,"HumanoidRootPart")
                    if(root)then
                        Snipefunc(root,function()
                            MoveTo(root,CFrame.new(58,-70,271))
                        end)
                    end
                end
            end)
        end
        if(config.Snipes.LoopRagdoll.Value)then
            task.spawn(function()
                local t = getPlayerFromName(config.Snipes.Target.Value)
                if t and t.Character then
                    local root=get(t.Character,"HumanoidRootPart")
                    if(root)then
                        Snipefunc(root,function()
                            local rpos=root.CFrame
                            Velocity(root,Vector3.new(0,-64,0))
                            task.wait(.1)
                            MoveTo(root,rpos)
                            Velocity(root,Vector3.zero)
                        end)
                    end
                end
            end)
        end
        if(config.Snipes.LoopDeath.Value)then
            task.spawn(function()
                local t = getPlayerFromName(config.Snipes.Target.Value)
                if t and t.Character then
                    local root=get(t.Character,"HumanoidRootPart")
                    if(root)then
                        Snipefunc(root,function()
                            local hum = cget(root.Parent,"Humanoid")
                            if hum then
                                hum:ChangeState(Enum.HumanoidStateType.Dead)
                            end
                            task.wait(.5)
                            ungrab(root)
                        end)
                    end
                end
            end)
        end
    end
end)


   

--==============================
-- 初期化
--==============================
OrionLib:Init()
