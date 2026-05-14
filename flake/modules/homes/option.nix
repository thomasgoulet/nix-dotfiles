{ lib, ... }:
{
  options.flake.homes = lib.mkOption {
    type = lib.types.attrsOf lib.types.deferredModule;
    default = { };
    description = ''
      Home-manager configurations keyed by user name.
      Each value is a deferred module merged from all contributing flake-parts modules.
      Referenced from nixosConfigurations via inputs.self.homes.<name>.
    '';
  };
}
