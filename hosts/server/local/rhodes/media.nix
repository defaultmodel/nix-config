{ config, ... }:
let mediaDir = "/data";
in {

  age.secrets.wg-conf = { file = ../../../../secrets/wg-conf.age; };

  vpnNamespaces.wg = {
    enable = true;
    wireguardConfigFile = config.age.secrets.wg-conf.path;
    accessibleFrom = [ "192.168.1.0/24" "10.0.0.0/8" "127.0.0.1" ];
  };

  # Init media group, used by all apps
  users.groups.media = { };

  # Create media folder with appropriates permissions
  systemd.tmpfiles.rules =
    [ "d '${mediaDir}/media'        0775 root media - -" ];

  ### MEDIA ###

  def.jellyfin = {
    enable = true;
    mediaDir = "${mediaDir}/media";
  };
  def.jellyseerr.enable = true;
  def.navidrome = {
    enable = true;
    musicFolder = "${mediaDir}/media/music";
  };

  ### ARR ###

  age.secrets.bazarr-api-key = {
    file = ../../../../secrets/bazarr-api-key.age;
    owner = "bazarr";
  };
  def.bazarr = {
    enable = true;
    apiKeyFile = config.age.secrets.bazarr-api-key.path;
  };

  age.secrets.prowlarr-api-key = {
    file = ../../../../secrets/prowlarr-api-key.age;
    owner = "prowlarr";
  };
  def.prowlarr = {
    enable = true;
    apiKeyFile = config.age.secrets.prowlarr-api-key.path;
  };

  age.secrets.radarr-api-key = {
    file = ../../../../secrets/radarr-api-key.age;
    owner = "radarr";
  };
  def.radarr = {
    enable = true;
    apiKeyFile = config.age.secrets.radarr-api-key.path;
  };

  age.secrets.sonarr-api-key = {
    file = ../../../../secrets/sonarr-api-key.age;
    owner = "sonarr";
  };
  def.sonarr = {
    enable = true;
    apiKeyFile = config.age.secrets.sonarr-api-key.path;
  };

  age.secrets.lidarr-api-key = {
    file = ../../../../secrets/lidarr-api-key.age;
    owner = "lidarr";
  };
  def.lidarr = {
    enable = true;
    apiKeyFile = config.age.secrets.lidarr-api-key.path;
  };

  def.recyclarr = {
    enable = true;
    radarrApiKeyFile = config.age.secrets.radarr-api-key.path;
    sonarrApiKeyFile = config.age.secrets.sonarr-api-key.path;
  };

  ### DOWNLOADERS ###

  age.secrets.torrent-credentials = {
    file = ../../../../secrets/torrent-credentials.age;
    mode = "400";
    owner = "torrent";
  };

  def.torrent = {
    enable = true;
    mediaDir = mediaDir;
    authFile = config.age.secrets.torrent-credentials.path;
    vpn.enable = true;
  };

  # def.usenet = {
  #   enable = true;
  #   mediaDir = mediaDir;
  #   vpn.enable = true;
  # };

  age.secrets.slskd-credentials = {
    file = ../../../../secrets/slskd-credentials.age;
    mode = "400";
    owner = "slskd";
  };

  def.slskd = {
    enable = true;
    mediaDir = mediaDir;
    authFile = config.age.secrets.slskd-credentials.path;
  };

  ### OTHERS ###
  def.beets = {
    enable = false;
    user = "root";
    group = "root";
    importPaths =
      [ "${mediaDir}/soulseek/complete" "${mediaDir}/torrent/music" ];
    mediaDir = "${mediaDir}/media/music";
  };
}

