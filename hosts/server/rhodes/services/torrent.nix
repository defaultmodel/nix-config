{ config, ... }:
let
  srv = config.services.qbittorrent;
  certloc = "/var/lib/acme/defaultmodel.eu.org";
  url = "torrent.defaultmodel.eu.org";

  # Download will be actually be moved based on their tags
  downloadDir = "/data/torrent";
  incompleteDir = "/data/torrent/.incomplete";
  watchDir = "/data/torrent/.watch";
in {
  systemd.tmpfiles.rules = [
    "d '${downloadDir}'             0775 ${srv.user} ${srv.group} - -"
    "d '${incompleteDir}' 0755 ${srv.user} ${srv.group} - -"
    "d '${watchDir}'      0755 ${srv.user} ${srv.group} - -"
    "d '${downloadDir}/movies'      0775 ${srv.user} ${srv.group} - -"
    "d '${downloadDir}/shows'       0775 ${srv.user} ${srv.group} - -"
    "d '${downloadDir}/music'       0775 ${srv.user} ${srv.group} - -"
  ];

  users.users.torrent = {
    isSystemUser = true;
    group = "media";
  };

  services.qbittorrent = {
    enable = true;
    user = "torrent";
    group = "media";

    webuiPort = 8301;
    torrentingPort = 24325;
    openFirewall = true;

    serverConfig = {
      LegalNotice.Accepted = true;
      Core.AutoDeleteAddedTorrentFile = "IfAdded";
      BitTorrent.Session = {
        AddTorrentStopped = false;
        AlternativeGlobalDLSpeedLimit = 0;
        AlternativeGlobalUPSpeedLimit = 0;
        BTProtocol = "TCP";
        DefaultSavePath = "/data/torrent";
        DisableAutoTMMByDefault = false;
        DisableAutoTMMTriggers.CategorySavePathChanged = false;
        DisableAutoTMMTriggers.DefaultSavePathChanged = false;
        MaxConnections = -1;
        MaxConnectionsPerTorrent = -1;
        MaxUploads = -1;
        MaxUploadsPerTorrent = -1;
        Preallocation = true;
        QueueingSystemEnabled = false;
        TempPathEnabled = true;
        TempPath = "/data/torrent/.incomplete";
        # Bind to the ProtonVPN WireGuard interface to avoid leaks
        Interface = "wg0";
        InterfaceName = "wg0";
      };
      Preferences = {
        General.Locale = "fr";
        WebUI = {
          Username = "defaultmodel";
          # nix run git+https://codeberg.org/feathecutie/qbittorrent_password -- -p <password>
          Password_PBKDF2 =
            "@ByteArray(QuhSmvrTLctWL2odAFfaUw==:ohAN42sYKMkovM5XIAVy+FgjMw/hZ1vcdEigNQiLjB+/1rTS5GB/ALgsE8+KHwUVMbN4ca2zWXCmv8c2jV0xBg==)";
          Address = "192.168.15.1"; # Address in `ip netns exec wg ip a`
          AuthSubnetWhitelistEnabled = true;
          AuthSubnetWhitelist = "192.168.15.5, 192.168.8.0/24, 127.0.0.1";
          ClickjackingProtection = false;
          CSRFProtection = false;
        };
        Network.PortForwardingEnabled = false;
      };
    };
  };

  services.caddy = {
    virtualHosts.${url}.extraConfig = ''
      reverse_proxy http://192.168.15.1:${toString srv.webuiPort}
      tls ${certloc}/cert.pem ${certloc}/key.pem {
        protocols tls1.3
      }
    '';
  };

  services.adguardhome.settings.filtering.rewrites = [{
    domain = url;
    answer =
      (builtins.elemAt (config.networking.interfaces.enp2s0.ipv4.addresses)
        0).address;
  }];

  ### HOMEPAGE ###
  def.homepage.categories."Downloaders"."qBittorrent" = {
    icon = "qbittorrent.png";
    description = "Torrent downloader";
    href = "https://${url}";
  };

  ### VPN ###
  # Enable and specify VPN namespace to confine service in.
  systemd.services."qbittorrent".vpnConfinement = {
    enable = true;
    vpnNamespace = "wg";
  };
  systemd.services."qbittorrent-nox".vpnConfinement = {
    enable = true;
    vpnNamespace = "wg";
  };

  # Port mappings
  vpnNamespaces.wg = {
    portMappings = [{
      from = srv.webuiPort;
      to = srv.webuiPort;
    }];
    openVPNPorts = [{
      port = srv.torrentingPort;
      protocol = "both";
    }];
  };
}
