@ECHO OFF
SETLOCAL
REM Check if environment variable VERSION is set
if "%VERSION%"=="" (
    REM If not, set it to "latest"
    SET VERSION=latest
)

SET RELEASE_URL="https://github.com/mamba-org/micromamba-releases/releases/%VERSION%/download/micromamba-win-64"

REM If MAMBA_ROOT_PREFIX is defined, use it as install location 
if DEFINED MAMBA_ROOT_PREFIX (
    SET _installPath=%MAMBA_ROOT_PREFIX%
    SET _profilePath=%MAMBA_ROOT_PREFIX%
) else (
    SET _installPath=%LOCALAPPDATA%\micromamba
    SET _profilePath=%USERPROFILE%\micromamba
)

REM Report var values
SET VERSION
SET RELEASE_URL
SET _installPath
SET _profilePath

REM Download micromamba using curl.exe
curl.exe -L -o micromamba.exe %RELEASE_URL%

REM Create a directory for micromamba
MKDIR %_installPath%

REM Move micromamba.exe to the final directory
MOVE /Y micromamba.exe %_installPath%\micromamba.exe

REM check if this is an interactive shell
if "%PROMPT%"=="" (
    echo Initializing micromamba in %_profilePath%
    %_installPath%\micromamba.exe init -p %_profilePath%
)

@REM REM Ask user if micromamba should be added to the PATH
@REM ECHO Add micromamba to the PATH?
@REM ECHO y) Yes
@REM ECHO n) No
@REM SET /P ADD_TO_PATH="Enter your choice: "

@REM REM check if add to path is either y or Y (case insensitive)
@REM if "%ADD_TO_PATH:~0,1%"=="y" (
@REM     REM Add micromamba to the PATH
@REM     echo Adding micromamba to the PATH
@REM     setx PATH "%PATH%;%LOCALAPPDATA%\micromamba"
@REM )

:: Choice is probably the safer method, as it only allows a single keypress
REM Ask user if micromamba should be initialized
@REM ECHO Initialize micromamba?
@REM ECHO y) Yes (default)
@REM ECHO n) No
@REM SET /P INITIALIZE="Enter your choice: "

@REM if "%INITIALIZE:~0,1%"=="y" || "%INITIALIZE"=="" (
@REM     REM Initialize micromamba
@REM     echo Initializing micromamba in %_profilePath%
@REM     %_installPath%\micromamba.exe init -p %_profilePath%
@REM )

:init
choice /N /M "Initialize micromamba? (y/n) "
if errorlevel  2 (
    ECHO Skipped initialization
    goto :EOF
) else (
    ECHO Initializing micromamba in %_profilePath%
    %_installPath%\micromamba.exe shell init -p %_profilePath%
)
