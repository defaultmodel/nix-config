{ config, ... }:
let
  srv = config.services.authelia;
  certloc = "/var/lib/acme/defaultmodel.eu.org";
  url = "sso.defaultmodel.eu.org";
in {
  age.secrets.authelia-main-storageEncryptionKey = {
    file = ../../../../../secrets/authelia-main-storageEncryptionKey.age;
    owner = "authelia-main";
  };

  age.secrets.authelia-main-jwtSecret = {
    file = ../../../../../secrets/authelia-main-jwtSecret.age;
    owner = "authelia-main";
  };

  services.authelia.instances = {
    main = {
      enable = true;
      user = "authelia-main";
      group = "authelia-main";
      secrets.storageEncryptionKeyFile =
        "/etc/authelia/storageEncryptionKeyFile";
      secrets.jwtSecretFile = "/etc/authelia/jwtSecretFile";
      settings = {
        theme = "light";
        default_2fa_method = "totp";
        server.disable_healthcheck = true;
      };
    };
  };
}
