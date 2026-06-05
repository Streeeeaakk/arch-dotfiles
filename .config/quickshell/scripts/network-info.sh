#!/usr/bin/env bash

connected_line="$(nmcli -t -f DEVICE,TYPE,STATE,CONNECTION dev status 2>/dev/null | awk -F: '$3=="connected" && $2!="loopback" {print; exit}')"

if [ -z "$connected_line" ]; then
    printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\n' "none" "Disconnected" "-" "-" "-" "-" "No network"
    exit 0
fi

IFS=':' read -r dev type state name <<< "$connected_line"

ipaddr="$(ip -4 -o addr show "$dev" 2>/dev/null | awk '{print $4}' | head -n1)"
gateway="$(ip route 2>/dev/null | awk '/default/ {print $3; exit}')"

signal="-"
networks="-"

if [ "$type" = "wifi" ]; then
    signal="$(nmcli -t -f IN-USE,SIGNAL dev wifi list 2>/dev/null | awk -F: '$1=="*" {print $2; exit}')"

    networks="$(nmcli -t -f SSID,SIGNAL dev wifi list --rescan no 2>/dev/null | \
        awk -F: '
            $1 != "" {
                item=$1 " " $2 "%"
                out=(out=="" ? item : out " | " item)
                count++
                if (count==5) {
                    print out
                    exit
                }
            }
            END {
                if (count > 0 && count < 5) print out
            }
        ')"

    [ -z "$networks" ] && networks="No nearby Wi-Fi listed"
fi

[ -z "$name" ] && name="Connected"
[ -z "$ipaddr" ] && ipaddr="-"
[ -z "$gateway" ] && gateway="-"
[ -z "$signal" ] && signal="-"

printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\n' "$type" "$name" "$dev" "$ipaddr" "$gateway" "$signal" "$networks"
