{ ... }:
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
}
