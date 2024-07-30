local Dash = {}
Dash.__index = Dash
-- dash by shikirai - https://www.youtube.com/@shikirai
local config = require(script.Actor.Config)
local animstable2 = require(script.Parent.Anims)
local animstable = animstable2.new()
local Debris = game:GetService("Debris")
local player = game.Players.LocalPlayer
local DashEffects = require(script.Actor.vfx)
local dashEffects = DashEffects.new()

function Dash.new()
	local self = setmetatable({}, Dash)

	self.cd = config["CD"]
	self.anim = Instance.new("Animation")
	self.candash = true

	self.dashVectors = {
		W = {Vector3.new(0, 0, -1), animstable:get()['W'], true},
		A = {Vector3.new(-1, 0, 0), animstable:get()['A'], false},
		S = {Vector3.new(0, 0, 1), animstable:get()['S'], true},
		D = {Vector3.new(1, 0, 0), animstable:get()['D'], false},
	}

	return self
end

function Dash:enableCooldown()
	task.desynchronize()
	task.wait(self.cd)
	self.candash = true
end

function Dash:getDashData(key, hrp)
	task.desynchronize()
	local vector, animId, faceForward = unpack(self.dashVectors[key] or self.dashVectors['W'])
	vector = hrp.CFrame:VectorToWorldSpace(vector)
	local dashVector = Vector3.new(vector.X * config.Lenght, 5, vector.Z * config.Lenght)
	task.synchronize()
	return dashVector, animId, faceForward
end

function Dash:getIgnoreList()
	task.desynchronize()
	local il = {}
	for _, v in pairs(workspace:GetDescendants()) do
		if v:IsA("BasePart") and not v.CanCollide then
			table.insert(il, v)
		end
	end
	task.synchronize()
	return il
end

function Dash:createBodyMovers(hrp, hitpos)
	local bp = Instance.new('BodyPosition')
	bp.MaxForce = Vector3.new(1e5, 1e3, 1e5)
	bp.D = 100
	bp.P = 500
	bp.Position = hitpos
	bp.Parent = hrp

	local bg = Instance.new('BodyGyro')
	bg.MaxTorque = Vector3.new(1e5, 1e3, 1e5)
	bg.D = 50
	bg.P = 5000
	bg.CFrame = hrp.CFrame
	bg.Parent = hrp

	Debris:AddItem(bp, 0.3)
	Debris:AddItem(bg, 0.3)
end

function Dash:Dash(key, shift)
	task.synchronize()
	if not self.candash then return end

	self.candash = false
	local c = player.Character
	local hrp = c:FindFirstChild("HumanoidRootPart")

	if not hrp then return end
	c:SetAttribute("Dash", true)

	local dashVector, animId, faceForward = self:getDashData(key, hrp)
	if not shift then
		dashVector, animId, faceForward = self:getDashData('W', hrp)
	end

	self.anim.AnimationId = animId
	dashEffects:dashvfx(c, faceForward, shift)

	local ray = Ray.new(hrp.Position, dashVector)
	local ignoreList = self:getIgnoreList()
	local _, hitpos = workspace:FindPartOnRayWithIgnoreList(ray, ignoreList, false, true)

	self:createBodyMovers(hrp, hitpos)

	local humanoid = c:FindFirstChild("Humanoid")
	if humanoid then
		local animInstance = humanoid:LoadAnimation(self.anim)
		animInstance:Play()
		animInstance:AdjustSpeed(1.5)
		animInstance.Stopped:Connect(function()
			task.wait(0.2)
			c:SetAttribute("Dash", false)
		end)
	end

	coroutine.wrap(function() self:enableCooldown() end)()
	dashEffects:dashvisual(hrp)
	task.desynchronize()
end

return Dash
