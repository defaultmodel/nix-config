{ config, lib, ... }:
with lib;
let
  # Shorter name to access a final setting
  # All modules are under the custom attribute "def"
  cfg = config.def.storage-optimization;
in {
  options.def.storage-optimization = {
    enable = mkEnableOption "Nix garbage collector & nix store optimization";
  };

  config = mkIf cfg.enable {
    nix.optimise = {
      automatic = true;
      dates = [ "05:00" ];
      persistent = true; # Catchup optimization if the last timer was missed
      randomizedDelaySec =
        "1800"; # 30 min # Randomize timer as to not run gc and optimize at the same time
    };

    nix.gc = {
      automatic = true;
      dates = "05:00";
      persistent = true; # Catchup optimization if the last timer was missed
      randomizedDelaySec =
        "1800"; # 30 min # Randomize timer as to not run gc and optimize at the same time
    };
  };
}
