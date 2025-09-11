local wezterm = require 'wezterm'
local config = {}

-- In newer versions of wezterm, use the config_builder which will
-- help provide clearer error messages
if wezterm.config_builder then
  config = wezterm.config_builder()
end

-- Kanso color scheme
config.colors = {
  -- The default text color
  foreground = '#c5c8c6',
  -- The default background color
  background = '#1d1f21',

  -- Overrides the cell background color when the current cell is occupied by the
  -- cursor and the cursor style is set to Block
  cursor_bg = '#c5c8c6',
  -- Overrides the text color when the current cell is occupied by the cursor
  cursor_fg = '#1d1f21',
  -- Specifies the border color of the cursor when the cursor style is set to Block,
  -- or the color of the vertical or horizontal bar when the cursor style is set to
  -- Bar or Underline.
  cursor_border = '#c5c8c6',

  -- the foreground color of selected text
  selection_fg = '#1d1f21',
  -- the background color of selected text
  selection_bg = '#c5c8c6',

  -- The color of the scrollbar "thumb"; the portion that represents the current viewport
  scrollbar_thumb = '#282a2e',

  -- The color of the split lines between panes
  split = '#707880',

  ansi = {
    '#282a2e', -- black
    '#a54242', -- red
    '#8c9440', -- green
    '#de935f', -- yellow
    '#5f819d', -- blue
    '#85678f', -- magenta
    '#5e8d87', -- cyan
    '#707880', -- white
  },
  brights = {
    '#373b41', -- bright black
    '#cc6666', -- bright red
    '#b5bd68', -- bright green
    '#f0c674', -- bright yellow
    '#81a2be', -- bright blue
    '#b294bb', -- bright magenta
    '#8abeb7', -- bright cyan
    '#c5c8c6', -- bright white
  },

  -- Indexed colors. The first 16 are the same as the ansi and brights
  indexed = {
    [136] = '#af8700',
  },

  -- Visual Bell
  visual_bell = '#202020',

  -- Colors for copy_mode and quick_select
  -- available since: 20220807-113146-c2fee766
  -- In copy_mode, the color of the active text is:
  -- 1. copy_mode_active_highlight_* if additional text was selected using the mouse
  -- 2. selection_* otherwise
  copy_mode_active_highlight_bg = { Color = '#52ad70' },
  -- use `AnsiColor` to specify one of the ansi color palette values
  -- (index 0-15) using one of the names "Black", "Maroon", "Green",
  --  "Olive", "Navy", "Purple", "Teal", "Silver", "Grey", "Red", "Lime",
  -- "Yellow", "Blue", "Fuchsia", "Aqua" or "White".
  copy_mode_active_highlight_fg = { AnsiColor = 'Black' },
  copy_mode_inactive_highlight_bg = { Color = '#52ad70' },
  copy_mode_inactive_highlight_fg = { AnsiColor = 'White' },

  quick_select_label_bg = { Color = 'peru' },
  quick_select_label_fg = { Color = '#ffffff' },
  quick_select_match_bg = { AnsiColor = 'Navy' },
  quick_select_match_fg = { Color = '#ffffff' },
}

-- Font configuration
config.font = wezterm.font('JetBrains Mono')
config.font_size = 12.0

-- Window configuration
config.window_background_opacity = 0.88
config.window_decorations = "TITLE | RESIZE"
config.window_padding = {
  left = 10,
  right = 10,
  top = 10,
  bottom = 10,
}

-- Window frame configuration
-- Note: Commented out to use macOS native window decorations
-- config.window_frame = {
--   -- Border configuration
--   border_left_width = '1px',
--   border_right_width = '1px',
--   border_bottom_height = '1px',
--   border_top_height = '1px',
--   border_left_color = '#707880',
--   border_right_color = '#707880',
--   border_bottom_color = '#707880',
--   border_top_color = '#707880',
-- }

-- Tab bar
config.hide_tab_bar_if_only_one_tab = true
config.tab_bar_at_bottom = false
config.use_fancy_tab_bar = false

-- Tab bar colors
config.colors.tab_bar = {
  -- The color of the inactive tab bar edge/divider
  inactive_tab_edge = '#707880',
}

-- Cursor
config.default_cursor_style = 'BlinkingBar'

-- Other settings
config.scrollback_lines = 10000
config.enable_scroll_bar = false

-- Key bindings
config.keys = {
  -- Make Option-Left equivalent to Alt-b which many line editors interpret as backward-word
  { key = 'LeftArrow', mods = 'OPT', action = wezterm.action.SendString '\x1bb' },
  -- Make Option-Right equivalent to Alt-f; forward-word
  { key = 'RightArrow', mods = 'OPT', action = wezterm.action.SendString '\x1bf' },
}

return config