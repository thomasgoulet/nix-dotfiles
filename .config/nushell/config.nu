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
    search_result: { bg: red fg: white }
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
    # shape_garbage: red_underline
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
        use_ls_colors: true
        clickable_links: false
    }

    rm: {
        always_trash: false
    }

    table: {
        mode: rounded
        index_mode: auto
        padding: { left: 1, right: 1 }
        trim: {
            methodology: wrapping
            wrapping_try_keep_words: true
            truncating_suffix: "..."
        }
        header_on_separator: false
    }

    datetime_format: {
        normal: '%a, %d %b %Y %H:%M:%S %z'    # shows up in displays of variables or other datetime's outside of tables
        # table: '%m/%d/%y %I:%M:%S%p'          # generally shows up in tabular outputs such as ls. commenting this out will change it to the default human readable datetime format
    }

    display_errors: {
        exit_code: false
        termination_signal: true
    }
    error_style: "fancy"

    history: {
        max_size: 10000
        sync_on_enter: true
        file_format: "sqlite"
    }

    completions: {
        case_sensitive: false
        quick: true
        partial: true
        algorithm: "fuzzy"
        external: {
            enable: false # set to false to prevent nushell looking into $env.PATH to find more suggestions, `false` recommended for WSL users as this look up my be very slow
            max_results: 100 # setting it lower can improve completion performance at the cost of omitting some options
            completer: null
        }
        use_ls_colors: true
    }

    cursor_shape: {
        emacs: line
        vi_insert: block
        vi_normal: underscore
    }

    color_config: $theme
    footer_mode: 25 # always, never, number_of_rows, auto
    float_precision: 2
    use_ansi_coloring: true
    edit_mode: emacs
    shell_integration: {
        osc2: true
        osc7: true
        osc8: true
        osc9_9: true
        osc133: true
        osc633: true
        reset_application_mode: true
    }

    show_banner: false

    render_right_prompt_on_last_line: false
    use_kitty_protocol: false
    highlight_resolved_externals: false
    recursion_limit: 50

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
            name: history_menu
            only_buffer_difference: true
            marker: "? "
            type: {
                layout: list
                page_size: 20
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
            name: completion_menu
            modifier: none
            keycode: tab
            mode: [emacs vi_normal vi_insert]
            event: {
                until: [
                    { send: menu name: completion_menu }
                    { send: menunext }
                ]
            }
        }
        {
            name: completion_previous
            modifier: shift
            keycode: backtab
            mode: [emacs, vi_normal, vi_insert] # Note: You can add the same keybinding to all modes by using a list
            event: { send: menuprevious }
        }
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
            name: fuzzy_history
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
                              | str join (char -i 0)
                              | fzf --read0 --height 40% --reverse --inline-info +s --bind 'tab:down' --bind 'shift-tab:up' -q (commandline)
                              | decode utf-8
                              | str trim
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

source ~/.config/nushell/cache.nu
use cache

# Use zoxide
source ~/.cache/zoxide/init.nu

# Use starship
source ~/.cache/starship/init.nu

# Source aliases
source ~/.config/nushell/aliases.nu
use aliases *

# argo aliases and functions
source ~/.config/nushell/argo.nu
use argo *

# azure-cli aliases and functions
source ~/.config/nushell/az.nu
use az *

# git aliases and functions
source ~/.config/nushell/git.nu
use git *

# helix aliases and functions
source ~/.config/nushell/helix.nu
use helix *

# kubectl aliases and functions
source ~/.config/nushell/kubernetes.nu
use kubernetes *

# nix aliases and functions
source ~/.config/nushell/nix.nu
use nix *

# taskwarrior aliases and functions
source ~/.config/nushell/task.nu
use task *

# Open ZelliJ session if not inside one
if ($env | columns | where $it == ZELLIJ | is-empty) {
    zellij attach -c thomas
}
