{ config, lib, ... }:
with lib;
let
  # Shorter name to access a final setting
  # All modules are under the custom attribute "def"
  cfg = config.def.radarr;
  srv = config.services.radarr;
  certloc = "/var/lib/acme/defaultmodel.eu.org";
  url = "radarr.defaultmodel.eu.org";
in {
  options.def.radarr = {
    enable = mkEnableOption "Radarr movie manager";
    apiKeyFile = mkOption { type = types.path; };
  };

  config = mkIf cfg.enable {
    services.radarr = {
      enable = true;
      group = "media";
      openFirewall = true;
    };

    # The same could be done via services.radarr.environmentFiles
    # But this solution for every service rather than just the *arrs
    systemd.services.radarr = {
      serviceConfig = {
        LoadCredential = [ "key:${cfg.apiKeyFile}" ];
        Environment = [ "RADARR__AUTH__APIKEY=%d/key" ];
      };
    };

    ### REVERSE PROXY ###
    services.caddy = {
      virtualHosts.${url}.extraConfig = ''
        reverse_proxy http://localhost:${toString srv.settings.server.port}
        tls ${certloc}/cert.pem ${certloc}/key.pem {
          protocols tls1.3
        }
      '';
    };

    services.adguardhome.settings.dns.rewrites = [{
      domain = url;
      answer = config.networking.interfaces.bond0.ipv4;
    }] ++ (config.services.adguardhome.settings.dns.rewrites or [ ]);

    ### HOMEPAGE ###
    systemd.services.homepage-dashboard = {
      serviceConfig = {
        LoadCredential = [ "key:${cfg.apiKeyFile}" ];
        Environment = [ "HOMEPAGE_FILE_RADARR_APIKEY=%d/key" ];
      };
    };

    services.homepage-dashboard.widgets = [{
      type = "radarr";
      url = "https://${url}";
      # This will be replace by the env var we set above with systemd credentials
      key = "{{HOMEPAGE_FILE_RADARR_APIKEY}}";
    }] ++ (config.services.homepage-dashboard.widgets or [ ]);
  };
}
