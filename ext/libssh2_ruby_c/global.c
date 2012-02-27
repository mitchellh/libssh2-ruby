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
 *     LibSSH2::Native.session_init -> LibSSH2::Native::Session
 *
 * Creates a new LibSSH2 session and returns an object representing
 * this session.
 *
 * */
static VALUE
session_init(VALUE module) {
    // LibSSH2::Native::Session.new
    return rb_class_new_instance(0, 0, rb_cLibSSH2_Native_Session);
}

/*
 * call-seq:
 *     Native.handshake(fileno) -> int
 *
 * See `Session#handshake`
 * */
static VALUE
session_handshake(VALUE module, VALUE session, VALUE fd) {
    CHECK_SESSION(session);
    return rb_funcall(session, rb_intern("handshake"), 1, fd);
}

/*
 * call-seq:
 *     Native.set_blocking(session, true) -> true
 *
 * See `Session#set_blocking`
 * */
static VALUE
session_set_blocking(VALUE module, VALUE session, VALUE blocking) {
    CHECK_SESSION(session);
    return rb_funcall(session, rb_intern("set_blocking"), 1, blocking);
}

/*
 * call-seq:
 *     Native.userauth_password(session, "username", "password") -> true
 *
 * See `Session#userauth_password`
 * */
static VALUE
userauth_password(VALUE module, VALUE session, VALUE username, VALUE password) {
    CHECK_SESSION(session);
    return rb_funcall(session, rb_intern("userauth_password"), 2, username, password);
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
    rb_define_singleton_method(rb_mLibSSH2_Native, "session_init", session_init, 0);
    rb_define_singleton_method(rb_mLibSSH2_Native, "session_handshake", session_handshake, 2);
    rb_define_singleton_method(rb_mLibSSH2_Native, "session_set_blocking", session_set_blocking, 2);
    rb_define_singleton_method(rb_mLibSSH2_Native, "userauth_password", userauth_password, 3);
    rb_define_singleton_method(rb_mLibSSH2_Native, "version", version, 0);
}
