# micromamba - grab your release here!

This repository is used to distribute release builds of `micromamba`, the fast package manager for conda packages!
micromamba is a single-file executable that is statically linked and can be dropped anywhere on the operating to get started with powerful package management and virtual environments.

To install, copy and paste the commands from the following sections.
The `pfx.dev` URLs are just shorthands for the URLs to the raw files on Github from this repository.

### Linux / macOS / Windows (git bash)

On Linux and macOS, this script downloads the micromamba release file and places it in `~/.local/bin`. The script then asks you if you want to perform "shell initialization". If yes, shell initialization will add a block to your `~/.bashrc` or `.zshrc` file. You can choose to do that later by executing `micromamba shell init`. Shell initialization is necessary to properly activate and deactivate virtual environments, however you can use micromamba without and use `micromamba run -n myenv` or `micromamba shell -n myenv` functions to run in or drop into virtual environments.

```bash
"${SHELL}" <(curl -L https://micro.mamba.pm/install.sh)
```

### Windows

On Windows, the executable `micromamba.exe` is installed into `$Env:LocalAppData\micromamba\micromamba.exe`.

With Powershell:
```powershell
irm https://micro.mamba.pm/install.ps1 | iex
```
