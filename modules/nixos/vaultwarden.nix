{ config, lib, ... }:
with lib;
let
  # Shorter name to access a final setting
  # All modules are under the custom attribute "def"
  cfg = config.def.vaultwarden;
  srv = config.services.vaultwarden;
  certloc = "/var/lib/acme/defaultmodel.eu.org";
  url = "vaultwarden.defaultmodel.eu.org";
in
{
  options.def.vaultwarden = {
    enable = mkOption {
      default = false;
      type = types.bool;
    };
  };

  config = mkIf config.def.vaultwarden.enable {
    services.vaultwarden = {
      enable = true;
      dbBackend = "sqlite";
      config = {
        SIGNUPS_ALLOWED = false;
        ROCKET_ADDRESS = "0.0.0.0";
        ROCKET_PORT = 8222;
      };
    };

    ### REVERSE PROXY ###
    services.caddy = {
      virtualHosts.${url}.extraConfig = ''
        reverse_proxy http://localhost:${toString srv.config.ROCKET_PORT}
        tls ${certloc}/cert.pem ${certloc}/key.pem {
          protocols tls1.3
        }
      '';
    };

    services.adguardhome.settings.dns.rewrites = [{
      domain = url;
      answer = config.networking.interfaces.enp2s0.ipv4;
    }] ++ (config.services.adguardhome.settings.dns.rewrites or [ ]);

    ### HOMEPAGE ###
    services.homepage-dashboard.widgets = [{
      type = "sonarr";
      url = "https://${url}";
      # This will be replace by the env var we set above with systemd credentials
      key = "{{HOMEPAGE_FILE_SONARR_APIKEY}}";
    }] ++ (config.services.homepage-dashboard.widgets or [ ]);
  };
}
