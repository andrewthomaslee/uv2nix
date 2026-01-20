{
  projectName,
  projectScripts,
  workspace,
  pythonSets,
  ...
}: {
  perSystem = {
    pkgs,
    system,
    ...
  }: {
    apps = let
      pythonSet = pythonSets.${system};
      # Create a venv with `default` dependencies
      venv = pythonSet.mkVirtualEnv "${projectName}-env" workspace.deps.default;

      # Helper function returns the nix app definition
      mkApp = scriptName: {
        name = scriptName;
        value = {
          type = "app";
          meta.description = "Run `${scriptName}` uv script";
          # Points directly to the binary inside the venv
          program = "${venv}/bin/${scriptName}";
        };
      };
    in
      # Create attrset of apps
      builtins.listToAttrs (map mkApp projectScripts);
  };
}
