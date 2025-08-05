{ ... }: {

  imports = [
    ../default.nix # Common config for all local servers
    ./disk-config.nix
    ./hardware-configuration.nix

    ./nas.nix
    ./media.nix
    ./backup.nix

    ./services/adguardhome.nix
    ./services/homepage.nix
    ./services/caddy.nix
    ./services/rss.nix
    ./services/vaultwarden.nix
    # ./services/immich.nix
    ./services/paperless.nix
    ./services/fancontrol.nix
    ./services/hedgedoc.nix
    ./services/monitoring/default.nix
    ./services/protonmail-bridge.nix
    ./services/radicale.nix
  ];

  networking = {
    hostName = "rhodes";
    interfaces.bond0.ipv4.addresses = [{
      address = "192.168.1.30";
      prefixLength = 24;
    }];
    defaultGateway = {
      address = "192.168.1.1";
      interface = "bond0";
    };
    bonds = {
      bond0 = {
        interfaces = [ "enp2s0" "enp3s0" ];
        driverOptions = {
          miimon = "100"; # Monitor MII link every 100ms
          mode = "802.3ad";
          xmit_hash_policy = "layer3+4"; # IP and TCP/UDP hash
        };
      };
    };
  };

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 80 443 ];
  };

}
