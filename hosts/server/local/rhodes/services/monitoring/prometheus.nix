{ ... }: {
  services.prometheus = {
    enable = true;
    listenAddress = "0.0.0.0";
    port = 9001;

    scrapeConfigs = [{
      job_name = "node";
      static_configs = [{ targets = [ "rhodes:9100" ]; }];
    }];
  };
}
