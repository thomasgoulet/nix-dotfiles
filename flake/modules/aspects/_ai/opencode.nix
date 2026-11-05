{
  lib,
  mcp-servers,
  prompts,
  skills,
}:
{
  home.sessionVariables = {
    OPENCODE_DISABLE_LSP_DOWNLOAD = "true";
  };

  programs.opencode = {
    enable = true;
    enableMcpIntegration = false;
    skills = skills;
    settings = {

      mcp.servers =
        mcp-servers
        |> lib.mapAttrs (
          _: server:
          {
            type = "local";
            command = [ server.command ] ++ (server.args or [ ]);
          }
          // lib.optionalAttrs (server.env or { } != { }) { environment = server.env; }
        );

      default_agent = "build";
      update = "disable";
      experimental = {
        todo = true;
        background_compaction = true;
      };
      permissions = [
        {
          action = "context7*";
          resource = "*";
          effect = "deny";
        }
        {
          action = "external_directory";
          resource = "*";
          effect = "ask";
        }
      ];
      agents = {
        review = {
          mode = "subagent";
          color = "#f5c2e7";
          system = prompts.review;
          permissions = [
            {
              action = "edit";
              resource = "*";
              effect = "deny";
            }
            {
              action = "context7*";
              resource = "*";
              effect = "allow";
            }
          ];
        };
        explore.permissions = [
          {
            action = "external_directory";
            resource = "*";
            effect = "ask";
          }
        ];
        docs = {
          mode = "all";
          color = "#89b4fa";
          system = prompts.docs;
          permissions = [
            {
              action = "*";
              resource = "*";
              effect = "deny";
            }
            {
              action = "context7*";
              resource = "*";
              effect = "allow";
            }
            {
              action = "read";
              resource = "*";
              effect = "allow";
            }
            {
              action = "webfetch";
              resource = "*";
              effect = "allow";
            }
            {
              action = "websearch";
              resource = "*";
              effect = "allow";
            }
            {
              action = "external_directory";
              resource = "*";
              effect = "ask";
            }
          ];
        };
        build.color = "#cba6f7";
        plan.color = "#a6e3a1";
      };
    };
  };

  xdg.configFile."opencode/cli.json" = {
    force = true;
    text = builtins.toJSON {
      "$schema" = "https://opencode.ai/v2/cli.json";
      theme = {
        name = "catppuccin";
        mode = "dark";
      };
      scroll.acceleration = true;
      diffs.wrap = "none";
      session = {
        sidebar = "hide";
        scrollbar = false;
        thinking = "show";
      };
      animations = true;
      tabs.mode = "off";
    };
  };
}
