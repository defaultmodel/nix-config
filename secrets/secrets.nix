let
  root-wolfcall =
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJwMavP3djIhEVnNJjBUoMOIVlBI1bjyxg3NNtDpP/Op";
  defaultmodel-wolfcall =
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAtsgdnGkeAWcGjsLyQRhCJDJyfwlD0euUW37u8ou6px";
  root-rhodes =
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAO/RjuSJEP2Ne0sr4q8PQdXUoGuZFTZYtvY/7JsJVan";
in {
  "wg-conf.age".publicKeys = [ defaultmodel-wolfcall root-rhodes ];
  "smb-credentials.age".publicKeys = [ defaultmodel-wolfcall root-rhodes ];
  "paperless-admin-password.age".publicKeys =
    [ defaultmodel-wolfcall root-rhodes ];
  "slskd-credentials.age".publicKeys = [ defaultmodel-wolfcall root-rhodes ];
  "torrent-credentials.age".publicKeys = [ defaultmodel-wolfcall root-rhodes ];
  "dns-provider-api-key.age".publicKeys = [ defaultmodel-wolfcall root-rhodes ];
  "rss-credentials.age".publicKeys = [ defaultmodel-wolfcall root-rhodes ];
  "bazarr-api-key.age".publicKeys = [ defaultmodel-wolfcall root-rhodes ];
  "radarr-api-key.age".publicKeys = [ defaultmodel-wolfcall root-rhodes ];
  "sonarr-api-key.age".publicKeys = [ defaultmodel-wolfcall root-rhodes ];
  "lidarr-api-key.age".publicKeys = [ defaultmodel-wolfcall root-rhodes ];
  "vaultwarden-admin-token.age".publicKeys =
    [ defaultmodel-wolfcall root-rhodes ];
  "hetzner-backup-passphrase.age".publicKeys =
    [ defaultmodel-wolfcall root-rhodes ];
}
