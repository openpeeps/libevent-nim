# Nim bindings for Libevent HTTP server.
# 
# Official page: https://libevent.org/
#
# (c) 2025 George Lemon | MIT License
#          Made by Humans from OpenPeeps
#          https://github.com/openpeeps/libevent-nim

{.passL:"-L/opt/local/lib -levent", passC:"-I /opt/local/include".}

import ./libevent/bindings/[buffer, bufferevent, bufferevent_ssl, event, http, listener]
export buffer, bufferevent, event, http, listener, bufferevent_ssl