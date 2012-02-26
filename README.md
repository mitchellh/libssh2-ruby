# libssh2 Ruby Bindings

This library provides bindings to [libssh2](http://www.libssh2.org).

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

session = LibSSH2::Native.session_init
LibSSH2::Native.session_set_blocking(session, false)
LibSSH2::Native.session_free(session)
```
