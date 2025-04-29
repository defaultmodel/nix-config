{ config, lib, ... }:
with lib;
let
  # Shorter name to access a final setting
  # All modules are under the custom attribute "def"
  cfg = config.def.navidrome;
in {
  options.def.navidrome = {
    enable = mkOption {
      default = false;
      type = types.bool;
    };
    musicFolder = mkOption { type = types.path; };
  };

  config = mkIf cfg.enable {
    services.navidrome = {
      enable = true;
      settings = {
        Address = "0.0.0.0";
        Port = 4533;
        MusicFolder = cfg.musicFolder;
      };
    };

    networking.firewall.allowedTCPPorts =
      [ config.services.navidrome.settings.Port ];
  };
}
