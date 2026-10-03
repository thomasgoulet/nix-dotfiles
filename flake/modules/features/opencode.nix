# opencode (https://opencode.ai), the AI coding agent, with its MCP servers and per-agent prompts.
{
  den,
  lib,
  ...
}:
let
  prompts = {
    docs = "You research documentation. Use the Context7 MCP to search official documentation, then answer the user's prompt based on what you find. Never guess — always search. Do not edit any file.";
    review = "You review the current branch against master (or main) branch. Structure your feedback in three sections: High-Level Architecture Decisions, Good Practices, Code Smells (nit & bugs). Indicate if the feedback is positive (+) or negative (-). Delegate documentation research (docs agent) when required to clarify library usage. Do not edit any file.";
  };

  # TODO - This could be changed to use import-tree
  skills =
    ./opencode/skills
    |> lib.filesystem.listFilesRecursive
    |> map (file: {
      "${(lib.removeSuffix ".md" (baseNameOf file))}" = file;
    })
    |> lib.attrsets.mergeAttrsList;
in
{
  den.aspects.opencode = {

    homeManager =
      {
        config,
        inputs',
        pkgs,
        ...
      }:
      let
        pkgs-stable = inputs'.nixpkgs-stable.legacyPackages;
      in
      {
        home.packages = [
          pkgs.context7-mcp
          pkgs-stable.pdf-oxide
          inputs'.nu-mcp.packages.default
        ];

        programs.mcp = {
          enable = true;
          servers = {
            context7.command = "context7-mcp";
            nu-mcp = {
              command = "nu-mcp";
              args = [
                "--tools-dir"
                "${config.home.homeDirectory}/.config/nushell/tools"
                "--enable-run-nu"
              ];
            };
          };
        };

        home.sessionVariables = {
          OPENCODE_DISABLE_LSP_DOWNLOAD = "true";
        };

        programs.opencode = {
          enable = true;
          enableMcpIntegration = true;
          skills = skills;
          settings = {
            model = "anthropic/claude-sonnet-5";
            default_agent = "build";
            autoupdate = false;
            tools."context7*" = false;
            agent = {
              review = {
                mode = "all";
                color = "accent";
                tools."*" = true;
                prompt = prompts.review;
              };
              docs = {
                mode = "all";
                color = "info";
                tools = {
                  "*" = false;
                  read = true;
                  webfetch = true;
                  websearch = true;
                  "context7*" = true;
                };
                prompt = prompts.docs;
              };
              build.color = "secondary";
              plan.color = "success";
            };
          };
          tui = {
            theme = "catppuccin";
            scroll_acceleration.enabled = true;
          };
        };
      };
  };
}
