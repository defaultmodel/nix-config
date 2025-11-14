{ config, ... }:
let
  srv = config.services.slskd;
  certloc = "/var/lib/acme/defaultmodel.eu.org";
  url = "slskd.defaultmodel.eu.org";

  mediaDir = "/data/soulseek";
  completeDir = "${mediaDir}/complete";
  incompleteDir = "${mediaDir}/incomplete";
in
{
  systemd.tmpfiles.rules = [
    "d '${mediaDir}'  0775 ${srv.user} ${srv.group} - -"
    "d '${completeDir}'  0775 ${srv.user} ${srv.group} - -"
    "d '${incompleteDir}'    0775 ${srv.user} ${srv.group} - -"
  ];

  age.secrets.slskd-credentials = {
    file = ../../../../secrets/slskd-credentials.age;
    mode = "400";
    owner = srv.user;
  };

  # Enable and specify VPN namespace to confine service in.
  systemd.services.deluge.vpnConfinement = {
    enable = true;
    vpnNamespace = "wg";
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

  services.slskd = {
    enable = true;
    user = "slskd";
    group = "media";
    openFirewall = true;
    domain = null;
    environmentFile = config.age.secrets.slskd-credentials.path;
    settings = {
      global = {
        upload.slots = 30;
        upload.speed_limit = 10000;
        download.speed_limit = 10000;
      };
      web = { port = 5030; };
      directories = {
        downloads = completeDir;
        incomplete = incompleteDir;
      };
      shares = {
        directories = [
          "/data/media/movies"
          "/data/media/shows"
          "/data/media/music"
        ];
      };
    };
  };

  ### REVERSE PROXY ###
  services.caddy = {
    virtualHosts.${url}.extraConfig = ''
      reverse_proxy http://localhost:${toString srv.settings.web.port}
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
  def.homepage.categories."Downloaders"."Slskd" = {
    icon = "slskd.png";
    description = "Soulseek web-app";
    href = "https://${url}";
  };
}
