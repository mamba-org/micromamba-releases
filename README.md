# micromamba - grab your release here!

This repository is used to distribute release builds of `micromamba`, the fast package manager for conda packages!
micromamba is a single-file executable that is statically linked and can be dropped anywhere on the operating to get started with powerful package management and virtual environments.

To install, copy and paste the commands from the following sections.
The `pfx.dev` URLs are just shorthands for the URLs to the raw files on Github from this repository.

### Linux / macOS / Windows (git bash)

On Linux and macOS, this script downloads the micromamba release file and places it in `~/.local/bin`. The script then asks you if you want to perform "shell initialization". If yes, shell initialization will add a block to your `~/.bashrc` or `.zshrc` file. You can choose to do that later by executing `micromamba shell init`. Shell initialization is necessary to properly activate and deactivate virtual environments, however you can use micromamba without and use `micromamba run -n myenv` or `micromamba shell -n myenv` functions to run in or drop into virtual environments.

```
curl https://pfx.dev/micromamba/install.sh | bash

# or if you prefer `zsh`, it should work just as well

curl https://pfx.dev/micromamba/install.sh | zsh
```

### Windows

On Windows, the executable `micromamba.exe` is installed into `%LocalAppData%\micromamba\micromamba.exe`.

```
curl.exe https://pfx.dev/micromamba/install.ps1 | powershell.exe -ExecutionPolicy Bypass -

# or cmd.exe:

curl.exe https://pfx.dev/micromamba/install.bat | cmd.exe
```