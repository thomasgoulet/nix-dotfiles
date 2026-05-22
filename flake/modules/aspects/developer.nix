{ den, ... }:
{
  den.aspects.developer = {
    includes = [ den.aspects.shell ];

    homeManager =
      { ... }:
      {
        imports = [
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
