{
  workspace,
  editableOverlay,
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
    devShells = let
      bash_aliases = pkgs.writeText "bash_aliases" ''
        alias k="kubectl "
        alias docker="podman"
      '';
      complete_alias = builtins.fetchGit {
        url = "https://github.com/cykerway/complete-alias.git";
        ref = "master";
        rev = "7f2555c2fe7a1f248ed2d4301e46c8eebcbbc4e2";
      };

      # # https://pyproject-nix.github.io/uv2nix/usage/getting-started.html#setting-up-a-development-environment-optional
      # Editable packages make entry points like scripts available in the virtual environment,
      # but instead of installed Python files the virtualenv contains pointers to the source tree.
      # This means that changes to the sources are immeditately activated and doesn't require a rebuild.
      pythonSet = pythonSets.${system}.overrideScope editableOverlay;
      # Create a venv with `all` dependencies
      virtualenv = pythonSet.mkVirtualEnv "hello-world-dev" workspace.deps.all;
    in {
      default = pkgs.mkShell {
        buildInputs = with pkgs;
          [
            bash
            podman
            podman-compose
            uv
          ]
          ++ [
            virtualenv
          ];
        env = {
          UV_NO_SYNC = "1";
          UV_PYTHON = pythonSet.python.interpreter;
          UV_PYTHON_DOWNLOADS = "never";
        };
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
          source ${complete_alias}/complete_alias
          complete -F _complete_alias k
        '';
      };
    };
  };
}
