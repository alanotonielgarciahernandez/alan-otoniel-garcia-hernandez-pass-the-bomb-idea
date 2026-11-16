--!strict

local ServerScriptService = game:GetService("ServerScriptService")
local GameMap = require(ServerScriptService:WaitForChild("GameMap"))

type FakePlayer = {
	Character: Model?,
}

local function asPlayer(player: FakePlayer): Player
	return (player :: any) :: Player
end

local function makePlayer(withRoot: boolean): FakePlayer
	local player: FakePlayer = {
		Character = nil,
	}
	if withRoot then
		local character = Instance.new("Model")
		local root = Instance.new("Part")
		root.Name = "HumanoidRootPart"
		root.Parent = character
		player.Character = character
	end
	return player
end

local function cleanup(player: FakePlayer)
	local character = player.Character
	if character ~= nil then
		character:Destroy()
	end
end

return {
	{
		name = "characterRoot is nil when the player has no character",
		run = function()
			local player = makePlayer(false)
			local ok, err = pcall(function()
				assert(GameMap.characterRoot(asPlayer(player)) == nil, "expected no root")
			end)
			cleanup(player)
			if not ok then
				error(err)
			end
		end,
	},
	{
		name = "spectateCFrame is above the top of the Spectate part",
		run = function()
			local baseplate = workspace:FindFirstChild("Baseplate")
			local spectate = if baseplate ~= nil then baseplate:FindFirstChild("Spectate") else nil
			if spectate == nil or not spectate:IsA("BasePart") then
				error("Spectate spawn is missing")
			end
			local destination = GameMap.spectateCFrame()
			local localOffset = spectate.CFrame:PointToObjectSpace(destination.Position)
			local minimumHeight = spectate.Size.Y / 2
			assert(localOffset.Y > minimumHeight, "spectate position is not above the part")
			assert(math.abs(localOffset.X) < 0.01 and math.abs(localOffset.Z) < 0.01, "spectate position is not centered over the part")
		end,
	},
	{
		name = "characterRoot returns the HumanoidRootPart",
		run = function()
			local player = makePlayer(true)
			local ok, err = pcall(function()
				local root = GameMap.characterRoot(asPlayer(player))
				assert(root ~= nil and root.Name == "HumanoidRootPart", "expected the HumanoidRootPart")
			end)
			cleanup(player)
			if not ok then
				error(err)
			end
		end,
	},
}
