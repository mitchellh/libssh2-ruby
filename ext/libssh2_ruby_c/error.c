#include <libssh2_ruby.h>

/*
 * This is a convenience method to quickly wrap a libssh2 error in
 * the proper class.
 * */
VALUE libssh2_ruby_wrap_error(int error) {
    VALUE instance = rb_class_new_instance(0, 0, rb_eLibSSH2_Native_Error);
    rb_iv_set(instance, "@error_code", INT2NUM(error));
    return instance;
}
