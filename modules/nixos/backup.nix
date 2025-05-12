{ config, lib, ... }:
with lib;
let
  cfg = config.def.backup;
  # Helper to turn each job into the right shape for services.borgbackup.jobs
  defineBorgJob = name: settings: {
    inherit (settings) paths exclude repo;
    encryption = {
      mode = "repokey-blake2";
      passCommand = "cat ${settings.repoPassphraseFile}";
    };
    environment = { BORG_RSH = "ssh -p 23 -i ${settings.repoSSHKeyFile}"; };
    compression = "auto,lzma";
    startAt = "daily";
    extraCreateArgs = "--verbose --stats";
    prune.keep = {
      within = "1d"; # Keep all archives from the last day
      daily = 7;
      weekly = 4;
      monthly = 1;
      yearly = 3;
    };
  };
in {
  options = {
    def.backup = {
      enable = mkEnableOption "Enable automated backups";
      pgBackup = mkEnableOption "Enable backup of postgresql instance";
      pgBackupDir = mkOption {
        type = types.path;
        default = "/var/lib/backup/pg"; # pick a sane default or omit
      };
      jobs = mkOption {
        type = types.attrsOf (types.submodule {
          options = {
            paths = mkOption {
              type = types.listOf types.path;
              default = [ ];
            };
            exclude = mkOption {
              type = types.listOf types.path;
              default = [ ];
            };
            repo = mkOption {
              type = types.str;
              default = "";
            };
            repoPassphraseFile = mkOption {
              type = types.path;
              default = "";
            };
            repoSSHKeyFile = mkOption {
              type = types.path;
              default = "";
            };
          };
        });
        default = { };
      };
    };
  };

  config = mkIf cfg.enable {
    # Enable borgbackup and inject each job
    services.borgbackup = {
      jobs =
        mapAttrs' (name: value: nameValuePair name (defineBorgJob name value))
        cfg.jobs;
    };

    services.postgresqlBackup = mkIf cfg.pgBackup {
      enable = true;
      location = cfg.pgBackupDir;
      backupAll = true;
      startAt = "daily";
      compression = "zstd";
      compressionLevel = 3;
    };

  };
}

