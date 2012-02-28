#include <libssh2_ruby.h>

VALUE rb_mLibSSH2;
VALUE rb_mLibSSH2_Native;
VALUE rb_mLibSSH2_Native_Error;
VALUE rb_cLibSSH2_Native_Channel;
VALUE rb_cLibSSH2_Native_Session;

void Init_libssh2_ruby_c() {
    // Define the modules we're creating
    rb_mLibSSH2 = rb_define_module("LibSSH2");
    rb_mLibSSH2_Native = rb_define_module_under(rb_mLibSSH2, "Native");
    rb_mLibSSH2_Native_Error = rb_define_module_under(rb_mLibSSH2_Native, "Error");
    rb_cLibSSH2_Native_Channel = rb_define_class_under(rb_mLibSSH2_Native, "Channel", rb_cObject);
    rb_cLibSSH2_Native_Session = rb_define_class_under(rb_mLibSSH2_Native, "Session", rb_cObject);

    // Initialize the various parts of the C-based API. The source
    // for these are in their respective files. i.e. global.c has
    // init_libssh2_global.
    init_libssh2_global();
    init_libssh2_channel();
    init_libssh2_session();
}
