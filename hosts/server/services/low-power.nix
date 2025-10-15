{ ... }: {
  # Ouch !! 0.2016€ / kWh 

  hardware.cpu.intel.updateMicrocode = true;
  hardware.enableAllFirmware = true;

  boot.kernelModules = [ "coretemp" ];

  powerManagement.cpuFreqGovernor = "powersave";
  powerManagement.powertop.enable = true;

  # uncomment to lower CPU frequeuncy (0 - lowest, 100 - highest)
  # if it spins even on lowest frequency, then this can be hardware problem

  # system.activationScripts.cpu-frequency-set = {
  #     text = ''
  #         echo 75 > /sys/devices/system/cpu/intel_pstate/max_perf_pct
  #         # check freq with    "sudo cpupower frequency-info"
  #     '';
  #     deps = [];
  # };
}
