{ config, lib, ... }:
with lib;
let
  # Shorter name to access a final setting
  # All modules are under the custom attribute "def"
  cfg = config.def.jellyseerr;
  srv = config.services.jellyseerr;
  certloc = "/var/lib/acme/defaultmodel.eu.org";
  url = "jellyseer.defaultmodel.eu.org";
in {
  options.def.jellyseerr = {
    enable = mkEnableOption "Jellyseerr media requester";
  };

  config = mkIf cfg.enable {
    services.jellyseerr = {
      enable = true;
      openFirewall = true;
    };

    ### REVERSE PROXY ###
    services.caddy = {
      virtualHosts.${url}.extraConfig = ''
        reverse_proxy http://localhost:${toString srv.port}
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
    def.homepage.categories."Media"."Jellyseer" = {
      icon = "jellyseerr.png";
      description = "Request manager";
      href = "https://${url}";
    };
  };
}
