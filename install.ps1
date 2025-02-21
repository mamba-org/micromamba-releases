<#
.SYNOPSIS
    Install micromamba on Windows with optional non-interactive default initialization.

.DESCRIPTION
    This script downloads and installs micromamba and adds it to your PATH.
    It supports both interactive and non-interactive initialization.
    If run interactively, it will prompt you whether to initialize micromamba
    and allow you to specify a custom prefix. With the -AcceptDefaults switch,
    it bypasses the prompts and automatically uses the default prefix 
    ($Env:UserProfile\micromamba).
#>

param(
    [switch]$AcceptDefaults
)

# check if VERSION env variable is set, otherwise use "latest"
$RELEASE_URL = if ($null -eq $Env:VERSION) {
    "https://github.com/mamba-org/micromamba-releases/releases/latest/download/micromamba-win-64"
} else {
    "https://github.com/mamba-org/micromamba-releases/releases/download/$Env:VERSION/micromamba-win-64"
}

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

if ($null -eq $Host.UI.RawUI -or $AcceptDefaults) {
    Write-Output "`nNon-interactive session or AcceptDefaults flag provided, initializing micromamba to $Env:UserProfile\micromamba`n"
    & $MAMBA_INSTALL_PATH shell init -s powershell -p $Env:UserProfile\micromamba
} else {
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
}
