{ config, ... }:
let mediaDir = "/mnt/shares/data";
in {

  imports = [
    ../default.nix # Common config for all local servers
    ./disk-config.nix

    ./nas.nix
    ./media.nix
  ];

  networking = {
    hostName = "rhodes";
    interfaces.ens18.ipv4.addresses = [{
      address = "192.168.1.30";
      prefixLength = 24;
    }];
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
  def.reverse-proxy.enable = true;

  ### NAVIDROME ###
  def.navidrome = {
    enable = true;
    musicFolder = "${mediaDir}/media/music";
  };

  ### VAULTWARDEN ###
  def.vaultwarden.enable = true;

  ### IMMICH ###
  def.immich = {
    enable = true;
    photoFolder = "${mediaDir}/media/photos";
  };

  ### PAPERLESS ###
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
