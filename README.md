<p align="center">👑 Nim Bindings for LibEvent</p>
<p align="center">
  <code>nimble install libevent</code>
</p>

<p align="center">
  <a href="https://openpeeps.github.io/libevent/">API reference</a><br>
  <img src="https://github.com/openpeeps/libevent/workflows/test/badge.svg" alt="Github Actions">  <img src="https://github.com/openpeeps/libevent/workflows/docs/badge.svg" alt="Github Actions">
</p>

## About
Libevent is an event notification library with a focus on asynchronous IO. It provides a mechanism to execute a callback function when a specific event occurs on a file descriptor or after a timeout has been reached. It also supports callbacks due to signals or regular timeouts.

Libevent additionally provides a sophisticated framework for buffered network IO, with support for sockets, filters, rate-limiting, SSL, zero-copy file transmission, and IOCP. Libevent includes support for several useful protocols, including DNS, HTTP, and a minimal RPC framework.

### Requirements
- [Libevent](https://libevent.org/) 2.1.12 or later
- Nim 2.0 or later

## Create a simple HTTP server

Using the bindings in this package, you can create a simple HTTP server like this:
```nim
import std/httpcore
import pkg/libevent

from std/net import Port

let eventBase = event_base_new()
assert eventBase != nil, "Could not create event base"

let httpServer = evhttp_new(eventBase)
assert httpServer != nil, "Could not create HTTP server"

template respond(str: string, code: HttpCode = HttpCode(200)) =
  let buf = evhttp_request_get_output_buffer(req)
  assert buf != nil # should never be nil
  assert evbuffer_add(buf, str.cstring, str.len.csize_t) == 0
  evhttp_send_reply(req, code.cint, "", buf)
  return

proc onRequest(req: ptr evhttp_request, arg: pointer) {.cdecl.} =
  let uri = evhttp_request_get_uri(req)
  let path = if uri.len > 0: uri else: "/"
  let httpMethod = evhttp_request_get_command(req)
  case path
  of "/":
    respond("Hello, World!")
  else:
    respond("Not Found", HttpCode(404))
  
assert evhttp_bind_socket(httpServer, "0.0.0.0", uint16(8000)) == 0
evhttp_set_gencb(httpServer, onRequest, nil)
assert event_base_dispatch(eventBase) > -1, "Could not start event loop"

# cleanup after event loop ends, which it never does in this example
evhttp_free(httpServer)
event_base_free(eventBase)
```


### ❤ Contributions & Support
- 🐛 Found a bug? [Create a new Issue](https://github.com/openpeeps/libevent-nim/issues)
- 👋 Wanna help? [Fork it!](https://github.com/openpeeps/libevent-nim/fork)
- 😎 [Get €20 in cloud credits from Hetzner](https://hetzner.cloud/?ref=Hm0mYGM9NxZ4)

### 🎩 License
MIT license. [Made by Humans from OpenPeeps](https://github.com/openpeeps).<br>
Copyright OpenPeeps & Contributors &mdash; All rights reserved.
