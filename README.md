This is designed for D://MPV
Trying to put it anywhere else is going to be a nightmare due to multiple jsons and bats adding various functions.
Remember to get the Firefox extension and move the file in the folder!

Mpv build is initially 07/12/2025
Windows only. All useful functions you can add with meson enabled. No Alsa or dsound (yet)

useful changes:
----------------------------------
added terminal window when using ff2mpg

Found Lua Changes:
----------------------------------
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