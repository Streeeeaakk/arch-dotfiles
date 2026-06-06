#!/usr/bin/env bash
set -euo pipefail

theme="${1:-purple}"
P10K="$HOME/.p10k.zsh"

[ -f "$P10K" ] || exit 0

case "$theme" in
  green)
    os_bg=40
    os_fg=0
    dir_bg=40
    dir_fg=0
    vcs_clean_bg=40
    vcs_mod_bg=82
    status_ok_bg=0
    status_ok_fg=40
    time_bg=40
    time_fg=0
    ornament_fg=40
    ;;

  purple|mauve)
    os_bg=5
    os_fg=7
    dir_bg=5
    dir_fg=7
    vcs_clean_bg=5
    vcs_mod_bg=3
    status_ok_bg=0
    status_ok_fg=5
    time_bg=5
    time_fg=7
    ornament_fg=5
    ;;

  gaming|blue)
    os_bg=4
    os_fg=7
    dir_bg=4
    dir_fg=7
    vcs_clean_bg=4
    vcs_mod_bg=3
    status_ok_bg=0
    status_ok_fg=4
    time_bg=4
    time_fg=7
    ornament_fg=4
    ;;

  cyan|normal)
    os_bg=6
    os_fg=0
    dir_bg=6
    dir_fg=0
    vcs_clean_bg=6
    vcs_mod_bg=3
    status_ok_bg=0
    status_ok_fg=6
    time_bg=6
    time_fg=0
    ornament_fg=6
    ;;

  red)
    os_bg=160
    os_fg=15
    dir_bg=160
    dir_fg=15
    vcs_clean_bg=160
    vcs_mod_bg=202
    status_ok_bg=0
    status_ok_fg=160
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
    vcs_mod_bg=3
    status_ok_bg=0
    status_ok_fg=7
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

# Frame / prompt ornaments
set_line("POWERLEVEL9K_MULTILINE_FIRST_PROMPT_PREFIX", f"'%{ornament_fg}F╭─'")
set_line("POWERLEVEL9K_MULTILINE_NEWLINE_PROMPT_PREFIX", f"'%{ornament_fg}F├─'")
set_line("POWERLEVEL9K_MULTILINE_LAST_PROMPT_PREFIX", f"'%{ornament_fg}F╰─'")
set_line("POWERLEVEL9K_MULTILINE_FIRST_PROMPT_SUFFIX", f"'%{ornament_fg}F─╮'")
set_line("POWERLEVEL9K_MULTILINE_NEWLINE_PROMPT_SUFFIX", f"'%{ornament_fg}F─┤'")
set_line("POWERLEVEL9K_MULTILINE_LAST_PROMPT_SUFFIX", f"'%{ornament_fg}F─╯'")

# Left prompt
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
set_line("POWERLEVEL9K_VCS_LOADING_BACKGROUND", "8")

# Right prompt basics
set_line("POWERLEVEL9K_STATUS_OK_BACKGROUND", status_ok_bg)
set_line("POWERLEVEL9K_STATUS_OK_FOREGROUND", status_ok_fg)
set_line("POWERLEVEL9K_STATUS_OK_PIPE_BACKGROUND", status_ok_bg)
set_line("POWERLEVEL9K_STATUS_OK_PIPE_FOREGROUND", status_ok_fg)

set_line("POWERLEVEL9K_TIME_BACKGROUND", time_bg)
set_line("POWERLEVEL9K_TIME_FOREGROUND", time_fg)

p.write_text(s)
PY

# Reload all visible zsh prompts if possible.
# Current shell still needs: source ~/.p10k.zsh
