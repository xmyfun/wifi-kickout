#!/bin/sh

# Copyright (c) 2026 XMyFun
# MIT License - See README for details
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files, to deal in the Software without
# restriction, including without limitation the rights to use, copy, modify, merge,
# publish, distribute, sublicense, and/or sell copies of the Software.
#

### kickout.sh ###

# threshold (dBm), always negative
thr=-75

## mode (string) = "white" or "black", always minuscule !
# black: only the clients in the blacklist can be kicked out.
# white: kick out all the clients except those in the whitelist.
mode="white"

# In "black" mode, only the clients in the blacklist can be kicked out.
blacklist="00:00:00:00:00:00 00:00:00:00:00:00"

# In "white" mode, the clients in the whitelist will not be kicked out.
whitelist="00:00:00:00:00:00 00:00:00:00:00:00"

# Specified logfile
logfile="/tmp/kickout-wifi.log"
datetime=`date +%Y-%m-%d_%H:%M:%S`
if [[ ! -f "$logfile" ]]; then
	echo "creating kickout-wifi logfile: $logfile"
	echo "$datetime: kickout-wifi log file created." > $logfile
fi

# Enhanced signal strength detection for multi-platform compatibility
get_signal_strength() {
    local mac=$1
    local wlan=$2

    # Suppress stderr to avoid error messages from iw command
    local output=$(iw $wlan station get $mac 2>/dev/null)

    # Method 1: Try "signal avg" pattern (most common)
    # Store result and try field 4 as fallback
    local rssi=$(echo "$output" | grep -E "signal.*avg" | tail -1 | awk '{print $3}')
    if [ -z "$rssi" ] || [ "$rssi" = "-1" ]; then
        rssi=$(echo "$output" | grep -E "signal.*avg" | tail -1 | awk '{print $4}')
    fi

    # Method 2: Try "signal" with dBm pattern if method 1 fails
    if [ -z "$rssi" ] || [ "$rssi" = "-1" ]; then
        rssi=$(echo "$output" | grep -E "signal.*dBm" | tail -1 | awk '{print $3}')
    fi

    # Method 3: Extract the last numeric value before "dBm"
    # More precise pattern to avoid false matches
    if [ -z "$rssi" ] || [ "$rssi" = "-1" ]; then
        rssi=$(echo "$output" | grep -E "(signal|avg).*[0-9-][0-9]* dBm" | grep -o "[0-9-][0-9]* dBm" | tail -1 | awk '{print $1}')
    fi

    # Validate the result
    if [ -z "$rssi" ] || [ "$rssi" = "-1" ]; then
        echo "unknown"
    else
        echo "$rssi"
    fi
}

# function deauth
function deauth ()
{
	mac=$1
	wlan=$2
	rssi=$3
	echo "kicking $mac with $rssi dBm (thr=$thr) at $wlan" | logger
	echo "$datetime: kicking $mac with $rssi dBm (thr=$thr) at $wlan" >> $logfile
	ubus call hostapd.$wlan del_client \
	"{'addr':'$mac', 'reason':5, 'deauth':true, 'ban_time':3000}"
# "ban_time" prohibits the client to reassociate for the given amount of milliseconds.
}

# wlanlist for multiple wlans (e.g., 5GHz/2.4GHz)
wlanlist=$(ifconfig | grep wlan | grep -v sta | awk '{ print $1 }')

# loop for each wlan
for wlan in $wlanlist
do
	maclist=""; maclist=$(iw $wlan station dump | grep Station | awk '{ print $2 }')
	# loop for each associated client (station)
	for mac in $maclist
	do
		echo "$blacklist" | grep -q -F "$mac"
		inBlack=$?	#0 for in Blacklist!
		echo "$whitelist" | grep -q -F "$mac"
		inWhite=$?	#0 for in Whitelist!

		if [ $mode = "black" -a $inBlack -eq 0 ] || [ $mode = "white" -a $inWhite -ne 0 ]
		then
			rssi=$(get_signal_strength $mac $wlan)

			# Validate rssi is a valid number before comparison
			if [ "$rssi" != "unknown" ] && printf '%d' "$rssi" > /dev/null 2>&1 && [ $rssi -lt $thr ]
			then
				deauth $mac $wlan $rssi
			else
				echo "$datetime: Skipped $mac - invalid signal: $rssi" >> $logfile
			fi
		fi
	done
done


## Auto-loop execution mode (uncomment for continuous operation)
# sleep 10s and call itself.
# sleep 10; /bin/sh $0 &

### END of kickout.sh