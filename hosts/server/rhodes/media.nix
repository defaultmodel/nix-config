{ config, ... }:
let mediaDir = "/data";
in {

  age.secrets.wg-conf = { file = ../../../../secrets/wg-conf.age; };

  vpnNamespaces.wg = {
    enable = true;
    wireguardConfigFile = config.age.secrets.wg-conf.path;
    accessibleFrom = [ "192.168.1.0/24" "127.0.0.1" ];
  };

  # Init media group, used by all apps
  users.groups.media = { };

  # Create media folder with appropriates permissions
  systemd.tmpfiles.rules =
    [ "d '${mediaDir}/media'        0775 root media - -" ];

  imports = [
    ### MEDIA ###
    ./services/jellyfin.nix
    ./services/jellyseerr.nix
    # ./services/navidrome.nix
    ### ARR ###
    ./services/radarr.nix
    ./services/sonarr.nix
    # ./services/lidarr.nix
    ./services/prowlarr.nix
    ./services/bazarr.nix
    ./services/recyclarr.nix
    ./services/flaresolverr.nix
    ### DOWNLOADERS ###
    ./services/torrent.nix
    ./services/slskd.nix # The one we shall not name

    # ./services/beets.nix
  ];
}

