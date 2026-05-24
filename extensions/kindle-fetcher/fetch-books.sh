#!/bin/sh

BASE_URL="http://192.168.1.10:8000/kindle/"
DOWNLOAD_DIR="/mnt/us/documents"
INDEX_FILE="/tmp/kindle-fetcher-index.html"
LINKS_FILE="/tmp/kindle-fetcher-links.txt"
SHOW_SCREEN=1
EIPS_LOG_COL=5
EIPS_LOG_ROW=15
EIPS_LOG_COLS=38
EIPS_LOG_ROWS=11
EIPS_LOG_LINE=0
EIPS_CLEAR_TEXT="                                      "

SCRIPT_DIR=${0%/*}
if [ "$SCRIPT_DIR" = "$0" ]; then
    SCRIPT_DIR="."
fi

LOG_FILE="$SCRIPT_DIR/fetch-books.log"

# Optional local override. Keep this file on the Kindle if your server URL changes.
if [ -f "$SCRIPT_DIR/settings.sh" ]; then
    . "$SCRIPT_DIR/settings.sh"
fi

log_msg() {
    message="$1"

    printf '%s\n' "$message" >&2
    printf '%s %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$message" >> "$LOG_FILE"
    screen_log "$message"
}

screen_log() {
    [ "$SHOW_SCREEN" = "1" ] || return 0
    message="$1"
    row=$((EIPS_LOG_ROW + EIPS_LOG_LINE))

    eips "$EIPS_LOG_COL" "$row" "$EIPS_CLEAR_TEXT" 2>>"$LOG_FILE"
    eips "$EIPS_LOG_COL" "$row" "$message" 2>>"$LOG_FILE"

    EIPS_LOG_LINE=$((EIPS_LOG_LINE + 1))
    if [ "$EIPS_LOG_LINE" -ge "$EIPS_LOG_ROWS" ]; then
        EIPS_LOG_LINE=0
    fi
}

fail() {
    log_msg "Error: $1"
    exit 1
}

decode_name() {
    printf '%s\n' "$1" |
        sed 's/%20/ /g; s/%28/(/g; s/%29/)/g; s/%5B/[/g; s/%5D/]/g; s/%2C/,/g; s/%27/'"'"'/g'
}

mkdir -p "$DOWNLOAD_DIR" || fail "cannot create $DOWNLOAD_DIR"
if ! : > "$LOG_FILE"; then
    printf '%s\n' "Error: cannot write log file $LOG_FILE" >&2
    screen_log "Log error"
    exit 1
fi

case "$BASE_URL" in
    */) : ;;
    *) BASE_URL="$BASE_URL/" ;;
esac

log_msg "Fetching list"
wget -q -O "$INDEX_FILE" "$BASE_URL" || fail "cannot fetch $BASE_URL"
[ -s "$INDEX_FILE" ] || fail "empty directory listing"

tr '<' '\n' < "$INDEX_FILE" |
    sed -n 's/.*[Hh][Rr][Ee][Ff]="\([^"]*\)".*/\1/p; s/.*[Hh][Rr][Ee][Ff]='"'"'\([^'"'"']*\)'"'"'.*/\1/p' > "$LINKS_FILE"

count=0
downloaded=0
skipped=0

while IFS= read -r href; do
    [ -n "$href" ] || continue

    case "$href" in
        ../|./|/*|*://*|//*|*/*|*\?*|*\#*)
            continue
            ;;
    esac

    lower=$(printf '%s\n' "$href" | tr 'ABCDEFGHIJKLMNOPQRSTUVWXYZ' 'abcdefghijklmnopqrstuvwxyz')
    case "$lower" in
        *.mobi|*.azw|*.azw3) : ;;
        *) continue ;;
    esac

    count=$((count + 1))
    name=$(decode_name "$href")
    target="$DOWNLOAD_DIR/$name"

    if [ -s "$target" ]; then
        skipped=$((skipped + 1))
        log_msg "Skipping existing: $name"
        continue
    fi

    log_msg "Downloading: $name"
    if wget -q -O "$target" "$BASE_URL$href"; then
        if [ -s "$target" ]; then
            downloaded=$((downloaded + 1))
        else
            rm -f "$target"
            log_msg "Empty download: $name"
        fi
    else
        rm -f "$target"
        log_msg "Failed download: $name"
    fi
done < "$LINKS_FILE"

rm -f "$INDEX_FILE" "$LINKS_FILE"

if [ "$count" -eq 0 ]; then
    fail "no .mobi, .azw, or .azw3 links found"
fi

if command -v lipc-set-prop >/dev/null 2>&1; then
    lipc-set-prop -- com.lab126.scanner doFullScan 1 >/dev/null 2>&1
    log_msg "Requested document rescan"
else
    log_msg "lipc-set-prop unavailable; rescan skipped"
fi

log_msg "Done: $downloaded downloaded, $skipped skipped"
exit 0
