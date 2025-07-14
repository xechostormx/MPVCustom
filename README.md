----------------------------------
This is designed for D://MPV
Trying to put it anywhere else is going to be a nightmare due to multiple jsons and bats adding various functions.
Remember to get the Firefox extension and move the file in the folder!
----------------------------------
Mpv build is initially 07/12/2025
Windows only. All useful functions you can add with meson enabled. No Alsa or dsound (yet)
----------------------------------
useful changes:

added terminal window when using ff2mpg
moved to modernz as an interface base
----------------------------------
Found Lua Changes:

autosave.lua has been rewriten as:
    autosave_echo.lua — Smart Playback Recovery for MPV
    Description: An enhanced rewrite of MPV’s autosave logic. It periodically writes the watch-later position, captures full local playback state,
    and restores sessions on demand. It’s lightweight, zero-config, self-contained, and avoids hangs by throttling seek-triggered saves.
    Core Features:
    Periodic Position Saving • Writes playback position every 30 seconds • Writes playback position after any manual seek (default throttle: 5 seconds)
    Local State Capture Saves last played file path, volume, fullscreen status, subtitle track ID, and audio track ID
    Session Restoration On request (or automatically once at startup), reopens the last saved file and restores volume, fullscreen, and track selections
    File Type Filtering Skips saving or restoring for remote streams (URLs containing “://”) and HLS playlists (*.m3u8)
    No External Configs Fully self-contained Lua script—no extra .conf entries or user options needed
    Portable Save Location Resolves its own script directory at load time (via Lua debug.getinfo) and writes last_state.json alongside the script
    Minimal Logging All messages prefixed with “[autosave_echo]”; control global verbosity with MPV’s standard msg-level flags 
	(e.g., --msg-level=all=info or all=verbose)
    Script Message API Supports mpv command “script-message restore-last” for manual or external invocation of session restore
    Integration Notes: Place autosave_echo.lua in your scripts/ folder. MPV will auto-restore the last session once on startup if state exists,
	periodically save watch-later points, and throttle seek saves to prevent hangs.
	
sponsorblock_minimal.lua has been rewritten as:
	sponsorblock_minimal_echo.lua — Lightweight Async SponsorBlock for MPV
    Description A minimal, zero-hang SponsorBlock integration for MPV that automatically skips unwanted YouTube segments. It fetches skip-segments asynchronously, jumps over sponsor parts with a single OSD notification per segment, and requires no manual toggles or external dependencies beyond MPV and curl.
    Core Features:
    Asynchronous Fetch • Uses command_native_async (curl) to download skip segments without freezing playback.
    Automatic Sponsor Skipping • Detects sponsor segments and jumps forward seamlessly (with a 0.01s buffer).
    Configurable Categories • Default skips only "sponsor", but you can add "intro", "outro", "selfpromo", "interaction", etc., via script-opts.
    YouTube-Only Detection • Parses common YouTube URL patterns and skips only when a valid video ID is found.
    Single OSD Notice • Displays one concise on-screen message (“⏩ skipping 15s”) per segment to avoid spamming.
    Automatically enables on load when segments exist; no key-binding clutter.
    No External Dependencies • Pure Lua script; relies only on MPV’s native subprocess support and curl.
    Simple Configuration if desired • All settings via script-opts/sponsorblock_minimal_echo-*. in mpv.conf (server URL, categories, hash mode).
    Minimal Logging • Every log is prefixed [sponsorblock_minimal_echo]; control verbosity with MPV’s --msg-level flags.
    Integration Notes: Place sponsorblock_minimal_echo.lua in your scripts/ folder. Ensure curl is available in your PATH for HTTP requests.
	you probably have curl in  C:\Program Files\Git\mingw64\bin\
----------------------------------