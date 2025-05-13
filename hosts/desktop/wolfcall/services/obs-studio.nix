{ pkgs, ... }:
{
  programs.obs-studio = {
    enable = true;
    enableVirtualCamera = true;
    # This will compile obs-studio from source (20-40min) to enable CUDA support
    # Which will allow for NVENC support to be detected
    # This may be needed because of https://github.com/NixOS/nixpkgs/pull/383402 *shrugs*
    package = pkgs.obs-studio.override { cudaSupport = true; };
  };
}

