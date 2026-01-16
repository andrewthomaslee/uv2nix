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
    in {
      default = mkApplication {
        venv = pythonSet.mkVirtualEnv "hello-world-env" workspace.deps.default;
        package = pythonSet.hello-world;
      };
    };
  };
}
