<div align="center">

Shocket
---
A Bash library for easier interacting with WebSocket<br>


</div>

## Usage
Shocket does not use async [![Latest Release](https://img.shields.io/github/v/release/UrNightmaree/shocket?style=for-the-badge)](https://github.com/UrNightmaree/shocket/releases/latest) or anything, just `shocket_new`, `shocket_connect` and `shocket_close`
```bash
. shocket.sh # or `source shocket.sh`

shocket_new my_ws wss://ws.ifelse.io # create `my_ws` variable with uri

echo "inside my_ws"
declare -p my_ws

shocket_connect my_ws # connect to the websocket echo server

shocket_recieve my_ws >/dev/null # suppress message from websocket echo server after connecting

shocket_send my_ws "Hello from Shocket!" # send message
shocket_recieve my_ws #=> Hello from Shocket!"

shocket_close my_ws # close the connection
```
