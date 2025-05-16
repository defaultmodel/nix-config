{ ... }:
{
  imports = [
    ./prometheus.nix
    ./grafana.nix
    ./loki.nix
    ./uptime-kuma.nix
  ];
}

