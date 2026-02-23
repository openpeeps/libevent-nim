# Nim bindings for Libevent HTTP server.
# 
# Official page: https://libevent.org/
#
# (c) 2025 George Lemon | MIT License
#          Made by Humans from OpenPeeps
#          https://github.com/openpeeps/libevent-nim
import std/openssl
import ./bufferevent, ./event

type
  SSL* = SslPtr
  mbedtls_dyncontext* = pointer
  mbedtls_ssl_context* = pointer
  mbedtls_ssl_config* = pointer

# Use cint constants instead of an importc enum that C doesn't typedef
const
  BUFFEREVENT_SSL_OPEN* = 0.cint
  BUFFEREVENT_SSL_CONNECTING* = 1.cint
  BUFFEREVENT_SSL_ACCEPTING* = 2.cint

const
  BUFFEREVENT_SSL_DIRTY_SHUTDOWN* = 1
  BUFFEREVENT_SSL_BATCH_WRITE* = 2

# OpenSSL bufferevent functions — explicit cdecl, no push block
proc bufferevent_ssl_get_flags*(bev: ptr bufferevent): uint64
  {.cdecl, importc: "bufferevent_ssl_get_flags", header: "<event2/bufferevent_ssl.h>".}
proc bufferevent_ssl_set_flags*(bev: ptr bufferevent, flags: uint64): uint64
  {.cdecl, importc: "bufferevent_ssl_set_flags", header: "<event2/bufferevent_ssl.h>".}
proc bufferevent_ssl_clear_flags*(bev: ptr bufferevent, flags: uint64): uint64
  {.cdecl, importc: "bufferevent_ssl_clear_flags", header: "<event2/bufferevent_ssl.h>".}

proc bufferevent_openssl_filter_new*(
  base: ptr event_base, underlying: ptr bufferevent,
  ssl: SSL, state: cint, options: cint
): ptr bufferevent
  {.cdecl, importc: "bufferevent_openssl_filter_new", header: "<event2/bufferevent_ssl.h>".}

proc bufferevent_openssl_socket_new*(
  base: ptr event_base, fd: cint,
  ssl: SSL, state: cint, options: cint
): ptr bufferevent
  {.cdecl, importc: "bufferevent_openssl_socket_new", header: "<event2/bufferevent_ssl.h>".}

proc bufferevent_openssl_get_ssl*(bufev: ptr bufferevent): SSL
  {.cdecl, importc: "bufferevent_openssl_get_ssl", header: "<event2/bufferevent_ssl.h>".}

proc bufferevent_openssl_get_allow_dirty_shutdown*(bev: ptr bufferevent): cint
  {.cdecl, importc: "bufferevent_openssl_get_allow_dirty_shutdown", header: "<event2/bufferevent_ssl.h>".}
proc bufferevent_openssl_set_allow_dirty_shutdown*(bev: ptr bufferevent, allow_dirty_shutdown: cint)
  {.cdecl, importc: "bufferevent_openssl_set_allow_dirty_shutdown", header: "<event2/bufferevent_ssl.h>".}

proc bufferevent_ssl_renegotiate*(bev: ptr bufferevent): cint
  {.cdecl, importc: "bufferevent_ssl_renegotiate", header: "<event2/bufferevent_ssl.h>".}
proc bufferevent_get_openssl_error*(bev: ptr bufferevent): culong
  {.cdecl, importc: "bufferevent_get_openssl_error", header: "<event2/bufferevent_ssl.h>".}

# MbedTLS bufferevent functions
proc bufferevent_mbedtls_filter_new*(base: ptr event_base, underlying: ptr bufferevent, ssl: mbedtls_dyncontext, state: cint, options: cint): ptr bufferevent
  {.cdecl, importc: "bufferevent_mbedtls_filter_new", header: "<event2/bufferevent_ssl.h>".}
proc bufferevent_mbedtls_socket_new*(base: ptr event_base, fd: cint, ssl: mbedtls_dyncontext, state: cint, options: cint): ptr bufferevent
  {.cdecl, importc: "bufferevent_mbedtls_socket_new", header: "<event2/bufferevent_ssl.h>".}

proc bufferevent_mbedtls_get_allow_dirty_shutdown*(bev: ptr bufferevent): cint
  {.cdecl, importc: "bufferevent_mbedtls_get_allow_dirty_shutdown", header: "<event2/bufferevent_ssl.h>".}
proc bufferevent_mbedtls_set_allow_dirty_shutdown*(bev: ptr bufferevent, allow_dirty_shutdown: cint)
  {.cdecl, importc: "bufferevent_mbedtls_set_allow_dirty_shutdown", header: "<event2/bufferevent_ssl.h>".}
proc bufferevent_mbedtls_get_ssl*(bufev: ptr bufferevent): mbedtls_ssl_context
  {.cdecl, importc: "bufferevent_mbedtls_get_ssl", header: "<event2/bufferevent_ssl.h>".}
proc bufferevent_mbedtls_renegotiate*(bev: ptr bufferevent): cint
  {.cdecl, importc: "bufferevent_mbedtls_renegotiate", header: "<event2/bufferevent_ssl.h>".}
proc bufferevent_get_mbedtls_error*(bev: ptr bufferevent): culong
  {.cdecl, importc: "bufferevent_get_mbedtls_error", header: "<event2/bufferevent_ssl.h>".}

proc bufferevent_mbedtls_dyncontext_new*(conf: mbedtls_ssl_config): mbedtls_dyncontext
  {.cdecl, importc: "bufferevent_mbedtls_dyncontext_new", header: "<event2/bufferevent_ssl.h>".}
proc bufferevent_mbedtls_dyncontext_free*(ctx: mbedtls_dyncontext)
  {.cdecl, importc: "bufferevent_mbedtls_dyncontext_free", header: "<event2/bufferevent_ssl.h>".}