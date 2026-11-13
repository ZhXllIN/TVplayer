# TVplayer · Dual-display signage player

[简体中文](README.md)

Run two TVs from one 64-bit Windows 10/11 PC. Channels A and B have independent playlists, display assignments, schedules and sign-in settings. The desktop interface is in Chinese.

## Quick start

1. Download the offline ZIP from [Releases](https://github.com/ZhXllIN/TVplayer/releases/latest). Extract it fully to a permanent, writable folder. It includes LibreOffice, Poppler and libmpv for offline playback.
2. Connect the TVs and choose **Win + P → Extend**. Double-click **Start.cmd**, then open channel A or B.
3. Choose **添加素材** to add files and **目标显示器** to select the display. Click **保存设置并开始 / 等待定时播放** to save and start or wait for the scheduled time.

## Media and playback

| Media | File types | Playback |
| --- | --- | --- |
| Video | MP4, MKV, MOV, AVI, WMV, M4V, WebM, TS, MPG, MPEG | Advances when the clip ends |
| Images | PNG, JPG, JPEG, BMP | Adjustable duration, 20 seconds by default |
| Presentations and documents | PPT, PPTX, PDF | Converted into static pages on import. Slides use the image duration. Animations and embedded videos are omitted. |

The playlist loops by default. Select **单项播放** to hold one page or repeat one clip. Both channels use the system default audio output. Per-channel audio routing is currently unavailable.

## Scheduling and sign-in

For example, enter `08:00-22:00` for playback and `12:00-13:00` for a lunch break. Overnight ranges are supported. An empty playback range means all day. An empty break means no break. Enable **Windows 登录后自动启动此路** and save to restore that channel at the next Windows sign-in. During breaks, the output window hides and the desktop may be visible.

## Running from source and moving to another PC

The repository contains the launcher, console, player scripts and native video bridge source. To run this checkout, copy the complete `tools` directory from the release alongside `Start.cmd`. The player stores settings, imported media and rendered pages in `PlayerData`. To move a configured player, copy its entire directory, select the displays on the destination PC and save the sign-in settings again.

## Third-party components in the offline package

| Component | Location in the ZIP | Purpose and upstream |
| --- | --- | --- |
| LibreOffice 26.2.7 (Impress) | `tools/LibreOffice/` | Converts PPT and PPTX to PDF using The Document Foundation’s Windows x64 build. See the bundled `LICENSE.html`, `license.txt` and `NOTICE` in this directory. [LibreOffice](https://www.libreoffice.org/) |
| Poppler 26.07.0 | `tools/poppler/` | Renders PDF pages to PNG with `bin/pdftoppm.exe`, its accompanying DLLs and resource directories. [Poppler](https://poppler.freedesktop.org/) |
| mpv (libmpv) | `tools/mpv/libmpv-2.dll` | Decodes and plays video through `PortableVideo.cs`. This DLL comes from the Tsukimi 26.6.1 Windows distribution. The version number identifies Tsukimi. [mpv](https://mpv.io/) · [Tsukimi](https://github.com/tsukinaha/tsukimi) |

The Git tree tracks only the project's `mpv/PortableVideo.cs` bridge under `tools/`. The release ZIP supplies the runtime files listed above. GitHub’s **Source code (zip)** contains the tracked sources. For deployment, download **TVplayer-v1.0.0-win-x64-offline.zip**. The UI uses Windows PowerShell, WPF and Windows Forms. WPF displays still images.
