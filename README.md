# Dotfiles Configuration

A repository for managing cross-platform developer environments using [chezmoi](https://www.chezmoi.io/). It configures a cohesive terminal setup featuring WezTerm, Zsh, Powerlevel10k (p10k), Starship, and modern command-line utilities.

## Quick Start (Bootstrap)

To initialize and apply these dotfiles on a new machine, run:

```bash
sudo -v && sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply mmvarma-pro
```

This command will:
1. Install the `chezmoi` binary.
2. Initialize the configuration from the repository.
3. Automatically trigger the OS-specific package installation scripts.
4. Deploy the configuration files (dotfiles) to your home directory.

---

## Operating System Support & Requirements

### 1. macOS (Darwin)
- **Package Manager**: [Homebrew](https://brew.sh/) must be installed.
- **Auto-installed Packages**: `wezterm`, `zsh`, `starship`, `zoxide`, `fzf`, `eza`, `bat`, `git`, `ripgrep`, `fd`, `jq`, `lazygit`, `btop`, `neovim`, `zsh-autosuggestions`, `zsh-syntax-highlighting`.
- **Fonts**: Clones `powerlevel10k` and downloads `MesloLGS NF` fonts to `~/Library/Fonts`.

### 2. Linux (Ubuntu/Debian, Arch Linux, etc.)
- **Package Manager**: Uses `apt-get` on Debian/Ubuntu-based systems and `pacman` on Arch-based systems.
- **Auto-installed Packages**: Installs the same set of packages as macOS.
- **Sudo requirement**: Requires passwordless `sudo` to run system package manager installs. If not available, it skips APT/Pacman packages and attempts installation via Homebrew (Linuxbrew) if installed.
- **Manual Fallbacks**:
  - Clones `zsh-autosuggestions` and `zsh-syntax-highlighting` directly to `~/.zsh` if not found in package managers.
  - Downloads the latest release of `eza` directly from GitHub into `~/.local/bin/` if not available.
  - Downloads `MesloLGS NF` fonts to `~/.local/share/fonts` and regenerates the system font cache using `fc-cache`.

### 3. Windows
- **Package Manager**: [Scoop](https://scoop.sh/) is automatically installed if not already present.
- **Execution Policy**: Temporarily sets execution policy to `Bypass` to run scripts.
- **Auto-installed Packages**: Installs `wezterm`, `starship`, `zoxide`, `fzf`, `eza`, `bat`, `ripgrep`, `fd-find`, `jq`, `lazygit`, `btop`, `neovim`, and `git` via Scoop (utilizing the `extras` bucket).

---

## Common Issues & Troubleshooting

### 1. Missing Unicode/Icon Glyphs (Broken Prompt Icons)
- **Symptom**: Prompt symbols render as boxes, question marks, or garbled characters.
- **Fix**: The prompt depends on Nerd Fonts (MesloLGS NF). Although the scripts download the fonts to the correct directories on macOS and Linux, you must configure your terminal emulator to use them.
  - **WezTerm**: The included `dot_wezterm.lua` is pre-configured to use font fallbacks correctly.
  - **Other terminals (Alacritty, iTerm2, Kitty, GNOME Terminal)**: Open terminal preferences and select `MesloLGS NF` as the default font.

### 2. Linux Package Installation Skipped
- **Symptom**: Chezmoi apply finishes but packages like `zsh` or `wezterm` are not installed.
- **Fix**: The installation script requires passwordless `sudo`. If passwordless sudo is not configured, install the packages manually using:
  ```bash
  sudo apt install -y wezterm zsh starship zoxide fzf bat git ripgrep fd-find jq lazygit btop neovim
  ```

### 3. macOS Installation Fails / Exits Early
- **Symptom**: Output says `"Homebrew not found. Please install Homebrew first."` and script exits.
- **Fix**: Install Homebrew by running the official command from [brew.sh](https://brew.sh/):
  ```bash
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  ```
  After Homebrew is installed, re-run `chezmoi apply`.

### 4. `eza` Command Not Found on Linux
- **Symptom**: The terminal reports `eza: command not found` after applying dotfiles.
- **Fix**: When `eza` is installed to the fallback path `~/.local/bin/eza`, you must ensure that `~/.local/bin` is in your `PATH` environment variable. Add the following to your shell configuration (e.g., `~/.zshrc`):
  ```bash
  export PATH="$HOME/.local/bin:$PATH"
  ```

### 5. Windows Execution Policy Restriction
- **Symptom**: Running Scoop or PowerShell profile scripts yields execution policy errors.
- **Fix**: Run PowerShell as Administrator and enable script execution system-wide:
  ```powershell
  Set-ExecutionPolicy RemoteSigned -Scope LocalMachine
  ```

---

## Uninstallation / Full Reversal

If you wish to completely remove the dotfiles setup, managed files, downloaded plugins, fonts, installed packages, and chezmoi itself, you can run the uninstallation command for your platform:

### macOS & Linux (Unix)

```bash
curl -fsSL https://raw.githubusercontent.com/mmvarma-pro/dotfiles/main/uninstall.sh | bash
```

### Windows

```powershell
Invoke-RestMethod -Uri https://raw.githubusercontent.com/mmvarma-pro/dotfiles/main/uninstall.ps1 | Invoke-Expression
```

