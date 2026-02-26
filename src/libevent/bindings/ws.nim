# Nim bindings for Libevent HTTP server.
# 
# Official page: https://libevent.org/
# 
# This module implements high-level API bindings for
# creating an HTTP server using Libevent.
#
# (c) 2025 George Lemon | MIT License
#          Made by Humans from OpenPeeps
#          https://github.com/openpeeps/libevent-nim

import ./[event, buffer, bufferevent, http]

# {.emit: """
# #include <event2/visibility.h>

# /* Ensure both 'struct evws_connection' and 'evws_connection' are valid names */
# struct evws_connection; /* forward declaration of the tag */
# typedef struct evws_connection evws_connection;

# /* Const uchar pointer typedef we can refer to from Nim */
# typedef const unsigned char* ev_const_uchar_ptr;
# """.}


const
  WS_CR_NONE* = 0
  WS_CR_NORMAL* = 1000
  WS_CR_PROTO_ERR* = 1002
  WS_CR_DATA_TOO_BIG* = 1009

  WS_TEXT_FRAME* = 0x1
  WS_BINARY_FRAME* = 0x2

# type
#   cucharptr* {.importc: "unsigned char *", nodecl.} = pointer

type
  # evws_connection* {.importc: "struct evws_connection", header: "event2/ws.h".} = object
  # Import the opaque struct tag name (no "struct" here)
  evws_connection* {.importc: "struct evws_connection", header: "<event2/ws.h>".} = object

  # Map our const pointer typedef; nodecl so Nim won't redeclare it
  ev_const_uchar_ptr* {.importc: "ev_const_uchar_ptr", nodecl.} = pointer
  
  ws_on_msg_cb* = proc(conn: ptr evws_connection, typ: cint, data: ev_const_uchar_ptr, len: csize_t, arg: pointer) {.cdecl,.}
  ws_on_close_cb* = proc(conn: ptr evws_connection, arg: pointer) {.cdecl.}

{.push, importc, header:"<event2/ws.h>".}
proc evws_new_session*(req: ptr evhttp_request, cb: ws_on_msg_cb, arg: pointer, options: cint): ptr evws_connection
proc evws_send_text*(evws: ptr evws_connection, packet_str: cstring)
proc evws_send_binary*(evws: ptr evws_connection, packet_data: cstring, packet_len: csize_t)
proc evws_close*(evws: ptr evws_connection, reason: uint16)
proc evws_connection_set_closecb*(evws: ptr evws_connection, cb: ws_on_close_cb, arg: pointer)
proc evws_connection_free*(evws: ptr evws_connection)
proc evws_connection_get_bufferevent*(evws: ptr evws_connection): ptr bufferevent
{.pop.}