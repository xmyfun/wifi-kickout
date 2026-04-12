[English](README.md) | 简体中文

Copyright (c) 2026 XMyFun

# Introduction to wifi-kickout

The shell script for OpenWrt kicks out the wifi client whose signal is too weak signal by comparing it to a threshold.
It can be periodically triggered by crontab or by a loop with a `sleep` command, thus improves roaming performance.

The shell script works on original OpenWrt (ash shell) with no additional packages, it is also compatible with the bash shell.
This repository was inspired by [nikito7/kickout-wifi](https://github.com/nikito7/kickout-wifi), thanks for his/her original work :)

I modified some of the kickout rules to meet my own requirements and thus opened a new repository to accept issues for my version.

# Parameters

Before using it, you are suggested to set the 4 parameters according to your own preference.
**thr**=-75 is the threshold (dBm), always negative!

**mode** can be set to either "**white**" or "**black**" (always minuscule):
 - in "**black**list" mode, **only** the clients in the blacklist can be kicked out;
 - in "**white**list" mode, the script kicks out **all** the clients **except** those in the whitelist.
There are thus a **blacklist** and a **whitelist**, attention that the type is string other than array, a comma is used to seprate the different mac addresses.
By default, the "**white**list" mode is selected, and with an empty whitelist, any associated client might be kicked out by the router if its signal is too weak (< **thr**).

**hidden functions** there are commented-out codes in the sh file to offer additional functions, if you can not understand them, just leave those lines commented-out.

# Installation

First, copy the script file kickout.sh to your router (e.g., using scp), in my case the location is /usr/kickout.sh.

Then, I recommend triggering the script periodically by crontab, whose highest frequency is 1 run per minute. To do this, add the following line to your /etc/crontabs/root file:

`*/1 * * * * /bin/sh /usr/kickout.sh`

Otherwise, you may prefer a higher frequency to run the script by using the "sleep" command in the kickout.sh and then call itself again. Another way is to use a loop *while *true* - do - done* with the "sleep" command in the end of the loop.

The log file is located at `/tmp/wifi-kickout.log`. Some actions are also recorded in the system logger `/var/log/message`.

# Future improvement

Use a array-like structure to set different thresholds for different wlan devices in the router. Since ash does not support list, string manipulation seems necessary.

# Issues

Issues are always welcome, please use the [issues](issues) page. 