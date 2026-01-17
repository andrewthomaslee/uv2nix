# uv2nix Python Template Project

This is a template project demonstrating how to manage a Python package using [Nix flakes](https://nixos.org/manual/nix/stable/package-management/flakes.html) and [uv2nix](https://github.com/andrewthomaslee/uv2nix) for reproducible dependency management.

## Prerequisites

To use this project, you need:
*   [Nix package manager](https://nixos.org/download/) with [flakes](https://nixos.wiki/wiki/Flakes) enabled.

## Development Shell

Use the Nix development shell to enter the environment with all development dependencies installed:

```bash
nix develop
```

## Building the Package

To build the resulting package, run:

```bash
nix build
```

The built package will be available in the `result` symlink.

## NixOS Module

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