{ pkgs, config, lib, ... }:
with lib;
let
  # Shorter name to access a final setting
  # All modules are under the custom attribute "def"
  cfg = config.def.coolercontrol;
in {
  options.def.coolercontrol = { enable = mkEnableOption "Coolercontro GUI"; };
  config = mkIf cfg.enable {
    # NVIDIA support is already baked in if nvidia drivers are installed
    # See default value https://mynixos.com/nixpkgs/option/programs.coolercontrol.nvidiaSupport
    programs.coolercontrol.enable = true;

    environment.systemPackages = with pkgs; [ liquidctl ];

    # Enable many sensors (try running "sensors" now and see the
    # difference). Module names were found by running "sudo sensors-detect".
    boot.kernelModules = [ "coretemp" "nct6775" ];
  };
}
