check_deps() {
    local missing=()
    local deps=(yt-dlp ffmpeg)
    [[ "${NON_INTERACTIVE:-0}" != "1" ]] && deps+=(fzf)

    for dep in "${deps[@]}"; do
        command -v "$dep" &>/dev/null || missing+=("$dep")
    done
    [[ ${#missing[@]} -eq 0 ]] || { echo "[!] Missing: ${missing[*]}"; exit 1; }
}

build_ytdlp_cmd() {
    YTDLP=(yt-dlp)
    for browser in firefox chromium chrome brave vivaldi; do
        if command -v "$browser" &>/dev/null; then
            YTDLP+=(--cookies-from-browser "$browser")
            break
        fi
    done
}
