get_clipboard_url() {
    local clip=""

    if command -v wl-paste &>/dev/null; then
        clip=$(wl-paste --no-newline 2>/dev/null || true)
    elif command -v xclip &>/dev/null; then
        clip=$(xclip -selection clipboard -o 2>/dev/null || true)
    elif command -v xsel &>/dev/null; then
        clip=$(xsel --clipboard --output 2>/dev/null || true)
    fi

    echo "$clip"
}

get_url() {
    local clip=""
    clip=$(get_clipboard_url)

    local options=()
    [[ "$clip" =~ (youtube\.com/watch|youtu\.be/|youtube\.com/playlist) ]] \
        && options+=("Clipboard  ->  $clip")
    options+=("Enter URL manually" "Search history" "Manage history" "Settings")

    local choice
    choice=$(printf '%s\n' "${options[@]}" \
        | fzf --prompt="URL source > " --height=10) || exit 0

    case "$choice" in
        "Clipboard"*)
            echo "$clip"
            ;;
        "Enter URL manually")
            read -rp "URL: " _url
            echo "$_url"
            ;;
        "Search history")
            if [[ ! -f "$HISTORY_FILE" ]] || [[ ! -s "$HISTORY_FILE" ]]; then
                echo "[!] No history found." >&2
                sleep 1
                echo "__LOOP__"
                return
            fi
            local url
            url=$(browse_history) || { echo "__LOOP__"; return; }
            echo "$url"
            ;;
        "Manage history")
            echo "__MANAGE_HISTORY__"
            ;;
        "Settings")
            echo "__SETTINGS__"
            ;;
    esac
}
