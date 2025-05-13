{ ... }:
{
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
}
