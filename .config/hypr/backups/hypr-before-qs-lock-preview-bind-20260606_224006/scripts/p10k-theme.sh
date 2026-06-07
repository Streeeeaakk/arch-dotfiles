#!/usr/bin/env bash
set -euo pipefail

theme="${1:-purple}"
P10K="$HOME/.p10k.zsh"

[ -f "$P10K" ] || exit 0

case "$theme" in
  green)
    os_bg=46
    os_fg=0
    dir_bg=46
    dir_fg=0
    vcs_clean_bg=46
    vcs_mod_bg=82
    status_ok_bg=46
    status_ok_fg=0
    time_bg=46
    time_fg=0
    ornament_fg=46
    ;;

  purple|mauve)
    os_bg=55
    os_fg=15
    dir_bg=55
    dir_fg=15
    vcs_clean_bg=55
    vcs_mod_bg=93
    status_ok_bg=55
    status_ok_fg=15
    time_bg=55
    time_fg=15
    ornament_fg=55
    ;;

  gaming|blue)
    os_bg=33
    os_fg=15
    dir_bg=33
    dir_fg=15
    vcs_clean_bg=33
    vcs_mod_bg=39
    status_ok_bg=33
    status_ok_fg=15
    time_bg=33
    time_fg=15
    ornament_fg=33
    ;;

  cyan|normal)
    os_bg=37
    os_fg=0
    dir_bg=37
    dir_fg=0
    vcs_clean_bg=37
    vcs_mod_bg=44
    status_ok_bg=37
    status_ok_fg=0
    time_bg=37
    time_fg=0
    ornament_fg=37
    ;;

  red)
    os_bg=160
    os_fg=15
    dir_bg=160
    dir_fg=15
    vcs_clean_bg=160
    vcs_mod_bg=202
    status_ok_bg=160
    status_ok_fg=15
    time_bg=160
    time_fg=15
    ornament_fg=160
    ;;

  white)
    os_bg=7
    os_fg=0
    dir_bg=7
    dir_fg=0
    vcs_clean_bg=7
    vcs_mod_bg=8
    status_ok_bg=7
    status_ok_fg=0
    time_bg=7
    time_fg=0
    ornament_fg=7
    ;;

  *)
    exit 0
    ;;
esac

python - "$P10K" "$os_bg" "$os_fg" "$dir_bg" "$dir_fg" "$vcs_clean_bg" "$vcs_mod_bg" "$status_ok_bg" "$status_ok_fg" "$time_bg" "$time_fg" "$ornament_fg" <<'PY'
from pathlib import Path
import re
import sys

p = Path(sys.argv[1])

os_bg, os_fg = sys.argv[2], sys.argv[3]
dir_bg, dir_fg = sys.argv[4], sys.argv[5]
vcs_clean_bg, vcs_mod_bg = sys.argv[6], sys.argv[7]
status_ok_bg, status_ok_fg = sys.argv[8], sys.argv[9]
time_bg, time_fg = sys.argv[10], sys.argv[11]
ornament_fg = sys.argv[12]

s = p.read_text()

def set_line(name, value):
    global s
    pat = rf"typeset -g {re.escape(name)}=.*"
    repl = f"typeset -g {name}={value}"
    s = re.sub(pat, repl, s)

set_line("POWERLEVEL9K_MULTILINE_FIRST_PROMPT_PREFIX", f"'%{ornament_fg}F╭─'")
set_line("POWERLEVEL9K_MULTILINE_NEWLINE_PROMPT_PREFIX", f"'%{ornament_fg}F├─'")
set_line("POWERLEVEL9K_MULTILINE_LAST_PROMPT_PREFIX", f"'%{ornament_fg}F╰─'")
set_line("POWERLEVEL9K_MULTILINE_FIRST_PROMPT_SUFFIX", f"'%{ornament_fg}F─╮'")
set_line("POWERLEVEL9K_MULTILINE_NEWLINE_PROMPT_SUFFIX", f"'%{ornament_fg}F─┤'")
set_line("POWERLEVEL9K_MULTILINE_LAST_PROMPT_SUFFIX", f"'%{ornament_fg}F─╯'")

set_line("POWERLEVEL9K_OS_ICON_BACKGROUND", os_bg)
set_line("POWERLEVEL9K_OS_ICON_FOREGROUND", os_fg)

set_line("POWERLEVEL9K_DIR_BACKGROUND", dir_bg)
set_line("POWERLEVEL9K_DIR_FOREGROUND", dir_fg)
set_line("POWERLEVEL9K_DIR_SHORTENED_FOREGROUND", dir_fg)
set_line("POWERLEVEL9K_DIR_ANCHOR_FOREGROUND", dir_fg)

set_line("POWERLEVEL9K_VCS_CLEAN_BACKGROUND", vcs_clean_bg)
set_line("POWERLEVEL9K_VCS_MODIFIED_BACKGROUND", vcs_mod_bg)
set_line("POWERLEVEL9K_VCS_UNTRACKED_BACKGROUND", vcs_clean_bg)
set_line("POWERLEVEL9K_VCS_CONFLICTED_BACKGROUND", vcs_mod_bg)

set_line("POWERLEVEL9K_STATUS_OK_BACKGROUND", status_ok_bg)
set_line("POWERLEVEL9K_STATUS_OK_FOREGROUND", status_ok_fg)
set_line("POWERLEVEL9K_STATUS_OK_PIPE_BACKGROUND", status_ok_bg)
set_line("POWERLEVEL9K_STATUS_OK_PIPE_FOREGROUND", status_ok_fg)

set_line("POWERLEVEL9K_TIME_BACKGROUND", time_bg)
set_line("POWERLEVEL9K_TIME_FOREGROUND", time_fg)

p.write_text(s)
PY
