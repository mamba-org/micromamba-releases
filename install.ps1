# check if VERSION env variable is set, otherwise use "latest"
$VERSION = if ($null -eq $Env:VERSION) { "latest" } else { $Env:VERSION }

$RELEASE_URL = "https://github.com/mamba-org/micromamba-releases/releases/$VERSION/download/micromamba-win-64"

Write-Output "Downloading micromamba from $RELEASE_URL"
curl.exe -L -o micromamba.exe $RELEASE_URL

# check if MAMBA_ROOT_PREFIX env variable is set, otherwise use Local AppData and UserProfile
$installPath = if ($null -eq $Env:MAMBA_ROOT_PREFIX) { "$Env:LocalAppData\micromamba" } else { $Env:MAMBA_ROOT_PREFIX }
$profilePath = if ($null -eq $Env:MAMBA_ROOT_PREFIX) { "$Env:UserProfile\micromamba" } else { $Env:MAMBA_ROOT_PREFIX }

if (!(Test-Path $installPath)) {
    New-Item -ItemType Directory -Force -Path  $installPath | out-null
}

$MAMBA_INSTALL_PATH = Join-Path -Path $installPath -ChildPAth micromamba.exe

Write-Output "`nInstalling micromamba to $installPath`n"
Move-Item -Force micromamba.exe $MAMBA_INSTALL_PATH | out-null

# Add micromamba to PATH if the folder is not already in the PATH variable
$PATH = [Environment]::GetEnvironmentVariable("Path", "User")
if ($PATH -notlike "*$installPath*") {
    Write-Output "Adding $MAMBA_INSTALL_PATH to PATH`n"
    [Environment]::SetEnvironmentVariable("Path", "$installPath;" + [Environment]::GetEnvironmentVariable("Path", "User"), "User")
}
else {
    Write-Output "$MAMBA_INSTALL_PATH is already in PATH`n"
}

# check if this is an interactive session
if ($null -eq $Host.UI.RawUI) {
    Write-Output "`nNot an interactive session, initializing micromamba to $profilePath`n"
    & $MAMBA_INSTALL_PATH shell init -s powershell -p $profilePath
}

$choice = Read-Host "Do you want to initialize micromamba for the shell activate command? (Y/n)"
if ($choice -eq "y" -or $choice -eq "Y" -or $choice -eq "") {
    $prefix = Read-Host "Enter the path to the micromamba prefix (default: $profilePath)"
    if ($prefix -eq "") {
        $prefix = "$profilePath"
    }

    Write-Output "Initializing micromamba in $prefix"
    Write-Output $MAMBA_INSTALL_PATH
    & $MAMBA_INSTALL_PATH shell init -s powershell -p $profilePath
}
else {
    Write-Output "`nYou can always initialize powershell pr cmd.exe with micromamba by running `nmicromamba shell init -s powershell -p $profilePath`n"
}
