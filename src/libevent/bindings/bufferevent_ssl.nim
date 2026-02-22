# Nim bindings for Libevent HTTP server.
# 
# Official page: https://libevent.org/
#
# (c) 2025 George Lemon | MIT License
#          Made by Humans from OpenPeeps
#          https://github.com/openpeeps/libevent-nim

import ./bufferevent, ./event

type
  ssl_ctx_st* {.incompleteStruct.} = object
  ssl_st* {.incompleteStruct.} = object
  ssl_method_st* {.incompleteStruct.} = object
  mbedtls_dyncontext* {.incompleteStruct.} = object
  mbedtls_ssl_context* {.incompleteStruct.} = object
  mbedtls_ssl_config* {.incompleteStruct.} = object

  SSL_CTX* = ptr ssl_ctx_st
  SSL* = ptr ssl_st
  SSL_METHOD* = ptr ssl_method_st

const
  SSL_FILETYPE_PEM* = 1
  TLS1_2_VERSION* = 0x0303
  SSL_CTRL_SET_MIN_PROTO_VERSION* = 123

proc SSL_new*(ctx: ptr ssl_ctx_st): ptr ssl_st
  {.cdecl, importc: "SSL_new", header: "<openssl/ssl.h>".}
proc SSL_free*(ssl: ptr ssl_st)
  {.cdecl, importc: "SSL_free", header: "<openssl/ssl.h>".}
proc SSL_CTX_new*(m: ptr ssl_method_st): ptr ssl_ctx_st
  {.cdecl, importc: "SSL_CTX_new", header: "<openssl/ssl.h>".}
proc SSL_CTX_free*(ctx: ptr ssl_ctx_st)
  {.cdecl, importc: "SSL_CTX_free", header: "<openssl/ssl.h>".}
proc TLS_server_method*(): ptr ssl_method_st
  {.cdecl, importc: "TLS_server_method", header: "<openssl/ssl.h>".}

template SSLv23_server_method*(): ptr ssl_method_st = TLS_server_method()

proc OPENSSL_init_ssl*(opts: uint64, settings: pointer): cint
  {.cdecl, importc: "OPENSSL_init_ssl", header: "<openssl/ssl.h>".}
proc SSL_CTX_use_certificate_file*(ctx: ptr ssl_ctx_st, file: cstring, typ: cint): cint
  {.cdecl, importc: "SSL_CTX_use_certificate_file", header: "<openssl/ssl.h>".}
proc SSL_CTX_use_PrivateKey_file*(ctx: ptr ssl_ctx_st, file: cstring, typ: cint): cint
  {.cdecl, importc: "SSL_CTX_use_PrivateKey_file", header: "<openssl/ssl.h>".}
proc SSL_CTX_check_private_key*(ctx: ptr ssl_ctx_st): cint
  {.cdecl, importc: "SSL_CTX_check_private_key", header: "<openssl/ssl.h>".}
proc SSL_CTX_ctrl*(ctx: ptr ssl_ctx_st, cmd: cint, larg: clong, parg: pointer): clong
  {.cdecl, importc: "SSL_CTX_ctrl", header: "<openssl/ssl.h>".}
template SSL_CTX_set_min_proto_version*(ctx: ptr ssl_ctx_st, version: cint): cint =
  cint(SSL_CTX_ctrl(ctx, SSL_CTRL_SET_MIN_PROTO_VERSION.cint, clong(version), nil))

proc ERR_get_error*(): culong
  {.cdecl, importc: "ERR_get_error", header: "<openssl/err.h>".}
proc ERR_error_string_n*(e: culong, buf: cstring, len: csize_t)
  {.cdecl, importc: "ERR_error_string_n", header: "<openssl/err.h>".}

{.push, importc, header:"<event2/bufferevent_ssl.h>".}

# Enum definitions
type
  BuffereventSSLState* = enum
    BUFFEREVENT_SSL_OPEN = 0,
    BUFFEREVENT_SSL_CONNECTING = 1,
    BUFFEREVENT_SSL_ACCEPTING = 2

# Constants
const
  BUFFEREVENT_SSL_DIRTY_SHUTDOWN* = 1
  BUFFEREVENT_SSL_BATCH_WRITE* = 2


# Function declarations (OpenSSL)
proc bufferevent_ssl_get_flags*(bev: ptr bufferevent): uint64
proc bufferevent_ssl_set_flags*(bev: ptr bufferevent, flags: uint64): uint64
proc bufferevent_ssl_clear_flags*(bev: ptr bufferevent, flags: uint64): uint64

proc bufferevent_openssl_filter_new*(base: ptr event_base, underlying: ptr bufferevent, ssl: ptr ssl_st, state: BuffereventSSLState, options: int): ptr bufferevent
proc bufferevent_openssl_socket_new*(base: ptr event_base, fd: evutil_socket_t, ssl: ptr ssl_st, state: BuffereventSSLState, options: int): ptr bufferevent

proc bufferevent_openssl_get_allow_dirty_shutdown*(bev: ptr bufferevent): int
proc bufferevent_openssl_set_allow_dirty_shutdown*(bev: ptr bufferevent, allow_dirty_shutdown: int)
proc bufferevent_openssl_get_ssl*(bufev: ptr bufferevent): ptr ssl_st
proc bufferevent_ssl_renegotiate*(bev: ptr bufferevent): int
proc bufferevent_get_openssl_error*(bev: ptr bufferevent): culong

# Function declarations (MbedTLS)
proc bufferevent_mbedtls_filter_new*(base: ptr event_base, underlying: ptr bufferevent, ssl: ptr mbedtls_dyncontext, state: BuffereventSSLState, options: int): ptr bufferevent
proc bufferevent_mbedtls_socket_new*(base: ptr event_base, fd: evutil_socket_t, ssl: ptr mbedtls_dyncontext, state: BuffereventSSLState, options: int): ptr bufferevent

proc bufferevent_mbedtls_get_allow_dirty_shutdown*(bev: ptr bufferevent): int
proc bufferevent_mbedtls_set_allow_dirty_shutdown*(bev: ptr bufferevent, allow_dirty_shutdown: int)
proc bufferevent_mbedtls_get_ssl*(bufev: ptr bufferevent): ptr mbedtls_ssl_context
proc bufferevent_mbedtls_renegotiate*(bev: ptr bufferevent): int
proc bufferevent_get_mbedtls_error*(bev: ptr bufferevent): culong

proc bufferevent_mbedtls_dyncontext_new*(conf: ptr mbedtls_ssl_config): ptr mbedtls_dyncontext
proc bufferevent_mbedtls_dyncontext_free*(ctx: ptr mbedtls_dyncontext)

{.pop.}