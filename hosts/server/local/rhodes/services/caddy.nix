{ config, ... }:
let srv = config.services.caddy;
in {
  age.secrets.dns-provider-api-key = {
    file = ../../../../../secrets/dns-provider-api-key.age;
    mode = "400";
    owner = srv.user;
  };

  users.users.reverse-proxy = {
    isSystemUser = true;
    group = "reverse-proxy";
  };
  users.groups.reverse-proxy = { };

  services.caddy = {
    enable = true;
    user = "reverse-proxy";
    group = "reverse-proxy";

    globalConfig = ''
      servers {
        metrics
      }
      log {
        output file /var/log/caddy/caddy_main.log {
          roll_size 100MiB
          roll_keep 5
          roll_keep_for 100d
        }
        format json
        level INFO
       }
    '';
  };

  networking.firewall.allowedTCPPorts = [ 80 443 ];
  networking.firewall.allowedUDPPorts = [ 80 443 ];

  security.acme = {
    acceptTerms = true;
    defaults.email = "hilanmeyran@protonmail.com";
    defaults.group = srv.group;

    certs."defaultmodel.eu.org" = {
      extraDomainNames = [ "*.defaultmodel.eu.org" ];
      dnsProvider = "desec";
      dnsResolver = "1.1.1.1:53";
      dnsPropagationCheck = true;
      environmentFile = config.age.secrets.dns-provider-api-key.path;
    };
  };
}
