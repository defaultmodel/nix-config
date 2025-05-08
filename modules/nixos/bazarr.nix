{ config, lib, ... }:
with lib;
let
  # Shorter name to access a final setting
  # All modules are under the custom attribute "def"
  cfg = config.def.bazarr;
  srv = config.services.bazarr;
  certloc = "/var/lib/acme/defaultmodel.eu.org";
  url = "bazarr.defaultmodel.eu.org";
in {
  options.def.bazarr = {
    enable = mkEnableOption "Bazarr subtitle manager";
    apiKeyFile = mkOption { type = types.path; };
  };

  config = mkIf cfg.enable {
    services.bazarr = {
      enable = true;
      group = "media";
      openFirewall = true;
    };

    systemd.services.bazarr.serviceConfig.EnvironmentFile = cfg.apiKeyFile;

    ### REVERSE PROXY ###
    services.caddy = {
      virtualHosts.${url}.extraConfig = ''
        reverse_proxy http://localhost:${toString srv.listenPort}
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
    def.homepage.categories."Arr*"."Bazarr" = {
      icon = "bazarr.png";
      description = "Subtitle manager";
      href = "https://${url}";
    };
  };
}
