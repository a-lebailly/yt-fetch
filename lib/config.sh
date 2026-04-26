YT_FETCH_CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}/yt-fetch/config"

# Load saved user config before applying defaults
[[ -f "$YT_FETCH_CONFIG" ]] && source "$YT_FETCH_CONFIG"

MP4_DIR="${MP4_DIR:-$HOME/Videos/YouTube}"
MP3_DIR="${MP3_DIR:-$HOME/Music/YouTube}"
HISTORY_FILE="${HISTORY_FILE:-$HOME/.local/share/yt-fetch/history.log}"

ensure_runtime_dirs() {
    mkdir -p "$MP4_DIR" "$MP3_DIR" "$(dirname "$HISTORY_FILE")"
}
