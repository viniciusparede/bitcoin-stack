FROM debian:bookworm-slim

ARG TARGETARCH
ARG FULCRUM_VERSION
ENV FULCRUM_VERSION=$FULCRUM_VERSION

WORKDIR /opt/fulcrum

RUN apt-get update \
  && apt-get install -qfy ca-certificates bash wget gettext-base

RUN if [ "${TARGETARCH}" = "arm64" ]; then \
  wget https://github.com/cculianu/Fulcrum/releases/download/v${FULCRUM_VERSION}/Fulcrum-${FULCRUM_VERSION}-arm64-linux.tar.gz; \
  else \
  wget https://github.com/cculianu/Fulcrum/releases/download/v${FULCRUM_VERSION}/Fulcrum-${FULCRUM_VERSION}-x86_64-linux.tar.gz; \
  fi \
  && wget https://github.com/cculianu/Fulcrum/releases/download/v${FULCRUM_VERSION}/Fulcrum-${FULCRUM_VERSION}-shasums.txt

RUN if [ "${TARGETARCH}" = "arm64" ]; then \
    grep "Fulcrum-${FULCRUM_VERSION}-arm64-linux.tar.gz" Fulcrum-${FULCRUM_VERSION}-shasums.txt | sha256sum -c; \
  else \
    grep "Fulcrum-${FULCRUM_VERSION}-x86_64-linux.tar.gz" Fulcrum-${FULCRUM_VERSION}-shasums.txt | sha256sum -c; \
  fi

RUN mkdir -p fulcrum /data \
  && if [ "${TARGETARCH}" = "arm64" ]; then \
    tar xzvf Fulcrum-${FULCRUM_VERSION}-arm64-linux.tar.gz --strip-components=1 -C fulcrum; \
  else \
    tar xzvf Fulcrum-${FULCRUM_VERSION}-x86_64-linux.tar.gz --strip-components=1 -C fulcrum; \
  fi \
  && mv fulcrum/Fulcrum fulcrum/FulcrumAdmin /usr/local/bin/

RUN apt-get clean && apt-get autoclean

EXPOSE 50001 50002

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
