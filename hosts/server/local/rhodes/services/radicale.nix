{ config, ... }:
let
  srv = config.services.radarr;
  certloc = "/var/lib/acme/defaultmodel.eu.org";
  url = "radicale.defaultmodel.eu.org";
in
{

  age.secrets.radicale-credentials = {
    file = ../../../../../secrets/radicale-credentials.age;
    owner = "radicale";
  };

  services.radicale = {
    enable = true;
    settings = {
      server = {
        hosts = [ "0.0.0.0:5232" "[::]:5232" ];
      };
      auth = {
        type = "htpasswd";
        htpasswd_filename = config.age.secrets.radicale-credentials.path;
        htpasswd_encryption = "bcrypt";
      };
      storage = {
        filesystem_folder = "/var/lib/radicale/collections";
      };
    };
    rights = {
      defaultmodel = {
        user = ".+";
        collection = "{user}";
        permissions = "RW";
      };
    };
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
  def.homepage.categories."Others"."Radicale" = {
    icon = "radicale.png";
    description = "CarDAV/CalDAV manager";
    href = "https://${url}";
  };
}
