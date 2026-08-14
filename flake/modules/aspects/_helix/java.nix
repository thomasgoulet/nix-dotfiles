{ pkgs, ... }:
let
  lombok = pkgs.fetchurl {
    url = "https://projectlombok.org/downloads/lombok-1.18.44.jar";
    sha256 = "11mz6l8c1vvaswxx10az7q201dprmaamw67f4pxixfsqqgyipsf6";
  };
in
{
  home.packages = [
    pkgs.jdk25_headless
    (pkgs.jdt-language-server.override { jdk = pkgs.jdk25_headless; })
  ];

  programs.helix.languages.language-server.jdtls = {
    command = "jdtls";
    args = [ "--jvm-arg=-javaagent:${lombok}" ];
  };
}
