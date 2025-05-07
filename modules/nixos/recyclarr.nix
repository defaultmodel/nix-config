{ config, lib, ... }:
with lib;
let
  # Shorter name to access a final setting
  # All modules are under the custom attribute "def"
  cfg = config.def.recyclarr;
  srv = config.services.recyclarr;
in
{
  options.def.recyclarr = {
    enable = mkEnableOption "Recyclarr arr* suite synchronization";
    radarrApiKeyFile = mkOption { type = types.path; };
    sonarrApiKeyFile = mkOption { type = types.path; };
  };

  config = mkIf cfg.enable {
    services.recyclarr = {
      enable = true;
      openFirewall = true;

      systemd.services.recyclarr.serviceConfig.LoadCredential = [
        "radarr-api_key:${cfg.radarrApiPkey}"
        "sonarr-api_key:${cfg.sonarrApiPkey}"
      ];

      configuration = {
        radarr = [
          {
            api_key = {
              _secret = "/run/credentials/recyclarr.service/radarr-api_key";
            };
            base_url = "http://localhost:7878";
            instance_name = "main";
          }
        ];
        sonarr = [
          {
            api_key = {
              _secret = "/run/credentials/recyclarr.service/sonarr-api_key";
            };
            base_url = "http://localhost:8989";
            instance_name = "main";
          }
        ];
      };
    };
  };
}

