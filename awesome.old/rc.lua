-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
require("awful.autofocus")
-- Widget and layout library
local wibox = require("wibox")
-- Theme handling library
local beautiful = require("beautiful")
-- Notification library
local naughty = require("naughty")
local menubar = require("menubar")
local hotkeys_popup = require("awful.hotkeys_popup").widget
-- Enable hotkeys help widget for VIM and other apps
-- when client with a matching name is opened:
require("awful.hotkeys_popup.keys")

-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
	naughty.notify({
		preset = naughty.config.presets.critical,
		title = "Oops, there were errors during startup!",
		text = awesome.startup_errors
	})
end

-- Handle runtime errors after startup
do
	local in_error = false
	awesome.connect_signal("debug::error", function (err)
		-- Make sure we don't go into an endless error loop
		if in_error then return end
		in_error = true

		naughty.notify({
			preset = naughty.config.presets.critical,
			title = "Oops, an error happened!",
			text = tostring(err)
		})
		in_error = false
	end)
end
-- }}}

-- {{{ Variable definitions
-- Theme
beautiful.init(gears.filesystem.get_configuration_dir() .. "theme/theme.lua")

-- This is used later as the default terminal and editor to run.
terminal = "st"
editor = "subl"
editor_cmd = terminal .. " -e nano"

-- Default modkey (Windows Key)
modkey = "Mod4"

-- Table of layouts to cover with awful.layout.inc, order matters.
awful.layout.layouts = {
	awful.layout.suit.floating,
	awful.layout.suit.tile,
	awful.layout.suit.tile.left,
	-- awful.layout.suit.tile.bottom,
	-- awful.layout.suit.tile.top,
	awful.layout.suit.fair,
	awful.layout.suit.fair.horizontal,
	awful.layout.suit.spiral,
	-- awful.layout.suit.spiral.dwindle,
	awful.layout.suit.max,
	-- awful.layout.suit.max.fullscreen,
	-- awful.layout.suit.magnifier,
	-- awful.layout.suit.corner.nw,
	-- awful.layout.suit.corner.ne,
	-- awful.layout.suit.corner.sw,
	-- awful.layout.suit.corner.se,
}
-- }}}

-- {{{ Helper functions
local function client_menu_toggle_fn()
	local instance = nil

	return function ()
		if instance and instance.wibox.visible then
			instance:hide()
			instance = nil
		else
			instance = awful.menu.clients({ theme = { width = 250 } })
		end
	end
end

local function set_wallpaper(s)
	if beautiful.wallpaper then
		local wallpaper = beautiful.wallpaper
		if type(wallpaper) == "function" then
			wallpaper = wallpaper(s)
		end
		gears.wallpaper.maximized(wallpaper, s, true)
	end
end
-- }}}

-- {{{ Menu
submenu_awesome = {
	{ "hotkeys", function() return false, hotkeys_popup.show_help end },
	{ "manual", terminal .. " -e man awesome" },
	{ "edit config", editor .. " " .. awesome.conffile },
	{ "restart", awesome.restart },
	{ "quit", function() awesome.quit() end }
}

menu_main = awful.menu({
	items = {
		{ "awesome", submenu_awesome, beautiful.awesome_icon },
		{ "Terminal", terminal },
		{ "Chromium", "chromium" },
		{ "Sublime Text", "subl -n" }
	}
})

widget_menu = awful.widget.launcher({
	image = beautiful.awesome_icon,
	menu = menu_main
})

-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it
-- }}}

-- {{{ Buttons
buttons_tags = gears.table.join(
	awful.button({        }, 1, function(t) t:view_only() end),
	awful.button({ modkey }, 1, function(t) if client.focus then client.focus:move_to_tag(t) end end),
	awful.button({        }, 3, awful.tag.viewtoggle),
	awful.button({ modkey }, 3, function(t) if client.focus then client.focus:toggle_tag(t) end end),
	awful.button({        }, 4, function(t) awful.tag.viewprev(t.screen) end),
	awful.button({        }, 5, function(t) awful.tag.viewnext(t.screen) end)
)

buttons_tasks = gears.table.join(
	awful.button({ }, 1, function(c)
		if c == client.focus then
			c.minimized = true
		else
			c.minimized = false
			if not c:isvisible() and c.first_tag then
				c.first_tag:view_only()
			end
			client.focus = c
			c:raise()
		end
	end),
	awful.button({ }, 3, client_menu_toggle_fn()),
	awful.button({ }, 4, function() awful.client.focus.byidx( 1) end),
	awful.button({ }, 5, function() awful.client.focus.byidx(-1) end)
)

buttons_layouts = gears.table.join(
	awful.button({ }, 1, function () awful.layout.inc( 1) end),
	awful.button({ }, 3, function () awful.layout.inc(-1) end),
	awful.button({ }, 4, function () awful.layout.inc( 1) end),
	awful.button({ }, 5, function () awful.layout.inc(-1) end)
)
-- }}}

