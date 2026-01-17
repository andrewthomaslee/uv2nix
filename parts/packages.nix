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
      # Create a derivation that wraps the venv but that only links package
      # content present in pythonSet.hello-world.
      #
      # This means that files such as:
      # - Python interpreters
      # - Activation scripts
      # - pyvenv.cfg
      #
      # Are excluded but things like binaries, man pages, systemd units etc are included.
      default = mkApplication {
        # create a venv with the `default` dependencies
        venv = pythonSet.mkVirtualEnv "hello-world-env" workspace.deps.default;
        # `hello-world` is the name of the project in `pyproject.toml`
        package = pythonSet.hello-world;
      };
    };
  };
}
