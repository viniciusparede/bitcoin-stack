#!/usr/bin/env bash
set -euo pipefail

# Gera o hash da senha e cria um torrc completo em local gravável
HASH=$(tor --hash-password "${TOR_CONTROL_PASSWORD}" 2>/dev/null)
cat /etc/tor/torrc > /tmp/torrc
echo "HashedControlPassword ${HASH}" >> /tmp/torrc

exec tor -f /tmp/torrc
