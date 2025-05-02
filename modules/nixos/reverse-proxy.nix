{ config, lib, ... }:
with lib;
let
  # Shorter name to access a final setting
  # All modules are under the custom attribute "def"
  cfg = config.def.reverse-proxy;
  srv = config.services.caddy;
in {
  options.def.reverse-proxy = {
    enable = mkEnableOption "reverse proxy";
    cloudflareKeyFile = mkOption { type = types.path; };
  };

  config = mkIf cfg.enable {
    users.users.reverse-proxy = {
      isSystemUser = true;
      group = "network";
    };
    users.groups.network = { };

    services.caddy = {
      enable = true;
      user = "reverse-proxy";
      group = "network";
    };
    networking.firewall.allowedTCPPorts = [ 80 443 ];

    security.acme = {
      acceptTerms = true;
      defaults.email = "hilanmeyran@protonmail.com";
      defaults.group = srv.group;

      certs."defaultmodel.eu.org" = {
        extraDomainNames = [ "*.defaultmodel.eu.org" ];
        dnsProvider = "cloudflare";
        dnsResolver = "1.1.1.1:53";
        dnsPropagationCheck = true;
        environmentFile = cfg.cloudflareKeyFile;
      };
    };
  };
}
