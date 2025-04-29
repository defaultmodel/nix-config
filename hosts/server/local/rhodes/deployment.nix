{ inputs, ... }: {
  deployment = {
    targetHost = "ithaca";
    targetPort = 22;
    targetUser = "root";
    tags = [ "local" ];
  };

  imports = [
    inputs.disko.nixosModules.disko
    inputs.agenix.nixosModules.default

    ./configuration.nix
  ];
}
