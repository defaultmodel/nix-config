{ config, lib, ... }:
with lib;
let
  # Shorter name to access a final setting
  # All modules are under the custom attribute "def"
  cfg = config.def.rss;
  srv = config.services.miniflux;
  certloc = "/var/lib/acme/defaultmodel.eu.org";
  url = "rss.defaultmodel.eu.org";
in {
  options.def.rss = {
    enable = mkEnableOption "RSS feed read";
    authFile = mkOption { type = types.path; };
  };

  config = mkIf cfg.enable {
    services.miniflux = {
      enable = true;
      adminCredentialsFile = cfg.authFile;
      config = {
        CREATE_ADMIN = 1;
        LISTEN_ADDR = "0.0.0.0:7381";
        PORT = 7381;
      };
    };

    ### REVERSE PROXY ###
    services.caddy = {
      virtualHosts.${url}.extraConfig = ''
        reverse_proxy http://localhost:${toString srv.config.PORT}
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
      type = "miniflux";
      url = "https://${url}";
      key = ""; # Complete it once miniflux generates it
    }] ++ (config.services.homepage-dashboard.widgets or [ ]);
  };
}
