local awful = require("awful")

-- Spawn a program if it isn't already running
local function run_once(cmd_arr)
    local findme  = cmd_arr[1]
    local firstarg = cmd_arr[2]
    if firstarg then
        findme = findme .. " " .. firstarg
    end
    awful.spawn.with_shell(string.format(
        "pgrep -u $USER -x '%s' > /dev/null || (%s)",
        findme,
        table.concat(cmd_arr, " ")
    ))
end

-- Kill the system-default xcompmgr before picom claims the compositing slot
awful.spawn.with_shell(
    "pkill -x xcompmgr; sleep 0.5 && picom --config ~/.config/picom/picom.conf --daemon"
)

-- Wallpaper — northernlights.jpg; change path/filename as needed
awful.spawn.with_shell("feh --bg-fill ~/Pictures/Wallpapers/blue_lake-OM.jpg")

-- Quickshell: bar, notifications, settings app (config in ~/.config/quickshell)
awful.spawn.with_shell(
    "pgrep -x quickshell >/dev/null || pgrep -x qs >/dev/null || qs >/dev/null 2>&1 &"
)

-- Clipboard daemon (feeds Super+/ rofi clipboard picker)
run_once({ "greenclip", "daemon" })

-- xsettingsd propagates GTK/icon theme to running apps
run_once({ "xsettingsd" })

-- Polkit authentication agent — uncomment whichever path exists on your system:
-- run_once({ "/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1" })
-- run_once({ "/usr/libexec/polkit-gnome-authentication-agent-1" })
-- run_once({ "/usr/lib/xfce4/polkit-gnome-authentication-agent-1" })

return {}
