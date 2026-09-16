{ den, ... }:
{
  den.aspects.thom = {

    includes = [
      den.aspects.docker
      den.aspects.notes
      den.aspects.terminal
      den.batteries.primary-user
    ];

    homeManager =
      { ... }:
      {
        home.stateVersion = "26.05";
        programs.home-manager.enable = true;

        home.username = "thom";
        home.homeDirectory = "/home/thom";

        programs.git = {
          enable = true;
          settings = {
            credential.helper = "store";
            push.autoSetupRemote = true;
          };
        };
      };
  };
}
