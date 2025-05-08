{ config, lib, ... }:
with lib;
let
  # Shorter name to access a final setting
  # All modules are under the custom attribute "def"
  cfg = config.def.firefox;

  lock-false = {
    Value = false;
    Status = "locked";
  };
  lock-true = {
    Value = true;
    Status = "locked";
  };
in {
  options.def.firefox = {
    enable = mkEnableOption "Firefox with reasonable defaults";
    verticalTabs = mkEnableOption "Enable vertical tabs";
  };

  config = mkIf cfg.enable {
    programs = {
      firefox = {
        enable = true;
        languagePacks = [ "fr" "en-US" ];

        # ---- POLICIES ----
        # Check about:policies#documentation for options.
        policies = {
          DisableTelemetry = true;
          DisableFirefoxStudies = true;
          EnableTrackingProtection = {
            Value = true;
            Locked = true;
            Cryptomining = true;
            Fingerprinting = true;
          };
          DisablePocket = true;
          DisableFirefoxAccounts = true;
          DisableAccounts = true;
          DisableFirefoxScreenshots = true;
          OverrideFirstRunPage = "";
          OverridePostUpdatePage = "";
          DontCheckDefaultBrowser = true;
          DisplayBookmarksToolbar =
            "never"; # alternatives: "always" or "newtab"
          DisplayMenuBar =
            "default-off"; # alternatives: "always", "never" or "default-on"
          SearchBar = "unified"; # alternative: "separate"

          # ---- EXTENSIONS ----
          # Check about:support for extension/add-on ID strings.
          # Valid strings for installation_mode are "allowed", "blocked",
          # "force_installed" and "normal_installed".
          ExtensionSettings = {
            "*".installation_mode =
              "blocked"; # blocks all addons except the ones specified below
            # uBlock Origin:
            "uBlock0@raymondhill.net" = {
              install_url =
                "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
              installation_mode = "force_installed";
              private_browsing = true;
            };
            # Sponsor Block:
            "sponsorBlocker@ajay.app" = {
              install_url =
                "https://addons.mozilla.org/en-US/firefox/downloads/sponsorblock/";
              installation_mode = "force_installed";
              private_browsing = true;
            };
            # Bitwarden:
            "{446900e4-71c2-419f-a6a7-df9c091e268b}" = {
              install_url =
                "https://addons.mozilla.org/firefox/downloads/latest/bitwarden-password-manager/latest.xpi";
              installation_mode = "force_installed";
              private_browsing = true;
            };
          };

          # ---- PREFERENCES ----
          # Check about:config for options.
          Preferences = {
            # Firefox's Enhanced Tracking Protection
            "browser.contentblocking.category" = {
              Value = "strict";
              Status = "locked";
            };
            # Change scrollbar style
            "widget.non-native-theme.scrollbar.style" = {
              Value = 1; # Mac-OS style scrollbar
              Status = "locked";
            };
            # Enable middle-mouse to auto-scroll
            "general.autoScroll" = lock-true;
            "sidebar.verticalTabs" =
              if cfg.verticalTabs then lock-true else lock-false;
            "extensions.pocket.enabled" = lock-false;
            "extensions.screenshots.disabled" = lock-true;
            "browser.topsites.contile.enabled" = lock-false;
            "browser.formfill.enable" = lock-false;
            "browser.search.suggest.enabled" = lock-false;
            "browser.search.suggest.enabled.private" = lock-false;
            "browser.urlbar.suggest.searches" = lock-false;
            "browser.urlbar.showSearchSuggestionsFirst" = lock-false;
            "browser.translations.enable" = lock-false;
            "browser.newtabpage.activity-stream.feeds.section.topstories" =
              lock-false;
            "browser.newtabpage.activity-stream.feeds.snippets" = lock-false;
            "browser.newtabpage.activity-stream.section.highlights.includePocket" =
              lock-false;
            "browser.newtabpage.activity-stream.section.highlights.includeBookmarks" =
              lock-false;
            "browser.newtabpage.activity-stream.section.highlights.includeDownloads" =
              lock-false;
            "browser.newtabpage.activity-stream.section.highlights.includeVisited" =
              lock-false;
            "browser.newtabpage.activity-stream.showSponsored" = lock-false;
            "browser.newtabpage.activity-stream.system.showSponsored" =
              lock-false;
            "browser.newtabpage.activity-stream.showSponsoredTopSites" =
              lock-false;
          };
        };
      };
    };
  };
}
