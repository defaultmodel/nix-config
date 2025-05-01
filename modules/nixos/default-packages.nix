{ pkgs, config, lib, ... }:
with lib;
let
  # Shorter name to access a final setting
  # All modules are under the custom attribute "def"
  cfg = config.def.default-packages;
in {
  options.def.default-packages = {
    enable = mkEnableOption "Install some useful packages";
  };

  config = mkIf cfg.enable {
    # fuck nano all my homies use helix
    environment.variables.EDITOR = "hx";

    environment.systemPackages = with pkgs; [
      # archives
      zip
      xz
      unzip
      p7zip

      # utils
      bat # better cat
      ripgrep # better grep
      jq # JSON handling
      eza # better ls
      fzf # fuzzy finder
      sad # better sed

      # misc
      file
      which
      tree
      tldr
      gnupg
      git
      git-filter-repo
      lazygit

      # DNS
      dig
      drill
      doggo

      # Monitoring
      btop # replacement of htop/nmon
      iotop # io monitoring
      iftop # network monitoring

      # Editor
      helix

      # system tools
      lm_sensors # for `sensors` command
      pciutils # lspci
      usbutils # lsusb
    ];
  };
}
