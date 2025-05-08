{ config, lib, ... }:
with lib;
let
  # Shorter name to access a final setting
  # All modules are under the custom attribute "def"
  cfg = config.def.jellyfin;
  srv = config.services.jellyfin;
  certloc = "/var/lib/acme/defaultmodel.eu.org";
  url = "jellyfin.defaultmodel.eu.org";
in {
  options.def.jellyfin = {
    enable = mkEnableOption "Jellyfin media system";
    mediaDir = mkOption { type = types.path; };
  };

  config = mkIf cfg.enable {
    # Always prioritise Jellyfin IO
    systemd.services.jellyfin.serviceConfig.IOSchedulingPriority = 0;

    systemd.tmpfiles.rules = [
      "d '${cfg.mediaDir}/media/shows'        0775 ${srv.user} ${srv.group} - -"
      "d '${cfg.mediaDir}/media/movies'       0775 ${srv.user} ${srv.group} - -"
      "d '${cfg.mediaDir}/media/music'        0775 ${srv.user} ${srv.group} - -"
    ];

    services.jellyfin = {
      enable = true;
      group = "media";
      openFirewall = true;
    };

    services.caddy = {
      virtualHosts.${url}.extraConfig = ''
        reverse_proxy http://localhost:8096
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
    def.homepage.categories."Media"."Jellyfin" = {
      icon = "jellyfin.png";
      description = "Media streamer";
      href = "https://${url}";
    };
  };
}

