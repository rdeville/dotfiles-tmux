#!/usr/bin/env bash


# Set my default module order
# -----------------------------------------------------------------------------
mode_indicator[order]="icon mode_indicator"
session[order]="icon session"
hostname[order]=""
ip[order]=""
uptime[order]=""
battery[order]=""
disk[order]=""
disk[sub_order]=""
net[order]=""
mem[order]=""
cpu[order]=""
date[order]="icon format"

# Set status background color for darth-vader
status[bg]="${red_500}"

mode_indicator[order]="icon"
session[order]="session"
date[format]="%H:%M"

