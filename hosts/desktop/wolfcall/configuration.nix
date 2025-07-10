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
    ./services/audit.nix
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
    equibop
    bitwarden-desktop
    signal-desktop
    qbittorrent
    borgbackup
    vlc
    obsidian # Note taking
    ### nix-stuff
    colmena
    ragenix
    ### Dev-tools
    nodejs
    pnpm
    ### Gaming
    lutris
    wineWowPackages.waylandFull
    ### Utils
    wayland-utils # Wayland utilities
    wl-clipboard # Command-line copy/paste utilities for Wayland

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

  programs.xwayland.enable = true;

  virtualisation = {
    containers.enable = true;
    podman = {
      enable = true;
      # Required for containers under podman-compose to be able to talk to each other.
      defaultNetwork.settings.dns_enabled = true;
    };
  };
}
