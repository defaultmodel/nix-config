{ config, ... }:
let srv = config.services.recyclarr;
in {
  age.secrets.radarr-api-key-plain = {
    file = ../../../../../secrets/radarr-api-key-plain.age;
    mode = "440";
    group = srv.group;
  };

  age.secrets.sonarr-api-key-plain = {
    file = ../../../../../secrets/sonarr-api-key-plain.age;
    mode = "440";
    group = srv.group;
  };

  services.recyclarr = {
    enable = true;
    user = "recyclarr";
    group = "media";
    schedule = "daily";

    configuration = {
      radarr = {
        main-radarr = {
          api_key = {
            _secret = "/run/credentials/recyclarr.service/radarr-api_key";
          };
          base_url = "http://localhost:7878";
          quality_definition = { type = "movie"; };
          include = [
            # Shows
            { template = "radarr-quality-definition-movie"; }
            {
              template = "radarr-quality-profile-hd-remux-web-french-multi-vf";
            }
            {
              template = "radarr-custom-formats-hd-remux-web-french-multi-vf";
            }
            # Anime
            # {template = "radarr-quality-definition-movie" ;} # Shows take priority
            { template = "radarr-quality-profile-anime"; }
            { template = "radarr-custom-formats-anime"; }
          ];
          custom_formats = [
            {
              trash_ids = [
                "2c29a39a4fdfd6d258799bc4c09731b9" # VFF
                "7ae924ee9b2f39df3283c6c0beb8a2aa" # VOF
                "b6816a0e1d4b64bf3550ad3b74b009b6" # VFI
                "34789ec3caa819f087e23bbf9999daf7" # VF2
                "802dd70b856c423a9b0cb7f34ac42be1" # VOQ
              ];
              assign_scores_to = [{
                name = "FR-REMUX-MULTi-VF-HD";
                score = 101;
              }];
            }
            {
              trash_ids = [
                "0f12c086e289cf966fa5948eac571f44" # Hybrid
                "570bc9ebecd92723d2d21500f4be314c" # Remaster
                "eca37840c13c6ef2dd0262b141a5482f" # 4K Remaster
                "e0c07d59beb37348e975a930d5e50319" # Criterion Collection
                "9d27d9d2181838f76dee150882bdc58c" # Masters of Cinema
                "db9b4c4b53d312a3ca5f1378f6440fc9" # Vinegar Syndrome
                "957d0f44b592285f26449575e8b1167e" # Special Edition
                "eecf3a857724171f968a66cb5719e152" # IMAX
                "9f6cbff8cfe4ebbc1bde14c7b7bec0de" # IMAX Enhanced
              ];
              assign_scores_to = [{
                name = "FR-REMUX-MULTi-VF-HD";
                score = 51;
              }];
            }
          ];
        };
      };
      sonarr = {
        main-sonarr = {
          api_key = {
            _secret = "/run/credentials/recyclarr.service/sonarr-api_key";
          };
          base_url = "http://localhost:8989";
          quality_definition = { type = "series"; };
          include = [
            # Shows
            { template = "sonarr-quality-definition-series"; }
            {
              template =
                "sonarr-v4-quality-profile-bluray-web-1080p-french-multi-vf";
            }
            {
              template =
                "sonarr-v4-custom-formats-bluray-web-1080p-french-multi-vf";
            }
            # Anime
            # {template = "sonarr-quality-definition-anime" ;} # Shows take priority
            { template = "sonarr-v4-quality-profile-1080p-french-anime-multi"; }
            { template = "sonarr-v4-custom-formats-1080p-french-anime-multi"; }
          ];
          custom_formats = [
            {
              trash_ids = [
                "2c29a39a4fdfd6d258799bc4c09731b9" # VFF
                "7ae924ee9b2f39df3283c6c0beb8a2aa" # VOF
                "b6816a0e1d4b64bf3550ad3b74b009b6" # VFI
                "34789ec3caa819f087e23bbf9999daf7" # VF2
                "802dd70b856c423a9b0cb7f34ac42be1" # VOQ
              ];
              assign_scores_to = [{
                name = "FR-MULTi-VF-WEB-1080p";
                score = 101;
              }];
            }
            {
              trash_ids = [
                "44b6c964dad997577d793fd004a39224" # FR Anime FanSub
              ];
              assign_scores_to = [{
                name = "FR-ANIME-MULTi";
                score = 101;
              }];
            }
          ];
        };
      };
    };
  };

  systemd.services.recyclarr.serviceConfig.LoadCredential = [
    "radarr-api_key:${config.age.secrets.radarr-api-key-plain.path}"
    "sonarr-api_key:${config.age.secrets.sonarr-api-key-plain.path}"
  ];
}

