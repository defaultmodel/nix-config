{ config, ... }:
let
  srv = config.services.prowlarr;
  certloc = "/var/lib/acme/defaultmodel.eu.org";
  url = "prowlarr.defaultmodel.eu.org";
in {
  services.prowlarr = {
    enable = true;
    openFirewall = true;
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
  def.homepage.categories."Arr*"."Prowlarr" = {
    icon = "prowlarr.png";
    description = "Indexer manager";
    href = "https://${url}";
  };
}
