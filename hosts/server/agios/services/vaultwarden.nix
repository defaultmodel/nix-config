{ config, ... }:
let
  srv = config.services.vaultwarden;
  certloc = "/var/lib/acme/defaultmodel.eu.org";
  url = "vaultwarden.defaultmodel.eu.org";
in {
  age.secrets.vaultwarden-admin-token = {
    file = ../../../../secrets/vaultwarden-admin-token.age;
    owner = "vaultwarden";
  };
  services.vaultwarden = {
    enable = true;
    dbBackend = "sqlite";
    environmentFile = config.age.secrets.vaultwarden-admin-token.path;
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
}
