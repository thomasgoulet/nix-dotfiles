if [ -e /home/thomas/.nix-profile/etc/profile.d/nix.sh ]; then . /home/thomas/.nix-profile/etc/profile.d/nix.sh; fi # added by Nix installer

function dotfiles {
   /usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME $@
}
