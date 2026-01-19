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
-- 【物人専用】Bling House タブ (右クリック掴み対応)
--==============================
local BlingTab = Window:MakeTab({
	Name = "Bling House",
	Icon = "rbxassetid://4483345998",
	PremiumOnly = false
})

local TargetPlayer = nil
local HouseBypass = false
local MagneticGrab = false
local BV = nil
local VIM = game:GetService("VirtualInputManager")

-- [1] 貫通 & 落下防止（ブロブマン対応）
game:GetService("RunService").Stepped:Connect(function()
    if HouseBypass then
        local char = game.Players.LocalPlayer.Character
        if char then
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") then part.CanCollide = false end
            end
            local humanoid = char:FindFirstChild("Humanoid")
            if humanoid and humanoid.SeatPart and humanoid.SeatPart.Parent then
                for _, vPart in pairs(humanoid.SeatPart.Parent:GetDescendants()) do
                    if vPart:IsA("BasePart") then vPart.CanCollide = false end
                end
            end
        end
    end
end)

-- [2] 吸い付き & 右クリック掴み連打ロジック
task.spawn(function()
    while true do
        if MagneticGrab and TargetPlayer and TargetPlayer.Character then
            local myRoot = game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            local tRoot = TargetPlayer.Character:FindFirstChild("HumanoidRootPart")
            
            if myRoot and tRoot then
                -- 相手の目の前に張り付く (距離1.5で固定)
                myRoot.CFrame = tRoot.CFrame * CFrame.new(0, 0, -1.5) * CFrame.Angles(0, math.rad(180), 0)
                
                -- 【物人仕様】マウス右クリック (MouseButton2) を高速連打
                VIM:SendMouseButtonEvent(0, 0, 1, true, game, 0) -- 右クリ押し
                task.wait(0.01)
                VIM:SendMouseButtonEvent(0, 0, 1, false, game, 0) -- 右クリ離し
            end
        end
        task.wait(0.02) -- 掴み判定をさらに濃密に
    end
end)

-- --- UIコンポーネント ---

local function getPlayers()
    local pList = {}
    for _, p in pairs(game.Players:GetPlayers()) do
        if p ~= game.Players.LocalPlayer then table.insert(pList, p.Name) end
    end
    return pList
end

local PlayerSelect = BlingTab:AddDropdown({
	Name = "1. Target: Select Player",
	Default = "",
	Options = getPlayers(),
	Callback = function(Value)
		TargetPlayer = game.Players:FindFirstChild(Value)
	end
})

BlingTab:AddButton({
	Name = "Refresh List",
	Callback = function() PlayerSelect:Refresh(getPlayers(), true) end
})

BlingTab:AddToggle({
	Name = "2. House Bypass (Noclip)",
	Default = false,
	Callback = function(Value)
		HouseBypass = Value
        local root = game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if Value then
            if root and not BV then
                BV = Instance.new("BodyVelocity")
                BV.Velocity = Vector3.new(0, 0, 0)
                BV.MaxForce = Vector3.new(0, math.huge, 0)
                BV.Parent = root
            end
        else
            if BV then BV:Destroy() BV = nil end
            pcall(function()
                for _, part in pairs(game.Players.LocalPlayer.Character:GetDescendants()) do
                    if part:IsA("BasePart") then part.CanCollide = true end
                end
            end)
        end
	end    
})

BlingTab:AddToggle({
	Name = "3. Auto Magnetic Grab (Right Click)",
	Default = false,
	Callback = function(Value)
		MagneticGrab = Value
	end
})
-- 初期化
OrionLib:Init()
