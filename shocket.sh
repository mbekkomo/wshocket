#!/usr/bin/env bash

#      _                _        _ 
#  ___| |__   ___   ___| | _____| |_
# / __| '_ \ / _ \ / __| |/ / _ \ __|
# \__ \ | | | (_) | (__|   <  __/ |_  
# |___/_| |_|\___/ \___|_|\_\___|\__|
# ---------------------------------------------
#       A Bash module for interacting WebSocket
#       https://github.com/UrNightmaree/shocket
#
# MIT License
#
# Copyright (c) 2023 kooshie
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

# shellcheck disable=SC2059,SC2155,SC2034

# Replace default echo
print() { printf "$*"; }
println() { print "$*\n"; }

# Prevent running it as a CLI tool instead
# running it as `. shocket.sh` or `source shocket.sh`
if [[ "${BASH_SOURCE[0]}" = "$0" ]]; then
    println "\x1b[31;1mSOURCE shocket.sh (\`. shocket.sh\` or \`source shoket.sh\`) INSTEAD OF RUNNING IT!\x1b[0m\n"
    exit 1
fi

# Check if websocat exist
if ! command -v websocat >/dev/null; then
    println "\x1b[31;1mNEED websocat INSTALLED!\x1b[0m\n"
    exit 1
fi

shocket_new() {
    local uri="$1"
    local varname="$2"
    local errname="${3:-_ERR_}"

    declare -gA "$varname"; local -n _var="$varname"
    declare -g "$errname"; local -n _err="$errname"

    local pipe="/tmp/shocket-$(shuf -i 1000-9999 -n 1)"

    if [[ -p "$pipe" ]]; then
        _err="cannot create FIFO, \`$pipe\` exist"
        return 1
    fi

    mkfifo "$pipe"

    _var[_uri]="$uri"
    _var[_pipe]="$pipe"
}

export -f shocket_new
