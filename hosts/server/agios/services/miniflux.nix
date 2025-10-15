{ config, ... }:
let
  srv = config.services.miniflux;
  certloc = "/var/lib/acme/defaultmodel.eu.org";
  url = "rss.defaultmodel.eu.org";
in {
  age.secrets.rss-credentials = {
    file = ../../../../secrets/rss-credentials.age;
    owner = "miniflux";
  };

  services.miniflux = {
    enable = true;
    createDatabaseLocally = true;
    adminCredentialsFile = config.age.secrets.rss-credentials.path;
    config = {
      CREATE_ADMIN = 1;
      LISTEN_ADDR = "0.0.0.0:7381";
      PORT = 7381;
    };
  };

  ### REVERSE PROXY ###
  services.caddy = {
    virtualHosts.${url}.extraConfig = ''
      reverse_proxy http://localhost:${toString srv.config.PORT}
      tls ${certloc}/cert.pem ${certloc}/key.pem {
        protocols tls1.3
      }
    '';
  };
}
