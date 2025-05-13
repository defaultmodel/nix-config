{ pkgs, ... }:
{
  programs.steam = {
    enable = true;
    remotePlay.openFirewall =
      true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall =
      true; # Open ports in the firewall for Source Dedicated Server
    gamescopeSession.enable =
      true; # Microcompositor used to provide an isolated compositor that is tailored towards gaming
    extraCompatPackages = with pkgs;
      [ proton-ge-bin ]; # GloriousEggroll's Proton-GE
  };
}
