{ config, lib, ... }:
with lib;
let
  # Shorter name to access a final setting
  # All modules are under the custom attribute "def"
  cfg = config.def.torrent;
  srv = config.services.deluge;
  certloc = "/var/lib/acme/defaultmodel.eu.org";
in {
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
    systemd.services.deluge.vpnConfinement = mkIf cfg.vpn.enable {
      enable = true;
      vpnNamespace = "wg";
    };

    # Port mappings
    vpnNamespaces.wg = mkIf cfg.vpn.enable {
      openVPNPorts = [
        {
          port = cfg.guiPort;
          protocol = "both";
        }
        {
          port = 58846;
          protocol = "both";
        }
        {
          port = 6881;
          protocol = "both";
        }
        {
          port = 6891;
          protocol = "both";
        }
      ];
    };

    users.users.torrent = {
      isSystemUser = true;
      group = "media";
    };
    users.groups.torrent = { };

    services.deluge = {
      enable = true;
      user = "torrent";
      group = "media";

      declarative = true;
      authFile = cfg.authFile;

      openFirewall = true;
      web = {
        enable = true;
        port = cfg.guiPort;
        openFirewall = true;
      };

      # All options are here https://git.deluge-torrent.org/deluge/tree/deluge/core/preferencesmanager.py#n37
      # Following recommendations from https://trash-guides.info/Downloaders/Deluge/Basic-Setup/
      config = {
        pre_allocate_storeage = true;
        upnp = false;
        natpmp = false;
        enabled_plugins = [ "Label" "Web" ];
        download_location = "${cfg.mediaDir}/torrents/";
        max_upload_speed = "6000.0";
        allow_remote = true;
        daemon_port = 58846;
        listen_ports = [ 6881 6891 ];
      };
    };

    services.caddy = {
      virtualHosts."torrent.defaultmodel.eu.org".extraConfig = ''
        reverse_proxy http://localhost:${toString srv.web.port}
        tls ${certloc}/cert.pem ${certloc}/key.pem {
          protocols tls1.3
        }
      '';
    };
  };
}
