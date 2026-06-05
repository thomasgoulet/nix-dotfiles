{ inputs', config, pkgs, ... }:
let

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

    # AI
    pkgs.opencode
    pkgs.github-copilot-cli
    pkgs.ctx7
    pkgs.context7-mcp
    inputs'.nu-mcp.packages.default

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

    # Markdown
    zk

    # Nix
    pkgs.nil

    # Python
    pkgs.python312
    pkgs.python312Packages.python-lsp-server
    pkgs.black
    pkgs.ruff
    pkgs.ty

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
    COPILOT_HOME = "${config.home.homeDirectory}/.config/copilot";
    OPENCODE_DISABLE_LSP_DOWNLOAD = "true";
  };
}
