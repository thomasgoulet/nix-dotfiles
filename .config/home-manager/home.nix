extra@{ config, pkgs, ... }:

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

  home.packages = with pkgs; [
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
    fzf
    lf
    ripgrep
    zoxide

    # Editor / Programming
    git
    helix
    lazygit

    # LSPs
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

      # CSS, HTML, JS, JSON, Typescript
      vscode-langservers-extracted
      typescript-language-server
      nodejs_22
      nodePackages.prettier 

    # Infrastructure
    azure-cli
    k9s
    kubectl
    kubelogin
    podman
    terraform
  ];

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
