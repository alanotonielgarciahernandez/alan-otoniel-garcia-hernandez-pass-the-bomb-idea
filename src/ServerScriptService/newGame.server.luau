-- Servicios
local Players = game:GetService("Players");
local RepStor = game:GetService("ReplicatedStorage");
local Teams = game:GetService("Teams");

-- Variables
local plrs = {};
local spects = {};
local excludeNames = {"CenterTower", "FrontBridge", "RightBridge", "BackBridge", "LeftBridge", "Center"};
local restart = false;

local gameFolder = game.Workspace.Game_Folder;
local DiedEvent = RepStor:WaitForChild("DiedEvent");
local Map = RepStor:WaitForChild("Map");
local Spawns = RepStor:WaitForChild("Spawns");
local Sky = RepStor:WaitForChild("Sky");
local WarSky = RepStor:WaitForChild("WarSky");
local isBomb = false;

-- Funciones
local function addPlrToSpectsList(plr)
	table.insert(spects, plr);
	plr.Team = Teams.Spectating;
end;

local function addPlrsToPlrsList()
	for i, v in pairs(spects) do
		if v.Character then
			table.insert(plrs, v);
			v.Team = Teams.Playing;
		end;
	end;
	table.clear(spects);
end;

local function removePlrFromList(plr)
	if table.find(plrs, plr) ~= nil then
		table.remove(plrs, table.find(plrs, plr));
	else
		table.remove(spects, table.find(spects, plr));
	end
end;

local function setBomb()
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

local function createMap()
	local newMap = Map:Clone();
	local newSpawns = Spawns:Clone();
	newMap.Parent, newSpawns.Parent = gameFolder, gameFolder;
end;

local function newGame()
	for i, v in pairs(Players:GetPlayers()) do
		local gui = v.PlayerGui:FindFirstChild("Notice");
		if gui then
			gui.TextLabel.Text = "Reinitialazing match";
		end;
	end;

	if game.Lighting.WarSky then
		game.Lighting.WarSky:Destroy();
	end;

	gameFolder:ClearAllChildren();
	isBomb = false;
	wait(1);
	
	restart = true;
end;

local function onGame()
	for i, plr in pairs(plrs) do
		if plr.Character and plr.Character:FindFirstChild("Bomb") then
			isBomb = true
		end;
	end;

	if isBomb == false and #plrs >= 1 then
		setBomb();
	end;

	for i, v in pairs(Players:GetPlayers()) do
		local gui = v.PlayerGui:FindFirstChild("Notice");
		if gui then
			gui.TextLabel.Text = "Remains ".. #plrs.. " Players";
		end;
	end;

	if #plrs == 1 then
		if plrs[1].Character.Bomb then
			plrs[1].Character.Bomb:Destroy();
		end;

		for i, v in pairs(Players:GetPlayers()) do
			local gui = v.PlayerGui:FindFirstChild("Notice");
			if gui then
				gui.TextLabel.Text = plrs[1].Name.. " Won the game!";
			end;
		end;

		wait(5);

		plrs[1].Team = game.Teams.Spectating;
		table.insert(spects, plrs[1]);
		plrs[1].Character.HumanoidRootPart.CFrame = game.Workspace.Baseplate.Spectate.CFrame;
		plrs[1].Character.Humanoid.WalkSpeed = 22;
		table.clear(plrs);
		
		wait(3);
		
		newGame();

	elseif #plrs == 0 then
		for i, v in pairs(Players:GetPlayers()) do
			local gui = v.PlayerGui:FindFirstChild("Notice");
			if gui then
				gui.TextLabel.Text = "No one won the game!";
			end;
		end;
		table.clear(plrs);

		wait(3);
		
		newGame();
	end;
end;

local function startGame()
	for i, v in pairs(Players:GetPlayers()) do
		local gui = v.PlayerGui:FindFirstChild("Notice");
		if gui then
			gui.TextLabel.Text = "Waiting for Players";
		end;
	end;
	
	wait(20)
	
	repeat wait(1); until #spects >= 1
		
	for i, v in pairs(Players:GetPlayers()) do
		local gui = v.PlayerGui:FindFirstChild("Notice");
		if gui then
			gui.TextLabel.Text = "Starting Match";
		end;
	end;
	
	addPlrsToPlrsList();
	createMap();
	
	if #plrs < 5 then
		local newSky = WarSky:Clone();
		newSky.Parent = game.Lighting;
		for i, v in pairs(gameFolder.Map:GetChildren()) do
			if table.find(excludeNames, v.Name) == nil then
				v:Destroy();
			end;
		end;
		for i, v in pairs(gameFolder.Spawns:GetChildren()) do
			if table.find(excludeNames, v.Name) == nil then
				v:Destroy();
			end;
		end;
		for i, v in pairs(plrs) do
			v.Character.HumanoidRootPart.CFrame = game.Workspace.Game_Folder.Spawns.Center.CFrame;
		end;
	else 
		local newSky = Sky:Clone();
		newSky.Parent = game.Lighting;
		for i, v in pairs(Players:GetPlayers()) do
			v.Character.HumanoidRootPart.CFrame = gameFolder.Spawns:GetChildren()[i].CFrame;
		end;
	end;
	
	onGame();
end;

-- Run
Players.PlayerAdded:Connect(function(plr)
	addPlrToSpectsList(plr);
end);
Players.PlayerRemoving:Connect(function(plr)
	removePlrFromList(plr);
end);

DiedEvent.OnServerEvent:Connect(function(dPlayer)
	removePlrFromList(dPlayer);
	table.insert(spects, dPlayer);
	dPlayer.Team = Teams.Spectating;
end);

startGame();

while wait(1) do
	if restart == true then
		restart = false;
		startGame();
	end;
end;
