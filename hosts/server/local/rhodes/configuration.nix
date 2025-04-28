{ config, ... }: {

  imports = [
    ../default.nix # Common config for all local servers
    ./disk-config.nix

    ./nas.nix
    ./media.nix
  ];

  networking.hostName = "rhodes";

  age.secrets.smb-credentials = {
    file = ../../../../secrets/smb-credentials.age;
    mode = "440";
  };

  def.adguardhome = {
    enable = true;
    password = "$2a$15$0kVcvZCskZQvHt.qfi.K/O2d1Iah/8V8S7gGaYXaKZxsQAHdU5nI.";
  };

  ### NAVIDROME ###
  def.navidrome = {
    enable = true;
    musicFolder = "/mnt/shares/data/media/music";
  };

  ### VAULTWARDEN ###
  def.vaultwarden.enable = true;

  ### IMMICH ###
  def.immich = {
    enable = true;
    photoFolder = "/var/lib/immich/media";
  };

  fileSystems."${config.def.immich.photoFolder}" = {
    device = "//nas/photos";
    fsType = "cifs";
    options = [
      "credentials=${config.age.secrets.smb-credentials.path}"
      "uid=immich"
      "gid=immich"
      "noserverino"
      "nofail"
    ];
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
    documentFolder = "${config.services.paperless.dataDir}/media";
    consumeFolder = "${config.services.paperless.dataDir}/consume";
  };

  fileSystems."${config.def.paperless.documentFolder}" = {
    device = "//nas/documents";
    fsType = "cifs";
    options = [
      "credentials=${config.age.secrets.smb-credentials.path}"
      "uid=paperless"
      "gid=paperless"
      "noserverino"
      "nofail"
    ];
  };

  fileSystems."${config.def.paperless.consumeFolder}" = {
    device = "//nas/documents-consume";
    fsType = "cifs";
    options = [
      "credentials=${config.age.secrets.smb-credentials.path}"
      "uid=paperless"
      "gid=paperless"
      "noserverino"
      "nofail"
    ];
  };
}
