#!/usr/bin/env bash

. shocket.sh

shocket_new s ws err
echo "${ws[_pipe]}"
echo "$err"
