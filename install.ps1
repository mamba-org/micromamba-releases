$RELEASE_URL="https://github.com/mamba-org/micromamba-releases/releases/latest/download/micromamba-win-64"

curl.exe -L -o micromamba.exe $RELEASE_URL

New-Item -ItemType Directory -Force -Path  $Env:LocalAppData\micromamba

Move-Item -Force micromamba.exe $Env:LocalAppData\micromamba\micromamba.exe