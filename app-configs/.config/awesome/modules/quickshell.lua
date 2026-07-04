-- Bridge to quickshell: serialize per-screen tag/layout state to a JSON file
-- ($XDG_RUNTIME_DIR/awesomewm-state.json) that quickshell watches. Commands
-- come back the other way via `awesome-client` (see AwesomeState.qml).

local awful = require("awful")
local gears = require("gears")

local M = {}

local state_path = (os.getenv("XDG_RUNTIME_DIR") or "/tmp") .. "/awesomewm-state.json"

local function esc(s)
    local out = tostring(s):gsub('[\\"]', "\\%0"):gsub("\n", "\\n")
    return out
end

local function collect()
    local screens = {}
    for s in screen do
        local outputs = {}
        for name in pairs(s.outputs) do
            outputs[#outputs + 1] = '"' .. esc(name) .. '"'
        end

        local tags = {}
        for i, t in ipairs(s.tags) do
            tags[#tags + 1] = string.format(
                '{"index":%d,"name":"%s","selected":%s,"occupied":%s,"urgent":%s}',
                i, esc(t.name),
                tostring(t.selected),
                tostring(#t:clients() > 0),
                tostring(t.urgent or false)
            )
        end

        screens[#screens + 1] = string.format(
            '{"index":%d,"outputs":[%s],"layout":"%s","tags":[%s]}',
            s.index,
            table.concat(outputs, ","),
            esc(awful.layout.getname(awful.layout.get(s))),
            table.concat(tags, ",")
        )
    end
    return '{"screens":[' .. table.concat(screens, ",") .. "]}"
end

local function write_state()
    local f = io.open(state_path, "w")
    if not f then return end
    f:write(collect())
    f:close()
end

-- Coalesce signal bursts (e.g. a client moving between tags) into one write
local timer = gears.timer {
    timeout     = 0.05,
    single_shot = true,
    callback    = write_state,
}
local function schedule()
    if timer.started then timer:stop() end
    timer:start()
end

function M.setup()
    tag.connect_signal("property::selected",  schedule)
    tag.connect_signal("property::urgent",    schedule)
    tag.connect_signal("property::layout",    schedule)
    tag.connect_signal("property::activated", schedule)
    client.connect_signal("tagged",           schedule)
    client.connect_signal("untagged",         schedule)
    client.connect_signal("property::urgent", schedule)
    screen.connect_signal("list",             schedule)
    write_state()
end

return M
