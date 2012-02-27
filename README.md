# libssh2 Ruby Bindings

This library provides bindings to [libssh2](http://www.libssh2.org).

**Project status:** Alpha. Much of the library is still not yet done,
and proper cross-platform testing has not been done.

## Usage

The API for interacting with SSH is idiomatic Ruby and you should find
it friendly and intuitive:

```ruby
require "libssh2"

# COMING SOON!
```

However, if you require more fine-grained control, I don't want the
API to limit you in any way. Therefore, it is my intension to expose
all the native libssh2 functions on the `LibSSH2::Native`
module as singleton methods, without the `libssh2_` prefix. So if you want
to call `libssh2_init`, you actually call `LibSSH2::Native.init`. Here is
an example that does some things with sessions:

```ruby
require "libssh2"
include LibSSH2::Native

# Remember, we're using the _native_ interface so below looks a lot
# like C and some nasty Ruby code, but it is the direct interface
# to libssh2. libssh2-ruby also provides a more idiomatic Ruby interface
# that you can see above in the README.
session = session_init
session_set_blocking(session, false)
session_handshake(session, socket.fileno)
userauth_password(session, "username", "password")

channel = channel_open_session(session)
channel_exec(channel, "echo hello")
data, _ = channel_read(channel)

# Outputs "hello\n"
puts data
```
