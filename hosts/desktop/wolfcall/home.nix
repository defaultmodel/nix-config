{ pkgs, ... }: {

  imports = [
    ./home/alacritty.nix
    ./home/firefox.nix
    ./home/helix.nix
    ./home/starship.nix
    ./home/git.nix
  ];

  home.username = "defaultmodel";
  home.homeDirectory = "/home/defaultmodel";

  # Packages that should be installed to the user profile.
  home.packages = with pkgs; [
    heroic # Game launcher
    moonlight-qt # Game Streaming
  ];

  # Let home Manager install and manage itself.
  programs.home-manager.enable = true;
  home.stateVersion = "24.11";
}
