{ config, lib, ... }:
with lib;
let
  # Shorter name to access a final setting
  # All modules are under the custom attribute "def"
  cfg = config.def.prowlarr;
in {
  options.def.prowlarr.enable = mkEnableOption "Prowlarr indexer manager";

  config = mkIf cfg.enable {
    services.prowlarr = {
      enable = true;
      openFirewall = true;
    };
  };
}
