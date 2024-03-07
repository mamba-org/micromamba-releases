# check if VERSION env variable is set, otherwise use "latest"
$VERSION = if ($null -eq $Env:VERSION) { "latest" } else { $Env:VERSION }

$RELEASE_URL="https://github.com/mamba-org/micromamba-releases/releases/$VERSION/download/micromamba-win-64"

Write-Output "Downloading micromamba from $RELEASE_URL"
curl.exe -L -o micromamba.exe $RELEASE_URL

New-Item -ItemType Directory -Force -Path  $Env:LocalAppData\micromamba | out-null

$MAMBA_INSTALL_PATH = Join-Path -Path $Env:LocalAppData -ChildPath micromamba\micromamba.exe

Write-Output "`nInstalling micromamba to $Env:LocalAppData\micromamba`n"
Move-Item -Force micromamba.exe $MAMBA_INSTALL_PATH | out-null

# Add micromamba to PATH if the folder is not already in the PATH variable
$PATH = [Environment]::GetEnvironmentVariable("Path", "User")
if ($PATH -notlike "*$Env:LocalAppData\micromamba*") {
    Write-Output "Adding $MAMBA_INSTALL_PATH to PATH`n"
    [Environment]::SetEnvironmentVariable("Path", "$Env:LocalAppData\micromamba;" + [Environment]::GetEnvironmentVariable("Path", "User"), "User")
} else {
    Write-Output "$MAMBA_INSTALL_PATH is already in PATH`n"
}

# check if this is an interactive session
if ($null -eq $Host.UI.RawUI) {
    Write-Output "`nNot an interactive session, initializing micromamba to $Env:UserProfile\micromamba`n"
    & $MAMBA_INSTALL_PATH shell init -s powershell -p $Env:UserProfile\micromamba
}

$choice = Read-Host "Do you want to initialize micromamba for the shell activate command? (Y/n)"
if ($choice -eq "y" -or $choice -eq "Y" -or $choice -eq "") {
    $prefix = Read-Host "Enter the path to the micromamba prefix (default: $Env:UserProfile\micromamba)"
    if ($prefix -eq "") {
        $prefix = "$Env:UserProfile\micromamba"
    }

    Write-Output "Initializing micromamba in  $prefix"
    $MAMBA_INSTALL_PATH = Join-Path -Path $Env:LocalAppData -ChildPath micromamba\micromamba.exe
    Write-Output $MAMBA_INSTALL_PATH
    & $MAMBA_INSTALL_PATH shell init -s powershell -p $prefix
} else {
    Write-Output "`nYou can always initialize powershell or cmd.exe with micromamba by running `nmicromamba shell init -s powershell -p $Env:UserProfile\micromamba`n"
}
