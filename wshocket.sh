#!/usr/bin/env bash
#                _                _        _   
#               | |              | |      | |  
#  __      _____| |__   ___   ___| | _____| |_ 
#  \ \ /\ / / __| '_ \ / _ \ / __| |/ / _ \ __|
#   \ V  V /\__ \ | | | (_) | (__|   <  __/ |_ 
#    \_/\_/ |___/_| |_|\___/ \___|_|\_\___|\__|
#  -----------------------------------------------
#         A Bash module for interacting WebSocket
#         https://github.com/komothecat/wshocket
#
#  MIT License
#
#  Copyright (c) 2023 Komo
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

_util.echo() {
  echo "wshocket: $*"
}

_util.echoerr() {
  _util.echo "$@" >&2
}

_util.error() {
  _util.echoerr "$@"
  return 1
}

_util.funcerr() {
  _util.echoerr "${FUNCNAME[${LVL:-1}]}: $*"
  return 1
}

_util.param_assert() {
  local LVL=2
  if (( $# == 2 )); then
    (( $1 != $2 )) && { _util.funcerr "expected $2 arguments, got $1"; return; }
  else
    (( $1 < $2 )) && { _util.funcerr "expected at least $2 arguments, got $1"; return; }
    (( $1 > $3 )) && { _util.funcerr "expected at most $3 arguments, got $1"; return; }
  fi
  return 0
}

_util.is_ws_uri() { [[ "$1" =~ ^wss?://.+$ ]]; }

if ! (( BASH_VERSINFO[0] >= 4 && BASH_VERSINFO[1] >= 3 || BASH_VERSINFO[0] >= 5 )); then
  _util.error "wshocket only works in 4.3+ where nameref and coproc exist."
  return
fi

if ! command -v websocat >/dev/null; then
  _util.error "websocat must be installed before using wshocket!"
  return
fi

wshocket.new() {
  _util.param_assert "$#" 2 || return
  local LVL=1

  if ! _util.is_ws_uri "$2"; then
    _util.funcerr "invalid websocket uri: '$2'"
    return
  fi
} 
