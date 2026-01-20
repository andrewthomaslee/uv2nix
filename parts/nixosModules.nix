{
  self,
  projectName,
  projectScripts,
  ...
}: {
  flake = {
    nixosModules = let
      # Function that creates a NixOS module for a specific script name
      mkOciModule = scriptName: {
        name = "oci-${scriptName}";
        value = {pkgs, ...}: let
          # fetch the packages from this flake
          image = self.packages.${pkgs.stdenv.hostPlatform.system}."container-stream-${scriptName}";
        in {
          # The NixOS Module
          virtualisation.oci-containers.containers."${projectName}-${scriptName}" = {
            image = "${image.imageName}:${image.imageTag}";
            imageStream = image;
          };
        };
      };
      # Convert list of scripts to attrset of modules
      dynamicModules = builtins.listToAttrs (map mkOciModule projectScripts);
    in
      {
        default = {pkgs, ...}: {
          environment.systemPackages = [
            self.packages.${pkgs.stdenv.hostPlatform.system}.default
          ];
        };
      }
      # merge the modules into a single attrset
      // dynamicModules;
  };
}
