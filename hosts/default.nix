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

  # Eiffel Tower FTW !!
  time.timeZone = lib.mkDefault "Europe/Paris";

  # Experimental my ass
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Make every machine aware of each others
  networking.hosts = {
    "192.168.1.2" = [ "ithaca" ];
    "192.168.1.10" = [ "wolfcall" ];
    "192.168.1.11" = [ "calligraphite" ];
    "192.168.1.20" = [ "nas" ];
    "192.168.1.30" = [ "rhodes" ];
  };

  system.stateVersion = "24.11";
}