-- {{{ Widgets
-- textclock
widget_clock = wibox.widget.textclock()

-- awesome pulseaudio widget
local APW = require("apw/widget")
-- }}}

-- {{{ Wibar
-- Re-set wallpaper when a screen's geometry changes (e.g. different resolution)
screen.connect_signal("property::geometry", set_wallpaper)

awful.screen.connect_for_each_screen(function(s)
	set_wallpaper(s)

	local tag_names = { "Main", "Web", "Dev", "Term", "5", "6", "7", "8", "9" }
	local l = awful.layout.suit
	local tag_layouts = { l.floating, l.tile, l.tile, l.fair }
	awful.tag(tag_names, s, tag_layouts)

	s.widget_prompt = awful.widget.prompt()

	s.widget_tags = awful.widget.taglist(s, awful.widget.taglist.filter.all, buttons_tags)

	s.widget_tasks = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, buttons_tasks)

	s.widget_layout = awful.widget.layoutbox(s)
	s.widget_layout:buttons(buttons_layouts)

	s.wibar_main = awful.wibar({ position = "bottom", screen = s })
	s.wibar_main:setup {
		layout = wibox.layout.align.horizontal,
		{ -- Left widgets
			layout = wibox.layout.fixed.horizontal,
			widget_menu,
			s.widget_tags,
			s.widget_prompt,
		},
		{ -- Middle widgets
			layout = wibox.layout.fixed.horizontal,
			s.widget_tasks,
		},
		{ -- Right widgets
			layout = wibox.layout.fixed.horizontal,
			wibox.widget.systray(),
			APW,
			widget_clock,
			s.widget_layout,
		},
	}
end)
-- }}}

-- {{{ Notifications
naughty.config.defaults.position = "bottom_right"
naughty.config.defaults.hover_timeout = 10
-- }}}

