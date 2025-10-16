#!/bin/bash

# Uninstall network configuration files
(cd /etc/systemd/network/ && rm 00-br0-bridge.netdev 00-tb0-interface.link 00-usb0-interface.link 10-br0.network 20-tb0.network 20-usb0.network)

# Restart systemd-networkd to apply changes
systemctl restart systemd-networkd