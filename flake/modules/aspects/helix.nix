{ den, ... }:
{
  den.aspects.helix = {
    homeManager =
      { ... }: {

        imports = [
          ./_helix/helix-languages.nix
          ./_helix/packages.nix
          ./_helix/settings.nix
        ];

        home.sessionVariables = {
          EDITOR = "hx";
        };

      };
  };
}
