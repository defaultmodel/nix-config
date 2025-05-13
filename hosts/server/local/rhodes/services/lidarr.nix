{ config, ... }:
let
  srv = config.services.lidarr;
  certloc = "/var/lib/acme/defaultmodel.eu.org";
  url = "lidarr.defaultmodel.eu.org";
in
{
  age.secrets.lidarr-api-key = {
    file = ../../../../secrets/lidarr-api-key.age;
    owner = srv.user;
  };

  services.lidarr = {
    enable = true;
    group = "media";
    openFirewall = true;
    environmentFiles = [ config.age.secrets.lidarr-api-key.path ];
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
  def.homepage.categories."Arr*"."Lidarr" = {
    icon = "lidarr.png";
    description = "Music manager";
    href = "https://${url}";
  };
}
