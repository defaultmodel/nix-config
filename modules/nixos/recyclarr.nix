{ config, lib, ... }:
with lib;
let
  # Shorter name to access a final setting
  # All modules are under the custom attribute "def"
  cfg = config.def.recyclarr;
in {
  options.def.recyclarr = {
    enable = mkEnableOption "Recyclarr arr suite synchronization";
  };

  config = mkIf cfg.enable {
    services.jellyseerr = {
      enable = true;
      openFirewall = true;
    };
  };
}

