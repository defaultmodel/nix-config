{ config, lib, ... }:
with lib;
let
  # Shorter name to access a final setting
  cfg = config.def.backup;

  # Helper function to define options
  mkBackupOption = name: type: default: mkOption {
    type = type;
    default = default;
    description = "Backup option: ${name}";
  };

  # Function to define a new BorgBackup job
  defineBorgJob = name: settings: {
    paths = settings.paths;
    exclude = settings.exclude;
    repo = settings.repo;
    encryption = {
      mode = "repokey-blake2";
      passCommand = "cat ${settings.repoPassphraseFile}";
    };
    environment.BORG_RSH = "ssh -i ${settings.repoSSHKeyFile}";
    compression = "auto,lzma";
    startAt = "daily";
  };
in
{
  options.def.backup = {
    enable = mkEnableOption "Enable automated backups";
    jobs = mkBackupOption "List of backup jobs" (types.listOf types.attrs) [ ];
  };

  config = mkIf cfg.enable {
    services.borgbackup.jobs = mapAttrs (name: settings: defineBorgJob name settings) cfg.jobs;
  };
}
