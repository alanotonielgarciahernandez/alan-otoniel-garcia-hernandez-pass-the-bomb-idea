local PlrSer = game:GetService("Players");
local RepStor = game:GetService("ReplicatedStorage");
local Teams = game:GetService("Teams");
local spect = {};
local plrst = {};

local Map = RepStor:WaitForChild("Map");
local Spawns = RepStor:WaitForChild("Spawns");

local function setBomb(plrs)
	local randomplr = math.random(1, #plrs);
	local bombchar = plrs[randomplr].Character;
	bombchar.Humanoid.WalkSpeed = 30;
	
	local bomb = RepStor:WaitForChild("Bomb"):Clone();
	local weld = Instance.new("WeldConstraint");
	weld.Part0 = bombchar.RightHand;
	weld.Part1 = bomb;
	weld.Parent = bomb;
	
	bomb.plrname.Value = bombchar.Name;
	bomb.CFrame = bombchar.RightHand.CFrame;
	bomb.Parent = bombchar;
	bomb.BombScript.Disabled = false;
end;

PlrSer.PlayerAdded:Connect(function(plr)
	plr.CharacterAdded:Connect(function(char)
		char.Humanoid.WalkSpeed = 22;
		char.Humanoid.JumpHeight = 0;
		char.HumanoidRootPart.CFrame = game.Workspace.Baseplate.Spectate.CFrame;
	end);
	table.insert(spect, plr);
	plr.Team = game.Teams.Spectating;
end);

wait(5);

while true do
	
	local NewMap = Map:Clone();
	NewMap.Parent = game.Workspace;
	local NewSpawns = Spawns:Clone();
	NewSpawns.Parent = game.Workspace;
	
	local Towers = {game.Workspace.Map.BackBridge1;game.Workspace.Map.BackBridge1A;game.Workspace.Map.BackBridge2;game.Workspace.Map.BackBridge2B;game.Workspace.Map.BackTower;game.Workspace.Map.BackTower1;game.Workspace.Map.BackTower2;game.Workspace.Map.FrontBridge1;game.Workspace.Map.FrontBridge1A;game.Workspace.Map.FrontBridge2;game.Workspace.Map.FrontBridge2B;game.Workspace.Map.FrontTower;game.Workspace.Map.FrontTower1;game.Workspace.Map.FrontTower2;game.Workspace.Map.LeftTower;game.Workspace.Map.RightTower;};
	local Spowns = {game.Workspace.Spawns.Back;game.Workspace.Spawns.Back1;game.Workspace.Spawns.Back2;game.Workspace.Spawns.Front;game.Workspace.Spawns.Front1;game.Workspace.Spawns.Front2;game.Workspace.Spawns.Left;game.Workspace.Spawns.Right;}
	
	for i, plr in pairs(PlrSer:GetPlayers()) do
		plr.PlayerGui.Notice.TextLabel.Text = "Waiting for Players";
	end;
	
	repeat wait(.2); until #spect > 1;
	
	pcall(function ()
		for i, plr in pairs(PlrSer:GetPlayers()) do
			plr.PlayerGui.Notice.TextLabel.Text = "Starting Match";
		end;
	end);
	
	wait(5);
	
	pcall(function()
		for i, plr in pairs(PlrSer:GetPlayers()) do
			if plr.Character then
				table.insert(plrst, plr);
				plr.Team = game.Teams.Playing;
			end;
		end;
		table.clear(spect);
	end);
	
	if #plrst <= 5 then
		pcall(function()
			local newSky = RepStor:WaitForChild("WarSky"):Clone();
			newSky.Parent = game.Lighting;
			for i, twr in pairs(Towers) do
				twr:Destroy();
			end;
			for i, spwn in pairs(Spowns) do
				spwn:Destroy();
			end;
			for i, plr in pairs(plrst) do
				plr.Character.HumanoidRootPart.CFrame = game.Workspace.Spawns.Center.CFrame;
			end;
		end);
	else pcall(function()
			local newSky = RepStor:WaitForChild("Sky"):Clone();
			newSky.Parent = game.Lighting;
			for i, plr in pairs(PlrSer:GetPlayers()) do
				plr.Character.HumanoidRootPart.CFrame = Spowns[i].CFrame;
			end;
		end);
	end;

	pcall(function()
		setBomb(plrst);
	end);

	local confirmarbomba = false;

	while true do
		pcall(function()
			for i, plr in pairs(plrst) do
				if plr.Character then
					if plr.Character.Humanoid.Health == 0 then
						table.remove(plrst, i);
						table.insert(spect, plr);
						plr.Team = game.Teams.Spectating;
					end;
				else table.remove(plrst, i);
				end;
			end;
		end);
		
		confirmarbomba = false;
		for i, plr in pairs(plrst) do
			if plr.Character and plr.Character:FindFirstChild("Bomb") then
				confirmarbomba = true
			end;
		end;

		if confirmarbomba == false then
			if #plrst >= 2 then
				pcall(function()
					setBomb(plrst);
				end);
			end;
		end;

		for i, plr in pairs(PlrSer:GetPlayers()) do
			plr.PlayerGui:WaitForChild("Notice").TextLabel.Text = "Remains ".. #plrst.. " Players";
			wait(.1);
		end;
		if #plrst == 1 then
			pcall(function()
				if plrst[1].Character.Bomb then
					plrst[1].Character.Bomb:Destroy();
				end;
			end);
			for i, plr in pairs(PlrSer:GetPlayers()) do
				plr.PlayerGui.Notice.TextLabel.Text = plrst[1].Name.. " Won the game!";
			end;
			wait(5);
			plrst[1].Team = game.Teams.Spectating;
			table.insert(spect, plrst[1]);
			plrst[1].Character.HumanoidRootPart.CFrame = game.Workspace.Baseplate.Spectate.CFrame;
			table.clear(plrst);
			break;
		elseif #plrst == 0 then
			for i, plr in pairs(PlrSer:GetPlayers()) do
				plr.PlayerGui.Notice.TextLabel.Text = "No one won the game!";
			end;
			table.clear(plrst);
			wait(3);
			break;
		end;
	end;
	for i, plr in pairs(PlrSer:GetPlayers()) do
		plr.PlayerGui.Notice.TextLabel.Text = "Reinitialazing match";
	end;
	if game.Lighting.WarSky then
		game.Lighting.WarSky:Destroy();
	end;
	NewMap:Destroy();
	NewSpawns:Destroy();
	confirmarbomba = false;
	wait(1);
end;
