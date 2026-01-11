getgenv().gethui = function() return game.CoreGui end

-- Orion Lib 読み込み
local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/jensonhirst/Orion/main/source')))()

-- [[ テーマ設定 (Blitz風) ]]
-- テーマ一覧: Default, Green, Seth, Razor, Jester, Akali (AkaliがBlitzに近いクールな色)
local Window = OrionLib:MakeWindow({
    Name = "Xenouzu Hub |", 
    HidePremium = false, 
    SaveConfig = true, 
    ConfigFolder = "XenouzuHub",
    IntroEnabled = true,
    IntroText = "Xenouzu Hub 起動中..."
})

-- [[ メインタブ：プレイヤー設定 ]]
local MainTab = Window:MakeTab({
    Name = "プレイヤー設定",
    Icon = "rbxassetid://4483345998"
})

MainTab:AddSection({ Name = "基本ステータス" })

MainTab:AddSlider({
    Name = "歩行速度 (WalkSpeed)",
    Min = 16, Max = 500, Default = 16, Increment = 1,
    Callback = function(v) 
        if game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") then
            game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = v 
        end
    end    
})

MainTab:AddSlider({
    Name = "ジャンプ力 (JumpPower)",
    Min = 50, Max = 1000, Default = 50, Increment = 1,
    Callback = function(v) 
        if game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") then
            game.Players.LocalPlayer.Character.Humanoid.JumpPower = v 
        end
    end    
})

MainTab:AddToggle({
    Name = "無限ジャンプ",
    Default = false,
    Callback = function(v) _G.InfJump = v end    
})

-- 無限ジャンプのロジック
game:GetService("UserInputService").JumpRequest:Connect(function()
    if _G.InfJump then
        local hum = game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum:ChangeState("Jumping") end
    end
end)

-- [[ 移動タブ：特殊移動 ]]
local StealthTab = Window:MakeTab({
    Name = "移動ハック",
    Icon = "rbxassetid://4483345998"
})

StealthTab:AddSection({ Name = "空飛び & 壁抜け" })

StealthTab:AddToggle({
    Name = "壁抜け (Noclip)",
    Default = false,
    Callback = function(v) _G.Noclip = v end    
})

-- Noclipロジック
game:GetService("RunService").Stepped:Connect(function()
    if _G.Noclip and game.Players.LocalPlayer.Character then
        for _, v in pairs(game.Players.LocalPlayer.Character:GetDescendants()) do
            if v:IsA("BasePart") then v.CanCollide = false end
        end
    end
end)

StealthTab:AddToggle({
    Name = "空中飛行 (Fly)",
    Default = false,
    Callback = function(v)
        _G.Fly = v
        local lp = game.Players.LocalPlayer
        local char = lp.Character or lp.CharacterAdded:Wait()
        local root = char:WaitForChild("HumanoidRootPart")
        
        if _G.Fly then
            local bg = Instance.new("BodyGyro", root)
            bg.P = 9e4
            bg.maxTorque = Vector3.new(9e9, 9e9, 9e9)
            bg.cframe = root.CFrame
            local bv = Instance.new("BodyVelocity", root)
            bv.velocity = Vector3.new(0,0.1,0)
            bv.maxForce = Vector3.new(9e9, 9e9, 9e9)
            
            task.spawn(function()
                while _G.Fly do
                    task.wait()
                    if char:FindFirstChild("Humanoid") then
                        char.Humanoid.PlatformStand = true
                        bv.velocity = (workspace.CurrentCamera.CFrame.LookVector * (char.Humanoid.WalkSpeed * 1.5))
                        bg.cframe = workspace.CurrentCamera.CFrame
                    end
                end
                bg:Destroy()
                bv:Destroy()
                if char:FindFirstChild("Humanoid") then char.Humanoid.PlatformStand = false end
            end)
        end
    end    
})

-- [[ 攻撃タブ：オーラ ]]
local AuraTab = Window:MakeTab({
    Name = "攻撃オーラ",
    Icon = "rbxassetid://4483345998"
})

AuraTab:AddSection({ Name = "自動吹き飛ばし (Fling)" })

