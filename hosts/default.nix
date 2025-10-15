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

  # Make my machines aware of each other
  networking.hosts = {
    "152.70.21.44" = [ "lemnos" "oracle1" ];
    "141.144.227.227" = [ "agios" "oracle2" ];
  };

  # give me that negative karma
  nixpkgs.config.allowUnfree = true;

  # Eiffel Tower FTW !!
  time.timeZone = lib.mkDefault "Europe/Paris";

  # Experimental my ass
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  system.stateVersion = "24.11";
}
