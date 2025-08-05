{ pkgs, ... }: {

  programs.dconf.enable = true;

  users.users."defaultmodel".extraGroups = [ "libvirtd" ];

  environment.systemPackages = with pkgs; [
    virt-manager
    virt-viewer
    spice
    spice-gtk
    spice-protocol
    win-virtio
    win-spice
    adwaita-icon-theme
    quickemu # some nice shit right there
    vagrant
  ];

  # Bypasses the need to specify --provider=libvirt each time when using vagrant
  environment.variables.VAGRANT_DEFAULT_PROVIDER = "libvirt";

  virtualisation = {
    libvirtd = {
      enable = true;
      qemu = {
        swtpm.enable = true;
        ovmf.enable = true;
        ovmf.packages = [ pkgs.OVMFFull.fd ];
      };
    };
    spiceUSBRedirection.enable = true;
  };
  services.spice-vdagentd.enable = true;
}
