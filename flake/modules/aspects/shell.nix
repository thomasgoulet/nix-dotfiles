{ den, ... }:
{
  den.aspects.shell = {

    user =
      { pkgs, ... }:
      {
        shell = pkgs.nushell;
        extraGroups = [ "docker" ];
      };

    homeManager =
      { pkgs, ... }:
      let
        scripts = import ./editor/scripts.nix { inherit pkgs; };
        zjstatus = pkgs.fetchurl {
          url = "https://github.com/dj95/zjstatus/releases/download/v0.23.0/zjstatus.wasm";
          sha256 = "1zv173qh67x4bf4k4m5fpz22vy0pbp6f88c0c7dkjhjj4c9901p0";
        };
      in
      {

        _module.args = scripts;

        imports = [
          ./editor/packages.nix
          ./editor/helix-settings.nix
          ./editor/helix-languages.nix
          ./editor/lazygit.nix
          ./editor/broot.nix
        ];

        home.packages = [

          # Core functionality
          pkgs.nushell
          pkgs.zellij

          # General utilities
          pkgs.delta
          pkgs.eza
          pkgs.fd
          pkgs.fzf
          pkgs.just
          pkgs.jq
          pkgs.ripgrep
          pkgs.sd
          pkgs.zoxide

        ];

        xdg.configFile."zellij/zjstatus.wasm".source = zjstatus;

        programs.bat = {
          enable = true;
          config = {
            theme = "Catppuccin Mocha";
            style = "changes,numbers,header,grid";
            pager = "less -RF --no-init";
          };
          syntaxes = {
            nushell = {
              src = ../homes/shared/bat/syntaxes;
              file = "nushell.sublime-syntax";
            };
          };
        };

        programs.starship = {
          enable = true;
          settings = {
            add_newline = true;
            format = ''
              $cmd_duration [$directory](bright-white)$kubernetes$azure$git_status
              $env_var$nix_shell$character'';

            cmd_duration = {
              format = "[ took $duration]($style)\n\n";
              style = "italic white";
              min_time = 2000;
            };

            env_var.PROMPT_EXTRA = {
              style = "italic purple";
              variable = "PROMPT_EXTRA";
              format = "[ $env_value]($style)";
            };
            nix_shell = {
              style = "italic cyan";
              format = "[ nix]($style)";
            };
            character = {
              success_symbol = " [->](bright-white)";
              error_symbol = " [|>](red)";
            };
            directory = {
              style = "blue";
              format = "[$path]($style)";
              fish_style_pwd_dir_length = 1;
            };

            kubernetes = {
              style = "green";
              format = " [\\[[[k8s::](bright-white)$context([:](bright-white)[$namespace](yellow))]($style)\\]](bright-white)";
              disabled = false;
              contexts = [
                {
                  context_pattern = ".*prod.*";
                  style = "red";
                }
              ];
            };
            git_status = {
              style = "red";
              deleted = "x";
              diverged = "[⇡⇣](purple)";
              up_to_date = "[](green)";
              format = " [\\[[$all_status$ahead_behind]($style)\\]](bright-white)";
            };
          };
        };
      };
  };
}
