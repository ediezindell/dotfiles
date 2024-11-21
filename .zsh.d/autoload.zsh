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
if [ -d "${VOLTA_HOME}" ]; then
  export PATH="${VOLTA_HOME}/bin:$PATH"
fi

