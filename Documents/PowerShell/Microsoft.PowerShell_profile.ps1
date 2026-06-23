# PowerShell Profile Config

# Setup UTF-8 encoding for output (critical for Nerd Fonts)
[console]::InputEncoding = [System.Text.Encoding]::UTF8
[console]::OutputEncoding = [System.Text.Encoding]::UTF8

# Initialize starship prompt
if (Get-Command starship -ErrorAction SilentlyContinue) {
    Invoke-Expression (&starship init powershell)
}

# Initialize zoxide (smarter cd)
if (Get-Command zoxide -ErrorAction SilentlyContinue) {
    Invoke-Expression (&zoxide init powershell)
}

# Override default aliases with modern alternatives
if (Get-Command eza -ErrorAction SilentlyContinue) {
    Remove-Item Alias:ls -ErrorAction SilentlyContinue
    Set-Alias -Name ls -Value eza -Option Force
}
if (Get-Command bat -ErrorAction SilentlyContinue) {
    Remove-Item Alias:cat -ErrorAction SilentlyContinue
    Set-Alias -Name cat -Value bat -Option Force
}

# General aliases
if (Get-Command lazygit -ErrorAction SilentlyContinue) {
    Set-Alias -Name git-ui -Value lazygit
}
if (Get-Command btop -ErrorAction SilentlyContinue) {
    Set-Alias -Name top -Value btop
}
if (Get-Command nvim -ErrorAction SilentlyContinue) {
    Set-Alias -Name vim -Value nvim
}
