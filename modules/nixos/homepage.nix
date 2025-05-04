{ config, lib, ... }:
with lib;
let
  # Shorter name to access a final setting
  # All modules are under the custom attribute "def"
  cfg = config.def.homepage;
  srv = config.services.homepage-dashboard;
  certloc = "/var/lib/acme/defaultmodel.eu.org";
in {
  options.def.homepage = { enable = mkEnableOption "Homepage"; };

  config = mkIf cfg.enable {
    services.homepage-dashboard = {
      enable = true;
      settings = {
        title = "Rhodes";
        favicon = "https://huggingface.co/favicon.ico";
        headerStyle = "clean";
        layout = {
          media = {
            style = "row";
            columns = 3;
          };
          infra = {
            style = "row";
            columns = 4;
          };
          machines = {
            style = "row";
            columns = 4;
          };
        };
      };
    };

    services.caddy = {
      virtualHosts."home.defaultmodel.eu.org".extraConfig = ''
        reverse_proxy http://localhost:${toString srv.port}
        tls ${certloc}/cert.pem ${certloc}/key.pem {
          protocols tls1.3
        }
      '';
    };
  };
}
