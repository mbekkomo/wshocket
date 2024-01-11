<div align="center">

Shocket
---
A Bash library for easier interacting with WebSocket<br>
[![Latest Release](https://img.shields.io/github/v/release/komothecat/wshocket?style=for-the-badge)](https://github.com/komothecat/wshocket/releases/latest)

</div>

This library helps you with interacting WebSocket through Bash scripting language, it adds features for creating, connecting, sending and receiving text from WebSocket server!

**Table of Contents**
 * [Installation](#Installation)
 * [Usage](#Usage)
 * [API](#API)
    * [wshocket_new](#wshocket_new)
    * [wshocket_connect](#wshocket_connect)
    * [wshocket_send](#wshocket_send)
    * [wshocket_receive](#wshocket_receive)
    * [wshocket_close](#wshocket_close)

## Installation
Shocket dependencies:
 * `websocat` from [Websocat](https://github.com/vi/websocat).
 * `nc` from [OpenBSD variant](https://man.openbsd.org/nc.1) of netcat, [GNU variant](https://netcat.sourceforge.net/) might also works.

You can install Shocket via `bpkg`:
```bash
bpkg install komothecat/wshocket
```
or copy-and-paste it:
```bash
git clone https://github.com/komothecat/wshocket
cp wshocket/wshocket.sh .
```

## Usage
Shocket does not use async event or anything, just `wshocket_new`, `wshocket_connect` and `wshocket_close`
```bash
. wshocket.sh # or `source wshocket.sh`

wshocket_new my_ws wss://ws.ifelse.io # create `my_ws` variable with uri

echo "inside my_ws"
declare -p my_ws

if wshocket_connect my_ws conn_err; then # connect to the websocket echo server
    wshocket_receive my_ws >/dev/null # suppress message from server

    wshocket_send my_ws 'Hello from Shocket'
    wshocket_receive my_ws #=> Hello from Shocket
else echo "$conn_err"; exit 1; fi

wshocket_close my_ws
```

## API

> For tracking error, append `wshocket_*` function argument, e.g `wshocket_connect ws err`. This will create a variable named `err` in your environment.

### wshocket_new
Usage: `wshocket_new <variable-name> <uri>`

Create an associative array with name based on param `variable-name` with URI `uri`
```bash
# Creates `ws_var` variable
wshocket_new ws_var wss://ws.example.com

declare -p ws_var
```

### wshocket_connect
Usage: `wshocket_connect <variable>`

Start listening to the WebSocket server
```bash
wshocket_new ws_var wss://ws.example.com

wshocket_connect ws_var # Connecting and listening to `ws.example.com`
```

### wshocket_send
Usage: `wshocket_send <variable> <msg>`

Send a message to WebSocket server
```bash
wshocket_connect ws_var

wshocket_send ws_var "Hello!" # Send "Hello!" to server
```

### wshocket_receive
Usage: `wshocket_receive <variable>`

Receive message from WebSocket server and sent it to STDOUT
```bash
wshocket_connect ws_var

wshocket_send ws_var "Hello!"

wshocket_receive ws_var # Sent "Hello!" to STDOUT
# or
MSG="$(wshocket_receive ws_var)" # Sent "Hello!" to $MSG
```

### wshocket_close
Usage: `wshocket_close <variable>`

Close connection between client and server.
```bash
wshocket_connect ws_var

wshocket_send ws_var "Hello!"
wshocket_receive ws_var

wshocket_close ws_var
# Closes connection between client and server.
# Variable that is created with `wshocket_new` will still remain,
# use `unset` to clear it
```
