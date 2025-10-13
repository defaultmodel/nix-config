{ config, ... }:
let
  srv = config.services.deluge;
  certloc = "/var/lib/acme/defaultmodel.eu.org";
  url = "torrent.defaultmodel.eu.org";

  # Download will be actually be moved based on their tags
  downloadDir = "/data/torrent";
  incompleteDir = "/data/torrent/.incomplete";
  watchDir = "/data/torrent/.watch";
in {
  systemd.tmpfiles.rules = [
    "d '${downloadDir}'             0775 ${srv.user} ${srv.group} - -"
    "d '${incompleteDir}' 0755 ${srv.user} ${srv.group} - -"
    "d '${watchDir}'      0755 ${srv.user} ${srv.group} - -"
    "d '${downloadDir}/movies'      0775 ${srv.user} ${srv.group} - -"
    "d '${downloadDir}/shows'       0775 ${srv.user} ${srv.group} - -"
    "d '${downloadDir}/music'       0775 ${srv.user} ${srv.group} - -"
  ];

  age.secrets.torrent-credentials = {
    file = ../../../../../secrets/torrent-credentials.age;
    mode = "400";
    owner = srv.user;
  };

  users.users.torrent = {
    isSystemUser = true;
    group = "media";
  };

  services.deluge = {
    enable = true;
    user = "torrent";
    group = "media";

    authFile = config.age.secrets.torrent-credentials.path;
    web.enable = true;

    declarative = true;
    config = {
      download_location = downloadDir;
      enabled_plugins = [ "Label" "WebUi" ];

      auto_managed = false;
      max_connections_global = -1;
      max_upload_speed = -1;
      max_download_speed = -1;
      max_upload_slots_global = -1;
      max_active_seeding = -1;
      max_active_downloading = -1;
      max_active_limit = -1;
      super_seeding = true;

      random_outgoing_ports = false;
      pre_allocate_storage = true;
      # Networking
      allow_remote = true;
      daemon_port = 58846;
      random_port = false;
      listen_ports = [ 6881 ];
      enc_level = 1; # Full stream encryption
      # Features
      upnp = false;
      natpmp = false;
    };
  };

  ### REVERSE PROXY ###
  services.caddy = {
    virtualHosts.${url}.extraConfig = ''
      reverse_proxy http://192.168.15.1:${toString srv.web.port}
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
  def.homepage.categories."Downloaders"."Deluge" = {
    icon = "deluge.png";
    description = "Torrent downloader";
    href = "https://${url}";
  };

  ### VPN ###
  # Enable and specify VPN namespace to confine service in.
  systemd.services.deluged.vpnConfinement = {
    enable = true;
    vpnNamespace = "wg";
  };
  systemd.services.delugeweb.vpnConfinement = {
    enable = true;
    vpnNamespace = "wg";
  };

  # Port mappings
  vpnNamespaces.wg = {
    portMappings = [{
      from = srv.web.port;
      to = srv.web.port;
    }];
    openVPNPorts = [
      {
        port = srv.config.daemon_port;
        protocol = "both";
      }
      {
        port = 6881;
        protocol = "both";
      }
    ];
  };
}
