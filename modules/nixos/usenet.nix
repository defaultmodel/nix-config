{ config, lib, ... }:
with lib;
let
  # Shorter name to access a final setting
  # All modules are under the custom attribute "def"
  cfg = config.def.usenet;
in {
  options.def.usenet = {
    enable = mkEnableOption "Usenet downloader";
    mediaDir = mkOption { type = types.path; };
    guiPort = mkOption {
      type = types.int;
      default = 8080;
    };
    vpn = {
      enable = mkEnableOption "confinement of sabnzbd to a VPN";
      wgConfFile = mkOption { type = types.path; };
    };
  };

  config = mkIf cfg.enable {
    systemd.tmpfiles.rules = [
      "d '${cfg.mediaDir}/usenet'             0755 ${config.services.sabnzbd.user} ${config.services.sabnzbd.group} - -"
      "d '${cfg.mediaDir}/usenet/.incomplete' 0755 ${config.services.sabnzbd.user} ${config.services.sabnzbd.group} - -"
      "d '${cfg.mediaDir}/usenet/.watch'      0755 ${config.services.sabnzbd.user} ${config.services.sabnzbd.group} - -"
      "d '${cfg.mediaDir}/usenet/movies'      0775 ${config.services.sabnzbd.user} ${config.services.sabnzbd.group} - -"
      "d '${cfg.mediaDir}/usenet/shows'       0775 ${config.services.sabnzbd.user} ${config.services.sabnzbd.group} - -"
      "d '${cfg.mediaDir}/usenet/music'       0775 ${config.services.sabnzbd.user} ${config.services.sabnzbd.group} - -"
    ];

    # Enable and specify VPN namespace to confine service in.
    systemd.services.sabnzbd.vpnConfinement = mkIf cfg.vpn.enable {
      enable = true;
      vpnNamespace = "wg";
    };

    # Port mappings
    vpnNamespaces.wg = mkIf cfg.vpn.enable {
      openVPNPorts = [{
        port = cfg.guiPort;
        protocol = "both";
      }];
    };

    services.sabnzbd = {
      enable = true;
      user = "usenet";
      group = "media";
      openFirewall = true;
    };
  };
}
