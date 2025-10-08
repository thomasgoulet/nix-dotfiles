# Nushell Environment Config File

# Environment variables
$env.BROWSER = "wslview" # `sudo ln -s (which wslview | get path.0) /usr/local/bin/xdg-open` to make app requiring xdg-open work
$env.EDITOR = "hx"
$env.KUBE_CONFIG_PATH = "/home/thomas/.kube/config"
$env.KUBECTL_EXTERNAL_DIFF = "delta --paging never"
$env.LS_COLORS = "di=1;34:ln=0;34:pi=0;33:bd=1;33:cd=1;33:so=1;31:ex=1;32:*README=1;4;33:*README.txt=1;4;33:*README.md=1;4;33:*readme.txt=1;4;33:*readme.md=1;4;33:*.ninja=1;4;33:*Makefile=1;4;33:*Cargo.toml=1;4;33:*SConstruct=1;4;33:*CMakeLists.txt=1;4;33:*build.gradle=1;4;33:*pom.xml=1;4;33:*Rakefile=1;4;33:*package.json=1;4;33:*Gruntfile.js=1;4;33:*Gruntfile.coffee=1;4;33:*BUILD=1;4;33:*BUILD.bazel=1;4;33:*WORKSPACE=1;4;33:*build.xml=1;4;33:*Podfile=1;4;33:*webpack.config.js=1;4;33:*meson.build=1;4;33:*composer.json=1;4;33:*RoboFile.php=1;4;33:*PKGBUILD=1;4;33:*Justfile=1;4;33:*Procfile=1;4;33:*Dockerfile=1;4;33:*Containerfile=1;4;33:*Vagrantfile=1;4;33:*Brewfile=1;4;33:*Gemfile=1;4;33:*Pipfile=1;4;33:*build.sbt=1;4;33:*mix.exs=1;4;33:*bsconfig.json=1;4;33:*tsconfig.json=1;4;33:*.zip=0;31:*.tar=0;31:*.Z=0;31:*.z=0;31:*.gz=0;31:*.bz2=0;31:*.a=0;31:*.ar=0;31:*.7z=0;31:*.iso=0;31:*.dmg=0;31:*.tc=0;31:*.rar=0;31:*.par=0;31:*.tgz=0;31:*.xz=0;31:*.txz=0;31:*.lz=0;31:*.tlz=0;31:*.lzma=0;31:*.deb=0;31:*.rpm=0;31:*.zst=0;31:*.lz4=0;31"
$env.NIX_PROFILES = "/nix/var/nix/profiles/default /home/thomas/.nix-profile"
$env.NIX_SSL_CERT_FILE = "/etc/ssl/certs/ca-certificates.crt"
$env.PAGER = "less -RF --no-init"
$env.STARSHIP_CONFIG = "/home/thomas/.config/starship/config.toml"
$env._ZO_FZF_OPTS = "--color=16 --inline-info --tiebreak length --bind 'tab:down' --bind 'shift-tab:up'"

$env.ENV_CONVERSIONS = {
    "PATH": {
        from_string: { |s| $s | split row (char esep) | path expand -n }
        to_string: { |v| $v | path expand -n | str join (char esep) }
    }
    "Path": {
        from_string: { |s| $s | split row (char esep) | path expand -n }
        to_string: { |v| $v | path expand -n | str join (char esep) }
    }
}

$env.NU_LIB_DIRS = [
    ($nu.config-path | path dirname | path join 'scripts')
]

$env.NU_PLUGIN_DIRS = [
    ($nu.config-path | path dirname | path join 'plugins')
]

$env.PATH = ($env.PATH | split row (char esep))
use std "path add"

path add 'local/bin'
path add 'cargo/bin'
path add '/home/thomas/'
path add '/home/thomas/bin'
path add '/home/thomas/go/bin'
path add '/home/thomas/.config/carapace/bin'
path add '/home/thomas/.local/bin'
path add '/home/thomas/.nix-profile/bin'

$env.PATH = ($env.PATH | uniq)

# Use zoxide
let zoxide_init_path = '~/.cache/zoxide/init.nu' | path expand
if not ($zoxide_init_path | path exists) {
    mkdir ~/.cache/zoxide | ignore
    zoxide init nushell --cmd j | save -f $zoxide_init_path
}

# Use starship
let starship_init_path = '~/.cache/starship/init.nu' | path expand
if not ($starship_init_path | path exists) {
    mkdir ~/.cache/starship | ignore
    starship init nu | save -f $starship_init_path
}
$env.TRANSIENT_PROMPT_COMMAND = {"\n " + (starship module directory) + (starship module character)}
