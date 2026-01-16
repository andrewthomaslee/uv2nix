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
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
    in {
      inherit systems;

      imports = [
        ./parts/devShell.nix
        ./parts/packages.nix
        ./parts/nixosModules.nix
      ];

      _module.args = let
        workspace = inputs.uv2nix.lib.workspace.loadWorkspace {workspaceRoot = ./.;};
        overlay = workspace.mkPyprojectOverlay {
          sourcePreference = "wheel";
        };
        editableOverlay = workspace.mkEditablePyprojectOverlay {
          root = "$REPO_ROOT";
        };

        mkPythonSet = system: let
          pkgs = inputs.nixpkgs.legacyPackages.${system};
        in
          (pkgs.callPackage inputs.pyproject-nix.build.packages {
            python = pkgs.python314;
          }).overrideScope
          (
            lib.composeManyExtensions [
              inputs.pyproject-build-systems.overlays.wheel
              overlay
            ]
          );

        pythonSets = lib.genAttrs systems mkPythonSet;
      in {
        inherit workspace overlay editableOverlay pythonSets;
      };
    });
}
