# Nim bindings for Libevent HTTP server.
# 
# Official page: https://libevent.org/
#
# (c) 2025 George Lemon | MIT License
#          Made by Humans from OpenPeeps
#          https://github.com/openpeeps/libevent-nim

import os

const ext =
  when defined(linux):
    "so"
  elif defined(windows):
    "dll"
  else:
    "dylib"

type
  # Opaque pointer types
  event_base* {.importc: "struct event_base", header: "<event2/event.h>", incompleteStruct.} = object
  event* {.importc: "struct event", header: "<event2/event.h>", incompleteStruct.} = object
  event_config* {.importc: "struct event_config", header: "<event2/event.h>", incompleteStruct.} = object
  evutil_socket_t* = cint
  ev_uint64_t* = uint64

  EventBase* = object
  Event* = object
  EventConfig* = object

  PEventBase* = ptr event_base
  PEvent* = ptr event
  PEventConfig* = ptr event_config

  EventCallbackFn* = proc(fd: cint, events: cshort, arg: pointer) {.cdecl.}
  EventLogCb* = proc(severity: cint, msg: cstring) {.cdecl.}
  EventFatalCb* = proc(err: cint) {.cdecl.}
  EventFinalizeCallbackFn* = proc(ev: ptr event, arg: pointer) {.cdecl.}
  EventBaseForeachEventCb* = proc(base: ptr event_base, ev: ptr event, arg: pointer): cint {.cdecl.}

{.push, importc, header:"<event2/event.h>", dynlib: "libevent." & ext.}

const
  EV_TIMEOUT* = 0x01
  EV_READ*    = 0x02
  EV_WRITE*   = 0x04
  EV_SIGNAL*  = 0x08
  EV_PERSIST* = 0x10
  EV_ET*      = 0x20
  EV_FINALIZE* = 0x40
  EV_CLOSED*  = 0x80

  # Log severities
  EVENT_LOG_DEBUG* = 0
  EVENT_LOG_MSG*   = 1
  EVENT_LOG_WARN*  = 2
  EVENT_LOG_ERR*   = 3

  # event_base_event_count
  EVENT_BASE_COUNT_ACTIVE* = 1'u32
  EVENT_BASE_COUNT_VIRTUAL* = 2'u32
  EVENT_BASE_COUNT_ADDED* = 4'u32

  # event_method_feature
  EV_FEATURE_ET* = 0x01
  EV_FEATURE_O1* = 0x02
  EV_FEATURE_FDS* = 0x04
  EV_FEATURE_EARLY_CLOSE* = 0x08

  # event_base_config_flag
  EVENT_BASE_FLAG_NOLOCK* = 0x01
  EVENT_BASE_FLAG_IGNORE_ENV* = 0x02
  EVENT_BASE_FLAG_STARTUP_IOCP* = 0x04
  EVENT_BASE_FLAG_NO_CACHE_TIME* = 0x08
  EVENT_BASE_FLAG_EPOLL_USE_CHANGELIST* = 0x10
  EVENT_BASE_FLAG_PRECISE_TIMER* = 0x20

  # loop flags
  EVLOOP_ONCE* = 0x01
  EVLOOP_NONBLOCK* = 0x02
  EVLOOP_NO_EXIT_ON_EMPTY* = 0x04

