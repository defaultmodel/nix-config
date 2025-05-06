{ config, lib, ... }:
with lib;
let
  # Shorter name to access a final setting
  # All modules are under the custom attribute "def"
  cfg = config.def.lidarr;
  srv = config.services.lidarr;
  certloc = "/var/lib/acme/defaultmodel.eu.org";
  url = "lidarr.defaultmodel.eu.org";
in {
  options.def.lidarr = {
    enable = mkEnableOption "lidarr subtitle manager";
    apiKeyFile = mkOption { type = types.path; };
  };

  config = mkIf cfg.enable {
    services.lidarr = {
      enable = true;
      group = "media";
      openFirewall = true;
    };

    # The same could be done via services.radarr.environmentFiles
    # But this solution for every service rather than just the *arrs
    systemd.services.lidarr = {
      serviceConfig = {
        LoadCredential = [ "key:${cfg.apiKeyFile}" ];
        Environment = [ "LIDARR__AUTH__APIKEY=%d/key" ];
      };
    };

    services.adguardhome.settings.dns.rewrites = [{
      domain = url;
      answer = config.networking.interfaces.ens18.ipv4;
    }] ++ (config.services.adguardhome.settings.dns.rewrites or [ ]);

    ### REVERSE PROXY ###
    services.caddy = {
      virtualHosts.${url}.extraConfig = ''
        reverse_proxy http://localhost:${toString srv.settings.server.port}
        tls ${certloc}/cert.pem ${certloc}/key.pem {
             protocols tls1.3
           }
      '';
    };

    ### HOMEPAGE ###
    systemd.services.homepage-dashboard = {
      serviceConfig = {
        LoadCredential = [ "key:${cfg.apiKeyFile}" ];
        Environment = [ "HOMEPAGE_FILE_LIDARR_APIKEY=%d/key" ];
      };
    };

    services.homepage-dashboard.widgets = [{
      type = "lidarr";
      url = "https://${url}";
      # This will be replace by the env var we set above with systemd credentials
      key = "{{HOMEPAGE_FILE_LIDARR_APIKEY}}";
    }] ++ (config.services.homepage-dashboard.widgets or [ ]);
  };
}
