notify() {
    command -v notify-send &>/dev/null \
        && notify-send --app-name="YT FETCH" "$1" "${2:-}" 2>/dev/null \
        || true
}
