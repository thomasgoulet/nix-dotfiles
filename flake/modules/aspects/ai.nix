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
          pkgs.ctx7
          pkgs.context7-mcp
          inputs'.nu-mcp.packages.default

          # tools
          pkgs.pdf-oxide
        ];

        home.sessionVariables = {
          COPILOT_HOME = "${config.home.homeDirectory}/.config/copilot";
          OPENCODE_DISABLE_LSP_DOWNLOAD = "true";
        };
      };
  };
}
