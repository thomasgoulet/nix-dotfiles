{ den, ... }:
{
  den.aspects.developer = {
    includes = [ den.aspects.shell den.aspects.editor ];

    user =
      { pkgs, ... }:
      {
        shell = pkgs.nushell;
        extraGroups = [ "docker" ];
      };
  };
}
