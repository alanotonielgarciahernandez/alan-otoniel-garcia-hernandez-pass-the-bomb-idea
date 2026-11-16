--!strict

local GameMap = {}

local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")
local Workspace = game:GetService("Workspace")

local excludeNames: {string} = {"CenterTower", "FrontBridge", "RightBridge", "BackBridge", "LeftBridge", "Center"}

local gameFolder: Instance? = nil
local mapTemplate: Instance? = nil
local spawnsTemplate: Instance? = nil
local skyTemplate: Sky? = nil
local warSkyTemplate: Sky? = nil

local function requireInstance(parent: Instance, name: string): Instance
	return parent:WaitForChild(name)
end

local function requireBasePart(parent: Instance, name: string): BasePart
	local child = parent:WaitForChild(name)
	if not child:IsA("BasePart") then
		error(name .. " must be a BasePart")
	end
	return child
end

function GameMap.characterRoot(player: Player): BasePart?
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

local SPECTATE_CLEARANCE = 5

function GameMap.spectateCFrame(): CFrame
	local spectate = requireBasePart(requireInstance(Workspace, "Baseplate"), "Spectate")
	local aboveTop = spectate.Size.Y / 2 + SPECTATE_CLEARANCE
	return spectate.CFrame * CFrame.new(0, aboveTop, 0)
end

function GameMap.clear()
	assert(gameFolder ~= nil, "GameMap.start was not called")
	local activeWarSky = Lighting:FindFirstChild("WarSky")
	if activeWarSky ~= nil then
		activeWarSky:Destroy()
	end
	gameFolder:ClearAllChildren()
end

function GameMap.create()
	assert(gameFolder ~= nil and mapTemplate ~= nil and spawnsTemplate ~= nil, "GameMap.start was not called")
	local newMap = mapTemplate:Clone()
	local newSpawns = spawnsTemplate:Clone()
	newMap.Parent, newSpawns.Parent = gameFolder, gameFolder
end

local function destroyChildrenExcept(parent: Instance)
	for _, child in parent:GetChildren() do
		if table.find(excludeNames, child.Name) == nil then
			child:Destroy()
		end
	end
end

function GameMap.beginRound(playing: {Player})
	assert(gameFolder ~= nil and skyTemplate ~= nil and warSkyTemplate ~= nil, "GameMap.start was not called")
	local spawnedMap = gameFolder:FindFirstChild("Map")
	local spawnedSpawns = gameFolder:FindFirstChild("Spawns")
	if spawnedMap == nil or spawnedSpawns == nil then
		error("Cloned map or spawns are missing")
	end

	if #playing < 5 then
		local newSky = warSkyTemplate:Clone()
		newSky.Parent = Lighting
		destroyChildrenExcept(spawnedMap)
		destroyChildrenExcept(spawnedSpawns)
		local center = spawnedSpawns:FindFirstChild("Center")
		if center == nil or not center:IsA("BasePart") then
			error("Center spawn must be a BasePart")
		end
		for _, player in playing do
			local root = GameMap.characterRoot(player)
			if root ~= nil then
				root.CFrame = center.CFrame
			end
		end
	else
		local newSky = skyTemplate:Clone()
		newSky.Parent = Lighting
		local spawnList = spawnedSpawns:GetChildren()
		for index, player in Players:GetPlayers() do
			local spawn = spawnList[index]
			local root = GameMap.characterRoot(player)
			if spawn ~= nil and spawn:IsA("BasePart") and root ~= nil then
				root.CFrame = spawn.CFrame
			end
		end
	end
end

function GameMap.start()
	gameFolder = requireInstance(Workspace, "Game_Folder")
	mapTemplate = requireInstance(ServerStorage, "Map")
	spawnsTemplate = requireInstance(ServerStorage, "Spawns")
	local sky = requireInstance(ServerStorage, "Sky")
	local warSky = requireInstance(ServerStorage, "WarSky")
	if not sky:IsA("Sky") or not warSky:IsA("Sky") then
		error("Sky templates must be Sky instances")
	end
	skyTemplate = sky
	warSkyTemplate = warSky
end

return GameMap
