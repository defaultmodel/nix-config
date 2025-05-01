{ config, lib, ... }:
with lib;
let
  # Shorter name to access a final setting
  # All modules are under the custom attribute "def"
  cfg = config.def.sonarr;
in {
  options.def.sonarr = {
    enable = mkEnableOption "Sonarr movie manager";
    authFile = mkOption { type = types.path; };
  };

  config = mkIf cfg.enable {
    services.sonarr = {
      enable = true;
      group = "media";
      openFirewall = true;
      # Set the api key through here
      environmentFiles = [ cfg.authFile ];
    };
  };
}
