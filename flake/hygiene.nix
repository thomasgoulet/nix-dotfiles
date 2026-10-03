# Formatting and self-checks. Imported explicitly from flake.nix (as opposed to
# the import-tree scan of ./aspects) because these are flake-parts outputs, not
# den aspects.
{
  self,
  ...
}:
{
  perSystem =
    { pkgs, ... }:
    let
      treefmt-config = pkgs.writeText "treefmt.toml" ''
        [formatter.nixfmt]
        command = "nixfmt"
        includes = ["*.nix"]
      '';

      # The tree root is pinned to the flake source so `nix fmt` formats the
      # flake from anywhere in the repository.
      treefmt = pkgs.writeShellApplication {
        name = "treefmt";
        runtimeInputs = [
          pkgs.nixfmt
          pkgs.treefmt
        ];
        text = ''
          exec treefmt \
            --config-file ${treefmt-config} \
            --tree-root ${self} \
            "$@"
        '';
      };
    in
    {
      # `nix fmt`
      formatter = treefmt;

      # `nix flake check` fails when a file in the flake is not formatted.
      checks.formatting = pkgs.runCommand "flake-formatting" { } ''
        ${treefmt}/bin/treefmt --fail-on-change --no-cache
        touch $out
      '';
    };
}
