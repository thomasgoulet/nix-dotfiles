{ pkgs, ... }:
{
  home.packages = with pkgs; [

    # Core functionality
    nushell
    zellij

    # General utilities
    delta
    difftastic
    eza
    fd
    fzf
    just
    ripgrep
    sd
    zoxide

  ];

  programs.bat = {
    enable = true;
    config = {
      theme = "Catppuccin Mocha";
      style = "changes,numbers,header,grid";
      pager = "less -RF --no-init";
    };
    syntaxes = {
      nushell = {
        src = ./bat/syntaxes;
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
        symbol = "";
        format = " [\\[[$symbol$context([/](bright-white)[$namespace](purple))]($style)\\]](bright-white)";
        disabled = false;
        contexts = [
          {
            context_pattern = ".*prod.*";
            style = "red";
          }
        ];
      };
      azure = {
        style = "yellow";
        symbol = "";
        format = " [\\[[$symbol$subscription]($style)\\]](bright-white)";
        disabled = false;
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

}
