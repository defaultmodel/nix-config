{ config, ... }:
let
  musicFolder = "/data/media/music";
  srv = config.services.navidrome;
  certloc = "/var/lib/acme/defaultmodel.eu.org";
  url = "navidrome.defaultmodel.eu.org";
in {
  systemd.tmpfiles.rules =
    [ "d '${musicFolder}'        0775 ${srv.user} ${srv.group} - -" ];

  services.navidrome = {
    enable = true;
    group = "media";
    settings = {
      Address = "0.0.0.0";
      Port = 4533;
      MusicFolder = musicFolder;
    };
  };

  ### REVERSE PROXY ###
  services.caddy = {
    virtualHosts.${url}.extraConfig = ''
      reverse_proxy http://localhost:${toString srv.settings.Port}
      tls ${certloc}/cert.pem ${certloc}/key.pem {
        protocols tls1.3
      }
    '';
  };

  services.adguardhome.settings.filtering.rewrites = [{
    domain = url;
    answer =
      (builtins.elemAt (config.networking.interfaces.enp2s0.ipv4.addresses)
        0).address;
  }];

  ### HOMEPAGE ###
  def.homepage.categories."Media"."Navidrome" = {
    icon = "navidrome.png";
    description = "Music Streamer";
    href = "https://${url}";
  };
}
