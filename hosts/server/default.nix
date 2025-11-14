{
  imports = [
    ../default.nix # Common config for all hosts
    ./services/low-power.nix
    ./services/watchdog.nix
    ./services/boot.nix
  ];

  # at least I try to be secure ¯\_(ツ)_/¯
  networking.firewall.enable = true;

  services.openssh.enable = true;
  networking.firewall.allowedTCPPorts = [ 22 ];

  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAtsgdnGkeAWcGjsLyQRhCJDJyfwlD0euUW37u8ou6px"
  ];

}
