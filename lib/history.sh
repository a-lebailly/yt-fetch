log_history() {
    # FORMAT: DATE | MODE | TITLE | URL
    echo "$(date '+%Y-%m-%d %H:%M:%S') | $1 | $2 | $3" >> "$HISTORY_FILE"
}

browse_history() {
    [[ -f "$HISTORY_FILE" ]] || return 1
    local sel
    sel=$(tac "$HISTORY_FILE" | fzf --prompt="History > " --height=20) || return 1
    sed 's/.*| //' <<< "$sel"
}

manage_history() {
    if [[ ! -f "$HISTORY_FILE" ]] || [[ ! -s "$HISTORY_FILE" ]]; then
        echo "[!] No history found."
        sleep 1
        return
    fi

    local selected
    selected=$(
        { echo "--- Clear all history ---"; tac "$HISTORY_FILE"; } \
            | fzf --multi \
                  --prompt="Manage history > " \
                  --header="TAB select  |  ENTER confirm  |  ESC cancel" \
                  --height=20
    ) || return 0

    [[ -z "$selected" ]] && return 0

    # Clear all shortcut
    if [[ "$selected" == *"--- Clear all history ---"* ]]; then
        local confirm
        confirm=$(printf 'Yes — clear all\nCancel\n' \
            | fzf --prompt="Clear all history? > " --height=5) || return 0
        [[ "$confirm" == "Yes — clear all" ]] || return 0
        > "$HISTORY_FILE"
        echo "[+] History cleared."
        sleep 1
        return
    fi

    # Selective delete
    local count
    count=$(echo "$selected" | wc -l)

    local confirm
    confirm=$(printf 'Confirm delete\nCancel\n' \
        | fzf --prompt="Delete $count entries? > " --height=5) || return 0
    [[ "$confirm" == "Confirm delete" ]] || return 0

    grep -vFf <(echo "$selected") "$HISTORY_FILE" > "${HISTORY_FILE}.tmp" || true
    mv "${HISTORY_FILE}.tmp" "$HISTORY_FILE"

    local word
    [[ "$count" -eq 1 ]] && word="entry" || word="entries"
    echo "[+] Deleted $count $word."
    sleep 1
}
