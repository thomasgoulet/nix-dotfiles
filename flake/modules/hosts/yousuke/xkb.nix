# Keyboard and locale settings for the console and the graphical session.
{ ... }:
{
  services.xserver.xkb.options = "caps:escape";
  services.xserver.xkb.layout = "ca";
  console.useXkbConfig = true; # use xkb.options in tty.
}
