# Nim bindings for Libevent HTTP server.
# 
# Official page: https://libevent.org/
#
# (c) 2025 George Lemon | MIT License
#          Made by Humans from OpenPeeps
#          https://github.com/openpeeps/libevent-nim

import posix
import ./http, ./event

{.push importc, cdecl.}

type
  sockaddr* = object # opaque, defined in posix

  evconnlistener_cb* = proc(
    listener: ptr evconnlistener,
    fd: evutil_socket_t,
    res: ptr sockaddr,
    socklen: cint,
    user_arg: pointer
  ) {.cdecl.}

  evconnlistener_errorcb* = proc(listener: ptr evconnlistener, user_arg: pointer) {.cdecl.}

const
  LEV_OPT_LEAVE_SOCKETS_BLOCKING* = (1'u32 shl 0)
  LEV_OPT_CLOSE_ON_FREE* = (1'u32 shl 1)
  LEV_OPT_CLOSE_ON_EXEC* = (1'u32 shl 2)
  LEV_OPT_REUSEABLE* = (1'u32 shl 3)
  LEV_OPT_THREADSAFE* = (1'u32 shl 4)
  LEV_OPT_DISABLED* = (1'u32 shl 5)
  LEV_OPT_DEFERRED_ACCEPT* = (1'u32 shl 6)
  LEV_OPT_REUSEABLE_PORT* = (1'u32 shl 7)
  LEV_OPT_BIND_IPV6ONLY* = (1'u32 shl 8)

proc evconnlistener_new*( base: ptr event_base, cb: evconnlistener_cb, res: pointer, flags: cuint, backlog: cint, fd: evutil_socket_t): ptr evconnlistener
  ## Creates a new connection listener that will listen for incoming connections on the specified file descriptor `fd`.

proc evconnlistener_new_bind*( base: ptr event_base, cb: evconnlistener_cb, res: pointer, flags: cuint, backlog: cint, sa: ptr sockaddr, socklen: cint): ptr evconnlistener
  ## Creates a new connection listener that will listen for incoming connections on the specified address `sa`.

proc evconnlistener_free*(lev: ptr evconnlistener)
proc evconnlistener_enable*(lev: ptr evconnlistener): cint
proc evconnlistener_disable*(lev: ptr evconnlistener): cint
proc evconnlistener_get_base*(lev: ptr evconnlistener): ptr event_base
proc evconnlistener_get_fd*(lev: ptr evconnlistener): evutil_socket_t
proc evconnlistener_set_cb*(lev: ptr evconnlistener, cb: evconnlistener_cb, arg: pointer)
proc evconnlistener_set_error_cb*(lev: ptr evconnlistener, errorcb: evconnlistener_errorcb)

{.pop.}