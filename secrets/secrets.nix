let
  root-wolfcall =
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJwMavP3djIhEVnNJjBUoMOIVlBI1bjyxg3NNtDpP/Op";
  defaultmodel-wolfcall =
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAtsgdnGkeAWcGjsLyQRhCJDJyfwlD0euUW37u8ou6px";
  root-rhodes =
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPwGBa6jJZKe3TvA4wqvXu1T4I9/53Ouqi0gKHs6RDZ7";
in {
  "paperless-admin-password.age".publicKeys =
    [ defaultmodel-wolfcall root-rhodes ];
  "smb-credentials.age".publicKeys = [ defaultmodel-wolfcall root-rhodes ];
  "slskd-credentials.age".publicKeys = [ defaultmodel-wolfcall root-rhodes ];
  "wg-conf.age".publicKeys = [ defaultmodel-wolfcall root-rhodes ];
  "torrent-credentials.age".publicKeys = [ defaultmodel-wolfcall root-rhodes ];
  "radarr-api-key.age".publicKeys = [ defaultmodel-wolfcall root-rhodes ];
  "sonarr-api-key.age".publicKeys = [ defaultmodel-wolfcall root-rhodes ];
}
