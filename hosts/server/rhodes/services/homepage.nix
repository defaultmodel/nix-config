{ config, lib, ... }:
with lib;
let
  cfg = config.def.homepage;
  srv = config.services.homepage-dashboard;
  certloc = "/var/lib/acme/defaultmodel.eu.org";
  url = "home.defaultmodel.eu.org";

  # Define a type for a service entry
  serviceType = types.submodule {
    options = {
      icon = mkOption { type = types.str; };
      description = mkOption { type = types.str; };
      href = mkOption { type = types.str; };
    };
  };

  # Define a type for a category (a set of service names → service config)
  categoryType = types.attrsOf serviceType;
in {
  options.def.homepage = {
    categories = mkOption {
      type = types.attrsOf categoryType;
      default = { };
      description = "Services grouped by category name.";
    };
  };

  config = {
    services.homepage-dashboard = {
      enable = true;
      openFirewall = true;

      allowedHosts = "*";

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
      # Convert the `categories` attrset into the `services` list format
      # Defined like so :
      # ```nix
      # def.homepage.categories."categorie-name"."service-name" = {
      #   icon = "...";
      #   description = "...";
      #   href = "...";
      # };
      # ```
      services = lib.mapAttrsToList (name: services: {
        "${name}" =
          mapAttrsToList (serviceName: cfg: { "${serviceName}" = cfg; })
          services;
      }) cfg.categories;
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
  };
}
