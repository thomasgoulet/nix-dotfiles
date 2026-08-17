{ den, inputs, ... }:
{
  den.aspects.ai = {

    nixos =
      { pkgs, ... }:
      let
        pkgs-stable = import inputs.nixpkgs-stable {
          inherit (pkgs.stdenv.hostPlatform) system;
          config.allowUnfree = true;
        };
      in
      {
        nix.settings = {
          substituters = [ "https://cuda-maintainers.cachix.org" ];
          trusted-public-keys = [
            "cuda-maintainers.cachix.org-1:0dq3bujKpuEPMCX6U4WylrUDZ9JyUG0VpVZa73qAH0Y="
          ];
        };

        services.ollama = {
          enable = true;
          package = pkgs-stable.ollama-cuda;
          loadModels = [
            "qwen2.5-coder:7b-instruct-q4_K_M"
            "qwen3:8b"
          ];
          syncModels = true;
          environmentVariables = {
            OLLAMA_CONTEXT_LENGTH = "16384";
            OLLAMA_FLASH_ATTENTION = "1";
            OLLAMA_KV_CACHE_TYPE = "q8_0";
          };
        };
      };

    homeManager = { inputs', config, pkgs, lib, ... }:
      {
        home.packages = [
          # harness
          pkgs.opencode
          pkgs.github-copilot-cli

          # mcp servers
          pkgs.context7-mcp
          inputs'.nu-mcp.packages.default

          # tools
          pkgs.pdf-oxide
        ];

        programs.mcp = {
          enable = true;
          servers = {
            context7 = {
              command = "context7-mcp";
            };
            nu-mcp = {
              command = "nu-mcp";
              args = [ "--tools-dir" "${config.home.homeDirectory}/.config/nushell/tools" "--enable-run-nu" ];
            };
          };
        };

        programs.opencode = {
          enable = true;
          enableMcpIntegration = true;
          skills = {
            interview = ./_ai/skills/interview.md;
          };
          settings = {
            model = "anthropic/claude-haiku-4-5";
            default_agent = "build";
            autoupdate = false;
            tools."context7*" = false;
            agent = {
              review = {
                mode = "all";
                color = "accent";
                tools."*" = true;
                prompt = "You review the current branch against master (or main) branch. Structure your feedback in three sections: High-Level Architecture Decisions, Good Practices, Code Smells (nit & bugs). Indicate if the feedback is positive (+) or negative (-). Delegate documentation research (docs agent) when required to clarify library usage.";
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
                prompt = "You research documentation. Use the Context7 MCP to search official documentation, then answer the user's prompt based on what you find. Never guess — always search.";
              };
              build.color = "secondary";
              plan.color = "success";
            };
            provider.ollama = {
              npm = "@ai-sdk/openai-compatible";
              name = "local";
              options.baseURL = "http://127.0.0.1:11434/v1";
              models = {
                "qwen2.5-coder:7b-instruct-q4_K_M" = {
                  name = "qwen2.5-coder";
                  limit = {
                    context = 16384;
                    output = 4096;
                  };
                };
                "qwen3:8b" = {
                  name = "qwen3-8B";
                  limit = {
                    context = 16384;
                    output = 8192;
                  };
                };
              };
            };
          };
          tui = {
            theme = "catppuccin";
            scroll_acceleration.enabled = true;
          };
        };

        home.sessionVariables = {
          COPILOT_HOME = "${config.home.homeDirectory}/.config/copilot";
          OPENCODE_DISABLE_LSP_DOWNLOAD = "true";
        };
      };
  };
}
