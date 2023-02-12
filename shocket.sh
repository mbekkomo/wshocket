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

# Replace default echo
print() { printf "$*"; }
println() { print "$*\n"; }

# Prevent running it as a CLI tool instead
# running it as `. shocket.sh` or `source shocket.sh`
if [[ "${BASH_SOURCE[0]}" = "$0" ]]; then
    println "SOURCE shocket.sh (\`. shocket.sh\` or \`source shoket.sh\`) INSTEAD OF RUNNING IT!\n"
    exit 1
fi

check_cmd() {
    if ! command -v "$1" >/dev/null; then
        println "SHOCKET DEPENDS ON \`$1\` COMMAND!\n"
        exit 1
    fi
}

check_cmd websocat
check_cmd reredirect

## END OF CHECKS ##

check_argc() {
    local argc="$1"
    local min="$2" max="$3"
    local fn="$4"

    if (( argc < min )); then
        >&2 println "$4: LESS ARGS, ATLEAST $min OF THEM"
        return 1
    elif (( argc > max )); then
        >&2 println "$4: MORE ARGS, MAXIMUM $max OF THEM"
        return 1
    fi
}

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
    case "$#" in
        2)
            varname="$1"
            errname="_shocket_new_ERR_"
            uri="$2"
            ;;

        3)
            varname="$1"
            errname="$2"
            uri="$3"
            ;;
    esac

    declare -gA "$varname"; local -n _var="$varname"
    declare -g "$errname"; local -n _err="$errname"

    local pipe_send="/tmp/shocket-send-$(shuf -i 1000-9999 -n 1)"
    local pipe_recv="/tmp/shocket-recv-$(shuf -i 1000-9999 -n 1)"

    if ! is_valid_ws "$uri"; then
        _err="invalid uri"
        return 1
    fi

    _var[_uri]="$uri"
    _var[_pipe_send]="$pipe_send"
    _var[_pipe_recv]="$pipe_recv"
}

ws_listen() {
    local pidname="$1"
    local uri="$2"
    local pipe="$3"

    declare -g "$pidname"; local -n _pid="$pidname"

    while true; do
        if read -r txt < "$pipe"; then
            websocat - "$uri" --text <<< "$txt"
            _pid="$!"
        fi
    done
}

shocket_connect() {
    if ! check_argc "$#" 1 2 shocket_connect; then
        return 1
    fi

    local errname
    case "$#" in
            1)
                local -n _var="$1"
                errname="_shocket_connect_ERR_"
                ;;

            2)
                local -n _var="$1"
                errname="$2"
                ;;
    esac

    declare -g "$errname"; local -n _err="$errname"

    if [[ -e "${_var[_pipe_send]}" && -p "${_var[_pipe_send]}" ]]; then
        _err="cannot create FIFO for send, '${_var[_pipe_send]}' exist"
        return 1
    fi

    if [[ -e "${_var[_pipe_recv]}" && -p "${_var[_pipe_recv]}" ]]; then
        _err="cannot create FIFO for recieve, '${_var[_pipe_recv]}' exist"
        return 1
    fi

    mkfifo "${_var[_pipe_send]}"
    mkfifo "${_var[_pipe_recv]}"

    ws_listen pid \
        "${_var[_uri]}" "${_var[_pipe_send]}" &

    _var[_wslisten_pid]="$!"
    _var[_wssocat_pid]="$pid"
}

shocket_send() {
    if ! check_argc "$#" 2 3 shocket_send; then
        return 1
    fi

    local errname msg
    case "$#" in
        2)
            local -n _var="$1"
            errname="_shocket_send_ERR_"
            msg="$2"
            ;;

        3)
            local -n _var="$1"
            errname="$2"
            msg="$3"
            ;;
    esac

    declare -g "$errname"; local -n _err="$errname"

    echo "$msg" > "${_var[_pipe_send]}"
    echo "${_var[_wssocat_pid]}"
    reredirect "${_var[_wssocat_pid]}" -m "${_var[_pipe_recv]}"
}

shocket_recieve() {
    if ! check_argc "$#" 1 2 shocket_recieve; then
        return 1
    fi

    local errname
    case "$#" in
        1)
            local -n _var="$1"
            errname="_shocket_send_ERR_"
            ;;

        2)
            local -n _var="$1"
            errname="$2"
            ;;
    esac

    declare -g "$errname"; local -n _err="$errname"

    read -r recv_msg < "${_var[_pipe_recv]}"
    echo "$recv_msg"
}

shocket_close() {
    if ! check_argc "$#" 1 2 shocket_close; then
        return 1
    fi

    local errname
    case "$#" in
        1)
            local -n _var="$1"
            errname="_shocket_close_ERR_"
            ;;

        2)
            local -n _var="$1"
            errname="$2"
            ;;
    esac

    declare -g "$errname"; local -n _err="$errname"

    kill "${_var[_wssocat_pid]}"
    kill "${_var[_wslisten_pid]}"

    rm -f "${_var[_pipe_send]}" "${_var[_pipe_recv]}"
}

export -f shocket_new
export -f shocket_connect
export -f shocket_recieve
export -f shocket_send
export -f shocket_close
