{...}: {
  perSystem = {
    pkgs,
    system,
    inputs',
    self',
    ...
  }: {
    # Use alejandra for 'nix fmt'
    formatter = pkgs.alejandra;
  };
}