-- {{{ Key bindings
globalkeys = gears.table.join(
	-- Awesome
	awful.key({ modkey, "Control" }, "r",      awesome.restart,              { description = "reload awesome", group = "awesome" }),
	awful.key({ modkey, "Shift"   }, "q",      awesome.quit,                 { description = "quit awesome", group = "awesome" }),
	awful.key({ modkey            }, "s",      hotkeys_popup.show_help,      { description = "show help", group = "awesome" }),
	awful.key({ modkey            }, "x",      function()
			awful.prompt.run {
				prompt       = "Lua >>> ",
				textbox      = awful.screen.focused().widget_prompt.widget,
				exe_callback = awful.util.eval,
				history_path = awful.util.get_cache_dir() .. "/history_eval"
			}
		end,                                                                 { description = "lua execute prompt", group = "awesome" }),
	-- Screen
	awful.key({ modkey, "Control" }, "j",      function()
		awful.client.swap.byidx(-1) end,                                     { description = "focus the previous screen", group = "screen" }),
	awful.key({ modkey, "Control" }, "k",      function()
		awful.client.swap.byidx( 1) end,                                     { description = "focus the next screen", group = "screen" }),
	-- Client
	awful.key({ modkey            }, "j",      function()
		awful.client.focus.byidx(-1) end,                                    { description = "focus previous by index", group = "client" }),
	awful.key({ modkey            }, "k",      function()
		awful.client.focus.byidx( 1) end,                                    { description = "focus next by index", group = "client" }),
	awful.key({ modkey, "Shift"   }, "j",      function()
		awful.client.swap.byidx(-1) end,                                     { description = "swap with previous client by index", group = "client" }),
	awful.key({ modkey, "Shift"   }, "k",      function()
		awful.client.swap.byidx( 1) end,                                     { description = "swap with next client by index", group = "client" }),
	awful.key({ modkey            }, "Tab",    function()
			awful.client.focus.history.previous()
			if client.focus then
				client.focus:raise()
			end
		end,                                                                 { description = "go back", group = "client" }),
	awful.key({ modkey,           }, "u",      awful.client.urgent.jumpto,   { description = "jump to urgent client", group = "client" }),
	awful.key({ modkey, "Control" }, "n",      function()
			local c = awful.client.restore()
			if c then
				client.focus = c
				c:raise()
			end
		end,                                                                 { description = "restore minimized", group = "client" }),
	-- Launcher
	awful.key({ modkey,           }, "Return", function ()
		awful.spawn(terminal) end,                                           { description = "open a terminal", group = "launcher" }),
	awful.key({ modkey            }, "p",      function()
		menubar.show() end,                                                  { description = "show the menubar", group = "launcher" }),
	awful.key({ modkey            }, "r",      function()
		awful.screen.focused().widget_prompt:run() end,                        { description = "run prompt", group = "launcher" }),
	-- Layout
	awful.key({ modkey            }, "h",      function()
		awful.tag.incmwfact(-0.05) end,                                      { description = "decrease master width factor", group = "layout" }),
	awful.key({ modkey            }, "l",      function()
		awful.tag.incmwfact(0.05) end,                                       { description = "increase master width factor", group = "layout" }),
	awful.key({ modkey, "Shift"   }, "h",      function()
		awful.tag.incnmaster(-1, nil, true) end,                             { description = "decrease the number of master clients", group = "layout" }),
	awful.key({ modkey, "Shift"   }, "l",      function()
		awful.tag.incnmaster(1, nil, true) end,                              { description = "increase the number of master clients", group = "layout" }),
	awful.key({ modkey, "Control" }, "h",      function()
		awful.tag.incncol(-1, nil, true) end,                                { description = "decrease the number of columns", group = "layout" }),
	awful.key({ modkey, "Control" }, "l",      function()
		awful.tag.incncol(1, nil, true) end,                                 { description = "increase the number of columns", group = "layout" }),
	awful.key({ modkey,           }, "space",  function()
		awful.layout.inc(1) end,                                             { description = "select next", group = "layout" }),
	awful.key({ modkey, "Shift"   }, "space",  function()
		awful.layout.inc(-1) end,                                            { description = "select previous", group = "layout" }),
	-- Tag
	awful.key({ modkey,           }, "Escape", awful.tag.history.restore,    { description = "go back", group = "tag" }),
	awful.key({ modkey,           }, "Left",   awful.tag.viewprev,           { description = "view previous", group = "tag" }),
	awful.key({ modkey,           }, "Right",  awful.tag.viewnext,           { description = "view next", group = "tag" }),
	-- Audio Control
	awful.key({ }, "XF86AudioRaiseVolume",     APW.Up),
	awful.key({ }, "XF86AudioLowerVolume",     APW.Down),
	awful.key({ }, "XF86AudioMute",            APW.ToggleMute)
)
-- Tag
for i = 1, 9 do
	globalkeys = gears.table.join(globalkeys,
		awful.key({ modkey                     }, "#" .. i + 9, function()
				local screen = awful.screen.focused()
				local tag = screen.tags[i]
				if tag then
					tag:view_only()
				end
			end,                                                             { description = "view tag #" .. i, group = "tag" }),
		awful.key({ modkey, "Control"          }, "#" .. i + 9, function()
				local screen = awful.screen.focused()
				local tag = screen.tags[i]
				if tag then
					awful.tag.viewtoggle(tag)
				end
			end,                                                             { description = "toggle tag #" .. i, group = "tag" }),
		awful.key({ modkey,            "Shift" }, "#" .. i + 9, function()
				if client.focus then
					local tag = client.focus.screen.tags[i]
					if tag then
						client.focus:move_to_tag(tag)
					end
				end
			end,                                                             { description = "move focused client to tag #" .. i, group = "tag" }),
		awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9, function()
				if client.focus then
					local tag = client.focus.screen.tags[i]
					if tag then
						client.focus:toggle_tag(tag)
					end
				end
			end,                                                             { description = "toggle focused client on tag #" .. i, group = "tag" })
	)
end

globalbuttons = gears.table.join(
	awful.button({ modkey }, 8, awful.tag.viewprev),
	awful.button({ modkey }, 9, awful.tag.viewnext)
)
-- Set Global keys
root.keys(globalkeys)
root.buttons(globalbuttons)

-- Client
clientkeys = gears.table.join(
	awful.key({ modkey, "Shift"   }, "c",      function(c) c:kill() end,     { description = "close", group = "client" }),
	awful.key({ modkey,           }, "f",      function(c)
			c.fullscreen = not c.fullscreen
			c:raise()
		end,                                                                 { description = "toggle fullscreen", group = "client" }),	
	awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle, { description = "toggle floating", group = "client" }),
	awful.key({ modkey,           }, "t",      function(c)
		c.ontop = not c.ontop end,                                           { description = "toggle keep on top", group = "client" }),
	awful.key({ modkey,           }, "n",      function(c)
		c.minimized = true end,                                              { description = "minimize", group = "client" }),
	awful.key({ modkey,           }, "m",      function(c)
			c.maximized = not c.maximized
			c:raise()
		end,                                                                 { description = "(un)maximize", group = "client" }),
	awful.key({ modkey, "Control" }, "m",      function(c)
			c.maximized_vertical = not c.maximized_vertical
			c:raise()
		end,                                                                 { description = "(un)maximize vertically", group = "client" }),
	awful.key({ modkey, "Shift"   }, "m",      function(c)
			c.maximized_horizontal = not c.maximized_horizontal
			c:raise()
		end,                                                                 { description = "(un)maximize horizontally", group = "client" }),
	awful.key({ modkey, "Control" }, "Return", function(c)
		c:swap(awful.client.getmaster()) end,                                { description = "swap with master", group = "client" }),
	awful.key({ modkey,           }, "o",      function(c)
		c:move_to_screen() end,                                              { description = "move to screen", group = "client" })
)

clientbuttons = gears.table.join(
	awful.button({        }, 1, function(c) client.focus = c; c:raise() end),
	awful.button({ modkey }, 1, awful.mouse.client.move),
	awful.button({ modkey }, 3, awful.mouse.client.resize),
	awful.button({ modkey }, 8, function(c) awful.tag.viewprev() end),
	awful.button({ modkey }, 9, function(c) awful.tag.viewnext() end)
)
-- }}}

