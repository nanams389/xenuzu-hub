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
local LoopKillTab = Window:MakeTab({
	Name = "ループキル",
	Icon = "rbxassetid://4483345998"
})

LoopKillTab:AddSection({
	Name = "物理衝突型・無限殺戮"
})

-- ループ管理用の変数
_G.LoopKillActive = false

LoopKillTab:AddToggle({
	Name = "全員を地球の彼方へ飛ばす (Loop Kill)",
	Default = false,
	Callback = function(Value)
		_G.LoopKillActive = Value
		
		if Value then
			task.spawn(function()
				local lp = game.Players.LocalPlayer
				
				while _G.LoopKillActive do
					task.wait(0.01) -- 高速ループ
					pcall(function()
						local char = lp.Character
						local hrp = char and char:FindFirstChild("HumanoidRootPart")
						
						if hrp then
							-- 1. 体を「超高速回転する弾丸」に変える
							-- これにより、触れた瞬間に相手に巨大な衝撃力が伝わる
							hrp.RotVelocity = Vector3.new(0, 50000, 0)
							
							-- 2. 全プレイヤーをスキャンして激突しに行く
							for _, player in ipairs(game.Players:GetPlayers()) do
								if player ~= lp and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
									if not _G.LoopKillActive then break end
									
									local targetHRP = player.Character.HumanoidRootPart
									
									-- 相手の背後に一瞬でテレポート
									hrp.CFrame = targetHRP.CFrame * CFrame.new(0, 0, 1)
									task.wait(0.02) -- 物理判定を発生させるための一瞬の溜め
								end
							end
						end
					end)
				end
			end)
		else
			-- OFFにした時は回転を止める
			pcall(function()
				if game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
					game.Players.LocalPlayer.Character.HumanoidRootPart.RotVelocity = Vector3.new(0, 0, 0)
				end
			end)
		end
	end    
})

LoopKillTab:AddLabel("※使用前に移動ハックの『Noclip』をONにしてくれ！")

-- 初期化
OrionLib:Init()
