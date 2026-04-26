sanitize_playlist_name() {
    echo "$1" | sed 's/[^a-zA-Z0-9_.-]/_/g' | sed -E 's/_+/_/g; s/^[_.]+//; s/[_.]+$//'
}

# Modifies globals: PLAYLIST_MODE, PLAYLIST_NAME
handle_playlist() {
    [[ "$URL" =~ list= ]] || return 0

    local choice
    choice=$(printf 'Single video only\nFull playlist\n' \
        | fzf --prompt="Playlist detected > " --height=6) || exit 0

    if [[ "$choice" == "Single video only" ]]; then
        PLAYLIST_MODE="single"
        return 0
    fi

    PLAYLIST_MODE="playlist"

    local raw_name
    while true; do
        read -rp "Playlist name: " raw_name
        PLAYLIST_NAME=$(sanitize_playlist_name "$raw_name")
        [[ -n "$PLAYLIST_NAME" ]] && break
        echo "[!] Playlist name cannot be empty."
    done
}
