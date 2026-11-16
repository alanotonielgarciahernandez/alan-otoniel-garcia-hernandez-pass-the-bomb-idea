--!strict

local ServerScriptService = game:GetService("ServerScriptService")

type ServerModule = {
	start: () -> (),
}

local function requireServerModule(name: string): ServerModule
	local child = ServerScriptService:WaitForChild(name)
	if not child:IsA("ModuleScript") then
		error(name .. " is not a ModuleScript")
	end

	return require(child) :: ServerModule
end

local Bomb = requireServerModule("Bomb")
local GameMap = requireServerModule("GameMap")
local Notice = requireServerModule("Notice")
local PlayerLists = requireServerModule("PlayerLists")
local Round = requireServerModule("Round")

Notice.start()
PlayerLists.start()
GameMap.start()
Bomb.start()
Round.start()
