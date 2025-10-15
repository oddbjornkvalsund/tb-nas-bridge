#!/bin/bash

# Disable usb0 from being a bridge slave of br0
ip link set usb0 nomaster

# Get an IP address via DHCP
dhclient usb0