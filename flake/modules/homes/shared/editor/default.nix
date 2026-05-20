{ pkgs, ... }:
let
  scripts = import ./scripts.nix { inherit pkgs; };
in
{
  _module.args = scripts;

  imports = [
    ./packages.nix
    ./helix-settings.nix
    ./helix-languages.nix
    ./lazygit.nix
    ./broot.nix
  ];
}
