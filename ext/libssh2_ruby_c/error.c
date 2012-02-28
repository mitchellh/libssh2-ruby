#include <libssh2_ruby.h>

/*
 * This convenience method takes an error code, finds the proper error
 * class, instantiates it, and returns it.
 * */
VALUE libssh2_ruby_wrap_error(int error) {
    VALUE error_code  = INT2NUM(error);
    VALUE error_klass = rb_funcall(
            rb_mLibSSH2_Native_Error,
            rb_intern("error_for_code"),
            1,
            error_code);

    return rb_class_new_instance(1, &error_code, error_klass);
}
