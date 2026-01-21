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

AuraTab:AddToggle({
	Name = "Ultra Fling Aura (自分固定版)",
	Default = false,
	Callback = function(Value)
		_G.UltraFlingEnabled = Value
		if Value then
			task.spawn(function()
				local lp = game.Players.LocalPlayer
				local RunService = game:GetService("RunService")
				
				while _G.UltraFlingEnabled do
					local char = lp.Character
					local hrp = char and char:FindFirstChild("HumanoidRootPart")
					
					if hrp then
						-- 1. 自分のパーツを「物理的な凶器」にする設定
						for _, v in pairs(char:GetDescendants()) do
							if v:IsA("BasePart") then
								v.CanCollide = false -- 通常時はすり抜ける（自分が飛ばないため）
								v.Velocity = Vector3.new(200000, 200000, 200000) -- 常に高圧力を維持
							end
						end

						for _, player in ipairs(game.Players:GetPlayers()) do
							if player ~= lp and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
								local tHrp = player.Character.HumanoidRootPart
								local dist = (tHrp.Position - hrp.Position).Magnitude

								if dist <= 20 then
									-- 2. 相手に重なった瞬間だけ自分を「固定(Anchor)」して「衝突」を有効化
									local oldCF = hrp.CFrame
									
									-- 相手の座標に高速回転しながら突入
									hrp.CFrame = tHrp.CFrame * CFrame.Angles(math.rad(math.random(0,360)), math.rad(math.random(0,360)), 0)
									
									-- 【重要】自分を固定して相手の反動を受けないようにする
									hrp.Anchored = true 
									for _, p in pairs(char:GetChildren()) do
										if p:IsA("BasePart") then p.CanCollide = true end
									end

									task.wait(0.05) -- この0.05秒の間に相手が吹っ飛ぶ

									-- 3. 固定を解除して元の位置に戻る
									hrp.Anchored = false
									hrp.CFrame = oldCF
									for _, p in pairs(char:GetChildren()) do
										if p:IsA("BasePart") then p.CanCollide = false end
									end
								end
							end
						end
					end
					RunService.Heartbeat:Wait()
				end
			end)
		end
	end    
})

--==============================
-- タブ：Blobman Fling & Kill All
--==============================
local BlobTab = Window:MakeTab({
	Name = "Blobman Fling",
	Icon = "rbxassetid://4483345998",
	PremiumOnly = false
})

local selectedPlayer = nil
_G.FlingActive = false

-- 【修正：ボタン類をタブ作成の直後に配置】
-- Kill All ボタン
BlobTab:AddButton({
	Name = "Kill All (Grab Method)",
	Callback = function()
		local lp = game.Players.LocalPlayer
		local char = lp.Character
		
		for _, v in pairs(game.Players:GetPlayers()) do
			if v ~= lp and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
				task.spawn(function()
					local tHrp = v.Character.HumanoidRootPart
					local rArm = char:FindFirstChild("Right Arm") or char:FindFirstChild("RightHand")
					if rArm then
						tHrp.CFrame = rArm.CFrame
						task.wait(0.1)
						tHrp.Velocity = Vector3.new(1000000, 1000000, 1000000)
						tHrp.RotVelocity = Vector3.new(1000000, 1000000, 1000000)
						
						local bav = Instance.new("BodyAngularVelocity", tHrp)
						bav.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
						bav.AngularVelocity = Vector3.new(1000, 1000, 1000)
						game:GetService("Debris"):AddItem(bav, 0.5)
					end
				end)
			end
		end
		
		OrionLib:MakeNotification({
			Name = "Nazu Hub",
			Content = "Attempting to Kill All Players via Grab/Network...",
			Time = 3
		})
	end    
})

-- プレイヤーリスト更新関数
local function updatePlayerList()
    local p = {}
    for _, v in pairs(game.Players:GetPlayers()) do
        if v ~= game.Players.LocalPlayer then table.insert(p, v.Name) end
    end
    return p
end

-- ターゲット選択
local PlayerDropdown = BlobTab:AddDropdown({
	Name = "Select Target",
	Default = "None",
	Options = updatePlayerList(),
	Callback = function(Value)
		selectedPlayer = game.Players:FindFirstChild(Value)
	end    
})

BlobTab:AddButton({
	Name = "Refresh Player List",
	Callback = function()
		PlayerDropdown:Refresh(updatePlayerList(), true)
	end    
})

-- 無限Flingトグル
BlobTab:AddToggle({
	Name = "Enable Infinite Fling",
	Default = false,
	Callback = function(Value)
		_G.FlingActive = Value
	end    
})

-- 物理ロジック（バックグラウンド動作）
task.spawn(function()
    while task.wait() do
        local lp = game.Players.LocalPlayer
        local char = lp.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        
        local isBlob = false
        if char then
            for _, v in pairs(char:GetChildren()) do
                if v:IsA("BasePart") and v.Size.Magnitude > 5 then
                    isBlob = true; break
                end
            end
        end

        if _G.FlingActive and selectedPlayer and selectedPlayer.Character and isBlob then
            local tChar = selectedPlayer.Character
            local tHrp = tChar and tChar:FindFirstChild("HumanoidRootPart")
            local rArm = char:FindFirstChild("Right Arm") or char:FindFirstChild("RightHand")
            local lArm = char:FindFirstChild("Left Arm") or char:FindFirstChild("LeftHand")

            if tHrp and (rArm or lArm) then
                hrp.Anchored = true
                
                if not tHrp:FindFirstChild("FlingPosing") then
                    local bp = Instance.new("BodyPosition", tHrp)
                    bp.Name = "FlingPosing"
                    bp.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                    bp.P = 20000
                    
                    local bav = Instance.new("BodyAngularVelocity", tHrp)
                    bav.Name = "FlingSpin"
                    bav.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
                    bav.AngularVelocity = Vector3.new(1000, 1000, 1000)
                end

                local targetArm = (tick() % 0.2 > 0.1) and rArm or lArm
                if targetArm then
                    tHrp.BodyPosition.Position = targetArm.Position
                    tHrp.CFrame = targetArm.CFrame * CFrame.Angles(math.rad(math.random(0,360)), math.rad(math.random(0,360)), math.rad(math.random(0,360)))
                end
            end
        else
            if hrp then hrp.Anchored = false end
            if selectedPlayer and selectedPlayer.Character then
                local tHrp = selectedPlayer.Character:FindFirstChild("HumanoidRootPart")
                if tHrp then
                    if tHrp:FindFirstChild("FlingPosing") then tHrp.FlingPosing:Destroy() end
                    if tHrp:FindFirstChild("FlingSpin") then tHrp.FlingSpin:Destroy() end
                end
            end
        end
    end
end)

--==============================
-- 初期化
--==============================
OrionLib:Init()
