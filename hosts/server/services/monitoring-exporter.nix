{ config, ... }:
let metricsHost = "192.168.1.30"; # Rhodes
in {
  services.prometheus.exporters.node = {
    enable = true;
    port = 9100;
    openFirewall = true;

    enabledCollectors = [ "cpu" "systemd" ];
  };

  services.promtail = {
    enable = true;
    configuration = {
      server = {
        http_listen_port = 28183;
        grpc_listen_port = 0;
      };
      clients = [{ url = "http://${metricsHost}:3100/loki/api/v1/push"; }];
      scrape_configs = [{
        job_name = "systemd-journal";
        journal = {
          max_age = "12h";
          labels = {
            job = "systemd-journal";
            host = config.networking.hostName;
          };
        };
        pipeline_stages = [
          {
            json.expressions = {
              transport = "_TRANSPORT";
              unit = "_SYSTEMD_UNIT";
              msg = "MESSAGE";
              coredump_cgroup = "COREDUMP_CGROUP";
              coredump_exe = "COREDUMP_EXE";
              coredump_cmdline = "COREDUMP_CMDLINE";
              coredump_uid = "COREDUMP_UID";
              coredump_gid = "COREDUMP_GID";
            };
          }
          {
            # Set the unit (defaulting to the transport like audit and kernel)
            template = {
              source = "unit";
              template = "{{if .unit}}{{.unit}}{{else}}{{.transport}}{{end}}";
            };
          }
          {
            regex = {
              expression = "(?P<coredump_unit>[^/]+)$";
              source = "coredump_cgroup";
            };
          }
          { labels.coredump_unit = "coredump_unit"; }
          {
            # Normalize session IDs (session-1234.scope -> session.scope) to limit number of label values
            replace = {
              source = "unit";
              expression = "^(session-\\d+.scope)$";
              replace = "session.scope";
            };
          }
          { labels.unit = "unit"; }
          {
            # Write the proper message instead of JSON
            output.source = "msg";
          }
          # Silence
          # ignore random portscans on the internet
          { drop.expression = "refused connection: IN="; }
        ];
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
      }];
    };
  };

}

