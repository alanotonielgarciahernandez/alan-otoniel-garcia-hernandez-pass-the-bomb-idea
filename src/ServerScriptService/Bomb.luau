--!strict

local BombService = {}

local CollectionService = game:GetService("CollectionService")
local ServerStorage = game:GetService("ServerStorage")

type BombPart = Part & {
	PointLight: PointLight,
	beep: Sound,
	explosionsound: Sound,
	plrname: StringValue,
	bombtime: NumberValue,
	G: IntValue,
	B: IntValue,
	db: BoolValue,
}

local BOMB_TAG = "Bomb"

local function asBomb(instance: Instance): BombPart
	if not instance:IsA("Part") then
		error("Bomb must be a Part")
	end

	local light = instance:FindFirstChild("PointLight")
	local beep = instance:FindFirstChild("beep")
	local explosion = instance:FindFirstChild("explosionsound")
	local plrname = instance:FindFirstChild("plrname")
	local bombtime = instance:FindFirstChild("bombtime")
	local green = instance:FindFirstChild("G")
	local blue = instance:FindFirstChild("B")
	local debounce = instance:FindFirstChild("db")

	if light == nil or not light:IsA("PointLight")
		or beep == nil or not beep:IsA("Sound")
		or explosion == nil or not explosion:IsA("Sound")
		or plrname == nil or not plrname:IsA("StringValue")
		or bombtime == nil or not bombtime:IsA("NumberValue")
		or green == nil or not green:IsA("IntValue")
		or blue == nil or not blue:IsA("IntValue")
		or debounce == nil or not debounce:IsA("BoolValue")
	then
		error("Bomb is missing one of its required children")
	end

	return instance :: BombPart
end

local bombTemplate = asBomb(ServerStorage:WaitForChild("Bomb"))

local function runBomb(instance: Instance)
	local bomb = asBomb(instance)
	if bomb:GetAttribute("BombStarted") == true then
		return
	end
	bomb:SetAttribute("BombStarted", true)

	local light = bomb.PointLight
	local beep = bomb.beep
	local explosion = bomb.explosionsound
	local plrname = bomb.plrname
	local bombtime = bomb.bombtime
	local G = bomb.G
	local B = bomb.B
	local db = bomb.db

	bomb.Touched:Connect(function(hit: BasePart)
		local character = hit.Parent
		if character == nil or not character:IsA("Model") then
			return
		end
		if character.Name == plrname.Value or db.Value ~= false then
			return
		end

		local humanoid = character:FindFirstChildOfClass("Humanoid")
		local rightHand = character:FindFirstChild("RightHand")
		local carrier = bomb.Parent
		if humanoid == nil or rightHand == nil or not rightHand:IsA("BasePart") then
			return
		end
		if carrier == nil or not carrier:IsA("Model") then
			return
		end
		local carrierHumanoid = carrier:FindFirstChildOfClass("Humanoid")
		if carrierHumanoid == nil then
			return
		end

		db.Value = true
		carrierHumanoid.WalkSpeed = 22
		local newBomb = asBomb(bombTemplate:Clone())
		newBomb.bombtime.Value = bomb.bombtime.Value
		newBomb.G.Value = G.Value
		newBomb.B.Value = B.Value

		local weld = Instance.new("WeldConstraint")
		weld.Part0 = rightHand
		weld.Part1 = newBomb
		weld.Parent = newBomb

		bomb:Destroy()

		newBomb.plrname.Value = character.Name
		newBomb.db.Value = true
		newBomb.CFrame = rightHand.CFrame
		newBomb.Parent = character
		humanoid.WalkSpeed = 30
		CollectionService:AddTag(newBomb, BOMB_TAG)
		task.wait(2)
		if newBomb.Parent ~= nil then
			newBomb.db.Value = false
		end
	end)

	task.spawn(function()
		for i = bombtime.Value, 0, -.05 do
			if bomb.Parent == nil then
				return
			end
			if bombtime.Value > 0 then
				bombtime.Value = i
				light.Enabled = false
				light.Color = Color3.fromRGB(255, G.Value, B.Value)
				bomb.Color = Color3.fromRGB(255, G.Value / 2, B.Value / 2)
				G.Value = G.Value - 10
				B.Value = B.Value - 10
				task.wait(i / 2)
				if bomb.Parent == nil then
					return
				end
				light.Enabled = true
				beep:Play()
				task.wait(i / 2)
			else
				break
			end
		end

		if bomb.Parent == nil then
			return
		end

		light.Color = Color3.fromRGB(255, G.Value, B.Value)
		bomb.Color = Color3.fromRGB(255, G.Value / 2, B.Value / 2)

		for _ = 1, 20 do
			if bomb.Parent == nil then
				return
			end
			beep:Play()
			task.wait(0.1)
		end

		if bomb.Parent == nil then
			return
		end

		local bum = Instance.new("Explosion")
		bum.Position = bomb.Position
		bum.BlastRadius = 5
		bum.Parent = bomb
		explosion:Play()
		task.wait(2)
		if bomb.Parent ~= nil then
			bomb:Destroy()
		end
	end)
end

function BombService.start()
	CollectionService:GetInstanceAddedSignal(BOMB_TAG):Connect(runBomb)
	for _, bomb in CollectionService:GetTagged(BOMB_TAG) do
		runBomb(bomb)
	end
end

return BombService
