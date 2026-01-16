{...}: {
  perSystem = {
    pkgs,
    system,
    inputs',
    self',
    ...
  }: {
    packages = {
      default = pkgs.hello;
    };
  };
}
