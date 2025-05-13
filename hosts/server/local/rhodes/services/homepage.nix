{ config, lib, ... }:
let
  srv = config.services.homepage-dashboard;
  certloc = "/var/lib/acme/defaultmodel.eu.org";
  url = "home.defaultmodel.eu.org";
in
{
  services.homepage-dashboard = {
    enable = true;
    openFirewall = true;

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
    services = [
      #TODO complete
    ];
    bookmarks = [
      {
        Dev = [{
          Github = [{
            abbr = "GH";
            href = "https://github.com/";
            icon = "github.png";
          }];
        }];
      }
      {
        Entertainment = [{
          YouTube = [{
            abbr = "YT";
            href = "https://youtube.com/";
            icon = "reddit.png";
          }];
          Reddit = [{
            abbr = "YT";
            href = "https://reddit.com/";
            icon = "reddit.png";
          }];
        }];
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

  systemd.services.homepage-dashboard.environment = {
    # We can afford this because only our local network will have access
    HOMEPAGE_ALLOWED_HOSTS = "*";
  };

  ### REVERSE PROXY ###
  services.caddy = {
    virtualHosts."home.defaultmodel.eu.org".extraConfig = ''
      reverse_proxy http://localhost:${toString srv.listenPort}
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
}
