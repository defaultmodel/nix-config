{ inputs, ... }:
{
  deployment = {
    targetHost = "158.180.44.80";
    targetPort = 22;
    targetUser = "root";
    tags = [ "remote" "oracle" "vps" ];
  };
  imports = [
    hosts/default.nix
    hosts/remote/default.nix
    hosts/remote/lemnos/configuration.nix
    inputs.disko.nixosModules.disko
    inputs.agenix.nixosModules.default

  ];
}
