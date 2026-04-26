sanitize_name() {
    # Mirrors yt-dlp --restrict-filenames: keep alphanumeric, dot, hyphen, underscore
    echo "$1" | sed 's/[^a-zA-Z0-9_.-]/_/g' | sed -E 's/_+/_/g; s/^[_.]+//; s/[_.]+$//'
}

check_existing_file() {
    local type="$1"
    local ts
    ts=$(sanitize_name "$TITLE")

    case "$type" in
        MP4) find "$MP4_DIR" -name "${ts}.mp4" 2>/dev/null | head -1 ;;
        MP3) find "$MP3_DIR" -name "${ts}.mp3" 2>/dev/null | head -1 ;;
    esac
}

confirm_overwrite() {
    local type="$1" file="$2"

    [[ -n "$file" ]] || return 1

    echo "[!] $type already downloaded:"
    echo -e "    ${file#"$MP4_DIR"/} > ${file#"$MP3_DIR"/}" | sed "s|^$MP4_DIR/||;s|^$MP3_DIR/||"
    echo

    local answer
    answer=$(printf 'Replace\nSkip\n' \
        | fzf --prompt="$type exists > " --height=5) || return 1
    [[ "$answer" == "Replace" ]]
}

output_template() {
    [[ "$PLAYLIST_MODE" == "playlist" ]] \
        && echo "${PLAYLIST_NAME:-%(uploader)s}/%(title)s.%(ext)s" \
        || echo "%(uploader)s/%(title)s.%(ext)s"
}

download_mp4() {
    local url="$1" format="$2"
    local cmd=("${YTDLP[@]}"
        -f "$format"
        --merge-output-format mp4
        -P "$MP4_DIR"
        -o "$(output_template)"
        --restrict-filenames
    )
    [[ "$PLAYLIST_MODE" == "single" ]]        && cmd+=(--no-playlist)
    [[ "${FORCE_OVERWRITE_MP4:-0}" == "1" ]] && cmd+=(--force-overwrites)
    cmd+=("$url")
    "${cmd[@]}"
}

download_mp3() {
    local url="$1" format="$2"
    local cmd=("${YTDLP[@]}"
        -x
        -f "$format"
        --audio-format mp3
        --audio-quality 0
        --embed-thumbnail
        --add-metadata
        -P "$MP3_DIR"
        -o "$(output_template)"
        --restrict-filenames
    )
    [[ "$PLAYLIST_MODE" == "single" ]]        && cmd+=(--no-playlist)
    [[ "${FORCE_OVERWRITE_MP3:-0}" == "1" ]] && cmd+=(--force-overwrites)
    cmd+=("$url")
    "${cmd[@]}"
}
