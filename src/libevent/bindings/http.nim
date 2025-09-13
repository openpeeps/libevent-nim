# Nim bindings for Libevent HTTP server.
# 
# Official page: https://libevent.org/
#
# (c) 2025 George Lemon | MIT License
#          Made by Humans from OpenPeeps
#          https://github.com/openpeeps/libevent-nim

import ./[event, buffer]

# Response codes
const
  HTTP_OK*                = 200
  HTTP_NOCONTENT*         = 204
  HTTP_MOVEPERM*          = 301
  HTTP_MOVETEMP*          = 302
  HTTP_NOTMODIFIED*       = 304
  HTTP_BADREQUEST*        = 400
  HTTP_NOTFOUND*          = 404
  HTTP_BADMETHOD*         = 405
  HTTP_ENTITYTOOLARGE*    = 413
  HTTP_EXPECTATIONFAILED* = 417
  HTTP_INTERNAL*          = 500
  HTTP_NOTIMPLEMENTED*    = 501
  HTTP_SERVUNAVAIL*       = 503

  # Connection/server flags
  EVHTTP_SERVER_LINGERING_CLOSE* = 0x0001
  EVHTTP_CON_REUSE_CONNECTED_ADDR* = 0x0008
  EVHTTP_CON_READ_ON_WRITE_ERROR*  = 0x0010
  EVHTTP_CON_LINGERING_CLOSE*      = 0x0020
  EVHTTP_CON_PUBLIC_FLAGS_END*     = 0x100000

# Enum types
type
  EvhttpCmdType* = enum
    EVHTTP_REQ_GET     = 1 shl 0
    EVHTTP_REQ_POST    = 1 shl 1
    EVHTTP_REQ_HEAD    = 1 shl 2
    EVHTTP_REQ_PUT     = 1 shl 3
    EVHTTP_REQ_DELETE  = 1 shl 4
    EVHTTP_REQ_OPTIONS = 1 shl 5
    EVHTTP_REQ_TRACE   = 1 shl 6
    EVHTTP_REQ_CONNECT = 1 shl 7
    EVHTTP_REQ_PATCH   = 1 shl 8

  evhttp_request_kind* = enum
    Evhttp_request  = 0
    Evhttp_response = 1

  EvhttpRequestError* = enum
    EVREQ_HTTP_TIMEOUT
    EVREQ_HTTP_EOF
    EVREQ_HTTP_INVALID_HEADER
    EVREQ_HTTP_BUFFER_ERROR
    EVREQ_HTTP_REQUEST_CANCEL
    EVREQ_HTTP_DATA_TOO_LONG

# Opaque types
type
  evhttp* {.importc: "struct evhttp", header: "<event2/http.h>", incompleteStruct.} = object
  evhttp_request* {.importc: "struct evhttp_request", header: "<event2/http.h>", incompleteStruct.} = object
  evkeyvalq* {.importc: "struct evkeyvalq", header: "<event2/http.h>", incompleteStruct.} = object
  evhttp_bound_socket* {.importc: "struct evhttp_bound_socket", header: "<event2/http.h>", incompleteStruct.} = object
  evconnlistener* {.importc: "struct evconnlistener", header: "<event2/http.h>", incompleteStruct.} = object
  evdns_base* {.importc: "struct evdns_base", header: "<event2/http.h>", incompleteStruct.} = object
  evhttp_connection* {.importc: "struct evhttp_connection", header: "<event2/http.h>", incompleteStruct.} = object
  evhttp_uri* {.importc: "struct evhttp_uri", header: "<event2/http.h>", incompleteStruct.} = object

# proc nim_evkeyvalq_iterate*(headers: ptr evkeyvalq, cb: proc(key, value: cstring, arg: pointer) {.cdecl.}, arg: pointer) {.importc, header: "<event2/http.h>".}
proc nim_evkeyvalq_iterate*(headers: pointer, cb: proc(key, value: cstring, arg: pointer) {.cdecl.}, arg: pointer) {.importc, header: "<event2/http.h>".}


