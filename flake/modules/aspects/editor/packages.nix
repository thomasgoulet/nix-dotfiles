{ inputs', config, pkgs, ... }:
let

  pkgs-stable = inputs'.nixpkgs-stable.legacyPackages;

  zk = pkgs.buildGoModule {
    pname = "zk";
    version = "unstable-2025-06-04";
    src = pkgs.fetchFromGitHub {
      owner = "zk-org";
      repo = "zk";
      rev = "d62622f99f99b67e89ce29453f868f85f9e7850c";
      hash = "sha256-bA3RIr+x4JxSyklKaHRlCDRrfq9yMwmujc3kW+WKI08=";
    };
    vendorHash = "sha256-YX+voBRKC/2LN7ByS8XWgJkm6dAip8L0kHpt754wHck=";
    doCheck = false;
    env.CGO_ENABLED = 1;
    tags = [ "fts5" ];
    ldflags = [
      "-s" "-w"
      "-X=main.Build=unstable"
      "-X=main.Version=unstable"
    ];
  };

in
{
  home.packages = [

    # CSS, HTML, JS, JSON, TypeScript
    pkgs.vscode-langservers-extracted
    pkgs.typescript-language-server
    pkgs.nodejs_26
    pkgs.prettier

    # C#
    pkgs.dotnet-sdk_8
    pkgs.omnisharp-roslyn

    # Go
    pkgs.go
    pkgs.gopls

    # Java
    pkgs.jdk25_headless
    (pkgs.jdt-language-server.override { jdk = pkgs.jdk25_headless; })

    # Notes
    pkgs.tuxedo
    zk

    # Nix
    pkgs.nil

    # Python
    pkgs.python312
    pkgs-stable.python312Packages.python-lsp-server
    pkgs-stable.black
    pkgs-stable.ruff
    pkgs-stable.ty

    # Terraform / HCL
    pkgs.terraform-ls

    # Typst
    pkgs.typst
    pkgs.tinymist

    # YAML
    pkgs.yaml-language-server
    pkgs.yamlfmt

  ];

  home.sessionVariables = {
    TODO_DIR = "${config.home.homeDirectory}/notebook";
    TODO_FILE = "${config.home.homeDirectory}/notebook/tasks.txt";
    ZK_NOTEBOOK_DIR = "${config.home.homeDirectory}/notebook";
    ZK_SHELL = "/bin/bash";
  };
}
