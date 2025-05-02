{ ... }: {

  # Common config for all desktops

  imports = [ ../default.nix ];

  networking.networkmanager.insertNameservers = [ "1.1.1.1" "8.8.8.8" ];

  def.boot = {
    enable = true;
    latestGenerationMax = 20;
  };

  def.sound.enable = true;

  def.locale.enable = true;
}
