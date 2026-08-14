{ ... }:
{
  nix.settings = {
    auto-optimise-store = true;
    experimental-features = [ "pipe-operators" "nix-command" "flakes" ];
    trusted-users = [ "root" "thomas" ];
  };

  nix.gc = {
    automatic = true;
    persistent = true;
    dates = "Fri *-*-* 06:00:00";
    options = "--delete-older-than 7d";
  };
}
