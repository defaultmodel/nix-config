{ pkgs, ... }: {
  # give me that negative karma
  nixpkgs.config.allowUnfree = true;

  # fuck nano all my homies use helix
  environment.variables.EDITOR = "hx";

  environment.systemPackages = with pkgs; [
    python3

    # archives
    zip
    xz
    unzip
    p7zip

    # utils
    bat # better cat
    ripgrep # better grep
    jq # JSON handling
    eza # better ls
    fzf # fuzzy finder
    sad # better sed
    zellij # Terminal multiplexer
    borgbackup

    # misc
    file
    which
    tree
    tldr
    gnupg
    git
    git-filter-repo
    lazygit
    tcpdump

    # DNS
    dig
    drill
    doggo

    # Monitoring
    btop # replacement of htop/nmon
    iotop # io monitoring
    iftop # network monitoring

    # Editor
    helix

    # system tools
    lm_sensors # for `sensors` and `sensors-detect` command
    dmidecode # for `sensors-detect` to detect IPMI
    pciutils # lspci
    usbutils # lsusb
  ];
}
