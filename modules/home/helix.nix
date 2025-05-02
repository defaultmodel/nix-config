{ pkgs, config, lib, ... }:
with lib;
let
  # Shorter name to access a final setting
  # All modules are under the custom attribute "def"
  cfg = config.def.helix;
in {
  options.def.helix = {
    enable = mkEnableOption "Helix text editor";
    defaultEditor =
      mkEnableOption "Put 'helix' in the $EDITOR enviroment variable";
  };

  config = mkIf cfg.enable {
    programs.helix = {
      enable = true;
      defaultEditor = cfg.defaultEditor;

      extraPackages = with pkgs; [
        lldb # Allow debugging

        bash-language-server # Bash LSP
        shellcheck # Bash diagnostics
        shfmt # Bash formatter
        clang-tools # C/C++
        vscode-langservers-extracted # CSS/HTML/JS
        dockerfile-language-server-nodejs # Docker
        docker-compose-language-service # Docker compose
        nil # Nix
        nixfmt-classic # Nix formatter
        marksman # Markdown
        pyright # Python LSP
        ruff # Python linter
        rust-analyzer # Rust
        taplo # TOML
      ];

      languages = {
        language = [
          {
            name = "nix";
            auto-format = true;
            formatter.command = "${pkgs.nixfmt-classic}/bin/nixfmt";
          }
          {
            name = "python";
            auto-format = true;
            language-servers = [ "pyright" "ruff" ];
          }
        ];
        language-server.pyright.config.python.analysis.typeCheckingMode =
          "basic";
        language-server.ruff = {
          command = "ruff";
          args = [ "server" ];
        };
      };

      settings = {
        theme = "iroaseta";
        editor = {
          line-number = "relative";
          lsp = {
            display-progress-messages = true;
            display-inlay-hints = true;
          };
          auto-save.focus-lost = true; # Save on window change
          indent-guides.render = true; # Show indent lines
          inline-diagnostics.cursor-line =
            "warning"; # show warnings and errors on the current line
        };
      };
    };
  };
}
