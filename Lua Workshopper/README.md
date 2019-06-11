
# LuaWorkshopper Version 1.0 | Quick Tool For Addon Making And Publishing

## Info

**Release date:** *03.03.2018*

**Type:** *Program*

**Category:** *Tool*

**Subcategory:** *Workshop Tool*

**Operating System:** *Windows*

**Additional Requirements:** *Installed Garry's Mod or gma.exe and gmpublish.exe*

**Extension:** *.exe*

**Written on:** *Lua*

**Compiled by:** *SrLua 5.1 Pre-Compiled*

**Interface:** *Command line*

**File Name:** *LuaWorkshopper.exe*

**File Size:** *294 KB*

**License:** *MIT*



## Description

LuaWorkshopper is a tool for Workshop which includes .gma creation and Workshop publishing.

Prefix "Lua" means program was written on Lua language. You don't need to have installed Lua tools, program was compiled to .exe and it's portable.

LuaWorkshopper was developed for simplifying addons preparation process. Program will report errors in file or print separately.

## Installation

Download latest version from this post.
Put anywhere you want. For best experience use unprotected directories such as Desktop.


## Usage

For the first startup you need to set bin folder where gma.exe and gmpublish.exe are located.
Go to Garry's Mod folder location (steamapps/Garry's Mod/ or right click on GMod icon in Steam and find "Browse local files...")
Drag from folder your bin folder to LuaWorkshopper (Don't mess with steamapps/Garry's Mod/garrysmod/lua/bin or steamapps/Garry's Mod/garrysmod/bin)
Don't worry about quotation marks, program will strip them
Press enter to continue


After bin folder is set you're ready to use program
First of all you need to choose action, so no arguments accepted there (Example: gma) (Wrong: gma *you addon folder*)
LuaWorkshopper will say what you need to give and what's wrong.
For next results type help. To exit from action type "cancel". Action can be chosen after "Input:" text appearing


## Available Commands
| Command | Description |
|--|--|
| exit | Exit program. |
| gma | Creates .gma |
| gma log | Returns last gmad.exe log. Available after gmad.exe build. |
| help | Returns available commands. |
| mode | Switches input mode filename/path. |
| workshop create | Creates new Workshop Item. |
| workshop error | Return error description by number. |
| workshop list | Returns list of Workshop Items. |
| workshop log	 | Returns last gmpublish.exe log. Available after gmpublish.exe executing. |
| workshop update | Updates new Workshop Item. |

## Modes

### File Name Mode
File name mode requires file name or folder name without full path.

Example: folder is in C:/Users/Spar/Desktop/ named My Unique DarkRP. You need to type: My Unique DarkRP

### Path Mode

Path mode requires full path starting from disk (C:/)

Example: folder is in C:/Users/Spar/Desktop/ named My Unique DarkRP. You need to type or drag: C:/Users/Spar/Desktop/My Unique DarkRP or "C:/Users/Spar/Desktop/My Unique DarkRP"



## Images


## Known Problems

 1. If you put LuaWorkshopper in protected folder, it won't be able to create config and error file. To fix that: Put in unprotected folder such as Desktop or Run LuaWorkshopper as Administrator.
 2. If you ran LuaWorkshopper as Administrator there will be an issue with dragging files inside program. To fix that: Copy path in Windows Explorer and paste into program
 3. If you wrote quote symbol " in changes text, it will fail. No fix for now
    
## Next Update

Super-fast creator. One command will create .gma and publish it after
Fix 3rd known problem


### Note about source code: LuaWorkshopper use some functions made by Facepunch studio and other programmers. Noncommercial use.
