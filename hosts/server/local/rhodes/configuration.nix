{ config, ... }:
let mediaDir = "/data";
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
    interfaces.bond0.ipv4.addresses = [{
      address = "192.168.1.30";
      prefixLength = 24;
    }];
    defaultGateway = {
      address = "192.168.1.1";
      interface = "bond0";
    };
    bonds = {
      bond0 = {
        interfaces = [ "enp2s0" "enp3s0" ];
        driverOptions = {
          miimon = "100"; # Monitor MII link every 100ms
          mode = "802.3ad";
          xmit_hash_policy = "layer3+4"; # IP and TCP/UDP hash
        };
      };
    };
  };

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 80 443 ];
  };

  # Ouch !! 0.2016€ / kWh 
  def.low-power.enable = true;

  age.secrets.smb-credentials = {
    file = ../../../../secrets/smb-credentials.age;
    mode = "440";
  };
  def.adguardhome = {
    enable = true;
    password = "$2a$15$0kVcvZCskZQvHt.qfi.K/O2d1Iah/8V8S7gGaYXaKZxsQAHdU5nI.";
  };

  def.homepage.enable = true;

  ### REVERSE-PROXY ###
  age.secrets.dns-provider-api-key = {
    file = ../../../../secrets/dns-provider-api-key.age;
    mode = "400";
    owner = "reverse-proxy";
  };
  def.reverse-proxy = {
    enable = true;
    DNSProviderApiKeyFile = config.age.secrets.dns-provider-api-key.path;
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
  age.secrets.vaultwarden-admin-token = {
    file = ../../../../secrets/vaultwarden-admin-token.age;
    mode = "440";
    owner = "vaultwarden";
    group = "vaultwarden";
  };
  def.vaultwarden = {
    enable = true;
    adminTokenFile = config.age.secrets.vaultwarden-admin-token.path;
  };

  ### IMMICH ###
  def.immich = {
    enable = true;
    photoFolder = "${mediaDir}/photos";
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
    documentFolder = "${mediaDir}/documents";
    consumeFolder = "${config.services.paperless.dataDir}/consume";
  };

  ### BACKUPS ###
  age.secrets.hetzner-backup-passphrase = {
    file = ../../../../secrets/hetzner-backup-passphrase.age;
  };
  def.backup = {
    enable = true;
    pgBackup = true;
    pgBackupDir = "/data/backups/";
    jobs = {
      hetzner = {
        paths = [
          "/var/lib"
          "/etc/ssh"
          "/data/photos"
          "/data/documents"
          "/data/backups"
          "/data/media/music"
        ];
        exclude = [ "/var/lib/docker" "/var/lib/systemd" ];
        repo = "u414837-sub1@u414837.your-storagebox.de:/home/borg-repo";
        repoPassphraseFile = config.age.secrets.hetzner-backup-passphrase.path;
        repoSSHKeyFile = "/etc/ssh/ssh_host_ed25519_key";
      };
    };
  };
}
