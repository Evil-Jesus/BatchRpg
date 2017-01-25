@echo off

set saveName=None

rem | Player Data
set pName=noName
set /a pHp=99
set /a pAgi=99
set /a pStr=99
set /a pDef=99
set pLeftHand=Fist
set pRightHand=Fist

rem | World Data
set /a worldSteps=0
set worldName=Overworld

:MainMenu
echo. 1: New game
echo. 2: Load game

set /p MainMenuSelection=

if %MainMenuSelection%==1 goto NewGame
if /i "%MainMenuSelection%"=="NewGame" goto NewGame

if %MainMenuSelection%==2 goto LoadGame
if /i "%MainMenuSelection"=="LoadGame" goto LoadGame

rem | else try again
goto MainMenu

:NewGame
set /p saveName=New game name:

if not exist SaveGames\%saveName% (
MD SaveGames\%saveName%\World\Events
copy SaveGames\Default\ SaveGames\%saveName%\
copy SaveGames\Default\World SaveGames\%saveName%\World
copy SaveGames\Default\World\Events SaveGames\%saveName%\World\Events
) else (
echo. %saveName% already exist!
goto MainMenu
)

echo If there are errors, close program, delete 
echo SaveGames\%saveName% folder and try again
set /p dummy=Press enter to continue if no errors..
cls
goto World

:LoadGame
set /p saveName=Load save name: 

if exist SaveGames\%saveName%\PlayerData.txt (
set /p pName=
set /p pHp=
set /p pAgi=
set /p pStr=
set /p pDef=
set /p pLeftHand=
set /p pRightHand=
)<SaveGames\%saveName%\PlayerData.txt

echo. Loaded save \%saveName% with values:
echo. %pName%, %pHp%, %pAgi%, %pStr%, %pDef%, %pLeftHand%, %pRightHand%
goto World

:SaveGame
rem | Choose a saveGame name to save as
set /p saveName=Save as:

if exist SaveGames\%saveName% (
echo SaveGames\%saveName% already exist.
echo If you continue you will override your old save.
set /p YN="Do you wish to continue? (Y/N)"
if not /i "%YN%"=="Y" goto World
)

rem | Prevent overwriting the default save
if /i "%saveName%"=="Default" (
echo You cant override the Default save
goto SaveGame
)

(
echo %pName%
echo %pHp%
echo %pAgi%
echo %pStr%
echo %pDef%
echo %pLeftHand%
echo %pRightHand%
)>SaveGames\%saveName%\PlayerData.txt

echo test inventory>SaveGames\%saveName%\Inventory.txt
goto World

:World
set /a WorldEvent=%RANDOM% * 2 / 32768 + 1
set /p WorldAction=Input:

if /i "%WorldAction%"=="Help" goto WorldHelp
if /i "%WorldAction%"=="SaveGame" goto SaveGame
if /i "%WorldAction%"=="LoadGame" goto LoadGame
if /i "%WorldAction%"=="MainMenu" goto MainMenu

if /i "%WorldAction%"=="Move" goto Move

echo invalid action
goto World

:Move
echo. Event: %WorldEvent%
for /f "tokens=* skip=5" %%a in (SaveGames\%saveName%\World\Events\%WorldEvent%.txt) do (
  echo. %%a
)
goto World

:WorldHelp
cls
type Templates\WorldHelp.txt
set /p dummy=Press enter to return
cls
goto World

:WorldInfo
cls
type Worlds\%worldName%\Info.txt
set /p dummy=
goto World



