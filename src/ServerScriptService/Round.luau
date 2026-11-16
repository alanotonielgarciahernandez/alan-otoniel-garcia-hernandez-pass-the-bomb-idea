--!strict

local Round = {}

local CollectionService = game:GetService("CollectionService")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Teams = game:GetService("Teams")
local Workspace = game:GetService("Workspace")

local playingPlayers: {Player} = {}
local spectators: {Player} = {}
local excludeNames: {string} = {"CenterTower", "FrontBridge", "RightBridge", "BackBridge", "LeftBridge", "Center"}
local restart = false

local function requireInstance(parent: Instance, name: string): Instance
	local child = parent:WaitForChild(name)
	return child
end

local function requireBasePart(parent: Instance, name: string): BasePart
	local child = parent:WaitForChild(name)
	if not child:IsA("BasePart") then
		error(name .. " must be a BasePart")
	end
	return child
end

local function requireTeam(name: string): Team
	local child = Teams:FindFirstChild(name)
	if child == nil or not child:IsA("Team") then
		error(name .. " team is missing")
	end
	return child
end

local playingTeam = requireTeam("Playing")
local spectatingTeam = requireTeam("Spectating")

local gameFolder = requireInstance(Workspace, "Game_Folder")
local diedEvent = requireInstance(ReplicatedStorage, "DiedEvent")
if not diedEvent:IsA("RemoteEvent") then
	error("DiedEvent must be a RemoteEvent")
end
local DiedEvent: RemoteEvent = diedEvent
local Bomb = requireInstance(ServerStorage, "Bomb")
local Map = requireInstance(ServerStorage, "Map")
local Spawns = requireInstance(ServerStorage, "Spawns")
local Sky = requireInstance(ServerStorage, "Sky")
local WarSky = requireInstance(ServerStorage, "WarSky")
if not Sky:IsA("Sky") or not WarSky:IsA("Sky") then
	error("Sky templates must be Sky instances")
end
local isBomb = false

local function setNotice(player: Player, text: string)
	local gui = player.PlayerGui:FindFirstChild("Notice")
	if gui == nil then
		return
	end
	local label = gui:FindFirstChild("TextLabel")
	if label ~= nil and label:IsA("TextLabel") then
		label.Text = text
	end
end

local function characterRoot(player: Player): BasePart?
	local character = player.Character
	if character == nil then
		return nil
	end
	local root = character:FindFirstChild("HumanoidRootPart")
	if root ~= nil and root:IsA("BasePart") then
		return root
	end
	return nil
end

local function addPlayerToSpectators(player: Player)
	table.insert(spectators, player)
	player.Team = spectatingTeam
end

local function moveSpectatorsToPlaying()
	for _, player in spectators do
		if player.Character then
			table.insert(playingPlayers, player)
			player.Team = playingTeam
		end
	end
	table.clear(spectators)
end

local function removePlayer(player: Player)
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
	local plrname = bomb:FindFirstChild("plrname")
	if plrname == nil or not plrname:IsA("StringValue") then
		error("Bomb is missing plrname")
	end

	humanoid.WalkSpeed = 30

	local weld = Instance.new("WeldConstraint")
	weld.Part0 = rightHand
	weld.Part1 = bomb
	weld.Parent = bomb

	plrname.Value = character.Name
	bomb.CFrame = rightHand.CFrame
	bomb.Parent = character
	CollectionService:AddTag(bomb, "Bomb")
end

local function createMap()
	local newMap = Map:Clone()
	local newSpawns = Spawns:Clone()
	newMap.Parent, newSpawns.Parent = gameFolder, gameFolder
end

local function newGame()
	for _, player in Players:GetPlayers() do
		setNotice(player, "Reinitialazing match")
	end

	local activeWarSky = Lighting:FindFirstChild("WarSky")
	if activeWarSky ~= nil then
		activeWarSky:Destroy()
	end

	gameFolder:ClearAllChildren()
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
		setNotice(player, "Remains " .. #playingPlayers .. " Players")
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
			setNotice(player, winner.Name .. " Won the game!")
		end

		task.wait(5)

		winner.Team = spectatingTeam
		table.insert(spectators, winner)
		local root = characterRoot(winner)
		local humanoid = if character ~= nil then character:FindFirstChildOfClass("Humanoid") else nil
		if root ~= nil then
			root.CFrame = requireBasePart(requireInstance(Workspace, "Baseplate"), "Spectate").CFrame
		end
		if humanoid ~= nil then
			humanoid.WalkSpeed = 22
		end
		table.clear(playingPlayers)

		task.wait(3)

		newGame()

	elseif #playingPlayers == 0 then
		for _, player in Players:GetPlayers() do
			setNotice(player, "No one won the game!")
		end
		table.clear(playingPlayers)

		task.wait(3)

		newGame()
	end
end

local function destroyChildrenExcept(parent: Instance)
	for _, child in parent:GetChildren() do
		if table.find(excludeNames, child.Name) == nil then
			child:Destroy()
		end
	end
end

local function startGame()
	for _, player in Players:GetPlayers() do
		setNotice(player, "Waiting for Players")
	end

	task.wait(20)

	repeat
		task.wait(1)
	until #spectators >= 1

	for _, player in Players:GetPlayers() do
		setNotice(player, "Starting Match")
	end

	moveSpectatorsToPlaying()
	createMap()

	local spawnedMap = gameFolder:FindFirstChild("Map")
	local spawnedSpawns = gameFolder:FindFirstChild("Spawns")
	if spawnedMap == nil or spawnedSpawns == nil then
		error("Cloned map or spawns are missing")
	end

	if #playingPlayers < 5 then
		local newSky = WarSky:Clone()
		newSky.Parent = Lighting
		destroyChildrenExcept(spawnedMap)
		destroyChildrenExcept(spawnedSpawns)
		local center = spawnedSpawns:FindFirstChild("Center")
		if center == nil or not center:IsA("BasePart") then
			error("Center spawn must be a BasePart")
		end
		for _, player in playingPlayers do
			local root = characterRoot(player)
			if root ~= nil then
				root.CFrame = center.CFrame
			end
		end
	else
		local newSky = Sky:Clone()
		newSky.Parent = Lighting
		local spawnList = spawnedSpawns:GetChildren()
		for index, player in Players:GetPlayers() do
			local spawn = spawnList[index]
			local root = characterRoot(player)
			if spawn ~= nil and spawn:IsA("BasePart") and root ~= nil then
				root.CFrame = spawn.CFrame
			end
		end
	end

	onGame()
end

function Round.start()
	Players.PlayerAdded:Connect(function(player: Player)
		addPlayerToSpectators(player)
	end)
	Players.PlayerRemoving:Connect(function(player: Player)
		removePlayer(player)
	end)

	DiedEvent.OnServerEvent:Connect(function(player: Player)
		local character = player.Character
		local humanoid = if character ~= nil then character:FindFirstChildOfClass("Humanoid") else nil
		if character ~= nil and (humanoid == nil or humanoid.Health > 0) then
			return
		end

		removePlayer(player)
		table.insert(spectators, player)
		player.Team = spectatingTeam
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
