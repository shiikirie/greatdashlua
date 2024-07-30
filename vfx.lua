local DashEffects = {}
DashEffects.__index = DashEffects

local config = require(script.Parent.Config)

function DashEffects.new()
	local self = setmetatable({}, DashEffects)
	return self
end

function DashEffects:dashvfx(character, direction, shift)
	local hrp = character:FindFirstChild("HumanoidRootPart")
	local vfxp = script.vfx:Clone()
	vfxp.Parent = workspace.Fx
	vfxp.Position = hrp.Position
	vfxp.ParticleEmitter:Emit(7)

	local weld = Instance.new('Weld', hrp)
	weld.Part0 = vfxp
	weld.Part1 = hrp

	if shift then
		if direction then
			weld.C0 = CFrame.new(0, 0, 0) * CFrame.Angles(0, 0, 0)
		else
			weld.C0 = CFrame.new(0, 0, 0) * CFrame.Angles(0, math.rad(90), 0)
		end
	else
		weld.C0 = CFrame.new(0, 0, 0) * CFrame.Angles(0, 0, 0)
	end
	game.Debris:AddItem(weld, 0.3)
	game.Debris:AddItem(vfxp, 0.3)
end

function DashEffects:dashvisual(hrp)
	local visual = script.dashvisual:Clone()
	local weld = Instance.new('Weld')
	weld.Part0 = hrp
	weld.Parent = hrp
	weld.Part1 = visual
	visual.Parent = hrp
	weld.C1 = CFrame.new(-2.457, -0.465, -0.848)

	local tweenService = game:GetService("TweenService")
	tweenService:Create(visual.back.back.front, TweenInfo.new(0.2), {Transparency = 0.05}):Play()
	tweenService:Create(visual.back.back, TweenInfo.new(0.2), {Transparency = 0.9}):Play()
	tweenService:Create(visual.back.back.front, TweenInfo.new(config.CD, Enum.EasingStyle.Sine), {Size = UDim2.new(1, 0, 1, 0)}):Play()

	task.wait(1.5)

	tweenService:Create(visual.back.back.front, TweenInfo.new(0.2), {Transparency = 1}):Play()
	tweenService:Create(visual.back.back, TweenInfo.new(0.2), {Transparency = 1}):Play()

	task.wait(0.2)

	visual:Destroy()
	weld:Destroy()
end

return DashEffects
