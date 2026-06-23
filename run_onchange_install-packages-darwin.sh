#!/bin/bash
# OS Check
if [ "$(uname)" != "Darwin" ]; then
  exit 0
fi

echo "Installing packages for macOS using Homebrew..."
if ! command -v brew >/dev/null; then
  echo "Homebrew not found. Please install Homebrew first."
  exit 1
fi

# Install WezTerm cask
if ! brew list --cask wezterm &>/dev/null; then
  echo "Installing WezTerm (cask)..."
  brew install --cask wezterm
else
  echo "WezTerm (cask) is already installed."
fi

# List of brew formulas to install
formulas=(
  zsh
  starship
  zoxide
  fzf
  eza
  bat
  git
  ripgrep
  fd
  jq
  lazygit
  btop
  neovim
  zsh-autosuggestions
  zsh-syntax-highlighting
)

for formula in "${formulas[@]}"; do
  if ! brew list "$formula" &>/dev/null; then
    echo "Installing $formula..."
    brew install "$formula"
  else
    echo "$formula is already installed."
  fi
done
