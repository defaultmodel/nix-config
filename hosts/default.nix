{ lib, ... }: {

  # This is imported by all hosts

  imports = [
    ./services/boot.nix
    ./services/default-packages.nix
    ./services/fonts.nix
    ./services/locale.nix
    ./services/sound.nix
    ./services/ssh-hardening.nix
    ./services/storage-optimization.nix
    ./services/system-hardening.nix
  ];

  # give me that negetive karma
  nixpkgs.config.allowUnfree = true;

  services.tailscale.enable = true;

  # Eiffel Tower FTW !!
  time.timeZone = lib.mkDefault "Europe/Paris";

  # Experimental my ass
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  system.stateVersion = "24.11";
}
