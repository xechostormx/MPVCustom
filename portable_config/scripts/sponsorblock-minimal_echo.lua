-- sponsorblock_minimal_echo.lua
-- Async SponsorBlock for MPV, with path-based URLs and fallback

local mp    = require 'mp'
local msg   = mp.msg
local utils = require 'mp.utils'
local opt   = require 'mp.options'

local prefix = "[sponsorblock_minimal_echo] "

-- User options
local o = {
    server     = "https://sponsor.ajay.me/api/skipSegments",  -- base path, no trailing slash
    categories = { "sponsor" },
    hash       = false,
}
opt.read_options(o)

-- URL-encode JSON array for query
local function urlencode(s)
    return (s:gsub("([^%w%-_.~])", function(c)
        return string.format("%%%02X", string.byte(c))
    end))
end

-- Build two candidate URLs:
--   1) {server}/{id}?categories=...
--   2) fallback to /api/segments/{id}?categories=...
local function build_urls(id)
    local cat_enc  = urlencode(utils.format_json(o.categories))
    local urls = {}

    -- primary endpoint: skipSegments path
    table.insert(urls, string.format("%s/%s?categories=%s", o.server, id, cat_enc))

    -- optional: segments endpoint (same host, different path)
    urls[#urls+1] = string.format(
        "%s?segments/%s?categories=%s",
        o.server:gsub("/skipSegments$","/segments"),
        id,
        cat_enc
    )

    return urls
end

-- Async fetch with automatic fallback on 404/empty
local function fetch_ranges(id, urls, cb, idx)
    idx = idx or 1
    local url = urls[idx]
    msg.debug(prefix .. "trying URL: " .. url)

    mp.command_native_async({
        name           = "subprocess",
        capture_stdout = true,
        args           = { "curl", "-L", "-s", "-g", url },
    }, function(success, res)
        local body = (res and res.stdout) or ""

        -- HTTP or empty => try next URL
        if not success or body == "" or body:match("^Not Found") then
            msg.debug(prefix .. "no data at idx="..idx)
            if idx < #urls then
                return fetch_ranges(id, urls, cb, idx+1)
            else
                msg.info(prefix .. "no sponsor segments found")
                return cb(nil)
            end
        end

        -- parse JSON
        local ok, parsed = pcall(utils.parse_json, body)
        if not ok or type(parsed) ~= "table" then
            msg.error(prefix .. "JSON parse error, raw response:")
            for line in body:gmatch("[^\r\n]+") do
                msg.error(prefix .. "  " .. line)
            end
            return cb(nil)
        end

        -- if using hash, filter by videoID field
        if o.hash then
            for _, entry in ipairs(parsed) do
                if entry.videoID == id then
                    return cb(entry.segments)
                end
            end
            return cb(nil)
        end

        cb(parsed)
    end)
end

-- jump-over logic
local active_ranges, current_seg
local function skip_ads(_, pos)
    if not active_ranges then return end
    for _, seg in ipairs(active_ranges) do
        local s,e = seg.segment[1], seg.segment[2]
        if s <= pos and pos < e then
            if current_seg ~= seg then
                current_seg = seg
                local delta = math.floor(e-pos)
                msg.info(prefix .. "skipping "..delta.."s")
                mp.osd_message(prefix.."⏩ skipping "..delta.."s", 1.5)
                mp.set_property_number("time-pos", e+0.01)
            end
            return
        end
    end
    current_seg = nil
end

-- on file load: extract ID, fetch ranges, start observing
local function file_loaded()
    mp.unobserve_property(skip_ads)
    active_ranges, current_seg = nil, nil

    local path = mp.get_property("path","") or ""
    local id = path:match("youtu%.be/([%w-_]+)")
            or path:match("youtube%.com/watch%?v=([%w-_]+)")
            or mp.get_property("metadata/by-key/PURL",""):match("([%w-_]+)$")

    if not id or #id<11 then return end

    local urls = build_urls(id)
    fetch_ranges(id, urls, function(ranges)
        if not ranges or #ranges == 0 then return end
        active_ranges = ranges
        msg.info(prefix.."loaded "..#ranges.." segment(s)")
        mp.observe_property("time-pos","number",skip_ads)
    end)
end

-- cleanup
local function end_file() mp.unobserve_property(skip_ads) active_ranges=nil end

mp.register_event("file-loaded", file_loaded)
mp.register_event("end-file",    end_file)
