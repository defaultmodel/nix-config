{ ... }: {

  imports = [
    ../default.nix # Common config for all servers
    ./hardware-configuration.nix

    ./media.nix
    ./backup.nix

    ./services/adguardhome.nix
    ./services/homepage.nix
    ./services/caddy.nix
    # ./services/rss.nix
    # ./services/vaultwarden.nix
    # ./services/immich.nix
    # ./services/paperless.nix
    ./services/fancontrol.nix
    # ./services/hedgedoc.nix
    # ./services/monitoring/default.nix
    # ./services/protonmail-bridge.nix
    # ./services/radicale.nix
  ];

  networking = {
    hostName = "homelab";
    interfaces.enp2s0 = {
      ipv4.addresses = [{
        address = "192.168.8.132";
        prefixLength = 24;
      }];
    };
    defaultGateway = {
      address = "192.168.8.1";
      interface = "enp2s0";
    };
  };
}
