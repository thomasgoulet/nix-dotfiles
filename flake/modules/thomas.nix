{ den, ... }:
{
  den.aspects.thomas = {
    includes = [ den.aspects.developer den.aspects.sysops ];

    homeManager =
      { ... }:
      {
        imports = [
          ./homes/thomas/default.nix
          ./homes/thomas/custom-bins.nix
          ./homes/thomas/git.nix
        ];
      };
  };
}
