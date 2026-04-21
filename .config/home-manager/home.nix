extra@{ config, pkgs, pkgs-stable, ... }:
let
  binaries = import ./binaries.nix { inherit pkgs; };
in
{
  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "26.05";
  programs.home-manager.enable = true;

  home.username = "thomas";
  home.homeDirectory = "/home/thomas";

  nixpkgs.config.allowUnfree = true;

  home.packages = (
    with pkgs; [

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
      binaries.backlog-md
      binaries.hl
      binaries.oasdiff
      bat
      broot
      delta
      difftastic
      eza
      fd
      fzf
      just
      ripgrep
      sd
      wsl-open
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
        # jdt-language-server

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

    ]
  );

  # ++ (
  #   # Packages which do not build on unstable
  #   with pkgs-stable; [
  #   ]
  # );

}
