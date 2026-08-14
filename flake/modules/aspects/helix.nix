{ den, ... }:
{
  den.aspects.helix = {
    homeManager =
      { ... }: {

        imports = [
          ./helix/helix-languages.nix
          ./helix/packages.nix
          ./helix/settings.nix
        ];

        home.sessionVariables = {
          EDITOR = "hx";
        };

      };
  };
}
