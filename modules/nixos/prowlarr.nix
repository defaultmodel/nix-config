{ config, lib, ... }:
with lib;
let
  # Shorter name to access a final setting
  # All modules are under the custom attribute "def"
  cfg = config.def.prowlarr;
  srv = config.services.prowlarr;
  certloc = "/var/lib/acme/defaultmodel.eu.org";
  url = "prowlarr.defaultmodel.eu.org";
in {
  options.def.prowlarr = {
    enable = mkEnableOption "Prowlarr indexer manager";
    apiKeyFile = mkOption { type = types.path; };
  };

  config = mkIf cfg.enable {
    services.prowlarr = {
      enable = true;
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
    def.homepage.categories."Arr*"."Prowlarr" = {
      icon = "prowlarr.png";
      description = "Indexer manager";
      href = "https://${url}";
    };
  };
}
