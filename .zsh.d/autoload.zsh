# starship
eval "$(starship init zsh)"

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

export PATH="$HOME/.local/bin:$PATH"
# mise
eval "$(mise activate zsh --shims)" # should be first
eval "$(mise activate zsh)"

export CARGO_HOME=$HOME/.cargo
if [ -d "${CARGO_HOME}" ]; then
  export PATH="${CARGO_HOME}/bin:$PATH"
fi
