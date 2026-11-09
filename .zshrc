# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH=$HOME/.oh-my-zsh

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="amuse"

plugins=()

source $ZSH/oh-my-zsh.sh

# Activate mise so a repo's enter hook can load its aliases and zsh functions
if command -v mise >/dev/null 2>&1; then
  eval "$(mise activate zsh)"
fi

# Bash-style completions the devcontainer ships
if [[ -f /etc/zsh/bash-compatible-completions ]]; then
  source /etc/zsh/bash-compatible-completions
fi
