{ lib, ... }: {

  # This is imported by all hosts

  imports = [
    ./services/default-packages.nix
    ./services/fonts.nix
    ./services/locale.nix
    ./services/ssh-hardening.nix
    ./services/storage-optimization.nix
    ./services/system-hardening.nix
  ];

  # Is there a time when I don't want this ?
  boot.kernel.sysctl."net.ipv4.ip_forward" = lib.mkDefault 1;

  # Experimental my ass
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  system.stateVersion = "24.11";
}
