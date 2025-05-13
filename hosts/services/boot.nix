{ ... }:
let
  maxGenerations = 10;
in
{
  boot.loader.grub = {
    enable = true;
    efiSupport = true;
    efiInstallAsRemovable = true;
    device = "nodev"; # Mandatory for UEFI installations
    useOSProber = true;
    configurationLimit = maxGenerations;
  };
}
