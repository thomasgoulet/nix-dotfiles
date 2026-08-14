{ den, inputs, lib, ... }:
{
  den.aspects.helix = {
    homeManager = {
      imports = [
        (inputs.import-tree ./_helix)
      ];

      options.helix.notes.enable = lib.mkEnableOption "notes tooling in helix";

      config.programs.helix.enable = true;

      config.home.sessionVariables = {
        EDITOR = "hx";
      };
    };
  };
}
