{ pkgs, ... }: {
  services.protonmail-bridge = {
    enable = true;
    logLevel = "info";
    path = with pkgs; [ pass ];
  };
}
