local wezterm = require 'wezterm'
-- This table will hold the configuration.
local config = {}

-- In newer versions of wezterm, use the config_builder which will
-- help provide clearer error messages
if wezterm.config_builder then
  config = wezterm.config_builder()
end

-- This is where you actually apply your config choices

-- For example, changing the color scheme:

-- and finally, return the configuration to wezterm
-- config.font_dirs = { '~/.local/share/fonts' }
config.color_scheme = 'Sonokai (Gogh)'
config.colors = {
  split = '#aaaaaa'
}
config.font = wezterm.font_with_fallback {'FiraCode Nerd Font'}
config.window_background_opacity = 0.99
config.text_background_opacity = 0.7
config.inactive_pane_hsb = {
  saturation = 0.5,
  brightness = 0.5,
}

config.mouse_bindings = {
  {
    event = { Drag = { streak = 1, button = 'Left' } },
    mods = 'CTRL|SHIFT',
    action = wezterm.action.StartWindowDrag,
  },
}

config.keys = {
  -- This will create a new split and run the `top` program inside it
  {
    key = '\\',
    mods = 'CTRL|SHIFT',
    action = wezterm.action.SplitVertical {
      args = { 'top' },
    },
  },
  {
    key = '/',
    mods = 'CTRL|SHIFT',
    action = wezterm.action.SplitPane {
      direction = 'Left',
      command = { args = { 'top' } },
      size = { Percent = 50 },
    },
  },
  {
    key = 'F',
    mods = 'ALT|CTRL|SHIFT',
    action = wezterm.action.Search {CaseSensitiveString=""},
  },
}

config.window_background_gradient = {
  -- Can be "Vertical" or "Horizontal".  Specifies the direction
  -- in which the color gradient varies.  The default is "Horizontal",
  -- with the gradient going from left-to-right.
  -- Linear and Radial gradients are also supported; see the other
  -- examples below
  orientation = 'Vertical',

  -- Specifies the set of colors that are interpolated in the gradient.
  -- Accepts CSS style color specs, from named colors, through rgb
  -- strings and more
  colors = {
    '#000000',
    '#182614',
    '#111111',
  },

  -- Instead of specifying `colors`, you can use one of a number of
  -- predefined, preset gradients.
  -- A list of presets is shown in a section below.
  -- preset = "Warm",

  -- Specifies the interpolation style to be used.
  -- "Linear", "Basis" and "CatmullRom" as supported.
  -- The default is "Linear".
  interpolation = 'Linear',

  -- How the colors are blended in the gradient.
  -- "Rgb", "LinearRgb", "Hsv" and "Oklab" are supported.
  -- The default is "Rgb".
  blend = 'Rgb',

  -- To avoid vertical color banding for horizontal gradients, the
  -- gradient position is randomly shifted by up to the `noise` value
  -- for each pixel.
  -- Smaller values, or 0, will make bands more prominent.
  -- The default value is 64 which gives decent looking results
  -- on a retina macbook pro display.
  -- noise = 64,

  -- By default, the gradient smoothly transitions between the colors.
  -- You can adjust the sharpness by specifying the segment_size and
  -- segment_smoothness parameters.
  -- segment_size configures how many segments are present.
  -- segment_smoothness is how hard the edge is; 0.0 is a hard edge,
  -- 1.0 is a soft edge.

  -- segment_size = 11,
  -- segment_smoothness = 0.0,
}

return config
