{ config, lib, ... }:
with lib;
let
  # Shorter name to access a final setting
  # All modules are under the custom attribute "def"
  cfg = config.def.prowlarr;
  srv = config.services.prowlarr;
  certloc = "/var/lib/acme/defaultmodel.eu.org";
in {
  options.def.prowlarr.enable = mkEnableOption "Prowlarr indexer manager";

  config = mkIf cfg.enable {
    services.prowlarr = {
      enable = true;
      openFirewall = true;
    };

    services.caddy = {
      virtualHosts."prowlarr.defaultmodel.eu.org".extraConfig = ''
        reverse_proxy http://localhost:${toString srv.settings.server.port}
        tls ${certloc}/cert.pem ${certloc}/key.pem {
          protocols tls1.3
        }
      '';
    };
  };
}
