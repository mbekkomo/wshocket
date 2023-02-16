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

check_argc() {
    local argc="$1"
    local min="$2" max="$3"
    local fn="$4"

    if (( argc < min )); then
        >&2 printf "%s: LESS ARGS, ATLEAST %d OF THEM" "$fn" "$min"
        return 1
    elif (( argc > max )); then
        >&2 printf "%s: MORE ARGS, MAXIMUM %d OF THEM" "$fn" "$min"
        return 1
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

shocket_new() {
    if ! check_argc "$#" 2 3 shocket_new; then
        return 1
    fi

    local uri varname errname
    if (( $# == 2 )); then
        varname="$1"
        uri="$2"

        local shonew_err
        declare -gA "$varname"; local -n shonew_var="$varname"
    else
        varname="$1"
        errname="$2"
        uri="$3"


        declare -gA "$varname"
        declare -g "$errname"
        local -n shonew_var="$varname" shonew_err="$errname"
    fi
        

    local pipe="/tmp/shocket-$$"

    if ! is_valid_ws "$uri"; then
        shonew_err="invalid uri"
        return 1
    fi

    shonew_var[_uri]="$uri"
    shonew_var[_pipe]="$pipe"
}

shocket_connect() {
    if ! check_argc "$#" 1 2 shocket_connect; then
        return 1
    fi

    local errname
    if (( $# == 1 )); then
        local -n shoconnect_var="$1"
        local shoconnect_err
    else
        local -n shoconnect_var="$1"

        declare -g "$errname"
        local -n shoconnect_err="$errname"
    fi

    if [[ -p "${shoconnect_var[_pipe]}" ]]; then
        shoconnect_err="cannot create FIFO, '${shoconnect_var[_pipe]}' exist"
        return 1
    fi

    mkfifo "${shoconnect_var[_pipe]}"

    local port="$$"

#    ws_listen "${_var[_pipe_send]}" "${_var[_pipe]}" "${_var[_uri]}" &
    websocat -t -u  tcp-l:127.0.0.1:"$port" reuse-raw:- | websocat "${shoconnect_var[_uri]}" > "${shoconnect_var[_pipe]}" &

    shoconnect_var[_websocat_pid]="$!"
    shoconnect_var[_port]="$port"
}

shocket_send() {
    if ! check_argc "$#" 2 3 shocket_send; then
        return 1
    fi

    local errname msg
    if (( $# == 2 )); then
        local -n shosend_var="$1"
        msg="$2"

        local shosend_err
    else
        local -n shosend_var="$1"

    fi

    nc 127.0.0.1 "${shosend_var[_port]}" <<< "$msg"
}

shocket_recieve() {
    if ! check_argc "$#" 1 2 shocket_recieve; then
        return 1
    fi

    local errname
    if (( $# == 1 )); then
        local -n shorecieve_var="$1"
        
        local shorecieve_err
    else
        local -n shorecieve_var="$1"
        errname="$2"

        declare -g "$errname"
        local -n shorecieve_err="$errname"
    fi

    read -r recv_msg < "${shorecieve_var[_pipe]}"
    echo "$recv_msg"
}

shocket_close() {
    if ! check_argc "$#" 1 2 shocket_close; then
        return 1
    fi

    local errname
    if (( $# == 1 )); then
        local -n shoclose_var="$1"

        local shoclose_err
    else
        local -n shoclose_var="$1"
        errname="$2"

        declare -g "$errname"
        local -n shoclose_err="$errname"
    fi

    kill "${shoclose_var[_websocat_pid]}"

    rm -f /tmp/shocket-*
}

SHOCKET_VERSION="0.1.0"

export -f shocket_new
export -f shocket_connect
export -f shocket_recieve
export -f shocket_send
export -f shocket_close
