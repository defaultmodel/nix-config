{ config, ... }:
let srv = config.services.loki;
in {
  services.loki = {
    enable = true;
    configuration = {
      auth_enabled = false;
      server = {
        http_listen_port = 3100;
        http_listen_address = "0.0.0.0";
        grpc_listen_port = 9096;
      };

      ingester = {
        wal = {
          enabled = true;
          dir = "${srv.dataDir}/wal";
        };
        lifecycler = {
          address = "127.0.0.1";
          ring = {
            kvstore = { store = "inmemory"; };
            replication_factor = 1;
          };
          final_sleep = "0s";
        };
        chunk_idle_period = "1h";
      };

      schema_config = {
        configs = [{
          from = "2022-12-01";
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
        tsdb_shipper = {
          active_index_directory = "${srv.dataDir}/tsdb-index";
          cache_location = "${srv.dataDir}/tsdb-cache";
          cache_ttl = "24h";
        };
        filesystem = { directory = "${srv.dataDir}/chunks"; };
      };

      limits_config = {
        allow_structured_metadata = false;
        reject_old_samples = true;
        reject_old_samples_max_age = "72h";
      };

      compactor = { working_directory = "${srv.dataDir}/compactor"; };
    };
  };

  networking.firewall.allowedTCPPorts =
    [ srv.configuration.server.http_listen_port ];
}

