# OS Check
if (-not ($IsWindows -or $env:OS -eq 'Windows_NT')) {
  exit 0
}

Write-Host "Installing packages for Windows..."

# Install Scoop if not already installed
if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) {
  Write-Host "Scoop not found. Installing Scoop..."
  Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope Process -Force
  Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression
}

if (Get-Command scoop -ErrorAction SilentlyContinue) {
  Write-Host "Using Scoop to install packages..."
  scoop bucket add extras
  scoop bucket add main

  $packages = @(
    "git",
    "wezterm",
    "starship",
    "zoxide",
    "fzf",
    "eza",
    "bat",
    "ripgrep",
    "fd",
    "jq",
    "lazygit",
    "btop",
    "neovim"
  )

  foreach ($pkg in $packages) {
    if (-not (scoop which $pkg)) {
      Write-Host "Installing $pkg via Scoop..."
      scoop install $pkg
    } else {
      Write-Host "$pkg is already installed."
    }
  }
} else {
  Write-Host "Warning: Scoop could not be installed. Falling back to Winget..."
  $wingetPackages = @(
    "Git.Git",
    "Wez.WezTerm",
    "Starship.Starship",
    "ajeetdsouza.zoxide",
    "junegunn.fzf",
    "sharkdp.bat",
    "BurntSushi.ripgrep",
    "sharkdp.fd",
    "jqlang.jq",
    "JesseDuffield.lazygit",
    "aristocratos.btop",
    "Neovim.Neovim"
  )
  foreach ($pkg in $wingetPackages) {
    Write-Host "Installing $pkg via Winget..."
    winget install --silent --accept-source-agreements --accept-package-agreements $pkg
  }
  Write-Host "Please note that 'eza' is not available via Winget. You should install Scoop or download it manually."
}
