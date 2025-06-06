{ config, ... }:
let metricsHost = "192.168.1.30"; # rhodes
in {
  services.prometheus.exporters.node = {
    enable = true;
    port = 9100;
    openFirewall = true;
    enabledCollectors = [ "systemd" ];
  };

  services.promtail = {
    enable = true;
    configuration = {
      server = {
        http_listen_port = 28183;
        grpc_listen_port = 0;
      };
      clients = [{ url = "http://${metricsHost}:3100/loki/api/v1/push"; }];
      scrape_configs = [
        {
          job_name = "systemd-journal";
          journal = {
            max_age = "12h";
            labels = {
              job = "systemd-journal";
              host = config.networking.hostName;
            };
          };
          relabel_configs = [
            {
              source_labels = [ "__journal__systemd_unit" ];
              target_label = "unit";
            }
            {
              source_labels = [ "__journal_priority_keyword" ];
              target_label = "level";
            }
          ];
        }
        {
          job_name = "caddy";
          journal = {
            max_age = "12h";
            labels = {
              job = "caddy";
              host = config.networking.hostName;
              __path__ = "/var/log/caddy/*log";
            };
          };
        }
      ];
    };
  };

}
