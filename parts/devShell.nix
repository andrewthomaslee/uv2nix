{...}: {
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
      '';
      complete_alias = builtins.fetchGit {
        url = "https://github.com/cykerway/complete-alias.git";
        ref = "master";
        rev = "7f2555c2fe7a1f248ed2d4301e46c8eebcbbc4e2";
      };
    in {
      default = pkgs.mkShell {
        buildInputs = with pkgs; [bash];
        packages = with pkgs; [
          httpie
          kubectl
          k9s
          kompose
        ];
        shellHook = ''
          export REPO_ROOT=$(git rev-parse --show-toplevel)
          export EDITOR=${pkgs.vim}/bin/vim
          export SHELL=$(which bash)
          if [ -f $REPO_ROOT/.env ]; then
            source $REPO_ROOT/.env
          fi

          source ${bash_aliases}
          source ${complete_alias}/complete_alias
          complete -F _complete_alias k
        '';
      };
    };
  };
}
