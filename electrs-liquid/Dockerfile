# ── Stage 1: compilação ──────────────────────────────────────────────────────
FROM rust:bookworm AS builder

RUN apt-get update \
  && apt-get install -qfy clang cmake librocksdb-dev

WORKDIR /build

RUN git clone --depth 1 https://github.com/blockstream/electrs .

RUN cargo build --release --bin electrs --features liquid

# ── Stage 2: imagem final ─────────────────────────────────────────────────────
FROM debian:bookworm-slim

RUN apt-get update \
  && apt-get install -qfy librocksdb-dev \
  && apt-get clean && apt-get autoclean

COPY --from=builder /build/target/release/electrs /usr/local/bin/electrs

EXPOSE 60001

CMD ["electrs"]
