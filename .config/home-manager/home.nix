extra@{ config, pkgs, pkgs-stable, ... }:
let

  hl-bin = pkgs.stdenv.mkDerivation {
    pname = "hl";
    version = "v0.35.3";
    src = pkgs.fetchurl {
      url = "https://github.com/pamburus/hl/releases/download/v0.35.3/hl-linux-x86_64-musl.tar.gz";
      sha256 = "140hpyxccrn8ryc36bzzq7qf70dlimfpzvrxi6hcyyi023dvssck"; # nix-prefetch-url <url>
    };
    dontUnpack = true;
    installPhase = ''
      mkdir -p $out/bin
      tar -xzvf $src
      cp hl $out/bin/
    '';
  };

  oasdiff-bin = pkgs.stdenv.mkDerivation {
    pname = "oasdiff";
    version = "1.11.7";
    src = pkgs.fetchurl {
      url = "https://github.com/oasdiff/oasdiff/releases/download/v1.11.7/oasdiff_1.11.7_linux_amd64.tar.gz";
      sha256 = "093j69a9s1d4wysz7jwfpfp934z00s311ynqykb6ykppclihbwcp"; # nix-prefetch-url <url>
    };
    dontUnpack = true;
    installPhase = ''
      mkdir -p $out/bin
      tar -xzvf $src
      cp oasdiff $out/bin/
    '';
  };

in
{
  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "25.05";
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
      broot
      delta
      difftastic
      eza
      fd
      fzf
      hl-bin
      just
      oasdiff-bin
      ripgrep
      sd
      wslu
      zoxide

      # Editor / Programming
      git
      github-copilot-cli
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
        jdk
        jdt-language-server

        # Python
        python312
        python312Packages.python-lsp-server
        black
        ruff
        ty

        # CSS, HTML, JS, JSON, Typescript
        vscode-langservers-extracted
        typescript-language-server
        nodejs_22
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
