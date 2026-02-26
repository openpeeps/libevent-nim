# Nim bindings for Libevent HTTP server.
# 
# Official page: https://libevent.org/
#
# (c) 2025 George Lemon | MIT License
#          Made by Humans from OpenPeeps
#          https://github.com/openpeeps/libevent-nim

import ./event

# Constants for lock flags
const
  EVTHREAD_WRITE* = 0x04
  EVTHREAD_READ* = 0x08
  EVTHREAD_TRY* = 0x10

# Lock API version
const
  EVTHREAD_LOCK_API_VERSION* = 1

# Lock types
const
  EVTHREAD_LOCKTYPE_RECURSIVE* = 1
  EVTHREAD_LOCKTYPE_READWRITE* = 2

# Condition API version
const
  EVTHREAD_CONDITION_API_VERSION* = 1

type
  # Forward declaration for timeval
  Timeval* = object
    # ...define fields if needed...

  # Lock callbacks structure
  EvthreadLockCallbacks* {.importc: "struct evthread_lock_callbacks", header: "<event2/http.h>", incompleteStruct.} = object
    lock_api_version*: cint
    supported_locktypes*: cuint
    alloc*: proc(locktype: cuint): pointer {.cdecl.}
    free*: proc(lock: pointer, locktype: cuint) {.cdecl.}
    lock*: proc(mode: cuint, lock: pointer): cint {.cdecl.}
    unlock*: proc(mode: cuint, lock: pointer): cint {.cdecl.}

  # Condition callbacks structure
  EvthreadConditionCallbacks* {.importc: "struct evthread_condition_callbacks", header: "<event2/http.h>", incompleteStruct.} = object
    condition_api_version*: cint
    alloc_condition*: proc(condtype: cuint): pointer {.cdecl.}
    free_condition*: proc(cond: pointer) {.cdecl.}
    signal_condition*: proc(cond: pointer, broadcast: cint): cint {.cdecl.}
    wait_condition*: proc(cond: pointer, lock: pointer, timeout: ptr Timeval): cint {.cdecl.}

# Set lock callbacks
proc evthread_set_lock_callbacks*(cb: ptr EvthreadLockCallbacks): cint {.cdecl, importc, header: "<event2/thread.h>".}

# Set condition callbacks
proc evthread_set_condition_callbacks*(cb: ptr EvthreadConditionCallbacks): cint {.cdecl, importc, header: "<event2/thread.h>".}

# Set thread id callback
proc evthread_set_id_callback*(id_fn: proc(): culong {.cdecl.}) {.cdecl, importc, header: "<event2/thread.h>".}

# Windows threads support
proc evthread_use_windows_threads*(): cint {.cdecl, importc, header: "<event2/thread.h>".}
const
  EVTHREAD_USE_WINDOWS_THREADS_IMPLEMENTED* = 1

# Pthreads support
proc evthread_use_pthreads*(): cint {.cdecl, importc, header: "<event2/thread.h>".}
const
  EVTHREAD_USE_PTHREADS_IMPLEMENTED* = 1

# Enable lock debugging
proc evthread_enable_lock_debugging*() {.cdecl, importc, header: "<event2/thread.h>".}
proc evthread_enable_lock_debuging*() {.cdecl, importc, header: "<event2/thread.h>".} # Deprecated misspelling

# Make event base notifiable
proc evthread_make_base_notifiable*(base: ptr event_base): cint {.cdecl, importc, header: "<event2/thread.h>".}
