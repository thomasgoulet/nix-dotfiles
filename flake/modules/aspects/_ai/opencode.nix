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

      model = "anthropic/claude-sonnet-5";
      default_agent = "build";
      update = "disable";
      permissions = [
        {
          action = "context7*";
          resource = "*";
          effect = "deny";
        }
      ];
      agents = {
        review = {
          mode = "all";
          color = "#cba6f7";
          system = prompts.review;
        };
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
          ];
        };
        build.color = "#f5c2e7";
        plan.color = "#a6e3a1";
      };
    };
  };

  xdg.configFile."opencode/cli.json" = {
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
    };
  };
}
