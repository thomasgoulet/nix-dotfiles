{ den, ... }:
{
  den.aspects.nushell = {
    user =
      { pkgs, ... }:
      {
        shell = pkgs.nushell;
      };

    homeManager =
      { config, lib, pkgs, ... }:
      let
        inherit (lib) concatStringsSep mapAttrsToList;

        env = {
          skeleton = builtins.readFile ./nushell/env.nu;
          extra = concatStringsSep "\n" (mapAttrsToList (name: value: "$env.${name} = \"${value}\"") config.home.sessionVariables);
        };
      in
      {
        home.packages = [
          pkgs.nushell
        ];

        xdg.configFile."nushell/env.nu" = {
          text = env.extra + "\n" + env.skeleton;
        };

        programs.bat.syntaxes.nushell = {
          src = ./nushell;
          file = "nushell.sublime-syntax";
        };
      };
  };
}
