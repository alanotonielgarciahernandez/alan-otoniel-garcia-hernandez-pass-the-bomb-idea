--!strict

local Round = {}

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

type NoticeModule = {
	set: (player: Player, text: string) -> (),
	start: () -> (),
}

type PlayerListsModule = {
	playing: () -> {Player},
	spectators: () -> {Player},
	addSpectator: (player: Player) -> (),
	moveSpectatorsToPlaying: () -> (),
	remove: (player: Player) -> (),
	start: () -> (),
}

type BombModule = {
	give: (playingPlayers: {Player}) -> (),
	isCarriedBy: (character: Model) -> boolean,
	removeFrom: (character: Model) -> (),
	start: () -> (),
}

type GameMapModule = {
	clear: () -> (),
	create: () -> (),
	beginRound: (playing: {Player}) -> (),
	characterRoot: (player: Player) -> BasePart?,
	spectateCFrame: () -> CFrame,
	start: () -> (),
}

local function requireModule(name: string): any
	local child = ServerScriptService:WaitForChild(name)
	if not child:IsA("ModuleScript") then
		error(name .. " is not a ModuleScript")
	end
	return require(child)
end

local Bomb = requireModule("Bomb") :: BombModule
local Notice = requireModule("Notice") :: NoticeModule
local PlayerLists = requireModule("PlayerLists") :: PlayerListsModule
local GameMap = requireModule("GameMap") :: GameMapModule

local playingPlayers = PlayerLists.playing()
local spectators = PlayerLists.spectators()

local diedEvent = ReplicatedStorage:WaitForChild("DiedEvent")
if not diedEvent:IsA("RemoteEvent") then
	error("DiedEvent must be a RemoteEvent")
end
local DiedEvent: RemoteEvent = diedEvent
local MINIMUM_PLAYERS = 2
local restart = false
local matchLive = false
local resolving = false

local function newGame()
	for _, player in Players:GetPlayers() do
		Notice.set(player, "Reinitializing match")
	end

	GameMap.clear()
	matchLive = false
	task.wait(1)

	restart = true
end

local function someoneCarriesBomb(): boolean
	for _, player in playingPlayers do
		local character = player.Character
		if character ~= nil and Bomb.isCarriedBy(character) then
			return true
		end
	end
	return false
end

local function onGame()
	if not matchLive or resolving then
		return
	end
	resolving = true

	local remaining = #playingPlayers
	if remaining >= 2 and not someoneCarriesBomb() then
		Bomb.give(playingPlayers)
	end

	for _, player in Players:GetPlayers() do
		Notice.set(player, "Remains " .. remaining .. " Players")
	end

	if remaining == 1 then
		matchLive = false
		local winner = playingPlayers[1]
		assert(winner ~= nil, "Winner is missing")
		local character = winner.Character
		if character ~= nil then
			Bomb.removeFrom(character)
		end

		for _, player in Players:GetPlayers() do
			Notice.set(player, winner.Name .. " Won the game!")
		end

		task.wait(5)

		PlayerLists.remove(winner)
		PlayerLists.addSpectator(winner)
		local root = GameMap.characterRoot(winner)
		local humanoid = if character ~= nil then character:FindFirstChildOfClass("Humanoid") else nil
		if root ~= nil then
			root.CFrame = GameMap.spectateCFrame()
		end
		if humanoid ~= nil then
			humanoid.WalkSpeed = 22
		end
		table.clear(playingPlayers)

		task.wait(3)

		newGame()
	elseif remaining == 0 then
		matchLive = false
		for _, player in Players:GetPlayers() do
			Notice.set(player, "No one won the game!")
		end
		table.clear(playingPlayers)

		task.wait(3)

		newGame()
	end

	resolving = false
end

local function readySpectators(): number
	local ready = 0
	for _, player in spectators do
		if player.Character ~= nil then
			ready += 1
		end
	end
	return ready
end

local function returnPlayingToSpectators()
	local returning = table.clone(playingPlayers)
	for _, player in returning do
		PlayerLists.remove(player)
		PlayerLists.addSpectator(player)
	end
end

local function startGame()
	for _, player in Players:GetPlayers() do
		Notice.set(player, "Waiting for Players")
	end

	task.wait(20)

	while true do
		if readySpectators() >= MINIMUM_PLAYERS then
			PlayerLists.moveSpectatorsToPlaying()
			if #playingPlayers >= MINIMUM_PLAYERS then
				break
			end
			returnPlayingToSpectators()
		end
		task.wait(1)
	end

	for _, player in Players:GetPlayers() do
		Notice.set(player, "Starting Match")
	end

	GameMap.create()
	GameMap.beginRound(playingPlayers)
	matchLive = true
	onGame()
end

function Round.start()
	DiedEvent.OnServerEvent:Connect(function(player: Player)
		local character = player.Character
		local humanoid = if character ~= nil then character:FindFirstChildOfClass("Humanoid") else nil
		if character ~= nil and (humanoid == nil or humanoid.Health > 0) then
			return
		end

		if character ~= nil then
			Bomb.removeFrom(character)
		end
		PlayerLists.remove(player)
		PlayerLists.addSpectator(player)
		onGame()
	end)

	Players.PlayerRemoving:Connect(function(_player: Player)
		onGame()
	end)

	startGame()

	while task.wait(1) do
		if restart == true then
			restart = false
			startGame()
		elseif matchLive then
			onGame()
		end
	end
end

return Round
