#!/bin/bash

# Start dbus service
/etc/init.d/dbus start

# Start Cloudflare Warp Daemon
warp-svc &
sleep 3

# Check if a WARP token is provided
if [ -z "$WARP_CONNECTOR_TOKEN" ]; then
    echo "No WARP_CONNECTOR_TOKEN provided. Exiting..."
    exit 1
fi

# Ensure WARP is connected
echo "Connecting to WARP..."
warp-cli --accept-tos registration delete
warp-cli --accept-tos settings reset
warp-cli --accept-tos connector new "$WARP_CONNECTOR_TOKEN"
warp-cli --accept-tos mode warp+doh
warp-cli --accept-tos connect

# Keep the container running
tail -f /dev/null
