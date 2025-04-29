{ config, lib, ... }:
with lib;
let
  # Shorter name to access a final setting
  # All modules are under the custom attribute "def"
  cfg = config.def.jellyseerr;
in {
  options.def.jellyseerr = {
    enable = mkEnableOption "Jellyseerr media requester";
  };

  config = mkIf cfg.enable {
    services.jellyseerr = {
      enable = true;
      openFirewall = true;
    };
  };
}
