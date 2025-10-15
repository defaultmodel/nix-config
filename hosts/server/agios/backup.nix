{ config, ... }: {
  age.secrets.hetzner-backup-agios-passphrase = {
    file = ../../../secrets/hetzner-backup-agios-passphrase.age;
  };

  services.borgbackup = {
    jobs."hetzner" = {
      paths = [ "/var/lib" "/etc/ssh" ];
      exclude = [ "/var/lib/docker" "/var/lib/systemd" ];
      repo = "ssh://u414837-sub1@u414837.your-storagebox.de/home/agios";
      encryption = {
        mode = "repokey-blake2";
        passCommand =
          "cat ${config.age.secrets.hetzner-backup-agios-passphrase.path}";
      };
      environment = {
        BORG_RSH = "ssh -p 23 -i /etc/ssh/ssh_host_ed25519_key";
      };
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
  };
}

