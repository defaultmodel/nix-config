{ config, lib, ... }:
with lib;
let
  # Shorter name to access a final setting
  # All modules are under the custom attribute "def"
  cfg = config.def.lidarr;
  srv = config.services.lidarr;
in {
  options.def.lidarr.enable = mkEnableOption "Lidarr music manager";

  config = mkIf cfg.enable {
    services.lidarr = {
      enable = true;
      group = "media";
      openFirewall = true;
    };

    services.caddy = {
      virtualHosts."lidarr.defaultmodel.eu.org".extraConfig = ''
        reverse_proxy http://localhost:${toString srv.settings.server.port}
      '';
    };
  };
}
