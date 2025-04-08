module aliases {

    export alias bye = wsl.exe --shutdown
    export alias c = clear
    export alias b64 = decode base64
    export alias expl = explorer.exe .
    export alias l = ls -las
    export alias lg = lazygit
    export alias pshell = powershell.exe -NoExit -Command "Set-Location $env:USERPROFILE"
    export alias tf = terraform
    export alias tg = terragrunt

    def "nu-complete labs" [] {
        ls ~/labs -s | get name;
    }

    export def --env lab [
        name: string@"nu-complete labs"  # Name of the lab
        --new (-n)  # Create a new lab
    ] {
        if $new {
            let path = $"($env.HOME)/labs/(date now | format date %Y-%m-%d)-($name)"
            mkdir $path
            cd $path
        } else if ($name in (nu-complete labs)) {
            cd $"($env.HOME)/labs/($name)"
        } else {
            "Could not find the folder."
        }
    }

}
