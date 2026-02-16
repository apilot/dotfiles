# FZF word search function
# Searches for the word under cursor in current project directory using fzf

function fzf-word-search() {
    local word_under_cursor
    local initial_query=""
    
    # Get the current command line buffer
    local buffer="$LBUFFER"
    
    # Extract the word under cursor (last word in buffer)
    if [[ -n "$buffer" ]]; then
        # Get the last word from the buffer
        word_under_cursor=(${(z)buffer})
        word_under_cursor="${word_under_cursor[-1]}"
        
        # Remove any special characters from the beginning
        word_under_cursor="${word_under_cursor#[^a-zA-Z0-9_]}"
        
        if [[ -n "$word_under_cursor" ]]; then
            initial_query="-q $word_under_cursor"
        fi
    fi

    # Save current cursor position
    local cur_prompt=$PS1
    local cur_rprompt=$RPROMPT

    # Open fzf to search files in current directory (project)
    # Using fd if available, otherwise find
    if command -v fd &> /dev/null; then
        local files=$(fd --type f --hidden --follow --exclude .git --exclude node_modules --exclude vendor --exclude .git 2>/dev/null)
    else
        local files=$(find . -type f -not -path '*/\.git/*' -not -path '*/node_modules/*' -not -path '*/vendor/*' 2>/dev/null)
    fi

    local file=$(echo "$files" | \
        fzf --tmux bottom,40% --layout reverse --border top --info=inline --margin=1 --padding=1 \
        --preview 'fzf-preview.sh {}' \
        --height 40% \
        --multi $initial_query)

    if [[ -n "$file" ]]; then
        # Open selected file in nvim
        nvim "$file"
    fi

    # Redraw prompt
    zle reset-prompt
}

# Create zle widget
zle -N fzf-word-search

# Bind keys for different modes
# In vim insert mode: Ctrl+Space
bindkey -M viins '^ ' fzf-word-search

# In vim normal mode: Space (leader-like)
bindkey -M vicmd ' ' fzf-word-search

# Also add Ctrl+f as alternative
bindkey '^f' fzf-word-search
