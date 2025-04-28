{ config, lib, ... }:
{
  options.def.vaultwarden = {
    enable = lib.mkOption {
      default = false;
      type = lib.types.bool;
    };
  };

  config = lib.mkIf config.def.vaultwarden.enable {
    services.vaultwarden = {
      enable = true;
      dbBackend = "sqlite";
      config = {
        SIGNUPS_ALLOWED = false;
        ROCKET_ADDRESS = "0.0.0.0";
        ROCKET_PORT = 8222;
      };
    };

    networking.firewall.allowedTCPPorts = [
      config.services.vaultwarden.config.ROCKET_PORT
    ];
  };
}
