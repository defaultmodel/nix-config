{ config, ... }:

let
  srv = config.services.grafana;
  certloc = "/var/lib/acme/defaultmodel.eu.org";
  url = "grafana.defaultmodel.eu.org";
in {
  services.grafana = {
    enable = true;

    settings.server = {
      domain = url;
      http_port = 2342;
      http_addr = "0.0.0.0";
    };

    provision = {
      enable = true;
      datasources.settings.datasources = [
        {
          name = "Prometheus";
          type = "prometheus";
          uid = "prom1";
          url =
            ("http://localhost:${toString config.services.prometheus.port}");
          isDefault = true;
        }
        {
          name = "Loki";
          type = "loki";
          url = ("http://localhost:${
              toString
              config.services.loki.configuration.server.http_listen_port
            }");
        }
      ];
      dashboards.settings.providers = [{
        name = "Node Exporter Full";
        type = "file";
        url = "https://grafana.com/api/dashboards/1860/revisions/29/download";
        options.path = dashboards/node-exporter-full.json;
      }];
    };
  };

  ### REVERSE PROXY ###
  services.caddy = {
    virtualHosts.${url}.extraConfig = ''
      reverse_proxy http://localhost:${toString srv.settings.server.http_port}
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
  def.homepage.categories."Monitoring"."Grafana" = {
    icon = "grafana.png";
    description = "Monitoring dashboard";
    href = "https://${url}";
  };
}

