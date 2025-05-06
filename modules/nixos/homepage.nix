{ config, lib, ... }:
with lib;
let
  # Shorter name to access a final setting
  # All modules are under the custom attribute "def"
  cfg = config.def.homepage;
  srv = config.services.homepage-dashboard;
  certloc = "/var/lib/acme/defaultmodel.eu.org";
  url = "home.defaultmodel.eu.org";
in
{
  options.def.homepage = { enable = mkEnableOption "Homepage"; };

  config = mkIf cfg.enable {
    services.homepage-dashboard = {
      enable = true;
      settings = {
        title = "Rhodes";
        favicon = "https://huggingface.co/favicon.ico";
        headerStyle = "clean";
        layout = {
          media = {
            style = "row";
            columns = 3;
          };
          infra = {
            style = "row";
            columns = 4;
          };
          machines = {
            style = "row";
            columns = 4;
          };
        };
      };
      bookmarks = [
        {
          Dev = [
            {
              Github = [
                {
                  abbr = "GH";
                  href = "https://github.com/";
                  icon = "github.png";
                }
              ];
            }
          ];
        }
        {
          Entertainment = [
            {
              YouTube = [
                {
                  abbr = "YT";
                  href = "https://youtube.com/";
                  icon = "reddit.png";
                }
              ];
              Reddit = [
                {
                  abbr = "YT";
                  href = "https://reddit.com/";
                  icon = "reddit.png";
                }
              ];
            }
          ];
        }
      ];
      widgets = [
        {
          resources = {
            cpu = true;
            memory = true;
            uptime = true;
            network = true;
          };
        }
        {
          search = {
            provider = "duckduckgo";
            showSearchSuggestions = true;
          };
        }
      ];
    };

    ### REVERSE PROXY ###
    services.caddy = {
      virtualHosts."home.defaultmodel.eu.org".extraConfig = ''
        reverse_proxy http://localhost:${toString srv.port}
        tls ${certloc}/cert.pem ${certloc}/key.pem {
          protocols tls1.3
        }
      '';
    };

    services.adguardhome.settings.dns.rewrites = [{
      domain = url;
      answer = config.networking.interfaces.enp2s0.ipv4;
    }] ++ (config.services.adguardhome.settings.dns.rewrites or [ ]);
  };
}
