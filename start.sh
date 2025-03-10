docker build -t warp-client .
docker run -d --name warp-client --cap-add=NET_ADMIN --env WARP_CONNECTOR_TOKEN="TOKEN_HERE" --device /dev/net/tun warp-client
