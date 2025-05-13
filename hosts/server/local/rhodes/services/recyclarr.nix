{ config, ... }:
let
  srv = config.services.recyclarr;
in
{
  age.secrets.radarr-api-key = {
    file = ../../../../../secrets/radarr-api-key.age;
    owner = srv.user;
  };

  age.secrets.sonarr-api-key = {
    file = ../../../../../secrets/sonarr-api-key.age;
    owner = srv.user;
  };

  services.recyclarr = {
    enable = true;
    configuration = {
      radarr = [{
        api_key = {
          _secret = "/run/credentials/recyclarr.service/radarr-api_key";
        };
        base_url = "http://localhost:7878";
        instance_name = "main";
      }];
      sonarr = [{
        api_key = {
          _secret = "/run/credentials/recyclarr.service/sonarr-api_key";
        };
        base_url = "http://localhost:8989";
        instance_name = "main";
      }];
    };
  };

  systemd.services.recyclarr.serviceConfig.LoadCredential = [
    "radarr-api_key:${config.age.secrets.radarr-api-key.path}"
    "sonarr-api_key:${config.age.secrets.sonarr-api-key.path}"
  ];
}

