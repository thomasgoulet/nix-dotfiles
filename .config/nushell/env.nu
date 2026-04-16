# Nushell Environment Config File

# Environment variables
$env.BROWSER = "wslview" # `sudo ln -s (which wslview | get path.0) /usr/local/bin/xdg-open` to make app requiring xdg-open work
$env.EDITOR = "hx"
$env.KUBE_CONFIG_PATH = "/home/thomas/.kube/config"
$env.KUBECTL_EXTERNAL_DIFF = "dyff between --omit-header --set-exit-code"
$env.NIX_PROFILES = "/nix/var/nix/profiles/default /home/thomas/.nix-profile"
$env.NIX_SSL_CERT_FILE = "/etc/ssl/certs/ca-certificates.crt"
$env.OPENCODE_DISABLE_LSP_DOWNLOAD = "true"
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
