{ ... }:
{
  flake.homes.thomas = { pkgs, ... }: {
    home.packages = with pkgs; [

      # Core functionality
      nushell
      starship
      zellij

      # General utilities
      bat
      broot
      delta
      difftastic
      eza
      fd
      fzf
      hl-log-viewer
      just
      ripgrep
      sd
      zoxide


    ];
  };
}
