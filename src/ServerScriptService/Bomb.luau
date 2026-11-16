local BombService = {}

local CollectionService = game:GetService("CollectionService");
local ServerStorage = game:GetService("ServerStorage");

local BOMB_TAG = "Bomb";
local bombTemplate = ServerStorage:WaitForChild("Bomb");

local function runBomb(bomb)
	if bomb:GetAttribute("BombStarted") then
		return;
	end;
	bomb:SetAttribute("BombStarted", true);

	local light = bomb.PointLight;
	local beep = bomb.beep;
	local explosion = bomb.explosionsound;
	local plrname = bomb.plrname;
	local bombtime = bomb.bombtime;
	local G = bomb.G;
	local B = bomb.B;
	local db = bomb.db;

	bomb.Touched:Connect(function(hit)
		if hit.Parent.Name ~= plrname.Value and hit.Parent:FindFirstChild("Humanoid") and db.Value == false then
			db.Value = true;
			bomb.Parent.Humanoid.WalkSpeed = 22;
			local newBomb = bombTemplate:Clone();
			newBomb.bombtime.Value = bomb.bombtime.Value;
			newBomb.G.Value = G.Value;
			newBomb.B.Value = B.Value;

			local weld = Instance.new("WeldConstraint");
			weld.Part0 = hit.Parent.RightHand;
			weld.Part1 = newBomb;
			weld.Parent = newBomb;

			bomb:Destroy();

			newBomb.plrname.Value = hit.Parent.Name;
			newBomb.db.Value = true;
			newBomb.CFrame = hit.Parent.RightHand.CFrame;
			newBomb.Parent = hit.Parent;
			newBomb.Parent.Humanoid.WalkSpeed = 30;
			CollectionService:AddTag(newBomb, BOMB_TAG);
			task.wait(2);
			if newBomb.Parent ~= nil then
				newBomb.db.Value = false;
			end;
		end;
	end);

	task.spawn(function()
		for i = bombtime.Value, 0, -.05 do
			if bomb.Parent == nil then
				return;
			end;
			if bombtime.Value > 0 then
				bombtime.Value = i;
				light.Enabled = false;
				light.Color = Color3.fromRGB(255, G.Value, B.Value);
				bomb.Color = Color3.fromRGB(255, G.Value / 2, B.Value / 2);
				G.Value += -10;
				B.Value += -10;
				task.wait(i/2);
				if bomb.Parent == nil then
					return;
				end;
				light.Enabled = true;
				beep:Play();
				task.wait(i/2);
			else
				break;
			end;
		end;

		if bomb.Parent == nil then
			return;
		end;

		light.Color = Color3.fromRGB(255, G.Value, B.Value);
		bomb.Color = Color3.fromRGB(255, G.Value / 2, B.Value / 2);

		for i = 1, 20 do
			if bomb.Parent == nil then
				return;
			end;
			beep:Play();
			task.wait(.1);
		end;

		if bomb.Parent == nil then
			return;
		end;

		local bum = Instance.new("Explosion");
		bum.Position = bomb.Position;
		bum.BlastRadius = 5;
		bum.Parent = bomb;
		explosion:Play();
		task.wait(2);
		if bomb.Parent ~= nil then
			bomb:Destroy();
		end;
	end);
end;

function BombService.start()
	CollectionService:GetInstanceAddedSignal(BOMB_TAG):Connect(runBomb);
	for _, bomb in CollectionService:GetTagged(BOMB_TAG) do
		runBomb(bomb);
	end;
end;

return BombService
