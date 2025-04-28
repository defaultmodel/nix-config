{ lib, ... }: {

  # This is imported by all hosts

  imports = [
    ../modules/nixos/default.nix # Allow all hosts to import nixos modules
  ];

  # give me that negetive karma
  nixpkgs.config.allowUnfree = true;

  # Eiffel Tower FTW !!
  time.timeZone = lib.mkDefault "Europe/Paris";

  # Make every machine aware of each others
  networking.hosts = {
    "192.168.1.2" = [ "ithaca" ];
    "192.168.1.10" = [ "wolfcall" ];
    "192.168.1.11" = [ "calligraphite" ];
    "192.168.1.20" = [ "nas" ];
    "192.168.1.30" = [ "rhodes" ];
  };

  def.default-packages.enable = true;

  def.ssh-hardening.enable = true;

  def.system-hardening.enable = true;

  def.storage-optimization.enable = true;

  system.stateVersion = "24.11";
}
