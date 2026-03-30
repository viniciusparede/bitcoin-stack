FROM debian:bookworm-slim

RUN apt-get update \
  && apt-get install -y --no-install-recommends tor \
  && rm -rf /var/lib/apt/lists/* \
  && mkdir -p /var/lib/tor /var/run/tor \
  && chown -R debian-tor:debian-tor /var/lib/tor /var/run/tor \
  && chmod 700 /var/lib/tor /var/run/tor

COPY torrc /etc/tor/torrc
RUN chown root:debian-tor /etc/tor/torrc && chmod 640 /etc/tor/torrc

EXPOSE 9050 9051

USER debian-tor
CMD ["tor", "-f", "/etc/tor/torrc"]
