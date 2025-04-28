{ pkgs, config, lib, ... }:
with lib;
let
  # Shorter name to access a final setting
  # All modules are under the custom attribute "def"
  cfg = config.def.fonts;
in {
  options.def.fonts = { enable = mkEnableOption "Set system fonts"; };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      nerd-fonts.ubuntu
      nerd-fonts.ubuntu-sans
      noto-fonts-color-emoji
      nerd-fonts.ubuntu-mono
    ];

    fonts.fontconfig = {
      enable = true;
      defaultFonts = {
        serif = [ "nerd-font-ubuntu" ];
        sansSerif = [ "nerf-font-ubuntu-sans" ];
        emoji = [ "noto-fonts-color-emoji" ];
        monospace = [ "nerd-fonts-ubuntu-mono" ];
      };
    };
  };
}
