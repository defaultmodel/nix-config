{ config, lib, ... }:
with lib;
let
  # Shorter name to access a final setting
  # All modules are under the custom attribute "def"
  cfg = config.def.sonarr;
  srv = config.services.sonarr;
  certloc = "/var/lib/acme/defaultmodel.eu.org";
  url = "sonarr.defaultmodel.eu.org";
in {
  options.def.sonarr = {
    enable = mkEnableOption "Sonarr movie manager";
    apiKeyFile = mkOption { type = types.path; };
  };

  config = mkIf cfg.enable {
    services.sonarr = {
      enable = true;
      group = "media";
      openFirewall = true;
      environmentFiles = [ cfg.apiKeyFile ];
    };

    # The same could be done via services.radarr.environmentFiles
    # But this solution for every service rather than just the *arrs
    systemd.services.sonarr = {
      serviceConfig = {
        LoadCredential = [ "key:${cfg.apiKeyFile}" ];
        Environment = [ "SONARR__AUTH__APIKEY=%d/key" ];
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

    services.adguardhome.settings.filtering.rewrites = [{
      domain = url;
      answer =
        (builtins.elemAt (config.networking.interfaces.bond0.ipv4.addresses)
          0).address;
    }];

    ### HOMEPAGE ###
    def.homepage.categories."Arr*"."Sonarr" = {
      icon = "sonarr.png";
      description = "Show manager";
      href = "https://${url}";
    };
  };
}
