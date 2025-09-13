# Nim bindings for Libevent HTTP server.
# 
# Official page: https://libevent.org/
#
# (c) 2025 George Lemon | MIT License
#          Made by Humans from OpenPeeps
#          https://github.com/openpeeps/libevent-nim

import ./[event, buffer]
import std/[os]

# Bufferevent event codes
const
  BEV_EVENT_READING*   = 0x01
  BEV_EVENT_WRITING*   = 0x02
  BEV_EVENT_EOF*       = 0x10
  BEV_EVENT_ERROR*     = 0x20
  BEV_EVENT_TIMEOUT*   = 0x40
  BEV_EVENT_CONNECTED* = 0x80

# Bufferevent options
const
  BEV_OPT_CLOSE_ON_FREE*    = 1 shl 0
  BEV_OPT_THREADSAFE*       = 1 shl 1
  BEV_OPT_DEFER_CALLBACKS*  = 1 shl 2
  BEV_OPT_UNLOCK_CALLBACKS* = 1 shl 3

# Bufferevent flush modes
type
  BuffereventFlushMode* = enum
    BEV_NORMAL = 0,
    BEV_FLUSH = 1,
    BEV_FINISHED = 2

# Bufferevent trigger options
const
  BEV_TRIG_IGNORE_WATERMARKS* = 1 shl 16
  BEV_TRIG_DEFER_CALLBACKS* = BEV_OPT_DEFER_CALLBACKS

# Bufferevent filter result
type
  BuffereventFilterResult* = enum
    BEV_OK = 0,
    BEV_NEED_MORE = 1,
    BEV_ERROR = 2

# Opaque types
type
  bufferevent* {.importc: "struct bufferevent", header: "<event2/bufferevent.h>", incompleteStruct.} = object
  ev_token_bucket_cfg* {.importc: "struct ev_token_bucket_cfg", header: "<event2/bufferevent.h>", incompleteStruct.} = object
  bufferevent_rate_limit_group* {.importc: "struct bufferevent_rate_limit_group", header: "<event2/bufferevent.h>", incompleteStruct.} = object

# Callback types
type
  bufferevent_data_cb* = proc(bev: ptr bufferevent, ctx: pointer) {.cdecl.}
  bufferevent_event_cb* = proc(bev: ptr bufferevent, what: cshort, ctx: pointer) {.cdecl.}
  bufferevent_filter_cb* = proc(
    src: ptr Evbuffer,
    dst: ptr Evbuffer,
    dst_limit: csize_t,
    mode: BuffereventFlushMode,
    ctx: pointer
  ): BuffereventFilterResult {.cdecl.}

