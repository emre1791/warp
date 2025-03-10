#!/bin/bash

# Start dbus service
/etc/init.d/dbus start

# Start Cloudflare Warp Daemon
warp-svc &
sleep 3

# Read WARP token from Swarm secret if available, otherwise use environment variable
if [ -f "/run/secrets/warp-token" ]; then
    WARP_CONNECTOR_TOKEN=$(cat /run/secrets/warp-token)
elif [ -z "$WARP_CONNECTOR_TOKEN" ]; then
    echo "Error: No WARP_CONNECTOR_TOKEN provided via secret or environment variable. Exiting..."
    exit 1
fi

# Ensure WARP is connected
echo "Connecting to WARP..."
warp-cli --accept-tos registration delete
warp-cli --accept-tos settings reset
warp-cli --accept-tos connector new "$WARP_CONNECTOR_TOKEN"
warp-cli --accept-tos mode proxy
warp-cli --accept-tos connect
sleep 3

# Allow WARP SOCKS5 Proxy to Listen on All Interfaces
echo "Starting SOCKS5 proxy on 0.0.0.0:40000..."
socat TCP-LISTEN:40000,fork,reuseaddr SOCKS4A:127.0.0.1:0.0.0.0:40000,socksport=40000 &

# Keep the container running
tail -f /dev/null
