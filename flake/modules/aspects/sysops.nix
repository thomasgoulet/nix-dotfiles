{ den, ... }:
{
  den.aspects.sysops = {
    homeManager =
      { ... }:
      {
        imports = [
          ../homes/shared/azure.nix
          ../homes/shared/infra.nix
        ];
      };
  };
}
