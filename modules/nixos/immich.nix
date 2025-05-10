{ config, lib, ... }:
with lib;
let
  # Shorter name to access a final setting
  # All modules are under the custom attribute "def"
  cfg = config.def.immich;
  srv = config.services.immich;
  certloc = "/var/lib/acme/defaultmodel.eu.org";
  url = "immich.defaultmodel.eu.org";
in {
  options.def.immich = {
    enable = mkOption {
      default = false;
      type = types.bool;
    };

    photoFolder = mkOption { type = types.path; };
  };

  config = mkIf cfg.enable {
    systemd.tmpfiles.rules =
      [ "d '${cfg.photoFolder}'        0775 ${srv.user} ${srv.group} - -" ];

    services.immich = {
      enable = true;
      host = "0.0.0.0";
      port = 2283;
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
    def.homepage.categories."Media"."Immich" = {
      icon = "immich.png";
      description = "Photo manager";
      href = "https://${url}";
    };
  };
}
