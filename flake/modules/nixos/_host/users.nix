{ inputs', ... }:
{
  users.users.thomas = {
    shell = inputs'.nixpkgs.legacyPackages.nushell;
    extraGroups = [ "docker" ];
  };
}
