{ inputs', pkgs, ... }:
let

  pkgs-stable = inputs'.nixpkgs-stable.legacyPackages;

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

    # Markdown
    pkgs.harper
    pkgs.marksman

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
}
