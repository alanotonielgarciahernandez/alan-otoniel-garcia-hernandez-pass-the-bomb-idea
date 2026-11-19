--!strict

local ServerScriptService = game:GetService("ServerScriptService")
local PlayerLists = require(ServerScriptService:WaitForChild("PlayerLists"))

type FakePlayer = {
	Name: string,
	Team: Team?,
	Character: Model?,
}

local function asPlayer(player: FakePlayer): Player
	return (player :: any) :: Player
end

local function makePlayer(name: string, withCharacter: boolean): FakePlayer
	local player: FakePlayer = {
		Name = name,
		Team = nil,
		Character = nil,
	}
	if withCharacter then
		local character = Instance.new("Model")
		character.Name = name
		local root = Instance.new("Part")
		root.Name = "HumanoidRootPart"
		root.Parent = character
		player.Character = character
	end
	return player
end

local function cleanup(player: FakePlayer)
	PlayerLists.remove(asPlayer(player))
	local character = player.Character
	if character ~= nil then
		character:Destroy()
	end
end

return {
	{
		name = "addSpectator records the player on the Spectating team",
		run = function()
			local player = makePlayer("Spectator", false)
			local ok, err = pcall(function()
				PlayerLists.addSpectator(asPlayer(player))
				assert(table.find(PlayerLists.spectators(), asPlayer(player)) ~= nil, "player was not added to spectators")
				local team = player.Team
				assert(team ~= nil and team.Name == "Spectating", "player was not on the Spectating team")
			end)
			cleanup(player)
			if not ok then
				error(err)
			end
		end,
	},
	{
		name = "moveSpectatorsToPlaying leaves a loading player on the spectator list",
		run = function()
			if #PlayerLists.spectators() > 0 or #PlayerLists.playing() > 0 then
				error("run this test while both player lists are empty")
			end
			local ready = makePlayer("Ready", true)
			local waiting = makePlayer("Waiting", false)
			local ok, err = pcall(function()
				PlayerLists.addSpectator(asPlayer(ready))
				PlayerLists.addSpectator(asPlayer(waiting))
				PlayerLists.moveSpectatorsToPlaying()
				assert(table.find(PlayerLists.playing(), asPlayer(ready)) ~= nil, "player with a character was not moved to playing")
				assert(table.find(PlayerLists.playing(), asPlayer(waiting)) == nil, "player without a character was moved to playing")
				assert(table.find(PlayerLists.spectators(), asPlayer(waiting)) ~= nil, "loading player was dropped from spectators")
				local playingTeam = ready.Team
				assert(playingTeam ~= nil and playingTeam.Name == "Playing", "moved player was not on the Playing team")
				local spectatingTeam = waiting.Team
				assert(spectatingTeam ~= nil and spectatingTeam.Name == "Spectating", "loading player was not left on the Spectating team")
			end)
			cleanup(ready)
			cleanup(waiting)
			if not ok then
				error(err)
			end
		end,
	},
	{
		name = "addSpectator does not record the same player twice",
		run = function()
			if #PlayerLists.spectators() > 0 or #PlayerLists.playing() > 0 then
				error("run this test while both player lists are empty")
			end
			local player = makePlayer("Twice", false)
			local ok, err = pcall(function()
				PlayerLists.addSpectator(asPlayer(player))
				PlayerLists.addSpectator(asPlayer(player))
				local copies = 0
				for _, spectator in PlayerLists.spectators() do
					if spectator == asPlayer(player) then
						copies += 1
					end
				end
				assert(copies == 1, "player was recorded more than once")
			end)
			cleanup(player)
			if not ok then
				error(err)
			end
		end,
	},
	{
		name = "remove ignores a player who is in neither list",
		run = function()
			if #PlayerLists.spectators() > 0 or #PlayerLists.playing() > 0 then
				error("run this test while both player lists are empty")
			end
			local staying = makePlayer("Staying", false)
			local outsider = makePlayer("Outsider", false)
			local ok, err = pcall(function()
				PlayerLists.addSpectator(asPlayer(staying))
				PlayerLists.remove(asPlayer(outsider))
				assert(table.find(PlayerLists.spectators(), asPlayer(staying)) ~= nil, "a listed player was removed")
				assert(#PlayerLists.spectators() == 1, "removing an unlisted player changed the spectator list")
				assert(#PlayerLists.playing() == 0, "removing an unlisted player changed the playing list")
			end)
			cleanup(staying)
			cleanup(outsider)
			if not ok then
				error(err)
			end
		end,
	},
	{
		name = "remove drops a player from playing or spectators",
		run = function()
			if #PlayerLists.spectators() > 0 or #PlayerLists.playing() > 0 then
				error("run this test while both player lists are empty")
			end
			local player = makePlayer("Leaving", true)
			local ok, err = pcall(function()
				PlayerLists.addSpectator(asPlayer(player))
				PlayerLists.remove(asPlayer(player))
				assert(table.find(PlayerLists.spectators(), asPlayer(player)) == nil, "player stayed in spectators")
				PlayerLists.addSpectator(asPlayer(player))
				PlayerLists.moveSpectatorsToPlaying()
				PlayerLists.remove(asPlayer(player))
				assert(table.find(PlayerLists.playing(), asPlayer(player)) == nil, "player stayed in playing")
			end)
			cleanup(player)
			if not ok then
				error(err)
			end
		end,
	},
}
