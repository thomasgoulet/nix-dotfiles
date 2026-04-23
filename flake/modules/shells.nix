{ inputs, ... }:
{
  perSystem = { config, pkgs, ... }: {
    devShells = {
      
      python = pkgs.mkShell {
        packages = with pkgs; [
          python312
          python312Packages.pandas
          python312Packages.numpy
        ];
      };

    };
  };
}
