# nix-dice

TL;DR: Using [Nix](https://nixos.org) is a way to have a fully-fledged package management system on the School of Informatics' [DICE](https://computing.help.inf.ed.ac.uk/dice-platform) Linux platform. If DICE already has a program installed, you can seamlessly go between using the old DICE version and a new version installed with Nix.

`apt` does not work on DICE without sudo/root access. There are a few package managers that do not require root, like [homebrew](https://brew.sh) and Nix. The issue with homebrew is that it requires root to create `/home/linuxbrew`, and if you choose to use a local directory like `~/.homebrew` instead, it must compile bottles from source (which either takes ages or doesn't work). Nix has a built-in solution to this, which is to mount a local directory, like `~/.nix`, onto `/nix`, creating an environment where prebuilt binaries are "tricked" into using your local folder and don't need to be recompiled.

This repository contains scripts that make installing and using Nix without root easier.

## Installation

An installation script is provided. Execute the following:

```sh
curl -L "https://github.com/alecks/nix-dice/raw/refs/heads/main/install.sh" | bash
```

This will install the `with-nix` and `enter-nix` scripts to `~/.local/bin`, modify your `~/.zshrc` to work with Nix, and run the official Nix installer.

Once this is complete, zsh will ask you whether to enter the Nix environment at startup. This simply just mounts `~/.nix` to `/nix` and adds relevant executables to your PATH variable. To enter the Nix environment by default, add `export BYPASS_NIX_CHECK=1` to the top of your `.zshrc`. To enter the normal environment by default, add `export BYPASS_NIX_CHECK_NORMAL=1`.

If you wish to enter the Nix environment at any point, use the `with-nix` command. For example, `with-nix zsh` will mount `~/.nix` to `/nix` and run `zsh`. This allows you to quickly swap between using old versions of programs bundled with DICE and new versions with Nix.

