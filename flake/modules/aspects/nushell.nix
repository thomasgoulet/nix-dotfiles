{ den, ... }:
{
  den.aspects.nushell = {
    user =
      { pkgs, ... }:
      {
        shell = pkgs.nushell;
      };

    homeManager =
      {
        config,
        lib,
        osConfig,
        pkgs,
        ...
      }:
      let
        inherit (lib) concatStringsSep mapAttrsToList;
        env =
          ((removeAttrs osConfig.environment.variables [ "PATH" ]) // config.home.sessionVariables)
          |> mapAttrsToList (name: value: "$env.${name} = \"${value}\"")
          |> concatStringsSep "\n";
      in
      {
        home.packages = [
          pkgs.nh
          pkgs.nushell
        ];

        xdg.configFile."nushell/env.nu" = {
          text = env + "\n" + (builtins.readFile ./_nushell/env.nu);
        };

        programs.bat.syntaxes.nushell = {
          src = ./_nushell;
          file = "nushell.sublime-syntax";
        };
      };
  };
}