# Bufferevent API
proc bufferevent_socket_new*(base: ptr event_base, fd: evutil_socket_t, options: cint): ptr bufferevent {.cdecl, importc, header: "<event2/bufferevent.h>".}
proc bufferevent_socket_connect*(bufev: ptr bufferevent, `addr`: pointer, socklen: cint): cint {.cdecl, importc, header: "<event2/bufferevent.h>".}
proc bufferevent_socket_connect_hostname*(bufev: ptr bufferevent, evdns_base: pointer, family: cint, hostname: cstring, port: cint): cint {.cdecl, importc, header: "<event2/bufferevent.h>".}
proc bufferevent_socket_connect_hostname_hints*(bufev: ptr bufferevent, evdns_base: pointer, hints_in: pointer, hostname: cstring, port: cint): cint {.cdecl, importc, header: "<event2/bufferevent.h>".}
proc bufferevent_socket_get_dns_error*(bev: ptr bufferevent): cint {.cdecl, importc, header: "<event2/bufferevent.h>".}
proc bufferevent_base_set*(base: ptr event_base, bufev: ptr bufferevent): cint {.cdecl, importc, header: "<event2/bufferevent.h>".}
proc bufferevent_get_base*(bev: ptr bufferevent): ptr event_base {.cdecl, importc, header: "<event2/bufferevent.h>".}
proc bufferevent_priority_set*(bufev: ptr bufferevent, pri: cint): cint {.cdecl, importc, header: "<event2/bufferevent.h>".}
proc bufferevent_get_priority*(bufev: ptr bufferevent): cint {.cdecl, importc, header: "<event2/bufferevent.h>".}
proc bufferevent_free*(bufev: ptr bufferevent) {.cdecl, importc, header: "<event2/bufferevent.h>".}
proc bufferevent_setcb*(bufev: ptr bufferevent, readcb: bufferevent_data_cb, writecb: bufferevent_data_cb, eventcb: bufferevent_event_cb, cbarg: pointer) {.cdecl, importc, header: "<event2/bufferevent.h>".}
proc bufferevent_getcb*(bufev: ptr bufferevent, readcb_ptr: ptr bufferevent_data_cb, writecb_ptr: ptr bufferevent_data_cb, eventcb_ptr: ptr bufferevent_event_cb, cbarg_ptr: ptr pointer) {.cdecl, importc, header: "<event2/bufferevent.h>".}
proc bufferevent_setfd*(bufev: ptr bufferevent, fd: evutil_socket_t): cint {.cdecl, importc, header: "<event2/bufferevent.h>".}
proc bufferevent_replacefd*(bufev: ptr bufferevent, fd: evutil_socket_t): cint {.cdecl, importc, header: "<event2/bufferevent.h>".}
proc bufferevent_getfd*(bufev: ptr bufferevent): evutil_socket_t {.cdecl, importc, header: "<event2/bufferevent.h>".}
proc bufferevent_get_underlying*(bufev: ptr bufferevent): ptr bufferevent {.cdecl, importc, header: "<event2/bufferevent.h>".}
proc bufferevent_write*(bufev: ptr bufferevent, data: pointer, size: csize_t): cint {.cdecl, importc, header: "<event2/bufferevent.h>".}
proc bufferevent_write_buffer*(bufev: ptr bufferevent, buf: ptr Evbuffer): cint {.cdecl, importc, header: "<event2/bufferevent.h>".}
proc bufferevent_read*(bufev: ptr bufferevent, data: pointer, size: csize_t): csize_t {.cdecl, importc, header: "<event2/bufferevent.h>".}
proc bufferevent_read_buffer*(bufev: ptr bufferevent, buf: ptr Evbuffer): cint {.cdecl, importc, header: "<event2/bufferevent.h>".}
proc bufferevent_get_input*(bufev: ptr bufferevent): ptr Evbuffer {.cdecl, importc, header: "<event2/bufferevent.h>".}
proc bufferevent_get_output*(bufev: ptr bufferevent): ptr Evbuffer {.cdecl, importc, header: "<event2/bufferevent.h>".}
proc bufferevent_enable*(bufev: ptr bufferevent, event: cshort): cint {.cdecl, importc, header: "<event2/bufferevent.h>".}
proc bufferevent_disable*(bufev: ptr bufferevent, event: cshort): cint {.cdecl, importc, header: "<event2/bufferevent.h>".}
proc bufferevent_get_enabled*(bufev: ptr bufferevent): cshort {.cdecl, importc, header: "<event2/bufferevent.h>".}
proc bufferevent_set_timeouts*(bufev: ptr bufferevent, timeout_read: pointer, timeout_write: pointer): cint {.cdecl, importc, header: "<event2/bufferevent.h>".}
proc bufferevent_setwatermark*(bufev: ptr bufferevent, events: cshort, lowmark: csize_t, highmark: csize_t) {.cdecl, importc, header: "<event2/bufferevent.h>".}
proc bufferevent_getwatermark*(bufev: ptr bufferevent, events: cshort, lowmark: ptr csize_t, highmark: ptr csize_t): cint {.cdecl, importc, header: "<event2/bufferevent.h>".}
proc bufferevent_lock*(bufev: ptr bufferevent) {.cdecl, importc, header: "<event2/bufferevent.h>".}
proc bufferevent_unlock*(bufev: ptr bufferevent) {.cdecl, importc, header: "<event2/bufferevent.h>".}
proc bufferevent_incref*(bufev: ptr bufferevent) {.cdecl, importc, header: "<event2/bufferevent.h>".}
proc bufferevent_decref*(bufev: ptr bufferevent): cint {.cdecl, importc, header: "<event2/bufferevent.h>".}
proc bufferevent_flush*(bufev: ptr bufferevent, iotype: cshort, mode: BuffereventFlushMode): cint {.cdecl, importc, header: "<event2/bufferevent.h>".}
proc bufferevent_trigger*(bufev: ptr bufferevent, iotype: cshort, options: cint) {.cdecl, importc, header: "<event2/bufferevent.h>".}
proc bufferevent_trigger_event*(bufev: ptr bufferevent, what: cshort, options: cint) {.cdecl, importc, header: "<event2/bufferevent.h>".}
proc bufferevent_filter_new*(underlying: ptr bufferevent, input_filter: bufferevent_filter_cb, output_filter: bufferevent_filter_cb, options: cint, free_context: proc(ctx: pointer) {.cdecl.}, ctx: pointer): ptr bufferevent {.cdecl, importc, header: "<event2/bufferevent.h>".}
proc bufferevent_pair_new*(base: ptr event_base, options: cint, pair: ptr ptr bufferevent): cint {.cdecl, importc, header: "<event2/bufferevent.h>".}
proc bufferevent_pair_get_partner*(bev: ptr bufferevent): ptr bufferevent {.cdecl, importc, header: "<event2/bufferevent.h>".}
proc ev_token_bucket_cfg_new*(read_rate, read_burst, write_rate, write_burst: csize_t, tick_len: pointer): ptr ev_token_bucket_cfg {.cdecl, importc, header: "<event2/bufferevent.h>".}
proc ev_token_bucket_cfg_free*(cfg: ptr ev_token_bucket_cfg) {.cdecl, importc, header: "<event2/bufferevent.h>".}
proc bufferevent_set_rate_limit*(bev: ptr bufferevent, cfg: ptr ev_token_bucket_cfg): cint {.cdecl, importc, header: "<event2/bufferevent.h>".}
proc bufferevent_rate_limit_group_new*(base: ptr event_base, cfg: ptr ev_token_bucket_cfg): ptr bufferevent_rate_limit_group {.cdecl, importc, header: "<event2/bufferevent.h>".}
proc bufferevent_rate_limit_group_set_cfg*(group: ptr bufferevent_rate_limit_group, cfg: ptr ev_token_bucket_cfg): cint {.cdecl, importc, header: "<event2/bufferevent.h>".}
proc bufferevent_rate_limit_group_set_min_share*(group: ptr bufferevent_rate_limit_group, min_share: csize_t): cint {.cdecl, importc, header: "<event2/bufferevent.h>".}
proc bufferevent_rate_limit_group_free*(group: ptr bufferevent_rate_limit_group) {.cdecl, importc, header: "<event2/bufferevent.h>".}
proc bufferevent_add_to_rate_limit_group*(bev: ptr bufferevent, group: ptr bufferevent_rate_limit_group): cint {.cdecl, importc, header: "<event2/bufferevent.h>".}
proc bufferevent_remove_from_rate_limit_group*(bev: ptr bufferevent): cint {.cdecl, importc, header: "<event2/bufferevent.h>".}
proc bufferevent_set_max_single_read*(bev: ptr bufferevent, size: csize_t): cint {.cdecl, importc, header: "<event2/bufferevent.h>".}
proc bufferevent_set_max_single_write*(bev: ptr bufferevent, size: csize_t): cint {.cdecl, importc, header: "<event2/bufferevent.h>".}
proc bufferevent_get_max_single_read*(bev: ptr bufferevent): csize_t {.cdecl, importc, header: "<event2/bufferevent.h>".}
proc bufferevent_get_max_single_write*(bev: ptr bufferevent): csize_t {.cdecl, importc, header: "<event2/bufferevent.h>".}
proc bufferevent_get_read_limit*(bev: ptr bufferevent): csize_t {.cdecl, importc, header: "<event2/bufferevent.h>".}
proc bufferevent_get_write_limit*(bev: ptr bufferevent): csize_t {.cdecl, importc, header: "<event2/bufferevent.h>".}
proc bufferevent_get_max_to_read*(bev: ptr bufferevent): csize_t {.cdecl, importc, header: "<event2/bufferevent.h>".}
proc bufferevent_get_max_to_write*(bev: ptr bufferevent): csize_t {.cdecl, importc, header: "<event2/bufferevent.h>".}
proc bufferevent_get_token_bucket_cfg*(bev: ptr bufferevent): ptr ev_token_bucket_cfg {.cdecl, importc, header: "<event2/bufferevent.h>".}
proc bufferevent_rate_limit_group_get_read_limit*(group: ptr bufferevent_rate_limit_group): csize_t {.cdecl, importc, header: "<event2/bufferevent.h>".}
proc bufferevent_rate_limit_group_get_write_limit*(group: ptr bufferevent_rate_limit_group): csize_t {.cdecl, importc, header: "<event2/bufferevent.h>".}
proc bufferevent_decrement_read_limit*(bev: ptr bufferevent, decr: csize_t): cint {.cdecl, importc, header: "<event2/bufferevent.h>".}
proc bufferevent_decrement_write_limit*(bev: ptr bufferevent, decr: csize_t): cint {.cdecl, importc, header: "<event2/bufferevent.h>".}
proc bufferevent_rate_limit_group_decrement_read*(group: ptr bufferevent_rate_limit_group, decr: csize_t): cint {.cdecl, importc, header: "<event2/bufferevent.h>".}
proc bufferevent_rate_limit_group_decrement_write*(group: ptr bufferevent_rate_limit_group, decr: csize_t): cint {.cdecl, importc, header: "<event2/bufferevent.h>".}
proc bufferevent_rate_limit_group_get_totals*(grp: ptr bufferevent_rate_limit_group, total_read_out: ptr ev_uint64_t, total_written_out: ptr ev_uint64_t) {.cdecl, importc, header: "<event2/bufferevent.h>".}
proc bufferevent_rate_limit_group_reset_totals*(grp: ptr bufferevent_rate_limit_group) {.cdecl, importc, header: "<event2/bufferevent.h>".}
