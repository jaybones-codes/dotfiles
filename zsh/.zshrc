# ============================================================================
# ZSH CONFIGURATION - Arch Linux
# Gruvbox Dark Theme | Lightweight | No oh-my-zsh
# ============================================================================

# ----------------------------------------------------------------------------
# GENERAL SETTINGS
# ----------------------------------------------------------------------------

# Enable colors
autoload -U colors && colors

# History settings
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_FIND_NO_DUPS
setopt HIST_SAVE_NO_DUPS
setopt SHARE_HISTORY
setopt APPEND_HISTORY
setopt INC_APPEND_HISTORY

# Directory navigation
setopt AUTO_CD              # Type directory name to cd
setopt AUTO_PUSHD           # Make cd push old directory onto stack
setopt PUSHD_IGNORE_DUPS    # Don't push duplicates
setopt PUSHD_SILENT         # Don't print directory stack

# Completion
setopt COMPLETE_IN_WORD     # Complete from both ends of word
setopt ALWAYS_TO_END        # Move cursor to end on completion
setopt AUTO_MENU            # Show completion menu on tab
setopt AUTO_LIST            # List choices on ambiguous completion

# Misc
setopt INTERACTIVE_COMMENTS # Allow comments in interactive shell
setopt MULTIOS             # Perform implicit tees/cats with multiple redirections

# ----------------------------------------------------------------------------
# KEY BINDINGS
# ----------------------------------------------------------------------------

# Use vim keybindings
bindkey -v
export KEYTIMEOUT=1

# Better vim mode
bindkey '^P' up-history
bindkey '^N' down-history
bindkey '^?' backward-delete-char
bindkey '^h' backward-delete-char
bindkey '^w' backward-kill-word
bindkey '^r' history-incremental-search-backward

# Edit command in $EDITOR
autoload -U edit-command-line
zle -N edit-command-line
bindkey -M vicmd v edit-command-line

# ----------------------------------------------------------------------------
# COMPLETION SYSTEM
# ----------------------------------------------------------------------------

# Enable completion system
autoload -Uz compinit
compinit

# Case-insensitive completion
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'

# Colored completion (different colors for dirs/files/etc)
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

# Menu selection
zstyle ':completion:*' menu select

# Better SSH/SCP/rsync completion
zstyle ':completion:*:(scp|rsync):*' tag-order 'hosts:-host:host hosts:-domain:domain hosts:-ipaddr:ip\ address *'
zstyle ':completion:*:(ssh|scp|rsync):*:hosts-host' ignored-patterns '*(.|:)*' loopback ip6-loopback localhost ip6-localhost broadcasthost
zstyle ':completion:*:(ssh|scp|rsync):*:hosts-domain' ignored-patterns '<->.<->.<->.<->' '^[-[:alnum:]]##(.[-[:alnum:]]##)##' '*@*'
zstyle ':completion:*:(ssh|scp|rsync):*:hosts-ipaddr' ignored-patterns '^(<->.<->.<->.<->|(|::)([[:xdigit:].]##:(#c,2))##(|%*))' '127.0.0.<->' '255.255.255.255' '::1' 'fe80::*'

# Process completion
zstyle ':completion:*:*:*:*:processes' command "ps -u $USER -o pid,user,comm -w -w"
zstyle ':completion:*:*:kill:*' menu yes select
zstyle ':completion:*:kill:*' force-list always

# Cache completion
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path ~/.zsh/cache

fastfetch

eval "$(starship init zsh)"
# ----------------------------------------------------------------------------
# PLUGIN INSTALLATION (Manual/Lightweight)
# ----------------------------------------------------------------------------

# Plugin directory
PLUGIN_DIR="${HOME}/.zsh/plugins"
mkdir -p "$PLUGIN_DIR"

# Function to clone or update plugins
function zsh_add_plugin() {
    local plugin_name="$1"
    local plugin_url="$2"
    local plugin_path="$PLUGIN_DIR/$plugin_name"
    
    if [[ ! -d "$plugin_path" ]]; then
        echo "Installing $plugin_name..."
        git clone "$plugin_url" "$plugin_path"
    fi
    
    # Source the plugin
    local init_file="$plugin_path/${plugin_name}.zsh"
    [[ ! -f "$init_file" ]] && init_file="$plugin_path/${plugin_name}.plugin.zsh"
    [[ -f "$init_file" ]] && source "$init_file"
}

# Install and load plugins
zsh_add_plugin "zsh-syntax-highlighting" "https://github.com/zsh-users/zsh-syntax-highlighting.git"
zsh_add_plugin "zsh-autosuggestions" "https://github.com/zsh-users/zsh-autosuggestions.git"
zsh_add_plugin "zsh-completions" "https://github.com/zsh-users/zsh-completions.git"

# Configure autosuggestions with Gruvbox colors
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=243'  # Gray color

# Configure syntax highlighting with Gruvbox colors
typeset -A ZSH_HIGHLIGHT_STYLES
ZSH_HIGHLIGHT_STYLES[command]='fg=142'           # Green
ZSH_HIGHLIGHT_STYLES[alias]='fg=142'             # Green
ZSH_HIGHLIGHT_STYLES[builtin]='fg=142'           # Green
ZSH_HIGHLIGHT_STYLES[function]='fg=142'          # Green
ZSH_HIGHLIGHT_STYLES[command-substitution]='fg=214'  # Yellow
ZSH_HIGHLIGHT_STYLES[path]='fg=109,underline'   # Blue underlined
ZSH_HIGHLIGHT_STYLES[globbing]='fg=208'          # Orange
ZSH_HIGHLIGHT_STYLES[single-quoted-argument]='fg=175'  # Purple
ZSH_HIGHLIGHT_STYLES[double-quoted-argument]='fg=175'  # Purple
ZSH_HIGHLIGHT_STYLES[comment]='fg=243'           # Gray

