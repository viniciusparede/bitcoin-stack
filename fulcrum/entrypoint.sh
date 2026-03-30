#!/usr/bin/env bash
set -euo pipefail

# Substitui variáveis de ambiente no template e gera o conf final
envsubst < /fulcrum.conf.template > /data/fulcrum.conf

exec Fulcrum /data/fulcrum.conf
