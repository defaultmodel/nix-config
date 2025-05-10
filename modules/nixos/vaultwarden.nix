{ config, lib, ... }:
with lib;
let
  # Shorter name to access a final setting
  # All modules are under the custom attribute "def"
  cfg = config.def.vaultwarden;
  srv = config.services.vaultwarden;
  certloc = "/var/lib/acme/defaultmodel.eu.org";
  url = "vaultwarden.defaultmodel.eu.org";
in {
  options.def.vaultwarden = {
    enable = mkEnableOption "Vaultwarden password manager";
    adminTokenFile = mkOption { type = types.path; };
  };

  config = mkIf cfg.enable {
    services.vaultwarden = {
      enable = true;
      dbBackend = "sqlite";
      environmentFile = cfg.adminTokenFile;
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

    services.adguardhome.settings.filtering.rewrites = [{
      domain = url;
      answer =
        (builtins.elemAt (config.networking.interfaces.bond0.ipv4.addresses)
          0).address;
    }];

    ### HOMEPAGE ###
    def.homepage.categories."Other"."Vaultwarden" = {
      icon = "vaultwarden.png";
      description = "Password manager";
      href = "https://${url}";
    };
  };
}
