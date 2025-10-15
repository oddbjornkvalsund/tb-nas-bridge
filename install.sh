#!/bin/bash

# Copy network configuration files
cp systemd/*br0* systemd/*tb0* systemd/*usb0* /etc/systemd/network/

# Restart systemd-networkd to apply changes
systemctl restart systemd-networkd