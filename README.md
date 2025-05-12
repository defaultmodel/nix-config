## Nix-OS anywhere
[Quickstart](https://github.com/nix-community/nixos-anywhere/blob/main/docs/quickstart.md)

```
  nix --extra-experimental-features nix-command --extra-experimental-features flake run github:nix-community/nixos-anywhere -- --disko-mode disko --flake .#<hostname> --target-host nixos@<host ip>
```

## Secrets File Structure

1. **wg-conf.age**
    - **Content**: WireGuard configuration file.
    - **Format**: In my case it is the content of a file downloaded [here](https://mullvad.net/fr/account/wireguard-config)

2. **smb-credentials.age**
    - **Content**: SMB (Server Message Block) credentials.
    - **Format**: See [this thread](https://unix.stackexchange.com/a/436181)
     ```
     username=...
     password=...
     ```

3. **sonarr-api-key.age**
    - **Content**: Sonarr API key.
    - **Format**: According to [servarr wiki](https://wiki.servarr.com/useful-tools#using-environment-variables-for-config):
    ```
      BAZARR__AUTH__APIKEY=...
    ```

4. **radarr-api-key.age**
    - **Content**: Radarr API key.
    - **Format**: According to [servarr wiki](https://wiki.servarr.com/useful-tools#using-environment-variables-for-config):
    ```
      BAZARR__AUTH__APIKEY=...
    ```

5. **torrent-credentials.age**
    - **Content**: Torrent client credentials.
    - **Format**: As per [Deluge documentation](https://deluge-torrent.org/userguide/authentication/):
      > NOTE: There should always be a 'localclient' entry for use by the UIs running locally by your user.
     ```
     localclient:<password>:10
     <username>:<password>:10
     ```

6. **slskd-credentials.age**
    - **Content**: Soulseek daemon (slskd) credentials.
    - **Format**: Must contain the variables `SLSKD_SLSK_USERNAME` and `SLSKD_SLSK_PASSWORD` for the **soulseek** connection. Web interface credentials should also be set with `SLSKD_USERNAME` and `SLSKD_PASSWORD`.
     ```
     SLSKD_SLSK_USERNAME=...
     SLSKD_SLSK_PASSWORD=...
     SLSKD_USERNAME=...
     SLSKD_PASSWORD=...
     ```

7. **paperless-admin-password.age**
    - **Content**: Admin password for Paperless.
    - **Format**: See the description of the [service option](https://mynixos.com/nixpkgs/option/services.paperless.passwordFile)
     ```
     <password>
     ```

8. **dns-provider-api-key.age**
    - **Content**: In my case, a [desec.io](https://desec.io/) token.
    - **Format**: The format comes from the documentation of the underlying tool for acme, [LEGO](https://go-acme.github.io/lego/dns/)
     ```
     DESEC_TOKEN=...
     ```

9. **rss-credentials.age**
    - **Content**: [Miniflux](https://miniflux.app/) credentials.
    - **Format**: According to [miniflux nixos service documentation](https://mynixos.com/nixpkgs/option/services.miniflux.adminCredentialsFile):
      ```
        ADMIN_USERNAME=...
        ADMIN_PASSWORD=...
      ```

10. **bazarr-api-key.age**
    - **Content**: Bazarr API key.
    - **Format**: According to [servarr wiki](https://wiki.servarr.com/useful-tools#using-environment-variables-for-config):
    ```
      BAZARR__AUTH__APIKEY=...
    ```

11. **lidarr-api-key.age**
    - **Content**: Lidarr API key.
    - **Format**: According to [servarr wiki](https://wiki.servarr.com/useful-tools#using-environment-variables-for-config):
    ```
      LIDARR__AUTH__APIKEY=...
    ```

12. **prowlarr-api-key.age**
    - **Content**: Prowlarr API key.
    - **Format**: According to [servarr wiki](https://wiki.servarr.com/useful-tools#using-environment-variables-for-config):
    ```
      PROWLARR__AUTH__APIKEY=...
    ```

13. **vaultwarden-admin-token.age**
    - **Content**: Vaultwarden admin token.
    - **Format**: Following [vaultwarden wiki](https://github.com/dani-garcia/vaultwarden/wiki/Enabling-admin-page).
    ```
      ADMIN_TOKEN=...
    ```

14. **hetzner-backup-passphrase.age**
    - **Content**: Hetzner backup passphrase.
    - **Format**: This file needs to only contain the passphrase as it will be cat in [backup.nix](modules/nixos/backup.nix).