-- オーラ用変数
local FLING_VELOCITY = 50 
local AURA_RANGE = 25 
_G.isConstantAuraEnabled = false

local function doUpFling(targetHRP)
    local rs = game:GetService("ReplicatedStorage")
    local grab = rs:FindFirstChild("GrabEvents")
    local SetNetworkOwner = grab and grab:FindFirstChild("SetNetworkOwner")
    
    if not targetHRP or not SetNetworkOwner then return end
    pcall(function() SetNetworkOwner:FireServer(targetHRP, targetHRP.CFrame) end)
    
    local bv = Instance.new("BodyVelocity")
    bv.Name = "BlitzFling"
    bv.Parent = targetHRP
    bv.MaxForce = Vector3.new(1e9, 1e9, 1e9)
    bv.Velocity = Vector3.new(0, FLING_VELOCITY, 0)
    game:GetService("Debris"):AddItem(bv, 0.15) 
end

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
                    local char = lp.Character
                    if char and char:FindFirstChild("HumanoidRootPart") then
                        for _, player in ipairs(game.Players:GetPlayers()) do
                            if player ~= lp and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                                local targetHRP = player.Character.HumanoidRootPart
                                if (targetHRP.Position - char.HumanoidRootPart.Position).Magnitude <= AURA_RANGE then
                                    doUpFling(targetHRP)
                                end
                            end
                        end
                    end
                end
            end)
        end
    end    
})

-- [[ 視覚タブ：ESP ]]
local VisualTab = Window:MakeTab({
    Name = "プレイヤー透視",
    Icon = "rbxassetid://4483345998"
})

VisualTab:AddSection({ Name = "視覚サポート" })

VisualTab:AddButton({
    Name = "プレイヤーESPを起動",
    Callback = function()
        for _, p in pairs(game.Players:GetPlayers()) do
            if p ~= game.Players.LocalPlayer and p.Character then
                local h = p.Character:FindFirstChild("Highlight") or Instance.new("Highlight", p.Character)
                h.FillColor = Color3.fromRGB(255, 0, 0)
                h.OutlineColor = Color3.fromRGB(255, 255, 255)
            end
        end
    end    
})

-- [[ LOOP KILL TAB ]]
local KillTab = Window:MakeTab({
	Name = "ループキル",
	Icon = "rbxassetid://4483345998"
})

KillTab:AddSection({
	Name = "物理衝突・無限キル（セーフゾーン対応）"
})

_G.LoopKillActive = false

KillTab:AddToggle({
	Name = "全員物理キル (Loop Kill)",
	Default = false,
	Callback = function(v)
		_G.LoopKillActive = v
		local lp = game.Players.LocalPlayer
		local GrabEvents = game:GetService("ReplicatedStorage"):WaitForChild("GrabEvents", 5)
		local SetNetworkOwner = GrabEvents and GrabEvents:FindFirstChild("SetNetworkOwner")
		
		if v then
			task.spawn(function()
				while _G.LoopKillActive do
					task.wait(0.01)
					pcall(function()
						local char = lp.Character
						local hrp = char and char:FindFirstChild("HumanoidRootPart")
						
						if hrp then
							-- 飛ばす力を極限まで高める（回転 + 横方向の速度）
							hrp.RotVelocity = Vector3.new(0, 100000, 0)
							hrp.Velocity = Vector3.new(0, 50, 0) -- 少し浮かせると飛びやすくなる
							
							for _, player in ipairs(game.Players:GetPlayers()) do
								if player ~= lp and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
									if not _G.LoopKillActive then break end
									
									local targetChar = player.Character
									local targetHRP = targetChar.HumanoidRootPart
									
									-- ✅ 【セーフゾーン回避】
									-- 1. ForceField（無敵オーラ）がある人はスキップ
									-- 2. 特定の場所（家の中など）を避けたい場合はここで判定
									if targetChar:FindFirstChildOfClass("ForceField") then
										continue -- 次のプレイヤーへ
									end

									-- ✅ 【飛ばすための核心】
									-- 相手のネットワーク権限を奪う（Fling Auraと同じ理屈）
									if SetNetworkOwner then
										SetNetworkOwner:FireServer(targetHRP, targetHRP.CFrame)
									end
									
									-- 相手に重なって弾き飛ばす
									hrp.CFrame = targetHRP.CFrame
									task.wait(0.02)
								end
							end
						end
					end)
				end
			end)
		else
			pcall(function()
				if lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then
					lp.Character.HumanoidRootPart.RotVelocity = Vector3.new(0, 0, 0)
					lp.Character.HumanoidRootPart.Velocity = Vector3.new(0, 0, 0)
				end
			end)
		end
	end    
})

