#!/bin/sh
HYPR="$HOME/.config/hypr"
REPO="$(dirname "$0")"

cp "$HYPR/hlc.lua" "$REPO/hlc.lua"
cp "$HYPR/example.lua" "$REPO/example.lua"

echo "synced from $HYPR"
