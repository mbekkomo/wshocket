#!/usr/bin/env bash

. shocket.sh

shocket_new ws \
    wss://ws.ifelse.io

shocket_connect ws

shocket_send ws \
    "Hi"

shocket_recieve ws

shocket_close ws
