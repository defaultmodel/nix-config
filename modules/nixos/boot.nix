{ config, lib, ... }:
with lib;
let
  # Shorter name to access a final setting
  # All modules are under the custom attribute "def"
  cfg = config.def.boot;
in {
  options.def.boot = {
    enable = mkEnableOption "Make GRUB the bootloader";
    osProber = mkOption {
      default = true;
      type = types.bool;
      description = "Whether to enable the discovery of other OS";
    };
    latestGenerationMax = mkOption {
      default = 10;
      type = types.int;
      description = "Maximum number of latest generations in the boot menu";
    };
  };

  config = mkIf cfg.enable {
    boot.loader.grub = {
      enable = true;
      efiSupport = true;
      efiInstallAsRemovable = true;
      device = "nodev"; # Mandatory for UEFI installations
      useOSProber = true;
      configurationLimit = cfg.latestGenerationMax;
    };
  };
}
