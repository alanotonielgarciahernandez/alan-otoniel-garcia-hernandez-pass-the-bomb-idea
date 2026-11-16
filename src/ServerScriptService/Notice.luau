--!strict

local Notice = {}

function Notice.set(player: Player, text: string)
	local gui = player.PlayerGui:FindFirstChild("Notice")
	if gui == nil then
		return
	end
	local label = gui:FindFirstChild("TextLabel")
	if label ~= nil and label:IsA("TextLabel") then
		label.Text = text
	end
end

function Notice.start()
end

return Notice
