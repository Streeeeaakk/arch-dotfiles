#!/usr/bin/env bash

item="$1"

printf '%s\n' "$item" | cliphist decode | wl-copy
