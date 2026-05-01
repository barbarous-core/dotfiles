# If export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
not running interactively, don't do anything (leave this at the top of this file)
[[ $- != *i* ]] && return
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

# All the default Omarchy aliases and functions
# (don't mess with these directly, just overwrite them here!)
source ~/.config/shells/rc


