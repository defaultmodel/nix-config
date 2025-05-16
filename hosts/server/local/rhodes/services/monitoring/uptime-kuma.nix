{ config, ... }:
let
  srv = config.services.uptime-kuma;
  certloc = "/var/lib/acme/defaultmodel.eu.org";
  url = "uptime.defaultmodel.eu.org";
in
{
  services.uptime-kuma = {
    enable = true;
    settings = {
      HOST = "0.0.0.0";
      PORT = "3001";
    };
  };

  ### REVERSE PROXY ###
  services.caddy = {
    virtualHosts.${url}.extraConfig = ''
      reverse_proxy http://localhost:${toString srv.settings.PORT}
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
  def.homepage.categories."Monitor"."Uptime-Kuma" = {
    icon = "uptime-kuma.png";
    description = "Uptime monitor";
    href = "https://${url}";
  };
}

