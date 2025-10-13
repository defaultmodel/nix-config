{ pkgs, lib, ... }:
with lib;
let
  user = "root";
  group = "media";

  mediaDir = "/data/media/music";
  configDir = "/var/lib/beets";

  beetsConfig = {
    directory = mediaDir;
    library = "${configDir}/library.blb";

    import = {
      write = true;
      copy = "no";
      move = "yes";
      resume = false;
      # quiet =
      # "no"; # Set by systemd, so that we can see logs if executed by hand
      quiet_fallback = "skip";
      log = "/var/log/beets.log";
    };

    paths = {
      default = "%asciify{$albumartist $album}[$year]/$track-$title}";
      singleton = "%asciify{Non-Album/$artist-$title[$year]}";
      comp = "%asciify{Compilations/$album/$track-$title}";
    };

    plugins = [
      "fetchart"
      "embedart"
      "fromfilename"
      "badfiles"
      "duplicates"
      "scrub"
      "web"
      "lyrics"
      "lastgenre"
    ];
    art_filename = "folder";

    fetchart = {
      auto = true;
      minwidth = 0;
      maxwidth = 0;
      enforce_ratio = false;
      cautious = false;
      cover_names = [ "cover" "front" "art" ];
      sources = [ "filesystem" "coverart" "itunes" "amazon" "albumart" ];
    };

    embedart = {
      auto = true;
      remove_art_file = "no";
    };

    lyrics = {
      auto = "yes";
      sources = [ "lrclib" "genius" ];
      synced = "yes";
    };

    lastgenre = {
      auto = "yes";
      count = 2;
    };
  };

in {
  environment.systemPackages = with pkgs; [ beets ffmpeg ];

  # User creation
  users.users.${user} = {
    isSystemUser = true;
    # group = group;
  };
  users.groups.${group} = { };

  # Folder creation
  systemd.tmpfiles.rules = [
    "d '${configDir}'  0770 ${user} ${group} - -"
    "f '${configDir}/library.db'  0660 ${user} ${group} - -"
  ];

  systemd.services.beets-import-slskd = let
    configFile = (pkgs.formats.yaml { }).generate "config.yaml" beetsConfig;
    path = "/data/soulseek/complete/";
  in {
    script =
      "set -eu && ${getExe pkgs.beets} -c ${configFile} import ${path} --quiet";
    serviceConfig = {
      Type = "oneshot";
      User = user;
      Group = group;
    };
  };

  systemd.timers.beets-import-slskd = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "15m";
      OnUnitActiveSec = "15m";
      Unit = "beets-import-slskd.service";
    };
  };
}
