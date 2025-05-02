{ config, ... }:
let mediaDir = "/mnt/shares/data";
in {

  age.secrets.wg-conf = { file = ../../../../secrets/wg-conf.age; };

  vpnNamespaces.wg = {
    enable = true;
    wireguardConfigFile = config.age.secrets.wg-conf.path;
    accessibleFrom = [ "192.168.1.0/24" "10.0.0.0/8" "127.0.0.1" ];
  };

  # Init media group, used by all apps
  users.groups.media = { };

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

  def.bazarr.enable = true;
  def.prowlarr.enable = true;

  age.secrets.radarr-api-key = {
    file = ../../../../secrets/wg-conf.age;
    mode = "400";
    owner = "radarr";
  };
  def.radarr = {
    enable = true;
    authFile = config.age.secrets.radarr-api-key.path;
  };

  age.secrets.sonarr-api-key = {
    file = ../../../../secrets/wg-conf.age;
    mode = "400";
    owner = "sonarr";
  };
  def.sonarr = {
    enable = true;
    authFile = config.age.secrets.sonarr-api-key.path;
  };

  def.lidarr.enable = false;

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
    mode = "440";
    owner = "slskd";
    group = "slskd";
  };

  def.slskd = {
    enable = true;
    mediaDir = mediaDir;
    authFile = config.age.secrets.slskd-credentials.path;
  };
}

