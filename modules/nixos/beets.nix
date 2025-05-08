{ pkgs, config, lib, ... }:
with lib;
let
  # Shorter name to access a final setting
  # All modules are under the custom attribute "def"
  cfg = config.def.beets;

  beetsConfig = {
    directory = cfg.mediaDir;
    library = "${cfg.configDir}/library.blb";

    import = {
      write = "yes";
      copy = "no";
      move = "yes";
      resume = "ask";
      quiet = "yes";
      quiet_fallback = "skip";
      log = "/var/log/beets.log";
    };

    paths = {
      default = "$albumartist $album[$year]/$track-$title";
      singleton = "Non-Album/$artist-$title[$year]";
      comp = "Compilations/$album/$track-$title";
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
      sources = [ "lrclib" "genius" "tekstowo" ];
      synced = "yes";
    };

    lastgenre = {
      auto = "yes";
      count = 2;
    };
  };

in {
  options.def.beets = {
    enable = mkEnableOption "Beets geek's music organizer";
    user = mkOption {
      type = types.str;
      default = "beets";
    };
    group = mkOption {
      type = types.str;
      default = "beets";
    };
    importPaths = mkOption {
      type = types.listOf types.str;
      default = [ ];
      description = "Paths to watch for new music imports";
    };
    configDir = mkOption {
      type = types.path;
      default = "/var/lib/beets";
    };
    mediaDir = mkOption { type = types.path; };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [ beets ffmpeg ];

    # User creation
    users.users.${cfg.user} = {
      isSystemUser = true;
      group = cfg.group;
    };
    users.groups.${cfg.group} = { };

    # Folder creation
    systemd.tmpfiles.rules = [
      "d '${cfg.configDir}'  0770 ${cfg.user} ${cfg.group} - -"
      "f '${cfg.configDir}/config.yaml'  0660 ${cfg.user} ${cfg.group} - -"
    ];

    systemd.services = listToAttrs (map (path:
      let
        configFile = (pkgs.formats.yaml { }).generate "config.yml" beetsConfig;
        serviceName = "beets-import-${
            replaceStrings [ "/" ] [ "" ] (builtins.baseNameOf path)
          }";
      in nameValuePair serviceName {
        script = "set -eu && ${
            getExe pkgs.beets
          } -l ${cfg.configDir}/library.blb import -c ${configFile} ${path} --quiet";
        serviceConfig = {
          Type = "oneshot";
          User = "root";
        };
      }) cfg.importPaths);

    systemd.timers = listToAttrs (map (path:
      let
        serviceName = "beets-import-${
            replaceChars [ "/" ] [ "" ] (builtins.baseNameOf path)
          }";
        timerName = "${serviceName}.timer";
      in nameValuePair timerName {
        wantedBy = [ "timers.target" ];
        timerConfig = {
          OnBootSec = "15m";
          OnUnitActiveSec = "15m";
          Unit = "${serviceName}.service";
        };
      }) cfg.importPaths);
  };
}
