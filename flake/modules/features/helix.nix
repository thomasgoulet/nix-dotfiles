{
  den,
  inputs,
  ...
}:
{
  den.aspects.helix = {
    homeManager = {
      imports = [
        (inputs.import-tree ./helix)
      ];

      config.programs.helix.enable = true;

      config.home.sessionVariables = {
        EDITOR = "hx";
      };
    };
  };
}
