{ config, lib, ... }:
with lib;
let
  # Shorter name to access a final setting
  # All modules are under the custom attribute "def"
  cfg = config.def.slskd;
  srv = config.services.slskd;
  certloc = "/var/lib/acme/defaultmodel.eu.org";
in {
  options.def.slskd = {
    enable = mkEnableOption "Slskd music downloader";
    mediaDir = mkOption { type = types.path; };
    authFile = mkOption { type = types.path; };
    vpn.enable = mkEnableOption "confinement of slskd to a VPN";
  };

  config = mkIf cfg.enable {
    systemd.tmpfiles.rules = [
      "d '${cfg.mediaDir}/soulseek/incomplete'  0755 ${srv.user} ${srv.group} - -"
      "d '${cfg.mediaDir}/soulseek/complete'    0775 ${srv.user} ${srv.group} - -"
    ];

    # Enable and specify VPN namespace to confine service in.
    systemd.services.deluge.vpnConfinement = mkIf cfg.vpn.enable {
      enable = true;
      vpnNamespace = "wg";
    };

    vpnNamespaces.wg = mkIf cfg.vpn.enable {
      openVPNPorts = [
        {
          port = 2271;
          protocol = "both";
        } # Connection to soulseek server
        {
          port = 50300;
          protocol = "both";
        } # P2P connection
      ];
    };

    services.slskd = {
      enable = true;
      openFirewall = true;
      domain = null;
      environmentFile = cfg.authFile;
      settings = {
        global = {
          upload.slots = 30;
          upload.speed_limit = 10000;
          download.speed_limit = 10000;
        };
        web = { port = 5030; };
        directories = {
          downloads = "/mnt/shares/data/soulseek/complete";
          incomplete = "/mnt/shares/data/soulseek/incomplete";
        };
        shares = {
          directories = [
            "${cfg.mediaDir}/media/movies"
            "${cfg.mediaDir}/media/shows"
            "${cfg.mediaDir}/media/music"
          ];
        };
      };
    };

    services.caddy = {
      virtualHosts."slskd.defaultmodel.eu.org".extraConfig = ''
        reverse_proxy http://localhost:${toString srv.settings.web.port}
        tls ${certloc}/cert.pem ${certloc}/key.pem {
          protocols tls1.3
        }
      '';
    };
  };
}
