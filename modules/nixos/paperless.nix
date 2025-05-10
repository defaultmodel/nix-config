{ config, lib, ... }:
with lib;
let
  # Shorter name to access a final setting
  # All modules are under the custom attribute "def"
  cfg = config.def.paperless;
  srv = config.services.paperless;
  certloc = "/var/lib/acme/defaultmodel.eu.org";
  url = "paperless.defaultmodel.eu.org";
in {
  options.def.paperless = {
    enable = mkOption {
      default = false;
      type = types.bool;
    };

    # WARNING: changing after the initial setup, the old superuser will continue to exist.
    adminUser = mkOption {
      type = types.string;
      default = "admin";
    };
    passwordFile = mkOption { type = types.path; };
    documentFolder = mkOption { type = types.path; };
    consumeFolder = mkOption { type = types.path; };
  };

  config = mkIf cfg.enable {
    systemd.tmpfiles.rules = [
      "d '${cfg.documentFolder}'        0775 ${srv.user} config.users.users.${
        (config.users.users.${srv.user}).group
      } - -"
      "d '${cfg.consumeFolder}'        0777 ${srv.user} config.users.users.${
        (config.users.users.${srv.user}).group
      } - -"
    ];

    services.paperless = {
      enable = true;
      address = "0.0.0.0";
      port = 28981;

      mediaDir = cfg.documentFolder;
      consumptionDir = cfg.consumeFolder;
      passwordFile = cfg.passwordFile;

      consumptionDirIsPublic = true;
      database.createLocally = true;

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
  };
}