# Callback types
type
  EvhttpRequestCb* = proc(req: ptr evhttp_request, arg: pointer) {.cdecl.}
  EvhttpBoundSocketForeachFn* = proc(sock: ptr evhttp_bound_socket, arg: pointer) {.cdecl.}
  EvhttpRequestHeaderCb* = proc(req: ptr evhttp_request, arg: pointer): cint {.cdecl.}
  EvhttpRequestErrorCb* = proc(err: EvhttpRequestError, arg: pointer) {.cdecl.}
  EvhttpRequestOnCompleteCb* = proc(req: ptr evhttp_request, arg: pointer) {.cdecl.}
  EvhttpConnectionCloseCb* = proc(conn: ptr evhttp_connection, arg: pointer) {.cdecl.}
  EvhttpBevcb* = proc(base: ptr event_base, arg: pointer): pointer {.cdecl.}

# HTTP server API
proc evhttp_new*(base: ptr event_base): ptr evhttp {.importc, header: "<event2/http.h>".}
proc evhttp_free*(http: ptr evhttp) {.importc, header: "<event2/http.h>".}
proc evhttp_bind_socket*(http: ptr evhttp, address: cstring, port: uint16): cint {.importc, header: "<event2/http.h>".}
proc evhttp_bind_socket_with_handle*(http: ptr evhttp, address: cstring, port: uint16): ptr evhttp_bound_socket {.importc, header: "<event2/http.h>".}
proc evhttp_accept_socket*(http: ptr evhttp, fd: cint): cint {.importc, header: "<event2/http.h>".}
proc evhttp_accept_socket_with_handle*(http: ptr evhttp, fd: cint): ptr evhttp_bound_socket {.importc, header: "<event2/http.h>".}
proc evhttp_bind_listener*(http: ptr evhttp, listener: ptr evconnlistener): ptr evhttp_bound_socket {.importc, header: "<event2/http.h>".}
proc evhttp_bound_socket_get_listener*(bound: ptr evhttp_bound_socket): ptr evconnlistener {.importc, header: "<event2/http.h>".}
proc evhttp_foreach_bound_socket*(http: ptr evhttp, fn: EvhttpBoundSocketForeachFn, arg: pointer) {.importc, header: "<event2/http.h>".}
proc evhttp_del_accept_socket*(http: ptr evhttp, bound: ptr evhttp_bound_socket) {.importc, header: "<event2/http.h>".}
proc evhttp_bound_socket_get_fd*(bound: ptr evhttp_bound_socket): cint {.importc, header: "<event2/http.h>".}
proc evhttp_set_max_headers_size*(http: ptr evhttp, max_headers_size: int64) {.importc, header: "<event2/http.h>".}
proc evhttp_set_max_body_size*(http: ptr evhttp, max_body_size: int64) {.importc, header: "<event2/http.h>".}
proc evhttp_set_default_content_type*(http: ptr evhttp, content_type: cstring) {.importc, header: "<event2/http.h>".}
proc evhttp_set_allowed_methods*(http: ptr evhttp, methods: uint16) {.importc, header: "<event2/http.h>".}
proc evhttp_set_cb*(http: ptr evhttp, path: cstring, cb: EvhttpRequestCb, cb_arg: pointer): cint {.importc, header: "<event2/http.h>".}
proc evhttp_del_cb*(http: ptr evhttp, path: cstring): cint {.importc, header: "<event2/http.h>".}
proc evhttp_set_gencb*(http: ptr evhttp, cb: EvhttpRequestCb, arg: pointer) {.importc, header: "<event2/http.h>".}
proc evhttp_set_bevcb*(http: ptr evhttp, cb: EvhttpBevcb, arg: pointer) {.importc, header: "<event2/http.h>".}
proc evhttp_add_virtual_host*(http: ptr evhttp, pattern: cstring, vhost: ptr evhttp): cint {.importc, header: "<event2/http.h>".}
proc evhttp_remove_virtual_host*(http: ptr evhttp, vhost: ptr evhttp): cint {.importc, header: "<event2/http.h>".}
proc evhttp_add_server_alias*(http: ptr evhttp, alias: cstring): cint {.importc, header: "<event2/http.h>".}
proc evhttp_remove_server_alias*(http: ptr evhttp, alias: cstring): cint {.importc, header: "<event2/http.h>".}
proc evhttp_set_timeout*(http: ptr evhttp, timeout_in_secs: cint) {.importc, header: "<event2/http.h>".}
proc evhttp_set_timeout_tv*(http: ptr evhttp, tv: pointer) {.importc, header: "<event2/http.h>".}
proc evhttp_set_flags*(http: ptr evhttp, flags: cint): cint {.importc, header: "<event2/http.h>".}

