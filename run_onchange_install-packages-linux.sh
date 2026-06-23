#!/bin/bash
# OS Check
if [ "$(uname)" != "Linux" ]; then
  exit 0
fi

echo "Installing packages for Linux..."

if command -v brew >/dev/null; then
  echo "Homebrew detected, using brew to install packages..."
  
  if ! brew list --cask wezterm &>/dev/null && ! brew list wezterm &>/dev/null; then
    brew install wezterm
  fi

  packages=(
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
  for pkg in "${packages[@]}"; do
    if ! brew list "$pkg" &>/dev/null; then
      brew install "$pkg"
    fi
  done
elif command -v apt-get >/dev/null; then
  echo "Debian/Ubuntu system detected, using apt-get..."
  SUDO=""
  if [ "$(id -u)" -ne 0 ]; then
    if sudo -n true 2>/dev/null; then
      SUDO="sudo"
    else
      echo "Warning: sudo requires a password, please install packages manually or run chezmoi as root/with passwordless sudo."
    fi
  fi

  # Install package manager packages
  $SUDO apt-get update -y
  $SUDO apt-get install -y zsh git ripgrep jq btop neovim curl

  # Install WezTerm via latest GitHub release deb
  if ! command -v wezterm >/dev/null; then
    echo "Installing WezTerm via .deb package from GitHub..."
    # We download the deb package from github releases.
    # Note: Ubuntu 22.04+ or Debian equivalent deb is downloaded.
    WEZTERM_DEB_URL=$(curl -s https://api.github.com/repos/wez/wezterm/releases/latest | grep -Po '"browser_download_url": "\K[^"]*ubuntu22.04[a-zA-Z0-9.-]*\.deb' | head -n 1)
    if [ -z "$WEZTERM_DEB_URL" ]; then
      # Fallback to general ubuntu deb
      WEZTERM_DEB_URL=$(curl -s https://api.github.com/repos/wez/wezterm/releases/latest | grep -Po '"browser_download_url": "\K[^"]*ubuntu[a-zA-Z0-9.-]*\.deb' | head -n 1)
    fi
    if [ -n "$WEZTERM_DEB_URL" ]; then
      curl -Lo wezterm.deb "$WEZTERM_DEB_URL"
      $SUDO apt-get install -y ./wezterm.deb
      rm -f wezterm.deb
    else
      echo "Could not find WezTerm deb package. Please install WezTerm manually."
    fi
  fi

  # Install fd (named fd-find on Debian/Ubuntu) and symlink it to fd
  if $SUDO apt-get install -y fd-find; then
    mkdir -p "$HOME/.local/bin"
    ln -sf $(command -v fdfind) "$HOME/.local/bin/fd"
  fi

  # Install tools
  $SUDO apt-get install -y fzf bat zoxide eza || true

  # If eza is not found, install a fallback or check if it exists
  if ! command -v starship >/dev/null; then
    echo "Installing starship prompt..."
    curl -sS https://starship.rs/install.sh | sh -s -- -y
  fi

  if ! command -v zoxide >/dev/null; then
    echo "Installing zoxide..."
    curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
  fi

  if ! command -v fzf >/dev/null; then
    echo "Installing fzf..."
    git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf || true
    ~/.fzf/install --all
  fi

  if ! command -v lazygit >/dev/null; then
    LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
    if [ -n "$LAZYGIT_VERSION" ]; then
      curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
      tar xf lazygit.tar.gz lazygit
      mkdir -p "$HOME/.local/bin"
      install lazygit "$HOME/.local/bin"
      rm -f lazygit.tar.gz lazygit
    fi
  fi

  # Install zsh plugins if not installed
  mkdir -p "$HOME/.zsh"
  if [ ! -d "$HOME/.zsh/zsh-autosuggestions" ]; then
    git clone https://github.com/zsh-users/zsh-autosuggestions "$HOME/.zsh/zsh-autosuggestions" || true
  fi
  if [ ! -d "$HOME/.zsh/zsh-syntax-highlighting" ]; then
    git clone https://github.com/zsh-users/zsh-syntax-highlighting "$HOME/.zsh/zsh-syntax-highlighting" || true
  fi
else
  echo "Unsupported Linux package manager. Please install dependencies manually."
fi
