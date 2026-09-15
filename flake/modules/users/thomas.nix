{ den, ... }:
{
  den.aspects.thomas = {

    includes = [
      den.aspects.ai
      den.aspects.docker
      den.aspects.infra
      den.aspects.notes
      den.aspects.terminal
      den.batteries.primary-user
    ];

    homeManager =
      { ... }:
      {
        home.stateVersion = "26.05";
        programs.home-manager.enable = true;

        home.username = "thomas";
        home.homeDirectory = "/home/thomas";

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
