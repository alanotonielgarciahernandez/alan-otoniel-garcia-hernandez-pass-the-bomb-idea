--!strict

local PlayerLists = {}

local Players = game:GetService("Players")
local Teams = game:GetService("Teams")

local playingPlayers: {Player} = {}
local spectators: {Player} = {}

local function requireTeam(name: string): Team
	local child = Teams:FindFirstChild(name)
	if child == nil or not child:IsA("Team") then
		error(name .. " team is missing")
	end
	return child
end

local playingTeam = requireTeam("Playing")
local spectatingTeam = requireTeam("Spectating")

function PlayerLists.playing(): {Player}
	return playingPlayers
end

function PlayerLists.spectators(): {Player}
	return spectators
end

function PlayerLists.addSpectator(player: Player)
	if table.find(spectators, player) == nil then
		table.insert(spectators, player)
	end
	player.Team = spectatingTeam
end

function PlayerLists.moveSpectatorsToPlaying()
	local index = 1
	while index <= #spectators do
		local player = spectators[index]
		if player.Character ~= nil then
			table.remove(spectators, index)
			table.insert(playingPlayers, player)
			player.Team = playingTeam
		else
			index += 1
		end
	end
end

function PlayerLists.remove(player: Player)
	local playingIndex = table.find(playingPlayers, player)
	if playingIndex ~= nil then
		table.remove(playingPlayers, playingIndex)
		return
	end
	local spectatingIndex = table.find(spectators, player)
	if spectatingIndex ~= nil then
		table.remove(spectators, spectatingIndex)
	end
end

function PlayerLists.start()
	local function join(player: Player)
		PlayerLists.addSpectator(player)
	end

	Players.PlayerAdded:Connect(join)
	for _, player in Players:GetPlayers() do
		join(player)
	end
	Players.PlayerRemoving:Connect(function(player: Player)
		PlayerLists.remove(player)
	end)
end

return PlayerLists
