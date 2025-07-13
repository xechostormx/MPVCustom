-- autosave_echo.lua
-- Smart, non-blocking autosave + resume for MPV, with throttled seeks.

local mp      = require 'mp'
local utils   = require 'mp.utils'
local options = require 'mp.options'

-- Custom logger
local msg = {
    info    = function(s) mp.msg.info("[autosave_echo] " .. s) end,
    warn    = function(s) mp.msg.warn("[autosave_echo] " .. s) end,
    verbose = function(s) mp.msg.verbose("[autosave_echo] " .. s) end,
}

-- User options
local o = {
    save_period   = 30,          -- seconds between watch-later saves
    state_file    = "last_state.json",
    seek_throttle = 5,           -- seconds to wait after last seek
}
options.read_options(o)

-- Compute script directory once (avoid repeated debug.getinfo calls)
local script_dir = (function()
    local src = debug.getinfo(1, "S").source or ""
    src = src:gsub("^@", "")
    local dir = src:match("^(.*)[/\\]") or utils.getcwd()
    if dir == "" then
        msg.warn("Could not auto-detect script directory; using CWD")
        dir = utils.getcwd()
    end
    return dir
end)()

-- Path to state JSON
local function get_state_path()
    return utils.join_path(script_dir, o.state_file)
end

-- Timer for periodic watch-later saves
local timer

local function reset_timer()
    if timer then
        timer:kill()
        timer = nil
    end
end

-- Write MPV's watch-later config
local function save_watch_later()
    if mp.get_property_bool("seekable", true) then
        mp.command("write-watch-later-config")
        msg.verbose("Watch-later saved.")
    end
end

-- Write JSON state (path, volume, fullscreen, tracks)
local function save_state()
    local path = mp.get_property("path")
    if not path or path:find("://") then return end
    if mp.get_property("filename"):match("%.m3u8$") then return end

    local state = {
        path       = path,
        volume     = tonumber(mp.get_property("volume")),
        fullscreen = mp.get_property_bool("fullscreen"),
        sub        = mp.get_property_number("sid"),
        aid        = mp.get_property("aid")
    }
    local json = utils.format_json(state)
    local fpath = get_state_path()
    local f = io.open(fpath, "wb")
    if f then
        f:write(json)
        f:close()
        msg.verbose("State saved to " .. fpath)
    end
end

-- Restore last saved session
local function restore_last()
    local fpath = get_state_path()
    local f = io.open(fpath, "rb")
    if not f then
        msg.warn("No saved state found.")
        return
    end

    local data = f:read("*a")
    f:close()

    local state = utils.parse_json(data)
    if not state or not state.path then
        msg.warn("Invalid state file.")
        return
    end

    msg.info("Restoring last file: " .. state.path)
    mp.commandv("loadfile", state.path, "replace")
    if state.volume     then mp.set_property("volume", state.volume) end
    if state.fullscreen then mp.set_property_bool("fullscreen", state.fullscreen) end
    if state.sub        then mp.set_property_number("sid", state.sub) end
    if state.aid        then mp.set_property("aid", state.aid) end
end

-- Pause/resume periodic timer
local function on_pause(_, paused)
    if not timer then return end
    if paused then timer:stop() else timer:resume() end
end

-- Start periodic autosave when a file loads
local function on_file_loaded()
    if not mp.get_property_bool("seekable", true) then
        msg.verbose("Non-seekable – autosave disabled.")
        return
    end
    reset_timer()
    timer = mp.add_periodic_timer(o.save_period, save_watch_later)
    mp.observe_property("pause", "bool", on_pause)
    msg.info("Autosave every " .. o.save_period .. " seconds.")
end

-- Throttled seek handler (5s default)
local seek_timer = nil
mp.register_event("seek", function()
    if seek_timer then return end
    seek_timer = mp.add_timeout(o.seek_throttle, function()
        save_watch_later()
        save_state()
        seek_timer = nil
    end)
end)

-- Register core hooks
mp.register_event("file-loaded",     on_file_loaded)
mp.register_event("end-file",        save_state)
mp.register_script_message("restore-last", restore_last)

-- One-time safe restore on startup
do
    local restored = false
    mp.register_event("start-file", function()
        if restored then return end
        local f = io.open(get_state_path(), "rb")
        if f then
            f:close()
            mp.command("script-message restore-last")
            restored = true
        end
    end)
end
