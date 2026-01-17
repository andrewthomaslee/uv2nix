{
  self,
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
    # Use alejandra for 'nix fmt'
    formatter = pkgs.alejandra;

    checks = {
      inherit (pythonSets.${system}.hello-world.passthru.tests) ruff pyrefly pytest;
      alejandra = pkgs.stdenv.mkDerivation {
        name = "alejandra";
        src = ../.;
        nativeBuildInputs = [pkgs.alejandra];
        dontConfigure = true;
        buildPhase = ''
          runHook preBuild
          alejandra --check $src
          runHook postBuild
        '';
        installPhase = ''
          runHook preInstall
          touch $out
          runHook postInstall
        '';
      };
    };
  };
  flake.templates = {
    default = {
      path = self;
      description = "hello world application using uv2nix";
    };
  };
}
