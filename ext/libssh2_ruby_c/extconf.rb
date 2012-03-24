require "mkmf"
require "rbconfig"

# Allow "--with-libssh2-dir" configuration directives...
dir_config("libssh2")

# Called to "asplode" the install in case a dependency is missing for
# this extension to compile properly. "asplode" seems to be the
# idiomatic Ruby name for this method.
def asplode(missing)
  abort "#{missing} is missing. Please install libssh2."
end

# Verify that we have libssh2
asplode("libssh2.h") if !find_header("libssh2.h")

# On Mac OS X, we can't actually statically compile a 64-bit version
# of OpenSSL, so we just link against the shared versions as well.
# Kind of a hack but it works fine.
if RbConfig::CONFIG["host_os"] =~ /^darwin/
  asplode("libcrypto") if !find_library("crypto", "CRYPTO_num_locks")
  asplode("openssl")   if !find_library("ssl", "SSL_library_init")
end

# Verify libssh2 is usable
asplode("libssh2")   if !find_library("ssh2", "libssh2_init")

# Create the makefile with the expected library name.
create_makefile("libssh2_ruby_c")
