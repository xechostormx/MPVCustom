------------

# MPV Build for Windows


## Installation
This build is designed for `D://MPV`. Placing it elsewhere may cause issues due to multiple JSONs and batch files enabling various functions.  
**Important**: Install the Firefox extension and move the provided file into the folder.

## Build Details
- **Initial Build Date**: July 12, 2025  
- **Platform**: Windows only  
- **Features**: All useful functions enabled via Meson. No ALSA or DSound support (yet).

## Notable Changes
- Added terminal window for `ff2mpg`.  
- Switched to `modernz` as the interface base.

---

## Lua Script Updates

### autosave_echo.lua
**Smart Playback Recovery for MPV**  
An enhanced rewrite of MPV’s autosave logic. Lightweight, zero-config, self-contained, and avoids hangs by throttling seek-triggered saves.

#### Core Features
- **Periodic Position Saving**: Saves playback position every 30 seconds and after manual seeks (5-second throttle).  
- **Local State Capture**: Saves last played file path, volume, fullscreen status, subtitle track ID, and audio track ID.  
- **Session Restoration**: Reopens the last saved file and restores settings on request or automatically at startup.  
- **File Type Filtering**: Skips saving/restoring for remote streams (URLs with `://`) and HLS playlists (*.m3u8).  
- **No External Configs**: Fully self-contained; no .conf entries needed.  
- **Portable Save Location**: Saves `last_state.json` alongside the script using Lua’s `debug.getinfo`.  
- **Minimal Logging**: Messages prefixed; control verbosity with MPV’s `--msg-level` (e.g., `--msg-level=all=info`).  
- **Script Message API**: Use `script-message restore-last` for manual session restore.  

#### Integration
Place `autosave_echo.lua` in your `scripts/` folder. MPV auto-restores the last session on startup if state exists, periodically saves watch-later points, and throttles seek saves.

---

### sponsorblock_minimal_echo.lua
**Lightweight Async SponsorBlock for MPV**  
A minimal, zero-hang rewite of sponsorblock_minimal.lua
SponsorBlock integration skips unwanted YouTube segments. Fetches skip-segments asynchronously and requires only MPV and `curl`.

#### Core Features
- **Asynchronous Fetch**: Uses `command_native_async` (curl) to download skip segments without freezing playback.  
- **Automatic Sponsor Skipping**: Skips sponsor segments seamlessly with a 0.01s buffer.  
- **Configurable Categories**: Skips "sponsor" by default; add "intro", "outro", "selfpromo", etc., via script-opts.  
- **YouTube-Only Detection**: Parses YouTube URLs and skips only for valid video IDs.  
- **Single OSD Notice**: Displays one concise message (e.g., “skipping 15s”) per segment.  
- **No External Dependencies**: Pure Lua; requires only MPV’s subprocess support and `curl`.  
- **Simple Configuration**: Optional settings via `script-opts/sponsorblock_minimal_echo-*` in `mpv.conf`.  
- **Minimal Logging**: Logs prefixed; control verbosity with `--msg-level`.  

#### Integration
Place `sponsorblock_minimal_echo.lua` in your `scripts/` folder. Ensure `curl` is in your PATH (e.g., `C:\Program Files\Git\mingw64\bin\`).

---

