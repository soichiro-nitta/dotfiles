local wezterm = require("wezterm")
local config = wezterm.config_builder()

-- Font Configuration
config.font = wezterm.font_with_fallback {
	{ family = "Hack Nerd Font", weight = "Regular" },
	{ family = "Osaka−等幅", scale = 1.0 },
	"Apple Color Emoji",
}
config.font_size = 13.0
config.line_height = 1.2

-- Color Scheme and Appearance
-- Kanso theme configuration
local kanso_zen = require("colors.kanso-zen")
config.colors = kanso_zen.colors
config.force_reverse_video_cursor = kanso_zen.force_reverse_video_cursor
config.window_background_opacity = 0.95
config.text_background_opacity = 1.0
config.window_decorations = "RESIZE"
config.window_close_confirmation = "AlwaysPrompt"

-- Tab Bar Configuration
config.hide_tab_bar_if_only_one_tab = true
config.tab_bar_at_bottom = false
config.use_fancy_tab_bar = true
config.tab_max_width = 25

-- Window Configuration
config.window_padding = {
	left = 16,
	right = 16,
	top = 16,
	bottom = 16,
}
config.adjust_window_size_when_changing_font_size = false
config.initial_cols = 120
config.initial_rows = 32

-- Performance and Behavior
config.enable_scroll_bar = false
config.scrollback_lines = 10000
config.check_for_updates = false
config.automatically_reload_config = true

-- Terminal Settings
config.default_cwd = "/Users/soichiro/Work"
config.set_environment_variables = {
	LANG = "ja_JP.UTF-8",
	LC_ALL = "ja_JP.UTF-8",
	TERM = "wezterm",
}

-- Enable Kitty keyboard protocol for better modifier key support
config.enable_kitty_keyboard = true

-- Bell Configuration
config.audible_bell = "Disabled"
config.visual_bell = {
	fade_in_duration_ms = 75,
	fade_out_duration_ms = 75,
	target = "CursorColor",
}

-- Key Bindings
config.keys = {
	-- Fix Shift+Enter for Claude Code multiline input
	{ key = "Enter", mods = "SHIFT", action = wezterm.action.SendString("\n") },
	
	-- Pane Management
	{ key = "d", mods = "CMD", action = wezterm.action.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
	{ key = "D", mods = "CMD|SHIFT", action = wezterm.action.SplitVertical({ domain = "CurrentPaneDomain" }) },
	{ key = "w", mods = "CMD", action = wezterm.action.CloseCurrentPane({ confirm = true }) },
	{ key = "z", mods = "CMD", action = wezterm.action.TogglePaneZoomState },

	-- Pane Navigation (Vim style)
	{ key = "h", mods = "CMD|SHIFT", action = wezterm.action.ActivatePaneDirection("Left") },
	{ key = "j", mods = "CMD|SHIFT", action = wezterm.action.ActivatePaneDirection("Down") },
	{ key = "k", mods = "CMD|SHIFT", action = wezterm.action.ActivatePaneDirection("Up") },
	{ key = "l", mods = "CMD|SHIFT", action = wezterm.action.ActivatePaneDirection("Right") },

	-- Pane Resizing
	{ key = "LeftArrow", mods = "CMD|SHIFT", action = wezterm.action.AdjustPaneSize({ "Left", 5 }) },
	{ key = "RightArrow", mods = "CMD|SHIFT", action = wezterm.action.AdjustPaneSize({ "Right", 5 }) },
	{ key = "UpArrow", mods = "CMD|SHIFT", action = wezterm.action.AdjustPaneSize({ "Up", 5 }) },
	{ key = "DownArrow", mods = "CMD|SHIFT", action = wezterm.action.AdjustPaneSize({ "Down", 5 }) },

	-- Tab Management
	{ key = "t", mods = "CMD", action = wezterm.action.SpawnTab("CurrentPaneDomain") },
	{ key = "w", mods = "CMD|SHIFT", action = wezterm.action.CloseCurrentTab({ confirm = true }) },
	{ key = "[", mods = "CMD", action = wezterm.action.ActivateTabRelative(-1) },
	{ key = "]", mods = "CMD", action = wezterm.action.ActivateTabRelative(1) },
	{ key = "{", mods = "CMD|SHIFT", action = wezterm.action.MoveTabRelative(-1) },
	{ key = "}", mods = "CMD|SHIFT", action = wezterm.action.MoveTabRelative(1) },

	-- Font Size Adjustment
	{ key = "=", mods = "CMD", action = wezterm.action.IncreaseFontSize },
	{ key = "-", mods = "CMD", action = wezterm.action.DecreaseFontSize },
	{ key = "0", mods = "CMD", action = wezterm.action.ResetFontSize },

	-- Search
	{ key = "f", mods = "CMD", action = wezterm.action.Search({ CaseSensitiveString = "" }) },

	-- Copy/Paste
	{ key = "c", mods = "CMD", action = wezterm.action.CopyTo("Clipboard") },
	{ key = "v", mods = "CMD", action = wezterm.action.PasteFrom("Clipboard") },

	-- Scrollback (changed to avoid conflict with pane navigation)
	{ key = "r", mods = "CMD|SHIFT", action = wezterm.action.ClearScrollback("ScrollbackAndViewport") },

	-- Quick Select Mode
	{ key = " ", mods = "CMD|SHIFT", action = wezterm.action.QuickSelect },

	-- Show Tab Navigator
	{ key = "9", mods = "CMD", action = wezterm.action.ShowTabNavigator },

	-- Show Launcher
	{ key = "p", mods = "CMD|SHIFT", action = wezterm.action.ShowLauncher },
	
	-- Send Cmd-p as Ctrl-p to Neovim
	{ key = "p", mods = "CMD", action = wezterm.action.SendString("\x10") },
}

-- Mouse Bindings
config.mouse_bindings = {
	{
		event = { Up = { streak = 1, button = "Left" } },
		mods = "CMD",
		action = wezterm.action.OpenLinkAtMouseCursor,
	},
}

-- Hyperlink Rules
config.hyperlink_rules = wezterm.default_hyperlink_rules()

-- Additional hyperlink rules for common patterns
table.insert(config.hyperlink_rules, {
	regex = [[\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}\b]],
	format = "mailto:$0",
})

-- SSH Domain Configuration (example)
config.ssh_domains = {
	{
		name = "server",
		remote_address = "server.example.com",
		username = "soichiro",
	},
}

return config

