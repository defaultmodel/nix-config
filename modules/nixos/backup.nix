{ config, lib, ... }:
with lib;
let
  # Shorter name to access a final setting
  cfg = config.def.backup;
  srv = config.services.borgbackup;

  # Function to define a new BorgBackup job
  defineBorgJob = name: settings: {
    paths = settings.paths;
    exclude = settings.exclude;
    repo = settings.repo;
    encryption = {
      mode = "repokey-blake2";
      passCommand = "cat ${settings.repoPassphraseFile}";
    };
    environment.BORG_RSH = "ssh -p 23 -i ${settings.repoSSHKeyFile}";
    compression = "auto,lzma";
    startAt = "daily";
  };
in {
  options.def.backup = {
    enable = mkEnableOption "Enable automated backups";
    pgBackup = mkEnableOption "Enable backup of postgresql instance";
    pgBackupDir = mkOption { type = types.path; };
    jobs = mkOption {
      type = types.attrsOf (types.submodule {
        options = {
          paths = mkOption { type = types.listOf types.path; };
          exclude = mkOption {
            type = types.listOf types.path;
            default = [ ];
          };
          repo = mkOption { type = types.str; };
          repoPassphraseFile = mkOption { type = types.path; };
          repoSSHKeyFile = mkOption { type = types.path; };
        };
      });
      default = { };
    };
  };

  config = mkIf cfg.enable {
    services.borgbackup.jobs =
      mapAttrs' (name: value: nameValuePair name (defineBorgJob name value))
      cfg.jobs;

    services.postgresqlBackup = mkIf cfg.pgBackup {
      enable = true;
      location = cfg.pgBackupDir;
      backupAll = true;
      startAt = "daily";
      compression = "zstd";
      compressionLevel = 3;
    };

    systemd.tmpfiles.rules = [ "d ${cfg.pgBackupDir} 0775 root media" ];

  };
}
