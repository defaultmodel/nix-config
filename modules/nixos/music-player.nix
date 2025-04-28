{ pkgs, config, lib, ... }:
with lib;
let
  # Shorter name to access a final setting
  # All modules are under the custom attribute "def"
  cfg = config.def.music-player;
in {
  options.def.music-player = { enable = mkEnableOption "Music player"; };
  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [ supersonic-wayland ];
  };
}
