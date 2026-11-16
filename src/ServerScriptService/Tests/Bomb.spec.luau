--!strict

local CollectionService = game:GetService("CollectionService")
local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")

local Bomb = require(ServerScriptService:WaitForChild("Bomb"))

local BOMB_TAG = "Bomb"

local function makeHolder(): Folder
	local holder = Instance.new("Folder")
	holder.Name = "BombTestHolder"
	holder.Parent = ServerStorage
	return holder
end

local function makeCharacter(holder: Folder): Model
	local character = Instance.new("Model")
	character.Name = "BombTestCharacter"
	character.Parent = holder
	return character
end

local function makeTaggedBomb(): Part
	local bomb = Instance.new("Part")
	bomb.Name = "TaggedBomb"
	CollectionService:AddTag(bomb, BOMB_TAG)
	return bomb
end

return {
	{
		name = "isCarriedBy is false when the character has no tagged bomb",
		run = function()
			local holder = makeHolder()
			local character = makeCharacter(holder)
			local ok, err = pcall(function()
				assert(Bomb.isCarriedBy(character) == false, "expected no carried bomb")
			end)
			holder:Destroy()
			if not ok then
				error(err, 0)
			end
		end,
	},
	{
		name = "isCarriedBy ignores a child that is not tagged",
		run = function()
			local holder = makeHolder()
			local character = makeCharacter(holder)
			local bomb = Instance.new("Part")
			bomb.Name = "Bomb"
			bomb.Parent = character
			local ok, err = pcall(function()
				assert(Bomb.isCarriedBy(character) == false, "untagged child counted as a bomb")
			end)
			holder:Destroy()
			if not ok then
				error(err, 0)
			end
		end,
	},
	{
		name = "isCarriedBy is true when a tagged bomb is parented to the character",
		run = function()
			local holder = makeHolder()
			local character = makeCharacter(holder)
			local bomb = makeTaggedBomb()
			bomb.Parent = character
			local ok, err = pcall(function()
				assert(Bomb.isCarriedBy(character) == true, "expected a carried bomb")
			end)
			holder:Destroy()
			if not ok then
				error(err, 0)
			end
		end,
	},
	{
		name = "removeFrom destroys only the tagged bomb on that character",
		run = function()
			local holder = makeHolder()
			local character = makeCharacter(holder)
			local other = makeCharacter(holder)
			local carried = makeTaggedBomb()
			local elsewhere = makeTaggedBomb()
			carried.Parent = character
			elsewhere.Parent = other
			local ok, err = pcall(function()
				Bomb.removeFrom(character)
				assert(carried.Parent == nil, "carried bomb was not destroyed")
				assert(elsewhere.Parent == other, "a bomb on another character was destroyed")
				assert(Bomb.isCarriedBy(character) == false, "character still counted as carrying a bomb")
			end)
			holder:Destroy()
			if elsewhere.Parent ~= nil then
				elsewhere:Destroy()
			end
			if not ok then
				error(err, 0)
			end
		end,
	},
}
