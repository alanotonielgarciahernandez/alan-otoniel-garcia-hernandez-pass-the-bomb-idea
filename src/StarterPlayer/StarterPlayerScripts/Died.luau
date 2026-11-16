--!strict

local Died = {}

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

function Died.start()
	local player = Players.LocalPlayer
	local diedEvent = ReplicatedStorage:WaitForChild("DiedEvent")
	if not diedEvent:IsA("RemoteEvent") then
		error("DiedEvent must be a RemoteEvent")
	end

	local connected: { [Model]: boolean } = {}

	local function connectCharacter(character: Model)
		if connected[character] then
			return
		end
		connected[character] = true

		local humanoid = character:WaitForChild("Humanoid")
		if not humanoid:IsA("Humanoid") then
			error("Humanoid is missing")
		end

		humanoid.Died:Connect(function()
			diedEvent:FireServer()
		end)
	end

	player.CharacterAdded:Connect(connectCharacter)
	if player.Character ~= nil then
		connectCharacter(player.Character)
	end
end

return Died
