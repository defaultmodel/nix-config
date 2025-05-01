{ config, lib, ... }:
with lib;
let
  # Shorter name to access a final setting
  # All modules are under the custom attribute "def"
  cfg = config.def.paperless;
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
    services.paperless = {
      enable = true;
      address = "0.0.0.0";
      port = 28981;

      mediaDir = cfg.documentFolder;
      consumptionDir = cfg.consumeFolder;
      passwordFile = cfg.passwordFile;

      settings = {
        PAPERLESS_ADMIN_USER = "defaultmodel";
        PAPERLESS_OCR_LANGUAGE = "fra+eng";
        PAPERLESS_CONSUMER_RECURSIVE = true;
        # Enable polling to use with SMB, which does not support iNotify
        PAPERLESS_CONSUMER_POLLING = 10;
      };
    };

    networking.firewall.allowedTCPPorts = [ config.services.paperless.port ];
  };
}
