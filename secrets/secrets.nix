let
  defaultmodel-wolfcall =
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAtsgdnGkeAWcGjsLyQRhCJDJyfwlD0euUW37u8ou6px";
  root-rhodes =
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIsBkMKOydPKaZKlapBojVUlCLd60nA/Kt/+OpSf9ka3 root@homelab";
  root-lemnos =
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILzfJLEwBnRwDBQlSG28krTAPp1LImWxnNm3LfkcFlcF";
  root-agios =
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIK5typsS1z9XxIBmDOxk803w/bs7ijbr2WnmzZbdcGcw";
in {
  "wg-conf.age".publicKeys = [ defaultmodel-wolfcall root-rhodes ];
  "paperless-admin-password.age".publicKeys =
    [ defaultmodel-wolfcall root-rhodes ];
  "slskd-credentials.age".publicKeys = [ defaultmodel-wolfcall root-rhodes ];
  "dns-provider-api-key.age".publicKeys =
    [ defaultmodel-wolfcall root-rhodes root-agios ];
  "rss-credentials.age".publicKeys = [ defaultmodel-wolfcall root-agios ];
  "bazarr-api-key.age".publicKeys = [ defaultmodel-wolfcall root-rhodes ];
  "radarr-api-key.age".publicKeys = [ defaultmodel-wolfcall root-rhodes ];
  "sonarr-api-key.age".publicKeys = [ defaultmodel-wolfcall root-rhodes ];
  "lidarr-api-key.age".publicKeys = [ defaultmodel-wolfcall root-rhodes ];
  "vaultwarden-admin-token.age".publicKeys =
    [ defaultmodel-wolfcall root-agios ];
  "radicale-credentials.age".publicKeys = [ defaultmodel-wolfcall root-agios ];
  "radarr-api-key-plain.age".publicKeys = [ defaultmodel-wolfcall root-rhodes ];
  "sonarr-api-key-plain.age".publicKeys = [ defaultmodel-wolfcall root-rhodes ];

  "hetzner-backup-passphrase.age".publicKeys =
    [ defaultmodel-wolfcall root-rhodes ];
  "hetzner-backup-agios-passphrase.age".publicKeys =
    [ defaultmodel-wolfcall root-agios ];
  "authelia-main-storageEncryptionKey".publicKeys =
    [ defaultmodel-wolfcall root-lemnos ];
  "authelia-main-jwtSecret".publicKeys = [ defaultmodel-wolfcall root-lemnos ];
}
