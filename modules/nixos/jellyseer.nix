{ config, lib, ... }:
with lib;
let
  # Shorter name to access a final setting
  # All modules are under the custom attribute "def"
  cfg = config.def.jellyseerr;
  srv = config.services.jellyseerr;
  certloc = "/var/lib/acme/defaultmodel.eu.org";
in {
  options.def.jellyseerr = {
    enable = mkEnableOption "Jellyseerr media requester";
  };

  config = mkIf cfg.enable {
    services.jellyseerr = { enable = true; };

    services.caddy = {
      virtualHosts."jellyseer.defaultmodel.eu.org".extraConfig = ''
        reverse_proxy http://localhost:${toString srv.port}
        tls ${certloc}/cert.pem ${certloc}/key.pem {
          protocols tls1.3
        }
      '';
    };
  };
}
