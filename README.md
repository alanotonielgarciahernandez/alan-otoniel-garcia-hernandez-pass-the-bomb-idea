<div align='center'>

  #### Alan Otoniel García Hernández Pass the Bomb Idea.
</div>

# Current state
It seems the game isn’t working properly. Work has already begun on reviewing the project to resolve all the issues.

# Information
Started in December, 2021. This experience is a copy of the original Pass the Bomb game, [ pass bomb thing TESTING ]( https://www.roblox.com/games/2961583129/pass-bomb-thing-TESTING ) by RVVZ. The map, the round, and the rest of the gameplay content come from that game. This repository is the Rojo export of my published copy, kept so I can read and version those files outside Roblox Studio.

I published the copy to test what I knew. I do not earn anything from it beyond that practice. Bugs can still appear while playing, and I only fix or extend the place when I decide to.

The copy includes:
- A replicated map from the original game.
- A round system. One player carries the bomb, and the last remaining player wins.
- Sudden death when 1 to 4 players remain. The outer map is removed and everyone starts at the center.

`newGame.server.luau` is the enabled round script. `Game.server.luau` is an earlier version of that loop and stays disabled.

## How has this project helped me build my portfolio?
The repository shows a published Roblox place with its map, teams, notice GUI, and bomb round saved as source files. The design belongs to the original game. What this project shows is that I could stand that copy up and keep it in Git.

## How has this project helped me test and expand my knowledge?
Building the copy was a way to practice Roblox gameplay in a place that already had a map and rules. Exporting it with Rojo then let me read the Luau round scripts next to the model files for the map, bomb, spawns, and GUI.

## How has this project helped to test and expand my skills?
The enabled round script keeps track of who is playing, who is spectating, when the bomb is missing, and when the match should restart. Splitting that loop into functions made those rules easier to follow than in my first script.

## Why did I make this project?
I wanted a place where I could try the original Pass the Bomb rules and see how the round, the map, and sudden death fit together. The experience was only for practice. This repository is the filesystem copy of that place.

## What's next?
The published copy stays on Roblox. I am not committed to fixing bugs or adding features unless I want to. Any change I do make belongs in this repository and goes back into Studio through Rojo.

# How to use

## Requirements
[ Roblox Studio ]( https://create.roblox.com/ ) and [ Rokit ]( https://github.com/rojo-rbx/rokit ) are required. Rokit installs the Rojo version pinned in `rokit.toml`.

Install the project tools by opening a shell and running the following command inside the project folder:
```sh
rokit install
```
Install the matching Studio plugin once:
```sh
rojo plugin install
```
Restart Studio after installing the plugin.

## Open the place
`game.rbxl` is the local copy of the published place. It is ignored by Git. Open that file in Roblox Studio, then start the Rojo server from the project folder:
```sh
rojo serve
```
In Studio, connect the Rojo plugin to the server. The plugin syncs `src` into the open place.

## Build the project
Open a shell and run the command below to build a place file from this repository.
```sh
rojo build -o "alan-otoniel-garcia-hernandez-pass-the-bomb-idea.rbxlx"
```
The built file is ignored by Git. Open it in Roblox Studio when you want a place generated only from the files in this repository.

# Functions
The gameplay below is copied from the original game. One player carries a bomb, eliminated players leave the round, and the match restarts after a winner is announced. Sudden death starts when 1 to 4 players remain.

## Joining and teams.
A player who joins is placed on the Spectating team. When a match starts, players who have a character move to the Playing team. Players who die, or who fire `DiedEvent`, return to Spectating.

## Match start.
The notice GUI tells everyone the server is waiting for players, then that the match is starting. The map and spawn points are cloned from `ReplicatedStorage` into `Workspace.Game_Folder`.

Sudden death applies with fewer than five players. Towers and outer spawns are removed, and everyone starts at the center under `WarSky`. With five or more players, the full map stays and each player is sent to a spawn under `Sky`.

## The bomb.
`setBomb` picks a playing character, raises that character's walk speed, and welds a clone of `Bomb` to the right hand. If nobody is still carrying the bomb and at least one player remains, another player receives it.

## Round end.
The notice GUI shows how many players remain. One player left wins, and that player's name is shown. Zero players left ends the round with no winner. The map is cleared, the carrier returns to the spectate point, and the next match starts.

# Technologies
- Programming Language: [ Luau ]( https://luau.org/ )
- Engine: [ Roblox ]( https://create.roblox.com/ )
- Project Sync: [ Rojo ]( https://github.com/rojo-rbx/rojo ) 7.7.1
- Toolchain Manager: [ Rokit ]( https://github.com/rojo-rbx/rokit )
