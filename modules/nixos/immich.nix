{ config, lib, ... }:
{
  options.def.immich = {
    enable = lib.mkOption {
      default = false;
      type = lib.types.bool;
    };

    photoFolder = lib.mkOption {
      type = lib.types.path;
    };
  };

  config = lib.mkIf config.def.immich.enable {
    services.immich = {
      enable = true;
      host = "0.0.0.0";
      port = 2283;

      environment = {
        IMMICH_TELEMETRY_INCLUDE = "all";
      };
    };

    networking.firewall.allowedTCPPorts = [
      config.services.immich.port
    ];
  };
}
