{
  imports = [
    ../default.nix # Common config for all hosts
    ./services/low-power.nix
    ./services/watchdog.nix
  ];

  # at least I try to be secure ¯\_(ツ)_/¯
  networking.firewall.enable = true;
}
