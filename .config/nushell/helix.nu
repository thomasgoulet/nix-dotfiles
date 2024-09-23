module helix {

    def "nu-complete zoxide repos" [] {
        zoxide query -l -s
        | from ssv -m 1 -n
        | rename score description
        | where description =~ repos\/
        | insert value {|r|
            $r.description | path basename
        }
    }

    # Open folder from zoxide picker in a different zellij tab
    export def prj [
        ...hint: string@"nu-complete zoxide repos"
    ] {
        mut dir = "";
        if ($hint == ["."]) {
            $dir = $env.PWD;
        } else if ($hint != []) {
            $dir = (zoxide query ...$hint);
        } else {
            $dir = (zoxide query -i);
        }

        if ($dir != "") {
            zellij action new-tab -c $dir -n (basename $dir) -l ~/.config/zellij/layouts/edit.kdl
        }
    }
  
}
