#include <libssh2_ruby.h>

/*
 * call-seq:
 *     LibSSH2::Native.init -> int
 *
 * Initializes libssh2 to run and returns the error code (0 if no error).
 * Note that this is not threadsafe and must be called before any other
 * libssh2 method. libssh2-ruby will automatically call this for you, usually,
 * but if you're only using the methods on Native, then you must call this
 * yourself.
 *
 * */
static VALUE
init(VALUE module) {
    int result = libssh2_init(0);
    if (result != 0) {
        rb_exc_raise(libssh2_ruby_wrap_error(result));
        return Qnil;
    }

    return Qtrue;
}

/*
 * call-seq:
 *     Native.exit -> true
 *
 * Exits libssh2, deallocating any memory used internally. If this is called
 * Native.init must be called prior to doing anything with libssh2 again.
 *
 * */
static VALUE
libexit(VALUE module) {
    libssh2_exit();
    return Qtrue;
}

/*
 * call-seq:
 *     LibSSH2::Native.version -> string
 *
 * Returns the version of libssh2 that is running.
 *
 * */
static VALUE
version(VALUE module) {
    VALUE result = rb_cNilClass;
    const char *version_string = libssh2_version(0);

    // Technically `libssh2_version` can return NULL if the runtime
    // version is not new enough, but the "0" parameter above should
    // force this to always be true. Still, better safe than segfault.
    if (version_string != NULL) {
        result = rb_str_new_cstr(version_string);
    }

    return result;
}

void init_libssh2_global() {
    rb_define_singleton_method(rb_mLibSSH2_Native, "exit", libexit, 0);
    rb_define_singleton_method(rb_mLibSSH2_Native, "init", init, 0);
    rb_define_singleton_method(rb_mLibSSH2_Native, "version", version, 0);
}
