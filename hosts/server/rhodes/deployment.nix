{ inputs, ... }: {
  deployment = {
    targetHost = "rhodes";
    targetPort = 22;
    targetUser = "root";
    tags = [ "local" ];
  };

  imports = [
    inputs.disko.nixosModules.disko
    inputs.agenix.nixosModules.default
    inputs.vpn-confinement.nixosModules.default

    ./configuration.nix
  ];
}
