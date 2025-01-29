#!/bin/bash

# Copyright 2024 Masaya Suzuki.

set -o errexit
set -o nounset
# set -o pipefail

PROTOCOL="http"
DOMAIN="localhost"
PORT=8000
ENDPOINT="${PROTOCOL}://${DOMAIN}:${PORT}/"

ret=0
until curl -i ${ENDPOINT} | grep "200 OK"
do
  sleep 5
done
