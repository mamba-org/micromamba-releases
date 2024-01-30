REM Check if environment variable VERSION is set
if "%VERSION%"=="" (
    REM If not, set it to "latest"
    SET VERSION=latest
)

SET RELEASE_URL="https://github.com/mamba-org/micromamba-releases/releases/%VERSION%/download/micromamba-win-64"

REM Download micromamba using curl.exe
curl.exe -L -o micromamba.exe %RELEASE_URL%

REM Create a directory for micromamba
MKDIR %LOCALAPPDATA%\micromamba

REM Move micromamba.exe to the final directory
MOVE /Y micromamba.exe %LOCALAPPDATA%\micromamba\micromamba.exe

REM check if this is an interactive shell
if "%PROMPT%"=="" (
    echo Initializing micromamba in %USERPROFILE%\micromamba
    %LOCALAPPDATA%\micromamba\micromamba.exe init -p %USERPROFILE%\micromamba
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

REM Ask user if micromamba should be initialized
ECHO Initialize micromamba?
ECHO y) Yes (default)
ECHO n) No
SET /P INITIALIZE="Enter your choice: "

if "%INITIALIZE:~0,1%"=="y" || "%INITIALIZE"=="" (
    REM Initialize micromamba
    echo Initializing micromamba in %USERPROFILE%\micromamba
    %LOCALAPPDATA%\micromamba\micromamba.exe init -p %USERPROFILE%\micromamba
)