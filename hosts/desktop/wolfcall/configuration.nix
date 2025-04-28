{ pkgs, ... }: {
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

  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      # Bind Ctrl-Z to fg for helix
      # https://github.com/helix-editor/helix/wiki/Recipes#fish
      bind \cz 'fg 2>/dev/null; commandline -f repaint'
    '';
  };

  fileSystems."/home/defaultmodel/Music" = {
    device = "//nas/music";
    fsType = "cifs";
    options = [ "x-systemd.automount" "noauto" ];
  };

  # Plasma 6
  services.xserver.enable = true;
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;
  services.displayManager.sddm.wayland.enable = true;

  environment.systemPackages = with pkgs; [ colmena equibop bitwarden-desktop ];

  def.nvidia.enable = true;

  def.steam.enable = true;

  def.obs-studio = {
    enable = true;
    enableNVENC = true;
  };

  def.fonts.enable = true;

  def.coolercontrol.enable = true;

  def.music-player.enable = true;
}
