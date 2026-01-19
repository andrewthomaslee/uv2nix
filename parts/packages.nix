{
  workspace,
  pythonSets,
  inputs,
  ...
}: {
  perSystem = {
    pkgs,
    system,
    inputs',
    self',
    ...
  }: {
    packages = let
      pythonSet = pythonSets.${system};
      inherit (pkgs.callPackages inputs.pyproject-nix.build.util {}) mkApplication;
      # create a venv with the `default` dependencies
      venv = pythonSet.mkVirtualEnv "hello-world-env" workspace.deps.default;
      # oci shared config
      name = "hello-world-container";
      created = "now";
      maxLayers = 125;
    in {
      # Create a derivation that wraps the venv but that only links package
      # content present in pythonSet.hello-world
      # https://pyproject-nix.github.io/uv2nix/patterns/applications.html
      default = mkApplication {
        inherit venv;
        # `hello-world` is the name of the project in `pyproject.toml`
        package = pythonSet.hello-world;
      };

      # create a oci container image with the venv
      # https://devdocs.io/nix/nixpkgs/stable/index#ssec-pkgs-dockerTools-buildLayeredImage
      container = pkgs.dockerTools.buildLayeredImage {
        inherit name created maxLayers;
        # add busybox if you want a shell
        # contents = [pkgs.busybox];
        config.Entrypoint = ["${venv}/bin/hello_world"];
      };

      container-stream = pkgs.dockerTools.streamLayeredImage {
        inherit name created maxLayers;
        config.Entrypoint = ["${venv}/bin/howdy_yall"];
      };
    };
  };
}
