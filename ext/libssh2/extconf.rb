require 'mkmf'

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
asplode("libssh2") if !find_library("ssh2", "libssh2_init")

# Create the makefile with the expected library name.
create_makefile("libssh2/libssh2")
