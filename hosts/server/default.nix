{ config, lib, modulesPath, ... }: {

  # Common config for all servers

  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    (modulesPath + "/profiles/qemu-guest.nix")
    ../default.nix # Common config for all hosts

    ./services/watchdog.nix
    ./services/monitoring-exporter.nix
  ];

  # Default user
  users.users.root = {
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAtsgdnGkeAWcGjsLyQRhCJDJyfwlD0euUW37u8ou6px"
    ];
  };

  networking = {
    useDHCP = true; # Enabled because the router should have DHCP reserved IP
    nameservers = [ "192.168.1.30" ];
  };

  services.openssh.enable = true;
  services.qemuGuest.enable = true;

  # Given that our systems are headless, emergency mode is useless.
  # We prefer the system to attempt to continue booting so
  # that we can hopefully still access it remotely.
  systemd.enableEmergencyMode = false;
  boot.initrd.systemd.suppressedUnits =
    lib.mkIf config.systemd.enableEmergencyMode [
      "emergency.service"
      "emergency.target"
    ];

  # Print the URL instead on servers
  environment.variables.BROWSER = "echo";

  # Servers are never tired !!
  systemd.sleep.extraConfig = ''
    AllowSuspend=no
    AllowHibernation=no
  '';

  # Rip it out
  security.sudo.enable = false;

  # enable firewall and block all ports
  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [ ];
  networking.firewall.allowedUDPPorts = [ ];

  # Make sure the serial console is visible in qemu when testing the server configuration
  # with nixos-rebuild build-vm
  virtualisation.vmVariant.virtualisation.graphics = lib.mkDefault false;

  # TODO: cargo culted.
  nix.daemonCPUSchedPolicy = lib.mkDefault "batch";
  nix.daemonIOSchedClass = lib.mkDefault "idle";
  nix.daemonIOSchedPriority = lib.mkDefault 7;

  systemd.services.nix-gc.serviceConfig = {
    CPUSchedulingPolicy = "batch";
    IOSchedulingClass = "idle";
    IOSchedulingPriority = 7;
  };

  # Make builds to be more likely killed than important services.
  # 100 is the default for user slices and 500 is systemd-coredumpd@
  # We rather want a build to be killed than our precious user sessions as builds can be easily restarted.
  systemd.services.nix-daemon.serviceConfig.OOMScoreAdjust = lib.mkDefault 250;
}
