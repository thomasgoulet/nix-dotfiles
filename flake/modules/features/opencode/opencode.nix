{
  prompts,
  skills,
}:
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
    };
    tui = {
      theme = "catppuccin";
      scroll_acceleration.enabled = true;
    };
  };
}
