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

-- [[ タブ：プレイヤー設定 ]]
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

-- [[ タブ：移動ハック ]]
local StealthTab = Window:MakeTab({ Name = "移動ハック", Icon = "rbxassetid://4483345998" })
StealthTab:AddToggle({ Name = "壁抜け (Noclip)", Default = false, Callback = function(v) _G.Noclip = v end })
game:GetService("RunService").Stepped:Connect(function()
    if _G.Noclip and game.Players.LocalPlayer.Character then
        for _, v in pairs(game.Players.LocalPlayer.Character:GetDescendants()) do
            if v:IsA("BasePart") then v.CanCollide = false end
        end
    end
end)

-- [[ タブ：攻撃オーラ ]]
local AuraTab = Window:MakeTab({ Name = "攻撃オーラ", Icon = "rbxassetid://4483345998" })
_G.isConstantAuraEnabled = false
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

-- [[ タブ：プレイヤー操作 ]]
local UtilTab = Window:MakeTab({ Name = "プレイヤー操作", Icon = "rbxassetid://4483345998" })
local selectedPlayer = ""

local function GetPlayerList()
    local list = {}
    for _, v in pairs(game.Players:GetPlayers()) do
        if v ~= game.Players.LocalPlayer then table.insert(list, v.Name) end
    end
    return list
end

local PlayerDropdown = UtilTab:AddDropdown({
    Name = "追跡ターゲットを選択", Default = "", Options = GetPlayerList(),
    Callback = function(Value) selectedPlayer = Value end    
})

UtilTab:AddButton({
    Name = "プレイヤーリストを更新",
    Callback = function() PlayerDropdown:Refresh(GetPlayerList(), true) end    
})

_G.Tracking = false
UtilTab:AddToggle({
    Name = "選んだ相手を追跡", Default = false,
    Callback = function(v)
        _G.Tracking = v
        if v then
            task.spawn(function()
                while _G.Tracking do
                    task.wait()
                    pcall(function()
                        local target = game.Players:FindFirstChild(selectedPlayer)
                        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
                            game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 2)
                        end
                    end)
                end
            end)
        end
    end    
})

UtilTab:AddButton({
    Name = "全員を自分の元へ引き寄せる (Bring All)",
    Callback = function()
        local lp = game.Players.LocalPlayer
        local rs = game:GetService("ReplicatedStorage")
        local SetNetworkOwner = rs:FindFirstChild("GrabEvents") and rs.GrabEvents:FindFirstChild("SetNetworkOwner")
        for _, p in pairs(game.Players:GetPlayers()) do
            if p ~= lp and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                pcall(function()
                    if SetNetworkOwner then SetNetworkOwner:FireServer(p.Character.HumanoidRootPart, p.Character.HumanoidRootPart.CFrame) end
                    p.Character.HumanoidRootPart.CFrame = lp.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, -3)
                end)
            end
        end
    end    
})

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

-- 内部変数
local SelectedPlayer = nil
local LoopKillEnabled = false
local LoopKillConnection = nil

-- --- Loop タブの作成 ---
local LoopTab = Window:MakeTab({
	Name = "Loop",
	Icon = "rbxassetid://4483345998",
	PremiumOnly = false
})

LoopTab:AddSection({
	Name = "Target Selection"
})

-- 1. ターゲット選択用のドロップダウン
-- プレイヤーが入退室するたびに更新するのが理想だが、まずは簡易版で実装
local function GetPlayerList()
	local plrs = {}
	for _, v in pairs(Players:GetPlayers()) do
		table.insert(plrs, v.Name)
	end
	return plrs
end

local PlayerDropdown = LoopTab:AddDropdown({
	Name = "Select Player (ターゲット選択)",
	Default = "None",
	Options = GetPlayerList(),
	Callback = function(Value)
		SelectedPlayer = Players:FindFirstChild(Value)
		
		-- プレイヤーが選ばれたら通知とアイコン表示（コンソールで確認用）
		if SelectedPlayer then
			local userId = SelectedPlayer.UserId
			local thumbType = Enum.ThumbnailType.HeadShot
			local thumbSize = Enum.ThumbnailSize.Size150x150
			local content, isReady = Players:GetUserThumbnailAsync(userId, thumbType, thumbSize)
			
			OrionLib:MakeNotification({
				Name = "Target Locked",
				Content = Value .. " を選択したぜ。",
				Image = content, -- プレイヤーのアイコンを表示！
				Time = 5
			})
		end
	end    
})

-- リスト更新ボタン
LoopTab:AddButton({
	Name = "Refresh Player List (リスト更新)",
	Callback = function()
		PlayerDropdown:Refresh(GetPlayerList(), true)
	end
})

LoopTab:AddSection({
	Name = "Actions"
})

local RunService = game:GetService("RunService")
local LocalPlayer = game.Players.LocalPlayer

-- 内部変数
local SelectedPlayer = nil
local LoopFlingEnabled = false
local FlingConnection = nil

