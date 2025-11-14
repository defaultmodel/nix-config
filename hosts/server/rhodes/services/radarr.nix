{ config, ... }:
let
  srv = config.services.radarr;
  certloc = "/var/lib/acme/defaultmodel.eu.org";
  url = "radarr.defaultmodel.eu.org";
in {
  age.secrets.radarr-api-key = {
    file = ../../../../secrets/radarr-api-key.age;
    mode = "440";
    owner = srv.user;
    group = srv.group;
  };

  services.radarr = {
    enable = true;
    group = "media";
    openFirewall = true;
    environmentFiles = [ config.age.secrets.radarr-api-key.path ];
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
      (builtins.elemAt (config.networking.interfaces.enp2s0.ipv4.addresses)
        0).address;
  }];

  ### HOMEPAGE ###
  def.homepage.categories."Arr*"."Radarr" = {
    icon = "radarr.png";
    description = "Movie manager";
    href = "https://${url}";
  };
}
