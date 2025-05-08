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
      environmentFiles = [ cfg.apiKeyFile ];
    };

    services.adguardhome.settings.filtering.rewrites = [{
      domain = url;
      answer =
        (builtins.elemAt (config.networking.interfaces.bond0.ipv4.addresses)
          0).address;
    }];

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
    def.homepage.categories."Arr*"."Lidarr" = {
      icon = "lidarr.png";
      description = "Music manager";
      href = "https://${url}";
    };
  };
}
