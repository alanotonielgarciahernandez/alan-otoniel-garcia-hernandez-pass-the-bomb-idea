--!strict

local Round = {}

local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")

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
local Bomb = ServerStorage:WaitForChild("Bomb")
local isBomb = false
local restart = false

local function setBomb()
	local carrier = playingPlayers[math.random(1, #playingPlayers)]
	if carrier == nil then
		return
	end
	local character = carrier.Character
	if character == nil then
		return
	end
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	local rightHand = character:FindFirstChild("RightHand")
	if humanoid == nil or rightHand == nil or not rightHand:IsA("BasePart") then
		return
	end

	local bomb = Bomb:Clone()
	if not bomb:IsA("BasePart") then
		error("Bomb clone must be a BasePart")
	end
	local playerName = bomb:FindFirstChild("plrname")
	if playerName == nil or not playerName:IsA("StringValue") then
		error("Bomb is missing plrname")
	end

	humanoid.WalkSpeed = 30

	local weld = Instance.new("WeldConstraint")
	weld.Part0 = rightHand
	weld.Part1 = bomb
	weld.Parent = bomb

	playerName.Value = character.Name
	bomb.CFrame = rightHand.CFrame
	bomb.Parent = character
	CollectionService:AddTag(bomb, "Bomb")
end

local function newGame()
	for _, player in Players:GetPlayers() do
		Notice.set(player, "Reinitialazing match")
	end

	GameMap.clear()
	isBomb = false
	task.wait(1)

	restart = true
end

local function onGame()
	for _, player in playingPlayers do
		local character = player.Character
		if character ~= nil and character:FindFirstChild("Bomb") ~= nil then
			isBomb = true
		end
	end

	if isBomb == false and #playingPlayers >= 1 then
		setBomb()
	end

	for _, player in Players:GetPlayers() do
		Notice.set(player, "Remains " .. #playingPlayers .. " Players")
	end

	if #playingPlayers == 1 then
		local winner = playingPlayers[1]
		assert(winner ~= nil, "Winner is missing")
		local character = winner.Character
		if character ~= nil then
			local bomb = character:FindFirstChild("Bomb")
			if bomb ~= nil then
				bomb:Destroy()
			end
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
	elseif #playingPlayers == 0 then
		for _, player in Players:GetPlayers() do
			Notice.set(player, "No one won the game!")
		end
		table.clear(playingPlayers)

		task.wait(3)

		newGame()
	end
end

local function startGame()
	for _, player in Players:GetPlayers() do
		Notice.set(player, "Waiting for Players")
	end

	task.wait(20)

	repeat
		task.wait(1)
	until #spectators >= 1

	for _, player in Players:GetPlayers() do
		Notice.set(player, "Starting Match")
	end

	PlayerLists.moveSpectatorsToPlaying()
	GameMap.create()
	GameMap.beginRound(playingPlayers)
	onGame()
end

function Round.start()
	DiedEvent.OnServerEvent:Connect(function(player: Player)
		local character = player.Character
		local humanoid = if character ~= nil then character:FindFirstChildOfClass("Humanoid") else nil
		if character ~= nil and (humanoid == nil or humanoid.Health > 0) then
			return
		end

		PlayerLists.remove(player)
		PlayerLists.addSpectator(player)
	end)

	startGame()

	while task.wait(1) do
		if restart == true then
			restart = false
			startGame()
		end
	end
end

return Round
