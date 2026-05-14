{ ... }:
{
  flake.homes.thomas = {
    home.stateVersion = "25.11";
    programs.home-manager.enable = true;

    home.username = "thomas";
    home.homeDirectory = "/home/thomas";
  };
}
