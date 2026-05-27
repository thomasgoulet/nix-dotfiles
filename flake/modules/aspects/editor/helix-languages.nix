{ pkgs, ... }:
let
  lombok = pkgs.fetchurl {
    url = "https://projectlombok.org/downloads/lombok-1.18.44.jar";
    sha256 = "11mz6l8c1vvaswxx10az7q201dprmaamw67f4pxixfsqqgyipsf6";
  };
in
{
  programs.helix = {
    enable = true;
    languages = {
      language-server = {
        none = { command = ""; };
        omnisharp = { command = "OmniSharp"; args = [ "--languageserver" ]; };
        vscode-esling-language-server = {
          command = "vscode-eslint-language-server";
          args = [ "stdio" ];
          config = {
            experimental.useFlatConfig = true;
            workingDirectory.mode = "auto";
          };
        };
        jdtls = { command = "jdtls"; args = [ "--jvm-arg=-javaagent:${lombok}" ]; };
        yaml = {
          command = "yaml-language-server";
          args = [ "--stdio" ];
          config.yaml = {
            format.enable = true;
            keyOrdering = false;
          };
        };
      };
      language = [
        { name = "bash"; language-servers = [ "none" ]; }
        { name = "c-sharp"; language-servers = [ "omnisharp" ]; }
        { name = "html"; auto-format = false; }
        { name = "css"; auto-format = false; }
        {
          name = "markdown";
          formatter = { command = "prettier"; args = [ "--parser" "markdown" ]; };
          language-servers = [ "marksman" "markdown-oxide" ];
          diagnostic-severity = "warning";
        }
        { name = "nu"; indent = { tab-width = 2; unit = "  "; }; }
        {
          name = "python";
          auto-format = false;
          indent = { tab-width = 4; unit = "	"; };
          formatter = { command = "black"; args = [ "-" "-l160" ]; };
          language-servers = [ "ruff" "pylsp" ];
        }
        {
          name = "typescript";
          formatter = { command = "npx"; args = [ "prettier" "--parser" "typescript" ]; };
          language-servers = [ "typescript-language-server" "vscode-eslint-language-server" ];
        }
        {
          name = "yaml";
          file-types = [ "yaml" "yml" ];
          language-servers = [ "yaml" ];
          auto-format = false;
          formatter = { command = "prettier"; args = [ "--parser" "yaml" ]; };
        }
      ];
    };
  };
}
