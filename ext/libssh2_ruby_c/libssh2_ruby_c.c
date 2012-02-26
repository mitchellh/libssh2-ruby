#include <libssh2_ruby.h>

VALUE mLibSSH2;
VALUE mLibSSH2_Native;

void Init_libssh2_ruby_c() {
    // Define the modules we're creating
    mLibSSH2 = rb_define_module("LibSSH2");
    mLibSSH2_Native = rb_define_module_under(mLibSSH2, "Native");

    // Initialize the various parts of the C-based API. The source
    // for these are in their respective files. i.e. global.c has
    // init_libssh2_global.
    init_libssh2_global();
}
