{ config, lib, ... }:
with lib;
let
  # Shorter name to access a final setting
  # All modules are under the custom attribute "def"
  cfg = config.def.watchdog;
in {

  #          :::!~!!!!!:.
  #      .xUHWH!! !!?M88WHX:.
  #    .X*#M@$!!  !X!M$$$$$$WWx:.
  #   :!!!!!!?H! :!$!$$$$$$$$$$8X:
  #  !!~  ~:~!! :~!$!#$$$$$$$$$$8X:
  #  !~::!H!<   ~.U$X!?R$$$$$$$$MM!
  #  !~!!!!~~ .:XW$$$U!!?$$$$$$RMM!
  #   !:~~~ .:!M"T#$$$$WX??#MRRMMM!
  #   ~?WuxiW*`   `"#$$$$8!!!!??!!!
  #     M$$$$       `"T#$T~!8$WUXU~
  #     ~#$$$m:        ~!~ ?$$$$$$
  #      ~T$$$$8xx.  .xWW- ~""##*"
  #        ~?T#$$@@W@*?$$      /`
  #         .:XUW$W!~ `"~:    :
  #        !WM$$$$Ti.: .!WUn+!`
  #     .!u "$$$B$$$!W:U!T$$M~
  #     !WTWo("*$$$W$TH$! `
  #     ?$$$B$Wu("**$RM!
  #      ~$$$$$B$$en:``
  #       ~"##*$$$$M~⠀⠀⠀⠀⠀⠀⠀

  options.def.watchdog = { enable = mkEnableOption "system watchdog"; };
  config = mkIf cfg.enable {
    systemd = {
      # For more detail, see:
      #   https://0pointer.de/blog/projects/watchdog.html
      watchdog = {
        # systemd will send a signal to the hardware watchdog at half
        # the interval defined here, so every 7.5s.
        # If the hardware watchdog does not get a signal for 15s,
        # it will forcefully reboot the system.
        runtimeTime = "15s";
        # Forcefully reboot if the final stage of the reboot
        # hangs without progress for more than 30s.
        # For more info, see:
        #   https://utcc.utoronto.ca/~cks/space/blog/linux/SystemdShutdownWatchdog
        rebootTime = "30s";
        # Forcefully reboot when a host hangs after kexec.
        # This may be the case when the firmware does not support kexec.
        kexecTime = "1m";
      };
    };
  };
}
