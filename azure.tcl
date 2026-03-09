ttk::style theme create azure -parent default -settings {
    ttk::style configure . -background #1e1e2e -foreground #cdd6f4 -font "Segoe UI 10"
    ttk::style configure TButton -padding {12 8} -font "Segoe UI 10 bold"
    ttk::style configure Accent.TButton -padding {16 12} -font "Segoe UI 11 bold"
    ttk::style map Accent.TButton -background [list active #89b4fa pressed #74c7ec] -foreground [list active #11111b]
    ttk::style configure TEntry -padding {10 8}
}
ttk::style theme use azure