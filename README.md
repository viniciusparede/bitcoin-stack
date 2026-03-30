# Bitcoin Node + Tor — Stack Docker

Nó completo do Bitcoin Core roteando todas as conexões pela rede Tor, com hidden service v3 automático.

Baseado em: [Blockstream/bitcoin-images](https://github.com/Blockstream/bitcoin-images)

---

## Estrutura

```
bitcoin-stack/
├── docker-compose.yml
├── .env                        # versão do Bitcoin Core e credenciais RPC
├── bitcoin/
│   ├── Dockerfile              # baixa e verifica assinatura GPG do Bitcoin Core
│   └── bitcoin.conf            # configuração com Tor habilitado
├── tor/
│   ├── Dockerfile
│   └── torrc                   # SOCKS5 :9050 + control port :9051
└── scripts/
    └── onion-address.sh        # exibe o endereço .onion do nó
```

---

## Pré-requisitos

- Docker >= 24
- Docker Compose >= v2
- HD externo montado em `/media/vinicius/1943edf9-e864-4ba8-af98-55894eff1418` (blockchain já sincronizada)

---

## Como subir

```bash
cd /home/vinicius/bitcoin-stack

# 1. Build das imagens (baixa o Bitcoin Core 28.1 e verifica a assinatura GPG)
docker compose build

# 2. Sobe a stack em background
docker compose up -d
```

O Tor sobe primeiro. O Bitcoin Core só inicia após o proxy Tor estar pronto (healthcheck).

---

## Comandos úteis

```bash
# Ver logs em tempo real
docker compose logs -f

# Ver logs de um serviço específico
docker compose logs -f bitcoind
docker compose logs -f tor

# Status dos containers
docker compose ps

# Parar a stack
docker compose down

# Parar preservando os volumes
docker compose stop
```

---

## Bitcoin CLI

```bash
# Informações gerais do nó
docker exec btc_node bitcoin-cli -datadir=/data -conf=/bitcoin.conf getnetworkinfo

# Peers conectados
docker exec btc_node bitcoin-cli -datadir=/data -conf=/bitcoin.conf getpeerinfo

# Status da blockchain
docker exec btc_node bitcoin-cli -datadir=/data -conf=/bitcoin.conf getblockchaininfo

# Mempool
docker exec btc_node bitcoin-cli -datadir=/data -conf=/bitcoin.conf getmempoolinfo
```

---

## Endereço .onion

O Bitcoin Core cria automaticamente um hidden service v3 via `torcontrol`.
A chave privada do endereço persiste em `/data/onion_v3_private_key` (no HD externo).

```bash
# Exibir o endereço .onion do nó
./scripts/onion-address.sh

# Ou diretamente via bitcoin-cli
docker exec btc_node bitcoin-cli -datadir=/data -conf=/bitcoin.conf getnetworkinfo \
  | python3 -c "import sys,json; [print(a['address']) for a in json.load(sys.stdin)['localaddresses'] if '.onion' in a['address']]"
```

---

## Nós de confiança

Configurado em `bitcoin/bitcoin.conf` via `addnode`:

```
# addnode=seunodo.onion:8333
```

Para adicionar um nó em tempo real (sem reiniciar):

```bash
docker exec btc_node bitcoin-cli -datadir=/data -conf=/bitcoin.conf \
  addnode "<endereço>.onion:8333" add
```

---

## Modo somente-Tor (opcional)

Para conectar **apenas** a peers .onion (mais privado, menos peers), edite `bitcoin/bitcoin.conf` e descomente:

```
onlynet=onion
```

Depois reinicie o bitcoind:

```bash
docker compose restart bitcoind
```

---

## Monitorar espaço em disco

O HD está com ~94% de uso. Monitore regularmente:

```bash
df -h /media/vinicius/1943edf9-e864-4ba8-af98-55894eff1418
```

---

## RPC

| Campo    | Valor                                      |
|----------|--------------------------------------------|
| Host     | `127.0.0.1:8332`                           |
| Usuário  | `bitcoin`                                  |
| Senha    | ver `.env` → `BITCOIN_RPC_PASSWORD`        |

> A porta RPC **não** é exposta na rede — apenas em `localhost`.
