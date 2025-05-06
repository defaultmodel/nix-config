{ config, ... }:
let mediaDir = "/mnt/shares/data";
in {

  imports = [
    ../default.nix # Common config for all local servers
    ./disk-config.nix
    ./hardware-configuration.nix

    ./nas.nix
    ./media.nix
  ];

  networking = {
    hostName = "rhodes";
    interfaces.enp2s0.ipv4.addresses = [{
      address = "192.168.1.30";
      prefixLength = 24;
    }];
    defaultGateway = {
      address = "192.168.1.1";
      interface = "enp2s0";
    };
  };

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 80 443 ];
  };

  age.secrets.smb-credentials = {
    file = ../../../../secrets/smb-credentials.age;
    mode = "440";
  };

  def.adguardhome = {
    enable = false;
    password = "$2a$15$0kVcvZCskZQvHt.qfi.K/O2d1Iah/8V8S7gGaYXaKZxsQAHdU5nI.";
  };

  ### REVERSE-PROXY ###
  age.secrets.cloudflare-dns-api-key = {
    file = ../../../../secrets/cloudflare-dns-api-key.age;
    mode = "400";
    owner = "reverse-proxy";
  };

  def.reverse-proxy = {
    enable = true;
    cloudflareKeyFile = config.age.secrets.cloudflare-dns-api-key.path;
  };

  ### RSS ###
  age.secrets.rss-credentials = {
    file = ../../../../secrets/rss-credentials.age;
    mode = "400";
    owner = "miniflux";
  };

  def.rss = {
    enable = true;
    authFile = config.age.secrets.rss-credentials.path;
  };

  ### VAULTWARDEN ###
  def.vaultwarden.enable = true;

  ### IMMICH ###
  def.immich = {
    enable = true;
    photoFolder = "${mediaDir}/media/photos";
  };

  ## PAPERLESS ###
  age.secrets.paperless-admin-password = {
    file = ../../../../secrets/paperless-admin-password.age;
    mode = "440";
    owner = "paperless";
    group = "paperless";
  };

  def.paperless = {
    enable = true;
    passwordFile = config.age.secrets.paperless-admin-password.path;
    documentFolder = "${mediaDir}/media/documents";
    consumeFolder = "${config.services.paperless.dataDir}/consume";
  };
}
