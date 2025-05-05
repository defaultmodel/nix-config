{ config, lib, ... }:
with lib;
let
  # Shorter name to access a final setting
  # All modules are under the custom attribute "def"
  cfg = config.def.immich;
  srv = config.services.immich;
  certloc = "/var/acme/defaultmodel.eu.org";
  url = "immich.defaultmodel.eu.org";
in
{
  options.def.immich = {
    enable = mkOption {
      default = false;
      type = types.bool;
    };

    photoFolder = mkOption {
      type = types.path;
    };
  };

  config = mkIf cfg.enable {
    services.immich = {
      enable = true;
      host = "0.0.0.0";
      port = 2283;
    };

    networking.firewall.allowedTCPPorts = [
      cfg.port
    ];

    ### REVERSE PROXY ###
    services.caddy = {
      virtualHosts.${url}.extraConfig = ''
        reverse_proxy http://localhost:${toString srv.port}
        tls ${certloc}/cert.pem ${certloc}/key.pem {
             protocols tls1.3
           }
      '';
    };

    services.adguardhome.settings.dns.rewrites = [{
      domain = url;
      answer = config.networking.interfaces.ens18.ipv4;
    }] ++ (config.services.adguardhome.settings.dns.rewrites or [ ]);

    ### HOMEPAGE ###
    services.homepage-dashboard.widgets = [{
      type = "immich";
      url = "https://${url}";
      key = ""; # Complete it once immich generates it
      version = 2;
    }] ++ (config.services.homepage-dashboard.widgets or [ ]);
  };
}
