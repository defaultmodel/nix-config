{ config, lib, ... }:
with lib;
let
  # Shorter name to access a final setting
  # All modules are under the custom attribute "def"
  cfg = config.def.ssh-hardening;
in {
  options.def.ssh-hardening = {
    enable = mkEnableOption "Sane defaults for SSH";
  };

  config = mkIf cfg.enable {
    services.openssh = {
      allowSFTP = false;
      # https://infosec.mozilla.org/guidelines/openssh#modern-openssh-67
      settings = {
        PermitRootLogin =
          "yes"; # deviation from mozilla's guidelines because root is my primary user on the servers
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = true;

        KexAlgorithms = [
          "curve25519-sha256"
          "curve25519-sha256@libssh.org"
          "ecdh-sha2-nistp521"
          "ecdh-sha2-nistp384"
          "ecdh-sha2-nistp256"
          "diffie-hellman-group-exchange-sha256"
        ];
        Ciphers = [
          "chacha20-poly1305@openssh.com"
          "aes256-gcm@openssh.com"
          "aes128-gcm@openssh.com"
          "aes256-ctr"
          "aes192-ctr"
          "aes128-ctr"
        ];
        Macs = [
          "hmac-sha2-512-etm@openssh.com"
          "hmac-sha2-256-etm@openssh.com"
          "umac-128-etm@openssh.com"
          "hmac-sha2-512"
          "hmac-sha2-256"
          "umac-128@openssh.com"
        ];
      };
      extraConfig = ''
        ClientAliveCountMax 0
        ClientAliveInterval 300

        AllowTcpForwarding no
        AllowAgentForwarding no
        MaxAuthTries 10
        MaxSessions 2
        TCPKeepAlive no
      '';
    };
  };
}
