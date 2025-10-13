{ config, ... }:
let
  srv = config.services.sonarr;
  certloc = "/var/lib/acme/defaultmodel.eu.org";
  url = "sonarr.defaultmodel.eu.org";
in {
  age.secrets.sonarr-api-key = {
    file = ../../../../../secrets/sonarr-api-key.age;
    mode = "440";
    owner = srv.user;
    group = srv.group;
  };

  services.sonarr = {
    enable = true;
    group = "media";
    openFirewall = true;
    environmentFiles = [ config.age.secrets.sonarr-api-key.path ];
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
  def.homepage.categories."Arr*"."Sonarr" = {
    icon = "sonarr.png";
    description = "Show manager";
    href = "https://${url}";
  };
}
