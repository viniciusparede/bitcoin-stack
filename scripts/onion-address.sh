#!/usr/bin/env bash
# Exibe o endereço .onion do nó Bitcoin (gerado automaticamente pelo torcontrol)

set -euo pipefail

CONTAINER="btc_node"

echo "Buscando endereço .onion do nó..."
docker exec "$CONTAINER" bitcoin-cli \
  -datadir=/data \
  -conf=/bitcoin.conf \
  getnetworkinfo | grep -A5 '"reachable": true' | grep onion || \
docker exec "$CONTAINER" bitcoin-cli \
  -datadir=/data \
  -conf=/bitcoin.conf \
  getnetworkinfo | python3 -c "
import sys, json
info = json.load(sys.stdin)
for net in info.get('networks', []):
    if net['name'] == 'onion':
        print(f\"Onion reachable: {net['reachable']}\")
addrs = info.get('localaddresses', [])
for a in addrs:
    if '.onion' in a.get('address',''):
        print(f\"Endereço .onion: {a['address']}:{a['port']}\")
"