# Request/response
proc evhttp_send_error*(req: ptr evhttp_request, error: cint, reason: cstring) {.importc, header: "<event2/http.h>".}
proc evhttp_send_reply*(req: ptr evhttp_request, code: cint, reason: cstring, databuf: ptr Evbuffer) {.importc, header: "<event2/http.h>".}
proc evhttp_send_reply_start*(req: ptr evhttp_request, code: cint, reason: cstring) {.importc, header: "<event2/http.h>".}
proc evhttp_send_reply_chunk*(req: ptr evhttp_request, databuf: ptr Evbuffer) {.importc, header: "<event2/http.h>".}
proc evhttp_send_reply_chunk_with_cb*(req: ptr evhttp_request, databuf: ptr Evbuffer, cb: EvhttpConnectionCloseCb, arg: pointer) {.importc, header: "<event2/http.h>".}
proc evhttp_send_reply_end*(req: ptr evhttp_request) {.importc, header: "<event2/http.h>".}

# Client connection/request
proc evhttp_connection_base_bufferevent_new*(
  base: ptr event_base,
  dnsbase: ptr evdnsbase,
  bev: pointer,
  address: cstring,
  port: uint16
): ptr evhttp_connection {.importc, header: "<event2/http.h>".}

proc evhttp_connection_get_bufferevent*(evcon: ptr evhttp_connection): pointer {.importc, header: "<event2/http.h>".}
proc evhttp_connection_get_server*(evcon: ptr evhttp_connection): ptr evhttp {.importc, header: "<event2/http.h>".}
proc evhttp_request_new*(cb: EvhttpRequestCb, arg: pointer): ptr evhttp_request {.importc, header: "<event2/http.h>".}
proc evhttp_request_set_chunked_cb*(req: ptr evhttp_request, cb: EvhttpRequestCb) {.importc, header: "<event2/http.h>".}
proc evhttp_request_set_header_cb*(req: ptr evhttp_request, cb: EvhttpRequestHeaderCb) {.importc, header: "<event2/http.h>".}
proc evhttp_request_set_error_cb*(req: ptr evhttp_request, cb: EvhttpRequestErrorCb) {.importc, header: "<event2/http.h>".}
proc evhttp_request_set_on_complete_cb*(req: ptr evhttp_request, cb: EvhttpRequestOnCompleteCb, cb_arg: pointer) {.importc, header: "<event2/http.h>".}
proc evhttp_request_free*(req: ptr evhttp_request) {.importc, header: "<event2/http.h>".}
proc evhttp_connection_base_new*(
  base: ptr event_base,
  dnsbase: ptr evdnsbase,
  address: cstring,
  port: uint16
): ptr evhttp_connection {.importc, header: "<event2/http.h>".}
proc evhttp_connection_set_family*(evcon: ptr evhttp_connection, family: cint) {.importc, header: "<event2/http.h>".}
proc evhttp_connection_set_flags*(evcon: ptr evhttp_connection, flags: cint): cint {.importc, header: "<event2/http.h>".}
proc evhttp_request_own*(req: ptr evhttp_request) {.importc, header: "<event2/http.h>".}
proc evhttp_request_is_owned*(req: ptr evhttp_request): cint {.importc, header: "<event2/http.h>".}
proc evhttp_request_get_connection*(req: ptr evhttp_request): ptr evhttp_connection {.importc, header: "<event2/http.h>".}
proc evhttp_connection_get_base*(evcon: ptr evhttp_connection): ptr event_base {.importc, header: "<event2/http.h>".}
proc evhttp_connection_set_max_headers_size*(evcon: ptr evhttp_connection, new_max_headers_size: int64) {.importc, header: "<event2/http.h>".}
proc evhttp_connection_set_max_body_size*(evcon: ptr evhttp_connection, new_max_body_size: int64) {.importc, header: "<event2/http.h>".}
proc evhttp_connection_free*(evcon: ptr evhttp_connection) {.importc, header: "<event2/http.h>".}
proc evhttp_connection_free_on_completion*(evcon: ptr evhttp_connection) {.importc, header: "<event2/http.h>".}
proc evhttp_connection_set_local_address*(evcon: ptr evhttp_connection, address: cstring) {.importc, header: "<event2/http.h>".}
proc evhttp_connection_set_local_port*(evcon: ptr evhttp_connection, port: uint16) {.importc, header: "<event2/http.h>".}
proc evhttp_connection_set_timeout*(evcon: ptr evhttp_connection, timeout_in_secs: cint) {.importc, header: "<event2/http.h>".}
proc evhttp_connection_set_timeout_tv*(evcon: ptr evhttp_connection, tv: pointer) {.importc, header: "<event2/http.h>".}
proc evhttp_connection_set_initial_retry_tv*(evcon: ptr evhttp_connection, tv: pointer) {.importc, header: "<event2/http.h>".}
proc evhttp_connection_set_retries*(evcon: ptr evhttp_connection, retry_max: cint) {.importc, header: "<event2/http.h>".}
proc evhttp_connection_set_closecb*(evcon: ptr evhttp_connection, cb: EvhttpConnectionCloseCb, arg: pointer) {.importc, header: "<event2/http.h>".}
proc evhttp_connection_get_peer*(evcon: ptr evhttp_connection, address: ptr cstring, port: ptr uint16) {.importc, header: "<event2/http.h>".}
proc evhttp_connection_get_addr*(evcon: ptr evhttp_connection): pointer {.importc, header: "<event2/http.h>".}
proc evhttp_make_request*(evcon: ptr evhttp_connection, req: ptr evhttp_request, typ: EvhttpCmdType, uri: cstring): cint {.importc, header: "<event2/http.h>".}
proc evhttp_cancel_request*(req: ptr evhttp_request) {.importc, header: "<event2/http.h>".}

