# Nim bindings for Libevent HTTP server.
# 
# Official page: https://libevent.org/
#
# (c) 2025 George Lemon | MIT License
#          Made by Humans from OpenPeeps
#          https://github.com/openpeeps/libevent-nim

import ./event

type
  Evbuffer* {.importc: "struct evbuffer", header: "<event2/event.h>", incompleteStruct.} = object
  EvbufferPtr* {.importc: "struct evbuffer_ptr", header: "<event2/event.h>", incompleteStruct.} = object
    pos*: int64
    internal*: array[2, pointer] # Opaque, do not access directly

  EvbufferIovec* {.importc: "struct evbuffer_iovec", header: "<event2/event.h>", incompleteStruct.} = object
    iov_base*: pointer
    iov_len*: csize_t

  EvbufferCbInfo* {.importc: "struct evbuffer_cb_info", header: "<event2/event.h>", incompleteStruct.} = object
    orig_size*: csize_t
    n_added*: csize_t
    n_deleted*: csize_t

  EvbufferCbEntry* {.importc: "struct evbuffer_cb_entry", header: "<event2/event.h>", incompleteStruct.} = object

  evbuffer_cb_func* = proc(buf: ptr Evbuffer, info: ptr EvbufferCbInfo, arg: pointer) {.cdecl.}
  evbuffer_ref_cleanup_cb* = proc(data: pointer, datalen: csize_t, extra: pointer) {.cdecl.}
  evbuffer_file_segment* = object
  evbuffer_file_segment_cleanup_cb* = proc(seg: ptr evbuffer_file_segment, flags: cint, arg: pointer) {.cdecl.}

const
  EVBUFFER_FLAG_DRAINS_TO_FD* = 1
  EVBUF_FS_CLOSE_ON_FREE* = 0x01
  EVBUF_FS_DISABLE_MMAP* = 0x02
  EVBUF_FS_DISABLE_SENDFILE* = 0x04
  EVBUF_FS_DISABLE_LOCKING* = 0x08
  EVBUFFER_CB_ENABLED* = 1

type
  EvbufferEolStyle* = enum
    EVBUFFER_EOL_ANY,
    EVBUFFER_EOL_CRLF,
    EVBUFFER_EOL_CRLF_STRICT,
    EVBUFFER_EOL_LF,
    EVBUFFER_EOL_NUL

  EvbufferPtrHow* = enum
    EVBUFFER_PTR_SET,
    EVBUFFER_PTR_ADD

