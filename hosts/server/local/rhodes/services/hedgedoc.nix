{ config, lib, ... }:
let
  srv = config.services.hedgedoc;
  certloc = "/var/lib/acme/defaultmodel.eu.org";
  url = "hedgedoc.defaultmodel.eu.org";
in {
  services.hedgedoc = {
    enable = true;
    settings = {
      host = "0.0.0.0";
      port = 3028;
      domain = url;

      protocolUseSSL = true;

      allowFreeURL = true;
      allowAnonymous = false;
      allowAnonymousEdits = true;
    };
  };

  systemd.services.hedgedoc = {
    serviceConfig = let workDir = "/var/lib/hedgedoc";
    in {
      WorkingDirectory = lib.mkForce workDir;
      StateDirectory = lib.mkForce [ "hedgedoc" "hedgedoc/uploads" ];

      # Hardening
      CapabilityBoundingSet = "";
      LockPersonality = true;
      NoNewPrivileges = true;
      PrivateDevices = true;
      PrivateMounts = true;
      PrivateTmp = true;
      PrivateUsers = true;
      ProtectClock = true;
      ProtectHome = true;
      ProtectHostname = true;
      ProtectKernelLogs = true;
      ProtectKernelModules = true;
      ProtectKernelTunables = true;
      ProtectProc = "invisible";
      ProtectSystem = "strict";
      ReadWritePaths = [ workDir ];
      RemoveIPC = true;
      RestrictSUIDSGID = true;
      UMask = "0007";
      RestrictAddressFamilies = [ "AF_UNIX AF_INET AF_INET6" ];
      SystemCallArchitectures = "native";
    };
  };

  ### REVERSE PROXY ###
  services.caddy = {
    virtualHosts.${url}.extraConfig = ''
      reverse_proxy http://localhost:${toString srv.settings.port}
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
  def.homepage.categories."Other"."Hedgedoc" = {
    icon = "hedgedoc.png";
    description = "Collaborative note taking";
    href = "https://${url}";
  };
}

