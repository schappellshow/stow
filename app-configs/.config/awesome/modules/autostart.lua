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

-- Tie the systemd user session lifecycle to this session: services hooked
-- to graphical-session.target (espanso, ...) start here like they did
-- under Plasma. The matching stop lives in rc.lua's exit handler.
awful.spawn.with_shell(
    "systemctl --user import-environment DISPLAY XAUTHORITY XDG_CURRENT_DESKTOP DESKTOP_SESSION 2>/dev/null; "
    .. "systemctl --user start awesome-session.target"
)

-- Kill the system-default xcompmgr before picom claims the compositing slot
awful.spawn.with_shell(
    "pkill -x xcompmgr; sleep 0.5 && picom --config ~/.config/picom/picom.conf --daemon"
)

-- Wallpaper is quickshell's job now (Settings app → Wallpaper page;
-- common/Wallpaper.qml runs feh from Settings.wallpaperPath at startup).

-- Quickshell: bar, notifications, settings app (config in ~/.config/quickshell)
awful.spawn.with_shell(
    "pgrep -x quickshell >/dev/null || pgrep -x qs >/dev/null || qs >/dev/null 2>&1 &"
)

-- Clipboard daemon (feeds Super+/ rofi clipboard picker)
run_once({ "greenclip", "daemon" })

-- xsettingsd propagates GTK/icon theme to running apps
run_once({ "xsettingsd" })

-- Polkit authentication agent (lxqt-policykit: Qt-native, no KDE deps)
awful.spawn.with_shell(
    "pgrep -u $USER -f lxqt-policykit-agent > /dev/null || /usr/libexec/lxqt-policykit-agent &"
)

-- Screen locking: xss-lock bridges X screensaver + systemd (loginctl
-- lock-session, lock-before-suspend) to the lock-screen wrapper script.
awful.spawn.with_shell(
    "pgrep -u $USER -x xss-lock > /dev/null || xss-lock --transfer-sleep-lock -- lock-screen &"
)

-- Idle/DPMS timeouts are quickshell's job now (Settings app → Power page;
-- common/PowerConfig.qml runs xset from settings at startup and on change).

return {}
