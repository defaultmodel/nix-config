{ config, ... }: {
  # User Authentication
  # For a user called my_user to be authenticated on the samba server, 
  # you must add their password using: `smbpasswd -a my_user`

  age.secrets.smb-credentials = { file = ../../../../secrets/smb-credentials.age; };

  systemd.tmpfiles.rules = [
    "d /data 0755 root root - -"
    "d /data/public 1777 nobody nogroup - -"
    "d /data/media 0775 root media - -"
  ];

  services.samba = {
    enable = true;
    openFirewall = true;
    settings = {
      global = {
        "workgroup" = "WORKGROUP";
        "server string" = config.networking.hostName;
        "netbios name" = config.networking.hostName;
        "security" = "user";
        "use sendfile" = "yes";
        "hosts allow" = "192.168.1. 127.0.0.1 localhost";
        "hosts deny" = "0.0.0.0/0";
        "guest account" = "nobody";
        "map to guest" = "bad user";
      };
      public = {
        "path" = "/data/public";
        "browseable" = "yes";
        "read only" = "no";
        "guest ok" = "yes";
        "create mask" = "0644";
        "directory mask" = "0755";
      };
      ### DATA ###
      data = {
        "path" = "/data";
        "browseable" = "no";
        "read only" = "no";
        "guest ok" = "no";
        "create mask" = "0644";
        "directory mask" = "0755";
      };
      public-media = {
        "path" = "/data/media";
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
