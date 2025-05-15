{ config, pkgs, lib, ... }:
with lib;
let
  srv = config.services.transmission;
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

  age.secrets.torrent-credentials = {
    file = ../../../../../secrets/torrent-credentials.age;
    mode = "400";
    owner = srv.user;
  };

  # Enable and specify VPN namespace to confine service in.
  systemd.services.transmission.vpnConfinement = {
    enable = true;
    vpnNamespace = "wg";
  };

  # Port mappings
  vpnNamespaces.wg = {
    portMappings = [{
      from = srv.settings.rpc-port;
      to = srv.settings.rpc-port;
      protocol = "both";
    }];
    openVPNPorts = [{
      port = srv.settings.peer-port;
      protocol = "both";
    }];
  };

  users.users.torrent = {
    isSystemUser = true;
    group = "media";
  };

  services.transmission = {
    enable = true;
    user = "torrent";
    group = "media";

    webHome = pkgs.flood-for-transmission;
    credentialsFile = config.age.secrets.torrent-credentials.path;

    openRPCPort = true;
    openPeerPorts = true;

    settings = {
      download-dir = downloadDir;
      incomplete-dir-enabled = true;
      incomplete-dir = incompleteDir;
      watch-dir-enabled = true;
      watch-dir = watchDir;

      rpc-bind-address =
        "0.0.0.0"; # Bind RPC/WebUI to VPN network namespace address
      rpc-port = 9091;
      rpc-whitelist-enabled = true;
      # "192.168.15.5"; Access from default network namespace
      # "192.168.1.*";  Access from other machines on specific subnet
      # "127.0.0.1";    Access through loopback within VPN network namespace
      rpc-whitelist =
        strings.concatStringsSep "," ([ "127.0.0.1,192.168.1.*,192.168.15.5" ]);
      rpc-host-whitelist-enabled = true;
      rpc-host-whitelist = url;
      rpc-authentication-required = false;

      blocklist-enabled = true;
      blocklist-url =
        "https://github.com/Naunter/BT_BlockLists/raw/master/bt_blocklists.gz";

      peer-port = 50000;
      dht-enabled = true;
      pex-enabled = true;
      utp-enabled = false;
      encryption = 1;
      port-forwarding-enabled = false;

      anti-brute-force-enabled = true;
      anti-brute-force-threshold = 10;
    };
  };

  ### REVERSE PROXY ###
  services.caddy = {
    virtualHosts.${url}.extraConfig = ''
      reverse_proxy http://192.168.15.1:${toString srv.settings.rpc-port}
      tls ${certloc}/cert.pem ${certloc}/key.pem {
        protocols tls1.3
      }
    '';
  };

  services.adguardhome.settings.filtering.rewrites = [{
    domain = url;
    answer =
      (builtins.elemAt (config.networking.interfaces.bond0.ipv4.addresses)
        0).address;
  }];

  ### HOMEPAGE ###
  def.homepage.categories."Downloaders"."Transmission" = {
    icon = "transmission.png";
    description = "Torrent downloader";
    href = "https://${url}";
  };
}
