--!strict

local StarterPlayerScripts = script.Parent

local diedModule = StarterPlayerScripts:WaitForChild("Died")
if not diedModule:IsA("ModuleScript") then
	error("Died is not a ModuleScript")
end

local Died = require(diedModule) :: { start: () -> () }
Died.start()
