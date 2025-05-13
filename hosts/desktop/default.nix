{ ... }: {

  # Common config for all desktops

  imports = [
    ../default.nix

    ./services/bluetooth.nix
    ./services/coolercontrol.nix
    ./services/nvidia.nix
    ./services/obs-studio.nix
    ./services/steam.nix
  ];
}
