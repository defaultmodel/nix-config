{ config, pkgs, lib, ... }:
with lib;
let
  # Shorter name to access a final setting
  # All modules are under the custom attribute "def"
  cfg = config.def.obs-studio;
in {
  options.def.obs-studio = {
    enable = mkEnableOption "OBS-Studio program";
    enableNVENC = mkEnableOption "Enable NVENC encoding";
  };

  config = mkIf cfg.enable {
    programs.obs-studio = {
      enable = true;
      enableVirtualCamera = true;
      # This will compile obs-studio from source (20-40min) to enable CUDA support
      # Which will allow for NVENC support to be detected
      # This may be needed because of https://github.com/NixOS/nixpkgs/pull/383402 *shrugs*
      package = if cfg.enableNVENC then
        pkgs.obs-studio.override { cudaSupport = true; }
      else
        pkgs.obs-studio;
    };
  };
}

