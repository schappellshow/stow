local awful     = require("awful")
local beautiful = require("beautiful")
local wibox     = require("wibox")
local gears     = require("gears")
local dpi       = require("beautiful.xresources").apply_dpi

local keys = require("modules.keys")

awful.rules.rules = {

    -- Default: all clients
    {
        rule = { },
        properties = {
            border_width      = beautiful.border_width,
            border_color      = beautiful.border_normal,
            focus             = awful.client.focus.filter,
            raise             = true,
            keys              = keys.clientkeys,
            buttons           = keys.clientbuttons,
            screen            = awful.screen.preferred,
            placement         = awful.placement.no_overlap + awful.placement.no_offscreen,
            titlebars_enabled = false,   -- no titlebars by default (Hyprland style)
        }
    },

    -- Floating clients
    {
        rule_any = {
            instance = { "DTA", "copyq", "pinentry" },
            class    = {
                "Arandr", "Blueman-manager", "Gpick", "Kruler",
                "MessageWin", "Sxiv", "Wpa_gui", "veromix",
                "xtightvncviewer", "Pavucontrol", "Nm-connection-editor",
                "pavucontrol-qt", "flameshot",
            },
            name  = { "Event Tester" },
            role  = { "AlarmWindow", "ConfigManager", "pop-up" },
        },
        properties = {
            floating  = true,
            placement = awful.placement.centered,
        }
    },

    -- Dialogs get titlebars (so they can be moved/closed)
    {
        rule_any  = { type = { "dialog" } },
        properties = {
            floating          = true,
            titlebars_enabled = true,
            placement         = awful.placement.centered,
        }
    },

    -- Ghostty: WM_CLASS is "com.mitchellh.ghostty" — verify with `xprop | grep WM_CLASS`
    {
        rule = { class = "com.mitchellh.ghostty" },
        properties = { titlebars_enabled = false }
    },

    -- Rofi: truly floating, no border, no titlebar
    {
        rule = { class = "Rofi" },
        properties = {
            floating          = true,
            border_width      = 0,
            titlebars_enabled = false,
        }
    },

    -- Quickshell's normal windows (settings app) float centered. type=normal
    -- keeps this off the bar, which is a dock window ("quickshell" is a Lua
    -- pattern, so it also matches an "org.quickshell" class).
    {
        rule = { class = "quickshell", type = "normal" },
        properties = {
            floating          = true,
            placement         = awful.placement.centered,
            titlebars_enabled = false,
        }
    },

}

-- Titlebar builder — only fires when titlebars_enabled = true (dialogs)
client.connect_signal("request::titlebars", function(c)
    local buttons = gears.table.join(
        awful.button({ }, 1, function()
            c:emit_signal("request::activate", "titlebar", { raise = true })
            awful.mouse.client.move(c)
        end),
        awful.button({ }, 3, function()
            c:emit_signal("request::activate", "titlebar", { raise = true })
            awful.mouse.client.resize(c)
        end)
    )

    awful.titlebar(c, { size = dpi(28) }):setup {
        layout = wibox.layout.align.horizontal,
        {   -- Left: icon
            awful.titlebar.widget.iconwidget(c),
            buttons = buttons,
            layout  = wibox.layout.fixed.horizontal,
        },
        {   -- Center: title
            { align = "center", widget = awful.titlebar.widget.titlewidget(c) },
            buttons = buttons,
            layout  = wibox.layout.flex.horizontal,
        },
        {   -- Right: buttons
            awful.titlebar.widget.floatingbutton(c),
            awful.titlebar.widget.maximizedbutton(c),
            awful.titlebar.widget.closebutton(c),
            layout = wibox.layout.fixed.horizontal(),
        },
    }
end)
