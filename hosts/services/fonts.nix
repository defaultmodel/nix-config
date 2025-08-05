{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    nerd-fonts.ubuntu
    nerd-fonts.ubuntu-sans
    noto-fonts-color-emoji
    nerd-fonts.ubuntu-mono
    atkinson-hyperlegible-next
    atkinson-hyperlegible-mono
  ];

  fonts.fontconfig = {
    enable = true;
    defaultFonts = {
      serif = [ "atkinson-hyperlegible" ];
      sansSerif = [ "nerf-font-ubuntu-sans" ];
      emoji = [ "noto-fonts-color-emoji" ];
      monospace = [ "nerd-fonts-ubuntu-mono" ];
    };
  };
}
