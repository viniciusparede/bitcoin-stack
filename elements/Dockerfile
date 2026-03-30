FROM debian:bookworm-slim

ARG TARGETARCH
ARG ELEMENTS_VERSION
ENV ELEMENTS_VERSION=$ELEMENTS_VERSION

WORKDIR /opt/elements

RUN apt-get update \
  && apt-get install -qfy ca-certificates bash wget

RUN if [ "${TARGETARCH}" = "arm64" ]; then \
  wget https://github.com/ElementsProject/elements/releases/download/elements-${ELEMENTS_VERSION}/elements-${ELEMENTS_VERSION}-aarch64-linux-gnu.tar.gz; \
  else \
  wget https://github.com/ElementsProject/elements/releases/download/elements-${ELEMENTS_VERSION}/elements-${ELEMENTS_VERSION}-x86_64-linux-gnu.tar.gz; \
  fi \
  && wget https://github.com/ElementsProject/elements/releases/download/elements-${ELEMENTS_VERSION}/SHA256SUMS

RUN if [ "${TARGETARCH}" = "arm64" ]; then \
    grep "elements-${ELEMENTS_VERSION}-aarch64-linux-gnu.tar.gz" SHA256SUMS | sha256sum -c; \
  else \
    grep "elements-${ELEMENTS_VERSION}-x86_64-linux-gnu.tar.gz" SHA256SUMS | sha256sum -c; \
  fi

RUN mkdir -p elements /data \
  && if [ "${TARGETARCH}" = "arm64" ]; then \
    tar xzvf elements-${ELEMENTS_VERSION}-aarch64-linux-gnu.tar.gz --strip-components=1 -C elements; \
  else \
    tar xzvf elements-${ELEMENTS_VERSION}-x86_64-linux-gnu.tar.gz --strip-components=1 -C elements; \
  fi \
  && mv elements/bin/* /usr/local/bin/ \
  && mv elements/lib/* /usr/local/lib/ || true \
  && mv elements/include/* /usr/local/include/ || true \
  && mv elements/share/* /usr/local/share/ || true

RUN apt-get clean && apt-get autoclean

EXPOSE 7041 7042

CMD ["elementsd", "-datadir=/data"]
