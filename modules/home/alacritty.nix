{ config, lib, ... }:
with lib;
let
  # Shorter name to access a final setting
  # All modules are under the custom attribute "def"
  cfg = config.def.alacritty;
in
{
  options.def.alacritty = { enable = mkEnableOption "Alacritty terminal"; };

  config = mkIf cfg.enable {
    programs.alacritty = {
      enable = true;
      settings = {
        window = {
          opacity = 0.95;
          padding = {
            x = 5;
            y = 5;
          };
          decorations = "None";
        };
        font = {
          normal = { family = "Comic Code"; };
          size = 14.0;
        };
        env = { TERM = "xterm-256color"; };
        general = { live_config_reload = true; };
      };
    };
  };
}
