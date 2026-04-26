```
██╗   ██╗████████╗    ███████╗███████╗████████╗ ██████╗██╗  ██╗
╚██╗ ██╔╝╚══██╔══╝    ██╔════╝██╔════╝╚══██╔══╝██╔════╝██║  ██║
 ╚████╔╝    ██║       █████╗  █████╗     ██║   ██║     ███████║
  ╚██╔╝     ██║       ██╔══╝  ██╔══╝     ██║   ██║     ██╔══██║
   ██║      ██║       ██║     ███████╗   ██║   ╚██████╗██║  ██║
   ╚═╝      ╚═╝       ╚═╝     ╚══════╝   ╚═╝    ╚═════╝╚═╝  ╚═╝
```

Minimal YouTube downloader for Linux. `yt-fetch` wraps `yt-dlp` with a small Bash CLI, an optional `fzf` TUI, playlist handling, quality presets, history, overwrite checks, clipboard detection, and desktop notifications.  
This tool is intended for downloading content you have the rights to use. Please respect YouTube's Terms of Service and content licenses.

## Summary

- [Demo](#demo)
- [Install](#install)
- [Dependencies](#dependencies)
- [Usage](#usage)
- [Quality Presets](#quality-presets)
- [Settings](#settings)
- [Bot Detection](#bot-detection)

## Demo

https://github.com/user-attachments/assets/198f2230-1d51-4582-b92d-2854339648cf

Videos used in this demo are provided by [NoCopyrightSounds](https://www.youtube.com/@NoCopyrightSounds) :
- [DEAF KEV - Invincible](https://www.youtube.com/watch?v=J2X5mJ3HDYE)
- [Cartoon, Jéja - On & On (feat. Daniel Levi)](https://www.youtube.com/watch?v=K4DyBUG242c)
- [Spektrem - Shine](https://www.youtube.com/watch?v=n4tK7LYFxI0)
- [LXNGVX, Warriyo - Mortals Funk Remix](https://www.youtube.com/watch?v=pytdWKT-NV4)

## Install

Install for the current user:

```bash
curl -fsSL https://raw.githubusercontent.com/a-lebailly/yt-fetch/main/install.sh | bash
```

or with `wget`:

```bash
wget -qO- https://raw.githubusercontent.com/a-lebailly/yt-fetch/main/install.sh | bash
```

Install system-wide:

```bash
curl -fsSL https://raw.githubusercontent.com/a-lebailly/yt-fetch/main/install.sh | bash -s -- --system
```

Only check dependencies:

```bash
curl -fsSL https://raw.githubusercontent.com/a-lebailly/yt-fetch/main/install.sh | bash -s -- --check
```

Manual install:

```bash
git clone https://github.com/a-lebailly/yt-fetch
cd yt-fetch
make install PREFIX="$HOME/.local"
```

System manual install:

```bash
git clone https://github.com/a-lebailly/yt-fetch
cd yt-fetch
sudo make install
```

## Dependencies

| Dependency | Required | Purpose |
|------------|----------|---------|
| [yt-dlp](https://github.com/yt-dlp/yt-dlp) | yes | Download engine |
| [FFmpeg](https://ffmpeg.org/) | yes | Muxing and audio extraction |
| [fzf](https://github.com/junegunn/fzf) | TUI only | Interactive menus |
| [wl-clipboard](https://github.com/bugaevc/wl-clipboard) | optional | Wayland clipboard detection |
| [xclip](https://github.com/astrand/xclip) or [xsel](https://github.com/kfish/xsel) | optional | X11 clipboard detection |
| [libnotify / notify-send](https://gitlab.gnome.org/GNOME/libnotify) | optional | Desktop notifications |

Package examples:

```bash
# Arch / EndeavourOS / Manjaro
sudo pacman -S yt-dlp ffmpeg fzf wl-clipboard libnotify

# Ubuntu / Debian on Wayland
sudo apt install yt-dlp ffmpeg fzf wl-clipboard libnotify-bin

# Ubuntu / Debian on X11
sudo apt install yt-dlp ffmpeg fzf xclip libnotify-bin

# Fedora
sudo dnf install yt-dlp ffmpeg fzf wl-clipboard libnotify
```

Some distro repositories ship old `yt-dlp` builds. If YouTube extraction fails unexpectedly, install a newer `yt-dlp` from the official project or via `pipx`.

## Usage

Launch the TUI:

```bash
yt-fetch
```

Run without the TUI:

```bash
yt-fetch -m mp3 -q safe "https://youtu.com/..."
yt-fetch --url "https://youtu.com/..." --mode mp4
yt-fetch --mode both --quality max --overwrite "https://youtu.com/..."
yt-fetch --playlist --playlist-name my_mix -m mp4 -q light "https://youtube.com/playlist?list=..."
```

CLI options:

| Option | Values | Default |
|--------|--------|---------|
| `-u`, `--url` | YouTube URL | positional URL |
| `-m`, `--mode` | `mp4`, `mp3`, `both` | `mp4` |
| `-q`, `--quality` | `max`, `safe`, `light` | `safe` |
| `--single` | - | enabled |
| `--playlist` | - | disabled |
| `--playlist-name` | folder name | required with `--playlist` |
| `-y`, `--overwrite` | - | skip existing files |
| `-h`, `--help` | - | show help |

## Quality Presets

| Preset | Description |
|--------|-------------|
| `MAX` | Best available quality, any codec |
| `SAFE` | H264 + m4a for broad device compatibility |
| `LIGHT` | 480p max video or lower bitrate audio |
| `CUSTOM` | Interactive format picker through `yt-dlp -F` |

`CUSTOM` is available only in the TUI and only for single-video downloads. Playlist mode uses `MAX`, `SAFE`, or `LIGHT`.

## Settings

The TUI settings screen can change the MP4 and MP3 output directories. Settings are saved to:

```text
~/.config/yt-fetch/config
```

You can also override output directories per command:

```bash
MP4_DIR=~/Downloads MP3_DIR=~/Downloads yt-fetch --mode both "https://youtu.com/..."
```

History is saved to:

```text
~/.local/share/yt-fetch/history.log
```

## Bot Detection

If YouTube returns bot-detection errors, `yt-fetch` automatically tries to use cookies from an installed browser through `yt-dlp --cookies-from-browser`.
