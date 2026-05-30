{ inputs', pkgs, ... }:
{
  home.packages = [

    # AI
    pkgs.opencode
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
    pkgs.marksman
    pkgs.markdown-oxide

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
    OPENCODE_DISABLE_LSP_DOWNLOAD = "true";
  };
}
