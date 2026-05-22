{ den, ... }:
{
  den.aspects.developer = {
    homeManager =
      { ... }:
      {
        imports = [
          ../homes/shared/shell.nix
          ../homes/shared/editor
        ];
      };

    user =
      { pkgs, ... }:
      {
        shell = pkgs.nushell;
        extraGroups = [ "docker" ];
      };
  };
}
