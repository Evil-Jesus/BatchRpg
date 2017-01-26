@echo off
SETLOCAL EnableDelayedExpansion

set saveName=None

rem | Player Data
set pName=null
set /a pHp=0
set /a pAgi=0
set /a pStr=0
set /a pDef=0
set pLeftHand=null
set pRightHand=null

rem | Enemy Data
set eName=null
set /a eHp=0
set /a eAgi=0
set /a eStr=0
set /a eDef=0
set eLeftHand=null
set eRightHand=null

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

(
set /p MoveGoto=
set /p MoveParameter1=
)<SaveGames\%saveName%\World\Events\%WorldEvent%.txt

rem | bug is here
if not "%MoveGoto%"=="null" (
set %MoveParameter1%
echo. %MoveGoto%
goto %MoveGoto%
)

(
set /p moveAction1=
)<SaveGames\%saveName%\World\Events\%WorldEvent%.txt



goto World

:initBattle
SET inputfile=SaveGames\%saveName%\World\Enemies.txt
SET linestoread=7
SET searchstring="banditM1"
SET found=0
FOR /F "tokens=*" %%L IN (%inputfile%) DO (
    IF !found!==1 (
        IF !linestoread!==0 GOTO initBattleBREAK
        SET /a linestoread=!linestoread!-1
        FOR /F "tokens=2 delims==" %%A IN ("%%L") DO (
			SET %%L
        )
    )
    IF "%%L"==%searchstring% SET found=1
)
goto initBattleBREAK

:initBattleBREAK
echo. Loaded enemy: %eName% with hp:%eHp%;
echo. Str:%eStr%; Agi:%eAgi%; Def:%eDef%
echo. LeftHand:%eLeftHand%; RightHand:%eRightHand%;
set /p dummy=Press enter to start battle
goto Battle

:Battle
cls
echo.
echo. ===*=*=*=*=*=*=*=*=*=*=*=*=*=*==// Battle //===*=*=*=*=*=*=*=*=*=*=*=*=*=*===
echo.
echo. =========// Actions //==========   /\  /\   ===========// Enemy //===========
echo.                                =   \/  \/   = %eName%
echo.        1. Attack               =   /\  /\   =   Hp: %eHp%
echo.        2. Abilities            =  /  \/  \  =   Str: %eStr%, Agi %eAgi%, Def: %eDef%
echo.        3. Inventory            =  \  /\  /  =   Main Hand: %eLeftHand%
echo.                                =   \/  \/   =   Off Hand: %eRightHand%
echo.                                =   /\  /\   =
echo. ================================   \/  \/   =================================
echo.
set /p BattleAction=Action: 

if "%BattleAction%"=="Attack" goto attackInit

if %eHp% LSS 0 goto BattleWon
if %pHp% LSS 0 goto GameOver
goto Battle

:attackInit
echo. %attacker% is attacking!

SET found1=0
SET found2=0

set /a left=0
set /a right=0
set attackTarget=p

SET inputfile=SaveGames\%saveName%\Items.txt

SET /a ptStr=%pStr%
SET /a ptAgi=%pAgi%
SET /a ptDef=%pDef%
SET /a etStr=%eStr%
SET /a etAgi=%eAgi%
SET /a etDef=%eDef%

:attackLeft
if %found1%==0 set attackTarget=p
if %found1%==1 set attackTarget=e

set searchstring1=!%attackTarget%LeftHand!

SET linestoreadA=3
SET found1=0
FOR /F "tokens=*" %%L IN (%inputfile%) DO (
    IF !found1!==1 (
        IF !linestoreadA!==0 (
			echo. %attackTarget%tStr%%L
			echo. %attackTarget%tAgi%%L
			echo. %attackTarget%tDef%%L
			IF "%attackTarget%"=="p" goto attackLeft
			goto attackRight
		)
        SET /a linestoread=!linestoreadA!-1
        FOR /F "tokens=2 delims==" %%A IN ("%%L") DO (
			if !linestoreadA!==2 set /a %attackTarget%tStr%%L
			if !linestoreadA!==1 set /a %attackTarget%tAgi%%L
			if !linestoreadA!==0 set /a %attackTarget%tDef%%L
        )
    )
    IF "%%L"==%searchstring1% SET found1=1
)

:attackRight
if %found2%==0 set attackTarget=p
if %found%==1 set attackTarget=e

set searchstring1=!%attackTarget%LeftHand!

SET linestoreadA=3
SET found2=0
FOR /F "tokens=*" %%L IN (%inputfile%) DO (
    IF !found2!==1 (
        IF !linestoread!==0 GOTO attackApply
        SET /a linestoread=!linestoread!-1
        FOR /F "tokens=2 delims==" %%A IN ("%%L") DO (
			if !linestoreadA!==2 set /a tStr%%L
			if !linestoreadA!==1 set /a tAgi%%L
			if !linestoreadA!==0 set /a tDef%%L
        )
    )
    IF "%%L"==%searchstring1% SET found2=1
)

:attackApply
echo. %ptStr%, %ptAgi%, %ptDef%
echo. %etStr%, %etAgi%, %etDef%
set /p dummy=Paused...
goto Battle

:BattleWon
goto World

:GameOver
goto MainMenu

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



