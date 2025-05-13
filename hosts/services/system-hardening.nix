{ ... }:
{
  # Clear /tmp on each reboot
  boot.tmp.useTmpfs = true;

  # zram allows swapping to RAM by compressing memory. This reduces the chance
  # that sensitive data is written to disk, and eliminates it if zram is used
  # to completely replace swap to disk. Generally *improves* storage lifespan
  # and performance, there usually isn't a need to disable this.
  zramSwap.enable = true;

  # disable coredump that could be exploited later
  # and also slow down the system when something crash
  systemd.coredump.enable = false;

  # Limit access to nix to users with the "wheel" group. ("sudoers")
  nix.settings.allowed-users = [ "@wheel" ];

  # Don't install the /lib/ld-linux.so.2 and /lib64/ld-linux-x86-64.so.2
  # stubs. Server users should know what they are doing.
  # environment.stub-ld.enable = false;

  # enable antivirus (1,4)
  # services.clamav.daemon.enable = true;
  # keep the signatures' database updated
  # services.clamav.updater.enable = true;
}
