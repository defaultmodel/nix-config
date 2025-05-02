{ config, lib, ... }:
with lib;
let
  # Shorter name to access a final setting
  # All modules are under the custom attribute "def"
  cfg = config.def.radarr;
  srv = config.services.radarr;
  certloc = "/var/lib/acme/defaultmodel.eu.org";
in {
  options.def.radarr = {
    enable = mkEnableOption "Radarr movie manager";
    authFile = mkOption { type = types.path; };
  };

  config = mkIf cfg.enable {
    services.radarr = {
      enable = true;
      group = "media";
      openFirewall = true;
      # Set the api key through here
      environmentFiles = [ cfg.authFile ];
    };

    services.caddy = {
      virtualHosts."radarr.defaultmodel.eu.org".extraConfig = ''
        reverse_proxy http://localhost:${toString srv.settings.server.port}
        tls ${certloc}/cert.pem ${certloc}/key.pem {
          protocols tls1.3
        }
      '';
    };
  };
}
