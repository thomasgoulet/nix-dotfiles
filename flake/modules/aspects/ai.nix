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
      let
        inherit (inputs) uv2nix pyproject-nix pyproject-build-systems;

        swivalSrc = pkgs.fetchFromGitHub {
          owner = "Swival";
          repo = "swival";
          rev = "1.0.39";
          hash = "sha256-OpPcn7SU4FEXCL6f/bIuK6KBpGuw5NGS8FktEWhSwF0=";
        };

        swivalWorkspace = uv2nix.lib.workspace.loadWorkspace { workspaceRoot = swivalSrc; };
        swivalOverlay = swivalWorkspace.mkPyprojectOverlay { sourcePreference = "wheel"; };
        swivalPython = pkgs.python313;
        swivalPythonBase = pkgs.callPackage pyproject-nix.build.packages {
          python = swivalPython;
        };

        swivalPythonSet = swivalPythonBase.overrideScope (
          lib.composeManyExtensions [
            pyproject-build-systems.overlays.wheel
            swivalOverlay
          ]
        );

        inherit (pkgs.callPackage pyproject-nix.build.util { }) mkApplication;

        swival = mkApplication {
          venv = swivalPythonSet.mkVirtualEnv "swival-env" swivalWorkspace.deps.default;
          package = swivalPythonSet.swival;
        };
      in
      {
        home.packages = [

          # Harness
          pkgs.opencode
          pkgs.github-copilot-cli
          swival

          # MCP Servers
          pkgs.ctx7
          pkgs.context7-mcp
          inputs'.nu-mcp.packages.default

        ];

        home.sessionVariables = {
          COPILOT_HOME = "${config.home.homeDirectory}/.config/copilot";
          OPENCODE_DISABLE_LSP_DOWNLOAD = "true";
        };
      };
  };
}
