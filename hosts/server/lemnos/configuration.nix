{ ... }: {

  imports = [
    ../default.nix # Common config for all servers
    ./hardware-configuration.nix

    # ./backup.nix

    # ./services/caddy.nix
    # ./services/miniflux.nix
    # ./services/vaultwarden.nix
    # ./services/radicale.nix
  ];

  age.identityPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

  services.openssh = { enable = true; };

  networking.hostName = "lemnos";
}
