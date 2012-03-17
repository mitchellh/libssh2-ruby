# libssh2 Ruby Bindings

This library provides bindings to [libssh2](http://www.libssh2.org). LibSSH2
is a modern C-library implementing the SSH2 protocol and made by the same
people who made [cURL](http://curl.haxx.se/).

**Project status:** Alpha. Much of the library is still not yet done,
and proper cross-platform testing has not been done. However, the library
itself is functional, and everything in this README should work.

## Motivation

The creation of `libssh2-ruby` was motivated primarily by edge-case issues
experienced by [Vagrant](http://vagrantup.com) while using
[Net-SSH](https://github.com/net-ssh/net-ssh). Net-SSH has been around 7
years and is a stable library, but the Vagrant project found that around 1%
of users were experiencing connectivity issues primarily revolving around
slightly incompliant behavior by remote servers.

`libssh2` is a heavily used library created by the same people as
[cURL](http://curl.haxx.se/), simply one of the best command line applications
around. It has been around for a few years and handles the SSH2 protocol
very well. It is under active development and the motivation for libssh2
to always work is high, since it is used by many high-profile open source
projects.

For this reason, `libssh2-ruby` was made to interface with this high
quality library and provide a stable and robust SSH2 interface for Ruby.

## Usage

The API for interacting with SSH is idiomatic Ruby and you should find
it friendly and intuitive:

```ruby
require "libssh2"

# This API is not yet complete. More coming soon!

session = LibSSH2::Session.new("127.0.0.1", "2222")
session.auth_by_password("username", "password")
session.execute "echo foo" do |channel|
  channel.on_data do |data|
    puts "stdout: #{data}"
  end
end
```

However, if you require more fine-grained control, I don't want the
API to limit you in any way. Therefore, it is my intention to expose
all the native libssh2 functions on the `LibSSH2::Native`
module as singleton methods, without the `libssh2_` prefix. So if you want
to call `libssh2_init`, you actually call `LibSSH2::Native.init`. Here is
an example that executes a basic `echo` via SSH:

```ruby
require "libssh2"
require "socket"
include LibSSH2::Native

# Remember, we're using the _native_ interface so below looks a lot
# like C and some nasty Ruby code, but it is the direct interface
# to libssh2. libssh2-ruby also provides a more idiomatic Ruby interface
# that you can see above in the README.
socket = Socket.new(Socket::AF_INET, Socket::SOCK_STREAM, 0)
socket.connect Socket.sockaddr_in("2222", "127.0.0.1")

session = session_init
session_set_blocking(session, true)
session_handshake(session, socket.fileno)
userauth_password(session, "username", "password")

channel = channel_open_session(session)
channel_exec(channel, "echo hello")
data, _ = channel_read(channel)

# Outputs "hello\n"
puts data
```

## Are there any downsides? When should I use Net::SSH?

There are certainly some downsides. I've enumerated them below:

* **libssh2-ruby requires libssh2**. This library requires [libssh2](http://www.libssh2.org/)
  to be installed. On most platforms this is very easy but it is still another
  step, whereas Net::SSH is a pure Ruby implementation of the SSH protocol.
* **libssh2 can't do much for stdout/stderr ordering.** Due to the way the libssh2
  API is, the ordering of stdout/stderr is usually off. In practice this may
  or may not matter for you, and I'm working with the libssh2 team to try
  to address this issue in some way.
* **libssh2 doesn't have access to every stream/request.** If you require advanced
  SSH usage, you can manually read from specific stream IDs, but the libssh2
  evented interface won't work with custom stream IDs or request types. For the
  99% case this is not an issue, but I did want to note that this problem
  exists.

That being said, libssh2 is wonderfully stable and fast, and if you're not
negatively impacted by the above issues, then you should use it.

## Running the Tests

This library has an acceptance test suite to verify everything is working.
Since it is an acceptance test library, it will make actually SSH connections
to verify things are working properly. Running the suite is easy. First,
create a `config.yml` based on the `config.yml.example` file in the `spec`
directory. This must be configured to point to a real server that can an
SSH connection can be established to with both password and key based auth.
Once the `config.yml` is in place, run the tests:

    $ bundle exec rake

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
