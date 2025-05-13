{ pkgs, ... }:
{
  # NVIDIA support is already baked in if nvidia drivers are installed
  # See default value https://mynixos.com/nixpkgs/option/programs.coolercontrol.nvidiaSupport
  programs.coolercontrol.enable = true;

  environment.systemPackages = with pkgs; [ liquidctl ];

  # Enable many sensors (try running "sensors" now and see the
  # difference). Module names were found by running "sudo sensors-detect".
  boot.kernelModules = [ "coretemp" "nct6775" ];
}
