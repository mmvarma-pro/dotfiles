Write-Host "Starting full reversal and uninstallation of the dotfiles setup on Windows..."

# Set ExecutionPolicy to bypass for the session to run commands
Set-ExecutionPolicy Bypass -Scope Process -Force

# 1. Destroy chezmoi-managed files
if (Get-Command chezmoi -ErrorAction SilentlyContinue) {
    Write-Host "Locating and removing chezmoi-managed target files..."
    chezmoi destroy --force || true
}

# 2. Uninstall packages via Scoop
if (Get-Command scoop -ErrorAction SilentlyContinue) {
    Write-Host "Uninstalling tools via Scoop..."
    $apps = @("wezterm", "neovim", "btop", "lazygit", "jq", "fd-find", "ripgrep", "bat", "eza", "fzf", "zoxide", "starship")
    foreach ($app in $apps) {
        Write-Host "Uninstalling $app..."
        scoop uninstall $app 2>&1 | Out-Null
    }
}

# 3. Purge chezmoi state and binary
if (Get-Command chezmoi -ErrorAction SilentlyContinue) {
    Write-Host "Purging chezmoi state and binary..."
    chezmoi purge --force --binary || true
}

Write-Host "Uninstallation and reversal complete."
