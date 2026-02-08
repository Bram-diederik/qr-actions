#!/bin/bash

#
#   Files arrive from Bluetooth devices.
#   Script verifies PIN if set.
#   Processes file based on its content (WiFi, URL, or text).
#   Saves output in Downloads and deletes the original.
#   Works with any file if no PIN is configured.


WATCH_DIR="/home/user/BluetoothDownloads"
DOWNLOAD_DIR="/home/user/Downloads"
PIN_FILE="/home/user/.config/bluetoothpin.txt"

# Clean the server PIN if the file exists
if [ -f "$PIN_FILE" ]; then
    SERVER_PIN=$(tr -d '\r\n ' < "$PIN_FILE")
else
    SERVER_PIN=""
fi

echo "Listening to $WATCH_DIR. PIN: ${SERVER_PIN:-<none>}"

inotifywait -m -e close_write -e moved_to --format "%f" "$WATCH_DIR" | while read -r FILE; do
    FULLPATH="$WATCH_DIR/$FILE"
    sleep 0.2

    [ ! -f "$FULLPATH" ] && continue

    # Line 1: Data, Line 2: PIN
    DATA=$(sed -n '1p' "$FULLPATH" | tr -d '\r\n')
    FILE_PIN=$(sed -n '2p' "$FULLPATH" | sed 's/^PIN: //' | tr -d '\r\n ')

    # Accept file if PIN is empty or matches
    if [ -z "$SERVER_PIN" ] || [ "$FILE_PIN" = "$SERVER_PIN" ]; then
        echo "PIN Verified or no PIN set."

        # CASE 1: WiFi
        if [[ "$DATA" =~ ^WIFI: ]]; then
            SSID=$(echo "$DATA" | sed -E 's/.*S:([^;]+);.*/\1/')
            PASS=$(echo "$DATA" | sed -E 's/.*P:([^;]+);.*/\1/')

            SAFE_SSID=$(echo "$SSID" | tr ' ' '_')
            CON_NAME="qr-action-$SAFE_SSID"

            echo "WiFi: Connecting to '$SSID' with profile '$CON_NAME'..."

            nmcli connection show "$CON_NAME" &>/dev/null && \
                nmcli connection delete "$CON_NAME"

            nmcli dev wifi connect "$SSID" password "$PASS" name "$CON_NAME"

        # CASE 2: URL
        elif [[ "$DATA" =~ ^https?:// ]]; then
            echo "URL detected: $DATA"
            wget -q -O "$DOWNLOAD_DIR/${FILE}.html" "$DATA" &
            echo "Downloading to $DOWNLOAD_DIR/${FILE}.html"

        # CASE 3: General Text
        else
            echo "$DATA" > "$DOWNLOAD_DIR/$FILE"
            echo "Saved text to $DOWNLOAD_DIR/$FILE"
        fi

        # Remove the original watched file
        rm "$FULLPATH"
    else
        echo "PIN Mismatch: Received '$FILE_PIN' - Ignoring."
    fi
done
