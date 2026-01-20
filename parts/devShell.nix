{
  projectName,
  workspace,
  editableOverlay,
  pythonSets,
  ...
}: {
  perSystem = {
    pkgs,
    system,
    lib,
    ...
  }: {
    devShells = let
      # # https://pyproject-nix.github.io/uv2nix/usage/getting-started.html#setting-up-a-development-environment-optional
      # Editable packages make entry points like scripts available in the virtual environment,
      # but instead of installed Python files the virtualenv contains pointers to the source tree.
      # This means that changes to the sources are immeditately activated and doesn't require a rebuild.
      pythonSet = pythonSets.${system}.overrideScope editableOverlay;
      # Create a venv with `all` dependencies
      venv = pythonSet.mkVirtualEnv "${projectName}-dev" workspace.deps.all;

      # ------ common shell config ------ #

      # bash aliases for common commands
      bash_aliases = pkgs.writeText "bash_aliases" ''
        alias uv-upgrade="uv lock --upgrade"
      '';

      # common shellHook, sourced in all shells
      shellHook = ''
        unset PYTHONPATH
        export REPO_ROOT=$(git rev-parse --show-toplevel)
        export SHELL=$(which bash)
        if [ -f $REPO_ROOT/.env.local ]; then
          set -a
          source $REPO_ROOT/.env.local
          set +a
        fi

        source ${bash_aliases}
      '';

      # common env vars for all shells
      env = {
        UV_PYTHON_DOWNLOADS = "never";
        UV_PYTHON = pythonSet.python.interpreter;
      };

      # common packages for all shells
      packages = with pkgs; [
        podman
        podman-compose
        uv
      ];
    in {
      # pure shell with venv built in
      default = pkgs.mkShell {
        inherit shellHook packages;
        buildInputs = [pkgs.bash venv];
        env = env // {UV_NO_SYNC = "1";};
      };
      # impure shell with `uv sync` and no bash for tricky environments
      impure = pkgs.mkShell {
        inherit packages;
        shellHook = shellHook + "uv sync";
        buildInputs = [pythonSet.python];
        env =
          env
          // lib.optionalAttrs pkgs.stdenv.isLinux {
            LD_LIBRARY_PATH = lib.makeLibraryPath pkgs.pythonManylinuxPackages.manylinux1;
          };
      };
    };
  };
}
