RELEASE_URL="https://github.com/mamba-org/micromamba-releases/releases/latest/download/micromamba-win-64"

REM Download micromamba using curl.exe
curl.exe -L -o micromamba.exe %RELEASE_URL%

REM Create a directory for micromamba
MKDIR %LOCALAPPDATA%\micromamba

REM Move micromamba.exe to the final directory
MOVE /Y micromamba.exe %LOCALAPPDATA%\micromamba\micromamba.exe