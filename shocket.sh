#!/usr/bin/env bash
#       _                _        _ 
#   ___| |__   ___   ___| | _____| |_
#  / __| '_ \ / _ \ / __| |/ / _ \ __|
#  \__ \ | | | (_) | (__|   <  __/ |_  
#  |___/_| |_|\___/ \___|_|\_\___|\__|
#  ---------------------------------------------
#        A Bash module for interacting WebSocket
#        https://github.com/UrNightmaree/shocket
#
#  MIT License
#
#  Copyright (c) 2023 kooshie
#
#  Permission is hereby granted, free of charge, to any person obtaining a copy
#  of this software and associated documentation files (the "Software"), to deal
#  in the Software without restriction, including without limitation the rights
#  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
#  copies of the Software, and to permit persons to whom the Software is
#  furnished to do so, subject to the following conditions:
#
#  The above copyright notice and this permission notice shall be included in all
#  copies or substantial portions of the Software.
#
#  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
#  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
#  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
#  SOFTWARE.

# shellcheck disable=SC2059,SC2155,SC2034,SC2154

# Prevent running it as a CLI tool instead
# running it as `. shocket.sh` or `source shocket.sh`
if [[ "${BASH_SOURCE[0]}" = "$0" ]]; then
    printf "SOURCE shocket.sh (\`. shocket.sh\` or \`source shoket.sh\`) INSTEAD OF RUNNING IT!\n"
    exit 1
fi

check_cmd() {
    if ! command -v "$1" >/dev/null; then
        printf "SHOCKET DEPENDS ON \`%s\` COMMAND!\n" "$1"
        exit 1
    fi
}

check_cmd websocat
check_cmd nc

# END OF CHECKS #

is_valid_ws() {
    local uri="$1"
    grep '^ws://' <<< "$uri" >/dev/null || grep '^wss://' <<< "$uri" >/dev/null
    return "$?"
}

# END OF FUNC DEFS #

SHOCKET_VERSION="dev"

shocket_new() {
    local varname="${1:?${FUNCNAME[0]}: specify a variable name}"
    local uri="${2:?${FUNCNAME[0]}: specify a websocket uri}"

    declare -gA "$varname"; local -n shonew_var="$varname"
    
    if (( $# > 2 )); then
        declare -g "$3"; local -n shonew_err="$3"
    else local shonew_err; fi

    local pipe="/tmp/shocket-$$"

    if ! is_valid_ws "$uri"; then
        shonew_err="invalid uri"
        return 1
    fi

    shonew_var[_uri]="$uri"
    shonew_var[_pipe]="$pipe"
}

shocket_connect() {
    local -n shoconnect_var="${1:?${FUNCNAME[0]}: specify a shocket variable}"
    
    if (( $# > 1 )); then
        declare -g "$2"; local -n shoconnect_err="$2"
    else local shoconnect_err; fi

    if [[ -p "${shoconnect_var[_pipe]}" ]]; then
        shoconnect_err="cannot create named pipe, '${shoconnect_var[_pipe]}' exist"
        return 1
    fi

    mkfifo "${shoconnect_var[_pipe]}"

    local port="$$"

    websocat -t -u  tcp-l:127.0.0.1:"$port" reuse-raw:- | websocat "${shoconnect_var[_uri]}" > "${shoconnect_var[_pipe]}" &

    shoconnect_var[_websocat_pid]="$!"
    shoconnect_var[_port]="$port"
}

shocket_send() {
    local -n shosend_var="${1:?${FUNCNAME[0]}: specify a shocket variable}"
    local msg="${2:? specify a message}"

    if (( $# > 2 )); then
        declare -g "$3"; local -n shosend_err="$3"
    else local shosend_err; fi

    nc 127.0.0.1 "${shosend_var[_port]}" <<< "$msg"
}

shocket_recieve() {
    local -n shorecieve_var="${1:?${FUNCNAME[0]}: specify a shocket variable}"
    
    if (( $# > 1 )); then
        declare -g "$2"; local -n shorecieve_err="$2"
    else local shorecieve_err; fi

    read -r recv_msg < "${shorecieve_var[_pipe]}"
    echo "$recv_msg"
}

shocket_close() {
    local -n shoclose_var="${1:?${FUNCNAME[0]}: specify a shocket variable}"
    
    if (( $# > 1 )); then
        declare -g "$2"; local -n shoclose_err="$2"
    else local shoclose_err; fi

    kill "${shoclose_var[_websocat_pid]}"

    rm -f /tmp/shocket-*
}

# export funcs
export -f shocket_new
export -f shocket_connect
export -f shocket_recieve
export -f shocket_send
export -f shocket_close

# export vars
export SHOCKET_VERSION
