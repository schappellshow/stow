local awful     = require("awful")
local wibox     = require("wibox")
local beautiful = require("beautiful")
local gears     = require("gears")
local dpi       = require("beautiful.xresources").apply_dpi

local modkey = "Mod4"

local M = {}

local taglist_buttons = gears.table.join(
    awful.button({ }, 1, function(t) t:view_only() end),
    awful.button({ modkey }, 1, function(t)
        if client.focus then client.focus:move_to_tag(t) end
    end),
    awful.button({ }, 3, awful.tag.viewtoggle),
    awful.button({ }, 4, function(t) awful.tag.viewnext(t.screen) end),
    awful.button({ }, 5, function(t) awful.tag.viewprev(t.screen) end)
)

-- Wrap a widget in a floating opaque dark pill (sections against the transparent bar)
local function section_pill(widget, pad_v, pad_h)
    pad_v = pad_v or dpi(8)
    pad_h = pad_h or dpi(6)
    return wibox.widget {
        {
            widget,
            top    = pad_v,
            bottom = pad_v,
            left   = pad_h,
            right  = pad_h,
            widget = wibox.container.margin,
        },
        bg     = beautiful.bg_normal,
        shape  = function(cr, w, h)
            gears.shape.rounded_rect(cr, w, h, dpi(10))
        end,
        widget = wibox.container.background,
    }
end

function M.setup(s)

    -- ── Taglist ────────────────────────────────────────────────────────────
    s.mytaglist = awful.widget.taglist {
        screen  = s,
        filter  = awful.widget.taglist.filter.all,
        buttons = taglist_buttons,
        layout  = {
            spacing = dpi(4),
            layout  = wibox.layout.fixed.vertical,
        },
        widget_template = {
            {
                {
                    id     = "text_role",
                    align  = "center",
                    widget = wibox.widget.textbox,
                },
                top    = dpi(8),
                bottom = dpi(8),
                left   = dpi(4),
                right  = dpi(4),
                widget = wibox.container.margin,
            },
            id     = "background_role",
            shape  = function(cr, w, h)
                gears.shape.rounded_bar(cr, w, h)
            end,
            widget = wibox.container.background,
            create_callback = function(self, t, index, objects)  --luacheck: no unused
                self:connect_signal("mouse::enter", function()
                    if self.bg ~= beautiful.taglist_bg_focus then
                        self.bg = beautiful.taglist_bg_focus .. "55"
                    end
                end)
                self:connect_signal("mouse::leave", function()
                    self:emit_signal("widget::redraw_needed")
                end)
            end,
        },
    }

    -- ── Stacked clock: hours / minutes / AM-PM ────────────────────────────
    local clock_h = wibox.widget {
        format = "%I",
        align  = "center",
        font   = "Hack Bold 14",
        widget = wibox.widget.textclock,
    }
    local clock_m = wibox.widget {
        format = "%M",
        align  = "center",
        font   = "Hack 12",
        widget = wibox.widget.textclock,
    }
    local clock_p = wibox.widget {
        format = "%p",
        align  = "center",
        font   = "Hack 8",
        widget = wibox.widget.textclock,
    }

    local clock_stack = wibox.widget {
        clock_h,
        clock_m,
        clock_p,
        spacing = dpi(1),
        layout  = wibox.layout.fixed.vertical,
    }

    local clock_section = section_pill(clock_stack)

    -- ── Battery widget ─────────────────────────────────────────────────────
    local bat_icon = wibox.widget {
        align  = "center",
        font   = "Hack Bold 7",
        widget = wibox.widget.textbox,
    }
    local bat_pct = wibox.widget {
        align  = "center",
        font   = "Hack 9",
        widget = wibox.widget.textbox,
    }
    local bat_stack = wibox.widget {
        bat_icon,
        bat_pct,
        spacing = dpi(1),
        layout  = wibox.layout.fixed.vertical,
    }

    gears.timer {
        timeout   = 60,
        call_now  = true,
        autostart = true,
        callback  = function()
            local f = io.open("/sys/class/power_supply/BAT0/capacity", "r")
            local g = io.open("/sys/class/power_supply/BAT0/status",   "r")
            local pct = f and tonumber(f:read("*l")) or 0
            local sta = g and g:read("*l") or "Unknown"
            if f then f:close() end
            if g then g:close() end
            local col = pct <= 15 and beautiful.bg_urgent
                     or pct <= 30 and "#dac040"
                     or beautiful.fg_normal
            bat_icon:set_markup(
                '<span color="' .. beautiful.fg_minimize .. '">'
                .. (sta == "Charging" and "CHG" or "BAT") .. '</span>')
            bat_pct:set_markup(
                '<span color="' .. col .. '">' .. pct .. '%</span>')
        end,
    }

    -- ── Layout indicator ───────────────────────────────────────────────────
    s.mylayoutbox = awful.widget.layoutbox(s)
    s.mylayoutbox:buttons(gears.table.join(
        awful.button({ }, 1, function() awful.layout.inc( 1) end),
        awful.button({ }, 3, function() awful.layout.inc(-1) end),
        awful.button({ }, 4, function() awful.layout.inc( 1) end),
        awful.button({ }, 5, function() awful.layout.inc(-1) end)
    ))

    -- ── Systray (primary screen only) ─────────────────────────────────────
    local systray = nil
    if s == screen.primary then
        local st = wibox.widget.systray()
        st:set_horizontal(false)
        systray = wibox.widget {
            st,
            top    = dpi(4),
            bottom = dpi(4),
            left   = dpi(2),
            right  = dpi(2),
            widget = wibox.container.margin,
        }
    end

    -- ── Vertical left wibar ────────────────────────────────────────────────
    s.mywibox = awful.wibar({
        position = "left",
        screen   = s,
        width    = beautiful.wibar_width,
        bg       = beautiful.wibar_bg,
        fg       = beautiful.wibar_fg,
    })

    -- Bottom pill contents: systray? → battery → layout icon
    local bottom_contents = wibox.widget {
        spacing = dpi(4),
        layout  = wibox.layout.fixed.vertical,
    }
    if systray then
        bottom_contents:add(systray)
    end
    bottom_contents:add(bat_stack)
    bottom_contents:add(wibox.widget {
        s.mylayoutbox,
        top    = dpi(4),
        bottom = dpi(4),
        left   = dpi(4),
        right  = dpi(4),
        widget = wibox.container.margin,
    })

    local bottom_section = section_pill(bottom_contents, dpi(6), dpi(4))

    s.mywibox:setup {
        layout = wibox.layout.align.vertical,

        -- Top: taglist floating pill
        {
            {
                section_pill(s.mytaglist),
                top    = dpi(8),
                bottom = dpi(4),
                left   = dpi(4),
                right  = dpi(4),
                widget = wibox.container.margin,
            },
            layout = wibox.layout.fixed.vertical,
        },

        -- Center: stacked clock floating pill
        {
            clock_section,
            valign = "center",
            halign = "center",
            widget = wibox.container.place,
        },

        -- Bottom: systray + battery + layout floating pill
        {
            {
                bottom_section,
                bottom = dpi(8),
                left   = dpi(4),
                right  = dpi(4),
                widget = wibox.container.margin,
            },
            valign = "bottom",
            halign = "center",
            widget = wibox.container.place,
        },
    }
end

return M
