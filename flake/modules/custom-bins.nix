{ inputs, ... }:
{
  perSystem = { pkgs, system, ... }: {
    packages = {

      backlog-md = inputs.backlog-md.packages.${system}.default;

      oasdiff = pkgs.stdenv.mkDerivation {
        pname = "oasdiff";
        version = "1.11.7";
        src = pkgs.fetchurl {
          url = "https://github.com/oasdiff/oasdiff/releases/download/v1.11.7/oasdiff_1.11.7_linux_amd64.tar.gz";
          sha256 = "093j69a9s1d4wysz7jwfpfp934z00s311ynqykb6ykppclihbwcp";
        };

        sourceRoot = ".";

        nativeBuildInputs = [ pkgs.autoPatchelfHook ];
        buildInputs = [ pkgs.stdenv.cc.cc.lib ];

        installPhase = ''
          mkdir -p $out/bin
          cp oasdiff $out/bin/
          chmod +x $out/bin/oasdiff
        '';
      };

    };
  };
}