# Function bindings
proc event_base_new*(): ptr event_base
proc event_base_free*(base: ptr event_base)
proc event_new*(base: ptr event_base, fd: cint, events: cushort, cb: EventCallbackFn, arg: pointer): ptr event
proc event_free*(ev: ptr event)
proc event_add*(ev: ptr event, timeout: pointer): cint
proc event_del*(ev: ptr event): cint
proc event_base_dispatch*(base: ptr event_base): cint
proc event_base_get_method*(base: ptr event_base): cstring
proc event_get_supported_methods*(): ptr cstring
proc event_gettime_monotonic*(base: ptr event_base, tp: pointer): cint
proc event_base_get_num_events*(base: ptr event_base, flags: cuint): cint
proc event_base_get_max_events*(base: ptr event_base, flags: cuint, clear: cint): cint
proc event_config_new*(): ptr event_config
proc event_config_free*(cfg: ptr event_config)
proc event_config_avoid_method*(cfg: ptr event_config, `method`: cstring): cint
proc event_config_require_features*(cfg: ptr event_config, feature: cint): cint
proc event_config_set_flag*(cfg: ptr event_config, flag: cint): cint
proc event_config_set_num_cpus_hint*(cfg: ptr event_config, cpus: cint): cint
proc event_config_set_max_dispatch_interval*(
  cfg: ptr event_config,
  max_interval: pointer,
  max_callbacks: cint,
  min_priority: cint
): cint
proc event_base_new_with_config*(cfg: ptr event_config): ptr event_base
proc event_base_free_nofinalize*(base: ptr event_base)
proc event_self_cbarg*(): pointer
proc event_base_loop*(base: ptr event_base, flags: cint): cint
proc event_base_loopexit*(base: ptr event_base, tv: pointer): cint
proc event_base_loopbreak*(base: ptr event_base): cint
proc event_base_loopcontinue*(base: ptr event_base): cint
proc event_base_get_features*(base: ptr event_base): cint
proc event_base_set*(base: ptr event_base, ev: ptr event): cint
proc event_assign*(
  ev: ptr event,
  base: ptr event_base,
  fd: cint,
  events: cushort,
  cb: EventCallbackFn,
  arg: pointer
): cint

proc event_finalize*(flags: cuint, ev: ptr event, cb: EventFinalizeCallbackFn): cint
proc event_free_finalize*(flags: cuint, ev: ptr event, cb: EventFinalizeCallbackFn): cint
proc event_base_once*(base: ptr event_base, fd: cint, events: cushort, cb: EventCallbackFn, arg: pointer, timeout: pointer): cint
proc event_remove_timer*(ev: ptr event): cint
proc event_del_noblock*(ev: ptr event): cint
proc event_del_block*(ev: ptr event): cint
proc event_active*(ev: ptr event, res: cint, ncalls: cushort)
proc event_pending*(ev: ptr event, events: cushort, tv: pointer): cint
proc event_base_get_running_event*(base: ptr event_base): ptr event
proc event_initialized*(ev: ptr event): cint
proc event_get_fd*(ev: ptr event): cint
proc event_get_base*(ev: ptr event): ptr event_base
proc event_get_events*(ev: ptr event): cushort
proc event_get_callback*(ev: ptr event): EventCallbackFn
proc event_get_callback_arg*(ev: ptr event): pointer
proc event_get_priority*(ev: ptr event): cint
proc event_get_assignment*(
  ev: ptr event,
  base_out: ptr ptr event_base,
  fd_out: ptr cint,
  events_out: ptr cushort,
  cb_out: ptr EventCallbackFn,
  arg_out: ptr pointer
)
proc event_size*(): csize_t
proc event_get_version*(): cstring
proc event_get_version_number*(): uint32
proc event_base_priority_init*(base: ptr event_base, npriorities: cint): cint
proc event_base_get_npriorities*(base: ptr event_base): cint
proc event_priority_set*(ev: ptr event, priority: cint): cint
proc event_base_init_common_timeout*(base: ptr event_base, duration: pointer): pointer
proc event_enable_debug_mode*()
proc event_debug_unassign*(ev: ptr event)
proc event_set_log_callback*(cb: EventLogCb)
proc event_set_fatal_callback*(cb: EventFatalCb)
proc event_enable_debug_logging*(which: uint32)
proc event_base_got_exit*(base: ptr event_base): cint
proc event_base_got_break*(base: ptr event_base): cint
proc event_base_dump_events*(base: ptr event_base, output: pointer)
proc event_base_active_by_fd*(base: ptr event_base, fd: cint, events: cushort)
proc event_base_active_by_signal*(base: ptr event_base, sig: cint)
proc event_base_foreach_event*(base: ptr event_base, fn: EventBaseForeachEventCb, arg: pointer): cint
proc event_base_gettimeofday_cached*(base: ptr event_base, tv: pointer): cint
proc event_base_update_cache_time*(base: ptr event_base): cint
proc libevent_global_shutdown*()
proc event_set_mem_functions*(
  malloc_fn: proc(sz: csize_t): pointer {.cdecl.},
  realloc_fn: proc(`ptr`: pointer, sz: csize_t): pointer {.cdecl.},
  free_fn: proc(`ptr`: pointer) {.cdecl.}
)

{.pop.}