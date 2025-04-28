{ config, lib, ... }:
{
  # options.def.borgbackup = {
  #   enable = lib.mkOption {
  #     default = false;
  #     type = lib.types.bool;
  #   };
  #   jobs = lib.mkOption {
  #     paths = lib.mkOption {
  #       type = lib.pathList;
  #       description = "Paths to backup";
  #     };
  #     exclude = lib.mkOption {
  #       type = lib.strList;
  #       default = [ ];
  #       description = "Paths to exclude from backup";
  #     };
  #     encryption = lib.mkOption {
  #       mode = lib.mkOption {
  #         type = lib.str;
  #         default = "repokey-blake2";
  #         description = "Encryption mode";
  #       };
  #       passCommand = lib.mkOption {
  #         type = lib.str;
  #         description = "Command to retrieve the encryption passphrase";
  #       };
  #     };
  #     repo = lib.mkOption {
  #       type = lib.str;
  #       description = "Borg repository URL";
  #     };
  #     compression = lib.mkOption {
  #       type = lib.str;
  #       default = "auto,zstd";
  #       description = "Compression mode";
  #     };
  #     startAt = lib.mkOption {
  #       type = lib.str;
  #       default = "daily";
  #       description = "Backup schedule";
  #     };

  #     prune = lib.mkOption {
  #       keepDaily = lib.mkOption {
  #         type = lib.int;
  #         default = 7;
  #         description = "Number of daily backups to keep";
  #       };
  #       keepWeekly = lib.mkOption {
  #         type = lib.int;
  #         default = 4;
  #         description = "Number of weekly backups to keep";
  #       };
  #       keepMonthly = lib.mkOption {
  #         type = lib.int;
  #         default = 3;
  #         description = "Number of monthly backups to keep";
  #       };
  #     };
  #     description = "BorgBackup jobs configuration";
  #   };
  # };

  # # Enable BorgBackup service
  # services.borgbackup = {
  #   enable = config.def.borgbackup.enable;
  #   jobs = lib.mkIf (config.def.borgbackup.enable) {
  #     inherit (config.def.borgbackup.jobs) paths exclude encryption repo compression startAt;

  #     prune = {
  #       keepDaily = config.def.borgbackup.jobs.prune.keepDaily;
  #       keepWeekly = config.def.borgbackup.jobs.prune.keepWeekly;
  #       keepMonthly = config.def.borgbackup.jobs.prune.keepMonthly;
  #     };
  #   };
  # };
}

