{ config, ... }:
{
  # User Authentication
  # For a user called my_user to be authenticated on the samba server, 
  # you must add their password using: `smbpasswd -a my_user`

  services.samba = {
    enable = true;
    securityType = "user";
    openFirewall = true;
    settings = {
      global = {
        "workgroup" = "WORKGROUP";
        "server string" = config.networking.hostName;
        "netbios name" = config.networking.hostName;
        "security" = "user";
        "use sendfile" = "yes";
        "hosts allow" = "192.168.0. 127.0.0.1 localhost";
        "hosts deny" = "0.0.0.0/0";
        "guest account" = "nobody";
        "map to guest" = "bad user";
      };
      "public" = {
        "path" = "/mnt/shares/public";
        "browseable" = "yes";
        "read only" = "no";
        "guest ok" = "yes";
        "create mask" = "0644";
        "directory mask" = "0755";
      };
      ### DATA ###
      "data" = {
        "path" = "/mnt/shares/data";
        "browseable" = "no";
        "read only" = "no";
        "guest ok" = "no";
        "create mask" = "0644";
        "directory mask" = "0755";
      };
      "torrents" = {
        "path" = "/mnt/shares/data/torrents";
        "browseable" = "no";
        "read only" = "no";
        "guest ok" = "no";
        "create mask" = "0644";
        "directory mask" = "0755";
      };
      "usenet" = {
        "path" = "/mnt/shares/data/usenet";
        "browseable" = "no";
        "read only" = "no";
        "guest ok" = "no";
        "create mask" = "0644";
        "directory mask" = "0755";
      };
      "soulseek" = {
        "path" = "/mnt/shares/data/soulseek";
        "browseable" = "no";
        "read only" = "no";
        "guest ok" = "no";
        "create mask" = "0644";
        "directory mask" = "0755";
      };
      "media" = {
        "path" = "/mnt/shares/data/media";
        "browseable" = "no";
        "read only" = "no";
        "guest ok" = "no";
        "create mask" = "0644";
        "directory mask" = "0755";
      };
      "public-media" = {
        "path" = "/mnt/shares/data/media";
        "browseable" = "yes";
        "read only" = "yes";
        "guest ok" = "yes";
        "create mask" = "0644";
        "directory mask" = "0755";
      };
    };
  };

  # Allow windows hosts to discover shares
  services.samba-wsdd = {
    enable = true;
    openFirewall = true;
  };
}
