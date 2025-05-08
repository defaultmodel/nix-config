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
      environmentFiles = [ cfg.apiKeyFile ];
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
    def.homepage.categories."Arr*"."Radarr" = {
      icon = "radarr.png";
      description = "Movie manager";
      href = "https://${url}";
    };
  };
}
