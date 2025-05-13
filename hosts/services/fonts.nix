{ pkgs, ... }:
{
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
}