# Request accessors
proc evhttp_request_get_uri*(req: ptr evhttp_request): cstring {.importc, header: "<event2/http.h>".}
proc evhttp_request_get_evhttp_uri*(req: ptr evhttp_request): ptr evhttp_uri {.importc, header: "<event2/http.h>".}
proc evhttp_request_get_command*(req: ptr evhttp_request): EvhttpCmdType {.importc, header: "<event2/http.h>".}
proc evhttp_request_get_response_code*(req: ptr evhttp_request): cint {.importc, header: "<event2/http.h>".}
proc evhttp_request_get_response_code_line*(req: ptr evhttp_request): cstring {.importc, header: "<event2/http.h>".}
proc evhttp_request_get_input_headers*(req: ptr evhttp_request): ptr evkeyvalq {.importc, header: "<event2/http.h>".}
proc evhttp_request_get_output_headers*(req: ptr evhttp_request): ptr evkeyvalq {.importc, header: "<event2/http.h>".}
proc evhttp_request_get_input_buffer*(req: ptr evhttp_request): ptr Evbuffer {.importc, header: "<event2/http.h>".}
proc evhttp_request_get_output_buffer*(req: ptr evhttp_request): ptr Evbuffer {.importc, header: "<event2/http.h>".}
proc evhttp_request_get_host*(req: ptr evhttp_request): cstring {.importc, header: "<event2/http.h>".}

