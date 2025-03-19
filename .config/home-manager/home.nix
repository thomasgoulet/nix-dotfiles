extra@{ config, pkgs, pkgs-stable, ... }:

{
  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "24.05";
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
      bat
      btop
      delta
      eza
      fd
      fx
      fzf
      just
      lf
      ripgrep
      taskwarrior3
      wslu
      zoxide

      # Editor / Programming
      git
      helix
      lazygit

      # LSPs
      vale vale-ls            # Spell checking
      marksman markdown-oxide # Markdown
      nil                     # Nix
      terraform-ls            # HCL
      yaml-language-server    # YAML

        # Go
        go
        gopls

        # Java
        jdk
        jdt-language-server

        # Python
        python312
        python312Packages.python-lsp-server

        # CSS, HTML, JS, JSON, Typescript
        vscode-langservers-extracted
        typescript-language-server
        nodejs_22
        nodePackages.prettier 

        # Typst
        typst
        tinymist

      # Infrastructure
      argocd
      k9s
      kubectl
      kubelogin
      kustomize
      podman
      terraform

    ]
  ) ++ (
    # Packages which do not build on unstable
    with pkgs-stable; [

    ]
  );

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # ".screenrc".source = dotfiles/screenrc;
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };
 
}
