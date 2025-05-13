{ config, lib, ... }:
with lib;
let
  srv = config.services.adguardhome;
  certloc = "/var/lib/acme/defaultmodel.eu.org";
  url = "adguardhome.defaultmodel.eu.org";
in
{
  services.adguardhome = {
    enable = true;
    host = "0.0.0.0";
    port = 38916;

    mutableSettings = false;
    allowDHCP = true;
    settings = {
      http = {
        address = "0.0.0.0:3000";
        session_ttl = "720h";
        enable_json_api = true;
      };
      users = [{
        name = "defaultmodel";
        password = "$2a$15$0kVcvZCskZQvHt.qfi.K/O2d1Iah/8V8S7gGaYXaKZxsQAHdU5nI.";
      }];
      auth_attempts = 5;
      block_auth_min = 15;
      dns = {
        # General settings
        bind_hosts = [ "0.0.0.0" ];
        port = 53;
        anonymize_client_ip = false;
        # Anti-DNS amplification features
        ratelimit = 50;
        refuse_any = true;
        # Upstream DNS servers settings:
        upstream_dns = [
          "194.242.2.4#base.dns.mullvad.net"
          "194.242.2.2#dns.mullvad.net"
          "193.110.81.0#dns0.eu"
          "185.253.5.0$dns0.eu"
        ];
        bootstrap_dns = [ "1.1.1.1" "8.8.8.8" "2606:4700:4700::1111" ];
        fallback_dns = [ "1.1.1.1" "8.8.8.8" ];
        upstream_mode = "load_balance";
        fastest_timeout = "2s";
        use_http3_upstreams = true;
        use_dns64 = false;
        dns64_prefixes = [ ];
        # ECS settings
        edns_client_subnet = {
          custom_ip = "";
          enabled = true;
          use_custom = false;
        };
        # Access settings
        allowed_clients = [ ];
        disallowed_clients = [ ];
        blocked_hosts = [ ];
        trusted_proxies = [ ];
        # DNS cache settings
        cache_size = 8388608;
        cache_ttl_min = 60;
        cache_ttl_max = 3600;
        cache_optimistic = true;
        # Other settings
        bogus_nxdomain = [ ];
        enable_dnssec = true;
        aaaa_disabled = false;
        cache_time = 600;
        max_goroutines = 1000;
        handle_ddr = true;
        ipset = [ ];
        upstream_timeout = "10s";
        serve_http3 = true;
        theme = "auto";
      };
      filtering = {
        protection_enabled = true;
        filtering_enabled = true;
        blocking_mode = "default";
        blocking_ipv4 = "";
        blocking_ipv6 = "";
        blocked_response_ttl = 10;
        parental_block_host = "family-block.dns.adguard.com";
        safebrowsing_block_host = "standard-block.dns.adguard.com";
        parental_enabled = false;
        safesearch_enabled = false;
        safebrowsing_enabled = false;
        safebrowsing_cache_size = 1048576;
        safesearch_cache_size = 1048576;
        parental_cache_size = 1048576;
        rewrites = [{
          domain = url;
          answer = (builtins.elemAt
            (config.networking.interfaces.bond0.ipv4.addresses) 0).address;
        }];
        cache_time = 30;
        filters_update_interval = 24;
        # blocked_services = [ ];
      };
      querylog = {
        enabled = true;
        file_enabled = true;
        interval = "2160h";
        size_memory = 2000;
        ignored = [ ];
      };
      statistics = {
        enabled = true;
        interval = "720h";
        ignored = [ ];
      };
      filters = [
        {
          enabled = true;
          url =
            "https://adguardteam.github.io/HostlistsRegistry/assets/filter_1.txt";
          name = "AdGuard DNS filter";
          id = 1;
        }
        {
          enabled = false;
          url =
            "https://adguardteam.github.io/HostlistsRegistry/assets/filter_2.txt";
          name = "AdAway Default Blocklist";
          id = 2;
        }
      ];
      whitelist_filters = [ ];
      user_rules = [
        "@@||0.client-channel.google.com^$important # In order for users on your network to access Google Drive and Google Docs editors this domain must be whitelisted - https://support.google.com/a/answer/2589954?hl=en"
        "@@||1drv.com^$important # It is actually a legitimate Microsoft owned domain and used as a short link for OneDrive documents."
        "@@||2.android.pool.ntp.org^$important # This domain is a part of The pool.ntp.org project which is a big virtual cluster of timeservers providing reliable time. This domain is used in Android devices"
        "@@||akamaihd.net^$important # This domain is owned by Akamai Technologies which is a is a global content delivery network (CDN)."
        "@@||akamaitechnologies.com^$important # This domain is owned by Akamai Technologies which is a is a global content delivery network (CDN)."
        "@@||akamaized.net^$important # This domain is owned by Akamai Technologies which is a is a global content delivery network (CDN)."
        "@@||amazonaws.com^$important # Amazon Web Services (AWS) is a subsidiary of Amazon providing on-demand cloud computing platforms and APIs. This domain is used to serve files and other static resources which are hosted on Amazon AWS"
        "@@||android.clients.google.com^$important # Google Play Store and few devices (especially Android One devices) depends on this domain for system updates."
        "@@||api.ipify.org^$important # It is used to get your public IP address programmatically. ipify is completely opensource."
        "@@||app-api.ted.com^$important # Used by ted.com streams."
        "@@||api.rlje.net^$important # Used to deliver contents on video straming apps on hulu etc."
        "@@||appleid.apple.com^$important # Used to sign in t your Apple account."
        "@@||apps.skype.com^$important # Used to make group calls, group chats etc. on Skype."
        "@@||appsbackup-pa.clients6.google.com^$important # Used to backup device settings and app data."
        "@@||appsbackup-pa.googleapis.com^$important # Used to backup device settings and app data."
      ];
      dhcp = {
        enabled = true;
        interface_name = "bond0";
        local_domain_name = "lan";
        dhcpv4 = {
          gateway_ip = "192.168.1.1";
          subnet_mask = "255.255.255.0";
          range_start = "192.168.1.100";
          range_end = "192.168.1.200";
          lease_duration = 86400;
          icmp_timeout_msec = 1000;
          options = [ ];
        };
        dhcpv6 = {
          range_start = "";
          lease_duration = 86400;
          ra_slaac_only = false;
          ra_allow_slaac = false;
        };
      };
      clients = {
        persistent = [ ];
        runtime_sources = {
          whois = true;
          arp = true;
          rdns = true;
          dhcp = true;
          hosts = true;
        };
      };
      log = {
        file = "syslog";
        local_time = true;
      };
    };
  };
  networking = {
    firewall = {
      allowedTCPPorts = [ srv.port 53 68 853 ];
      allowedUDPPorts = [ 53 67 68 ];
    };
  };

  services.caddy = {
    virtualHosts.${url}.extraConfig = ''
      reverse_proxy http://localhost:${toString srv.port}
      tls ${certloc}/cert.pem ${certloc}/key.pem {
           protocols tls1.3
         }
    '';
  };

  ### HOMEPAGE ###
  def.homepage.categories."Other"."AdguardHome" = {
    icon = "adguard-home.png";
    description = "Local DNS resolver";
    href = "https://${url}";
  };
}
