{ config, lib, ... }:
with lib;
let
  # Shorter name to access a final setting
  # All modules are under the custom attribute "def"
  cfg = config.def.jellyseerr;
  srv = config.services.jellyseerr;
  certloc = "/var/lib/acme/defaultmodel.eu.org";
  url = "jellyseer.defaultmodel.eu.org";
in {
  options.def.jellyseerr = {
    enable = mkEnableOption "Jellyseerr media requester";
  };

  config = mkIf cfg.enable {
    services.jellyseerr = { enable = true; };

    ### REVERSE PROXY ###
    services.caddy = {
      virtualHosts.${url}.extraConfig = ''
        reverse_proxy http://localhost:${toString srv.port}
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
      type = "jellyseer";
      url = "https://${url}";
      key = ""; # Complete it once jellyseer generates it
    }] ++ (config.services.homepage-dashboard.widgets or [ ]);
  };
}
