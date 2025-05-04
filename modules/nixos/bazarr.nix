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

    # systemd.services.bazarr = {
    #   serviceConfig = {
    #     LoadCredential =
    #       [ "api_key:${config.age.secrets.bazarr_api_key.path}" ];
    #     Environment = "BAZARR__AUTH__APIKEY=%d/api_key";
    #   };
    # };

    services.caddy = {
      virtualHosts.${url}.extraConfig = ''
        reverse_proxy http://localhost:${toString srv.listenPort}
        tls ${certloc}/cert.pem ${certloc}/key.pem {
             protocols tls1.3
           }
      '';
    };

    services.adguardhome.settings.dns.rewrites = [{
      domain = url;
      answer = config.networking.interfaces.ens18.ipv4;
    }] ++ (config.services.adguardhome.settings.dns.rewrites or [ ]);

    # services.homepage-dashboard.widgets = [{
    # type = "bazarr";
    # url = "https://${url}";
    # key = ;
    # }] ++ (config.services.homepage.dashboard.widgets or [ ]);
  };
}
