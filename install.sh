#!/usr/bin/env bash

if [[ "$PREFIX" = /data/data/com.termux/files/usr ]]; then
  INSTALL_PREFIX="${INSTALL_PREFIX:-$PREFIX/bin}"
else INSTALL_PREFIX="${INSTALL_PREFIX:-/usr/local/bin}"; fi

install -b wshocket.sh "$INSTALL_PREFIX"
