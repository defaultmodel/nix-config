{ config, ... }:
let mediaDir = "/mnt/shares/data";
in {

  age.secrets.wg-conf = { file = ../../../../secrets/wg-conf.age; };

  ### MEDIA ###
  def.jellyfin = {
    enable = true;
    mediaDir = mediaDir;
  };
  def.jellyseerr.enable = true;
  def.navidrome = {
    enable = true;
    musicFolder = "${mediaDir}/media/music";
  };

  ### ARR ###

  def.bazarr.enable = true;
  def.prowlarr.enable = true;
  def.radarr.enable = true;
  def.sonarr.enable = true;
  def.lidarr.enable = true;

  ### DOWNLOADERS ###

  age.secrets.torrent-credentials = {
    file = ../../../../secrets/torrent-credentials.age;
    mode = "400";
    owner = "deluge";
    group = "deluge";
  };

  def.torrent = {
    enable = true;
    mediaDir = mediaDir;
    authFile = config.age.secrets.torrent-credentials.path;
    vpn = {
      enable = true;
      wgConfFile = config.age.secrets.wg-conf.path;
    };
  };

  def.usenet = {
    enable = true;
    mediaDir = mediaDir;
    vpn = {
      enable = true;
      wgConfFile = config.age.secrets.wg-conf.path;
    };
  };

}

