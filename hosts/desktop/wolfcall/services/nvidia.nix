{ pkgs, config, ... }: {
  # Disables GSP which is a RISC-V processor included with recent (Turing and newer) NVIDIA cards.
  # It is responsible for doing things that were previously handled by driver itself (for example power management).
  # In theory it should improve performance but due to some bugs it is currently slower for some people.
  # When you disable it driver doesn’t use it and handles things by itself like before
  # Forcefully enabled in the open-source drivers
  # boot.kernelParams = [ "nvidia.NVreg_EnableGpuFirmware=0" ];

  # CUDA support
  environment.systemPackages = with pkgs; [ cudatoolkit ];

  hardware = {
    # Enable OpenGL
    graphics.enable = true;
    # Provides access to graphics acceleration to let the system offload video encoding/decoding to your GPU
    # VA-API implementation that uses NVDEC as a backend
    graphics.extraPackages = with pkgs; [ nvidia-vaapi-driver ];
  };

  # Load nvidia driver for Xorg and Wayland
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    # Modesetting is required.
    # Sets tthe display resolution and depth in the kernel space rather than user space. 
    modesetting.enable = true;

    # Nvidia power management. Experimental, and can cause sleep/suspend to fail.
    # Enable this if you have graphical corruption issues or application crashes after waking
    # up from sleep. This fixes it by saving the entire VRAM memory to /tmp/ instead
    # of just the bare essentials.
    powerManagement.enable = true;

    # Fine-grained power management. Turns off GPU when not in use.
    # Experimental and only works on modern Nvidia GPUs (Turing or newer).
    powerManagement.finegrained = false;

    # Use the NVidia open source kernel module (not to be confused with the
    # independent third-party "nouveau" open source driver).
    # An important note to take is that the option hardware.nvidia.open should only be set to false 
    # If you have a GPU with an older architecture than Turing (older than the RTX 20-Series).
    open = true;

    # Enable the Nvidia settings menu,
    # accessible via `nvidia-settings`.
    nvidiaSettings = true;

    # Optionally, you may need to select the appropriate driver version for your specific GPU.
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };
}
