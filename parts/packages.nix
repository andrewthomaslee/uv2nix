{
  projectName,
  projectScripts,
  workspace,
  pythonSets,
  inputs,
  ...
}: {
  perSystem = {
    pkgs,
    system,
    ...
  }: {
    packages = let
      inherit (pkgs.callPackages inputs.pyproject-nix.build.util {}) mkApplication;
      pythonSet = pythonSets.${system};

      # Create a venv with `default` dependencies
      venv = pythonSet.mkVirtualEnv "${projectName}-env" workspace.deps.default;

      # Helper function to generate the oci config for each uv script
      mkImageConfig = scriptName: {
        name = "${projectName}-${scriptName}"; # Resulting image name
        created = "now";
        maxLayers = 125;
        config.Entrypoint = ["${venv}/bin/${scriptName}"];
      };

      # Packages for each uv script using both `buildLayeredImage` and `streamLayeredImage`
      dynamicPackagesList =
        builtins.concatMap (scriptName: [
          # Layered Image
          {
            name = "container-${scriptName}";
            value = pkgs.dockerTools.buildLayeredImage (mkImageConfig scriptName);
          }
          # Stream Layered Image
          {
            name = "container-stream-${scriptName}";
            value = pkgs.dockerTools.streamLayeredImage (mkImageConfig scriptName);
          }
        ])
        projectScripts;
    in
      # Merge the packages into a single attrset
      {
        default = mkApplication {
          inherit venv;
          package = pythonSet.${projectName};
        };
      }
      // (builtins.listToAttrs dynamicPackagesList);
  };
}
