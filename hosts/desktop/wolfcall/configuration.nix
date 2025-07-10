{ pkgs, ... }: {

  imports = [
    ../default.nix
    ./disk-config.nix

    ./services/bluetooth.nix
    ./services/coolercontrol.nix
    ./services/nvidia.nix
    ./services/obs-studio.nix
    ./services/steam.nix
    ./services/virtualisation.nix
  ];

  networking = {
    hostName = "wolfcall";
    networkmanager.enable =
      true; # Easiest to use and most distros use this by default.
  };

  users.users.defaultmodel = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ]; # Enable ‘sudo’ for the user.
    shell = pkgs.fish;
  };

  environment.systemPackages = with pkgs; [
    colmena
    equibop
    bitwarden-desktop
    signal-desktop
    qbittorrent
    ragenix
    borgbackup
    vlc
    obsidian # Note taking
    pnpm
    ### GAMING
    lutris
    wineWowPackages.waylandFull
  ];

  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      # Bind Ctrl-Z to fg for helix
      # https://github.com/helix-editor/helix/wiki/Recipes#fish
      bind \cz 'fg 2>/dev/null; commandline -f repaint'
    '';
  };

  # Plasma 6
  services.xserver.enable = true;
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;
  services.displayManager.sddm.wayland.enable = true;

  virtualisation = {
    containers.enable = true;
    podman = {
      enable = true;
      # Required for containers under podman-compose to be able to talk to each other.
      defaultNetwork.settings.dns_enabled = true;
    };
  };
}
