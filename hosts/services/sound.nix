{ ... }:
{
  # Disable competing service
  services.pulseaudio.enable = false;
  # Hands out realtime scheduling priority to user processes
  security.rtkit.enable = true;

  services.pipewire = {
    enable = true;
    audio.enable = true; # Make pipewire the default sound server

    # Clients
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # technically not required, as it only serves as a wrapper around environment variables
    #jack.enable = true;

    # Session manager, It detects new streams and connects them to the appropriate output devices or applications
    # Wireplumber is the recommended session manager for pipewire
    wireplumber.enable = true;

    # Fix crackling
    extraConfig.pipewire = {
      "properties" = {
        "default.clock.allowed-rates" = [ 44100 48000 96000 ];
        "default.clock.quantum" = 256;
        "default.clock.min-quantum" = 256;
        "default.clock.max-quantum" = 256;
      };
    };
  };
}
