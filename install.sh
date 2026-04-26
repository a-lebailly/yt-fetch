#!/usr/bin/env bash

set -euo pipefail

REPO_URL="https://github.com/a-lebailly/yt-fetch"
ARCHIVE_URL="${REPO_URL}/archive/refs/heads/main.tar.gz"
PREFIX="${HOME}/.local"
SYSTEM_INSTALL=0
CHECK_ONLY=0
SKIP_DEPS=0

usage() {
    cat <<EOF
Usage:
  install.sh [options]

Options:
      --prefix <path>    Install prefix (default: ~/.local)
      --system           Install to /usr/local
      --check            Only check dependencies
      --skip-deps        Do not fail when dependencies are missing
  -h, --help             Show this help
EOF
}

die() {
    echo "[!] $*" >&2
    exit 1
}

info() {
    echo "[+] $*"
}

warn() {
    echo "[!] $*" >&2
}

have() {
    command -v "$1" >/dev/null 2>&1
}

parse_args() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --prefix)
                [[ $# -ge 2 ]] || die "Missing value for --prefix"
                PREFIX="$2"
                shift 2
                ;;
            --system)
                PREFIX="/usr/local"
                SYSTEM_INSTALL=1
                shift
                ;;
            --check)
                CHECK_ONLY=1
                shift
                ;;
            --skip-deps)
                SKIP_DEPS=1
                shift
                ;;
            -h|--help)
                usage
                exit 0
                ;;
            *)
                die "Unknown option: $1"
                ;;
        esac
    done
}

detect_os() {
    OS_NAME="$(uname -s)"
    DISTRO_ID="unknown"
    DISTRO_LIKE=""

    [[ "$OS_NAME" == "Linux" ]] || die "yt-fetch currently supports Linux only."

    if [[ -r /etc/os-release ]]; then
        # shellcheck disable=SC1091
        source /etc/os-release
        DISTRO_ID="${ID:-unknown}"
        DISTRO_LIKE="${ID_LIKE:-}"
    fi
}

detect_session() {
    SESSION_TYPE="${XDG_SESSION_TYPE:-}"
    if [[ -z "$SESSION_TYPE" ]]; then
        if [[ -n "${WAYLAND_DISPLAY:-}" ]]; then
            SESSION_TYPE="wayland"
        elif [[ -n "${DISPLAY:-}" ]]; then
            SESSION_TYPE="x11"
        else
            SESSION_TYPE="unknown"
        fi
    fi
}

missing_commands() {
    local missing=()
    local cmd
    for cmd in "$@"; do
        have "$cmd" || missing+=("$cmd")
    done
    [[ ${#missing[@]} -eq 0 ]] || printf '%s\n' "${missing[@]}"
}

package_hint() {
    local clipboard_pkg="$1"

    case "$DISTRO_ID" in
        arch|manjaro|endeavouros)
            echo "sudo pacman -S yt-dlp ffmpeg fzf ${clipboard_pkg} libnotify"
            ;;
        ubuntu|debian|linuxmint|pop)
            echo "sudo apt install yt-dlp ffmpeg fzf ${clipboard_pkg} libnotify-bin"
            ;;
        fedora)
            echo "sudo dnf install yt-dlp ffmpeg fzf ${clipboard_pkg} libnotify"
            ;;
        opensuse*|suse)
            echo "sudo zypper install yt-dlp ffmpeg fzf ${clipboard_pkg} libnotify-tools"
            ;;
        *)
            if [[ "$DISTRO_LIKE" == *"arch"* ]]; then
                echo "sudo pacman -S yt-dlp ffmpeg fzf ${clipboard_pkg} libnotify"
            elif [[ "$DISTRO_LIKE" == *"debian"* || "$DISTRO_LIKE" == *"ubuntu"* ]]; then
                echo "sudo apt install yt-dlp ffmpeg fzf ${clipboard_pkg} libnotify-bin"
            elif [[ "$DISTRO_LIKE" == *"fedora"* || "$DISTRO_LIKE" == *"rhel"* ]]; then
                echo "sudo dnf install yt-dlp ffmpeg fzf ${clipboard_pkg} libnotify"
            else
                echo "Install: yt-dlp ffmpeg fzf ${clipboard_pkg} notify-send"
            fi
            ;;
    esac
}

