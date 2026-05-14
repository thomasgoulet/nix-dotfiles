{ self', inputs', ... }:
{
  home.packages = [
    self'.packages.backlog-md
    self'.packages.oasdiff
    inputs'.nu-mcp.packages.default
  ];
}
