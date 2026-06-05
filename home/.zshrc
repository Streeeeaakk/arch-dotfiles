typeset -g POWERLEVEL9K_INSTANT_PROMPT=off

if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="powerlevel10k/powerlevel10k"

plugins=(git)

source $ZSH/oh-my-zsh.sh


[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh


fastfetch

show_banner(){
  fastfetch
}


clear() {
  command clear
  show_banner
}

cls() {
  command clear
  show_banner
}

[[ -r ~/.p10k.zsh ]] && source ~/.p10k.zsh

export XDG_DATA_DIRS="$HOME/.local/share/flatpak/exports/share:/var/lib/flatpak/exports/share:$XDG_DATA_DIRS"


h() {
  if [[ -z $WAYLAND_DISPLAY && $(tty) == /dev/tty1 ]]; then
    exec start-hyprland
  else
    echo "Already inside Hyprland."
  fi
}

sw() {
    pkill -x waybar 2>/dev/null || true
    sleep 0.2

    waybar -c ~/.config/waybar/demeter-cyan/config.jsonc \
        -s ~/.config/waybar/demeter-cyan/style.css & disown
}

alias cpu75='echo 75 | sudo tee /sys/devices/system/cpu/intel_pstate/max_perf_pct'
alias cpu85='echo 85 | sudo tee /sys/devices/system/cpu/intel_pstate/max_perf_pct'
alias cpu100='echo 100 | sudo tee /sys/devices/system/cpu/intel_pstate/max_perf_pct'
alias cpucheck='cat /sys/devices/system/cpu/intel_pstate/max_perf_pct'

alias marlow='marlow-voice'
alias marlow-ai='askai'
alias aitunnel='ssh -N -R 11434:localhost:11434 scerp'


# Quickshell
alias qson='quickshell >/tmp/quickshell.log 2>&1 &'
alias qsoff='pkill quickshell'
alias qsrestart='pkill quickshell; sleep 0.3; quickshell >/tmp/quickshell.log 2>&1 &'
alias qslog='tail -f /tmp/quickshell.log'
alias qscfg='nano ~/.config/quickshell/shell.qml'

# Quickshell theme
alias qstheme='~/.config/quickshell/scripts/qs-theme.sh'
alias qscyan='~/.config/quickshell/scripts/qs-theme.sh cyan'
alias qsgaming='~/.config/quickshell/scripts/qs-theme.sh gaming'
alias qstoggle='~/.config/quickshell/scripts/qs-theme.sh toggle'
