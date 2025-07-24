# Custom mpv Build with Enhanced Features

This repository contains a custom build of [mpv](https://mpv.io/), a powerful, open-source media player, compiled with a rich set of features for enhanced multimedia playback on Windows. Built in the MSYS2 `MINGW64` environment on Windows 11, this configuration includes advanced audio, video, and scripting capabilities, making it ideal for enthusiasts and developers.

## Features

This custom `mpv` build (version 0.40.0-UNKNOWN) includes the following enabled features:

- **Audio Outputs**:
  - **OpenAL**: 3D audio processing for immersive sound (`--ao=openal`).
  - **DirectSound**: Legacy Windows audio output (`--ao=dsound`).
  - **WASAPI**: Modern Windows Audio Session API for high-quality audio (`--ao=wasapi`).
  - **SDL2 Audio**: Cross-platform audio output via SDL2 (`--ao=sdl2`).

- **Video Outputs and Rendering**:
  - **OpenGL**: Hardware-accelerated video rendering with advanced scaling (`--vo=opengl`).
  - **Direct3D 11**: High-performance Windows video output (`--vo=d3d11`).
  - **Direct3D 9 Hardware Acceleration**: Legacy Direct3D support (`--vo=d3d9`).
  - **Vulkan**: Modern graphics API for high-performance rendering (`--vo=vulkan`).
  - **Vulkan KHR Display**: Direct display output via Vulkan.
  - **Shaderc and SPIRV-Cross**: Support for advanced shader-based rendering.

- **Media Format Support**:
  - **CDDA**: Audio CD playback (`--cdda`).
  - **DVD Navigation**: DVD menu and playback support via `libdvdnav` and `libdvdread`.
  - **Blu-ray**: Blu-ray playback via `libbluray`.
  - **Game Music Emu**: Playback of video game music formats (e.g., `.spc`, `.nsf`) via `libgme`.
  - **Teletext and Closed Captions**: Decoding via `libzvbi` (`--vf=vbi`).
  - **Archive Files**: Playback of media in archives (e.g., `.zip`, `.rar`) via `libarchive`.

- **Image and Font Processing**:
  - **zimg**: High-quality image scaling and colorspace conversion (`--scale=zimg`).
  - **Fontconfig**: Flexible font selection for OSD and subtitles (`--sub-font`).
  - **JPEG**: JPEG image decoding.
  - **Little CMS 2 (lcms2)**: Color management for accurate display.

- **Scripting and Plugins**:
  - **Lua (LuaJIT)**: High-performance Lua scripting for custom functionality (`--script`).
  - **JavaScript**: JavaScript scripting for advanced customization.
  - **C Plugins**: Support for custom C plugins (`--cplugins`).
  - **LADSPA**: Audio effect plugins for processing (`--af=ladspa`).
  - **VapourSynth**: Advanced video processing scripts (`--vf=vapoursynth`).

- **Text and Encoding**:
  - **libass**: Advanced subtitle rendering.
  - **uchardet**: Automatic charset detection for subtitles.
  - **iconv**: Character encoding conversion.

- **Other**:
  - **FFmpeg and libavdevice**: Broad codec and device support.
  - **SDL2 Gamepad and Video**: Gamepad input and SDL2 video output.
  - **libplacebo**: Advanced video rendering library.
  - **zlib**: Compression support.
  - **Windows-Specific**: Full Windows integration (desktop, executable, threads, paths).
  - **Debug Build**: Includes debugging symbols for development.
  - **CACA**: ASCII art video output for fun terminal playback.


