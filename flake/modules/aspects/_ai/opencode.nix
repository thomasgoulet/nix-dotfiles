{ lib, context-length, models, prompts, skills }:
{
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
      provider.ollama = {
        npm = "@ai-sdk/openai-compatible";
        name = "local";
        options.baseURL = "http://127.0.0.1:11434/v1";
        models = lib.attrsets.mergeAttrsList(
          models
          |> map (model: {
            "${model}" = {
              name = model;
              limit = {
                context = context-length;
                output = (context-length / 2);
              };
            };
          })
        );
      };
    };
    tui = {
      theme = "catppuccin";
      scroll_acceleration.enabled = true;
    };
  };
}
