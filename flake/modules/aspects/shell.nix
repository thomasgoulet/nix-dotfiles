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
      { config, lib, pkgs, ... }:
      let
        inherit (lib) concatStringsSep mapAttrsToList;

        env = {
          skeleton = builtins.readFile ./shell/env.nu;
          extra = concatStringsSep "\n" (mapAttrsToList (name: value: "$env.${name} = \"${value}\"") config.home.sessionVariables);
        };

        editorWrapper = pkgs.writeShellScript "editor-wrapper" ''
          file="$1"
          tab_id=$(zellij action list-tabs -j | jq -r '.[] | select(.active) | .tab_id')
          editor_pane=$(zellij action list-panes -j -c -t  | jq -r --argjson tid "$tab_id" --arg editor "$EDITOR" '.[] | select(.tab_id == $tid and (.title // "" | endswith($editor)) or (.pane_commend // "" | endswith($editor))) | .id')
          if [ -z "$tab_id" ] || [ -z "$editor_pane" ]; then
            exec $EDITOR "$file"
          fi
          zellij action write-chars -p "$editor_pane" ":o $file"
          zellij action send-keys -p "$editor_pane" "Enter"
        '';

        zjstatus = pkgs.fetchurl {
          url = "https://github.com/dj95/zjstatus/releases/download/v0.23.0/zjstatus.wasm";
          sha256 = "1zv173qh67x4bf4k4m5fpz22vy0pbp6f88c0c7dkjhjj4c9901p0";
        };
      in
      {

        _module.args = { inherit editorWrapper; };

        imports = [
          ./editor/packages.nix
          ./editor/helix-settings.nix
          ./editor/helix-languages.nix
          ./editor/lazygit.nix
          ./editor/broot.nix
        ];

        home.sessionVariables = {
          LS_COLORS = "di=1;34:ln=0;34:pi=0;33:bd=1;33:cd=1;33:so=1;31:ex=1;32:*README=1;4;33:*README.txt=1;4;33:*README.md=1;4;33:*readme.txt=1;4;33:*readme.md=1;4;33:*.ninja=1;4;33:*Makefile=1;4;33:*Cargo.toml=1;4;33:*SConstruct=1;4;33:*CMakeLists.txt=1;4;33:*build.gradle=1;4;33:*pom.xml=1;4;33:*Rakefile=1;4;33:*package.json=1;4;33:*Gruntfile.js=1;4;33:*Gruntfile.coffee=1;4;33:*BUILD=1;4;33:*BUILD.bazel=1;4;33:*WORKSPACE=1;4;33:*build.xml=1;4;33:*Podfile=1;4;33:*webpack.config.js=1;4;33:*meson.build=1;4;33:*composer.json=1;4;33:*RoboFile.php=1;4;33:*PKGBUILD=1;4;33:*Justfile=1;4;33:*Procfile=1;4;33:*Dockerfile=1;4;33:*Containerfile=1;4;33:*Vagrantfile=1;4;33:*Brewfile=1;4;33:*Gemfile=1;4;33:*Pipfile=1;4;33:*build.sbt=1;4;33:*mix.exs=1;4;33:*bsconfig.json=1;4;33:*tsconfig.json=1;4;33:*.zip=0;31:*.tar=0;31:*.Z=0;31:*.z=0;31:*.gz=0;31:*.bz2=0;31:*.a=0;31:*.ar=0;31:*.7z=0;31:*.iso=0;31:*.dmg=0;31:*.tc=0;31:*.rar=0;31:*.par=0;31:*.tgz=0;31:*.xz=0;31:*.txz=0;31:*.lz=0;31:*.tlz=0;31:*.lzma=0;31:*.deb=0;31:*.rpm=0;31:*.zst=0;31:*.lz4=0;31";
          PAGER = "less -RF --no-init";
        };

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

        xdg.configFile."nushell/env.nu" = {
          text = env.extra + "\n" + env.skeleton;
        };

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
              $env_var$character'';

            cmd_duration = {
              format = "[ took $duration]($style)\n\n";
              style = "italic white";
              min_time = 2000;
            };

            env_var.ESCAPE_MODE = {
              style = "italic purple";
              variable = "ESCAPE_MODE";
              format = "[ $env_value]($style)";
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
