{ config, pkgs, lib, ... }:

{
  options.def.monitoring.server = {
    enable = lib.mkEnableOption "Enable monitoring server services";

    grafana = lib.mkOption {
      type = lib.types.submodule {
        options = {
          adminUser = lib.mkOption {
            type = lib.types.str;
            default = "admin";
            description = "Grafana admin username";
          };
          adminPasswordFile = lib.mkOption {
            type = lib.types.path;
            default = "admin";
            description = "Grafana admin password";
          };
        };
      };
      default = { };
      description = "Grafana configuration options";
    };
  };

  config = lib.mkIf config.def.monitoring.server.enable {
    services.prometheus = {
      enable = true;
      listenAddress = "0.0.0.0";
      port = 9090;
      scrapeConfigs = [
        {
          job_name = "cyclades";
          static_configs = [{
            targets = [ "127.0.0.1:9100" ];
          }];
        }
        {
          job_name = "immich_api";
          static_configs = [{
            targets = [ "127.0.0.1:8081" ];
          }];
        }
        {
          job_name = "immich_microservices";
          static_configs = [{
            targets = [ "127.0.0.1:8082" ];
          }];
        }
      ];
    };

    services.grafana = {
      enable = true;
      settings = {
        server = {
          http_port = 3000;
          http_addr = "0.0.0.0";
        };
        security = {
          admin_user = config.def.monitoring.server.grafana.adminUser;
          admin_password = "$__file{${config.def.monitoring.server.grafana.adminPasswordFile}}";
        };
      };
      provision = {
        enable = true;
        datasources.settings.datasources = [
          {
            name = "Prometheus";
            type = "prometheus";
            access = "proxy";
            url = "http://localhost:${toString config.services.prometheus.port}";
            isDefault = true;
          }
          {
            name = "Loki";
            type = "loki";
            access = "proxy";
            url = "http://localhost:${toString config.services.loki.configuration.server.http_listen_port}";
          }
        ];
      };
    };

    services.loki = {
      enable = true;
      configuration = {
        auth_enabled = false;
        server.http_listen_port = 3100;
        common.path_prefix = "/var/lib/loki";
        ingester = {
          lifecycler = {
            address = "0.0.0.0";
            ring.kvstore.store = "inmemory";
            ring.replication_factor = 1;
          };
          chunk_idle_period = "1h"; # Any chunk not receiving new logs in this time will be flushed
          max_chunk_age = "1h"; # All chunks will be flushed when they hit this age, default is 1h
          chunk_target_size = 1048576; # Loki will attempt to build chunks up to 1.5MB, flushing first if chunk_idle_period or max_chunk_age is reached first
          chunk_retain_period = "30s"; # Must be greater than index read cache TTL if using an index cache (Default index read cache TTL is 5m)
          # max_transfer_retries = 0; # Chunk transfers disabled
        };
        schema_config = {
          configs = [{
            from = "2020-10-24";
            store = "tsdb";
            object_store = "filesystem";
            schema = "v13";
            index = {
              prefix = "index_";
              period = "24h";
            };
          }];
        };
        storage_config = {
          filesystem = {
            directory = "/var/lib/loki/tsdb";
          };
          tsdb_shipper = {
            active_index_directory = "/var/lib/loki/index";
            cache_location = "/var/lib/loki/cache";
          };
        };
        limits_config = {
          reject_old_samples = true;
          reject_old_samples_max_age = "168h";
        };
        # chunk_store_config = {
        #   max_look_back_period = "0s";
        # };
        table_manager = {
          retention_deletes_enabled = false;
          retention_period = "0s";
        };
        compactor = {
          working_directory = "var/lib/loki";
          # shared_store = "filesystem";
          compactor_ring.kvstore.store = "inmemory";
        };
      };
    };

    networking.firewall.allowedTCPPorts = [
      config.services.grafana.settings.server.http_port
      config.services.loki.configuration.server.http_listen_port
      config.services.prometheus.port
    ];
  };
}
