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

    services.adguardhome.settings.filtering.rewrites = [{
      domain = url;
      answer =
        (builtins.elemAt (config.networking.interfaces.bond0.ipv4.addresses)
          0).address;
    }];

    ### HOMEPAGE ###
    def.homepage.categories."Other"."Miniflux " = {
      icon = "rsshub.png";
      description = "RSS feed handler";
      href = "https://${url}";
    };
  };
}
