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
	for _, player in spectators do
		if player.Character then
			table.insert(playingPlayers, player)
			player.Team = playingTeam
		end
	end
	table.clear(spectators)
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
	Players.PlayerAdded:Connect(function(player: Player)
		PlayerLists.addSpectator(player)
	end)
	Players.PlayerRemoving:Connect(function(player: Player)
		PlayerLists.remove(player)
	end)
end

return PlayerLists
