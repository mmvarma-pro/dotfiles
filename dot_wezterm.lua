local wezterm = require 'wezterm'
local config = wezterm.config_builder()

-- Color scheme and aesthetics
config.color_scheme = 'Night Owl (Gogh)'
config.font = wezterm.font('JetBrains Mono Nerd Font')
config.font_size = 11.0
config.use_fancy_tab_bar = true
config.hide_tab_bar_if_only_one_tab = true
config.window_background_opacity = 0.85
config.macos_window_background_blur = 20
config.win32_system_backdrop = 'Acrylic'
config.window_padding = {
  left = 10,
  right = 10,
  top = 10,
  bottom = 10,
}
config.window_decorations = wezterm.target_triple:find("darwin") and "INTEGRATED_BUTTONS | RESIZE" or "RESIZE"
config.window_move_via_background = true

-- Shell selection based on OS
local function get_default_prog()
  if wezterm.target_triple:find("windows") then
    local success, stdout, stderr = wezterm.run_child_process({ 'where.exe', 'pwsh' })
    if success then
      return { 'pwsh.exe', '-NoLogo' }
    else
      return { 'powershell.exe', '-NoLogo' }
    end
  else
    return { '/bin/zsh', '-l' }
  end
end
config.default_prog = get_default_prog()

-- Multiplexing with Unix Domains
config.unix_domains = {
  {
    name = 'unix',
  },
}
-- Automatically connect to the local unix domain on startup to persist sessions
config.default_gui_startup_args = { 'connect', 'unix' }

-- Leader key definition (Ctrl+A)
config.leader = { key = 'a', mods = 'CTRL', timeout_milliseconds = 1000 }

-- Keybindings (Tmux emulation)
local act = wezterm.action
config.keys = {
  -- Split vertical (horizontal split line)
  {
    key = '-',
    mods = 'LEADER',
    action = act.SplitVertical { domain = 'CurrentPaneDomain' },
  },
  -- Split horizontal (vertical split line)
  {
    key = '|',
    mods = 'LEADER',
    action = act.SplitHorizontal { domain = 'CurrentPaneDomain' },
  },
  -- Activate pane direction (h, j, k, l)
  {
    key = 'h',
    mods = 'LEADER',
    action = act.ActivatePaneDirection 'Left',
  },
  {
    key = 'j',
    mods = 'LEADER',
    action = act.ActivatePaneDirection 'Down',
  },
  {
    key = 'k',
    mods = 'LEADER',
    action = act.ActivatePaneDirection 'Up',
  },
  {
    key = 'l',
    mods = 'LEADER',
    action = act.ActivatePaneDirection 'Right',
  },
  -- Create new tab
  {
    key = 'c',
    mods = 'LEADER',
    action = act.SpawnTab 'CurrentPaneDomain',
  },
  -- Close current pane
  {
    key = 'x',
    mods = 'LEADER',
    action = act.CloseCurrentPane { confirm = true },
  },
}

-- Tab navigation: Leader + 1-9
for i = 1, 9 do
  table.insert(config.keys, {
    key = tostring(i),
    mods = 'LEADER',
    action = act.ActivateTab(i - 1),
  })
end

return config