# Header manipulation
proc evhttp_find_header*(headers: ptr evkeyvalq, key: cstring): cstring {.importc, header: "<event2/http.h>".}
proc evhttp_remove_header*(headers: ptr evkeyvalq, key: cstring): cint {.importc, header: "<event2/http.h>".}
proc evhttp_add_header*(headers: ptr evkeyvalq, key: cstring, value: cstring): cint {.importc, header: "<event2/http.h>".}
proc evhttp_clear_headers*(headers: ptr evkeyvalq) {.importc, header: "<event2/http.h>".}

# URI helpers
proc evhttp_encode_uri*(str: cstring): cstring {.importc, header: "<event2/http.h>".}
proc evhttp_uriencode*(str: cstring, size: int64, space_to_plus: cint): cstring {.importc, header: "<event2/http.h>".}
proc evhttp_decode_uri*(uri: cstring): cstring {.importc, header: "<event2/http.h>".}
proc evhttp_uridecode*(uri: cstring, decode_plus: cint, size_out: ptr csize_t): cstring {.importc, header: "<event2/http.h>".}
proc evhttp_parse_query*(uri: cstring, headers: ptr evkeyvalq): cint {.importc, header: "<event2/http.h>".}
proc evhttp_parse_query_str*(query: cstring, headers: ptr evkeyvalq): cint {.importc, header: "<event2/http.h>".}
proc evhttp_htmlescape*(html: cstring): cstring {.importc, header: "<event2/http.h>".}

# URI struct helpers
proc evhttp_uri_new*(): ptr evhttp_uri {.importc, header: "<event2/http.h>".}
proc evhttp_uri_set_flags*(uri: ptr evhttp_uri, flags: cuint) {.importc, header: "<event2/http.h>".}
proc evhttp_uri_get_scheme*(uri: ptr evhttp_uri): cstring {.importc, header: "<event2/http.h>".}
proc evhttp_uri_get_userinfo*(uri: ptr evhttp_uri): cstring {.importc, header: "<event2/http.h>".}
proc evhttp_uri_get_host*(uri: ptr evhttp_uri): cstring {.importc, header: "<event2/http.h>".}
proc evhttp_uri_get_port*(uri: ptr evhttp_uri): cint {.importc, header: "<event2/http.h>".}
proc evhttp_uri_get_path*(uri: ptr evhttp_uri): cstring {.importc, header: "<event2/http.h>".}
proc evhttp_uri_get_query*(uri: ptr evhttp_uri): cstring {.importc, header: "<event2/http.h>".}
proc evhttp_uri_get_fragment*(uri: ptr evhttp_uri): cstring {.importc, header: "<event2/http.h>".}
proc evhttp_uri_set_scheme*(uri: ptr evhttp_uri, scheme: cstring): cint {.importc, header: "<event2/http.h>".}
proc evhttp_uri_set_userinfo*(uri: ptr evhttp_uri, userinfo: cstring): cint {.importc, header: "<event2/http.h>".}
proc evhttp_uri_set_host*(uri: ptr evhttp_uri, host: cstring): cint {.importc, header: "<event2/http.h>".}
proc evhttp_uri_set_port*(uri: ptr evhttp_uri, port: cint): cint {.importc, header: "<event2/http.h>".}
proc evhttp_uri_set_path*(uri: ptr evhttp_uri, path: cstring): cint {.importc, header: "<event2/http.h>".}
proc evhttp_uri_set_query*(uri: ptr evhttp_uri, query: cstring): cint {.importc, header: "<event2/http.h>".}
proc evhttp_uri_set_fragment*(uri: ptr evhttp_uri, fragment: cstring): cint {.importc, header: "<event2/http.h>".}
proc evhttp_uri_parse_with_flags*(source_uri: cstring, flags: cuint): ptr evhttp_uri {.importc, header: "<event2/http.h>".}
proc evhttp_uri_parse*(source_uri: cstring): ptr evhttp_uri {.importc, header: "<event2/http.h>".}
proc evhttp_uri_free*(uri: ptr evhttp_uri) {.importc, header: "<event2/http.h>".}
proc evhttp_uri_join*(uri: ptr evhttp_uri, buf: cstring, limit: csize_t): cstring {.importc, header: "<event2/http.h>".}
