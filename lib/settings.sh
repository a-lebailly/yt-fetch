_save_config() {
    mkdir -p "$(dirname "$YT_FETCH_CONFIG")"
    printf 'MP4_DIR="%s"\nMP3_DIR="%s"\n' "$MP4_DIR" "$MP3_DIR" > "$YT_FETCH_CONFIG"
}

_pick_dir() {
    local label="$1"
    shift
    local choice
    choice=$(printf '%s\n' "$@" "Custom path..." \
        | fzf --prompt="$label dir > " --height=10) || return 1

    if [[ "$choice" == "Custom path..." ]]; then
        read -rp "Path: " choice
        choice="${choice/#\~/$HOME}"
    fi

    [[ -n "$choice" ]] && echo "$choice"
}

show_settings() {
    while true; do
        clear
        echo "================================"
        echo "           SETTINGS             "
        echo "================================"
        echo
        printf '  MP4 → %s\n' "$MP4_DIR"
        printf '  MP3 → %s\n' "$MP3_DIR"
        echo

        local choice
        choice=$(printf 'Change MP4 directory\nChange MP3 directory\nReset to defaults\nBack\n' \
            | fzf --prompt="Settings > " --height=7) || break

        case "$choice" in
            "Change MP4 directory")
                local dir
                dir=$(_pick_dir "MP4" \
                    "$HOME/Videos/YouTube" \
                    "$HOME/Videos" \
                    "$HOME/Movies" \
                    "$HOME/Downloads") || continue
                MP4_DIR="$dir"
                mkdir -p "$MP4_DIR"
                _save_config
                echo "[+] MP4 → $MP4_DIR"
                sleep 1
                ;;
            "Change MP3 directory")
                local dir
                dir=$(_pick_dir "MP3" \
                    "$HOME/Music/YouTube" \
                    "$HOME/Music" \
                    "$HOME/Downloads") || continue
                MP3_DIR="$dir"
                mkdir -p "$MP3_DIR"
                _save_config
                echo "[+] MP3 → $MP3_DIR"
                sleep 1
                ;;
            "Reset to defaults")
                local confirm
                confirm=$(printf 'Yes — reset\nCancel\n' \
                    | fzf --prompt="Reset? > " --height=5) || continue
                [[ "$confirm" == "Yes — reset" ]] || continue
                MP4_DIR="$HOME/Videos/YouTube"
                MP3_DIR="$HOME/Music/YouTube"
                mkdir -p "$MP4_DIR" "$MP3_DIR"
                _save_config
                echo "[+] Reset to defaults."
                sleep 1
                ;;
            "Back"|*)
                break
                ;;
        esac
    done
}
