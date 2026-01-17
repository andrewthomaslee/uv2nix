{self, ...}: {
  flake = {
    nixosModules = {
      default = {pkgs, ...}: {
        # include our package into the NixOS system packages
        environment.systemPackages = [
          self.packages.${pkgs.stdenv.hostPlatform.system}.default
        ];
      };
    };
  };
}
