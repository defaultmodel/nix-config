{ pkgs, ... }: {
  programs.helix = {
    enable = true;
    defaultEditor = true;

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
      typescript-language-server # TS
      biome # TS
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
        {
          name = "javascript";
          language-servers = [
            {
              name = "typescript-language-server";
              except-features = [ "format" ];
            }
            "biome"
          ];
          auto-format = true;
        }
        {
          name = "typescript";
          language-servers = [
            {
              name = "typescript-language-server";
              except-features = [ "format" ];
            }
            "biome"
          ];
          auto-format = true;
        }
        {
          name = "tsx";
          auto-format = true;
          language-servers = [
            {
              name = "typescript-language-server";
              except-features = [ "format" ];
            }
            "biome"
          ];
        }
        {
          name = "jsx";
          auto-format = true;
          language-servers = [
            {
              name = "typescript-language-server";
              except-features = [ "format" ];
            }
            "biome"
          ];
        }
        {
          name = "json";
          language-servers = [
            {
              name = "vscode-json-language-server";
              except-features = [ "format" ];
            }
            "biome"
          ];
        }
        {
          name = "rust";
          auto-format = true;
        }
      ];
      language-server.pyright.config.python.analysis.typeCheckingMode = "basic";
      language-server.ruff = {
        command = "ruff";
        args = [ "server" ];
      };
      language-server.biome = {
        command = "biome";
        args = [ "lsp-proxy" ];
      };
      language-server.rust-analyzer.config = {
        check = { command = "clippy"; };
        procMacro.ignored.leptos_macro = [ "component" "server" ];
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
}
