{self, ...}: {
  flake = {
    nixosModules = {
      default = {pkgs, ...}: {
        # include our package into the NixOS system packages
        environment.systemPackages = [
          self.packages.${pkgs.stdenv.hostPlatform.system}.default
        ];
      };
      oci = {pkgs, ...}: {
        # OCI (Docker) containers to run as systemd services
        # https://search.nixos.org/options?channel=unstable&query=virtualisation.oci-containers
        virtualisation.oci-containers.containers.hello-world = {
          imageStream = self.packages.${pkgs.stdenv.hostPlatform.system}.container-stream;
        };
      };
    };
  };
}
