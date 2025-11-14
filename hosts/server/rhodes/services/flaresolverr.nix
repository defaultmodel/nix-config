{ config, ... }:
let
  srv = config.services.flaresolverr;
  certloc = "/var/lib/acme/defaultmodel.eu.org";
  url = "flaresolverr.defaultmodel.eu.org";
in {
  services.flaresolverr = {
    enable = true;
    openFirewall = true;
    port = 8191;
  };

  ### REVERSE PROXY ###
  services.caddy = {
    virtualHosts.${url}.extraConfig = ''
      reverse_proxy http://localhost:${toString srv.port}
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
}
