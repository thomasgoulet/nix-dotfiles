{ den, inputs, lib, ... }:
let
  context-length = 16384;
  models = [
    "qwen2.5-coder:7b-instruct-q4_K_M"
    "qwen3:8b"
  ];

  prompts = {
    docs = "You research documentation. Use the Context7 MCP to search official documentation, then answer the user's prompt based on what you find. Never guess — always search. Do not edit any file.";
    review = "You review the current branch against master (or main) branch. Structure your feedback in three sections: High-Level Architecture Decisions, Good Practices, Code Smells (nit & bugs). Indicate if the feedback is positive (+) or negative (-). Delegate documentation research (docs agent) when required to clarify library usage. Do not edit any file.";
  };

  mcp-servers = {
    context7 = {
      command = "context7-mcp";
    };
    nu-mcp = {
      command = "nu-mcp";
      args = [ "--tools-dir" "$HOME/.config/nushell/tools" "--enable-run-nu" ];
    };
  };

  skills = ./_ai/skills
  |> lib.filesystem.listFilesRecursive
  |> map (file: {"${(lib.removeSuffix ".md" (baseNameOf file))}" = file;})
  |> lib.attrsets.mergeAttrsList;
in
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
          loadModels = models;
          syncModels = true;
          environmentVariables = {
            OLLAMA_CONTEXT_LENGTH = (builtins.toString context-length);
            OLLAMA_FLASH_ATTENTION = "1";
            OLLAMA_KV_CACHE_TYPE = "q8_0";
          };
        };
      };

    homeManager = { inputs', config, lib, pkgs, ... }:
      {
        imports = [
          (import ./_ai/opencode.nix { inherit lib context-length models prompts skills; })
        ];

        home.packages = [
          # mcp servers
          pkgs.context7-mcp
          inputs'.nu-mcp.packages.default

          # tools
          pkgs.pdf-oxide
        ];

        programs.mcp = {
          enable = true;
          servers = mcp-servers;
        };

        programs.github-copilot-cli = {
          enable = true;
          configDir = "${config.home.homeDirectory}/.config/copilot";
          mcpServers = mcp-servers;
          skills = skills;
          settings.autoUpdate = false;
          agents = prompts
          |> lib.mapAttrs (name: prompt: ''
              ---
              name: ${name}
              description: ${lib.head (lib.strings.splitString "." prompt)}
              ---

              ${prompt}
              ''
          );
        };
      };
  };
}
