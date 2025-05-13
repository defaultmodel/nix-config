{ config, ... }:
let
  mediaDir = "/data";
  srv = config.services.jellyfin;
  certloc = "/var/lib/acme/defaultmodel.eu.org";
  url = "jellyfin.defaultmodel.eu.org";
in
{
  # Always prioritise Jellyfin IO
  systemd.services.jellyfin.serviceConfig.IOSchedulingPriority = 0;

  # Give access to GPU for transcoding
  users.users.${config.services.jellyfin.user}.extraGroups = [ "video" "render" ];
  # systemd.services.jellyfin.serviceConfig = {
  #   DeviceAllow = lib.mkForce [ "/dev/dri/card0" "/dev/dri/card1" ];
  # };

  # The files he needs to function
  systemd.tmpfiles.rules = [
    "d '${mediaDir}/shows'        0775 ${srv.user} ${srv.group} - -"
    "d '${mediaDir}/movies'       0775 ${srv.user} ${srv.group} - -"
    "d '${mediaDir}/music'        0775 ${srv.user} ${srv.group} - -"
  ];

  services.jellyfin = {
    enable = true;
    group = "media";
    openFirewall = true;
  };

  ### REVERSE-PROXY ###
  services.caddy = {
    virtualHosts.${url}.extraConfig = ''
      reverse_proxy http://localhost:8096
      tls ${certloc}/cert.pem ${certloc}/key.pem {
           protocols tls1.3
         }
    '';
  };

  ### DNS-REWRITE ###
  services.adguardhome.settings.filtering.rewrites = [{
    domain = url;
    answer =
      (builtins.elemAt (config.networking.interfaces.bond0.ipv4.addresses)
        0).address;
  }];

  ### HOMEPAGE ###
  def.homepage.categories."Media"."Jellyfin" = {
    icon = "jellyfin.png";
    description = "Media streamer";
    href = "https://${url}";
  };
}

