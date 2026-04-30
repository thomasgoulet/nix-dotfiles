{ inputs, ... }:
{
  # This module defines the home-manager configuration
  # It's imported by the NixOS configuration in wsl.nix
  flake.homes = {
    thomas = { config, pkgs, custom-bins, nu-mcp, ... }: {

      home.stateVersion = "25.11";
      programs.home-manager.enable = true;

      home.username = "thomas";
      home.homeDirectory = "/home/thomas";

      programs.git = {
        enable = true;
        settings = {
          credential.helper = "store";
          push.autoSetupRemote = true;

          core.pager = "delta";
          diff.colorMoved = "default";
          interactive.diffFilter = "delta --color-only";
          merge.conflictstyle = "diff3";

          delta = {
            dark = true;
            line-numbers = true;
            navigate = true;
            side-by-side = true;
            syntax-theme = "Catppuccin Mocha";
            blame-palette = "#1e1e2e #181825 #313244";
            hunk-header-style = "omit";
            file-style = "white";
          };
        };
      };

      home.packages = (with pkgs; [

        # Azure
        (azure-cli.withExtensions [
          azure-cli.extensions.ssh
          azure-cli.extensions.azure-devops
        ])

        # Shell
        nushell
        starship
        zellij

        # Utilities
        bat
        broot
        delta
        difftastic
        eza
        fd
        fzf
        hl-log-viewer
        just
        ripgrep
        sd
        zoxide

        # Editor / Programming
        helix
        lazygit
        opencode

        # LSPs
        vale vale-ls            # Spell checking
        marksman markdown-oxide # Markdown
        nil                     # Nix
        terraform-ls            # HCL

          # C#
          dotnet-sdk_8
          omnisharp-roslyn

          # Go
          go
          gopls

          # Java
          jdk25_headless
          (jdt-language-server.override { jdk = jdk25_headless; })

          # Python
          python312
          python312Packages.python-lsp-server
          black
          ruff
          ty

          # CSS, HTML, JS, JSON, Typescript
          vscode-langservers-extracted
          typescript-language-server
          nodejs_25
          prettier

          # Typst
          typst
          tinymist

          # YAML
          yaml-language-server
          yamlfmt

        # Infrastructure
        argocd
        dyff
        k9s
        kubectl
        kubelogin
        kustomize
        tenv

      ]) ++ [
        # Custom binaries from perSystem
        custom-bins.backlog-md
        custom-bins.oasdiff
        # nu-mcp from upstream flake (via inputs')
        nu-mcp
      ];
    };
  };
}
