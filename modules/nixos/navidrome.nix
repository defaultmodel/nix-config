{ config, lib, ... }:
with lib;
let
  # Shorter name to access a final setting
  # All modules are under the custom attribute "def"
  cfg = config.def.navidrome;
  srv = config.services.navidrome;
  certloc = "/var/lib/acme/defaultmodel.eu.org";
  url = "navidrome.defaultmodel.eu.org";
in {
  options.def.navidrome = {
    enable = mkOption {
      default = false;
      type = types.bool;
    };
    musicFolder = mkOption { type = types.path; };
  };

  config = mkIf cfg.enable {
    services.navidrome = {
      enable = true;
      settings = {
        Address = "0.0.0.0";
        Port = 4533;
        MusicFolder = cfg.musicFolder;
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
        (builtins.elemAt (config.networking.interfaces.bond0.ipv4.addresses)
          0).address;
    }];

    ### HOMEPAGE ###
    def.homepage.categories."Media"."Navidrome" = {
      icon = "navidrome.png";
      description = "Music Streamer";
      href = "https://${url}";
    };
  };
}
