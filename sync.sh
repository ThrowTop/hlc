#!/bin/sh
HYPR="$HOME/.config/hypr"
REPO="$(dirname "$0")"

cp "$HYPR/hlc.lua" "$REPO/hlc.lua"

echo "synced from $HYPR"
