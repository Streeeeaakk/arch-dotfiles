#!/bin/bash
if hyprctl devices -j | jq -e ".keyboards[0].active_keymap | contains(\"intl\")" > /dev/null; then
    echo "Eng Itl"
else
    echo "Eng Us"
fi
