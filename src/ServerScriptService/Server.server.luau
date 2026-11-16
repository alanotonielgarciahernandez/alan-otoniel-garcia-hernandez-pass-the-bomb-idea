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
local Round = requireServerModule("Round")

Bomb.start()
Round.start()
