--!strict

local Tests = {}

local function ensureTeam(name: string)
	local Teams = game:GetService("Teams")
	local existing = Teams:FindFirstChild(name)
	if existing ~= nil and existing:IsA("Team") then
		return
	end
	local team = Instance.new("Team")
	team.Name = name
	team.Parent = Teams
end

function Tests.start()
	ensureTeam("Playing")
	ensureTeam("Spectating")

	local passed = 0
	local failed = {}
	for _, child in script:GetChildren() do
		if child:IsA("ModuleScript") then
			local cases = require(child)
			for _, case in cases do
				local ok, err = pcall(case.run)
				if ok then
					passed += 1
				else
					table.insert(failed, child.Name .. " / " .. case.name .. ": " .. tostring(err))
				end
			end
		end
	end

	if #failed > 0 then
		error(table.concat(failed, "\n"))
	end
	print(passed .. " tests passed")
end

return Tests
