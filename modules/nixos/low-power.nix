{ config, lib, ... }:
with lib;
let
  # Shorter name to access a final setting
  # All modules are under the custom attribute "def"
  cfg = config.def.low-power;
in {
  options.def.low-power = {
    enable = mkEnableOption "Low-power modifications";
  };

  config = mkIf cfg.enable {
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

    services.thermald.enable = true;
    environment.etc."sysconfig/lm_sensors".text = ''
      HWMON_MODULES="coretemp"
    '';
  };
}
