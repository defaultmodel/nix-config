{ pkgs, ... }: {

  imports = [ ../../../modules/home/default.nix ];

  home.username = "defaultmodel";
  home.homeDirectory = "/home/defaultmodel";

  # Packages that should be installed to the user profile.
  home.packages = with pkgs; [
    heroic # Game launcher
    moonlight-qt # Game Streaming
  ];

  programs.git = {
    enable = true;
    userName = "Hilan Meyran";
    userEmail = "hilanmeyran@protonmail.com";
  };

  def.helix = {
    enable = true;
    defaultEditor = true;
  };
  def.firefox = {
    enable = true;
    verticalTabs = true;
  };
  def.starship = {
    enable = true;
    fishIntegration = true;
  };
  def.alacritty.enable = true;

  # Let home Manager install and manage itself.
  programs.home-manager.enable = true;
  home.stateVersion = "24.11";
}
