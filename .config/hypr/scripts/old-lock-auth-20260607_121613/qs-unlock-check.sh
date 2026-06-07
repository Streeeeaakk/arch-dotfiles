#!/usr/bin/env bash
set -euo pipefail

AUTH="$HOME/.config/hypr/scripts/qs-pam-auth"

if [[ ! -x "$AUTH" ]]; then
  echo "FAIL"
  exit 1
fi

"$AUTH"