-- [[ DEFENSE TAB (GOD MODE PHYSICS) ]]
local DefenseTab = Window:MakeTab({
	Name = "防御・回避",
	Icon = "rbxassetid://4483345998"
})

DefenseTab:AddSection({ Name = "絶対防御（投げ・飛ばし無効）" })

_G.AntiGrab = false
DefenseTab:AddToggle({
	Name = "絶対掴み防止 (Anti-Grab V2)",
	Default = false,
	Callback = function(v)
		_G.AntiGrab = v
		if v then
			task.spawn(function()
				while _G.AntiGrab do
					task.wait() -- 爆速ループ
					pcall(function()
						local char = game.Players.LocalPlayer.Character
						if char then
							-- 1. 全ての接続（Weld/Socket等）を強制的に消去
							for _, obj in ipairs(char:GetDescendants()) do
								if obj:IsA("JointInstance") or obj:IsA("TouchTransmitter") then
									if obj.Name ~= "Neck" and obj.Name ~= "Root" then
										obj:Destroy()
									end
								end
							end
							-- 2. 自分のパーツが「掴まれる判定」を持たないようにする
							for _, part in ipairs(char:GetPartBoundsInBox(char:GetModelCFrame(), char:GetModelSize())) do
								if part.Parent ~= char then -- 自分のパーツ以外との接触を無視
									-- ここで接触判定を一時的に操作する（ゲームによる）
								end
							end
						end
					end)
				end
			end)
		end
	end    
})

_G.AntiFling = false
DefenseTab:AddToggle({
	Name = "絶対飛ばし防止 (Velocity Anchor)",
	Default = false,
	Callback = function(v)
		_G.AntiFling = v
		if v then
			task.spawn(function()
				while _G.AntiFling do
					task.wait() -- 限界まで速く
					pcall(function()
						local hrp = game.Players.LocalPlayer.Character.HumanoidRootPart
						if hrp then
							-- 【重要】速度が一定を超えたら強制的にゼロにする
							-- 物理的に吹っ飛ぶエネルギーを毎フレーム消去する
							if hrp.Velocity.Magnitude > 0.1 or hrp.RotVelocity.Magnitude > 0.1 then
								hrp.Velocity = Vector3.new(0, 0, 0)
								hrp.RotVelocity = Vector3.new(0, 0, 0)
							end
						end
					end)
				end
			end)
		end
	end    
})

-- [[ TRACKER TAB ]]
local TrackerTab = Window:MakeTab({
	Name = "プレイヤー追跡",
	Icon = "rbxassetid://4483345998"
})

local targetPlayer = ""

TrackerTab:AddTextbox({
	Name = "ターゲット名 (略称可)",
	Default = "",
	TextDisappear = false,
	Callback = function(t)
		targetPlayer = t
	end	  
})

_G.Tracking = false
TrackerTab:AddToggle({
	Name = "ストーカーモード開始",
	Default = false,
	Callback = function(v)
		_G.Tracking = v
		if v then
			task.spawn(function()
				while _G.Tracking do
					task.wait()
					pcall(function()
						for _, p in pairs(game.Players:GetPlayers()) do
							if string.find(p.Name:lower(), targetPlayer:lower()) and p.Character then
								-- 相手の背後1スタッドの位置に張り付く
								local targetHRP = p.Character.HumanoidRootPart
								game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = targetHRP.CFrame * CFrame.new(0, 0, 1)
							end
						end
					end)
				end
			end)
		end
	end    
})

-- 初期化
OrionLib:Init()
