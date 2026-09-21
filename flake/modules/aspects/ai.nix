{
  den,
  inputs,
  lib,
  ...
}:
let
  context-length = 16384;
  models = [
    "qwen2.5-coder:7b-instruct-q4_K_M"
    "qwen3:8b"
  ];

  # One llama-server instance per model (vanilla llama.cpp serves a single
  # model per process, unlike Ollama's hot-swapping), each downloading and
  # caching its GGUF straight from Hugging Face.
  llama-server-models = [
    {
      name = "qwen2-5-coder-7b-instruct-q4-k-m";
      hfRepo = "Qwen/Qwen2.5-Coder-7B-Instruct-GGUF";
      hfFile = "qwen2.5-coder-7b-instruct-q4_k_m.gguf";
      port = 11434;
    }
    {
      name = "qwen3-8b-q4-k-m";
      hfRepo = "Qwen/Qwen3-8B-GGUF";
      hfFile = "Qwen3-8B-Q4_K_M.gguf";
      port = 11435;
    }
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
      args = [
        "--tools-dir"
        "/home/thomas/.config/nushell/tools"
        "--enable-run-nu"
      ];
    };
  };

  skills =
    ./_ai/skills
    |> lib.filesystem.listFilesRecursive
    |> map (file: {
      "${(lib.removeSuffix ".md" (baseNameOf file))}" = file;
    })
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
        llama-server-pkg = pkgs-stable.llama-cpp.override { cudaSupport = true; };

        mkLlamaServerService =
          {
            name,
            hfRepo,
            hfFile,
            port,
          }:
          {
            name = "llama-server-${name}";
            value = {
              description = "llama.cpp server (${name})";
              after = [ "network-online.target" ];
              wants = [ "network-online.target" ];
              serviceConfig = {
                ExecStart = lib.escapeShellArgs [
                  "${llama-server-pkg}/bin/llama-server"
                  "--host"
                  "127.0.0.1"
                  "--port"
                  (builtins.toString port)
                  "--ctx-size"
                  (builtins.toString context-length)
                  "--n-gpu-layers"
                  "999"
                  "--flash-attn"
                  "auto"
                  "--alias"
                  name
                  "--hf-repo"
                  hfRepo
                  "--hf-file"
                  hfFile
                ];
                DynamicUser = true;
                StateDirectory = "llama-server-${name}";
                Environment = [ "HOME=%S/llama-server-${name}" ];
                Restart = "on-failure";
                RestartSec = 5;
              };
            };
          };
      in
      {
        nix.settings = {
          substituters = [
            "https://cuda-maintainers.cachix.org"
            "https://llama-cpp.cachix.org"
          ];
          trusted-public-keys = [
            "cuda-maintainers.cachix.org-1:0dq3bujKpuEPMCX6U4WylrUDZ9JyUG0VpVZa73qAH0Y="
            "llama-cpp.cachix.org-1:H75X+w83wUKTIPSO1KWy9ADUrzThyGs8P5tmAbkWhQc="
          ];
        };

        systemd.services = lib.listToAttrs (map mkLlamaServerService llama-server-models);
      };

    homeManager =
      {
        inputs',
        config,
        lib,
        pkgs,
        ...
      }:
      let
        pkgs-stable = inputs'.nixpkgs-stable.legacyPackages;
      in
      {
        imports = [
          (import ./_ai/opencode.nix {
            inherit
              lib
              context-length
              models
              prompts
              skills
              ;
          })
        ];

        home.packages = [
          # mcp servers
          pkgs.context7-mcp
          inputs'.nu-mcp.packages.default

          # tools
          pkgs-stable.pdf-oxide
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
          agents =
            prompts
            |> lib.mapAttrs (
              name: prompt: ''
                ---
                name: ${name}
                description: ${lib.head (lib.strings.splitString "." prompt)}
                ---

                ${prompt}
              ''
            );
        };

        xdg.configFile."copilot/settings.json" = {
          source = (pkgs.formats.json { }).generate "github-copilot-cli-settings.json" {
            autoUpdate = false;
            theme = "default";
          };
        };
      };
  };
}
