export BREW_GLOBAL="/opt/homebrew/bin/brew"
export BREW_LOCAL="/usr/local/bin/brew"
if [ "${BREW_GLOBAL}" ]; then
  eval "$(${BREW_GLOBAL} shellenv)"
elif [ "${BREW_LOCAL}" ]; then
  eval "$(${BREW_LOCAL} shellenv)"
fi

# starship
eval "$(starship init zsh)"

# zoxide
eval "$(zoxide init zsh)"

# pnpm
export PNPM_HOME="$HOME/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac

# Neovim
export NEOVIM_HOME=$HOME/.local/nvim
if [ -d "${NEOVIM_HOME}" ]; then
  export PATH="${NEOVIM_HOME}/bin:$PATH"
fi

export PATH="$HOME/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"

# cargo
export CARGO_HOME=$HOME/.cargo
if [ -d "${CARGO_HOME}" ]; then
  export PATH="${CARGO_HOME}/bin:$PATH"
fi

# Volta
export VOLTA_HOME=$HOME/.volta/bin
# asdf
export ASDF_HOME=${ASDF_DATA_DIR:-$HOME/.asdf}
if [ -d "${ASDF_HOME}" ]; then
  export PATH="${ASDF_HOME}/shims:$PATH"
elif [ -d "${VOLTA_HOME}" ]; then
  export PATH="${VOLTA_HOME}/bin:$PATH"
fi

# npm completion
eval "`npm completion`" 

# deno
export DENO_HOME=$HOME/.deno
if [ -d "${DENO_HOME}" ]; then
  export PATH="${DENO_HOME}/bin:$PATH"
fi

# go
export GO_HOME=$HOME/go
if [ -d "${GO_HOME}" ]; then
  export PATH="${GO_HOME}/bin:$PATH"
fi

_direnv_hook() {
  trap -- '' SIGINT
  eval "$("/opt/homebrew/bin/direnv" export zsh)"
  trap - SIGINT
}
typeset -ag precmd_functions
if (( ! ${precmd_functions[(I)_direnv_hook]} )); then
  precmd_functions=(_direnv_hook $precmd_functions)
fi
typeset -ag chpwd_functions
if (( ! ${chpwd_functions[(I)_direnv_hook]} )); then
  chpwd_functions=(_direnv_hook $chpwd_functions)
fi

autoload -Uz edit-command-line
zle -N edit-command-line

# Ctrl+oでコマンドライン編集モードに移行
bindkey "^o" edit-command-line

# Alt+aを無効化
bindkey -r "^[a"

# noglob hook flag
_DID_SET_NOGLOB=0

# コマンドが実行前hook
auto_noglob_corrected_preexec() {
  _DID_SET_NOGLOB=0

  local -a words=("${(z)1}")
  local contains_bracket=0
  local contains_standalone_glob=0

  for word in "${words[@]}"; do
    if [[ "$word" == *'['* || "$word" == *']'* ]]; then
      contains_bracket=1
    elif [[ "$word" == *\** || "$word" == *\?* ]]; then
      contains_standalone_glob=1
    fi
  done
  
  if (( contains_bracket && !contains_standalone_glob )); then
    setopt noglob
    _DID_SET_NOGLOB=1
  fi
}

# コマンドが実行後hook
auto_noglob_corrected_precmd() {
  if (( _DID_SET_NOGLOB )); then
    unsetopt noglob
    _DID_SET_NOGLOB=0
  fi
}

# register hook
autoload -Uz add-zsh-hook
add-zsh-hook preexec auto_noglob_corrected_preexec
add-zsh-hook precmd  auto_noglob_corrected_precmd
