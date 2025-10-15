{ pkgs, ... }: {
  services.cron = {
    enable = true;
    systemCronJobs = [
      "* * * * * ${pkgs.php} /root/oci-arm-host-capacity/index.php >> /root/oci-arm-host-capacity/oci.log"
    ];
  };
}
