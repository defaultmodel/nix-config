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
    tor-browser
    ### nix-stuff
    colmena
    ragenix
    ### Dev-tools
    vscode
    nodejs
    pnpm
    godot
    go
    gotools
    ### Gaming
    lutris
    wineWowPackages.waylandFull
    ### Utils
    wayland-utils # Wayland utilities
    wl-clipboard # Command-line copy/paste utilities for Wayland
    ### KDE Applications
    kdePackages.discover # Optional: Install if you use Flatpak or fwupd firmware update sevice
    kdePackages.kcalc # Calculator
    kdePackages.kcharselect # Tool to select and copy special characters from all installed fonts
    kdePackages.kcolorchooser # A small utility to select a color
    kdePackages.kolourpaint # Easy-to-use paint program
    kdePackages.ksystemlog # KDE SystemLog Application
    kdePackages.sddm-kcm # Configuration module for SDDM
    kdePackages.isoimagewriter # Optional: Program to write hybrid ISO files onto USB disks
    kdePackages.partitionmanager # Optional Manage the disk devices, partitions and file systems on your computer
    ### Office
    libreoffice-qt
    hunspell # spell checking
    hunspellDicts.en-us
    hunspellDicts.fr-any
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
    docker.enable = true;
    podman = {
      enable = true;
      # Required for containers under podman-compose to be able to talk to each other.
      defaultNetwork.settings.dns_enabled = true;
    };
  };
}
