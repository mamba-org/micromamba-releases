# check if VERSION env variable is set, otherwise use "latest"
$VERSION = if ($Env:VERSION -eq $null) { "latest" } else { $Env:VERSION }

$RELEASE_URL="https://github.com/mamba-org/micromamba-releases/releases/$VERSION/download/micromamba-win-64"

echo "Downloading micromamba from $RELEASE_URL"
curl.exe -L -o micromamba.exe $RELEASE_URL

New-Item -ItemType Directory -Force -Path  $Env:LocalAppData\micromamba

echo "Installing micromamba to $Env:LocalAppData\micromamba"
Move-Item -Force micromamba.exe $Env:LocalAppData\micromamba\micromamba.exe

# check if this is an interactive session
if ($Host.UI.RawUI -eq $null) {
    echo "Not an interactive session, initializing micromamba to $Env:UserProfile\micromamba"
    micromamba shell init -s powershell -p $Env:UserProfile\micromamba
}

# echo "Adding micromamba to PATH"
# [Environment]::SetEnvironmentVariable("Path", "$Env:LocalAppData\micromamba;" + [Environment]::GetEnvironmentVariable("Path", "User"), "User")

$choice = Read-Host "Do you want to initialize micromamba? (Y/n)"
if ($choice -eq "y" -or $choice -eq "Y" -or $choice -eq "") {
    $prefix = Read-Host "Enter the path to the micromamba prefix (default: $Env:UserProfile\micromamba)"
    if ($prefix -eq "") {
        $prefix = "$Env:UserProfile\micromamba"
    }

    echo "Initializing micromamba in  $prefix"
    micromamba shell init -s powershell -p $Env:UserProfile\micromamba
}