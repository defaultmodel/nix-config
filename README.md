## Nix-OS anywhere
[Quickstart](https://github.com/nix-community/nixos-anywhere/blob/main/docs/quickstart.md)

```
  nix --extra-experimental-features nix-command --extra-experimental-features flake run github:nix-community/nixos-anywhere -- --disko-mode disko --flake .#<hostname> --target-host nixos@<host ip>
```

## Secrets

###### wg-conf.age
Wireguard config file

###### smb-credentials.age
```
username=...
password=...
```

###### sonarr-api-key.age
```
SONARR__AUTH__APIKEY=...
```

###### radarr-api-key.age
```
RADARR__AUTH__APIKEY=...
```

###### torrent-credentials.age
[deluge docs](https://deluge-torrent.org/userguide/authentication/)
```
<username>:<password>:10
```

###### slskd-credentials.age
It must at least contain the variables SLSKD_SLSK_USERNAME and SLSKD_SLSK_PASSWORD.
Web interface credentials should also be set here in SLSKD_USERNAME and SLSKD_PASSWORD.
```
SLSKD_SLSK_USERNAME=...
SLSKD_SLSK_PASSWORD=...
SLSKD_USERNAME=...
SLSKD_PASSWORD=...
```
###### paperless-admin-password.age
```
<password>
```
