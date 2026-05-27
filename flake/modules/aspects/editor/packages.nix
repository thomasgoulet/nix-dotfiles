{ pkgs, ... }:
{
  home.packages = with pkgs; [

    # AI
    opencode
    ctx7
    context7-mcp

    # CSS, HTML, JS, JSON, TypeScript
    vscode-langservers-extracted
    typescript-language-server
    nodejs_25
    prettier

    # C#
    dotnet-sdk_8
    omnisharp-roslyn

    # Go
    go
    gopls

    # Java
    jdk25_headless
    (jdt-language-server.override { jdk = jdk25_headless; })

    # Markdown
    marksman
    markdown-oxide

    # Nix
    nil

    # Python
    python312
    python312Packages.python-lsp-server
    black
    ruff
    ty

    # Terraform / HCL
    terraform-ls

    # Typst
    typst
    tinymist

    # YAML
    yaml-language-server
    yamlfmt

  ];
}
