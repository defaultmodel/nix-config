{ config, lib, ... }:

{
  options.def.monitoring.client = {
    enable = lib.mkEnableOption "Enable monitoring client services";

    promtail = {
      lokiAddress = lib.mkOption {
        type = lib.types.str;
        description = "Address of the Loki server (including port)";
        example = "http://monitoring-server:3100";
      };
      scrapeConfigs = lib.mkOption {
        type = lib.types.listOf lib.types.attrs;
        default = [ ];
        description = "Additional Promtail scrape configurations";
        example = lib.literalExpression ''
          [
            {
              job_name = "immich";
              static_configs = [{
                targets = [ "localhost" ];
                labels = {
                  job = "immich";
                  host = config.networking.hostName;
                  __path__ = "/var/lib/immich/logs/*.log";
                };
              }];
            }
          ]
        '';
      };
    };
  };

  config = lib.mkIf config.def.monitoring.client.enable {
    services.promtail = {
      enable = true;
      configuration = {
        server = {
          http_listen_port = 9080;
          grpc_listen_port = 0;
        };
        positions = {
          filename = "/tmp/positions.yaml";
        };
        clients = [{
          url = "${config.def.monitoring.client.promtail.lokiAddress}/loki/api/v1/push";
        }];
        scrape_configs = [{
          job_name = "journal";
          journal = {
            max_age = "12h";
            labels = {
              job = "systemd-journal";
              host = config.networking.hostName;
            };
          };
          relabel_configs = [{
            source_labels = [ "__journal__systemd_unit" ];
            target_label = "unit";
          }];
        }] ++ config.def.monitoring.client.promtail.scrapeConfigs;
      };
    };

    services.prometheus.exporters.node = {
      enable = true;
      port = 9100;
      enabledCollectors = [
        "processes"
        "systemd"
      ];
    };

    networking.firewall.allowedTCPPorts = [
      9080 # Promtail
      9100 # Node Exporter
    ];
  };
}