{.push, importc, header:"<event2/buffer.h>".}
# Core buffer functions
proc evbuffer_new*(): ptr Evbuffer
proc evbuffer_free*(buf: ptr Evbuffer)
proc evbuffer_enable_locking*(buf: ptr Evbuffer, lock: pointer): cint
proc evbuffer_lock*(buf: ptr Evbuffer)
proc evbuffer_unlock*(buf: ptr Evbuffer)
proc evbuffer_set_flags*(buf: ptr Evbuffer, flags: uint64): cint
proc evbuffer_clear_flags*(buf: ptr Evbuffer, flags: uint64): cint
proc evbuffer_get_length*(buf: ptr Evbuffer): csize_t
proc evbuffer_get_contiguous_space*(buf: ptr Evbuffer): csize_t
proc evbuffer_expand*(buf: ptr Evbuffer, datlen: csize_t): cint
proc evbuffer_reserve_space*(buf: ptr Evbuffer, size: int64, vec: ptr EvbufferIovec, n_vec: cint): cint
proc evbuffer_commit_space*(buf: ptr Evbuffer, vec: ptr EvbufferIovec, n_vecs: cint): cint
proc evbuffer_add*(buf: ptr Evbuffer, data: pointer, datlen: csize_t): cint
proc evbuffer_remove*(buf: ptr Evbuffer, data: pointer, datlen: csize_t): cint
proc evbuffer_copyout*(buf: ptr Evbuffer, data_out: pointer, datlen: csize_t): int64
proc evbuffer_copyout_from*(buf: ptr Evbuffer, pos: ptr EvbufferPtr, data_out: pointer, datlen: csize_t): int64
proc evbuffer_remove_buffer*(src: ptr Evbuffer, dst: ptr Evbuffer, datlen: csize_t): cint
proc evbuffer_readln*(buffer: ptr Evbuffer, n_read_out: ptr csize_t, eol_style: EvbufferEolStyle): cstring
proc evbuffer_add_buffer*(outbuf: ptr Evbuffer, inbuf: ptr Evbuffer): cint
proc evbuffer_add_buffer_reference*(outbuf: ptr Evbuffer, inbuf: ptr Evbuffer): cint
proc evbuffer_add_reference*(outbuf: ptr Evbuffer, data: pointer, datlen: csize_t, cleanupfn: evbuffer_ref_cleanup_cb, cleanupfn_arg: pointer): cint
proc evbuffer_add_file*(outbuf: ptr Evbuffer, fd: cint, offset: int64, length: int64): cint
proc evbuffer_file_segment_new*(fd: cint, offset: int64, length: int64, flags: cuint): ptr evbuffer_file_segment
proc evbuffer_file_segment_free*(seg: ptr evbuffer_file_segment)
proc evbuffer_file_segment_add_cleanup_cb*(seg: ptr evbuffer_file_segment, cb: evbuffer_file_segment_cleanup_cb, arg: pointer)
proc evbuffer_add_file_segment*(buf: ptr Evbuffer, seg: ptr evbuffer_file_segment, offset: int64, length: int64): cint
proc evbuffer_add_printf*(buf: ptr Evbuffer, fmt: cstring): cint {.importc, varargs, header: "<event2/buffer.h>".}
proc evbuffer_add_vprintf*(buf: ptr Evbuffer, fmt: cstring, ap: pointer): cint
proc evbuffer_drain*(buf: ptr Evbuffer, len: csize_t): cint
proc evbuffer_write*(buffer: ptr Evbuffer, fd: cint): cint
proc evbuffer_write_atmost*(buffer: ptr Evbuffer, fd: cint, howmuch: int64): cint
proc evbuffer_read*(buffer: ptr Evbuffer, fd: cint, howmuch: cint): cint
proc evbuffer_search*(buffer: ptr Evbuffer, what: cstring, len: csize_t, start: ptr EvbufferPtr): EvbufferPtr
proc evbuffer_search_range*(buffer: ptr Evbuffer, what: cstring, len: csize_t, start: ptr EvbufferPtr, `end`: ptr EvbufferPtr): EvbufferPtr
proc evbuffer_ptr_set*(buffer: ptr Evbuffer, `ptr`: ptr EvbufferPtr, position: csize_t, how: EvbufferPtrHow): cint
proc evbuffer_search_eol*(buffer: ptr Evbuffer, start: ptr EvbufferPtr, eol_len_out: ptr csize_t, eol_style: EvbufferEolStyle): EvbufferPtr
proc evbuffer_peek*(buffer: ptr Evbuffer, len: int64, start_at: ptr EvbufferPtr, vec_out: ptr EvbufferIovec, n_vec: cint): cint
proc evbuffer_add_cb*(buffer: ptr Evbuffer, cb: evbuffer_cb_func, cbarg: pointer): ptr EvbufferCbEntry
proc evbuffer_remove_cb_entry*(buffer: ptr Evbuffer, ent: ptr EvbufferCbEntry): cint
proc evbuffer_remove_cb*(buffer: ptr Evbuffer, cb: evbuffer_cb_func, cbarg: pointer): cint
proc evbuffer_cb_set_flags*(buffer: ptr Evbuffer, cb: ptr EvbufferCbEntry, flags: uint32): cint
proc evbuffer_cb_clear_flags*(buffer: ptr Evbuffer, cb: ptr EvbufferCbEntry, flags: uint32): cint
proc evbuffer_pullup*(buf: ptr Evbuffer, size: int64): ptr uint8
proc evbuffer_prepend*(buf: ptr Evbuffer, data: pointer, size: csize_t): cint
proc evbuffer_prepend_buffer*(dst: ptr Evbuffer, src: ptr Evbuffer): cint
proc evbuffer_freeze*(buf: ptr Evbuffer, at_front: cint): cint
proc evbuffer_unfreeze*(buf: ptr Evbuffer, at_front: cint): cint
proc evbuffer_defer_callbacks*(buffer: ptr Evbuffer, base: ptr event_base): cint
proc evbuffer_add_iovec*(buffer: ptr Evbuffer, vec: ptr EvbufferIovec, n_vec: cint): csize_t
