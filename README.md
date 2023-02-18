<div align="center">

Shocket
---
A Bash library for easier interacting with WebSocket<br>
[![Latest Release](https://img.shields.io/github/v/release/UrNightmaree/shocket?style=for-the-badge)](https://github.com/UrNightmaree/shocket/releases/latest)

</div>

This library helps you with interacting WebSocket through Bash scripting language, it adds features for creating, connecting, sending and receiving text from WebSocket server!

**Table of Contents**
 * [Installation](#Installation)
 * [Usage](#Usage)
 * [API](#API)
    * [shocket_new](#shocket_new)
    * [shocket_connect](#shocket_connect)
    * [shocket_send](#shocket_send)
    * [shocket_receive](#shocket_receive)
    * [shocket_close](#shocket_close)

## Installation
Shocket dependencies:
 * `websocat` from [Websocat](https://github.com/vi/websocat).
 * `nc` from [OpenBSD variant](https://man.openbsd.org/nc.1) of netcat, [GNU variant](https://netcat.sourceforge.net/) might also works.

You can install Shocket via `bpkg`:
```bash
bpkg install UrNightmaree/shocket
```
or copy-and-paste it:
```bash
git clone https://github.com/UrNightmaree/shocket
cp shocket/shocket.sh .
```

## Usage
Shocket does not use async event or anything, just `shocket_new`, `shocket_connect` and `shocket_close`
```bash
. shocket.sh # or `source shocket.sh`

shocket_new my_ws wss://ws.ifelse.io # create `my_ws` variable with uri

echo "inside my_ws"
declare -p my_ws

if shocket_connect my_ws conn_err; then # connect to the websocket echo server
    shocket_receive my_ws >/dev/null # suppress message from server

    shocket_send my_ws 'Hello from Shocket'
    shocket_receive my_ws #=> Hello from Shocket
else echo "$conn_err"; exit 1; fi

shocket_close my_ws
```

## API

> For tracking error, append `shocket_*` function argument, e.g `shocket_connect ws err`. This will create a variable named `err` in your environment.

### shocket_new
Usage: `shocket_new <variable-name> <uri>`

Create an associative array with name based on param `variable-name` with URI `uri`
```bash
# Creates `ws_var` variable
shocket_new ws_var wss://ws.example.com

declare -p ws_var
```

### shocket_connect
Usage: `shocket_connect <variable>`

Start listening to the WebSocket server
```bash
shocket_new ws_var wss://ws.example.com

shocket_connect ws_var # Connecting and listening to `ws.example.com`
```

### shocket_send
Usage: `shocket_send <variable> <msg>`

Send a message to WebSocket server
```bash
shocket_connect ws_var

shocket_send ws_var "Hello!" # Send "Hello!" to server
```

### shocket_receive
Usage: `shocket_receive <variable>`

Receive message from WebSocket server and sent it to STDOUT
```bash
shocket_connect ws_var

shocket_send ws_var "Hello!"

shocket_receive ws_var # Sent "Hello!" to STDOUT
# or
MSG="$(shocket_receive ws_var)" # Sent "Hello!" to $MSG
```

### shocket_close
Usage: `shocket_close <variable>`

Close connection between client and server.
```bash
shocket_connect ws_var

shocket_send ws_var "Hello!"
shocket_receive ws_var

shocket_close ws_var
# Closes connection between client and server.
# Variable that is created with `shocket_new` will still remain,
# use `unset` to clear it
```
