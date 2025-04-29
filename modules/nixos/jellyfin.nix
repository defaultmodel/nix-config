{ config, lib, ... }:
with lib;
let
  # Shorter name to access a final setting
  # All modules are under the custom attribute "def"
  cfg = config.def.jellyfin;
in {
  options.def.jellyfin = {
    enable = mkEnableOption "Jellyfin media system";
    mediaDir = mkOption { type = types.path; };
  };

  config = mkIf cfg.enable {
    # Always prioritise Jellyfin IO
    systemd.services.jellyfin.serviceConfig.IOSchedulingPriority = 0;

    systemd.tmpfiles.rules = [
      "d '${cfg.mediaDir}/media/shows'        0775 ${config.services.jellyfin.user} ${config.services.jellyfin.group} - -"
      "d '${cfg.mediaDir}/media/movies'       0775 ${config.services.jellyfin.user} ${config.services.jellyfin.group} - -"
      "d '${cfg.mediaDir}/media/music'        0775 ${config.services.jellyfin.user} ${config.services.jellyfin.group} - -"
    ];

    services.jellyfin = {
      enable = true;
      group = "media";
      openFirewall = true;
    };
  };
}

