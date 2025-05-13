{ config, ... }:
let
  pgBackupDir = "/data/backups";
in
{
  systemd.tmpfiles.rules = [ "d ${pgBackupDir} 1777 nobody nogroup - -" ];

  age.secrets.hetzner-backup-passphrase = {
    file = ../../../../secrets/hetzner-backup-passphrase.age;
  };

  services.borgbackup = {
    jobs."hetzner" =
      {
        paths = [
          "/var/lib"
          "/etc/ssh"
          "/data/photos"
          "/data/documents"
          "/data/backups"
          "/data/media/music"
        ];
        exclude = [ "/var/lib/docker" "/var/lib/systemd" ];
        repo = "ssh://u414837-sub1@u414837.your-storagebox.de/home/borg-repo";
        encryption = {
          mode = "repokey-blake2";
          passCommand = "cat ${config.age.secrets.hetzner-backup-passphrase.path}";
        };
        environment = { BORG_RSH = "ssh -p 23 -i /etc/ssh/ssh_host_ed25519_key"; };
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

    services.postgresqlBackup = {
      enable = true;
      location = pgBackupDir;
      backupAll = true;
      startAt = "daily";
      compression = "zstd";
      compressionLevel = 3;
    };
  };
}

