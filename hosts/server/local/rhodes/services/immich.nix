{ config, lib, ... }:
with lib;
let
  srv = config.services.immich;
  certloc = "/var/lib/acme/defaultmodel.eu.org";
  url = "immich.defaultmodel.eu.org";

  mediaDir = "/data";
  photosDir = "${mediaDir}/photos";
in {
  # Give access to GPU for accelerated AI
  users.users.${srv.user}.extraGroups = [ "video" "render" ];
  systemd.services.immich.serviceConfig = {
    DeviceAllow = mkForce [ "/dev/dri/card0" ];
  };

  systemd.tmpfiles.rules =
    [ "d '${photosDir}'        0775 ${srv.user} ${srv.group} - -" ];

  services.immich = {
    enable = true;
    host = "0.0.0.0";
    port = 2283;
  };

  ### REVERSE PROXY ###
  services.caddy = {
    virtualHosts.${url}.extraConfig = ''
      reverse_proxy http://localhost:${toString srv.port}
      tls ${certloc}/cert.pem ${certloc}/key.pem {
           protocols tls1.3
         }
    '';
  };

  services.adguardhome.settings.filtering.rewrites = [{
    domain = url;
    answer =
      (builtins.elemAt (config.networking.interfaces.bond0.ipv4.addresses)
        0).address;
  }];

  ### HOMEPAGE ###
  def.homepage.categories."Media"."Immich" = {
    icon = "immich.png";
    description = "Photo manager";
    href = "https://${url}";
  };
}