# ----------------------------------------------------------------------------
# FZF INTEGRATION
# ----------------------------------------------------------------------------

# FZF configuration with Gruvbox colors
if command -v fzf >/dev/null 2>&1; then
    # FZF base command
    export FZF_DEFAULT_OPTS="
        --color=bg+:#3c3836,bg:#282828,spinner:#fb4934,hl:#928374
        --color=fg:#ebdbb2,header:#928374,info:#8ec07c,pointer:#fb4934
        --color=marker:#fb4934,fg+:#ebdbb2,prompt:#fb4934,hl+:#fb4934
        --height 40% --reverse --border
    "
    
    # Use fd if available
    if command -v fd >/dev/null 2>&1; then
        export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
        export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
    fi
    
    # Load FZF key bindings
    if [[ -f /usr/share/fzf/key-bindings.zsh ]]; then
        source /usr/share/fzf/key-bindings.zsh
    fi
    
    if [[ -f /usr/share/fzf/completion.zsh ]]; then
        source /usr/share/fzf/completion.zsh
    fi
fi

# ----------------------------------------------------------------------------
# ALIASES
# ----------------------------------------------------------------------------

# Color aliases
alias ls='ls --color=auto'
alias ll='ls -lh --color=auto'
alias la='ls -lAh --color=auto'
alias grep='grep --color=auto'
alias diff='diff --color=auto'

# Safety nets
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

# Directory shortcuts
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# Git aliases
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git log --oneline --graph --decorate'
alias gd='git diff'

# Pacman aliases
alias pacu='sudo pacman -Syu'
alias pacs='pacman -Ss'
alias paci='sudo pacman -S'
alias pacr='sudo pacman -Rns'

# System
alias df='df -h'
alias du='du -h'
alias free='free -h'

# Tmux
alias ta='tmux attach -t'
alias tad='tmux attach -d -t'
alias ts='tmux new-session -s'
alias tl='tmux list-sessions'
alias tksv='tmux kill-server'
alias tkss='tmux kill-session -t'

# ----------------------------------------------------------------------------
# FUNCTIONS
# ----------------------------------------------------------------------------

# Create directory and cd into it
mkcd() {
    mkdir -p "$1" && cd "$1"
}

# Extract various archive formats
extract() {
    if [[ -f $1 ]]; then
        case $1 in
            *.tar.bz2)   tar xjf "$1"    ;;
            *.tar.gz)    tar xzf "$1"    ;;
            *.bz2)       bunzip2 "$1"    ;;
            *.rar)       unrar x "$1"    ;;
            *.gz)        gunzip "$1"     ;;
            *.tar)       tar xf "$1"     ;;
            *.tbz2)      tar xjf "$1"    ;;
            *.tgz)       tar xzf "$1"    ;;
            *.zip)       unzip "$1"      ;;
            *.Z)         uncompress "$1" ;;
            *.7z)        7z x "$1"       ;;
            *)           echo "'$1' cannot be extracted via extract()" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}

# Quick command lookup
cheat() {
    curl "cheat.sh/$1"
}

# ----------------------------------------------------------------------------
# ENVIRONMENT VARIABLES
# ----------------------------------------------------------------------------

# Default editor
export EDITOR='nvim'
export VISUAL='nvim'

# Less colors (man pages)
export LESS_TERMCAP_mb=$'\e[1;32m'
export LESS_TERMCAP_md=$'\e[1;32m'
export LESS_TERMCAP_me=$'\e[0m'
export LESS_TERMCAP_se=$'\e[0m'
export LESS_TERMCAP_so=$'\e[01;33m'
export LESS_TERMCAP_ue=$'\e[0m'
export LESS_TERMCAP_us=$'\e[1;4;31m'

# Add local bin to PATH if exists
[[ -d "$HOME/.local/bin" ]] && export PATH="$HOME/.local/bin:$PATH"

# ----------------------------------------------------------------------------
# PERFORMANCE TWEAKS
# ----------------------------------------------------------------------------

# Skip global compinit (if using system-wide oh-my-zsh)
skip_global_compinit=1

# Lazy load nvm (if installed) - uncomment if you use nvm
# export NVM_DIR="$HOME/.nvm"
# [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" --no-use

# ============================================================================
# USAGE NOTES
# ============================================================================
#
# FIRST TIME SETUP:
# 1. Install required packages:
#    sudo pacman -S fzf fd
#
# 2. Copy this file to ~/.zshrc
#
# 3. Restart your shell or run:
#    source ~/.zshrc
#
# 4. Plugins will auto-install on first launch
#
# KEY FEATURES:
# - Syntax highlighting (commands, paths, strings)
# - Auto-suggestions based on history
# - Advanced tab completion
# - FZF integration (Ctrl-R for history, Ctrl-T for files)
# - Vim keybindings
# - Git-aware prompt
# - Gruvbox color scheme throughout
#
# CUSTOMIZATION:
# - Edit colors in "GRUVBOX COLORS & PROMPT" section
# - Add more aliases in "ALIASES" section
# - Modify prompt format in git_prompt() and PROMPT variables
#
# ============================================================================
