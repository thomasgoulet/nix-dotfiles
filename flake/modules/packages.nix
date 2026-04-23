{ inputs, ... }:
{
  # This module defines the home-manager configuration
  # It's imported by the NixOS configuration in wsl.nix
  flake.homes = {
    thomas = { config, pkgs, custom-bins, ... }: {

      home.stateVersion = "25.11";
      programs.home-manager.enable = true;

      home.username = "thomas";
      home.homeDirectory = "/home/thomas";

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
        git
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
          nodejs_24
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
      ];
    };
  };
}
