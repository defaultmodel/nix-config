{ config, lib, pkgs, ... }:
with lib;
let
  # Shorter name to access a final setting
  # All modules are under the custom attribute "def"
  cfg = config.def.torrent;
  srv = config.services.transmission;
  certloc = "/var/lib/acme/defaultmodel.eu.org";
in
{
  options.def.torrent = {
    enable = mkEnableOption "Torrent downloader";
    mediaDir = mkOption { type = types.path; };
    guiPort = mkOption {
      type = types.int;
      default = 8112;
    };
    authFile = mkOption { type = types.path; };
    vpn.enable = mkEnableOption "confinement of deluge to a VPN";
  };

  config = mkIf cfg.enable {
    systemd.tmpfiles.rules = [
      "d '${cfg.mediaDir}/torrent'             0755 ${srv.user} ${srv.group} - -"
      "d '${cfg.mediaDir}/torrent/.incomplete' 0755 ${srv.user} ${srv.group} - -"
      "d '${cfg.mediaDir}/torrent/.watch'      0755 ${srv.user} ${srv.group} - -"
      "d '${cfg.mediaDir}/torrent/movies'      0775 ${srv.user} ${srv.group} - -"
      "d '${cfg.mediaDir}/torrent/shows'       0775 ${srv.user} ${srv.group} - -"
      "d '${cfg.mediaDir}/torrent/music'       0775 ${srv.user} ${srv.group} - -"
    ];

    # Enable and specify VPN namespace to confine service in.
    systemd.services.transmission.vpnConfinement = mkIf cfg.vpn.enable {
      enable = true;
      vpnNamespace = "wg";
    };

    # Port mappings
    vpnNamespaces.wg = mkIf cfg.vpn.enable {
      portMappings = [{
        from = cfg.guiPort;
        to = cfg.guiPort;
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
    users.groups.torrent = { };

    services.transmission = {
      enable = true;
      user = "torrent";
      group = "media";

      webHome = pkgs.flood-for-transmission;
      credentialsFile = cfg.authFile;

      openRPCPort = true;
      openPeerPorts = true;

      settings = {
        download-dir = "${cfg.mediaDir}/torrent";
        incomplete-dir-enabled = true;
        incomplete-dir = "${cfg.mediaDir}/torrent/.incomplete";
        watch-dir-enabled = true;
        watch-dir = "${cfg.mediaDir}/torrent/.watch";

        rpc-bind-address = "0.0.0.0";
        rpc-port = cfg.guiPort;
        rpc-whitelist-enabled = true;
        rpc-whitelist = strings.concatStringsSep "," ([
          "127.0.0.1,192.168.1.*" # Defaults
        ]);
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
        reverse_proxy http://localhost:${toString srv.settings.rpc-port}
        tls ${certloc}/cert.pem ${certloc}/key.pem {
          protocols tls1.3
        }
      '';
    };

    services.adguardhome.settings.dns.rewrites = [{
      domain = url;
      answer = config.networking.interfaces.ens18.ipv4;
    }] ++ (config.services.adguardhome.settings.dns.rewrites or [ ]);

    ### HOMEPAGE ###
    services.homepage-dashboard.widgets = [{
      type = "transmission";
      url = "https://${url}";
      username = "";
      password = "";
    }] ++ (config.services.homepage-dashboard.widgets or [ ]);
  };
}
