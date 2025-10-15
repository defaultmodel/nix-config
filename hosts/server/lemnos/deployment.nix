{ inputs, ... }: {
  deployment = {
    targetHost = "lemnos";
    targetPort = 22;
    targetUser = "root";
    tags = [ "remote" "vps" "oracle" ];
  };

  imports = [
    inputs.disko.nixosModules.disko
    inputs.agenix.nixosModules.default
    inputs.vpn-confinement.nixosModules.default

    ./configuration.nix
  ];
}