-- --- Loop Fling の処理 ---
LoopTab:AddToggle({
	Name = "Loop Fling (ON / OFF)",
	Default = false,
	Callback = function(Value)
		LoopFlingEnabled = Value
		
		if LoopFlingEnabled then
			-- 1フレームごとに実行（物理演算をバグらせて飛ばす）
			FlingConnection = RunService.Heartbeat:Connect(function()
				if SelectedPlayer and SelectedPlayer.Character and LocalPlayer.Character then
					local myRoot = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
					local targetRoot = SelectedPlayer.Character:FindFirstChild("HumanoidRootPart")
					
					if myRoot and targetRoot then
						-- 自分の動きを物理的に「異常」な速度にする（これが飛ばすコツ）
						local oldVelocity = myRoot.Velocity
						myRoot.Velocity = Vector3.new(10000, 10000, 10000) -- 超高速回転/移動
						
						-- 相手の場所に一瞬で移動してぶつかる
						myRoot.CFrame = targetRoot.CFrame
						
						-- すぐに速度を戻さないと自分もどこかへ行くので注意
						RunService.RenderStepped:Wait()
						myRoot.Velocity = oldVelocity
					end
				end
			end)
			
			OrionLib:MakeNotification({
				Name = "Fling Start",
				Content = SelectedPlayer.Name .. " を追放中...",
				Time = 3
			})
		else
			-- ループ停止
			if FlingConnection then
				FlingConnection:Disconnect()
				FlingConnection = nil
			end
		end
	end    
})

--==============================
-- 変数宣言（心臓部）
--==============================
local TargetPlayer = nil
local HouseBypass = false
local MagneticGrab = false
local KickAura = false
local GrabSpeed = 0.005 -- 君が見つけた爆速設定
local BV = nil
local VIM = game:GetService("VirtualInputManager")

-- [最強の強制掴み関数]
local function blobGrabPlayer(target)
    local blobman = workspace:FindFirstChild("PlayerToys") and workspace.PlayerToys:FindFirstChild("CreatureBlobman")
    if not blobman then
        for _, v in pairs(workspace:GetDescendants()) do
            if v.Name == "CreatureBlobman" then blobman = v break end
        end
    end

    if blobman and target and target.Character then
        local script = blobman:FindFirstChild("BlobmanSeatAndOwnerScript")
        if script and script:FindFirstChild("CreatureGrab") then
            local args = {
                [1] = blobman:FindFirstChild("RightDetector"),
                [3] = blobman:FindFirstChild("RightDetector"):FindFirstChild("RightWeld")
            }
            script.CreatureGrab:FireServer(unpack(args))
        end
    end
end

-- [実行メインループ]
task.spawn(function()
    while true do
        if MagneticGrab and TargetPlayer and TargetPlayer.Character then
            local myRoot = game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            local tRoot = TargetPlayer.Character:FindFirstChild("HumanoidRootPart")
            if myRoot and tRoot then
                -- 相手に張り付く
                myRoot.CFrame = tRoot.CFrame * CFrame.new(0, 0, -1.8)
                -- 強制掴み
                blobGrabPlayer(TargetPlayer)
            end
        end
        if KickAura then
            VIM:SendMouseButtonEvent(0, 0, 0, true, game, 0) -- 左クリック連打
            task.wait(0.05)
            VIM:SendMouseButtonEvent(0, 0, 0, false, game, 0)
        end
        task.wait(GrabSpeed)
    end
end)

-- 変数
local kickAuraEnabled = false
local auraRadius = 25
-- FTAPの攻撃用リモート（ReplicatedStorage内を探る）
local combatEvent = game:GetService("ReplicatedStorage"):WaitForChild("Events"):FindFirstChild("Combat") or game:GetService("ReplicatedStorage"):FindFirstChild("Remotes")

-- Auraタブ
local AuraTab = Window:MakeTab({
    Name = "Aura",
    Icon = "rbxassetid://4483362458",
    PremiumOnly = false
})

AuraTab:AddToggle({
    Name = "Kick Aura (FTAP Edition)",
    Default = false,
    Callback = function(Value)
        kickAuraEnabled = Value
        
        if kickAuraEnabled then
            task.spawn(function()
                while kickAuraEnabled do
                    local lp = game.Players.LocalPlayer
                    local char = lp.Character
                    if char and char:FindFirstChild("HumanoidRootPart") then
                        for _, v in pairs(game.Players:GetPlayers()) do
                            if v ~= lp and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
                                local targetHRP = v.Character.HumanoidRootPart
                                local dist = (char.HumanoidRootPart.Position - targetHRP.Position).Magnitude
                                
                                if dist <= auraRadius then
                                    -- 1. 物理的な座標飛ばし（ローカル側で位置をバグらせる）
                                    targetHRP.CFrame = targetHRP.CFrame * CFrame.new(0, 5000, 0)
                                    
                                    -- 2. サーバーへの攻撃通知（FTAPのキック・掴み判定を強制発火）
                                    -- ※ここが「ガチ」の部分だ。Remote名はお前の環境のXenuzuに合わせて調整してくれ
                                    pcall(function()
                                        -- 相手を掴んで(Grab)からキック(Kick)の状態を強制送信
                                        combatEvent:FireServer("Kick", v.Character)
                                        combatEvent:FireServer("Grab", v.Character)
                                    end)
                                end
                            end
                        end
                    end
                    task.wait(0.05) -- 物人の判定速度に合わせる
                end
            end)
        end
    end    
})

AuraTab:AddSlider({
    Name = "Aura Range",
    Min = 5,
    Max = 100,
    Default = 25,
    Color = Color3.fromRGB(255, 0, 0),
    Increment = 1,
    ValueName = "Studs",
    Callback = function(Value)
        auraRadius = Value
    end    
})
---初期化---
OrionLib:Init()