check_dependencies() {
    local required_missing=()
    local optional_missing=()
    local clipboard_pkg=""

    mapfile -t required_missing < <(missing_commands yt-dlp ffmpeg fzf)

    if [[ "$SESSION_TYPE" == "wayland" ]]; then
        have wl-paste || optional_missing+=("wl-paste")
        clipboard_pkg="wl-clipboard"
    elif [[ "$SESSION_TYPE" == "x11" ]]; then
        have xclip || have xsel || optional_missing+=("xclip or xsel")
        clipboard_pkg="xclip"
    else
        if ! have wl-paste && ! have xclip && ! have xsel; then
            optional_missing+=("wl-paste, xclip, or xsel")
        fi
        clipboard_pkg="wl-clipboard"
    fi

    have notify-send || optional_missing+=("notify-send")

    info "Detected Linux distro: ${DISTRO_ID}"
    info "Detected session: ${SESSION_TYPE}"

    if [[ ${#required_missing[@]} -eq 0 ]]; then
        info "Required dependencies are installed."
    else
        warn "Missing required dependencies: ${required_missing[*]}"
    fi

    if [[ ${#optional_missing[@]} -gt 0 ]]; then
        warn "Missing optional desktop helpers: ${optional_missing[*]}"
    fi

    if [[ ${#required_missing[@]} -gt 0 || ${#optional_missing[@]} -gt 0 ]]; then
        echo
        echo "Suggested install command:"
        echo "  $(package_hint "$clipboard_pkg")"
        echo
    fi

    if [[ ${#required_missing[@]} -gt 0 && "$SKIP_DEPS" != "1" ]]; then
        die "Install the required dependencies above, or re-run with --skip-deps."
    fi
}

download_source() {
    local tmpdir archive
    tmpdir="$(mktemp -d)"
    archive="${tmpdir}/yt-fetch.tar.gz"

    if have curl; then
        curl -fsSL "$ARCHIVE_URL" -o "$archive"
    elif have wget; then
        wget -qO "$archive" "$ARCHIVE_URL"
    else
        die "Missing curl or wget to download yt-fetch."
    fi

    tar -xzf "$archive" -C "$tmpdir"
    SOURCE_DIR="$(find "$tmpdir" -maxdepth 1 -type d -name 'yt-fetch-*' | head -1)"
    [[ -n "$SOURCE_DIR" ]] || die "Could not unpack yt-fetch archive."
}

resolve_source_dir() {
    if [[ -f ./yt-fetch && -d ./lib && -f ./Makefile ]]; then
        SOURCE_DIR="$(pwd)"
    else
        download_source
    fi
}

install_yt_fetch() {
    local install_cmd=(install)

    if [[ "$SYSTEM_INSTALL" == "1" && "${EUID}" -ne 0 ]]; then
        have sudo || die "System install requires sudo."
        install_cmd=(sudo install)
    fi

    info "Installing to ${PREFIX}"
    "${install_cmd[@]}" -Dm755 "${SOURCE_DIR}/yt-fetch" "${PREFIX}/bin/yt-fetch"
    "${install_cmd[@]}" -Dm755 "${SOURCE_DIR}/install.sh" "${PREFIX}/lib/yt-fetch/install.sh"
    "${install_cmd[@]}" -Dm644 "${SOURCE_DIR}/lib/config.sh" "${PREFIX}/lib/yt-fetch/config.sh"
    "${install_cmd[@]}" -Dm644 "${SOURCE_DIR}/lib/deps.sh" "${PREFIX}/lib/yt-fetch/deps.sh"
    "${install_cmd[@]}" -Dm644 "${SOURCE_DIR}/lib/ui.sh" "${PREFIX}/lib/yt-fetch/ui.sh"
    "${install_cmd[@]}" -Dm644 "${SOURCE_DIR}/lib/notify.sh" "${PREFIX}/lib/yt-fetch/notify.sh"
    "${install_cmd[@]}" -Dm644 "${SOURCE_DIR}/lib/history.sh" "${PREFIX}/lib/yt-fetch/history.sh"
    "${install_cmd[@]}" -Dm644 "${SOURCE_DIR}/lib/url.sh" "${PREFIX}/lib/yt-fetch/url.sh"
    "${install_cmd[@]}" -Dm644 "${SOURCE_DIR}/lib/playlist.sh" "${PREFIX}/lib/yt-fetch/playlist.sh"
    "${install_cmd[@]}" -Dm644 "${SOURCE_DIR}/lib/quality.sh" "${PREFIX}/lib/yt-fetch/quality.sh"
    "${install_cmd[@]}" -Dm644 "${SOURCE_DIR}/lib/download.sh" "${PREFIX}/lib/yt-fetch/download.sh"
    "${install_cmd[@]}" -Dm644 "${SOURCE_DIR}/lib/settings.sh" "${PREFIX}/lib/yt-fetch/settings.sh"
}

check_path() {
    local bindir="${PREFIX}/bin"
    case ":${PATH}:" in
        *":${bindir}:"*) ;;
        *)
            warn "${bindir} is not in PATH."
            echo "Add this to your shell config:"
            echo "  export PATH=\"${bindir}:\$PATH\""
            ;;
    esac
}

main() {
    parse_args "$@"
    detect_os
    detect_session
    check_dependencies

    if [[ "$CHECK_ONLY" == "1" ]]; then
        info "Check complete."
        exit 0
    fi

    resolve_source_dir
    install_yt_fetch
    check_path

    info "Installed yt-fetch."
    echo "Run: yt-fetch --help"
}

main "$@"
