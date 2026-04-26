pick_preset() {
    local options=(
        'MAX    — absolute best, any codec (VP9/AV1, 4K)'
        'SAFE   — H264 + m4a, max compatibility'
        'LIGHT  — 480p max, low bandwidth'
    )
    [[ "$PLAYLIST_MODE" != "playlist" ]] \
        && options+=('CUSTOM — pick format manually via fzf')

    local raw
    raw=$(printf '%s\n' "${options[@]}" \
        | fzf --prompt="Quality > " --height=8) || return 1
    awk '{print $1}' <<< "$raw"
}

resolve_video_format() {
    local url="$1" preset="$2"
    case "$preset" in
        MAX)
            echo "bestvideo+bestaudio"
            ;;
        SAFE)
            echo "bestvideo[vcodec^=avc1]+bestaudio[ext=m4a]/bestvideo[ext=mp4]+bestaudio"
            ;;
        LIGHT)
            echo "bestvideo[height<=480][ext=mp4]+bestaudio[ext=m4a]/bestvideo[height<=480]+bestaudio"
            ;;
        CUSTOM)
            local fmt id
            fmt=$("${YTDLP[@]}" -F "$url" 2>/dev/null \
                | grep -E '^[0-9]' \
                | grep -v 'audio only' \
                | fzf --prompt="Video format > " --height=20) || true
            id=$(awk '{print $1}' <<< "$fmt")
            [[ -n "$id" ]] \
                && echo "${id}+bestaudio[ext=m4a]/bestaudio" \
                || echo "bestvideo+bestaudio"
            ;;
        *)
            echo "bestvideo+bestaudio"
            ;;
    esac
}

resolve_audio_format() {
    local url="$1" preset="$2"
    case "$preset" in
        MAX)
            echo "bestaudio"
            ;;
        SAFE)
            echo "bestaudio[ext=m4a]/bestaudio"
            ;;
        LIGHT)
            echo "bestaudio[abr<=128]/bestaudio"
            ;;
        CUSTOM)
            local fmt id
            fmt=$("${YTDLP[@]}" -F "$url" 2>/dev/null \
                | grep -E '^[0-9]' \
                | grep 'audio only' \
                | fzf --prompt="Audio format > " --height=20) || true
            id=$(awk '{print $1}' <<< "$fmt")
            [[ -n "$id" ]] && echo "$id" || echo "bestaudio"
            ;;
        *)
            echo "bestaudio"
            ;;
    esac
}
