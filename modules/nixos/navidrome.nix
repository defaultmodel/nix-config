{ config, lib, ... }:
{
  options.def.navidrome = {
    enable = lib.mkOption {
      default = false;
      type = lib.types.bool;
    };

    musicFolder = lib.mkOption {
      type = lib.types.path;
    };
  };

  config = lib.mkIf config.def.navidrome.enable {
    services.navidrome = {
      enable = true;
      settings = {
        Address = "0.0.0.0";
        Port = 4533;
        MusicFolder = config.def.navidrome.musicFolder;
      };
    };

    networking.firewall.allowedTCPPorts = [
      config.services.navidrome.settings.Port
    ];
  };
}
