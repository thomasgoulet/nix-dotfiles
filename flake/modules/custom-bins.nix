{ inputs, ... }:
{
  perSystem = { pkgs, ... }: {
    packages = {
      
      backlog-md = pkgs.stdenv.mkDerivation {
        pname = "backlog-md";
        version = "1.44.0";
        src = pkgs.fetchurl {
          url = "https://registry.npmjs.org/backlog.md-linux-x64/-/backlog.md-linux-x64-1.44.0.tgz";
          sha256 = "1zc2kfzpw5m80gjnjnp8x9hpqxrldghls1p8a64hiana9j7b45zy";
        };
        dontUnpack = true;
        dontFixup = true;
        installPhase = ''
          mkdir -p $out/bin
          tar -xzf $src package/backlog
          cp package/backlog $out/bin/backlog
          chmod +x $out/bin/backlog
        '';
      };

      oasdiff = pkgs.stdenv.mkDerivation {
        pname = "oasdiff";
        version = "1.11.7";
        src = pkgs.fetchurl {
          url = "https://github.com/oasdiff/oasdiff/releases/download/v1.11.7/oasdiff_1.11.7_linux_amd64.tar.gz";
          sha256 = "093j69a9s1d4wysz7jwfpfp934z00s311ynqykb6ykppclihbwcp";
        };
        dontUnpack = true;
        installPhase = ''
          mkdir -p $out/bin
          tar -xzvf $src
          cp oasdiff $out/bin/
        '';
      };

    };
  };
}