-- {{{ Rules
awful.rules.rules = {
	-- Tag specific
	{ -- Global
		rule = { },
		properties = {
			border_width = beautiful.border_width,
			border_color = beautiful.border_color,
			focus = awful.client.focus.filter,
			raise = true,
			keys = clientkeys,
			buttons = clientbuttons,
			screen = awful.screen.preferred,
			placement = awful.placement.no_overlap + awful.placement.no_offscreen,
		}
	},
	{ -- Web
		rule_any = {
			class = { "chromium", "Chromium" }
		},
		properties = {
			tag = "Web",
			switchtotag = true,
			floating = false,
			maximized = false,
			border_width = 0,
		}
	},
	{ -- Dev
		rule_any = {
			class = { "sublime_text", "Sublime_text" }
		},
		properties = {
			tag = "Dev",
			switchtotag = true,
			floating = false,
			maximized = false,
			border_width = 0,
		}
	},
	{ -- Term
		rule_any = {
			class = { "st-256color" }
		},
		properties = {
			--tag = "Term",
			--switchtotag = true,
			floating = false,
			maximized = false,
		}
	},
	-- Tipe specific
	{ -- Dialog
		rule_any = {
			type = { "dialog" }
		},
		properties = {
			floating = true,
			maximized = false,
			placement = awful.placement.centered,
			ontop = true,
			border_width = beautiful.border_width,
		}
	},
	-- Application specific
	{ -- Telegram
		rule_any = {
			class = { "telegram-desktop", "TelegramDesktop" }
		},
		properties = {
			floating = true,
			width = 1440,
			height = 810,
			placement = awful.placement.centered,
			ontop = true,
		}
		-- should adapt to screen size
		-- callback = function(c) c:geometry({ width = 200, height = 800 }) end,
	},
}
-- }}}

-- {{{ Signals
client.connect_signal("manage", function(c)
	-- Set new window as slave
	if not awesome.startup then awful.client.setslave(c) end
	
	-- Prevent clients from being unreachable after screen count changes
	if awesome.startup and not c.size_hints.user_position and not c.size_hints.program_position then
		awful.placement.no_offscreen(c)
	end
end)

client.connect_signal("request::titlebars", function(c)
	-- buttons for the titlebar
	local buttons = gears.table.join(
		awful.button({ }, 1, function()
			client.focus = c
			c:raise()
			awful.mouse.client.move(c)
		end),
		awful.button({ }, 3, function()
			client.focus = c
			c:raise()
		end)
	)

	awful.titlebar(c):setup {
		layout = wibox.layout.align.horizontal,
		{ -- Left
			layout = wibox.layout.fixed.horizontal,
			buttons = buttons,
			awful.titlebar.widget.iconwidget(c),
		},
		{ -- Middle
			layout  = wibox.layout.flex.horizontal,
			buttons = buttons,
			{ -- Title
				align  = "center",
				widget = awful.titlebar.widget.titlewidget(c),
			},
		},
		{ -- Right
			layout = wibox.layout.fixed.horizontal(),
			awful.titlebar.widget.floatingbutton(c),
			awful.titlebar.widget.stickybutton(c),
			awful.titlebar.widget.ontopbutton(c),
			awful.titlebar.widget.maximizedbutton(c),
			awful.titlebar.widget.closebutton(c),
		},
	}
end)

-- Enable sloppy focus, so that focus follows mouse
client.connect_signal("mouse::enter", function(c)
	if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier and awful.client.focus.filter(c) then
		client.focus = c
	end
end)

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}

-- Startup and autorun
awful.spawn.with_shell(gears.filesystem.get_configuration_dir() .. "startup.sh")
awful.spawn.with_shell(gears.filesystem.get_configuration_dir() .. "autorun.sh")