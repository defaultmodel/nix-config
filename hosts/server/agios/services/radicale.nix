{ config, ... }:
let
  srv = config.services.radicale;
  certloc = "/var/lib/acme/defaultmodel.eu.org";
  url = "radicale.defaultmodel.eu.org";
in {

  # https://iotools.cloud/tool/htpasswd-generator/
  age.secrets.radicale-credentials = {
    file = ../../../../secrets/radicale-credentials.age;
    owner = "radicale";
  };

  services.radicale = {
    enable = true;
    settings = {
      server = { hosts = [ "0.0.0.0:5232" "[::]:5232" ]; };
      auth = {
        type = "htpasswd";
        htpasswd_filename = config.age.secrets.radicale-credentials.path;
        htpasswd_encryption = "autodetect";
      };
      storage = { filesystem_folder = "/var/lib/radicale/collections"; };
    };
  };

  ### REVERSE PROXY ###
  services.caddy = {
    virtualHosts.${url}.extraConfig = ''
      reverse_proxy http://localhost:5232
      tls ${certloc}/cert.pem ${certloc}/key.pem {
        protocols tls1.3
      }
    '';
  };
}
