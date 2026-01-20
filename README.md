# uv2nix Template Project

This is a template project demonstrating how to manage a Python package using [`Nix flakes`](https://nixos.wiki/wiki/Flakes) and [`uv2nix`](https://github.com/pyproject-nix/uv2nix) for reproducible builds and dependency management.

With [`Nix flakes`](https://nixos.wiki/wiki/Flakes) you generally set them up once and forget it. After the initial setup, the project runs similar to any [`uv`](https://docs.astral.sh/uv/) managed Python project. You can ignore the nix code entirely and use [`uv`](https://docs.astral.sh/uv/) as normal and use the flake for CI/CD.

## Prerequisites

To use this project, you need either:
*   [`Nix package manager`](https://nixos.org/download/) + [`flakes`](https://nixos.wiki/wiki/Flakes) enabled.

or

*   [`Docker`](https://docs.docker.com/get-docker/) + [`Dev Containers`](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers) VSCode Extension


## Features
- `OCI images` dynamically generated from pyproject.toml uv scripts
- `apps`, `checks`, `packages` and `nixosModules` dynamically generated for each uv script
- `devShell` with all development dependencies installed
- `static analysis` with `ruff`, `pyrefly`, `pytest`, and `alejandra`
- `devcontainers` for VSCode
- `nixosModules` for NixOS with default package and OCI systemd services for each uv script
- `x86_64-linux`, `aarch64-linux`, `x86_64-darwin` and `aarch64-darwin` support

## Usage
### Show available outputs

To view all available outputs from this remote flake:

```bash
nix flake show github:andrewthomaslee/uv2nix
```

### Use as a template

To pull this template into your own project ( make sure you are inside an empty directory):

```bash
nix flake init -t github:andrewthomaslee/uv2nix
```

### Development Shell

Use the Nix development shell to enter the environment with all development dependencies installed:

```bash
nix develop
```

### Building the Package

To build the resulting package:

```bash
nix build
```

The built package will be available in the `result` symlink.

### Running uv scripts

To execute a uv script defined in `pyproject.toml` use `nix run .#<script_name>` i.e. :

```bash
nix run .#hello_world
```

### Static Analysis

To run static analysis tools `ruff`, `pyrefly`, `pytest`, and `alejandra`:

```bash
nix flake check
```


### NixOS Module

This flake also provides a [NixOS module](parts/nixosModules.nix) that can be included in your `nixosConfiguration` to easily install and configure the package on a NixOS system.

Add the flake inputs of your flake
```nix
#flake.nix
{
    inputs = {
        hello-world = {
            url = "git+https://github.com/andrewthomaslee/uv2nix.git";
            inputs.nixpkgs.follows = "nixpkgs";
        };
    }
}
```
and then include the module in your `nixosConfiguration`
```nix
#nixosConfiguration.nix
{
    imports = [
        inputs.hello-world.nixosModules.default
    ];
}
```