--!strict

local Died = {}

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

function Died.start()
	local player = Players.LocalPlayer
	local character = player.CharacterAdded:Wait()
	local humanoid = character:WaitForChild("Humanoid")
	if not humanoid:IsA("Humanoid") then
		error("Humanoid is missing")
	end

	local diedEvent = ReplicatedStorage:WaitForChild("DiedEvent")
	if not diedEvent:IsA("RemoteEvent") then
		error("DiedEvent must be a RemoteEvent")
	end

	humanoid.Died:Connect(function()
		diedEvent:FireServer()
		player.CharacterAdded:Wait()
		local nextCharacter = player.Character
		if nextCharacter == nil then
			error("Character is missing")
		end
		nextCharacter:WaitForChild("Humanoid")
	end)
end

return Died
