{ config, ... }:
let
  srv = config.services.miniflux;
  certloc = "/var/lib/acme/defaultmodel.eu.org";
  url = "rss.defaultmodel.eu.org";
in
{
  age.secrets.rss-credentials = {
    file = ../../../../secrets/rss-credentials.age;
    mode = "400";
    owner = srv.user;
  };

  services.miniflux = {
    enable = true;
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

  services.adguardhome.settings.filtering.rewrites = [{
    domain = url;
    answer =
      (builtins.elemAt (config.networking.interfaces.bond0.ipv4.addresses)
        0).address;
  }];

  ### HOMEPAGE ###
  def.homepage.categories."Other"."Miniflux " = {
    icon = "rsshub.png";
    description = "RSS feed handler";
    href = "https://${url}";
  };
}
