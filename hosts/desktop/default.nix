{ ... }: {

  # Common config for all desktops

  imports = [ ../default.nix ./services/boot.nix ./services/sound.nix ];
}
