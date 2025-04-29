let
  root-wolfcall =
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJwMavP3djIhEVnNJjBUoMOIVlBI1bjyxg3NNtDpP/Op";
  defaultmodel-wolfcall =
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAtsgdnGkeAWcGjsLyQRhCJDJyfwlD0euUW37u8ou6px";
  root-rhodes =
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILT3J7nwgGp/O76ApMJKduxjrIOpWdX6qqJkU12zPmki";
in {
  "paperless-admin-password.age".publicKeys = [ root-rhodes ];
  "smb-credentials.age".publicKeys = [ root-rhodes ];
  "slskd-credentials.age".publicKeys = [ root-rhodes ];
  "wg-conf.age".publicKeys = [ root-rhodes ];
  "torrent-credentials.age".publicKeys = [ root-rhodes ];
}
