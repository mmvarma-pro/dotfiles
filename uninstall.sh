#!/bin/bash
set -euo pipefail

echo "Starting full reversal and uninstallation of the dotfiles setup..."

# 1. Destroy chezmoi-managed files in the home directory
if command -v chezmoi >/dev/null 2>&1; then
  echo "Locating and removing chezmoi-managed target files..."
  # If no targets are specified, chezmoi destroy will destroy all managed files and directories in the destination directory.
  chezmoi destroy --force || true
fi

# 2. Uninstall packages
OS_TYPE="$(uname)"
if [ "$OS_TYPE" = "Darwin" ]; then
  echo "Detecting macOS..."
  if command -v brew >/dev/null 2>&1; then
    echo "Uninstalling packages via Homebrew..."
    brew uninstall --force wezterm zsh starship zoxide fzf eza bat git ripgrep fd jq lazygit btop neovim zsh-autosuggestions zsh-syntax-highlighting || true
  fi
elif [ "$OS_TYPE" = "Linux" ]; then
  echo "Detecting Linux..."
  
  # APT
  if command -v apt-get >/dev/null 2>&1; then
    if sudo -n true 2>/dev/null; then
      echo "Uninstalling packages via APT..."
      sudo -n apt-get purge -y wezterm zsh starship zoxide fzf bat git ripgrep fd-find jq lazygit btop neovim || true
      sudo -n apt-get autoremove -y || true
      
      # Clean up WezTerm repository list
      if [ -f /etc/apt/sources.list.d/wezterm.list ]; then
        sudo -n rm -f /etc/apt/sources.list.d/wezterm.list
      fi
      if [ -f /etc/apt/keyrings/wezterm-fury.gpg ]; then
        sudo -n rm -f /etc/apt/keyrings/wezterm-fury.gpg
      fi
      sudo -n apt-get update -y || true
    else
      echo "Passwordless sudo not available, skipping APT package removal."
    fi
  # Pacman
  elif command -v pacman >/dev/null 2>&1; then
    if sudo -n true 2>/dev/null; then
      echo "Uninstalling packages via Pacman..."
      sudo -n pacman -Rns --noconfirm wezterm zsh starship zoxide fzf eza bat git ripgrep fd jq lazygit btop neovim || true
    else
      echo "Passwordless sudo not available, skipping Pacman package removal."
    fi
  fi

  # Linuxbrew
  if command -v brew >/dev/null 2>&1; then
    echo "Uninstalling packages via Linuxbrew..."
    brew uninstall --force wezterm zsh starship zoxide fzf eza bat git ripgrep fd jq lazygit btop neovim zsh-autosuggestions zsh-syntax-highlighting || true
  fi

  # Fallback eza binary
  if [ -f "$HOME/.local/bin/eza" ]; then
    echo "Removing manually installed eza binary..."
    rm -f "$HOME/.local/bin/eza"
  fi
fi

# 3. Clean up cloned repositories, plugins, and fonts
echo "Cleaning up directories, clones, and fonts..."
rm -rf "$HOME/powerlevel10k"
rm -rf "$HOME/.zsh"
rm -rf "$HOME/.local/share/fonts/MesloLGS*"
rm -rf "$HOME/Library/Fonts/MesloLGS*"

# Update font cache if on Linux
if [ "$OS_TYPE" = "Linux" ] && command -v fc-cache >/dev/null 2>&1; then
  fc-cache -f "$HOME/.local/share/fonts" || true
fi

# 4. Purge chezmoi state, configuration, and the chezmoi binary itself
if command -v chezmoi >/dev/null 2>&1; then
  echo "Purging chezmoi state and binary..."
  chezmoi purge --force --binary || true
fi

rm -f "$HOME/.local/bin/chezmoi" || true

echo "Uninstallation and reversal complete."
