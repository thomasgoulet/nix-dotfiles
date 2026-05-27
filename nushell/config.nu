# Nushell Config File

let theme = {
    separator: white
    leading_trailing_space_bg: { attr: n }
    header: light_gray_italic
    empty: blue
    bool: { || if $in { 'light_cyan' } else { 'light_gray' } }
    int: yellow
    filesize: cyan
    duration: cyan
    date: { || (date now) - $in | math abs |
        if $in < 1hr {
            'red'
        } else if ($in < 6hr) {
            'yellow'
        } else if ($in < 1day) {
            'green'
        } else if ($in < 3day) {
            'cyan'
        } else if ($in < 1wk) {
            'blue'
        } else if ($in < 6wk) {
            'purple'
        } else { 
            'light_gray'
        }
    }    
    range: white
    float: yellow
    string: blue
    nothing: white
    binary: white
    cellpath: cyan
    row_index: green
    record: white
    list: white
    block: white
    hints: light_gray
    search_result: blue
    shape_and: purple
    shape_binary: purple
    shape_block: blue
    shape_bool: blue
    shape_closure: green
    shape_custom: green
    shape_datetime: cyan
    shape_directory: cyan
    shape_external: cyan
    shape_externalarg: green
    shape_filepath: cyan
    shape_flag: blue
    shape_float: purple
    shape_garbage: red_underline
    shape_globpattern: cyan
    shape_int: purple
    shape_internalcall: cyan
    shape_list: blue
    shape_literal: blue
    shape_matching_brackets: { attr: u }
    shape_nothing: light_blue
    shape_operator: yellow
    shape_or: purple
    shape_pipe: purple
    shape_range: yellow
    shape_record: blue
    shape_redirection: purple
    shape_signature: green
    shape_string: green
    shape_string_interpolation: blue
    shape_table: blue
    shape_variable: purple
}

$env.config = {
    ls: {
        clickable_links: false
    }

    table: {
        index_mode: auto
        missing_value_symbol: $"(ansi red)-x-(ansi reset)"
        trim: {
            methodology: truncating
            truncating_suffix: "..."
        }
    }

    explore: {
        selected_cell: { fg: red_underline  }
    }

    datetime_format: {
        normal: '%a, %d %b %Y %H:%M:%S %z'    # shows up in displays of variables or other datetime's outside of tables
        # table: '%m/%d/%y %I:%M:%S%p'          # generally shows up in tabular outputs such as ls. commenting this out will change it to the default human readable datetime format
    }

    history: {
        max_size: 10000
        file_format: "sqlite"
    }

    completions: {
        algorithm: "fuzzy"
        external: {
            enable: false
        }
    }

    cursor_shape: {
        emacs: line
        vi_insert: block
        vi_normal: underscore
    }

    color_config: $theme
    use_ansi_coloring: true
    shell_integration: {
        osc9_9: true
    }

    show_banner: false

    hooks: {
        display_output: { ||
            if ((term size).columns >= 100) { table -e } else { table }
        }
    }

    menus: [
        {
            name: completion_menu
            only_buffer_difference: false
            marker: ""
            type: {
                layout: columnar
                columns: 1
                col_padding: 2
            }
            style: {
                text: yellow
                selected_text: yellow_reverse
                description_text: blue
            }
        }
        {
            name: help_menu
            only_buffer_difference: false
            marker: "? "
            type: {
                layout: description
                columns: 1
                col_padding: 2
                selection_rows: 10
                description_rows: 10
            }
            style: {
                text: yellow
                selected_text: yellow_reverse
                description_text: blue
            }
        }
    ]

    keybindings: [
        # Default keybindings
        {
            name: help_menu
            modifier: control
            keycode: char_h
            mode: [emacs vi_normal vi_insert]
            event: {
                until: [
                    { send: menu name: help_menu}
                    { send: menunext }
                ]
            }
        }
        {
            name: history
            modifier: control
            keycode: char_r
            mode: [emacs, vi_normal, vi_insert]
            event: [
                {
                    send: ExecuteHostCommand
                    cmd: "commandline edit (
                              history
                              | where exit_status == 0
                              | get command
                              | reverse
                              | uniq
                              | input list --fuzzy --no-footer
                          )"
                }
            ]
        }
        {
            name: cut-line
            modifier: control
            keycode: char_x
            mode: [emacs, vi_normal, vi_insert]
            event: { until: [ {edit: cutfromstart} ]
            }
        }
    ]
}

# Required modules
use std *
source ~/.config/nushell/modules/cache.nu; use cache

# Third-party
source ~/.cache/starship/init.nu
source ~/.cache/zoxide/init.nu

# Source aliases
source ~/.config/nushell/aliases.nu; use aliases *

const NU_LIB_DIRS = [
    '~/.config/nushell/modules'
]

source argo.nu; use argo *
source az.nu; use az *
source git.nu; use git *
source kubernetes.nu; use kubernetes *
source nix.nu; use nix *
source project.nu; use project *

# Open ZelliJ session if not inside one
if not ("ZELLIJ" in $env) {
    zellij attach -c thomas
}
