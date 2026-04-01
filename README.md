# bitcoin-stack

A self-hosted Bitcoin full node stack running entirely over Tor, with Electrum indexing, Liquid Network support, and wallet monitoring — all orchestrated via Docker Compose.

Based on: [Blockstream/bitcoin-images](https://github.com/Blockstream/bitcoin-images)

---

## Services

| Container | Image | Purpose | Port |
|-----------|-------|---------|------|
| `btc_tor` | custom | Tor SOCKS5 proxy + v3 hidden service | 9050, 9051 |
| `btc_node` | custom | Bitcoin Core full node (mainnet + Tor) | 8332 (RPC), 8333 (P2P) |
| `fulcrum` | custom | Fulcrum Electrum server for Bitcoin | 50001 |
| `elements_node` | custom | Elements / Liquid Network full node | 7041 (RPC), 7042 (P2P) |
| `electrs_liquid` | custom | electrs Electrum server for Liquid | 60001 |
| `canary_backend` | custom | Canary wallet monitor — Rust API | 8000 |
| `canary_frontend` | custom | Canary wallet monitor — Next.js UI | 3001 |

---

## Storage layout

This stack is designed for a **two-disk setup**:

```
HDD  (/mnt/hd)                     ← large/slow disk
└── bitcoin/                        Bitcoin Core blockchain (~700 GB)

NVMe (/home/<user>)                 ← fast disk
├── fulcrum-data/                   Fulcrum index (~100 GB)
├── elements-data/                  Liquid blockchain (~10 GB)
├── electrs-liquid-data/            electrs Liquid index (~5 GB)
└── canary-data/                    Canary app data (< 1 GB)
```

All paths are configured via `.env`. See `.env.example` for details.

---

## Requirements

- Docker >= 24
- Docker Compose >= v2
- HDD mounted at `/mnt/hd` with Bitcoin blockchain data

---

## Getting started

```bash
# 1. Clone the repo
git clone https://github.com/viniciusparede/bitcoin-stack
cd bitcoin-stack

# 2. Configure environment
cp .env.example .env
# Edit .env with your paths and credentials

# 3. Copy and configure bitcoin.conf
cp bitcoin/bitcoin.conf.example bitcoin/bitcoin.conf
# Edit bitcoin/bitcoin.conf as needed

# 4. Create data directories on NVMe
mkdir -p ~/fulcrum-data ~/elements-data ~/electrs-liquid-data ~/canary-data

# 5. Build images
docker compose build

# 6. Start the stack
docker compose up -d
```

Tor starts first. Bitcoin Core waits for the Tor proxy healthcheck before starting.

---

## Configuration

### bitcoin.conf

`bitcoin/bitcoin.conf` is **gitignored** (it may contain personal data such as trusted node addresses).
Use `bitcoin/bitcoin.conf.example` as a starting point.

### Credentials

All credentials live in `.env` (gitignored). Never commit `.env`.

RPC passwords are passed to containers via Docker Compose `command:` arguments —
no secrets are baked into images or config files tracked by git.

---

## Useful commands

```bash
# View logs
docker compose logs -f
docker compose logs -f bitcoind

# Container status
docker compose ps

# Stop the stack (containers will restart on next boot)
docker compose stop

# Stop and remove containers
docker compose down
```

### Bitcoin CLI

```bash
# Node info
docker exec btc_node bitcoin-cli -datadir=/data getnetworkinfo

# Connected peers
docker exec btc_node bitcoin-cli -datadir=/data getpeerinfo

# Blockchain status
docker exec btc_node bitcoin-cli -datadir=/data getblockchaininfo

# Mempool
docker exec btc_node bitcoin-cli -datadir=/data getmempoolinfo
```

### Elements CLI

```bash
# Liquid blockchain status
docker exec elements_node elements-cli -datadir=/data getblockchaininfo

# Liquid network info
docker exec elements_node elements-cli -datadir=/data getnetworkinfo
```

### Fulcrum admin

```bash
# Fulcrum sync status
docker exec fulcrum FulcrumAdmin -p 8000 status
```

---

## Onion address

Bitcoin Core automatically creates a v3 hidden service via `torcontrol`.
The private key persists at `/data/onion_v3_private_key` (on the HDD).

```bash
# Display the node's .onion address
./scripts/onion-address.sh
```

To add a trusted peer at runtime (no restart required):

```bash
docker exec btc_node bitcoin-cli -datadir=/data \
  addnode "<address>.onion:8333" add
```

---

## Ports

All ports are bound to `127.0.0.1` (localhost only) except Bitcoin P2P (8333) and Liquid P2P (7042), which accept inbound connections.

| Service | Port | Exposure |
|---------|------|----------|
| Bitcoin RPC | 8332 | localhost only |
| Bitcoin P2P | 8333 | public |
| Fulcrum (Bitcoin Electrum) | 50001 | localhost only |
| Liquid RPC | 7041 | localhost only |
| Liquid P2P | 7042 | public |
| electrs Liquid Electrum | 60001 | localhost only |
| Canary API | 8000 | localhost only |
| Canary UI | 3001 | localhost only |

---

## Canary wallet monitor

Canary watches Bitcoin wallets (read-only) and sends alerts for transactions and balance changes.

- Open `http://localhost:3001` in your browser
- Supports Sparrow, BlueWallet, Ledger, Trezor (via xpub / descriptors)
- Notifications via [ntfy](https://ntfy.sh)
- Connects to your local Fulcrum instance on port 50001

---

## Auto-start on boot

All services use `restart: unless-stopped`. Docker is enabled at system startup, so the entire stack restarts automatically after a reboot or power loss.

To stop a service permanently (so it does not restart on boot):

```bash
docker compose stop <service>
# followed by:
docker compose rm <service>
```

---

## License

MIT
