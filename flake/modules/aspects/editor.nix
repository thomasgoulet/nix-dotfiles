{ den, ... }:
{
  den.aspects.editor = {
    homeManager =
      { pkgs, ... }:
      let
        scripts = import ./editor/scripts.nix { inherit pkgs; };
      in
      {
        _module.args = scripts;

        imports = [
          ./editor/packages.nix
          ./editor/helix-settings.nix
          ./editor/helix-languages.nix
          ./editor/lazygit.nix
          ./editor/broot.nix
        ];
      };
  };
}
