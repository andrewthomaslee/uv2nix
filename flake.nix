# https://github.com/pyproject-nix/uv2nix
{
  description = "hello world application using uv2nix";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

    pyproject-nix = {
      url = "github:pyproject-nix/pyproject.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    uv2nix = {
      url = "github:pyproject-nix/uv2nix";
      inputs.pyproject-nix.follows = "pyproject-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    pyproject-build-systems = {
      url = "github:pyproject-nix/build-system-pkgs";
      inputs.pyproject-nix.follows = "pyproject-nix";
      inputs.uv2nix.follows = "uv2nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = inputs @ {flake-parts, ...}:
    flake-parts.lib.mkFlake {inherit inputs;} ({
      self,
      pkgs,
      lib,
      ...
    }: let
      # Supported systems
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
    in {
      inherit systems;

      imports = [
        ./parts/devShell.nix
        ./parts/flake.nix
        ./parts/packages.nix
        ./parts/nixosModules.nix
      ];

      # pass args to the rest of flake-parts in ./parts
      _module.args = let
        # https://pyproject-nix.github.io/uv2nix/lib/workspace.html
        # Load a workspace from a workspace root
        # Will recursively discover, load & parse all necessary member projects in a uv workspace
        workspace = inputs.uv2nix.lib.workspace.loadWorkspace {workspaceRoot = ./.;};

        # https://pyproject-nix.github.io/uv2nix/lib/overlays.html
        # Generate an overlay to use with pyproject.nix's build infrastructure.
        overlay = workspace.mkPyprojectOverlay {
          sourcePreference = "wheel";
        };

        # Uv2nix supports editable packages, but requires you to generate a separate overlay & package set
        editableOverlay = workspace.mkEditablePyprojectOverlay {
          root = "$REPO_ROOT";
        };

        # Helper function to generate a python set for a given system
        # Creates a attrset of pythonSets for use like `pythonSets.${system}`
        mkPythonSet = system: let
          pkgs = inputs.nixpkgs.legacyPackages.${system};
        in
          (pkgs.callPackage inputs.pyproject-nix.build.packages {
            # The version of python to use ie python314 from nixpkgs
            python = pkgs.python314; # https://search.nixos.org/packages?channel=unstable&show=python314&query=python314
          }).overrideScope
          (
            lib.composeManyExtensions [
              inputs.pyproject-build-systems.overlays.wheel
              overlay
            ]
          );

        # generate a python set for each supported system
        pythonSets = lib.genAttrs systems mkPythonSet;
      in {
        inherit workspace overlay editableOverlay pythonSets;
      };
    });
}
