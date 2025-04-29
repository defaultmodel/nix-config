{ config, lib, ... }:
with lib;
let
  # Shorter name to access a final setting
  # All modules are under the custom attribute "def"
  cfg = config.def.bazarr;
in {
  options.def.bazarr.enable = mkEnableOption "Bazarr subtitle manager";

  config = mkIf cfg.enable {
    services.bazarr = {
      enable = true;
      group = "media";
      openFirewall = true;
    };
  };
}
