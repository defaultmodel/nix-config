{ pkgs, ... }:
{
  systemd.timers."fancontrol" = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "*:0/3";
      Unit = "fancontrol.service";
    };
  };

  systemd.services."fancontrol" = {
    environment = {
      TEMP_MIN_FALLING = "50";
      TEMP_MAX_RISING = "56";
      TEMP_CRIT = "70";

      LOW_FAN_SPEED = "0x10";
    };

    script = ''
      SET_FAN_MANUAL="0x30 0x30 0x01 0x00" # Enable manual control
      SET_FAN_AUTO="0x30 0x30 0x01 0x01" # Disable manual control

      SET_FAN_LOW="0x30 0x30 0x02 0xff $LOW_FAN_SPEED"
      SET_FAN_MAX="0x30 0x30 0x02 0xff 0x64" # force 100%


      # Get all temperatures readings starting with "Temp ", find all two digit numbers followed by spaces, find the largest one, trim the trailing space
      maxcoretemp=$(${pkgs.ipmitool}/bin/ipmitool sdr type temperature | grep '^Temp ' |  grep -Po '\d{2} ' | sort -nr | head -n1 | xargs)

      # Verify that we read a valid number
      ISNUMBER='^[0-9]+$'
      if ! [[ $maxcoretemp =~ $ISNUMBER ]] ; then
        echo "Error: could not read temperature" >&2
        exit 2
      fi

      echo "Highest measured CPU temperature: '$maxcoretemp'"

      if [ "$maxcoretemp" -gt "$TEMP_CRIT" ]; then
        echo "TOO HOT, CRITICAL CPU TEMP"
        ${pkgs.ipmitool}/bin/ipmitool raw $SET_FAN_MANUAL
        ${pkgs.ipmitool}/bin/ipmitool raw $SET_FAN_MAX
        exit 1
      fi

      if [ "$maxcoretemp" -gt "$TEMP_MAX_RISING" ]; then
        echo "TOO HOT, switching to IDRAC fan controL"
        ${pkgs.ipmitool}/bin/ipmitool raw $SET_FAN_AUTO
        exit 0
      fi

      if [ "$maxcoretemp" -lt "$TEMP_MIN_FALLING" ]; then
        echo "Sufficiently cooled, stepping down fans"
        ${pkgs.ipmitool}/bin/ipmitool raw $SET_FAN_MANUAL
        ${pkgs.ipmitool}/bin/ipmitool raw $SET_FAN_LOW
        exit 0
      fi

      echo "Temperature is between limits, doing nothing..."
    '';
  };
}

