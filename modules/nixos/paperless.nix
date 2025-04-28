{ config, lib, ... }:
{
  options.def.paperless = {
    enable = lib.mkOption {
      default = false;
      type = lib.types.bool;
    };

    passwordFile = lib.mkOption {
      type = lib.types.path;
    };

    documentFolder = lib.mkOption {
      type = lib.types.path;
    };

    consumeFolder = lib.mkOption {
      type = lib.types.path;
    };
  };

  config = lib.mkIf config.def.paperless.enable {
    services.paperless = {
      enable = true;
      address = "0.0.0.0";
      port = 28981;

      mediaDir = config.def.paperless.documentFolder;
      consumptionDir = config.def.paperless.consumeFolder;

      passwordFile = config.def.paperless.passwordFile;

      settings = {
        PAPERLESS_OCR_LANGUAGE = "fra+eng";
        PAPERLESS_CONSUMER_RECURSIVE = true;
        # Enable polling to use with SMB, which does not support iNotify
        PAPERLESS_CONSUMER_POLLING = 10;
      };
    };

    networking.firewall.allowedTCPPorts = [
      config.services.paperless.port
    ];
  };
}
