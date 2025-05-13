{ config, ... }:
let
  srv = config.services.paperless;
  certloc = "/var/lib/acme/defaultmodel.eu.org";
  url = "paperless.defaultmodel.eu.org";

  documentDir = "/data/documents";
  consumeDir = "${config.services.paperless.dataDir}/consume";
in
{
  age.secrets.paperless-admin-password = {
    file = ../../../../secrets/paperless-admin-password.age;
    owner = srv.user;
  };

  systemd.tmpfiles.rules = [
    "d '${documentDir}'   0775 ${srv.user} config.users.users.${
        (config.users.users.${srv.user}).group
      } - -"
    "d '${consumeDir}'    1777 nobody nogroup - -"
  ];

  services.paperless = {
    enable = true;
    address = "0.0.0.0";
    port = 28981;

    mediaDir = documentDir;
    consumptionDir = consumeDir;
    passwordFile = config.age.secrets.paperless-admin-password.path;

    consumptionDirIsPublic = true;

    settings = {
      PAPERLESS_ADMIN_USER = "defaultmodel";
      PAPERLESS_OCR_LANGUAGE = "fra+eng";
      PAPERLESS_CONSUMER_RECURSIVE = true;
      # Enable polling to use with SMB, which does not support iNotify
      PAPERLESS_CONSUMER_POLLING = 10;
    };
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
      (builtins.elemAt (config.networking.interfaces.bond0.ipv4.addresses)
        0).address;
  }];

  ### HOMEPAGE ###
  def.homepage.categories."Media"."Paperless" = {
    icon = "paperless.png";
    description = "Document organizer";
    href = "https://${url}";
  };
}
