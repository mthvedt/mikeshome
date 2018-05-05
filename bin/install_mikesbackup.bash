#!/usr/bin/env bash -x -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
MIKESBACKUP_PLIST="$DIR/../etc/mikesbackup.plist"
TARGET="/Library/LaunchDaemons/mikesbackup.plist"

sudo cp -fv "$MIKESBACKUP_PLIST" "$TARGET"
sudo chown root "$TARGET"
sudo chgrp wheel "$TARGET"
sudo chmod 700 "$TARGET"
sudo vim "$TARGET" || true

sudo launchctl unload "$TARGET" || true
sudo launchctl load -w "$TARGET"
