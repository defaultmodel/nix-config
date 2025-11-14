{
  imports = [
    ../default.nix # Common config for all hosts
    ./services/low-power.nix
    ./services/watchdog.nix
    ./services/boot.nix
  ];

  # at least I try to be secure ¯\_(ツ)_/¯
  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [ 22 ];

  users.users."root".openssh.authorizedKeys.keyFiles =
    [ ./ssh-authorized-keys ];
}
