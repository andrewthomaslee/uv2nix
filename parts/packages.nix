{
  workspace,
  pythonSets,
  ...
}: {
  perSystem = {
    pkgs,
    system,
    inputs',
    self',
    ...
  }: {
    packages = {
      default = pythonSets.${system}.mkVirtualEnv "hello-world-env" workspace.deps.default;
    };
  };
}
