#!/bin/bash
# This script is useful to test the bridge configuration without dealing with systemd-networkd
# Remember to change the MAC addresses below to match your interfaces
IF1=enx00e04a6a9bbb
IF2=thunderbolt0

ip link set $IF1 down
ip addr flush dev $IF1
ip link set $IF2 down
ip addr flush dev $IF2
ip link set br0 down
ip addr flush dev br0

ip link add name br0 type bridge

# Here you can experiment with various bridge settings to see what works best for you
# In my experience they didn't make much difference
ip link set br0 type bridge stp_state 0
ip link set br0 type bridge forward_delay 0
ip link set br0 type bridge mcast_snooping 1

# Here you can experiment with various offloading settings to see what works best for you
# Note that the thunderbolt-net driver doesn't support any offloading options
OFFLOAD=on
for iface in $IF1 $IF2 br0; do
    ethtool -K $iface tso $OFFLOAD 2>/dev/null || true
    ethtool -K $iface gso $OFFLOAD 2>/dev/null || true
    ethtool -K $iface sg $OFFLOAD 2>/dev/null || true
    ethtool -K $iface gro $OFFLOAD 2>/dev/null || true
    ethtool -K $iface lro $OFFLOAD 2>/dev/null || true
    ethtool -K $iface rx $OFFLOAD 2>/dev/null || true
    ethtool -K $iface tx $OFFLOAD 2>/dev/null || true
    # Increase ring buffer sizes if supported
    ethtool -G $iface rx 4096 tx 4096 2>/dev/null || true
done

# On macOS:
# sysctl -w net.inet.tcp.tso=0

ip link set $IF1 master br0
ip link set $IF2 master br0

# These must be on for DHCP to work
ip link set $IF1 promisc on
ip link set $IF2 promisc on

sleep 5
ip link set $IF1 up
ip link set $IF2 up
ip link set br0 up

dhclient br0

sleep 5

# This is important to get full bandwidth and avoid 100% CPU usage on one side
# It must be set *after* bringing the link up for some reason
MTU=9000
ip link set $IF2 mtu $MTU
ip link set br0 mtu $MTU

brctl show
ip addr show br0
