{ config, lib, pkgs, ... }: {

  age.secrets.wg-conf = { file = ../../../../secrets/wg-conf.age; };

  nixarr = {
    enable = true;

    vpn = {
      enable = true;
      # WARNING: This file must _not_ be in the config git directory
      # You can usually get this wireguard file from your VPN provider
      wgConf = config.age.secrets.wg-conf.path;
    };

    mediaDir = "/mnt/shares/data/media";
    stateDir = "/var/lib";

    jellyfin.enable = true;
    jellyseerr.enable = true;
    bazarr.enable = true;
    prowlarr.enable = true;
    radarr.enable = true;
    sonarr.enable = true;
    lidarr.enable = true;
    recyclarr = {
      enable = true;
      configuration = {
        radarr = [{
          api_key = {
            _secret = "/run/credentials/recyclarr.service/radarr-api_key";
          };
          base_url = "http://localhost:7878";
          instance_name = "main";
        }];
        sonarr = [{
          api_key = {
            _secret = "/run/credentials/recyclarr.service/sonarr-api_key";
          };
          base_url = "http://localhost:8989";
          instance_name = "main";
        }];
      };
    };
    transmission = {
      enable = true;
      vpn.enable = true;
    };
    sabnzbd = {
      enable = true;
      vpn.enable = true;
    };
  };

  environment.systemPackages = with pkgs; [ beets ffmpeg ];

  systemd.timers."beets-import-soulseek" = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "15m";
      OnUnitActiveSec = "15m";
      Unit = "beets-import-soulseek.service";
    };
  };

  systemd.services."beets-import-soulseek" = {
    script = "set -eu && ${
        lib.getExe pkgs.beets
      } import /mnt/shares/data/soulseek/complete --quiet";
    serviceConfig = {
      Type = "oneshot";
      User = "root";
    };
  };

  vpnNamespaces.wg = {
    openVPNPorts = [
      {
        port = 2271;
        protocol = "both";
      } # Connection to soulseek server
      {
        port = 50300;
        protocol = "both";
      } # P2P connection
    ];
  };

  # Force slskd through nixarr VPN
  systemd.services.slskd.vpnconfinement = {
    enable = true;
    vpnnamespace = "wg"; # This must be "wg", that's what nixarr uses
  };

  age.secrets.slskd-credentials = {
    file = ../../../../secrets/slskd-credentials.age;
    mode = "440";
    owner = "slskd";
    group = "slskd";
  };

  services.slskd = {
    enable = true;
    openFirewall = true;
    domain = "slskd.defaultmodel.eu.org";
    environmentFile = config.age.secrets.slskd-credentials.path;
    settings = {
      global = {
        upload.slots = 10;
        upload.speed_limit = 10000;
        download.speed_limit = 10000;
      };
      web = { port = 5030; };
      directories = {
        downloads = "/mnt/shares/data/soulseek/complete";
        incomplete = "/mnt/shares/data/soulseek/incomplete";
      };
      shares = {
        directories = [
          "/mnt/shares/data/media/music"
          "/mnt/shares/data/media/movies"
          "/mnt/shares/data/media/shows"
        ];
      };
    };
  };
}
