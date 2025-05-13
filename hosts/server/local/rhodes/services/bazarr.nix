{ config, ... }:
let
  srv = config.services.bazarr;
  certloc = "/var/lib/acme/defaultmodel.eu.org";
  url = "bazarr.defaultmodel.eu.org";
in
{
  age.secrets.bazarr-api-key = {
    file = ../../../../secrets/bazarr-api-key.age;
    owner = srv.user;
  };

  services.bazarr = {
    enable = true;
    group = "media";
    openFirewall = true;
  };

  systemd.services.bazarr.serviceConfig.EnvironmentFile = config.age.secrets.bazarr-api-key.path;

  ### REVERSE PROXY ###
  services.caddy = {
    virtualHosts.${url}.extraConfig = ''
      reverse_proxy http://localhost:${toString srv.listenPort}
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
  def.homepage.categories."Arr*"."Bazarr" = {
    icon = "bazarr.png";
    description = "Subtitle manager";
    href = "https://${url}";
  };
}
