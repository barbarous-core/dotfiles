# Start configuration added by Zim Framework install {{{
#
# User configuration sourced by interactive shells
#

# -----------------
# Zsh configuration
# -----------------

#
# History
#

# Remove older command from the history if a duplicate is to be added.
setopt HIST_IGNORE_ALL_DUPS

#
# Input/output
#

# Set editor default keymap to emacs (`-e`) or vi (`-v`)
bindkey -e

# Prompt for spelling correction of commands.
#setopt CORRECT

# Customize spelling correction prompt.
#SPROMPT='zsh: correct %F{red}%R%f to %F{green}%r%f [nyae]? '

# Remove path separator from WORDCHARS.
WORDCHARS=${WORDCHARS//[\/]}

# --------------------
# Module configuration
# --------------------

#
# git
#

# Set a custom prefix for the generated aliases. The default prefix is 'G'.
#zstyle ':zim:git' aliases-prefix 'g'

#
# input
#

# Append `../` to your input for each `.` you type after an initial `..`
#zstyle ':zim:input' double-dot-expand yes

#
# termtitle
#

# Set a custom terminal title format using prompt expansion escape sequences.
# See http://zsh.sourceforge.net/Doc/Release/Prompt-Expansion.html#Simple-Prompt-Escapes
# If none is provided, the default '%n@%m: %~' is used.
#zstyle ':zim:termtitle' format '%1~'

#
# zsh-autosuggestions
#

# Disable automatic widget re-binding on each precmd. This can be set when
# zsh-users/zsh-autosuggestions is the last module in your ~/.zimrc.
ZSH_AUTOSUGGEST_MANUAL_REBIND=1

# Customize the style that the suggestions are shown with.
# See https://github.com/zsh-users/zsh-autosuggestions/blob/master/README.md#suggestion-highlight-style
#ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=242'

#
# zsh-syntax-highlighting
#

# Set what highlighters will be used.
# See https://github.com/zsh-users/zsh-syntax-highlighting/blob/master/docs/highlighters.md
ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets)

# Customize the main highlighter styles.
# See https://github.com/zsh-users/zsh-syntax-highlighting/blob/master/docs/highlighters/main.md#how-to-tweak-it
#ZSH_HIGHLIGHT_STYLES[comment]='fg=242'

# -----------------
# Completion & fzf-tab
# -----------------

# Disable caching for completion
zstyle ':completion:*' use-cache true
zstyle ':completion:*' cache-path "${ZDOTDIR:-$HOME}/.zcompcache"

# Matching control: case-insensitive, hyphen-insensitive, and partial matching
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'

# fzf-tab configuration
# ---------------------

# Preview directory contents with eza when completing 'cd'
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always $realpath'

# Preview process details when completing 'kill'
zstyle ':fzf-tab:complete:kill:argument-rest' fzf-preview 'ps --pid=$word -o cmd --no-headers -w -w'
zstyle ':fzf-tab:complete:kill:argument-rest' fzf-flags '--preview-window=down:3:wrap'

# Use tmux popup if in a tmux session
zstyle ':fzf-tab:*' fzf-command ftb-tmux-popup

# Custom colors for fzf-tab
zstyle ':fzf-tab:*' fzf-flags '--color=bg+:23'

# Switch groups using < and >
zstyle ':fzf-tab:*' switch-group '<' '>'

# ------------------
# Initialize modules
# ------------------

ZIM_HOME=${ZDOTDIR:-${HOME}}/.zim
# Download zimfw plugin manager if missing.
if [[ ! -e ${ZIM_HOME}/zimfw.zsh ]]; then
  if (( ${+commands[curl]} )); then
    curl -fsSL --create-dirs -o ${ZIM_HOME}/zimfw.zsh \
        https://github.com/zimfw/zimfw/releases/latest/download/zimfw.zsh
  else
    mkdir -p ${ZIM_HOME} && wget -nv -O ${ZIM_HOME}/zimfw.zsh \
        https://github.com/zimfw/zimfw/releases/latest/download/zimfw.zsh
  fi
fi
# Install missing modules, and update ${ZIM_HOME}/init.zsh if missing or outdated.
if [[ ! ${ZIM_HOME}/init.zsh -nt ${ZIM_CONFIG_FILE:-${ZDOTDIR:-${HOME}}/.zimrc} ]]; then
  source ${ZIM_HOME}/zimfw.zsh init
fi
# Initialize modules.
source ${ZIM_HOME}/init.zsh
# }}} End configuration added by Zim Framework install


# Automatic bicon for Arabic support in TTY
if [[ "$TERM" == "linux" ]] && [[ -z "$BICON_RUNNING" ]]; then
    export BICON_RUNNING=1
    exec bicon
fi

source ~/.config/shells/rc

# -----------------
# Custom Logic
# -----------------

# Deno
if [[ -f "$HOME/.deno/env" ]]; then
  . "$HOME/.deno/env"
fi
if [[ ":$FPATH:" != *":$HOME/.zsh/completions:"* ]]; then 
    export FPATH="$HOME/.zsh/completions:$FPATH"
fi

# ── yt-pick: paste a YouTube URL in the terminal → interactive download TUI ──
_yt_pick_handler() {
    # ONLY trigger if the entire command is JUST the URL (ignoring surrounding spaces/escapes)
    if [[ "$BUFFER" =~ '^[[:space:]]*https?://[^ ]*(youtube\.com|youtu\.be)[^ ]*[[:space:]]*$' ]]; then
        # Clean URL of shell escapes (\) and rewrite command
        local url="${BUFFER//\\/}"
        BUFFER="python3 /run/media/mohamed/PRODUCTION/MyScriptsWorkflow/yt-pick ${(q)url}"
    fi
    zle .accept-line
}
zle -N _yt_pick_handler
bindkey '^M' _yt_pick_handler
bindkey '^J' _yt_pick_handler

# End of .zshrc
