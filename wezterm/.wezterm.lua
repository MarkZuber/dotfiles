local wezterm = require("wezterm")

local act = wezterm.action
local config = wezterm.config_builder()

config.font = wezterm.font("ComicShannsMono Nerd Font")
config.font_size = 20
config.color_scheme = 'Material Darker (base 16)'

config.colors = {
    -- split = '#664422'
    split = '#006600'
}
config.underline_thickness = "8px"

config.enable_tab_bar = false

-- This removes the title bar but does make window move a bit more difficult
config.window_decorations = "RESIZE"

config.window_background_opacity = 0.9
config.macos_window_background_blur = 10

config.window_background_image = '/Users/zube/wallpaper/terminal/SadRain.gif'
config.window_background_image_hsb = {
    -- Darken the background image by reducing it to 1/3rd
    brightness = 0.3,

    -- You can adjust the hue by scaling its value.
    -- a multiplier of 1.0 leaves the value unchanged.
    hue = 1.0,

    -- You can adjust the saturation also.
    saturation = 1.0,
}

-- This is an alternative to the background image, and takes precedence
config.window_background_gradient = {
  orientation = 'Vertical',

  colors = {
    '#0f0c29',
    '#302b63',
    '#24243e',
  },
  interpolation = 'Linear',
  blend = 'Rgb',
}

config.window_padding = {
    left = '1cell',
    right = 20,
    top = 20,
    bottom = 20
}

-- Show which key table is active in the status area
wezterm.on('update-right-status', function(window, pane)
    local name = window:active_key_table()
    if name then
      name = 'TABLE: ' .. name
    end
    window:set_right_status(name or '')
  end)

  config.leader = { key = 'Space', mods = 'ALT|SHIFT' }
  config.keys = {
    -- CTRL+SHIFT+Space, followed by 'r' will put us in resize-pane
    -- mode until we cancel that mode.
    {
      key = 'r',
      mods = 'LEADER',
      action = act.ActivateKeyTable {
        name = 'resize_pane',
        one_shot = false,
      },
    },

    -- CTRL+SHIFT+Space, followed by 'a' will put us in activate-pane
    -- mode until we press some other key or until 1 second (1000ms)
    -- of time elapses
    {
      key = 'a',
      mods = 'LEADER',
      action = act.ActivateKeyTable {
        name = 'activate_pane',
        one_shot = false,
        -- timeout_milliseconds = 1000,
      },
    },
  }

  config.key_tables = {
    -- Defines the keys that are active in our resize-pane mode.
    -- Since we're likely to want to make multiple adjustments,
    -- we made the activation one_shot=false. We therefore need
    -- to define a key assignment for getting out of this mode.
    -- 'resize_pane' here corresponds to the name="resize_pane" in
    -- the key assignments above.
    resize_pane = {
      { key = 'LeftArrow', action = act.AdjustPaneSize { 'Left', 1 } },
      { key = 'h', action = act.AdjustPaneSize { 'Left', 1 } },

      { key = 'RightArrow', action = act.AdjustPaneSize { 'Right', 1 } },
      { key = 'l', action = act.AdjustPaneSize { 'Right', 1 } },

      { key = 'UpArrow', action = act.AdjustPaneSize { 'Up', 1 } },
      { key = 'k', action = act.AdjustPaneSize { 'Up', 1 } },

      { key = 'DownArrow', action = act.AdjustPaneSize { 'Down', 1 } },
      { key = 'j', action = act.AdjustPaneSize { 'Down', 1 } },

      -- Cancel the mode by pressing escape
      { key = 'Escape', action = 'PopKeyTable' },
    },

    -- Defines the keys that are active in our activate-pane mode.
    -- 'activate_pane' here corresponds to the name="activate_pane" in
    -- the key assignments above.
    activate_pane = {
      { key = 'LeftArrow', action = act.ActivatePaneDirection 'Left' },
      { key = 'h', action = act.ActivatePaneDirection 'Left' },

      { key = 'RightArrow', action = act.ActivatePaneDirection 'Right' },
      { key = 'l', action = act.ActivatePaneDirection 'Right' },

      { key = 'UpArrow', action = act.ActivatePaneDirection 'Up' },
      { key = 'k', action = act.ActivatePaneDirection 'Up' },

      { key = 'DownArrow', action = act.ActivatePaneDirection 'Down' },
      { key = 'j', action = act.ActivatePaneDirection 'Down' },

      -- Cancel the mode by pressing escape
      { key = 'Escape', action = 'PopKeyTable' },
    },
  }

  config.keys = {
    { key = 'v', mods = 'CTRL|ALT|SHIFT', action = wezterm.action.SplitVertical { domain = 'CurrentPaneDomain' }},
    { key = 'h', mods = 'CTRL|ALT|SHIFT', action = wezterm.action.SplitHorizontal { domain = 'CurrentPaneDomain' } }
  }


return config
