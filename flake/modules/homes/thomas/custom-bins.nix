{ ... }:
{
  flake.homes.thomas = { custom-bins, nu-mcp, ... }: {
    home.packages = [
      custom-bins.backlog-md
      custom-bins.oasdiff
      nu-mcp
    ];
  };
}
