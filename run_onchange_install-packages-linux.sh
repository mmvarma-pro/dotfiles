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
      echo "Error: Passwordless sudo is not configured and you are not running as root."
      echo "Please run 'sudo -v' before running 'chezmoi apply' to pre-authenticate sudo,"
      echo "or run chezmoi as root."
      exit 1
    fi
  fi

  # Install package manager packages
  $SUDO apt-get update -y
  $SUDO apt-get install -y zsh git ripgrep jq btop neovim curl

  # Install WezTerm via official apt repository
  if ! command -v wezterm >/dev/null; then
    echo "Installing WezTerm via official apt repository..."
    $SUDO rm -f /usr/share/keyrings/wezterm-fury.gpg
    if curl -fsSL https://apt.fury.io/wez/gpg.key | $SUDO gpg --dearmor -o /usr/share/keyrings/wezterm-fury.gpg; then
      echo 'deb [signed-by=/usr/share/keyrings/wezterm-fury.gpg] https://apt.fury.io/wez/ * *' | $SUDO tee /etc/apt/sources.list.d/wezterm.list >/dev/null
      $SUDO apt-get update -y
      $SUDO apt-get install -y wezterm
    else
      echo "Failed to add WezTerm apt repository. Please install WezTerm manually."
    fi
  fi

  # Install fd (named fd-find on Debian/Ubuntu) and symlink it to fd
  if $SUDO apt-get install -y fd-find; then
    if command -v fdfind >/dev/null; then
      mkdir -p "$HOME/.local/bin"
      ln -sf "$(command -v fdfind)" "$HOME/.local/bin/fd"
    fi
  fi

  # Install tools
  $SUDO apt-get install -y fzf bat zoxide eza || true

  # Symlink batcat to bat if needed
  if command -v batcat >/dev/null && ! command -v bat >/dev/null; then
    mkdir -p "$HOME/.local/bin"
    ln -sf "$(command -v batcat)" "$HOME/.local/bin/bat"
  fi
  # If eza is not found, install a fallback
  if ! command -v eza >/dev/null; then
    echo "eza not found via package manager, installing latest release from GitHub..."
    EZA_VERSION=$(curl -s "https://api.github.com/repos/eza-community/eza/releases/latest" | grep -Po '"tag_name": "\K[^"]*')
    if [ -n "$EZA_VERSION" ]; then
      mkdir -p "$HOME/.local/bin"
      TEMP_DIR=$(mktemp -d)
      if curl -Lo "$TEMP_DIR/eza.tar.gz" "https://github.com/eza-community/eza/releases/latest/download/eza_x86_64-unknown-linux-gnu.tar.gz"; then
        tar xzf "$TEMP_DIR/eza.tar.gz" -C "$TEMP_DIR"
        if [ -f "$TEMP_DIR/eza" ]; then
          install "$TEMP_DIR/eza" "$HOME/.local/bin/eza"
        elif [ -f "$TEMP_DIR/bin/eza" ]; then
          install "$TEMP_DIR/bin/eza" "$HOME/.local/bin/eza"
        fi
      fi
      rm -rf "$TEMP_DIR"
    fi
  fi
  # Install starship if not found
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
