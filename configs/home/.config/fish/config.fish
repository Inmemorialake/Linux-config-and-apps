# ~/.config/fish/config.fish

starship init fish | source

alias ls="eza -lah --icons --group-directories-first"
alias cat="bat --paging=never --theme='Catppuccin Frappe'"
alias ..="cd .."

if test "$TERM_PROGRAM" = "vscode"; or set -q JETBRAINS_IDE
    set -gx IDE_SHELL 1
end

if not set -q IDE_SHELL
    fastfetch
end

# >>> mamba initialize >>>
# !! Contents within this block are managed by 'mamba shell init' !!
set -gx MAMBA_EXE "/home/Inmemorialake/miniforge3/bin/mamba"
set -gx MAMBA_ROOT_PREFIX "/home/Inmemorialake/miniforge3"
set -gx JUPYTER_PATH /home/Inmemorialake/miniforge3/envs/cling/share/jupyter
$MAMBA_EXE shell hook --shell fish --root-prefix $MAMBA_ROOT_PREFIX | source
# <<< mamba initialize <