{...}: {
  perSystem = {
    pkgs,
    system,
    inputs',
    self',
    ...
  }: {
    nixosModules = {
      default = {...}: {
        programs.firefox.enable = true;
      };
    };
  };
}
